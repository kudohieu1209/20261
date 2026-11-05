/*
 * Tutorial 5A - Universal UEFI Bootloader (bản nâng cấp)
 *
 * So với code gốc trong PDF (xem original/main.c):
 *   - Sửa lỗi: WaitForEvent nhận Index = NULL, vòng đọc thư mục có thể lặp vô hạn,
 *     tràn mảng Entries, "Press key to refresh" không quét lại, chỉ chọn được 9 mục,
 *     watchdog 5 phút của firmware tự reset máy khi ngồi ở menu.
 *   - Tự nhận diện nhiều loại loader hơn: Windows, shim/grub/systemd-boot,
 *     file fallback \EFI\BOOT\BOOTX64.EFI trên các ổ khác.
 *   - Hiện loại ổ (USB / NVMe / SATA ...) và nhãn phân vùng.
 *
 * Bài TODO (bước 5): cho người dùng TÌM KIẾM và THÊM boot entry:
 *   [S] Search : tìm file .efi theo mẫu (*, ?) trên mọi ổ, chọn kết quả để thêm vào menu
 *   [A] Add    : chọn ổ rồi gõ đường dẫn file .efi
 *   [D] Delete : xoá entry tự thêm
 *   [R] Rescan : kết nối lại thiết bị (USB mới cắm) và quét lại
 *   Các entry tự thêm được lưu vào biến NVRAM nên vẫn còn sau khi khởi động lại.
 */

#include <efi.h>
#include <efilib.h>

#define MAX_VOLUMES       16
#define MAX_ENTRIES       32
#define MAX_HITS          64
#define NAME_LEN          64
#define PATH_LEN          256
#define TIMEOUT_SECONDS   5
#define SEARCH_MAX_DEPTH  6
#define NO_VOLUME         (-1)

// Device path subtype (UEFI spec) không có sẵn trong header của gnu-efi
#define MSG_NVME_NAMESPACE_DP  0x17
#define MSG_SD_DP              0x1A
#define MSG_EMMC_DP            0x1D

#define COLOR_NORMAL    (EFI_WHITE | EFI_BACKGROUND_BLUE)
#define COLOR_TITLE     (EFI_YELLOW | EFI_BACKGROUND_BLUE)
#define COLOR_HINT      (EFI_LIGHTGRAY | EFI_BACKGROUND_BLUE)
#define COLOR_SELECTED  (EFI_BLUE | EFI_BACKGROUND_LIGHTGRAY)
#define COLOR_ERROR     (EFI_LIGHTRED | EFI_BACKGROUND_BLUE)
#define COLOR_OK        (EFI_LIGHTGREEN | EFI_BACKGROUND_BLUE)

// Kết quả của RunMenu() khi người dùng bấm Enter / Esc
#define KEY_ENTER  CHAR_CARRIAGE_RETURN
#define KEY_ESC    0x1B

// Biến NVRAM lưu các entry do người dùng thêm
#define SAVE_VAR_NAME  L"UniversalBootEntries"
static EFI_GUID SaveVarGuid =
    { 0x6a7c5b1e, 0x3f2d, 0x4c8a, { 0x9b, 0x41, 0x2e, 0x5d, 0x7f, 0x10, 0xa3, 0xc4 } };

typedef struct {
    EFI_HANDLE       Handle;
    EFI_DEVICE_PATH *DevPath;      // device path của phân vùng (thuộc firmware, không được free)
    CHAR16           Kind[8];      // USB / NVMe / SATA ...
    CHAR16           Label[32];    // nhãn phân vùng
} Volume;

typedef struct {
    CHAR16           Name[NAME_LEN];
    CHAR16           Path[PATH_LEN];  // đường dẫn trong phân vùng, vd \EFI\ubuntu\grubx64.efi
    INTN             Vol;             // chỉ số trong Volumes[], NO_VOLUME nếu ổ không còn cắm
    BOOLEAN          Custom;          // TRUE = người dùng tự thêm (được lưu NVRAM)
    EFI_DEVICE_PATH *SavedVolDp;      // chỉ cho entry Custom: device path của ổ chứa nó
} BootEntry;

typedef struct {
    INTN   Vol;
    CHAR16 Path[PATH_LEN];
} SearchHit;

typedef VOID (*RenderFn)(UINTN Index, CHAR16 *Buf, UINTN BufLen);

static EFI_HANDLE  gImageHandle;
static EFI_HANDLE  SelfDevice;     // ổ chứa chính bootloader này
static CHAR16     *SelfPath;       // vd \EFI\BOOT\BOOTX64.EFI

static Volume      Volumes[MAX_VOLUMES];
static UINTN       VolumeCount;
static BootEntry   Entries[MAX_ENTRIES];
static UINTN       EntryCount;
static SearchHit   Hits[MAX_HITS];
static UINTN       HitCount;

/* ------------------------------------------------------------------ */
/* Tiện ích chuỗi / màn hình / bàn phím                                */
/* ------------------------------------------------------------------ */

// StrnCpy của gnu-efi không đảm bảo có '\0' ở cuối, nên tự viết bản an toàn
static VOID StrCopyN(CHAR16 *Dst, CONST CHAR16 *Src, UINTN DstLen) {
    UINTN i = 0;
    while (Src[i] && i + 1 < DstLen) {
        Dst[i] = Src[i];
        i++;
    }
    Dst[i] = 0;
}

