#!/bin/sh


if [ -d archbuild ]; then
	cd archbuild
	if [ -d root.x86_64 ]; then
		rm -rf root.x86_64
	fi
fi

