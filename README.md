# G8OS Initramfs Builder
This repository contains all that is needed to build the g8os-kernel and initramfs to start our root filesystem.

## Releases:
- [0.9.0](https://github.com/g8os/initramfs/tree/0.9.0) : used to build the [v0.9.0](https://github.com/g8os/core0/releases/tag/v0.9.0) of core0
- [0.10.0](https://github.com/g8os/initramfs/tree/0.10.0) : used to build the [v0.10.0](https://github.com/g8os/core0/releases/tag/v0.10.0) of core0
- [0.11.0](https://github.com/g8os/initramfs/tree/0.11.0) : used to build the [v0.11.0](https://github.com/g8os/core0/releases/tag/v0.11.0) of core0
- [0.12.0](https://github.com/g8os/initramfs/tree/0.12.0) : used to build the [v0.12.0](https://github.com/g8os/core0/releases/tag/v0.12.0) of core0

# Dependencies
Under Ubuntu 16.04, you will need this in order to compile everything:
 - `golang` (version 1.8)
 - `xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git asciidoc xmlto libbison-dev flex libmnl-dev libglib2.0-dev libfuse-dev libxml2-dev libdevmapper-dev libpciaccess-dev libnl-3-dev libnl-route-3-dev libyajl-dev dnsmasq`

These dependencies are of course valid for any other system but adapt you'll have to adapt it to suit yours.

On Gentoo, you probably already have all the dependancies.

## Privileges
You need to have root privilege to be able to execute all the scripts.
Some parts need to chown/setuid/chmod files as root.

# What does this script do ?
 - First, download and check checksum of all archives needed
 - Extract the archives
 - Compiles:
    - Busybox
    - Fuse (library and userland tools)
    - OpenSSL and SSL Certificates (ca-certificates)
    - util-linux (for `lsblk`, ...)
    - Redis (only the server is used)
    - BTRFS (btrfs-progs)
    - libvirt and QEMU
    - ZeroTier One
    - parted (partition management)
    - dnsmasq (used for dhcp on containers)
    - nftables (used for firewalling and routing)
    - iproute2 (used for network namespace support)
    - socat (used for some tcp/port forwarding)
    - unionfs-fuse (used for internal fuse layers)
    - RocksDB (shared library)
    - GoRocksDB
    - eudev and kmod (used for hardware and modules management)
 - Clean, remove useless files, optimize (strip) files and copy system's config
 - Compile the kernel (and bundles initramfs in the kernel)


# How to use it ?
## Easy
Just type: `bash initramfs.sh` and everything should be done in one shot.

## Custom way
The `initramfs.sh` script accepts multiple options:
```
 -d --download    only download and extract archives
 -b --busybox     only (re)build busybox
 -t --tools       only (re)build tools (ssl, fuse, ...)
 -c --cores       only (re)build core0 and coreX
 -k --kernel      only (re)build kernel (produce final image)
 -M --modules     only (re)build kernel modules
 -h --help        display this help message
```

The option `--kernel` is useful if you changes something on the root directory and want to rebuild the kernel (with the initramfs).

If you are modifying core0/coreX, you can simply use `--cores --kernel` options and the cores will be rebuilt and the initramfs rebuilt after.
This will produce a new image with the latest changes.

### Customize build
You can customise your build for some service, for exemple, you can configure a private ZeroTier Network to join during boot.
You need to add your own services to `conf/root/` directory. By default you will join ZeroTier Earth network.
You can disable this and join another network by editing/moving/copying `conf/root/zerotier-public.toml` file.

## Build using a docker container

From the root of this repository, create a docker container
```shell
docker run -ti --name g8osbuilder ubuntu:16.04 /bin/bash
```

Don't try to mount the initramfs repo, the build will fail.

Then from inside the docker
```shell
# install dependencies for building
apt-get update
apt-get install -y asciidoc xmlto --no-install-recommends
apt-get install -y xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git libbison-dev flex libmnl-dev xtables-addons-source libglib2.0-dev libfuse-dev libxml2-dev libdevmapper-dev libpciaccess-dev libnl-3-dev libnl-route-3-dev libyajl-dev dnsmasq liblz4-dev libsnappy-dev libbz2-dev libssl-dev gperf libelf-dev libkmod-dev liblzma-dev git kmod

# install go
curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz > /tmp/go1.8.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
mkdir /gopath
export GOPATH=/gopath

#clone the repo
git clone https://github.com/g8os/initramfs.git

# start the build
cd /initramfs
bash initramfs.sh
```
The result of the build will be located in `staging/vmlinuz.efi` so copy it out of the docker by executing `docker cp g8osbuilder:/initramfs/staging/vmlinuz.efi .`

# I have the kernel, what can I do with it ?
Just boot it. The kernel image is EFI bootable.

If you have an EFI Shell, just run the kernel like any EFI executable.
If you don't have the shell or want to boot it automaticaly, put the kernel in `/EFI/BOOT/BOOTX64.EFI` in a FAT partition.

## How to create a 'bootable' (EFI) image
```shell
dd if=/dev/zero of=/tmp/g8os.img bs=1M count=256
mkfs.vfat /tmp/g8os.iso
mkdir -p /mnt/g8os-iso
mount g8os.iso /mnt/g8os-iso
mkdir -p /mnt/g8os-iso/EFI/BOOT
cp staging/vmlinuz.efi /mnt/EFI/BOOT/BOOTX64.EFI
umount /mnt/g8os-iso
```
