#!/bin/bash -xe
echo 'en_US UTF-8' > /etc/locale.gen
locale-gen

echo 'Server = http://au.mirror.archlinuxarm.org/$arch/$repo' > /etc/pacman.d/mirrorlist  

pacman-key --init
pacman-key --populate archlinuxarm
pacman-key --recv-key 17C611F16D92677398E0ADF51AD43CA09D82C624
pacman-key --lsign-key 17C611F16D92677398E0ADF51AD43CA09D82C624

pacman -Syyu --noconfirm devtools sudo

useradd -m -r buildbot
echo 'buildbot ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/buildbot
