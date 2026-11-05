/*
 * Tutorial 5B - Universal UEFI Bootloader chạy trên máy thật
 * Mai Duy Hieu - 20223967
 *
 * Dựa trên code trong PDF, thêm hai bài tập:
 *   Exercise 1: DrawHeader() vẽ banner tên + MSSV căn giữa ở mọi màn hình,
 *               độ rộng lấy từ QueryMode() chứ không cố định 80 cột.
 *   Exercise 2: menu chọn bằng phím mũi tên, mục đang chọn tô màu đảo ngược,
 *               mỗi lần di chuyển chỉ vẽ lại 2 dòng thay đổi, kèm device path của ổ.
 *
 * Đồng thời sửa các lỗi của code gốc khi chạy trên máy thật (xem README.md):
 * WaitForEvent nhận Index = NULL, vòng đọc thư mục có thể lặp vô hạn, tràn mảng Entries,
 * watchdog 5 phút, firmware "fast boot" không kết nối hết các ổ.
 */

#include <efi.h>
#include <efilib.h>

#define MAX_ENTRIES      20
#define TIMEOUT_SECONDS  5
#define NAME_LEN         64
#define PATH_LEN         256
#define LINE_MAX         512    // đủ cho text mode rộng nhất (firmware thật có thể > 200 cột)

#define STUDENT_NAME  L"Mai Duy Hieu"
#define STUDENT_ID    L"20223967"

// Device path subtype của NVMe (UEFI spec 10.3.4.21), header gnu-efi không có
#define MSG_NVME_NAMESPACE_DP  0x17

#define COLOR_NORMAL    (EFI_LIGHTGRAY | EFI_BACKGROUND_BLACK)
#define COLOR_TITLE     (EFI_WHITE | EFI_BACKGROUND_BLACK)
#define COLOR_DIM       (EFI_DARKGRAY | EFI_BACKGROUND_BLACK)
#define COLOR_ERROR     (EFI_LIGHTRED | EFI_BACKGROUND_BLACK)
#define COLOR_HEADER    (EFI_YELLOW | EFI_BACKGROUND_BLUE)
#define COLOR_HEADER2   (EFI_LIGHTCYAN | EFI_BACKGROUND_BLUE)
#define COLOR_SELECTED  (EFI_BLACK | EFI_BACKGROUND_LIGHTGRAY)   // đảo ngược COLOR_NORMAL

// Bố cục màn hình menu (đơn vị: dòng)
#define HEADER_ROWS  2              // dòng 0-1: banner
#define TITLE_ROW    2
#define LIST_TOP     3              // mục đầu tiên của danh sách
#define BOTTOM_ROWS  3              // 2 dòng chi tiết + 1 dòng phím tắt

typedef struct {
    CHAR16        Name[NAME_LEN];
    CHAR16        Path[PATH_LEN];   // vd \EFI\ubuntu\shimx64.efi
    EFI_HANDLE    DeviceHandle;     // phân vùng chứa file
    CHAR16       *DevStr;           // DevicePathToStr(...) của phân vùng, phải FreePool
    CONST CHAR16 *Kind;             // USB / NVMe / SATA ...
} BootEntry;

static EFI_HANDLE gImageHandle;
static BootEntry  Entries[MAX_ENTRIES];
static UINTN      EntryCount;

static UINTN      Cols = 80, Rows = 25;   // cập nhật trong DrawHeader()
static UINTN      Sel, Top;               // mục đang chọn, mục đầu tiên đang hiện

/* ------------------------------------------------------------------ */
/* Chuỗi                                                               */
/* ------------------------------------------------------------------ */

// StrCpy/StrCat của code gốc không kiểm tra độ dài; bản này luôn cắt và có '\0'
static VOID StrCopyN(CHAR16 *Dst, CONST CHAR16 *Src, UINTN DstLen) {
    UINTN i = 0;
    while (Src[i] && i + 1 < DstLen) {
        Dst[i] = Src[i];
        i++;
    }
    Dst[i] = 0;
}

