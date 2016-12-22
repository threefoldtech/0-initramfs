# G8OS Initramfs Builder
This repository contains all that is needed to build the g8os-kernel and initramfs to start our root filesystem.

## Releases:
- [0.9.0](https://github.com/g8os/initramfs/tree/0.9.0) : used to build the [v0.9.0](https://github.com/g8os/core0/releases/tag/v0.9.0) of core0
- [0.10.0](https://github.com/g8os/initramfs/tree/0.10.0) : used to build the [v0.10.0](https://github.com/g8os/core0/releases/tag/v0.10.0) of core0

# Dependencies
Under Ubuntu 16.04, you will need this in order to compile everything:
 - `golang` (version 1.7)
 - `xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git asciidoc xmlto libbison-dev flex libmnl-dev`

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
    - SSL Certificates (ca-certificates)
    - util-linux (for `lsblk`, ...)
    - Redis (only the server is used)
    - IPFS
    - BTRFS (btrfs-progs)
 - Clean and remove useless files
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
docker run -v $(pwd):/initramfs -ti ubuntu:16.04 /bin/bash
```

Then from inside the docker
```shell
# install dependencies for building
apt-get update
apt-get install -y asciidoc xmlto --no-install-recommends
apt-get install -y xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git libbison-dev flex libmnl-dev xtables-addons-source

# install go
curl https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz > go1.7.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.7.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
mkdir /gopath
export GOPATH=/gopath

# start the build
cd /initramfs
bash initramfs.sh
```
The result of the build will be located in `staging/vmlinuz.efi`

# I have the kernel, what can I do with it ?
Just boot it. The kernel image is EFI bootable.

If you have an EFI Shell, just run the kernel like any EFI executable.
If you don't have the shell or want to boot it automaticaly, put the kernel in `/EFI/BOOT/BOOTX64.EFI` in a FAT partition.

example how to create a boot disk
```shell
dd if=/dev/zero of=g8os.img bs=1M count=64
mkfs.vfat g8os.iso
mount g8os.iso /mnt
mkdir -p /mnt/EFI/BOOT
cp staging/vmlinuz.efi /mnt/EFI/BOOT/BOOTX64.EFI
umount /mnt
```
