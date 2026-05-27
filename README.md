# ZOS Initramfs

Build tooling that assembles the initial RAM filesystem and bootable kernel image used to bring up Zero-OS nodes before the root filesystem is available.

## What this is

ZOS Initramfs contains scripts and configuration to compile the Zero-OS kernel and build the initramfs image. It downloads, verifies, extracts, and compiles third-party software into a compressed initial RAM filesystem, then bundles it into an EFI-bootable kernel image.

This component is essential for the early boot stage of nodes: it provides the minimal user-space environment needed to initialize hardware, set up networking, and transition to the full operating system.

## What this repository contains

- `initramfs.sh` — main build orchestration script
- `autobuild/` — automated build helpers and dependency scripts
- `extensions/` — custom extension scripts for additional build steps
- Kernel configuration based on Arch Linux defaults with customizations for the target environment
- Build support for debug and release modes
- Mirror support for faster, reproducible builds
- Static build support via musl libc for select binaries

## Role in the stack

## ZOS / Zero-OS

ZOS, also known as Zero-OS, is the operating system layer used to run and manage nodes. It provides the low-level runtime environment for workloads, networking, storage, and automation.

ZOS Initramfs produces the kernel and initramfs that ZOS boots from. The resulting `vmlinuz.efi` is an EFI-bootable image containing the compressed initramfs, early user-space utilities, kernel modules, and initialization scripts required to start the node.

## Relation to ThreeFold

This technology is used within the ThreeFold ecosystem and was first deployed on the ThreeFold Grid. The component itself is designed as reusable infrastructure technology and should be understood by its technical function first, independent of any specific deployment.

## Ownership

This repository is owned and maintained by TF-Tech NV, a Belgian company responsible for the development and maintenance of this technology.

## Dependencies

To compile the initramfs, install the build-time dependencies. See the `autobuild/` directory for helper scripts.

On Ubuntu 18.04 inside a Docker container:

```bash
. autobuild/tf-build-deps.sh
. autobuild/tf-build-settings.sh
```

The first script installs dependencies; the second exports needed variables.

Use `autobuild/tf-build-deps-clean.sh` if Go and Rust are already installed and should not be reinstalled.

## Privileges

Root privileges are required. Some parts need to `chown`, `setuid`, `chmod`, and `mknod` files. Not running as root will fail the build.

## What the build does

1. Download and verify checksums of all required archives
2. Extract the archives
3. Compile third-party software:
   - busybox (full base system)
   - fuse (library and userland tools)
   - openssl and CA certificates
   - util-linux
   - e2fs-progs
   - redis (server only)
   - btrfs-progs
   - libvirt and qemu
   - parted
   - dnsmasq (DHCP for containers)
   - nftables (firewalling and routing)
   - iproute2 (network namespace support)
   - unionfs-fuse (internal fuse layers)
   - eudev and kmod (hardware and module management)
   - smartmontools (S.M.A.R.T monitoring)
   - dmidecode (optional, for libvirt and management)
   - openssh (client and server, for debug)
   - netcat6 (libvirt migration)
   - curl (libcurl for zflist)
   - zflist (0-flist for on-the-fly flist creation)
   - restic (container backup and upload)
   - rtinfo (realtime monitoring)
   - seektime (disk type detection)
   - wireguard (VPN modules and userland tools)
   - zlib (compression library)
4. Integrate core components:
   - Compile `0-fs`
   - Compile `corex` (container remote control)
5. Clean, remove unnecessary files, and strip binaries
6. Copy system configuration and init scripts
7. Compile the kernel (bundling the initramfs inside)

## Usage

### Easy build

```bash
bash initramfs.sh
```

### Custom build options

```
-d --download    only download and extract archives
-b --busybox     only (re)build busybox
-t --tools       only (re)build tools (ssl, fuse, ...)
-c --cores       only (re)build core0 and coreX
-k --kernel      only (re)build kernel (produce final image)
-M --modules     only (re)build kernel modules
-e --extensions  only (re)build extensions
-n --nomirror    don't use a mirror to download files
-l --clean       only clean staging files
-m --mrproper    remove staging files and clean the root
-r --release     force a release build
-h --help        display help
```

The `--kernel` option is useful when you have changed something in the root directory and want to rebuild the kernel with the updated initramfs.