static VOID StrAppendN(CHAR16 *Dst, CONST CHAR16 *Src, UINTN DstLen) {
    UINTN n = StrLen(Dst);
    if (n < DstLen)
        StrCopyN(Dst + n, Src, DstLen - n);
}

// Nối Src vào Dst thành một cột rộng đúng Width ký tự (cắt bớt hoặc đệm khoảng trắng).
// Print của gnu-efi không hỗ trợ căn trái kiểu "%-24s" nên phải tự làm.
static VOID AppendColumn(CHAR16 *Dst, CONST CHAR16 *Src, UINTN Width) {
    UINTN n = StrLen(Dst), End = n + Width;
    if (End > LINE_MAX - 1)
        End = LINE_MAX - 1;
    while (*Src && n + 1 < End)       // chừa ít nhất 1 khoảng trắng giữa các cột
        Dst[n++] = *Src++;
    while (n < End)
        Dst[n++] = L' ';
    Dst[n] = 0;
}

/* ------------------------------------------------------------------ */
/* Màn hình                                                            */
/* ------------------------------------------------------------------ */

static VOID SetColor(UINTN Attr) {
    uefi_call_wrapper(ST->ConOut->SetAttribute, 2, ST->ConOut, Attr);
}

static VOID GotoXY(UINTN Col, UINTN Row) {
    uefi_call_wrapper(ST->ConOut->SetCursorPosition, 3, ST->ConOut, Col, Row);
}

static VOID ShowCursor(BOOLEAN Visible) {
    uefi_call_wrapper(ST->ConOut->EnableCursor, 2, ST->ConOut, Visible);
}

// Kích thước text mode hiện tại. Firmware thật có từ 80x25 tới hơn 200 cột.
static VOID QueryScreen(VOID) {
    if (EFI_ERROR(uefi_call_wrapper(ST->ConOut->QueryMode, 4, ST->ConOut,
                                    ST->ConOut->Mode->Mode, &Cols, &Rows))) {
        Cols = 80;
        Rows = 25;
    }
    if (Cols > LINE_MAX - 1)
        Cols = LINE_MAX - 1;
    if (Rows < 10)
        Rows = 10;
}

/*
 * In Text tại (Col, Row), chiếm đúng Width ô: dài quá thì cắt và thêm "...",
 * ngắn thì đệm khoảng trắng để màu nền phủ hết, xoá luôn chữ cũ còn sót lại.
 */
static VOID PutText(UINTN Col, UINTN Row, CONST CHAR16 *Text, UINTN Width) {
    static CHAR16 Buf[LINE_MAX];
    UINTN i;

    if (Width > LINE_MAX - 1)
        Width = LINE_MAX - 1;
    for (i = 0; i < Width && Text[i]; i++)
        Buf[i] = Text[i];
    if (Text[i] && Width > 3)
        Buf[Width - 1] = Buf[Width - 2] = Buf[Width - 3] = L'.';
    for (; i < Width; i++)
        Buf[i] = L' ';
    Buf[Width] = 0;
    GotoXY(Col, Row);
    uefi_call_wrapper(ST->ConOut->OutputString, 2, ST->ConOut, Buf);
}

// Tô cả dòng Row bằng màu Attr rồi in Text ở giữa
static VOID PutCentered(UINTN Row, CONST CHAR16 *Text, UINTN Attr) {
    UINTN Len = StrLen(Text);
    UINTN Col = Len < Cols ? (Cols - Len) / 2 : 0;

    SetColor(Attr);
    PutText(0, Row, L"", Cols);
    PutText(Col, Row, Text, Len < Cols - Col ? Len : Cols - Col);
}

/*
 * Exercise 1: banner định danh. Gọi ngay sau mọi lần ClearScreen (qua NewScreen()).
 * Kích thước màn hình được hỏi lại mỗi lần, vì chương trình được boot (rồi thoát ra)
 * hoặc phím M có thể đã đổi text mode.
 */
