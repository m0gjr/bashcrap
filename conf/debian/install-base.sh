#!/bin/bash -xe

cd $HOME

cat /etc/local/hostname > /etc/hostname

mkdir -p /etc/local/ssh/root
mkdir -p /etc/local/ssh/etc
rm -r .ssh || true
ln -sT /etc/local/ssh/root .ssh

ln -sf /etc/local/fstab /etc/fstab

mv /etc/hosts /tmp/hosts
cat <(printf '127.0.0.1\tlocalhost ') /etc/hostname <(grep -v 127.0.0.1 /tmp/hosts) > /etc/hosts
rm /tmp/hosts

apt-get update
apt-get -y upgrade

debconf-set-selections <<EOF
keyboard-configuration keyboard-configuration/layoutcode string gb
locales locales/default_environment_locale select en_GB.UTF-8
locales locales/locales_to_be_generated multiselect en_GB.UTF-8 UTF-8
EOF

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get install -y $(cat conf/debian/base.pkg)

apt-get remove -y $(cat conf/debian/base.del)

systemctl mask $(cat conf/debian/base.mask)

sed -i 's/HashKnownHosts yes/HashKnownHosts no/' /etc/ssh/ssh_config
cp -n /etc/ssh/ssh_host_* /etc/local/ssh/etc/
rm /etc/ssh/ssh_host_*
ln -s /etc/local/ssh/etc/ssh_host_* /etc/ssh/

mkdir -p /etc/systemd/system/getty@tty1.service.d
rm /etc/systemd/system/getty@tty1.service.d/override.conf || true
cp conf/getty-login.conf /etc/systemd/system/getty@tty1.service.d/override.conf
systemctl daemon-reload

ln bin/local/* /usr/local/bin/

cat > /etc/rc.local <<'EOF'
#!/bin/sh

exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local || true


echo "$0 completed successfully"
