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
apt-get install -y xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git libbison-dev flex libmnl-dev xtables-addons-source libglib2.0-dev libfuse-dev libxml2-dev libdevmapper-dev libpciaccess-dev libnl-3-dev libnl-route-3-dev libyajl-dev dnsmasq liblz4-dev libsnappy-dev libbz2-dev libssl-dev gperf libelf-dev libkmod-dev liblzma-dev git kmod libvirt-dev libcap-dev autopoint

# install go
curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz > /tmp/go1.8.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
mkdir -p /gopath
export GOPATH=/gopath

# adding extensions (fallback to master if branch not found)
cd "/$2/extensions"
git clone -b "$1" https://github.com/zero-os/initramfs-gig || git clone https://github.com/zero-os/initramfs-gig

# checkings arguments
arguments="--compact "
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