/*
 * Không dùng CopyMem/SetMem của gnu-efi: trên Ubuntu 26.04 (gnu-efi 4.0) hai hàm này trong
 * libefi.a được biên dịch theo MS ABI nhưng header lại khai báo kiểu SysV -> tham số bị
 * truyền sai thanh ghi và chương trình treo. Tự viết hàm copy cho chắc.
 */
static VOID CopyBytes(VOID *Dst, CONST VOID *Src, UINTN Len) {
    UINT8 *d = Dst;
    CONST UINT8 *s = Src;
    while (Len--)
        *d++ = *s++;
}

static VOID StrAppendN(CHAR16 *Dst, CONST CHAR16 *Src, UINTN DstLen) {
    UINTN n = StrLen(Dst);
    if (n < DstLen)
        StrCopyN(Dst + n, Src, DstLen - n);
}

// Ghép "Dir\Name" thành đường dẫn tuyệt đối trong phân vùng
static VOID JoinPath(CHAR16 *Out, CONST CHAR16 *Dir, CONST CHAR16 *Name) {
    StrCopyN(Out, Dir, PATH_LEN);
    StrAppendN(Out, L"\\", PATH_LEN);
    StrAppendN(Out, Name, PATH_LEN);
}

static VOID SetColor(UINTN Attr) {
    uefi_call_wrapper(ST->ConOut->SetAttribute, 2, ST->ConOut, Attr);
}

static VOID ClearScreen(VOID) {
    SetColor(COLOR_NORMAL);
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);
}

static VOID ShowCursor(BOOLEAN Visible) {
    uefi_call_wrapper(ST->ConOut->EnableCursor, 2, ST->ConOut, Visible);
}

static VOID ScreenSize(UINTN *Cols, UINTN *Rows) {
    if (EFI_ERROR(uefi_call_wrapper(ST->ConOut->QueryMode, 4, ST->ConOut,
                                    ST->ConOut->Mode->Mode, Cols, Rows))) {
        *Cols = 80;
        *Rows = 25;
    }
}

static EFI_INPUT_KEY WaitKey(VOID) {
    EFI_INPUT_KEY Key;
    UINTN Index;   // code gốc truyền NULL ở đây: sai spec, firmware thật có thể treo
    do {
        uefi_call_wrapper(BS->WaitForEvent, 3, 1, &ST->ConIn->WaitForKey, &Index);
    } while (EFI_ERROR(uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, &Key)));
    return Key;
}

static VOID WaitAnyKey(VOID) {
    SetColor(COLOR_HINT);
    Print(L"\n Press any key to continue...");
    WaitKey();
}

static VOID Message(UINTN Color, CONST CHAR16 *Text) {
    SetColor(Color);
    Print(L"\n %s\n", Text);
    WaitAnyKey();
}

static VOID DrawHeader(CONST CHAR16 *Subtitle) {
    ClearScreen();
    SetColor(COLOR_TITLE);
    Print(L" UNIVERSAL BOOTLOADER");
    SetColor(COLOR_HINT);
    Print(L"   - Tutorial 5A, HUST OS 2026.1\n");
    Print(L"==============================================================================\n");
    SetColor(COLOR_NORMAL);
    if (Subtitle)
        Print(L" %s\n\n", Subtitle);
}

/*
 * Đọc một dòng từ bàn phím. Buf có thể chứa sẵn giá trị mặc định (sửa được).
 * Trả về FALSE nếu người dùng bấm Esc.
 */
static BOOLEAN ReadLine(CONST CHAR16 *Prompt, CHAR16 *Buf, UINTN BufLen) {
    UINTN n = StrLen(Buf);
    BOOLEAN Ok;

    SetColor(COLOR_NORMAL);
    Print(L"%s%s", Prompt, Buf);
    ShowCursor(TRUE);
    for (;;) {
        EFI_INPUT_KEY Key = WaitKey();
        if (Key.ScanCode == SCAN_ESC) {
            Ok = FALSE;
            break;
        }
        if (Key.UnicodeChar == CHAR_CARRIAGE_RETURN) {
            Ok = TRUE;
            break;
        }
        if (Key.UnicodeChar == CHAR_BACKSPACE) {
            if (n > 0) {
                Buf[--n] = 0;
                Print(L"\b \b");
            }
        } else if (Key.UnicodeChar >= 0x20 && n + 1 < BufLen) {
            CHAR16 Echo[2] = { Key.UnicodeChar, 0 };
            Buf[n++] = Key.UnicodeChar;
            Buf[n] = 0;
            Print(L"%s", Echo);
        }
    }
    ShowCursor(FALSE);
    Print(L"\n");
    return Ok;
}

/*
 * Menu chọn bằng phím mũi tên, dùng chung cho menu chính, kết quả tìm kiếm, danh sách ổ.
 *   ↑ ↓ PgUp PgDn Home End : di chuyển
 *   Enter                  : trả về KEY_ENTER (*Selected = mục đang chọn)
 *   1..9                   : chọn nhanh mục tương ứng rồi trả về KEY_ENTER
 *   Esc                    : trả về KEY_ESC
 *   Chữ cái trong Hotkeys  : trả về chữ đó (viết hoa)
 */
