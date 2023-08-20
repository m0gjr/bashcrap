#!/bin/bash -xe

homedir=$(pwd)

dir=${installdir:-/mnt}

if [ ! -d .git ]
then
	echo "not in bashcrap git repository" >&2
	exit
fi

arch=$(bin/proc_arch)
url="https://gentoo.osuosl.org/releases/$arch/autobuilds/"
tarball="$url/$(curl "$url/latest-stage3-$arch-openrc.txt" | grep -v '^#' | cut -d' ' -f1)"

cd $dir
wget "$tarball"
tar xpf "$(basename "$tarball")" --xattrs-include='*.*' --numeric-owner
cd $homedir

cp -r .git $dir/root
cd $dir/root
git reset --hard

ln -sf /dev/null $dir/etc/hostid

echo 'USE="symlink -bindist"' >> $dir/etc/portage/make.conf
echo '*/* *' > $dir/etc/portage/package.license

bin/mount-chroot

! [ -z ${install_kernel-true} ] && chroot $dir /root/conf/gentoo/install-kernel.sh
! [ -z ${install_base-true} ] && chroot $dir /root/conf/gentoo/install-base.sh
! [ -z ${install_desktop-} ] && chroot $dir /root/conf/gentoo/install-desktop.sh

bin/umount-chroot

echo "$0 completed successfully"
