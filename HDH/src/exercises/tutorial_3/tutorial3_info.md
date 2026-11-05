# TUTORIAL 3 – KERNEL PROGRAMMING

## Objectives

This tutorial helps you:
* Create and configure kernel modules
* Get a kernel module compiled and installed
* Acquire hardware details about GPU of your machine

## Setup and preparation

All development packages for C/C++ must be properly installed. Your machine is expected to have them all set up in the previous tutorial.

To quicken the compilation time, you must compile your kernel source successfully before coming to the class. Subsequent compilations during the lecture will not have to recompile everything, but your added source code.

## Program functioning

The kernel program will report GPU information like vendor, device ID, DMA, IO address, and interrupts. You can use the PCI subsystem and the Direct Rendering Manager (DRM) to access GPU details. The following steps include a simple kernel module to retrieve basic PCI information for the GPU, and it can be extended to query more details.

### Steps:
1. **Identify GPU via the PCI Subsystem:** Most GPUs are PCI devices, so you can access them using the PCI subsystem.
2. **Create a Linux kernel module.**
3. **Query PCI details (vendor ID, device ID, etc.).**

---

## Linux Kernel Module Example

The following example is a kernel module that prints basic information about the PCI devices classified as display controllers (class 0x03).

### `gpu_info.c`

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/interrupt.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name and Student ID");
MODULE_DESCRIPTION("A simple Linux kernel module to report GPU information.");
MODULE_VERSION("1.0");

static void print_gpu_info(struct pci_dev *pdev)
{
    u16 vendor_id, device_id;
    unsigned long dma_base, io_base;
    int irq;

    // Get Vendor and Device ID
    pci_read_config_word(pdev, PCI_VENDOR_ID, &vendor_id);
    pci_read_config_word(pdev, PCI_DEVICE_ID, &device_id);

    // Get DMA base address
    dma_base = pci_resource_start(pdev, 0);

    // Get IO base address
    io_base = pci_resource_start(pdev, 1);

    // Get IRQ (interrupt number)
    irq = pdev->irq;

    // Print the GPU information
    pr_info("GPU Found:\n");
    pr_info("Vendor ID: 0x%x\n", vendor_id);
    pr_info("Device ID: 0x%x\n", device_id);
    pr_info("DMA Base: 0x%lx\n", dma_base);
    pr_info("IO Base: 0x%lx\n", io_base);
    pr_info("IRQ: %d\n", irq);
}

static int __init gpu_info_init(void)
{
    struct pci_dev *pdev = NULL;

    pr_info("Loading GPU Info Module...\n");

    // Iterate over all PCI devices, looking for display controllers
    for_each_pci_dev(pdev) {
        if ((pci_pdev_class(pdev) >> 16) == PCI_CLASS_DISPLAY_VGA) {
            print_gpu_info(pdev);
        }
    }

    return 0;
}

static void __exit gpu_info_exit(void)
{
    pr_info("Unloading GPU Info Module...\n");
}

module_init(gpu_info_init);
module_exit(gpu_info_exit);
```

### Key Functions:
* `pci_read_config_word`: Reads a word from the PCI configuration space of the device to get the vendor and device ID.
* `pci_resource_start`: Gets the base address of a resource (DMA, IO).
* `pdev->irq`: Retrieves the IRQ assigned to the device.
* `for_each_pci_dev`: Iterates over all PCI devices to find devices classified as display controllers.

---

## Compiling the Module as Built-in

You will let this module be loaded as built-in one.

1. Place the file in the kernel source tree, for example in `drivers/gpu/`.
2. Modify the Makefile in `drivers/gpu/`:
   ```makefile
   obj-y += gpu_info.o
   ```
3. Add the module to the kernel configuration by editing `Kconfig`:
   ```kconfig
   config GPU_INFO
       bool "GPU Information module"
       default y
   ```
4. Recompile the kernel:
   ```bash
   $ make menuconfig  # Enable your module in the configuration.
   $ make -j$(nproc)  # Compile the kernel.
   $ sudo make modules_install install  # Install the kernel and modules.
   ```
5. Reboot into the new kernel.
6. Once booted, check dmesg or `/var/log/kern.log` for the GPU information:
   ```bash
   $ dmesg | grep "GPU"
   ```

### Explanation:
* **Vendor and Device ID:** This identifies the specific GPU model.
* **DMA and IO Addresses:** These are the memory and IO regions allocated to the GPU.
* **IRQ:** Interrupt number assigned to the GPU, which handles events such as signal processing.

---

## Extended Exercises

This is just a basic example at home please extend the program to query more specific information like memory regions or direct interaction with GPU registers via more advanced subsystems like DRM.
