#!/bin/bash -xe

cd $HOME

ln -s /etc/local/wireguard /etc/wireguard

apt-get update
apt-get -y upgrade

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/desktop.pkg)
apt-get remove -y $(cat conf/debian/desktop.del)

echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user

useradd -s /usr/local/bin/graphic-start -u 10000 -G audio,video -d /home user || true

chown user:user /home
chown user:user /home/.config || true

mkdir -p /etc/xdg/i3/
mkdir -p /etc/xdg/i3status/
ln -sf /etc/local-conf/i3_config /etc/xdg/i3/config
ln -sf /etc/local-conf/i3status_config /etc/xdg/i3status/config

mkdir -p /etc/firefox/policies/
mkdir -p /etc/firefox-esr/
ln -sf /etc/local-conf/firefox-policies.json /etc/firefox/policies/policies.json
ln -sf /etc/local-conf/firefox-settings.js /etc/firefox-esr/settings.js

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

if [ -f /proc/acpi/ibm/fan ]
then
	apt-get -y install tp-smapi-dkms thinkfan
	cat conf/local/thinkpad_acpi.conf > /etc/modprobe.d/thinpad_acpi.conf
	ln -sf /etc/local-conf/thinkfan.conf /etc/
	systemctl enable thinkfan
fi

cat > /etc/rc.local <<'EOF'
#!/bin/sh

/root/bin/keyboard
/root/bin/mouse

/root/bin/zram-on

[ -f /etc/wireguard/vpn.conf ] && wg-quick up vpn && wg-shuffle
/root/bin/wifistart&

exit 0
EOF


echo "$0 completed successfully"
