#!/bin/bash -xe

cd $HOME

#deskprofile=$(eselect profile list | grep desktop | head -n1 | cut -d'[' -f2 | cut -d']' -f1)
#eselect profile set $deskprofile
sed -i 's/^USE=".*"$/USE="symlink -bindist wayland elogind -systemd"/' /etc/portage/make.conf

cp conf/gentoo/desktop.use /etc/portage/package.use/

emerge --quiet-build --autounmask-write --deep --update --newuse @world $(cat conf/gentoo/base.pkg conf/gentoo/desktop.pkg) || (dispatch-conf; emerge --quiet-build --autounmask-write --deep --update --newuse @world $(cat conf/gentoo/base.pkg conf/gentoo/desktop.pkg))

rc-update add elogind boot

pip3 install --break-system-packages i3ipc

echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user

useradd -u 10000 -G audio,video -s /bin/bash -d /home user || true

chown user:user /home

mkdir -p /etc/xdg/i3/
ln conf/i3_config /etc/xdg/i3/config

mkdir -p /etc/firefox/policies/
mkdir -p /etc/firefox-esr/
ln conf/firefox-policies.json /etc/firefox/policies/policies.json
ln conf/firefox-settings.js /etc/firefox-esr/settings.js

ln -s /usr/bin/foot /usr/local/bin/x-terminal-emulator

echo 'c8:2345:respawn:/sbin/agetty -a user 38400 tty8 linux' > /etc/inittab.d/user-term.tab

cat > /etc/rc.local <<'EOF'
#!/bin/sh

cd /root

/root/bin/zram-on
/root/bin/wifistart

exit 0
EOF

echo "$0 completed successfully"
