#!/bin/bash -xe
echo 'Server = http://au.mirror.archlinuxarm.org/$arch/$repo' > /etc/pacman.d/mirrorlist  
pacman -Syyu --noconfirm devtools binutils base-devel fakeroot
cd /work
chown -R buildbot:buildbot .
sudo -u buildbot makepkg -Asc --noconfirm --needed
chmod 644 *.pkg.tar.*
