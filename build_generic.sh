#!/bin/bash

# see http://null-byte.wonderhowto.com/how-to/create-custom-arch-linux-distro-0131002/
CHROOT=./target/chroot2
TARGET=${CHROOT%/*}

# move to target directory
mkdir -p ${TARGET}
cd ${TARGET}

# install software
sudo pacman -S devtools git make --needed

# Clone the Archiso package:
git clone git://projects.archlinux.org/archiso.git
# clone the arch-install-scripts package:
# git clone https://github.com/falconindy/arch-install-scripts
git clone git://projects.archlinux.org/arch-install-scripts.git

# Create a chroot with base-packages:
mkarchroot $CHROOT base-devel

# Compile Archiso to your chroot:
sudo make -C archiso DESTDIR=$CHROOT install
# Compile arch-install-scripts to your chroot:
sudo make -C arch-install-scripts DESTDIR=$CHROOT install

# Enter our chroot:
#mkarchroot -r bash $CHROOT

