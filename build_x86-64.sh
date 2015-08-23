#!/bin/bash
BASEDIR="${0%/*}"
. ${BASEDIR}/lib.sh

ARCH="x86-64"
IMAGE="${USER}/archlinux-${ARCH}"



cleanup
cd archbuild

VERSION=$(curl https://mirrors.kernel.org/archlinux/iso/latest/ | grep -Poh '(?<=archlinux-bootstrap-)\d*\.\d*\.\d*(?=\-x86_64)' | head -n 1)
download "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-bootstrap-$VERSION-x86_64.tar.gz" archlinux-bootstrap-$VERSION-x86_64.tar.gz
download "https://mirrors.kernel.org/archlinux/iso/latest/archlinux-bootstrap-$VERSION-x86_64.tar.gz.sig" archlinux-bootstrap-$VERSION-x86_64.tar.gz.sig
#check_download "archlinux-bootstrap-$VERSION-x86_64.tar.gz.sig"

# Extract
tar zxf archlinux-bootstrap-$VERSION-x86_64.tar.gz > /dev/null
mv root.x86_64 root.${ARCH}

###
# Do necessary install steps.
###
sudo ./root.${ARCH}/bin/arch-chroot root.${ARCH} << EOF
	# Setup a mirror.
	echo 'Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch' > /etc/pacman.d/mirrorlist
	# Setup Keys
	pacman-key --init
	pacman-key --populate archlinux
	# Base without the following packages, to save space.
	# linux jfsutils lvm2 cryptsetup groff man-db man-pages mdadm pciutils pcmciautils reiserfsprogs s-nail xfsprogs vi
	pacman -Syu --noconfirm bash bzip2 coreutils device-mapper dhcpcd gcc-libs gettext glibc grep gzip inetutils iproute2 iputils less libutil-linux licenses logrotate psmisc sed shadow sysfsutils systemd-sysvcompat tar texinfo usbutils util-linux which
	# Pacman doesn't let us force ignore files, so clean up.
	pacman -Scc --noconfirm
	# Install stuff
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen
	exit
EOF

# create devices
create_devices "root.${ARCH}"

build_container "root.${ARCH}" "${IMAGE}"
test_container "${IMAGE}"





