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

useradd -u 50000 -G audio,video browser || true
useradd -u 50001 -G audio browsertor || true
useradd -u 50002 -G audio -d /home/.media media || true
useradd -u 50003 documents || true

echo "/media /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

ln -s /home/conf/grey/ /usr/share/themes/grey
ln -s /home/conf/gtkrc-2.0 .gtkrc-2.0

ln /root/bin/magneter /usr/local/bin/magneter
ln /root/conf/magnet.desktop /usr/share/applications/magnet.desktop

cat > /etc/rc.local <<'EOF'
#!/bin/sh

cd /root

/root/bin/x11-respawn &
/root/bin/wifistart

exit 0
EOF
