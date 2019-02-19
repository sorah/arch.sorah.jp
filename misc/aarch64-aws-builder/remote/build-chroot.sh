#!/bin/bash -xe
pacman -Syyu --noconfirm
cd /work
chown -R buildbot:buildbot .
sudo -u buildbot makepkg -Asc --noconfirm --needed
chmod 644 *.pkg.tar.*
