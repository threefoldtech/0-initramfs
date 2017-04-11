#!/bin/bash
if [ "$1" == "" ]; then
    echo "[-] missing remote version"
    exit 1
fi

echo "Updating to version: $1"

# start the build
cd /initramfs
bash initramfs.sh --cores --kernel

# installing kernel to remote directory
mkdir -p /target
cp /initramfs/staging/vmlinuz.efi /target/
