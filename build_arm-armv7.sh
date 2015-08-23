#!/bin/bash
BASEDIR="${0%/*}"
. ${BASEDIR}/lib.sh

ARCH="arm-armv7"
IMAGE="${USER}/archlinux-${ARCH}"



cleanup
cd archbuild

download "http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz" 
download "http://os.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz.sig"
# check_download "ArchLinuxARM-armv7-latest.tar.gz.sig"

# Extract
mkdir root.${ARCH}
sudo tar zxf ArchLinuxARM-armv7-latest.tar.gz -C root.${ARCH} > /dev/null

# create devices
create_devices "root.${ARCH}"

build_container "root.${ARCH}" "${IMAGE}"
test_container "${IMAGE}"



