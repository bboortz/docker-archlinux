#!/bin/bash
echo "script not finished!!"
exit

# see http://null-byte.wonderhowto.com/how-to/create-custom-arch-linux-distro-0131002/

# install software
sudo pacman -S devtools git make --needed
# Create a chroot with base-packages:
mkarchroot /tmp/chroot base
# Clone the Archiso package:
git clone git://projects.archlinux.org/archiso.git
# Compile Archiso to your chroot:
make -C archiso/archiso DESTDIR=/tmp/chroot 
sudo make -C archiso/archiso DESTDIR=/tmp/chroot install
# clone the arch install scripts
git clone https://github.com/falconindy/arch-install-scripts
make -C  arch-install-scripts DESTDIR=/tmp/chroot 
sudo make -C  arch-install-scripts DESTDIR=/tmp/chroot install
# Enter our chroot:
mkarchroot -r bash /tmp/chroot

