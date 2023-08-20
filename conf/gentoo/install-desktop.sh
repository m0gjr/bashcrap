#!/bin/bash -xe

cd $HOME

deskprofile=$(eselect profile list | grep desktop | head -n1 | cut -d'[' -f2 | cut -d']' -f1)

eselect profile set $deskprofile

cp conf/gentoo/desktop.use /etc/portage/package.use/

emerge --quiet-build --deep --update --newuse @world $(cat conf/gentoo/base.pkg conf/gentoo/desktop.pkg)

cat conf/handler.sh > /etc/acpi/handler.sh
chmod +x /etc/acpi/handler.sh

cat > /etc/acpi/events/anything <<'EOF'
event=.*
action=/etc/acpi/handler.sh %e
EOF

rc-update add acpid default || true

useradd -u 50000 -G audio,video browser || true
useradd -u 50001 -G audio browsertor || true
useradd -u 50002 -G audio media || true
useradd -u 50003 documents || true

#echo "/- /etc/auto.sshfs allow_other" > /etc/auto.master.d/sshfs.autofs
#ln -s /root/conf/auto.sshfs /etc/auto.sshfs

cat > /etc/rc.local <<'EOF'
#!/bin/sh

cd /root


/root/bin/zram-on

/root/bin/x11-respawn &
/root/bin/wifistart

exit 0
EOF