static VOID DrawHeader(VOID) {
    CHAR16 Info[96];

    QueryScreen();
    PutCentered(0, STUDENT_NAME L"  -  MSSV " STUDENT_ID, COLOR_HEADER);
    UnicodeSPrint(Info, sizeof(Info), L"Universal Bootloader  |  Tutorial 5B  |  text mode %dx%d",
                  (int)Cols, (int)Rows);
    PutCentered(1, Info, COLOR_HEADER2);
    SetColor(COLOR_NORMAL);   // trả lại màu thường cho phần còn lại
    GotoXY(0, HEADER_ROWS + 1);
}

static VOID NewScreen(VOID) {
    SetColor(COLOR_NORMAL);   // ClearScreen tô nền bằng màu hiện tại
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);
    DrawHeader();
}

// Phím M: chuyển sang text mode kế tiếp mà firmware hỗ trợ (để thử căn giữa ở nhiều cỡ)
static VOID NextTextMode(VOID) {
    INT32 Cur = ST->ConOut->Mode->Mode, Max = ST->ConOut->Mode->MaxMode;
    UINTN C, R;

    for (INT32 m = (Cur + 1) % Max; m != Cur; m = (m + 1) % Max)
        if (!EFI_ERROR(uefi_call_wrapper(ST->ConOut->QueryMode, 4, ST->ConOut, m, &C, &R)) &&
            !EFI_ERROR(uefi_call_wrapper(ST->ConOut->SetMode, 2, ST->ConOut, m)))
            break;
    ShowCursor(FALSE);
}

/* ------------------------------------------------------------------ */
/* Bàn phím                                                            */
/* ------------------------------------------------------------------ */

static EFI_INPUT_KEY WaitKey(VOID) {
    EFI_INPUT_KEY Key;
    UINTN Index;   // code gốc truyền NULL: sai spec UEFI, firmware thật có thể treo
    do {
        uefi_call_wrapper(BS->WaitForEvent, 3, 1, &ST->ConIn->WaitForKey, &Index);
    } while (EFI_ERROR(uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, &Key)));
    return Key;
}

// Chờ phím tối đa Ms mili giây. Trả về TRUE nếu có phím.
static BOOLEAN PollKey(UINTN Ms, EFI_INPUT_KEY *Key) {
    for (UINTN t = 0; t < Ms; t += 10) {
        if (!EFI_ERROR(uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, Key)))
            return TRUE;
        uefi_call_wrapper(BS->Stall, 1, 10000);
    }
    return FALSE;
}

static BOOLEAN IsEnter(EFI_INPUT_KEY Key) {
    return Key.UnicodeChar == CHAR_CARRIAGE_RETURN || Key.UnicodeChar == CHAR_LINEFEED;
}

static VOID PressAnyKey(VOID) {
    SetColor(COLOR_DIM);
    Print(L"\n Press any key to continue...");
    WaitKey();
}

/* ------------------------------------------------------------------ */
/* Quét ổ đĩa                                                          */
/* ------------------------------------------------------------------ */

// Loại ổ = node "messaging" trong device path: USB(...), NVMe(...), Sata(...)
static CONST CHAR16 *DiskKind(EFI_DEVICE_PATH *Dp) {
    CONST CHAR16 *Kind = L"Disk";
    for (EFI_DEVICE_PATH *N = Dp; N && !IsDevicePathEnd(N); N = NextDevicePathNode(N)) {
        if (DevicePathType(N) == MEDIA_DEVICE_PATH && DevicePathSubType(N) == MEDIA_CDROM_DP)
            Kind = L"CD";
        if (DevicePathType(N) != MESSAGING_DEVICE_PATH)
            continue;
        switch (DevicePathSubType(N)) {
        case MSG_USB_DP:            Kind = L"USB";  break;
        case MSG_NVME_NAMESPACE_DP: Kind = L"NVMe"; break;
        case MSG_SATA_DP:           Kind = L"SATA"; break;
        case MSG_ATAPI_DP:          Kind = L"ATA";  break;
        case MSG_SCSI_DP:           Kind = L"SCSI"; break;
        }
    }
    return Kind;
}

