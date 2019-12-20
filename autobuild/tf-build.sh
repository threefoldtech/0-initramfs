#!/bin/bash
set -e

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "[-] missing remote version or repository name"
    exit 1
fi

# preparing environment
mkdir -p /target
rm -rf /target/*

# installing commons
. $(dirname $0)/tf-build-deps.sh
. $(dirname $0)/tf-build-settings.sh

# adding extensions (fallback to master if branch not found)
cd "/$2/extensions"
git clone -b "$1" https://github.com/zero-os/initramfs-gig || git clone https://github.com/zero-os/initramfs-gig

# checkings arguments
arguments="--all --compact "
if [ "${1:0:7}" = "release" ]; then
    arguments="--release"
fi

# setting up environment
export INTERACTIVE="false"

# start the build
cd "/$2"
bash initramfs.sh ${arguments}

# installing kernel to remote directory
echo "[+] moving kernel to /target"
cp -v "/$2/staging/vmlinuz.efi" /target/
