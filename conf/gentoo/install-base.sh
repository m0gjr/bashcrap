#!/bin/bash -xe

cd $HOME

mkdir -p /etc/local/ssh/root
mkdir -p /etc/local/ssh/etc
#ln -sT /etc/local/ssh/root .ssh

rm /etc/fstab
ln -s /etc/local/fstab /etc/fstab

mv /etc/hosts /tmp/hosts
cat <(printf '127.0.0.1\tlocalhost ') /etc/hostname <(grep -v 127.0.0.1 /tmp/hosts) > /etc/hosts
rm /tmp/hosts

echo "Europe/London" > /etc/timezone
echo "en_GB.UTF UTF-8" > /etc/locale.gen
locale-gen
eselect locale set en_GB.utf

emerge-webrsync

echo 'USE="-bindist"' >> /etc/portage/make.conf
cp conf/gentoo/base.use /etc/portage/package.use/

[ -z "$install_desktop" ] && emerge --quiet-build --deep --update $(cat conf/gentoo/base.pkg) @world

#sed -i 's/HashKnownHosts yes/HashKnownHosts no/' /etc/ssh/ssh_config
#cp -n /etc/ssh/ssh_host_* /etc/local/ssh/etc/
#rm /etc/ssh/ssh_host_*
#ln -s /etc/local/ssh/etc/ssh_host_* /etc/ssh/

passwd -d root

cat > /etc/rc.local <<'EOF'
#!/bin/sh

/root/bin/zram-on

exit 0
EOF

ln -s /etc/rc.local /etc/local.d/rc.start
chmod +x /etc/rc.local