static VOID AddEntry(CONST CHAR16 *Name, CONST CHAR16 *Path, EFI_HANDLE Device) {
    BootEntry *E;
    EFI_DEVICE_PATH *Dp;

    if (EntryCount >= MAX_ENTRIES)   // code gốc thêm Windows mà không kiểm tra -> tràn mảng
        return;
    E = &Entries[EntryCount++];
    StrCopyN(E->Name, Name, NAME_LEN);
    StrCopyN(E->Path, Path, PATH_LEN);
    E->DeviceHandle = Device;

    Dp = DevicePathFromHandle(Device);         // thuộc firmware, không được free
    E->DevStr = Dp ? DevicePathToStr(Dp) : NULL;   // chuỗi mới cấp phát -> FreePool sau
    E->Kind = Dp ? DiskKind(Dp) : L"?";
}

static VOID FreeEntries(VOID) {
    for (UINTN i = 0; i < EntryCount; i++)
        if (Entries[i].DevStr)
            FreePool(Entries[i].DevStr);
    EntryCount = 0;
}

static BOOLEAN FileExists(EFI_FILE_HANDLE Root, CONST CHAR16 *Path) {
    EFI_FILE_HANDLE File;
    if (EFI_ERROR(uefi_call_wrapper(Root->Open, 5, Root, &File, (CHAR16 *)Path,
                                    EFI_FILE_MODE_READ, 0)))
        return FALSE;
    uefi_call_wrapper(File->Close, 1, File);
    return TRUE;
}

// Loader của các distro Linux, ưu tiên shim (Ubuntu, Fedora... cài cả shim lẫn grub)
static CONST CHAR16 *LinuxLoaders[] = { L"shimx64.efi", L"grubx64.efi", L"systemd-bootx64.efi" };

static VOID ScanFilesystem(EFI_HANDLE Device, EFI_FILE_HANDLE Root) {
    EFI_FILE_HANDLE EfiDir;
    UINT64 Buf[128];   // UINT64 để căn lề 8 byte cho EFI_FILE_INFO
    EFI_FILE_INFO *Info = (EFI_FILE_INFO *)Buf;
    CHAR16 Path[PATH_LEN];

    // 1. Windows
    if (FileExists(Root, L"\\EFI\\Microsoft\\Boot\\bootmgfw.efi"))
        AddEntry(L"Windows Boot Manager", L"\\EFI\\Microsoft\\Boot\\bootmgfw.efi", Device);

    // 2. Linux: \EFI\<distro>\<loader>
    if (EFI_ERROR(uefi_call_wrapper(Root->Open, 5, Root, &EfiDir, L"\\EFI", EFI_FILE_MODE_READ, 0)))
        return;
    while (EntryCount < MAX_ENTRIES) {
        UINTN Size = sizeof(Buf);
        // Code gốc chỉ dừng khi gặp EFI_NOT_FOUND, lỗi khác sẽ làm vòng lặp chạy mãi
        if (EFI_ERROR(uefi_call_wrapper(EfiDir->Read, 3, EfiDir, &Size, Info)) || Size == 0)
            break;
        if (!(Info->Attribute & EFI_FILE_DIRECTORY) ||
            StrCmp(Info->FileName, L".") == 0 || StrCmp(Info->FileName, L"..") == 0 ||
            StriCmp(Info->FileName, L"Microsoft") == 0 || StriCmp(Info->FileName, L"Boot") == 0)
            continue;
        for (UINTN k = 0; k < sizeof(LinuxLoaders) / sizeof(LinuxLoaders[0]); k++) {
            StrCopyN(Path, L"\\EFI\\", PATH_LEN);
            StrAppendN(Path, Info->FileName, PATH_LEN);
            StrAppendN(Path, L"\\", PATH_LEN);
            StrAppendN(Path, LinuxLoaders[k], PATH_LEN);
            if (FileExists(Root, Path)) {
                AddEntry(Info->FileName, Path, Device);
                break;
            }
        }
    }
    uefi_call_wrapper(EfiDir->Close, 1, EfiDir);
}

