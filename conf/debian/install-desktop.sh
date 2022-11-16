#!/bin/bash -xe

cd $HOME

ln -s /etc/local/wireguard /etc/wireguard

apt-get update
apt-get -y upgrade

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/desktop.pkg)

pip install stacki3

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

useradd -u 10000 -G audio,video -s /bin/bash -d /home user || true

cat conf/lightdm.conf > /etc/lightdm/lightdm.conf

mkdir -p /etc/firefox/policies/
mkdir -p /etc/firefox-esr/
ln conf/firefox-policies.json /etc/firefox/policies/policies.json
ln conf/firefox-settings.js /etc/firefox-esr/settings.js

ln conf/keymap.conf /etc/X11/xorg.conf.d/keymap.conf

cat > /etc/rc.local <<'EOF'
#!/bin/sh

[ -f /etc/wireguard/vpn.conf ] && wg-quick up vpn
/root/bin/wifistart

/root/bin/zram-on

exit 0
EOF


echo "$0 completed successfully"
