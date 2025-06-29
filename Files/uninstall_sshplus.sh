#!/bin/sh

# حذف فایل‌های LuCI و اسکریپت‌ها
rm -f \
/usr/lib/lua/luci/controller/sshplus.lua \
/usr/lib/lua/luci/model/cbi/sshplus.lua \
/usr/lib/lua/luci/model/cbi/sshplus_statuspage.lua \
/usr/lib/lua/luci/view/sshplus.lua \
/usr/lib/lua/luci/view/sshplus_statuspage.htm \
/etc/init.d/sshplus \
/etc/sshplus.conf \
/etc/sshplus_id_rsa \
/root/sshplus-watchdog.sh \
/tmp/sshplus_start_time

# پاک کردن خط watchdog از کرون‌جاب
sed -i '/sshplus-watchdog.sh/d' /etc/crontabs/root
/etc/init.d/cron restart

# پاک کردن sessionهای screen
screen -ls | grep sshplus | awk '{print $1}' | sed 's/\..*//' | xargs -I {} screen -S {} -X quit

echo "✅ همه چیز مربوط به SSHPlus حذف شد."
