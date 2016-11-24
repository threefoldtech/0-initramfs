# G8OS Initramfs Builder
This repository contains all needed to build the g8os-kernel and initramfs to start our root filesystem.

# Dependencies
Under Ubuntu 16.04, you will need this in order to compile everything:
 - `golang` (version 1.7.1)
 - `xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev asciidoc git`

This dependencies is of course valid for any other system but adapt it yourself to your case.

Under Gentoo, you probably already have all the dependancies.

# What does this script do ?
 - First, downloading and checking checksum of all archives needed
 - Extracting archives
 - Compiling:
    - Busybox
    - Fuse (library and userland tools)
    - SSL Certificates (ca-certificates)
    - util-linux (for `lsblk`, ...)
    - Redis (only the server is used)
    - IPFS
    - BTRFS (btrfs-progs)
 - Cleaning and removing useless files
 - Compiling the kernel (initramfs is bundled)


# How to use it ?
## Easy way
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

If you are modifying the core0/coreX, you can simply use `--cores --kernel` options and the cores will be rebuild and the initramfs rebuild after.
This will produce easily a new image with last changes.

## Build using a docker container

From the root of this repository, create a docker container
```shell
docker run -v `pwd`:/initramfs --ti ubuntu:16.04 /bin/bash
```

Then from inside the docker
```shell
# install dependencies for building
apt-get update
apt-get install -y xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev asciidoc git

# install go
curl https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz > go1.7.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.7.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
mkdir /gopath
export GOPATH=/gopath

# start the build
bash initramfs.sh
```
The result of the build will be located in `staging/vmlinuz.efi`

# I have the kernel, what can I do with it ?
Just boot it. The kernel image if EFI bootable.

If you have a EFI Shell, just run the kernel like any EFI executable.
If you don't have the shell or want to boot it automaticaly, put the kernel in `/EFI/BOOT/BOOTX64.EFI` in a FAT partition.
