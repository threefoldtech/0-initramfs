#!/bin/bash
set -e

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "[-] missing remote version or repository name"
    exit 1
fi

mkdir -p /target
rm -rf /target/*

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/gopath

sed -i "/G8UFS_VERSION=/c\G8UFS_VERSION=\"$1\"" "/$2/internals/cores.sh"

# updating dependencies
cd "/$2/extensions/initramfs-gig"
git pull

# start the build
cd "/$2"
bash initramfs.sh --cores --kernel

# installing kernel to remote directory
cp "/$2/staging/vmlinuz.efi" /target/
