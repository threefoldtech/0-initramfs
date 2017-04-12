#!/bin/bash
if [ "$1" == "" ]; then
    echo "[-] missing remote version"
    exit 1
fi

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/gopath

echo "[+] updating to version: $1"
cd $GOPATH/src/github.com/g8os/core0

echo "[+] fetching code"
git fetch origin "$1:$1"

echo "[+] checkout repository"
git checkout 1.1.0-alpha
git pull origin 1.1.0-alpha

# start the build
cd /initramfs
bash initramfs.sh --cores --kernel

# installing kernel to remote directory
mkdir -p /target
cp /initramfs/staging/vmlinuz.efi /target/
