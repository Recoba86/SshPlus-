#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo -e "\e[33mStopping and removing SSHPlus service...\e[0m"

/etc/init.d/sshplus stop 2>/dev/null
/etc/init.d/sshplus disable 2>/dev/null
rm -f /etc/init.d/sshplus
rm -f /usr/bin/sshplus
rm -f /etc/sshplus.conf
rm -f /etc/sshplus_id_rsa

echo -e "\e[33mCleaning Passwall and Passwall2 configs...\e[0m"
uci delete passwall.SshPlus 2>/dev/null
uci commit passwall 2>/dev/null
uci delete passwall2.SshPlus 2>/dev/null
uci commit passwall2 2>/dev/null

echo -e "\e[33mOptionally restoring Dropbear (OpenWrt default SSH server)...\e[0m"
opkg install dropbear 2>/dev/null
/etc/init.d/dropbear enable 2>/dev/null
/etc/init.d/dropbear start 2>/dev/null

echo -e "\e[32mSshPlus and related files have been completely removed!\e[0m"
