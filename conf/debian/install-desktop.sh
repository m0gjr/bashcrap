#!/bin/bash -xe

cd $HOME

ln -s /etc/local/wireguard /etc/wireguard

apt-get update
apt-get -y upgrade

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/desktop.pkg)

pip install --break-system-packages stacki3

cat conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh
cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF
systemctl enable acpid || true

echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user

useradd -u 10000 -G audio,video -s /bin/bash -d /home user || true

chown user:user /home

mkdir -p /etc/xdg/i3/
ln conf/i3_config /etc/xdg/i3/config

mkdir -p /etc/firefox/policies/
mkdir -p /etc/firefox-esr/
ln conf/firefox-policies.json /etc/firefox/policies/policies.json
ln conf/firefox-settings.js /etc/firefox-esr/settings.js

mkdir -p /etc/systemd/system/getty@tty1.service.d
mkdir -p /etc/systemd/system/getty@tty2.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/sbin/agetty --autologin user --noclear %I $TERM
EOF
cat > /etc/systemd/system/getty@tty2.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/sbin/agetty --autologin root --noclear %I $TERM
EOF
systemctl daemon-reload

cat > /etc/rc.local <<'EOF'
#!/bin/sh

[ -f /etc/wireguard/vpn.conf ] && wg-quick up vpn
/root/bin/wifistart

/root/bin/zram-on

exit 0
EOF


echo "$0 completed successfully"
