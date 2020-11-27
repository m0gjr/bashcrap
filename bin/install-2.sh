#!/bin/bash -xe

mv /etc/hosts /tmp/hosts
cat <(printf '127.0.0.1\tlocalhost ') /etc/hostname <(grep -v 127.0.0.1 /tmp/hosts) > /etc/hosts
rm /tmp/hosts

apt-get update
apt-get -y upgrade

debconf-set-selections <<EOF
zfs-dkms zfs-dkms/note-incompatible-licenses note
keyboard-configuration keyboard-configuration/layoutcode string gb
locales locales/default_environment_locale select en_GB.UTF-8
locales locales/locales_to_be_generated multiselect en_GB.UTF-8 UTF-8
tzdata  tzdata/Areas select Europe
tzdata  tzdata/Zones/Europe select London
EOF

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

arch=$(uname -r | rev | cut -d- -f1 | rev)
apt-get -y install linux-image-$arch linux-headers-$arch

apt-get -y install zfs-initramfs || true
/usr/lib/dkms/dkms_autoinstaller start || true
modprobe zfs || failed
apt-get -y install zfs-initramfs

apt-get -y install \
bash-completion alsa-utils \
rsync less pm-utils psmisc reboot-notifier tmux \
htop iotop iftop lm-sensors \
nano vim elinks bc pv git sshfs autofs unzip \
netcat-openbsd arp-scan nmap curl wget dnsutils dhcpcd5 ssh \
iw wpasupplicant wireless-tools wavemon \
firmware-linux firmware-iwlwifi \
locales debconf-utils debootstrap \

apt remove isc-dhcp-client isc-dhcp-common || true

systemctl mask systemd-logind.service || true
systemctl mask systemd-journald.service || true

sed -i 's/HashKnownHosts yes/HashKnownHosts no/' /etc/ssh/ssh_config

passwd -d root

cat > /etc/rc.local <<'EOF'
#!/bin/sh

exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local || true

git config --global user.name "m0gjr"
git config --global user.email "m0gjr@github.com"

if [ $(basename "$0") = "install-headless.sh" ]
then
	exit
fi

apt-get -y install \
acpi upower acpid \
xorg  openbox \
xinput \
spacefm medit mplayer ffmpegthumbnailer \
viewnior imagemagick \
ffmpeg jmtpfs \
chromium gnumeric
tor torsocks \

cat /root/conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh

cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF

systemctl enable acpid || true

useradd -u 50000 -G audio browser || true
useradd -u 50001 -G audio browsertor || true
useradd -u 50002 -G audio media || true
useradd -u 50003 documents || true

echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
ln -s /root/conf/auto.sshfs /etc/auto.sshfs

cat > /etc/rc.local <<'EOF'
#!/bin/sh

cd /root

/root/bin/x11-respawn &
/root/bin/wifistart
wg-quick up vpn

exit 0
EOF
