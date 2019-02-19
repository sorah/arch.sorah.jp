#!/bin/bash -xe
cd /root

mkdir -p /root/archroot/work

cp /home/ubuntu/makepkg.conf /root/archroot/etc/makepkg.conf
cp /home/ubuntu/pacman.conf /root/archroot/etc/pacman.conf

cp /home/ubuntu/build-chroot.sh /root/archroot/build-chroot.sh

mount --bind /root/archroot /root/arch
mount --bind /home/ubuntu/target /root/arch/work
arch-chroot /root/arch /build-chroot.sh
