#!/bin/bash
BASEDIR="${0%/*}"
. ${BASEDIR}/lib.sh

ARCH="arm-armv7"
IMAGE="${USER}/archlinux-${ARCH}"



cleanup
cd archbuild

git_clone "https://github.com/LeMaker/linux-bananapi.git" lemaker-3.4
cd linux-bananapi
git pull

download "http://watchmysys.com/blog/wp-content/uploads/2014/08/linux-bananapi.config"
cp linux-bananapi.config .config

# make clean just in case this isn't a clean tree
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- clean
# build the kernel and modules
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- uImage modules
# install to ./modules
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=output modules_install
# create directory structure
mkdir -p output/boot/
# copy kernel
cp arch/arm/boot/uImage output/boot/
# create archive
tar -C output -cxvf ../linux-bananapi-3.4.90.tar.gz boot/ lib/

exit

build_container "root.${ARCH}" "${IMAGE}"
test_container "${IMAGE}"



