// wifi_info.c - Module CHỈ ĐỌC: duyệt các network interface trong kernel,
// đánh dấu interface nào là Wi-Fi và in driver/wiphy đang quản lý nó.
// Không đăng ký thiết bị, không sửa gì, nên an toàn khi nạp trên máy thật.
#include <linux/module.h>
#include <linux/netdevice.h>
#include <linux/rcupdate.h>
#include <net/net_namespace.h>
#include <net/cfg80211.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Mai Duy Hieu - 20223967");
MODULE_DESCRIPTION("Tutorial 7 - liet ke network interface va Wi-Fi interface");

static const char *driver_of(struct net_device *dev)
{
	struct device *parent = dev->dev.parent;    // Thiết bị vật lý (PCI/USB) bên dưới interface

	if (parent && parent->driver)
		return parent->driver->name;
	return "(ao / khong co)";
}

static int __init wifi_info_init(void)
{
	struct net_device *dev;

	pr_info("wifi_info: === danh sach network interface ===\n");

	rcu_read_lock();                            // Danh sách netdev có thể thay đổi, phải khóa khi duyệt
	for_each_netdev_rcu(&init_net, dev) {
		struct wireless_dev *wdev = dev->ieee80211_ptr;  // Khác NULL <=> interface do cfg80211 quản lý (Wi-Fi)

		if (wdev)
			pr_info("wifi_info: %-12s WIFI  driver=%s wiphy=%s mac=%pM mtu=%u\n",
				dev->name, driver_of(dev), wiphy_name(wdev->wiphy),
				dev->dev_addr, dev->mtu);
		else
			pr_info("wifi_info: %-12s other driver=%s mac=%pM mtu=%u\n",
				dev->name, driver_of(dev), dev->dev_addr, dev->mtu);
	}
	rcu_read_unlock();
	return 0;
}

static void __exit wifi_info_exit(void)
{
	pr_info("wifi_info: go module\n");
}

module_init(wifi_info_init);
module_exit(wifi_info_exit);
