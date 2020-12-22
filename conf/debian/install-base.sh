#!/bin/bash -xe

cd $HOME

mkdir -p /etc/local/ssh/root
mkdir -p /etc/local/ssh/etc
ln -sT /etc/local/ssh/root /root/.ssh

rm /etc/fstab
ln -s /etc/local/fstab /etc/fstab

mv /etc/hosts /tmp/hosts
cat <(printf '127.0.0.1\tlocalhost ') /etc/hostname <(grep -v 127.0.0.1 /tmp/hosts) > /etc/hosts
rm /tmp/hosts

apt-get update
apt-get -y upgrade

debconf-set-selections <<EOF
keyboard-configuration keyboard-configuration/layoutcode string gb
locales locales/default_environment_locale select en_GB.UTF-8
locales locales/locales_to_be_generated multiselect en_GB.UTF-8 UTF-8
tzdata  tzdata/Areas select Europe
tzdata  tzdata/Zones/Europe select London
EOF

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

xargs < /root/conf/debian/base.pkg apt-get -y install

apt -y remove isc-dhcp-client isc-dhcp-common || true

systemctl mask systemd-logind.service || true
systemctl mask systemd-journald.service || true

sed -i 's/HashKnownHosts yes/HashKnownHosts no/' /etc/ssh/ssh_config
cp -n /etc/ssh/ssh_host_* /etc/local/ssh/etc/
rm /etc/ssh/ssh_host_*
ln -s /etc/local/ssh/etc/ssh_host_* /etc/ssh/

passwd -d root

cat > /etc/rc.local <<'EOF'
#!/bin/sh

exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local || true
