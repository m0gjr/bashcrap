#!/bin/bash -xe

cd $HOME

apt-get update
apt-get -y upgrade

debconf-set-selections <<EOF
zfs-dkms zfs-dkms/note-incompatible-licenses note
EOF

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

case $(arch) in
	x86_64) arch="amd64";;
	aarch64) arch="arm64";;
	*) arch=$(uname -r | rev | cut -d- -f1 | rev);;
esac

apt-get -y install linux-image-$arch linux-headers-$arch

apt-get -y install zfs-initramfs || true
/usr/lib/dkms/dkms_autoinstaller start || true
modprobe zfs || true
apt-get -y install zfs-initramfs
