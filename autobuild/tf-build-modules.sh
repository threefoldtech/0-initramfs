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
source $HOME/.cargo/env

sed -i "/MODULES_BRANCH=/c\MODULES_BRANCH=\"$1\"" "/$2/internals/modules.sh"

# checkings arguments
arguments="--cores --kernel"
if [ "${1:0:7}" = "release" ]; then
    arguments="--cores --kernel --release"
fi

# start the build
cd "/$2"
bash initramfs.sh ${arguments}

# installing kernel to remote directory
cp "/$2/staging/vmlinuz.efi" /target/
