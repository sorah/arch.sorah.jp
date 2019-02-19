#!/bin/bash -xe
cd /root
apt-get update && apt-get install -y curl git-core m4 make libarchive-tools awscli
git clone https://git.archlinux.org/arch-install-scripts.git
(
  cd arch-install-scripts/
  make && make install
)

curl -Ssf -L -o /root/rootfs.tar.gz http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
curl -Ssf -L -o /root/rootfs.sig http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz.sig
gpg --recv-key 68B3537F39A313B3E574D06777193F152BDBE6A6
gpg --verify rootfs.sig rootfs.tar.gz

(
  mkdir /root/archroot
  bsdtar -xpf /root/rootfs.tar.gz -C /root/archroot || :
  mkdir /root/archroot/work
)
(
  mkdir /root/arch
  mount --bind /root/archroot /root/arch
)

rm -fv /root/rootfs.tar.gz
rm -fv /root/rootfs.sig

cp /home/ubuntu/prepare-chroot.sh /root/arch/prepare-chroot.sh
arch-chroot /root/arch /prepare-chroot.sh
