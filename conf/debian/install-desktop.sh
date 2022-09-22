#!/bin/bash -xe

cd $HOME

ln -s /etc/local/wireguard /etc/wireguard

apt-get update
apt-get -y upgrade

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/desktop.pkg)

cat conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh
cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF
systemctl enable acpid || true

echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

ln -s /home/conf/grey/ /usr/share/themes/grey

echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user

useradd -u 49999 -G audio -d /home/.user user || true
useradd -u 50000 -g user -G audio,video browser || true
useradd -u 50001 -g user -G audio browsertor || true
useradd -u 50002 -g user -G audio -d /home/.media media || true
useradd -u 50003 -g user documents || true
useradd -u 50004 -g user -G audio browserproxy || true

cat > /etc/rc.local <<'EOF'
#!/bin/sh

[ -f /etc/wireguard/vpn.conf ] && wg-quick up vpn
/root/bin/wifistart

/root/bin/zram-on

exit 0
EOF


echo "$0 completed successfully"
