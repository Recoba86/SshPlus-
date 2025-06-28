# **مدیر SSHPlus برای OpenWrt**  
[![گفت‌وگو در تلگرام](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![مجوز: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)  

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)  

![بنر](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)  

**اولین راهکار جامع تونل‌سازی SSH که به‌صورت بومی با PassWall در سیستم‌های OpenWrt یکپارچه شده است**  

---

## 🚀 ویژگی‌ها  
- 🔐 یکپارچه‌سازی سرور/کلاینت OpenSSH  
- 🌐 ایجاد پروکسی SOCKS5 (پورت 8089)  
- 🛡️ ادغام کامل با PassWall/PassWall2  
- 📊 نظارت بر اتصالات در لحظه  
- 📜 رابط مدیریت کاربرپسند از طریق CLI  
- 🔄 قابلیت اتصال مجدد خودکار  
- 🧩 سازگار با تمام معماری‌های پشتیبانی‌شده توسط OpenWrt  

---

## ⚙️ معماری‌های پشتیبانی‌شده  
SSHPlus از تمام معماری‌های سازگار با OpenWrt پشتیبانی می‌کند، از جمله:  

- `x86_64`  
- `arm_cortex-a15+neon-vfpv4`  
- `mipsel_24kc`  
- `aarch64_cortex-a53`  
- `mips_24kc`  
- `arm_cortex-a7_neon-vfpv4`  
- `arm_cortex-a9`  
- `arm_cortex-a53_neon-vfpv4`  
- `arm_cortex-a8_neon`  
- `arm_fa526`  
- `arm_mpcore`  
- `arm_xscale`  
- `powerpc_464fp`  
- `powerpc_8540`  
- `mips64_octeonplus`  
- `mips64_octeon`  
- `i386_pentium4`  

*لیست کامل سازگاری در [مستندات OpenWrt](https://openwrt.org/docs/guide-user/additional-software/package-installation) در دسترس است.*  

---

## 📥 نصب  
دستور زیر را با استفاده از اسکریپت‌های مخزن PeDitX در ترمینال OpenWrt خود اجرا کنید:

```bash
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/SshPlus/refs/heads/main/Files/install_sshplus.sh && sh install_sshplus.sh

```

### حذف برنامه
در صورت نیاز به پاک کردن SSHPlus دستور زیر را اجرا کنید:

```bash
rm -f uninstall_sshplus.sh && wget https://raw.githubusercontent.com/peditx/SshPlus/refs/heads/main/Files/uninstall_sshplus.sh && sh uninstall_sshplus.sh
```

---

## ✨ قابلیت‌های کلیدی  

1. **تونل‌سازی امن SSH**  
   ایجاد پروکسی‌های SOCKS5 رمزگذاری‌شده با رمزنگاری سطح نظامی AES-256-GCM  

2. **یکپارچگی با PassWall**  
   ادغام مستقیم با راهکارهای پروکسی محبوب OpenWrt  

3. **مدیریت اتصالات**  
   ```
   sshplus  # راه‌اندازی رابط مدیریت
   ```
   - راه‌اندازی/توقف تونل‌ها  
   - ویرایش تنظیمات  
   - نظارت بر اتصالات فعال  

4. **ایجاد سرویس خودکار**
   حفظ اتصالات پایدار حتی پس از ریبوت از طریق سرویس init.d
5. **احراز هویت انعطاف‌پذیر**
   امکان اتصال با گذرواژه یا کلید خصوصی

---

## 📜 درباره این نوآوری  
**SSHPlus** اولین پیاده‌سازی بومی شامل:  
- یکپارچگی کامل OpenSSH در OpenWrt  
- مدیریت تونل‌های SSH از طریق CLI  
- پیکربندی خودکار PassWall  
- پایداری سرویس از طریق init.d  

*طراحی‌شده به‌طور ویژه برای محیط OpenWrt*  

---

## 🔧 الزامات  
- OpenWrt نسخه 21.02 یا جدیدتر  
- حداقل 8 مگابایت فضای ذخیره‌سازی آزاد  
- اتصال اینترنت فعال  

---

## 📬 پشتیبانی و تماس  
**کانال تلگرام:**  
[https://t.me/peditx](https://t.me/peditx)  

---

## 📄 مجوز  
**© 2025 PeDitX**  
*این پروژه تحت مجوز GPL-3.0 منتشر شده است.*  

---

## 🙏 سپاس ویژه  
- الهام‌گرفته از [EZpasswall](https://github.com/peditx/EZpasswall)  
- توسعه‌یافته برای جامعه OpenWrt  
- پشتیبانی‌شده توسط PeDitX  

© PeDitX 2025 | تلگرام: [@peditx](https://t.me/peditx)