static CHAR16 RunMenu(CONST CHAR16 *Title, CONST CHAR16 *Hint, UINTN Count,
                      RenderFn Render, UINTN *Selected, CONST CHAR16 *Hotkeys) {
    UINTN Cols, Rows, Visible, Top = 0;
    CHAR16 Line[160], Item[160];

    ScreenSize(&Cols, &Rows);
    Visible = Rows > 9 ? Rows - 9 : 1;
    if (Cols >= sizeof(Line) / sizeof(CHAR16))
        Cols = sizeof(Line) / sizeof(CHAR16) - 1;
    if (*Selected >= Count)
        *Selected = Count ? Count - 1 : 0;

    for (;;) {
        if (*Selected < Top)
            Top = *Selected;
        if (*Selected >= Top + Visible)
            Top = *Selected - Visible + 1;

        DrawHeader(Title);
        if (Count == 0) {
            SetColor(COLOR_HINT);
            Print(L"   (empty)\n");
        }
        for (UINTN i = Top; i < Count && i < Top + Visible; i++) {
            UINTN Len;
            Render(i, Item, sizeof(Item) / sizeof(CHAR16));
            UnicodeSPrint(Line, sizeof(Line), L" %2d. %s", (int)(i + 1), Item);
            // Đệm khoảng trắng để thanh chọn kéo dài hết dòng, cắt bớt để không xuống dòng
            for (Len = StrLen(Line); Len < Cols - 1; Len++)
                Line[Len] = L' ';
            Line[Cols - 1] = 0;
            SetColor(i == *Selected ? COLOR_SELECTED : COLOR_NORMAL);
            Print(L"%s\n", Line);
        }
        SetColor(COLOR_HINT);
        if (Count > Visible)
            Print(L"   ... %d/%d\n", (int)(*Selected + 1), (int)Count);
        uefi_call_wrapper(ST->ConOut->SetCursorPosition, 3, ST->ConOut, 0, Rows - 2);
        Print(L" %s", Hint);

        EFI_INPUT_KEY Key = WaitKey();
        CHAR16 c = Key.UnicodeChar;
        switch (Key.ScanCode) {
        case SCAN_UP:        if (*Selected > 0) (*Selected)--;                            continue;
        case SCAN_DOWN:      if (*Selected + 1 < Count) (*Selected)++;                    continue;
        case SCAN_PAGE_UP:   *Selected = *Selected > Visible ? *Selected - Visible : 0;   continue;
        case SCAN_PAGE_DOWN: *Selected = *Selected + Visible < Count ? *Selected + Visible
                                                                     : (Count ? Count - 1 : 0);
                             continue;
        case SCAN_HOME:      *Selected = 0;                                               continue;
        case SCAN_END:       *Selected = Count ? Count - 1 : 0;                           continue;
        case SCAN_ESC:       return KEY_ESC;
        }
        if (c == CHAR_CARRIAGE_RETURN && Count > 0)
            return KEY_ENTER;
        if (c >= L'1' && c <= L'9' && (UINTN)(c - L'1') < Count) {
            *Selected = c - L'1';
            return KEY_ENTER;
        }
        if (c >= L'a' && c <= L'z')
            c -= L'a' - L'A';
        for (CONST CHAR16 *h = Hotkeys; h && *h; h++)
            if (*h == c)
                return c;
    }
}

/* ------------------------------------------------------------------ */
/* File system                                                         */
/* ------------------------------------------------------------------ */

// TRUE nếu Path tồn tại và là file (không phải thư mục)
static BOOLEAN FileExists(EFI_FILE_HANDLE Root, CONST CHAR16 *Path) {
    EFI_FILE_HANDLE File;
    EFI_FILE_INFO *Info;
    BOOLEAN IsFile = FALSE;

    if (EFI_ERROR(uefi_call_wrapper(Root->Open, 5, Root, &File, (CHAR16 *)Path,
                                    EFI_FILE_MODE_READ, 0)))
        return FALSE;
    Info = LibFileInfo(File);
    if (Info) {
        IsFile = !(Info->Attribute & EFI_FILE_DIRECTORY);
        FreePool(Info);
    }
    uefi_call_wrapper(File->Close, 1, File);
    return IsFile;
}

/*
 * Đọc mục tiếp theo trong thư mục. Trả về FALSE khi hết hoặc lỗi.
 * (Code gốc chỉ dừng khi gặp EFI_NOT_FOUND, các lỗi khác sẽ làm vòng lặp chạy mãi.)
 */
static BOOLEAN ReadDirEntry(EFI_FILE_HANDLE Dir, EFI_FILE_INFO *Info, UINTN InfoSize) {
    UINTN Size = InfoSize;
    EFI_STATUS Status = uefi_call_wrapper(Dir->Read, 3, Dir, &Size, Info);
    return !EFI_ERROR(Status) && Size != 0;
}

static BOOLEAN IsDotEntry(CONST CHAR16 *Name) {
    return StrCmp(Name, L".") == 0 || StrCmp(Name, L"..") == 0;
}

static BOOLEAN IsSelf(INTN Vol, CONST CHAR16 *Path) {
    return Vol != NO_VOLUME && Volumes[Vol].Handle == SelfDevice &&
           SelfPath && StriCmp((CHAR16 *)Path, SelfPath) == 0;
}

/* ------------------------------------------------------------------ */
/* Volume (phân vùng)                                                  */
/* ------------------------------------------------------------------ */

// Firmware thật thường chỉ kết nối ổ boot để khởi động nhanh, nên phải
// tự ConnectController thì mới thấy hết các ổ NVMe/SATA/USB khác.
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