// Firmware thật hay bật "fast boot": chỉ kết nối ổ đang boot. Phải tự ConnectController
// thì mới thấy ổ NVMe/SATA bên trong khi boot từ USB (và ngược lại).
static VOID ConnectAllControllers(VOID) {
    EFI_HANDLE *Handles;
    UINTN Count;

    if (EFI_ERROR(uefi_call_wrapper(BS->LocateHandleBuffer, 5, AllHandles, NULL, NULL,
                                    &Count, &Handles)))
        return;
    for (UINTN i = 0; i < Count; i++)
        uefi_call_wrapper(BS->ConnectController, 4, Handles[i], NULL, NULL, TRUE);
    FreePool(Handles);
}

static VOID ScanAllDisks(VOID) {
    EFI_HANDLE *Handles;
    UINTN Count;

    NewScreen();
    Print(L" Scanning disks...\n");
    FreeEntries();
    ConnectAllControllers();
    if (EFI_ERROR(uefi_call_wrapper(BS->LocateHandleBuffer, 5, ByProtocol, &FileSystemProtocol,
                                    NULL, &Count, &Handles)))
        return;
    for (UINTN i = 0; i < Count; i++) {
        EFI_FILE_HANDLE Root = LibOpenRoot(Handles[i]);
        if (Root) {
            ScanFilesystem(Handles[i], Root);
            uefi_call_wrapper(Root->Close, 1, Root);
        }
    }
    FreePool(Handles);
    Sel = Top = 0;
}

/* ------------------------------------------------------------------ */
/* Boot                                                                */
/* ------------------------------------------------------------------ */

static VOID Boot(BootEntry *E) {
    EFI_DEVICE_PATH *Dp;
    EFI_HANDLE Image;
    EFI_STATUS Status;

    NewScreen();
    SetColor(COLOR_TITLE);
    Print(L" Starting %s\n\n", E->Name);
    SetColor(COLOR_NORMAL);
    Print(L" Disk : %s\n File : %s\n", E->DevStr ? E->DevStr : L"?", E->Path);

    // Device path đầy đủ = device path của phân vùng + node file path
    Dp = FileDevicePath(E->DeviceHandle, E->Path);
    if (!Dp) {
        SetColor(COLOR_ERROR);
        Print(L"\n Out of memory.\n");
        PressAnyKey();
        return;
    }
    Status = uefi_call_wrapper(BS->LoadImage, 6, FALSE, gImageHandle, Dp, NULL, 0, &Image);
    FreePool(Dp);
    if (EFI_ERROR(Status)) {
        SetColor(COLOR_ERROR);
        Print(L"\n LoadImage failed: %r\n", Status);
        if (Status == EFI_SECURITY_VIOLATION)
            Print(L" Secure Boot rejected the file. Disable Secure Boot in the firmware setup.\n");
        PressAnyKey();
        return;
    }

    // Không xoá màn hình: OS loader (GRUB, Windows Boot Manager) tự vẽ màn hình của nó
    SetColor(COLOR_NORMAL);
    Status = uefi_call_wrapper(BS->StartImage, 3, Image, NULL, NULL);

    // Chỉ tới được đây nếu chương trình kia thoát ra (fake OS, EFI shell, loader lỗi...)
    uefi_call_wrapper(BS->SetWatchdogTimer, 4, 0, 0, 0, NULL);
    ShowCursor(FALSE);
    NewScreen();
    Print(L" %s returned: %r\n", E->Name, Status);
    PressAnyKey();
}

/* ------------------------------------------------------------------ */
/* Exercise 2: menu phím mũi tên                                       */
/* ------------------------------------------------------------------ */

static UINTN VisibleRows(VOID) {
    return Rows - LIST_TOP - BOTTOM_ROWS;
}

// Vẽ một mục. Chỉ hàm này và DrawDetail() chạy khi di chuyển trong cùng một trang.
static VOID DrawItem(UINTN i) {
    CHAR16 Line[LINE_MAX], Num[8];
    BootEntry *E = &Entries[i];

    UnicodeSPrint(Num, sizeof(Num), L" %2d.", (int)(i + 1));
    Line[0] = 0;
    AppendColumn(Line, Num, 6);
    AppendColumn(Line, E->Name, 24);
    AppendColumn(Line, E->Kind, 6);
    StrAppendN(Line, E->DevStr ? E->DevStr : L"(no device path)", LINE_MAX);

    SetColor(i == Sel ? COLOR_SELECTED : COLOR_NORMAL);
    PutText(0, LIST_TOP + (i - Top), Line, Cols - 1);
}

