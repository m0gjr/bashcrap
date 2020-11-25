#!/bin/bash -xe

apt-get update
apt-get -y upgrade

echo "zfs-dkms zfs-dkms/note-incompatible-licenses note" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/layoutcode string gb" | debconf-set-selections
echo "locales locales/default_environment_locale select en_GB.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect en_GB.UTF-8 UTF-8" | debconf-set-selections
echo "tzdata  tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata  tzdata/Zones/Europe select London" | debconf-set-selections

apt-get -y install linux-image-amd64

apt-get -y install zfs-initramfs || apt-get -y install zfs-initramfs

apt-get -y install \
bash-completion alsa-utils \
rsync less pm-utils psmisc tmux \
htop iotop iftop \
nano vim elinks bc pv git sshfs autofs unzip \
acpi lm-sensors upower acpid \
netcat arp-scan nmap curl wget dnsutils dhcpcd5 ssh \
iw wpasupplicant wireless-tools \
firmware-linux firmware-iwlwifi \
locales debconf-utils debootstrap \
tor torsocks \
xorg  openbox \
spacefm medit mplayer smplayer ffmpegthumbnailer \
viewnior imagemagick evince \
xinput lxappearance \
ffmpeg jmtpfs \
chromium gnumeric

cat /root/conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh

cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF

systemctl enable acpid || true

systemctl mask systemd-logind.service || true
systemctl mask systemd-journald.service || true

sed -i 's/HashKnownHosts yes/HashKnownHosts no/' /etc/ssh/ssh_config

passwd -d root

useradd -u 50000 -G audio browser || true
useradd -u 50001 -G audio browsertor || true

#grep "x11-start" /etc/inittab || echo "x11:5:respawn:/root/bin/x11-start" >> /etc/inittab
#sed -i 's/id:.:initdefault/id:5:initdefault/' /etc/inittab

env > /root/.root.env

echo "/- /etc/auto.sshfs" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

ln -s /etc/local/wifi.conf /root/wifi.conf

cat > /etc/rc.local <<'EOF'
#!/bin/sh

/root/bin/x11-respawn &
/root/bin/wifistart
wg-quick up vpn

exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local || true
