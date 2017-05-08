# G8OS Initramfs Builder
This repository contains all that is needed to build the g8os-kernel and initramfs to start our root filesystem.

## Releases:
- [0.9.0](https://github.com/g8os/initramfs/tree/0.9.0) : used to build the [v0.9.0](https://github.com/g8os/core0/releases/tag/v0.9.0) of core0
- [0.10.0](https://github.com/g8os/initramfs/tree/0.10.0) : used to build the [v0.10.0](https://github.com/g8os/core0/releases/tag/v0.10.0) of core0
- [0.11.0](https://github.com/g8os/initramfs/tree/0.11.0) : used to build the [v0.11.0](https://github.com/g8os/core0/releases/tag/v0.11.0) of core0
- [1.0.0](https://github.com/g8os/initramfs/tree/1.0.0) : used to build the [v1.0.0](https://github.com/g8os/core0/releases/tag/v1.0.0) of core0
- [1.1.0-alpha](https://github.com/g8os/initramfs/tree/1.1.0-alpha) : used to build the [v1.1.0-alpha](https://github.com/g8os/core0/releases/tag/v1.1.0-alpha) of core0

# Dependencies
In order to compile all the initramfs without issues, you'll need to installe build-time dependencies.

Please check the build process and use the dependencies listed there.

## Privileges
You need to have root privilege to be able to execute all the scripts.

Some parts need to `chown/setuid/chmod/mknod` files as root.

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
    - dropbear (lightweight ssh server)
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
 -e --extensions  only (re)build extensions
 -l --clean       only clean staging files (extracted sources)
 -m --mrproper    only remove staging files and clean the root
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
apt-get install -y xz-utils pkg-config lbzip2 make curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc e2fslibs-dev uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev git libbison-dev flex libmnl-dev xtables-addons-source libglib2.0-dev libfuse-dev libxml2-dev libdevmapper-dev libpciaccess-dev libnl-3-dev libnl-route-3-dev libyajl-dev dnsmasq liblz4-dev libsnappy-dev libbz2-dev libssl-dev gperf libelf-dev libkmod-dev liblzma-dev git kmod libvirt-dev libcap-dev

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

## How to test the kernel with QEMU
You can run the kernel and get the kernel output on your console from qemu directly
```
qemu-system-x86_64 -kernel vmlinuz.efi -m 2048 -enable-kvm -cpu host -net nic,model=e1000 -net bridge,br=vm0 -nographic -serial null -serial mon:stdio -append console=ttyS1,115200n8
```

## How to test the kernel with xhyve (OSX)
Install [xhyve](https://github.com/mist64/xhyve#installation).
```
xhyve -m 1G -c 2 -s 0:0,hostbridge -s 31,lpc -l com1 -l com2,stdio -s 2:0,virtio-net -f kexec,vmlinuz.efi,,earlyprintk=serial console=ttyS1 acpi=off
```


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

# Extensions

You can add your own building extension-scripts to customize the initramfs.

During the build process, after `cores` and before `kernel` process, all directories under `extensions` folder will be
parsed and executed. To make a working extension, you just need a `extension-name.sh` script on the root directory of your extension.

Exemple:
```
extensions/
  my-extension/
    some-stuff/
    another-stuff/
    my-extension.sh
  another-extension/
    README.md
    another-extension.sh
```

During the extension build phase, your extension script will be `sourced`, not forked, which means that you have access
to all the variables used during the build script process.

**Be careful, you could override some variable used by `initramfs.sh` itself and break the build process.**

You can rebuild extensions by calling `initramfs.sh --extensions`

# 'Hot' debug (inject files without rebuilding the vmlinuz)
Rebuilding the vmlinuz can take relatively long time, when you want to only change one config file
or do some small changes to the root image, this can become really painful to rebuild it each time.

In debug mode (enabled by default now), you can override the root filesystem, the step before `core0` starts, which
means that you can even overwrite `core0` binary.

The `/init-debug` script is executed just before `/init` does the `switch_root` to the real filesystem, this script
will search if `/dev/sda1` exists, if it exists, mounting it as `vfat` filesystem in read-only mode, checking for debug
files then copying them.

## Requirement
- A `vfat` filesystem on `/dev/sda1`
- A file called `.g8os-debug` on the root of `/dev/sda1`
- The whole content of `/dev/sda1` will be copied (overwriting existing files) on the real root

## QEMU
This way enable you to easily overwrite the system with your debug file from your local machine, with qemu.

Add `-drive file=fat:/debug-files,format=raw` as **first** drive argument to your qemu command line.

### Quick help
```
mkdir /tmp/g8os-debug/
touch /tmp/g8os-debug/.g8os-debug
echo World > /tmp/g8os-debug/hello

qemu-system-x86_64 -drive file=fat:/tmp/g8os-debug,format=raw $QEMU_CMD_LINE
```
This will add `/hello` to your running g8os.
