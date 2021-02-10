#!/bin/bash -xe

dir=${installdir:-/mnt}

if [ ! -d .git ]
then
	echo "not in bashcrap git repository" >&2
	exit 3
fi

if [ ! -f /etc/local/hostname ]
then
	echo "missing /etc/local/hostname" >&2
	exit 2
fi

if [ -z "$1" ]
then
	echo "must have release on command line" >&2
	exit 1
fi

debootstrap "$1" $dir/ http://deb.debian.org/debian/

echo "deb http://deb.debian.org/debian/ $1 main contrib non-free" > $dir/etc/apt/sources.list
if [ "$1" != "sid" ]
then
	echo "deb http://deb.debian.org/debian/ $1-updates main contrib non-free" >> $dir/etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security/ $1/updates main contrib non-free" >> $dir/etc/apt/sources.list
fi

cp -r .git $dir/root
cd $dir/root
git reset --hard

ln -sf /dev/null $dir/etc/hostid

bin/mount-chroot

! [ -z ${install_kernel-true} ] && chroot $dir /root/conf/debian/install-kernel.sh
! [ -z ${install_base-true} ] && chroot $dir /root/conf/debian/install-base.sh
! [ -z ${install_desktop-} ] && chroot $dir /root/conf/debian/install-desktop.sh

bin/umount-chroot

echo
echo successful install
