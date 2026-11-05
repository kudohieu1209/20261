#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/pci.h>
#include <linux/interrupt.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Hieu - 20223967");
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
        if ((pdev->class >> 8) == PCI_CLASS_DISPLAY_VGA) {
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
