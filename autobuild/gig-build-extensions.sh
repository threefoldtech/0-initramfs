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

# update extensions
cd "/$2/extensions/initramfs-gig/"
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "$1" ]; then
    git fetch origin "$1:$1"
    git checkout "$1"
fi

git pull origin "$1"

# checkings arguments
arguments="--extensions --kernel"
if [ "${1:0:7}" = "release" ]; then
    arguments="--extensions --kernel --release"
fi

# start the build
cd "/$2"
bash initramfs.sh ${arguments}

# installing kernel to remote directory
cp "/$2/staging/vmlinuz.efi" /target/
