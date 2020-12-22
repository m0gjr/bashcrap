#!/bin/bash -xe

if [ ! -d .git ]
then
	echo "not in bashcrap git repository"
	exit
fi

if [ -z "$1" ]
then
	echo "must have release on command line" >&2
	exit 1
fi

debootstrap "$1" /mnt/ http://deb.debian.org/debian/

echo "deb http://deb.debian.org/debian/ $1 main contrib non-free" > /mnt/etc/apt/sources.list
if [ "$1" != "sid" ]
then
	echo "deb http://deb.debian.org/debian/ $1-updates main contrib non-free" >> /mnt/etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security/ $1/updates main contrib non-free" >> /mnt/etc/apt/sources.list
fi

cp -r .git /mnt/root
cd /mnt/root
git reset --hard

echo "$HOSTNAME" > /mnt/etc/hostname

bin/mount-chroot

![ -z ${install_kernel-true} ] && chroot /mnt /root/conf/debian/install-kernel.sh
![ -z ${install_base-true} ] && chroot /mnt /root/conf/debian/install-base.sh
![ -z ${install_desktop-} ] && chroot /mnt /root/conf/debian/install-desktop.sh

bin/umount-chroot

echo
echo successful install
