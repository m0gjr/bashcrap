#!/bin/bash -xe

cd $HOME

apt-get update
apt-get -y upgrade

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/desktop.pkg)

systemctl mask $(cat conf/debian/desktop.mask)

cat conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh

cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF

systemctl enable acpid || true

useradd -u 50000 -G audio,video browser || true
useradd -u 50001 -G audio browsertor || true
useradd -u 50002 -G audio media || true
useradd -u 50003 documents || true

echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

ln -s /home/conf/grey/ /usr/share/themes/grey
ln -s /home/conf/gtkrc-2.0 .gtkrc-2.0

cat > /etc/rc.local <<'EOF'
#!/bin/sh

cd /root

/root/bin/x11-respawn &
/root/bin/wifistart

exit 0
EOF
