// hello.c - Kernel module đơn giản nhất: in log khi nạp và khi gỡ.
// Mục đích: kiểm tra môi trường build/nạp module đã sẵn sàng.
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");          // Không có GPL thì kernel bị "tainted" và không dùng được nhiều symbol
MODULE_AUTHOR("Mai Duy Hieu - 20223967");
MODULE_DESCRIPTION("Tutorial 7 - Hello kernel module");

static char *name = "HDH";
module_param(name, charp, 0444);    // Truyền tham số khi nạp: sudo insmod hello.ko name=abc
MODULE_PARM_DESC(name, "Ten in ra khi nap module");

static int __init hello_init(void)
{
	pr_info("hello: xin chao %s, module da duoc nap\n", name);
	return 0;                   // Trả về khác 0 thì insmod báo lỗi và module không được nạp
}

static void __exit hello_exit(void)
{
	pr_info("hello: tam biet %s, module da duoc go\n", name);
}

module_init(hello_init);
module_exit(hello_exit);