// Xác định loại ổ (USB, NVMe...) bằng cách duyệt các node trong device path
static VOID DescribeVolume(Volume *V) {
    EFI_FILE_HANDLE Root;

    StrCopyN(V->Kind, L"Disk", 8);
    V->Label[0] = 0;
    for (EFI_DEVICE_PATH *N = V->DevPath; N && !IsDevicePathEnd(N); N = NextDevicePathNode(N)) {
        if (DevicePathType(N) == MEDIA_DEVICE_PATH && DevicePathSubType(N) == MEDIA_CDROM_DP)
            StrCopyN(V->Kind, L"CD", 8);
        if (DevicePathType(N) != MESSAGING_DEVICE_PATH)
            continue;
        switch (DevicePathSubType(N)) {
        case MSG_USB_DP:            StrCopyN(V->Kind, L"USB", 8);    break;
        case MSG_NVME_NAMESPACE_DP: StrCopyN(V->Kind, L"NVMe", 8);   break;
        case MSG_SATA_DP:           StrCopyN(V->Kind, L"SATA", 8);   break;
        case MSG_ATAPI_DP:          StrCopyN(V->Kind, L"ATA", 8);    break;
        case MSG_SCSI_DP:           StrCopyN(V->Kind, L"SCSI", 8);   break;
        case MSG_SD_DP:
        case MSG_EMMC_DP:           StrCopyN(V->Kind, L"SD/MMC", 8); break;
        }
    }

    Root = LibOpenRoot(V->Handle);
    if (Root) {
        EFI_FILE_SYSTEM_VOLUME_LABEL_INFO *Info = LibFileSystemVolumeLabelInfo(Root);
        if (Info) {
            StrCopyN(V->Label, Info->VolumeLabel, 32);
            FreePool(Info);
        }
        uefi_call_wrapper(Root->Close, 1, Root);
    }
}

static VOID ScanVolumes(VOID) {
    EFI_HANDLE *Handles;
    UINTN Count;

    VolumeCount = 0;
    if (EFI_ERROR(uefi_call_wrapper(BS->LocateHandleBuffer, 5, ByProtocol, &FileSystemProtocol,
                                    NULL, &Count, &Handles)))
        return;
    for (UINTN i = 0; i < Count && VolumeCount < MAX_VOLUMES; i++) {
        Volume *V = &Volumes[VolumeCount];
        V->Handle = Handles[i];
        V->DevPath = DevicePathFromHandle(Handles[i]);
        if (!V->DevPath)
            continue;
        DescribeVolume(V);
        VolumeCount++;
    }
    FreePool(Handles);
}

static INTN FindVolumeByDevicePath(EFI_DEVICE_PATH *Dp) {
    UINTN Size = DevicePathSize(Dp);
    for (UINTN v = 0; v < VolumeCount; v++)
        if (DevicePathSize(Volumes[v].DevPath) == Size &&
            CompareMem(Volumes[v].DevPath, Dp, Size) == 0)
            return (INTN)v;
    return NO_VOLUME;
}

/* ------------------------------------------------------------------ */
/* Boot entry                                                          */
/* ------------------------------------------------------------------ */

static INTN FindEntry(INTN Vol, CONST CHAR16 *Path) {
    for (UINTN i = 0; i < EntryCount; i++)
        if (Entries[i].Vol == Vol && StriCmp(Entries[i].Path, (CHAR16 *)Path) == 0)
            return (INTN)i;
    return -1;
}

static BOOLEAN AddEntry(CONST CHAR16 *Name, INTN Vol, CONST CHAR16 *Path, BOOLEAN Custom) {
    BootEntry *E;

    if (EntryCount >= MAX_ENTRIES || FindEntry(Vol, Path) >= 0)
        return FALSE;
    E = &Entries[EntryCount++];
    StrCopyN(E->Name, Name, NAME_LEN);
    StrCopyN(E->Path, Path, PATH_LEN);
    E->Vol = Vol;
    E->Custom = Custom;
    E->SavedVolDp = Custom ? DuplicateDevicePath(Volumes[Vol].DevPath) : NULL;
    return TRUE;
}

// Loader của các distro Linux, ưu tiên shim (chạy được khi bật Secure Boot)
static CONST CHAR16 *LinuxLoaders[] = { L"shimx64.efi", L"grubx64.efi", L"systemd-bootx64.efi" };

static VOID DetectOnVolume(UINTN v) {
    EFI_FILE_HANDLE Root, EfiDir;
    UINT64 Buf[128];   // UINT64 để căn lề 8 byte cho EFI_FILE_INFO
    EFI_FILE_INFO *Info = (EFI_FILE_INFO *)Buf;
    CHAR16 Path[PATH_LEN];
    UINTN Before = EntryCount;

    Root = LibOpenRoot(Volumes[v].Handle);
    if (!Root)
        return;

    // 1. Windows
    if (FileExists(Root, L"\\EFI\\Microsoft\\Boot\\bootmgfw.efi"))
        AddEntry(L"Windows Boot Manager", v, L"\\EFI\\Microsoft\\Boot\\bootmgfw.efi", FALSE);

    // 2. Linux: \EFI\<distro>\{shim,grub,systemd-boot}
    if (!EFI_ERROR(uefi_call_wrapper(Root->Open, 5, Root, &EfiDir, L"\\EFI",
                                     EFI_FILE_MODE_READ, 0))) {
        while (EntryCount < MAX_ENTRIES && ReadDirEntry(EfiDir, Info, sizeof(Buf))) {
            if (!(Info->Attribute & EFI_FILE_DIRECTORY) || IsDotEntry(Info->FileName) ||
                StriCmp(Info->FileName, L"Microsoft") == 0 || StriCmp(Info->FileName, L"BOOT") == 0)
                continue;
            for (UINTN k = 0; k < sizeof(LinuxLoaders) / sizeof(LinuxLoaders[0]); k++) {
                StrCopyN(Path, L"\\EFI\\", PATH_LEN);
                StrAppendN(Path, Info->FileName, PATH_LEN);
                StrAppendN(Path, L"\\", PATH_LEN);
                StrAppendN(Path, LinuxLoaders[k], PATH_LEN);
                if (FileExists(Root, Path)) {
                    AddEntry(Info->FileName, v, Path, FALSE);
                    break;
                }
            }
        }
        uefi_call_wrapper(EfiDir->Close, 1, EfiDir);
    }

    // 3. Ổ không có OS nào ở trên nhưng có file fallback (USB cài đặt, ổ ngoài...)
    if (EntryCount == Before && !IsSelf(v, L"\\EFI\\BOOT\\BOOTX64.EFI") &&
        FileExists(Root, L"\\EFI\\BOOT\\BOOTX64.EFI")) {
        UnicodeSPrint(Path, sizeof(Path), L"Fallback loader (fs%d)", (int)v);
        AddEntry(Path, v, L"\\EFI\\BOOT\\BOOTX64.EFI", FALSE);
    }

    uefi_call_wrapper(Root->Close, 1, Root);
}