// 2 dòng cuối: đường dẫn đầy đủ sẽ đưa cho LoadImage (device path ổ + file) của mục đang chọn
static VOID DrawDetail(VOID) {
    CHAR16 Full[LINE_MAX];
    UINTN W = Cols - 2, Len;

    SetColor(COLOR_DIM);
    if (EntryCount == 0) {
        PutText(0, Rows - 3, L"", Cols - 1);
        PutText(0, Rows - 2, L"", Cols - 1);
        return;
    }
    StrCopyN(Full, Entries[Sel].DevStr ? Entries[Sel].DevStr : L"?", LINE_MAX);
    StrAppendN(Full, L"/", LINE_MAX);
    StrAppendN(Full, Entries[Sel].Path, LINE_MAX);
    Len = StrLen(Full);
    PutText(0, Rows - 3, L" ", 1);
    PutText(1, Rows - 3, Full, W);
    PutText(0, Rows - 2, L" ", 1);
    PutText(1, Rows - 2, Len > W ? Full + W : L"", W);
}

// Tiêu đề + mọi mục trong trang hiện tại (dùng khi trang cuộn hoặc vẽ lại cả màn hình)
static VOID DrawList(VOID) {
    CHAR16 Title[96], Range[32];
    UINTN Vis = VisibleRows();

    if (EntryCount > Vis)
        UnicodeSPrint(Range, sizeof(Range), L"[%d-%d of %d]", (int)(Top + 1),
                      (int)(Top + Vis < EntryCount ? Top + Vis : EntryCount), (int)EntryCount);
    else
        UnicodeSPrint(Range, sizeof(Range), L"[%d found]", (int)EntryCount);
    Title[0] = 0;
    AppendColumn(Title, L" Choose an operating system", 40);
    StrAppendN(Title, Range, 96);
    SetColor(COLOR_TITLE);
    PutText(0, TITLE_ROW, Title, Cols - 1);

    for (UINTN r = 0; r < Vis; r++) {
        if (Top + r < EntryCount) {
            DrawItem(Top + r);
        } else {
            SetColor(r == 0 && EntryCount == 0 ? COLOR_ERROR : COLOR_NORMAL);
            PutText(0, LIST_TOP + r,
                    r == 0 && EntryCount == 0 ? L"  No operating system found. Press R to rescan."
                                              : L"", Cols - 1);
        }
    }
}

static VOID DrawMenu(VOID) {
    NewScreen();
    // Rows có thể vừa đổi (phím M, hoặc chương trình được boot đã đổi text mode):
    // kéo trang sao cho mục đang chọn vẫn nằm trong phần nhìn thấy
    if (Sel < Top)
        Top = Sel;
    if (Sel >= Top + VisibleRows())
        Top = Sel - VisibleRows() + 1;
    DrawList();
    DrawDetail();
    SetColor(COLOR_DIM);
    PutText(0, Rows - 1,
            L" Up/Down/Home/End: move  Enter/1-20: boot  R: rescan  M: text mode  Esc: exit",
            Cols - 1);
}

// Đổi mục đang chọn. Nếu mục mới vẫn trong trang thì chỉ vẽ lại 2 dòng (cũ và mới).
static VOID Select(UINTN New) {
    UINTN Old = Sel, Vis = VisibleRows();

    if (New >= EntryCount || New == Old)
        return;
    Sel = New;
    if (Sel < Top || Sel >= Top + Vis) {
        Top = Sel < Top ? Sel : Sel - Vis + 1;
        DrawList();                    // trang cuộn: vẽ lại cả danh sách
    } else {
        DrawItem(Old);                 // bỏ tô sáng dòng cũ
        DrawItem(Sel);                 // tô sáng dòng mới
    }
    DrawDetail();
}

