/*
 * "OS giả" để thử bootloader trong QEMU: được copy thành bootmgfw.efi, grubx64.efi...
 * Khi được boot, nó in ra đường dẫn của chính nó rồi thoát, quay lại menu bootloader.
 * (Trong PDF, các OS giả là bản copy của main.efi nên boot vào lại chính bootloader.)
 */

#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_LOADED_IMAGE *Loaded;
    EFI_INPUT_KEY Key;
    UINTN Index;

    InitializeLib(ImageHandle, SystemTable);
    uefi_call_wrapper(ST->ConOut->SetAttribute, 2, ST->ConOut, EFI_LIGHTGREEN | EFI_BACKGROUND_BLACK);
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);

    Print(L"\n  ***  FAKE OPERATING SYSTEM  ***\n\n");
    if (!EFI_ERROR(uefi_call_wrapper(BS->HandleProtocol, 3, ImageHandle, &LoadedImageProtocol,
                                     (VOID **)&Loaded)))
        Print(L"  Loaded from: %s\n\n", DevicePathToStr(Loaded->FilePath));
    Print(L"  The bootloader started this program with LoadImage() + StartImage().\n");
    Print(L"  A real OS loader would now take over the machine.\n\n");
    Print(L"  Press any key to exit back to the bootloader...");

    uefi_call_wrapper(BS->WaitForEvent, 3, 1, &ST->ConIn->WaitForKey, &Index);
    uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, &Key);
    return EFI_SUCCESS;
}