/*
 * Quét lại toàn bộ: entry tự nhận diện đứng trước, entry người dùng thêm đứng sau.
 * Entry tự thêm được gắn lại với ổ qua device path (thứ tự fsN có thể đổi sau mỗi lần quét).
 */
static VOID RebuildEntries(VOID) {
    static BootEntry Custom[MAX_ENTRIES];
    UINTN CustomCount = 0;

    for (UINTN i = 0; i < EntryCount; i++)
        if (Entries[i].Custom)
            Custom[CustomCount++] = Entries[i];

    ConnectAllControllers();
    ScanVolumes();

    EntryCount = 0;
    for (UINTN v = 0; v < VolumeCount && EntryCount < MAX_ENTRIES; v++)
        DetectOnVolume(v);

    for (UINTN i = 0; i < CustomCount; i++) {
        Custom[i].Vol = FindVolumeByDevicePath(Custom[i].SavedVolDp);
        if (EntryCount < MAX_ENTRIES && (Custom[i].Vol == NO_VOLUME ||
                                         FindEntry(Custom[i].Vol, Custom[i].Path) < 0))
            Entries[EntryCount++] = Custom[i];
        else
            FreePool(Custom[i].SavedVolDp);
    }
}

/* ------------------------------------------------------------------ */
/* Lưu / đọc entry tự thêm trong NVRAM                                 */
/* Mỗi bản ghi: UINT16[4] = {byte của Name, byte của Path, byte của     */
/* device path, 0} rồi tới Name, Path, device path của ổ.              */
/* ------------------------------------------------------------------ */

static VOID SaveCustomEntries(VOID) {
    UINTN Total = 0;
    UINT8 *Blob, *p;
    EFI_STATUS Status;

    for (UINTN i = 0; i < EntryCount; i++)
        if (Entries[i].Custom)
            Total += 8 + StrSize(Entries[i].Name) + StrSize(Entries[i].Path) +
                     DevicePathSize(Entries[i].SavedVolDp);

    if (Total == 0) {
        LibDeleteVariable(SAVE_VAR_NAME, &SaveVarGuid);
        return;
    }

    Blob = p = AllocatePool(Total);
    if (!Blob)
        return;
    for (UINTN i = 0; i < EntryCount; i++) {
        BootEntry *E = &Entries[i];
        UINT16 Hdr[4];
        if (!E->Custom)
            continue;
        Hdr[0] = (UINT16)StrSize(E->Name);
        Hdr[1] = (UINT16)StrSize(E->Path);
        Hdr[2] = (UINT16)DevicePathSize(E->SavedVolDp);
        Hdr[3] = 0;
        CopyBytes(p, Hdr, sizeof(Hdr));        p += sizeof(Hdr);
        CopyBytes(p, E->Name, Hdr[0]);         p += Hdr[0];
        CopyBytes(p, E->Path, Hdr[1]);         p += Hdr[1];
        CopyBytes(p, E->SavedVolDp, Hdr[2]);   p += Hdr[2];
    }

    Status = LibSetNVVariable(SAVE_VAR_NAME, &SaveVarGuid, Total, Blob);
    FreePool(Blob);
    if (EFI_ERROR(Status)) {
        SetColor(COLOR_ERROR);
        Print(L"\nWarning: could not save entries to NVRAM: %r\n", Status);
        WaitAnyKey();
    }
}

static VOID LoadCustomEntries(VOID) {
    UINTN Size;
    UINT8 *Blob = LibGetVariableAndSize(SAVE_VAR_NAME, &SaveVarGuid, &Size);
    UINT8 *p = Blob, *End = Blob + Size;

    if (!Blob)
        return;
    while (p + 8 <= End && EntryCount < MAX_ENTRIES) {
        UINT16 Hdr[4];
        BootEntry *E = &Entries[EntryCount];

        CopyBytes(Hdr, p, sizeof(Hdr));
        p += sizeof(Hdr);
        // Dữ liệu hỏng thì bỏ qua phần còn lại
        if (Hdr[0] < 2 || Hdr[0] > sizeof(E->Name) || Hdr[1] < 2 || Hdr[1] > sizeof(E->Path) ||
            Hdr[2] < sizeof(EFI_DEVICE_PATH) || (UINTN)(End - p) < (UINTN)Hdr[0] + Hdr[1] + Hdr[2])
            break;

        CopyBytes(E->Name, p, Hdr[0]);   p += Hdr[0];
        CopyBytes(E->Path, p, Hdr[1]);   p += Hdr[1];
        E->Name[Hdr[0] / 2 - 1] = 0;
        E->Path[Hdr[1] / 2 - 1] = 0;
        E->SavedVolDp = AllocatePool(Hdr[2]);
        if (!E->SavedVolDp)
            break;
        CopyBytes(E->SavedVolDp, p, Hdr[2]);
        p += Hdr[2];
        E->Custom = TRUE;
        E->Vol = NO_VOLUME;   // RebuildEntries() sẽ gắn lại với ổ
        EntryCount++;
    }
    FreePool(Blob);
}

