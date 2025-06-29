# SshPlus Luci UI (OpenWrt Smart SSH Tunnel)

مدیریت و مانیتور تونل SSH و ساکس ۵ به صورت گرافیکی روی OpenWrt.
راه‌اندازی سریع تونل امن، کنترل، مانیتور و اتصال مجدد خودکار — همه از طریق رابط وب LuCI!

---

## معرفی کوتاه

این افزونه به شما امکان می‌دهد با چند کلیک:

* تونل امن SSH ایجاد کنید و آی‌پی خارجی بگیرید
* وضعیت و مدت اتصال را ببینید
* هر وقت تونل قطع شد، خودش دوباره وصل می‌شود
* همه‌چیز را در LuCI (پنل OpenWrt) مدیریت کنید
* حذف کامل با یک دستور

---

## قابلیت‌ها

* نصب و حذف خودکار با یک دستور
* کنترل تونل SSH (Start / Stop / Config) از داخل OpenWrt
* نمایش آی‌پی خروجی سرور و مدت اتصال
* Watchdog خودکار (اتصال مجدد در صورت قطع شدن)
* کاملاً رسپانسیو (موبایل و دسکتاپ)
* Kill هوشمند پراسس‌های قدیمی پیش از اتصال جدید
* مناسب برای استفاده با Clash / Passwall و سایر کلاینت‌های socks5
* مستقل و قابل شخصی‌سازی

---

## پیش‌نیازها

* OpenWrt با LuCI
* نصب پکیج‌های زیر:

  * luci
  * screen
  * openssh-client
  * (در صورت نیاز به پسورد: sshpass)
* دسترسی root

---

## نصب سریع

۱. یکی از دستورات زیر را در ترمینال روتر وارد کنید:

```sh
wget -O - https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/install_sshplus.sh | sh
```

یا

```sh
curl -fsSL https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/install_sshplus.sh | sh
```

۲. پس از نصب، از طریق مسیر **Services > SSHPlus** در رابط وب OpenWrt وارد شوید و کانفیگ را انجام دهید.

---

## حذف کامل (Full Uninstall)

برای حذف کامل افزونه، فایل‌ها و اسکریپت watchdog از دستورات زیر استفاده کنید:

```sh
wget -O - https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/uninstall_sshplus.sh | sh
```

یا

```sh
curl -fsSL https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/uninstall_sshplus.sh | sh
```

---

## نکات امنیتی و مهم

* توصیه می‌شود همیشه از کلید خصوصی امن استفاده کنید
* پورت سرور SSH را به دلایل امنیتی تغییر دهید
* این افزونه هیچ اطلاعاتی از دستگاه شما خارج نمی‌کند

---

## درباره پروژه

این افزونه نسخه توسعه‌یافته [پروژه اصلی SshPlus](https://github.com/peditx/SshPlus) است
و امکانات رابط گرافیکی، Watchdog و نصب/حذف آسان به آن اضافه شده است.

---

## پشتیبانی

برای سوال، رفع اشکال یا پیشنهاد، Issue جدید در همین گیت‌هاب ثبت کنید.

---
