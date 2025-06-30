#!/bin/sh

set -e

# حذف همه فایل‌های پروژه
rm -f \
/usr/lib/lua/luci/controller/sshplus.lua \
/usr/lib/lua/luci/model/cbi/sshplus.lua \
/usr/lib/lua/luci/model/cbi/sshplus_statuspage.lua \
/usr/lib/lua/luci/view/sshplus.lua \
/usr/lib/lua/luci/view/sshplus_statuspage.htm

# حذف اسکریپت راه‌انداز و Watchdog
/etc/init.d/sshplus stop 2>/dev/null || true
rm -f /etc/init.d/sshplus
rm -f /root/sshplus-watchdog.sh

# حذف فایل کانفیگ و داده‌های موقت
rm -f /etc/sshplus.conf
rm -f /tmp/sshplus_start_time

# حذف خط watchdog از کرون‌جاب
sed -i '/sshplus-watchdog.sh/d' /etc/crontabs/root
/etc/init.d/cron restart

echo
echo "🧹 SSHPlus و تمام فایل‌ها و تنظیمات آن حذف شد."
