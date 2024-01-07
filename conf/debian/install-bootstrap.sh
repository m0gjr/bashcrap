#!/bin/bash -xe

export HOME=/root

dir=${installdir:-/mnt}

snapshot(){
	if type zfs > /dev/null && [ "$(findmnt -no FSTYPE "$dir")" == "zfs" ]
	then
		zfs snapshot "$(findmnt -no SOURCE "$dir")@$1"
	fi
}

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

echo "deb http://ftp.uk.debian.org/debian/ $1 main contrib non-free non-free-firmware" > $dir/etc/apt/sources.list
if [ "$1" != "sid" ]
then
	echo "deb http://ftp.uk.debian.org/debian/ $1-updates main contrib non-free non-free-firmware" >> $dir/etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security/ $1-security main contrib non-free non-free-firmware" >> $dir/etc/apt/sources.list
	echo "deb http://ftp.uk.debian.org/debian/ $1-backports main contrib non-free non-free-firmware" >> $dir/etc/apt/sources.list
fi

cp -r .git $dir/root
cd $dir/root
git reset --hard

ln -sf /dev/null $dir/etc/hostid
cat /etc/local/hostname > $dir/etc/hostname

snapshot install-bootstrap

bin/mount-chroot

! [ -z ${install_kernel-true} ] && chroot $dir /root/conf/debian/install-kernel.sh && snapshot install-kernel
! [ -z ${install_base-true} ] && chroot $dir /root/conf/debian/install-base.sh && snapshot install-base
! [ -z ${install_desktop-true} ] && chroot $dir /root/conf/debian/install-desktop.sh && snapshot install-desktop

bin/umount-chroot


echo "$0 completed successfully"