/* ------------------------------------------------------------------ */
/* Khởi động một entry                                                 */
/* ------------------------------------------------------------------ */

static VOID Boot(BootEntry *E) {
    EFI_DEVICE_PATH *Dp;
    EFI_HANDLE NewImage;
    EFI_STATUS Status;

    DrawHeader(NULL);
    if (E->Vol == NO_VOLUME) {
        Message(COLOR_ERROR, L"The disk holding this entry is not connected.");
        return;
    }
    Print(L" Booting %s\n fs%d:%s\n", E->Name, (int)E->Vol, E->Path);

    Dp = FileDevicePath(Volumes[E->Vol].Handle, E->Path);
    if (!Dp) {
        Message(COLOR_ERROR, L"Out of memory.");
        return;
    }
    Status = uefi_call_wrapper(BS->LoadImage, 6, FALSE, gImageHandle, Dp, NULL, 0, &NewImage);
    FreePool(Dp);
    if (EFI_ERROR(Status)) {
        SetColor(COLOR_ERROR);
        Print(L"\n LoadImage failed: %r\n", Status);
        if (Status == EFI_SECURITY_VIOLATION)
            Print(L" (Secure Boot rejected this file - it is not signed.)\n");
        WaitAnyKey();
        return;
    }

    SetColor(EFI_LIGHTGRAY | EFI_BACKGROUND_BLACK);
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);
    Status = uefi_call_wrapper(BS->StartImage, 3, NewImage, NULL, NULL);

    // Chỉ tới được đây khi chương trình kia thoát (EFI shell, memtest, OS loader lỗi...)
    uefi_call_wrapper(BS->SetWatchdogTimer, 4, 0, 0, 0, NULL);
    DrawHeader(NULL);
    Print(L" %s returned: %r\n", E->Name, Status);
    WaitAnyKey();
}

/* ------------------------------------------------------------------ */
/* Bài TODO: tìm kiếm & thêm entry                                     */
/* ------------------------------------------------------------------ */

static VOID FormatVolume(INTN v, CHAR16 *Buf, UINTN BufLen) {
    if (v == NO_VOLUME)
        StrCopyN(Buf, L"(missing)", BufLen);
    else
        UnicodeSPrint(Buf, BufLen * sizeof(CHAR16), L"fs%d %s", (int)v, Volumes[v].Kind);
}

// Nối Str vào Buf rồi đệm khoảng trắng cho đủ Width ký tự
// (Print của gnu-efi không hỗ trợ căn trái kiểu "%-24s")
static VOID AppendColumn(CHAR16 *Buf, UINTN BufLen, CONST CHAR16 *Str, UINTN Width) {
    UINTN Start = StrLen(Buf), n;
    StrAppendN(Buf, Str, BufLen);
    for (n = StrLen(Buf); n < Start + Width && n + 1 < BufLen; n++)
        Buf[n] = L' ';
    Buf[n] = 0;
}

static VOID RenderEntry(UINTN i, CHAR16 *Buf, UINTN BufLen) {
    CHAR16 Where[24];
    FormatVolume(Entries[i].Vol, Where, 24);
    Buf[0] = 0;
    AppendColumn(Buf, BufLen, Entries[i].Custom ? L"+" : L" ", 2);
    AppendColumn(Buf, BufLen, Entries[i].Name, 25);
    AppendColumn(Buf, BufLen, Where, 10);
    AppendColumn(Buf, BufLen, Entries[i].Path, 0);
}

static VOID RenderHit(UINTN i, CHAR16 *Buf, UINTN BufLen) {
    CHAR16 Where[24];
    FormatVolume(Hits[i].Vol, Where, 24);
    Buf[0] = 0;
    AppendColumn(Buf, BufLen, Where, 10);
    AppendColumn(Buf, BufLen, Hits[i].Path, 0);
    if (FindEntry(Hits[i].Vol, Hits[i].Path) >= 0)
        AppendColumn(Buf, BufLen, L"   (in menu)", 0);
}

static VOID RenderVolume(UINTN i, CHAR16 *Buf, UINTN BufLen) {
    CHAR16 Fs[8];
    UnicodeSPrint(Fs, sizeof(Fs), L"fs%d", (int)i);
    Buf[0] = 0;
    AppendColumn(Buf, BufLen, Fs, 6);
    AppendColumn(Buf, BufLen, Volumes[i].Kind, 7);
    AppendColumn(Buf, BufLen, Volumes[i].Label[0] ? Volumes[i].Label : L"(no label)", 0);
}

