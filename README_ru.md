# **SSHPlus Manager для OpenWrt**  
[![Чат в Telegram](https://img.shields.io/badge/Chat%20on-Telegram-blue.svg)](https://t.me/peditx) [![Лицензия: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)  

[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)  

![Баннер](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)  

**Первое комплексное решение для SSH-туннелирования, нативно интегрированное с PassWall в системах OpenWrt**  

---

## 🚀 Возможности  
- 🔐 Интеграция сервера/клиента OpenSSH  
- 🌐 Создание SOCKS5-прокси (порт 8089)  
- 🛡️ Полная интеграция с PassWall/PassWall2  
- 📊 Мониторинг соединений в реальном времени  
- 📜 Удобный интерфейс управления через CLI  
- 🔄 Функция автоматического переподключения  
- 🧩 Совместимость со всеми архитектурами, поддерживаемыми OpenWrt  

---

## ⚙️ Поддерживаемые архитектуры  
SSHPlus поддерживает все архитектуры, совместимые с OpenWrt, включая:  

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

*Полный список совместимых архитектур доступен в [документации OpenWrt](https://openwrt.org/docs/guide-user/additional-software/package-installation).*  

---

## 📥 Установка  
Выполните следующую команду из репозитория PeDitX в терминале OpenWrt:

```bash
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/SshPlus-/refs/heads/main/Files/install_sshplus.sh && sh install_sshplus.sh

```

### Удаление
Чтобы полностью удалить SSHPlus, выполните:

```bash
rm -f uninstall_sshplus.sh && wget https://raw.githubusercontent.com/peditx/SshPlus-/refs/heads/main/Files/uninstall_sshplus.sh && sh uninstall_sshplus.sh
```

---

## ✨ Основные возможности  

1. **Безопасное SSH-туннелирование**  
   Создание зашифрованных SOCKS5-прокси с военным уровнем шифрования AES-256-GCM  

2. **Интеграция с PassWall**  
   Прямая совместимость с популярными OpenWrt-прокси-решениями  

3. **Управление соединениями**  
   ```
   sshplus  # Запуск интерфейса управления
   ```
   - Запуск/остановка туннелей  
   - Редактирование конфигураций  
   - Мониторинг активных соединений  

4. **Автоматическое создание сервисов**
   Поддержание постоянных соединений даже после перезагрузки через службу init.d
5. **Гибкая аутентификация**
   Возможность подключения по паролю или приватному ключу

---

## 📜 О данном решении  
**SSHPlus** — это первая нативная реализация:  
- Полной интеграции OpenSSH в OpenWrt  
- Управления SSH-туннелями через CLI  
- Автоматической настройки PassWall  
- Сохранения сервиса через init.d  

*Разработано специально для уникальной среды OpenWrt*  

---

## 🔧 Требования  
- OpenWrt 21.02 или новее  
- Минимум 8 МБ свободного пространства  
- Активное интернет-соединение  

---

## 📬 Поддержка и связь  
**Канал в Telegram:**  
[https://t.me/peditx](https://t.me/peditx)  

---

## 📄 Лицензия  
**© 2025 PeDitX**  
*Этот проект распространяется по лицензии GPL-3.0.*  

---

## 🙏 Особая благодарность  
- Вдохновлено проектом [EZpasswall](https://github.com/peditx/EZpasswall)  
- Создано для сообщества OpenWrt  
- Поддерживается PeDitX  

© PeDitX 2025 | Telegram: [@peditx](https://t.me/peditx)
