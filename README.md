# Zero-OS Initramfs Builder
This repository contains all that is needed to build the Zero-OS kernel and initramfs to start our root filesystem.

# Dependencies
In order to compile all the initramfs without issues, you'll need to install build-time dependencies.

Please check the build process and use the dependencies listed there (see `autobuild` directory).
If you want to install dependencies required inside an ubuntu 18.04 docker, you can use theses helpers:
```
. autobuild/tf-build-deps.sh
. autobuild/tf-build-setting.sh
```

The first script will install dependencies, the second one will source and export needed variables.

There is a special `autobuild/tf-build-deps-clean.sh` which doesn't install Go nor Rust.
Use it if you installed them already.

## Privileges

You need to have root privilege to be able to execute all the scripts.

Some parts need to `chown/setuid/chmod/mknod` files as root.

Not running it as root will fails the build process.

# What does this script do ?
 - First, download and check checksum of all archives needed
 - Extract the archives
 - Compiles third-party software:
    - busybox (for full base system)
    - fuse (library and userland tools)
    - openssl and ssl certificates (ca-certificates)
    - util-linux (for `lsblk`, ...)
    - e2fs-progs (for recent mkfs, etc.)
    - redis (only the server is used)
    - btrfs (btrfs-progs)
    - libvirt and qemu
    - parted (partition management)
    - dnsmasq (used for dhcp on containers)
    - nftables (used for firewalling and routing)
    - iproute2 (used for network namespace support)
    - unionfs-fuse (used for internal fuse layers)
    - eudev and kmod (used for hardware and modules management)
    - smartmontools (used for S.M.A.R.T monitoring)
    - dmidecode (optional dependency for libvirt and management)
    - openssh (client and server, for debug purpose)
    - netcat6 (needed by libvirt migration)
    - curl (needed for libcurl by zflist)
    - zflist (0-flist for flist on-the-fly creation)
    - restic (for container backup and upload)
    - rtinfo (for realtime monitoring out-of-box)
    - seektime (small tool to detect disk type)
    - wireguard (netgen vpn, modules and userland tools)
    - zlib (compression library)
 - Integrate core stuff:
    - Compile `0-fs`
    - Compile `corex` (container remote control)
 - Clean, remove useless files, optimize (strip) files
 - Copy system's configuration and init script
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
 -n --nomirror    don't use a mirror to download files (use upstream)
 -l --clean       only clean staging files (extracted sources)
 -m --mrproper    only remove staging files and clean the root
 -r --release     force a release build
 -h --help        display this help message
```

The option `--kernel` is useful if you changes something on the root directory and want to rebuild the kernel (with the initramfs).

This will produce a new image with the latest changes.

In order to see how to use theses steps in a maintained way, please check GitHub Action build: `.github/workflows/kernel.yaml` file.

## Build mode
By default, initramfs will compiles in `debug` mode, which contains some extra debug options.

To produce a `release` (aka **production** build), there is two options:
- Using `--release` option during build
- Override `BUILDMODE` variable defined on the top of `initramfs.sh`

This is obvious but, **do not use a debug version in a production environment.**

## Mirror
By default, all files (except git upstream repositories) use a mirror to download files.
This mirror url is set on the initramfs.sh script itself.

You can use the `--nomirror` flag to disable mirror and use upstream website. If you want to build
your own mirror, you can simply use this flag to create your local mirror (`--download --nomirror` flags).

You just need to expose the `archives` directory to a via a http server to provide a mirror.

## Build using a docker container

Create a docker container
```shell
docker run -ti --name zero-os-builder ubuntu:18.04 /bin/bash
```

- You need to use `ubuntu:18.04`, this is the only image we supports
- Ensure to have the repository available on `/0-initramfs`
- Run `autobuild/tf-build.sh` script. This script will install dependencies and build everything
- The result of the build will be located in `staging/vmlinuz.efi`

**Warning:** if you don't use Ubuntu 18.04 (at least for now), some build _and_ runtime issue can occures.

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
dd if=/dev/zero of=/tmp/zero-os.img bs=1M count=256
mkfs.vfat /tmp/zero-os.iso
mkdir -p /mnt/zero-os-iso
mount Zero-OS.iso /mnt/zero-os-iso
mkdir -p /mnt/zero-os-iso/EFI/BOOT
cp staging/vmlinuz.efi /mnt/EFI/BOOT/BOOTX64.EFI
umount /mnt/zero-os-iso
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

You can use this extension way to copy extra configuration files, edit some default value on files, etc.

Here are some useful variables you can use on your extension, they all points to a directory:
```
DISTFILES  - sources archive downloaded
WORKDIR    - extracted (and compiled) sources
ROOTDIR    - the target root directory (contains the initramfs contents)
```

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
- A file called `.zero-os-debug` on the root of `/dev/sda1`
- The whole content of `/dev/sda1` will be copied (overwriting existing files) on the real root

## QEMU
This way enable you to easily overwrite the system with your debug file from your local machine, with qemu.

Add `-drive file=fat:/debug-files,format=raw` as **first** drive argument to your qemu command line.

### Quick help
```
mkdir /tmp/zero-os-debug/
touch /tmp/zero-os-debug/.zero-os-debug
echo World > /tmp/zero-os-debug/hello

qemu-system-x86_64 -drive file=fat:rw:/tmp/zero-os-debug,format=raw $QEMU_CMD_LINE
```
This will add `/hello` to your running Zero-OS.

## Static build
To simplify some binaries update and compatibility for some container, some binaries (like `corex`) needs
to be compiled as fully static. The best way to get a well-working static binary is using, eg, musl as
libc to staticly compile the binary. We now support this.

There are some special packages compiled using musl, theses packages ends with `-musl` name and a special
root directory (defined by `MUSLROOTDIR`) create a root directory where a musl subsystem can be used.

You can take a look at `corex-musl` or `zlib-musl` to understand how this works.

## Kernel Configuration
Kernel configuration is based on Arch Linux default kernel config file.

Here is what we changed:
- Default kernel command line customized
- Initramfs is compressed using XZ
- Default hostname set to `zero-os`
- Build version name set to `Zero-OS`
- Change default initramfs path to `../../root` to include our root system
- All `Sound drivers` disabled
- All `Multimedia drivers` disabled
- Inputs `Mice`, `Joystick`, `Touchscreen`, `Tablets` and `Miscellaneous devices` disabled
- All `Special HID drivers`
- All `CAN bus subsystem` disabled
- All `Amateur Radio support` disabled
- All `IrDA (infrared)` and `NFC subsystem` disabled
- All `Bluetooth` and `CAIF` disabled
- All `Wireless`, `WiMAX` and `RF switch` disabled
- All `Data acquision support (comedi)` disabled
- Filesystems `ext4`, `Raiserfs`, `JFS`, `XFS`, `GFS2`, `OCFS2`, `NILFS2`, `F2FS`, `NTFS` disabled
- Modules are not compressed

# Repository Owner
- [Maxime Daniel](https://github.com/maxux), Telegram: [@maxux](http://t.me/maxux)