// Tìm đệ quy các file .efi khớp Pattern trong thư mục Dir (DirPath là đường dẫn của Dir)
static VOID SearchDir(UINTN v, EFI_FILE_HANDLE Dir, CONST CHAR16 *DirPath,
                      CHAR16 *Pattern, UINTN Depth) {
    UINT64 Buf[128];
    EFI_FILE_INFO *Info = (EFI_FILE_INFO *)Buf;
    CHAR16 Child[PATH_LEN];

    while (HitCount < MAX_HITS && ReadDirEntry(Dir, Info, sizeof(Buf))) {
        if (IsDotEntry(Info->FileName))
            continue;
        JoinPath(Child, DirPath, Info->FileName);
        if (Info->Attribute & EFI_FILE_DIRECTORY) {
            EFI_FILE_HANDLE Sub;
            if (Depth < SEARCH_MAX_DEPTH &&
                !EFI_ERROR(uefi_call_wrapper(Dir->Open, 5, Dir, &Sub, Info->FileName,
                                             EFI_FILE_MODE_READ, 0))) {
                SearchDir(v, Sub, Child, Pattern, Depth + 1);
                uefi_call_wrapper(Sub->Close, 1, Sub);
            }
        } else if (MetaiMatch(Info->FileName, L"*.efi") && MetaiMatch(Info->FileName, Pattern) &&
                   !IsSelf(v, Child)) {
            Hits[HitCount].Vol = v;
            StrCopyN(Hits[HitCount].Path, Child, PATH_LEN);
            HitCount++;
        }
    }
}

// Tên mặc định: thư mục cha (vd "fedora") hoặc tên file bỏ đuôi .efi
static VOID DefaultName(CONST CHAR16 *Path, CHAR16 *Name) {
    CHAR16 Tmp[PATH_LEN];
    CHAR16 *File, *Parent = NULL;
    UINTN n;

    StrCopyN(Tmp, Path, PATH_LEN);
    File = Tmp;
    for (CHAR16 *p = Tmp; *p; p++)
        if (*p == L'\\') {
            Parent = File;
            File = p + 1;
        }
    if (Parent && File > Tmp) {
        File[-1] = 0;   // cắt Tmp tại dấu '\' trước tên file
        if (*Parent == L'\\')
            Parent++;
        if (*Parent && StriCmp(Parent, L"BOOT") != 0 && StriCmp(Parent, L"EFI") != 0) {
            StrCopyN(Name, Parent, NAME_LEN);
            return;
        }
    }
    StrCopyN(Name, File, NAME_LEN);
    n = StrLen(Name);
    if (n > 4 && StriCmp(Name + n - 4, L".efi") == 0)
        Name[n - 4] = 0;
}

// Hỏi tên rồi thêm entry, lưu NVRAM. Trả về TRUE nếu đã thêm.
static BOOLEAN AddCustomEntry(INTN Vol, CONST CHAR16 *Path) {
    CHAR16 Name[NAME_LEN];

    DrawHeader(L"Add boot entry");
    Print(L" File : fs%d:%s\n\n", (int)Vol, Path);
    if (FindEntry(Vol, Path) >= 0) {
        Message(COLOR_ERROR, L"This file is already in the boot menu.");
        return FALSE;
    }
    if (EntryCount >= MAX_ENTRIES) {
        Message(COLOR_ERROR, L"Boot menu is full.");
        return FALSE;
    }
    DefaultName(Path, Name);
    if (!ReadLine(L" Name : ", Name, NAME_LEN))
        return FALSE;
    if (Name[0] == 0)
        DefaultName(Path, Name);

    AddEntry(Name, Vol, Path, TRUE);
    SaveCustomEntries();
    Message(COLOR_OK, L"Added to boot menu and saved to NVRAM.");
    return TRUE;
}

static VOID DoSearch(VOID) {
    CHAR16 Input[48] = L"";
    CHAR16 Pattern[64], Title[96];
    BOOLEAN HasWildcard = FALSE;
    UINTN Sel = 0;

    DrawHeader(L"Search for boot loaders on all disks");
    SetColor(COLOR_HINT);
    Print(L" Finds .efi files whose name matches a pattern (up to %d folders deep).\n",
          SEARCH_MAX_DEPTH);
    Print(L" Wildcards: * and ?.  Plain text means *text*.  Empty = every .efi file.\n");
    Print(L" Examples:  grub    *shim*    memtest*    vmlinuz*\n\n");
    if (!ReadLine(L" Pattern: ", Input, 48))
        return;

    for (CHAR16 *p = Input; *p; p++)
        if (*p == L'*' || *p == L'?')
            HasWildcard = TRUE;
    if (Input[0] == 0)
        StrCopyN(Pattern, L"*", 64);
    else if (HasWildcard)
        StrCopyN(Pattern, Input, 64);
    else
        UnicodeSPrint(Pattern, sizeof(Pattern), L"*%s*", Input);

    Print(L"\n Searching...\n");
    HitCount = 0;
    for (UINTN v = 0; v < VolumeCount && HitCount < MAX_HITS; v++) {
        EFI_FILE_HANDLE Root = LibOpenRoot(Volumes[v].Handle);
        if (Root) {
            SearchDir(v, Root, L"", Pattern, 1);
            uefi_call_wrapper(Root->Close, 1, Root);
        }
    }
    if (HitCount == 0) {
        Message(COLOR_ERROR, L"No .efi file matches this pattern.");
        return;
    }

    UnicodeSPrint(Title, sizeof(Title), L"Search \"%s\": %d file(s)%s", Pattern, (int)HitCount,
                  HitCount == MAX_HITS ? L" (list is full)" : L"");
    for (;;) {
        CHAR16 Key = RunMenu(Title, L"Enter: add to boot menu    Esc: back", HitCount,
                             RenderHit, &Sel, NULL);
        if (Key == KEY_ESC)
            return;
        if (AddCustomEntry(Hits[Sel].Vol, Hits[Sel].Path))
            return;
    }
}