See `.github/workflows/kernel.yaml` for a maintained CI build example.

## Build mode

By default, the build runs in `debug` mode with extra debug options.

To produce a `release` (production) build:
- Use the `--release` flag
- Or override the `BUILDMODE` variable at the top of `initramfs.sh`

Do not use a debug build in production.

## Mirror

By default, archives use a mirror for faster downloads. The mirror URL is set in `initramfs.sh`.

Use `--nomirror` to download from upstream directly. To create your own mirror, run `--download --nomirror` and expose the `archives` directory via HTTP.

## Docker build

```bash
docker run -ti --name zero-os-builder ubuntu:18.04 /bin/bash
```

Requirements:
- Use `ubuntu:18.04` (the only supported base image)
- Mount this repository at `/zos_initramfs`
- Run `autobuild/tf-build.sh` to install dependencies and build everything
- The result is located at `staging/vmlinuz.efi`

## Testing the kernel

### QEMU

```bash
qemu-system-x86_64 -kernel vmlinuz.efi -m 2048 -enable-kvm -cpu host \
    -net nic,model=e1000 -net bridge,br=vm0 -nographic -serial null \
    -serial mon:stdio -append console=ttyS1,115200n8
```

### xhyve (macOS, Intel only)

```bash
xhyve -m 1G -c 2 -s 0:0,hostbridge -s 31,lpc -l com1 -l com2,stdio \
    -s 2:0,virtio-net -f kexec,vmlinuz.efi,,earlyprintk=serial console=ttyS1 acpi=off
```

### Creating a bootable EFI image

```bash
dd if=/dev/zero of=/tmp/zero-os.img bs=1M count=256
mkfs.vfat /tmp/zero-os.img
mkdir -p /mnt/zero-os-iso
mount /tmp/zero-os.img /mnt/zero-os-iso
mkdir -p /mnt/zero-os-iso/EFI/BOOT
cp staging/vmlinuz.efi /mnt/zero-os-iso/EFI/BOOT/BOOTX64.EFI
umount /mnt/zero-os-iso
```

## Extensions

Custom build extensions can be added under the `extensions/` directory. During the build, after the `cores` step and before the `kernel` step, each extension directory is parsed and its `extension-name.sh` script is sourced (not forked), giving it access to all build variables.

Useful variables available in extensions:
- `DISTFILES` — downloaded source archives
- `WORKDIR` — extracted and compiled sources
- `ROOTDIR` — target root directory (initramfs contents)

Rebuild extensions with:

```bash
initramfs.sh --extensions
```

## Hot debug (inject files without rebuilding)

In debug mode, you can override root filesystem files without rebuilding `vmlinuz.efi`.

Requirements:
- A `vfat` filesystem on `/dev/sda1`
- A file called `.zero-os-debug` on the root of that filesystem
- The entire contents of `/dev/sda1` are copied over the real root

With QEMU, add the debug drive as the **first** drive:

```bash
qemu-system-x86_64 -drive file=fat:rw:/tmp/zero-os-debug,format=raw ...
```

Quick setup:

```bash
mkdir /tmp/zero-os-debug/
touch /tmp/zero-os-debug/.zero-os-debug
echo World > /tmp/zero-os-debug/hello
```

## Static build

Some binaries (e.g., `corex`) are compiled as fully static using musl libc. Packages ending in `-musl` are compiled into a separate root directory (`MUSLROOTDIR`) for the musl subsystem. See `corex-musl` and `zlib-musl` as examples.

## Kernel configuration

The kernel config is based on Arch Linux defaults with the following changes:
- Custom default kernel command line
- Initramfs compressed with XZ
- Default hostname set to `zero-os`
- Build version name set to `Zero-OS`
- Initramfs path adjusted to `../../root`
- Sound, multimedia, mice, joystick, touchscreen, tablet, HID, CAN bus, amateur radio, IrDA, NFC, Bluetooth, CAIF, wireless, WiMAX, RF switch, and comedi drivers disabled
- Filesystems `ext4`, `Reiserfs`, `JFS`, `XFS`, `GFS2`, `OCFS2`, `NILFS2`, `F2FS`, `NTFS` disabled
- Modules are not compressed

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
