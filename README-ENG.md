````markdown
# SSHPlus Luci UI (OpenWrt Smart SSH Tunnel Manager)

A modern, easy-to-use web UI for creating, controlling, and monitoring SSH tunnels (SOCKS Proxy) directly from OpenWrt's Luci interface. Quickly connect your OpenWrt router to remote SSH servers and securely tunnel your traffic – no advanced Linux knowledge required!

---

## ✨ Features

- Start, stop, and configure SSH tunnel from the web panel
- Supports both password and private key authentication
- **SOCKS5 Proxy** auto-created on the router (default: 127.0.0.1:8089)
- See real-time connection status and public IP from the UI
- Auto-reconnect: Watchdog script restarts the tunnel if it drops
- Uptime counter for SSH tunnel
- Clean up all old SSH processes before reconnecting
- Compatible with Passwall, Clash, and all SOCKS-capable apps
- Clean uninstall script to remove all configs and scripts

---

## 🚀 Quick Install

SSH into your OpenWrt router as **root** and run one of these commands:

**Using wget:**
```sh
wget -O - https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/install_sshplus.sh | sh
````

**Or with curl:**

```sh
curl -fsSL https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/install_sshplus.sh | sh
```

After installation, go to **Services → SSHPlus** in the Luci web panel.

---

## 🛠 Uninstall (Full Remove)

To completely remove the UI, config, and watchdog:

**Using wget:**

```sh
wget -O - https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/uninstall_sshplus.sh | sh
```

**Or with curl:**

```sh
curl -fsSL https://raw.githubusercontent.com/Recoba86/SshPlus-Luci-UI/main/Files/uninstall_sshplus.sh | sh
```

---

## 🔒 Notes & Security

* The tunnel only opens a SOCKS5 proxy to localhost – no port forwarding or shell access is exposed.
* All configs are managed by the LuCI UI – no manual file edits needed.
* Suitable for all OpenWrt routers with enough free memory and CPU for SSH tunneling.

---

## 📝 Credits & License

This UI is a forked and extended version of [peditx/SshPlus](https://github.com/peditx/SshPlus), rewritten and optimized for modern OpenWrt setups, with better auto-reconnect and Luci integration.

```

---

```