/*
 * Phím số. Với >= 10 mục, sau chữ số đầu chờ thêm 1 giây xem có chữ số thứ hai không
 * (vd "1" rồi "5" = mục 15), nhờ vậy cả 20 mục đều chọn được bằng số.
 * Trả về chỉ số mục (từ 0), hoặc EntryCount nếu số không hợp lệ.
 */
static UINTN ReadNumber(CHAR16 First) {
    UINTN n = First - L'0';
    EFI_INPUT_KEY Key;

    if (n >= 1 && n <= EntryCount)
        Select(n - 1);                 // tô sáng ngay để người dùng thấy
    if (n * 10 <= EntryCount && PollKey(1000, &Key) &&
        Key.UnicodeChar >= L'0' && Key.UnicodeChar <= L'9')
        n = n * 10 + (Key.UnicodeChar - L'0');
    return n >= 1 && n <= EntryCount ? n - 1 : EntryCount;
}

static VOID MenuLoop(VOID) {
    DrawMenu();
    for (;;) {
        EFI_INPUT_KEY Key = WaitKey();
        CHAR16 c = Key.UnicodeChar;
        UINTN Last = EntryCount ? EntryCount - 1 : 0;

        switch (Key.ScanCode) {
        case SCAN_UP:   Select(Sel > 0 ? Sel - 1 : Last);    continue;   // vòng lên mục cuối
        case SCAN_DOWN: Select(Sel < Last ? Sel + 1 : 0);    continue;   // vòng về mục đầu
        case SCAN_HOME: Select(0);                           continue;
        case SCAN_END:  Select(Last);                        continue;
        case SCAN_ESC:  return;   // trả quyền về firmware (boot option kế tiếp)
        }

        if (IsEnter(Key) && EntryCount > 0) {
            Boot(&Entries[Sel]);
            DrawMenu();
        } else if (c >= L'0' && c <= L'9') {
            UINTN i = ReadNumber(c);
            if (i < EntryCount) {
                Select(i);
                Boot(&Entries[i]);
                DrawMenu();
            }
        } else if (c == L'r' || c == L'R') {
            ScanAllDisks();
            DrawMenu();
        } else if (c == L'm' || c == L'M') {
            NextTextMode();
            DrawMenu();
        }
    }
}

/* ------------------------------------------------------------------ */
/* Đếm ngược                                                           */
/* ------------------------------------------------------------------ */

// TRUE nếu hết giờ (boot mục mặc định), FALSE nếu người dùng bấm phím
static BOOLEAN Countdown(VOID) {
    CHAR16 Line[128];
    EFI_INPUT_KEY Key;
    UINTN Row;

    NewScreen();
    Print(L" Found %d boot entr%s.\n\n", (int)EntryCount, EntryCount == 1 ? L"y" : L"ies");
    SetColor(COLOR_TITLE);
    Print(L" Default: %s  [%s]\n", Entries[0].Name, Entries[0].Kind);
    SetColor(COLOR_DIM);
    Print(L"          %s\n\n", Entries[0].DevStr ? Entries[0].DevStr : L"");
    Row = ST->ConOut->Mode->CursorRow;

    SetColor(COLOR_NORMAL);
    for (int s = TIMEOUT_SECONDS; s > 0; s--) {
        UnicodeSPrint(Line, sizeof(Line), L" Booting in %d s...  Press any key for the menu.", s);
        PutText(0, Row, Line, Cols - 1);
        if (PollKey(1000, &Key))
            return FALSE;
    }
    return TRUE;
}

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);
    gImageHandle = ImageHandle;

    // Firmware bật watchdog 5 phút khi chạy boot option; tắt đi để ngồi ở menu không bị reset
    uefi_call_wrapper(BS->SetWatchdogTimer, 4, 0, 0, 0, NULL);
    ShowCursor(FALSE);

    ScanAllDisks();
    if (EntryCount > 0 && Countdown())
        Boot(&Entries[0]);

    MenuLoop();

    FreeEntries();
    SetColor(COLOR_NORMAL);
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);
    return EFI_SUCCESS;
}
