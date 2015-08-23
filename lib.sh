#!/bin/bash

set -e
set -u

# Change your to your user if this is a unique new image.
USER="bboortz"

# Dependencies
function check() {
	hash $1 &>/dev/null || {
			echo "Could not find $1."
			exit 1
	}
}

check gpg
check docker
check curl


function cleanup() {
	echo "cleaning directory archbuild ..."
	if [ -d archbuild ]; then
		sudo ./cleanup.sh
	else
		mkdir archbuild
	fi
}

function download() {
	local url="${1}"
	local filename="${url##*/}"

	if [ ! -f $filename ]; then
		echo "downloading $filename ..."
		curl -O "$url"
	fi
}

function git_clone() {
	local url="${1}"
	local filename="${url##*/}"
	local branch="$2"

	if [ ! -d "$filename" ]; then
	    git clone -b $branch "$url"
	fi
}

function check_download() {
	local signaturefile="$1"
	echo "checking downloaded file ${signaturefile%.sig*} / $signaturefile ..."
	# Pull Pierre Schmitz PGP Key.
	# http://pgp.mit.edu:11371/pks/lookup?op=vindex&fingerprint=on&exact=on&search=0x4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC
	gpg --keyserver pgp.mit.edu --recv-keys 9741E8AC
	# Verify its integrity.
	gpg --verify $signaturefile
	VALID=$?
	if [[ $VALID == 1 ]]; then
		echo "Verification Failed";
		exit 1;
	fi
}

function create_devices() {
	local root="$1"
	DEV="${root}/dev"
	
	echo "creating devices in $DEV ..."
	sudo bash << EOF
		rm -rf $DEV
		mkdir -p $DEV
		mknod -m 666 $DEV/null c 1 3
		mknod -m 666 $DEV/zero c 1 5
		mknod -m 666 $DEV/random c 1 8
		mknod -m 666 $DEV/urandom c 1 9
		mkdir -m 755 $DEV/pts
		mkdir -m 1777 $DEV/shm
		mknod -m 666 $DEV/tty c 5 0
		mknod -m 600 $DEV/console c 5 1
		mknod -m 666 $DEV/tty0 c 4 0
		mknod -m 666 $DEV/full c 1 7
		mknod -m 600 $DEV/initctl p
		mknod -m 666 $DEV/ptmx c 5 2
		ln -sf /proc/self/fd $DEV/fd
EOF
}

function build_container() {
	local root="$1"
	local image="$2"

	echo "building container in $root: $image ..."
	sudo bash << EOF
		tar --numeric-owner -C $root -c .  | docker import - $image
EOF
}

function test_container() {
	local image="$1"

	echo "testing container $image ..."
	docker run --rm=true $image echo "Success, $image prepared."
}



