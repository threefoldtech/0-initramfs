#!/bin/bash
set -e

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "[-] missing remote version or repository name"
    exit 1
fi

# preparing environment
mkdir -p /target
rm -rf /target/*

# install dependencies for building
apt-get update
apt-get install -y asciidoc xmlto --no-install-recommends

# toolchain dependencies
deps=(pkg-config make m4 autoconf)

# system tools and libs
deps+=(libssl-dev dnsmasq git curl bc)

# fuse
deps+=(libfuse-dev)

# storage and filesystem
deps+=(e2fslibs-dev libblkid-dev uuid-dev libattr1-dev)

# virtualization
deps+=(libvirt-dev libdevmapper-dev)

# dirty list, needs to be documented
deps+=(xz-utils lbzip2 libtool gettext uuid-dev)
deps+=(libncurses5-dev libreadline-dev zlib1g-dev libacl1-dev)
deps+=(liblzo2-dev libbison-dev flex)
deps+=(libglib2.0-dev libfuse-dev libxml2-dev libpciaccess-dev)
deps+=(libyajl-dev liblz4-dev libbz2-dev)
deps+=(libcap-dev autopoint comerr-dev)

# udev and modules
deps+=(gperf libelf-dev libkmod-dev liblzma-dev kmod)

# nftables
deps+=(libnl-3-dev libnl-route-3-dev libmnl-dev xtables-addons-source)

# zflist
deps+=(libhiredis-dev libpixman-1-dev libb2-dev libsqlite3-dev libtar-dev libjansson-dev libsnappy-dev)

# corex
deps+=(cmake libjson-c-dev vim-runtime)

# containerd
deps+=(libseccomp-dev)

apt-get install -y ${deps[@]}

# install go
curl https://storage.googleapis.com/golang/go1.10.3.linux-amd64.tar.gz > /tmp/go1.10.3.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.10.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
mkdir -p /gopath
export GOPATH=/gopath

# install rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

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
