#!/bin/bash

# install dependencies for building
apt-get update
apt-get install -y asciidoc xmlto --no-install-recommends

# toolchain dependencies
deps=(pkg-config make m4 autoconf)

# system tools and libs
deps+=(libssl-dev dnsmasq git curl bc wget)

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

# libwebsockets
deps+=(cmake xxd)

# containerd
deps+=(libseccomp-dev)

# install musl
deps+=(musl musl-tools)

# bmon dependencies
deps+=(libconfuse-dev ncurses-bin)

apt-get install -y ${deps[@]}

# install go
GOVER="1.21.0"
curl -L https://dl.google.com/go/go${GOVER}.linux-amd64.tar.gz > /tmp/go${GOVER}.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go${GOVER}.linux-amd64.tar.gz
mkdir -p /gopath

# install rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup target add x86_64-unknown-linux-musl
