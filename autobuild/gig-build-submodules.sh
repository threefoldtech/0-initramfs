#!/bin/bash
if [ "$1" == "" ]; then
    echo "[-] missing remote version"
    exit 1
fi

mkdir -p /target
rm -rf /target/*

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/gopath

echo "[+] updating to version: $1"
cd $GOPATH/src/github.com/g8os/core0

echo "[+] fetching code"
git fetch origin "$1:$1"

echo "[+] checkout repository"
git checkout 1.1.0-alpha
git pull origin 1.1.0-alpha

sed -i "/CORES_VERSION=/c\CORES_VERSION=\"$1\"" /initramfs/internals/cores.sh

# start the build
cd /initramfs
bash initramfs.sh --cores --kernel

# installing kernel to remote directory
cp /initramfs/staging/vmlinuz.efi /target/
