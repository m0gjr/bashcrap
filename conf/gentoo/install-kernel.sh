#!/bin/bash -e

emerge-webrsync

emerge gentoo-sources linux-firmware genkernel

source /etc/profile

genkernel --install --symlink kernel

emerge zfs

rc-update add zfs-mount default

genkernel --install --symlink initramfs

echo "$0 completed successfully"