static VOID DoAddPath(VOID) {
    CHAR16 Path[PATH_LEN] = L"";
    UINTN Vol = 0;
    EFI_FILE_HANDLE Root;
    BOOLEAN Exists;

    if (VolumeCount == 0) {
        Message(COLOR_ERROR, L"No disk with a readable file system was found.");
        return;
    }
    if (RunMenu(L"Add entry: choose the disk", L"Enter: select    Esc: back",
                VolumeCount, RenderVolume, &Vol, NULL) == KEY_ESC)
        return;

    DrawHeader(L"Add entry: type the path of the .efi file");
    SetColor(COLOR_HINT);
    Print(L" Disk fs%d (%s %s).  Example: \\EFI\\fedora\\grubx64.efi\n\n",
          (int)Vol, Volumes[Vol].Kind, Volumes[Vol].Label);
    if (!ReadLine(L" Path: ", Path, PATH_LEN))
        return;

    // Cho phép gõ '/' như Linux, và thiếu '\' ở đầu
    for (CHAR16 *p = Path; *p; p++)
        if (*p == L'/')
            *p = L'\\';
    if (Path[0] != L'\\') {
        CHAR16 Tmp[PATH_LEN];
        JoinPath(Tmp, L"", Path);
        StrCopyN(Path, Tmp, PATH_LEN);
    }

    Root = LibOpenRoot(Volumes[Vol].Handle);
    Exists = Root && FileExists(Root, Path);
    if (Root)
        uefi_call_wrapper(Root->Close, 1, Root);
    if (!Exists) {
        Message(COLOR_ERROR, L"File not found (or it is a folder).");
        return;
    }
    AddCustomEntry(Vol, Path);
}

static VOID DoDelete(UINTN Sel) {
    EFI_INPUT_KEY Key;

    if (Sel >= EntryCount)
        return;
    if (!Entries[Sel].Custom) {
        DrawHeader(NULL);
        Message(COLOR_ERROR, L"Only entries you added (marked +) can be deleted.\n"
                             L" Auto-detected entries come back on every scan.");
        return;
    }
    DrawHeader(NULL);
    SetColor(COLOR_NORMAL);
    Print(L" Delete \"%s\" from the boot menu? (y/n) ", Entries[Sel].Name);
    Key = WaitKey();
    if (Key.UnicodeChar != L'y' && Key.UnicodeChar != L'Y')
        return;

    FreePool(Entries[Sel].SavedVolDp);
    for (UINTN i = Sel; i + 1 < EntryCount; i++)
        Entries[i] = Entries[i + 1];
    EntryCount--;
    SaveCustomEntries();
}

/* ------------------------------------------------------------------ */
/* Đếm ngược & menu chính                                              */
/* ------------------------------------------------------------------ */

// Trả về TRUE nếu hết giờ (boot mục mặc định), FALSE nếu người dùng bấm phím
static BOOLEAN Countdown(VOID) {
    DrawHeader(NULL);
    Print(L" Found %d boot entr%s on %d disk(s).\n\n", (int)EntryCount,
          EntryCount == 1 ? L"y" : L"ies", (int)VolumeCount);
    Print(L" Default: %s\n\n", Entries[0].Name);
    for (int s = TIMEOUT_SECONDS; s > 0; s--) {
        SetColor(COLOR_HINT);
        Print(L"\r Booting in %d s...  Press any key for the menu.", s);
        for (int t = 0; t < 20; t++) {
            uefi_call_wrapper(BS->Stall, 1, 50000);
            if (uefi_call_wrapper(BS->CheckEvent, 1, ST->ConIn->WaitForKey) == EFI_SUCCESS) {
                EFI_INPUT_KEY Key;
                uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, &Key);
                return FALSE;
            }
        }
    }
    return TRUE;
}

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_LOADED_IMAGE *Loaded;
    UINTN Sel = 0;

    InitializeLib(ImageHandle, SystemTable);
    gImageHandle = ImageHandle;

    // Firmware bật watchdog 5 phút khi chạy boot option; tắt đi để ngồi ở menu không bị reset
    uefi_call_wrapper(BS->SetWatchdogTimer, 4, 0, 0, 0, NULL);
    ShowCursor(FALSE);

    if (!EFI_ERROR(uefi_call_wrapper(BS->HandleProtocol, 3, ImageHandle, &LoadedImageProtocol,
                                     (VOID **)&Loaded))) {
        SelfDevice = Loaded->DeviceHandle;
        SelfPath = DevicePathToStr(Loaded->FilePath);
    }

    DrawHeader(NULL);
    Print(L" Scanning disks...\n");
    LoadCustomEntries();
    RebuildEntries();

    if (EntryCount > 0 && Countdown())
        Boot(&Entries[0]);

    for (;;) {
        CHAR16 Key = RunMenu(L"Choose an operating system   (+ = added by you)",
                             L"Enter/1-9 boot  S search  A add path  D delete  R rescan  Esc exit",
                             EntryCount, RenderEntry, &Sel, L"SADR");
        switch (Key) {
        case KEY_ENTER: Boot(&Entries[Sel]);  break;
        case L'S':      DoSearch();           break;
        case L'A':      DoAddPath();          break;
        case L'D':      DoDelete(Sel);        break;
        case L'R':
            DrawHeader(NULL);
            Print(L" Rescanning...\n");
            RebuildEntries();
            break;
        case KEY_ESC:
            // Trả quyền về firmware: nó sẽ thử boot option tiếp theo hoặc vào màn hình setup
            ClearScreen();
            return EFI_SUCCESS;
        }
    }
}
