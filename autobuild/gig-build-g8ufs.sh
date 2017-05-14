#!/bin/bash
if [ "$1" == "" ]; then
    echo "[-] missing remote version"
    exit 1
fi

mkdir -p /target
rm -rf /target/*

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/gopath

sed -i "/G8UFS_VERSION=/c\G8UFS_VERSION=\"$1\"" /initramfs/internals/cores.sh

# updating dependencies
cd /initramfs/extensions/initramfs-gig
git pull

# start the build
cd /initramfs
bash initramfs.sh --cores --kernel

# installing kernel to remote directory
cp /initramfs/staging/vmlinuz.efi /target/
