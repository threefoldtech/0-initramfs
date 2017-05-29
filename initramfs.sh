#!/bin/bash
set -e

# You need to use absolutes path
DISTFILES="${PWD}/archives"
WORKDIR="${PWD}/staging"
CONFDIR="${PWD}/config"
ROOTDIR="${PWD}/root"
INTERNAL="${PWD}/internals/"
EXTENDIR="${PWD}/extensions/"
PATCHESDIR="${PWD}/patches/"

# By default, we compiles with (number of cpu threads + 1)
# you can changes this to reduce computer load
JOBS=$(($(grep -c 'bogomips' /proc/cpuinfo) + 1))
MAKEOPTS="-j ${JOBS}"

#
# Flags
#
OPTS=$(getopt -o dbtckMelmh --long download,busybox,tools,cores,kernel,modules,extensions,clean,mrproper,help -n 'parse-options' -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi

DO_ALL=1

if [ "$OPTS" != " --" ]; then
    DO_ALL=0

    DO_DOWNLOAD=0
    DO_BUSYBOX=0
    DO_TOOLS=0
    DO_CORES=0
    DO_KERNEL=0
    DO_KMODULES=0
    DO_EXTENSIONS=0
    DO_CLEAN=0
    DO_MRPROPER=0

    eval set -- "$OPTS"
fi

while true; do
    case "$1" in
        -d | --download)   DO_DOWNLOAD=1;   shift ;;
        -b | --busybox)    DO_BUSYBOX=1;    shift ;;
        -t | --tools)      DO_TOOLS=1;      shift ;;
        -c | --cores)      DO_CORES=1;      shift ;;
        -k | --kernel)     DO_KERNEL=1;     shift ;;
        -M | --modules)    DO_KMODULES=1;   shift ;;
        -e | --extensions) DO_EXTENSIONS=1; shift ;;
        -l | --clean)      DO_CLEAN=1;      shift ;;
        -m | --mrproper)   DO_MRPROPER=1;   shift ;;
        -h | --help)
            echo "Usage:"
            echo " -d --download    only download and extract archives"
            echo " -b --busybox     only (re)build busybox"
            echo " -t --tools       only (re)build tools (ssl, fuse, ...)"
            echo " -c --cores       only (re)build core0 and coreX"
            echo " -k --kernel      only (re)build kernel (vmlinuz, produce final image)"
            echo " -M --modules     only (re)build kernel modules"
            echo " -e --extensions  only (re)build extensions"
            echo " -l --clean       only clean staging files (extracted sources)"
            echo " -m --mrproper    only remove staging files and clean the root"
            echo " -h --help        display this help message"
            exit 1
        shift ;;

        -- ) shift; break ;;
        * ) break ;;
    esac
done

#
# Including sub-system
#
. "${INTERNAL}"/linux-kernel.sh
. "${INTERNAL}"/busybox.sh
. "${INTERNAL}"/ca-certificates.sh
. "${INTERNAL}"/libfuse.sh
. "${INTERNAL}"/parted.sh
. "${INTERNAL}"/util-linux.sh
. "${INTERNAL}"/btrfs-progs.sh
. "${INTERNAL}"/zerotier.sh
. "${INTERNAL}"/cores.sh
. "${INTERNAL}"/dnsmasq.sh
. "${INTERNAL}"/nftables.sh
. "${INTERNAL}"/iproute2.sh
. "${INTERNAL}"/socat.sh
. "${INTERNAL}"/qemu.sh
. "${INTERNAL}"/libvirt.sh
. "${INTERNAL}"/openssl.sh
. "${INTERNAL}"/dmidecode.sh
. "${INTERNAL}"/unionfs-fuse.sh
. "${INTERNAL}"/gorocksdb.sh
. "${INTERNAL}"/eudev.sh
. "${INTERNAL}"/kmod.sh
. "${INTERNAL}"/dropbear.sh
. "${INTERNAL}"/smartmontools.sh

#
# Utilities
#
pushd() {
    command pushd "$@" > /dev/null
}

popd() {
    command popd "$@" > /dev/null
}

#
# Check the md5 hash from a file ($1) and compare with $2
#
checksum() {
    checksum=$(md5sum "$1" | awk '{ print $1 }')

    if [ "${checksum}" == "$2" ]; then
        echo "[+] checksum match"
        return 0
    else
        echo "[-] checksum mismatch"
        return 1
    fi
}

#
# Sanity check
#
prepare() {
    if [ ! -d "${CONFDIR}" ]; then
        echo "[-] confdir (${CONFDIR}) not found"
        exit 1
    fi

    if [ -z $GOPATH ]; then
        echo "[-] gopath not defined"
        exit 1
    fi

    if [ $UID != 0 ]; then
        echo "[-]"
        echo "[-] === WARNING ==="
        echo "[-] initramfs files need to be chown root"
        echo "[-] you need to run this script as root if you want"
        echo "[-] a working root filesystem, you can build it without"
        echo "[-] root privilege but you will hit trouble when running"
        echo "[-] the kernel, you have been warned."
        echo "[-] === WARNING ==="
        echo "[-]"
        sleep 1
    fi

    mkdir -p "${DISTFILES}"
    mkdir -p "${WORKDIR}"
    mkdir -p "${ROOTDIR}"
    mkdir -p "${EXTENDIR}"

    mkdir -p "${ROOTDIR}"/usr/lib

    if [ ! -e "${ROOTDIR}"/lib ]; then
        ln -s usr/lib "${ROOTDIR}"/lib
    fi

    if [ ! -e "${ROOTDIR}"/lib64 ]; then
        ln -s usr/lib "${ROOTDIR}"/lib64
    fi
}

#
# Download a file and check the hash
# First argument need to be the url, second is the md5 hash
#
download_file() {
    if [ "$3" != "" ]; then
        output=$3
    else
        output=$(basename "$1")
    fi

    echo "[+] downloading: ${output}"

    if [ -f "${output}" ]; then
        # Check for md5 before downloading the file
        checksum ${output} $2 && return
    fi

    # Download the file
    curl -L -k --progress-bar -C - -o "${output}" $1

    # Checksum the downloaded file
    checksum ${output} $2 || false
}

#
# Downloads all the archives, if the archive is already present
# a retry will be done (if the previous file was not downloaded correctly)
#
download_all() {
    pushd $DISTFILES

    download_kernel
    download_busybox
    download_fuse
    download_certs
    download_parted
    download_linuxutil
    download_btrfs
    download_zerotier
    download_dnsmasq
    download_nftables
    download_iproute2
    download_socat
    download_qemu
    download_libvirt
    download_openssl
    download_dmidecode
    download_unionfs
    download_gorocksdb
    download_eudev
    download_kmod
    download_dropbear
    download_smartmon

    popd
}

#
# Extract all archives
#
extract_all() {
    pushd "$WORKDIR"

    extract_kernel
    extract_busybox
    extract_fuse
    extract_certs
    extract_parted
    extract_linuxutil
    extract_btrfs
    extract_zerotier
    extract_dnsmasq
    extract_nftables
    extract_iproute2
    extract_socat
    extract_qemu
    extract_libvirt
    extract_openssl
    extract_dmidecode
    extract_unionfs
    extract_gorocksdb
    extract_eudev
    extract_kmod
    extract_dropbear
    extract_smartmon

    popd
}


#
# Dynamic libraries management
#
resolv_libs() {
    paths=$(grep -hr ^/ /etc/ld.so.conf*)
    for path in $paths; do
        if [ ! -e "$path/libresolv.so.2" ]; then
            continue
        fi

        cp -aL $path/libresolv* "${ROOTDIR}/usr/lib/"
        cp -a $path/libnss_{compat,dns,files}* "${ROOTDIR}/usr/lib/"
        cp -a $path/libnsl* "${ROOTDIR}/usr/lib/"
        return
    done

    echo "[-] warning: no libs found for resolving names"
    echo "[-] you will probably not be able to do dns request"
}

ensure_libs() {
    echo "[+] verifing libraries dependancies"
    pushd "${ROOTDIR}"

    if [ ! -e lib64 ]; then ln -s usr/lib lib64; fi
    if [ ! -e lib ]; then ln -s lib64 lib; fi

    export LD_LIBRARY_PATH=${ROOTDIR}/lib:${ROOTDIR}/usr/lib

    # Copiyng ld-dependancy
    ld=$(ldd /bin/bash | grep ld-linux | awk '{ print $1 }')
    cp -aL $ld lib/

    # Copying resolv libraries
    resolv_libs

    for file in $(find -type f -executable); do
        # Looking for dynamic libraries shared
        libs=$(ldd $file 2>&1 | grep '=>' | grep -v '=>  (' | awk '{ print $3 }' || true)

        # Checking each libraries
        for lib in $libs; do
            libname=$(basename $lib)

            # Library found and not the already installed one
            if [ -e lib/$libname ] || [ "$lib" == "${PWD}/usr/lib/$libname" ]; then
                continue
            fi

            # Grabbing library from host
            cp -aL $lib lib/
        done
    done

    popd
}

#
# Cleaner and optimizer
#
mknod_die() {
    echo "[-] mknod need root access, please run this command as root:"
    echo "[-]   mknod -m 622 "${ROOTDIR}"/dev/console c 5 1"
    echo "[-] and try again."

    exit 1
}

clean_root() {
    echo "[+] cleaning initramfs"

    pushd "${ROOTDIR}"
    mkdir -p dev mnt proc root sys tmp
    rm -rf lib/*.a
    rm -rf lib/*.la
    rm -rf etc/init.d
    rm -rf usr/lib/*.a
    rm -rf usr/lib/*.la
    rm -rf usr/share/doc
    rm -rf usr/share/gtk-doc
    rm -rf usr/share/man
    rm -rf usr/share/locale
    rm -rf usr/share/info
    rm -rf usr/share/bash-completion
    rm -rf usr/lib/pkgconfig
    rm -rf usr/include
    popd
}

optimize_size() {
    echo "[+] optimizing binaries size"
    pushd "${ROOTDIR}"

    for file in $(find ./bin ./sbin ./libexec ./usr/bin ./usr/sbin ./usr/libexec ./usr/lib -type f); do
        # dumping 4 first bytes
        header=$(dd if=$file bs=1 count=4 2> /dev/null | hexdump -e '/1 "%02X"')

        # checking if it's a ELF file
        if [ "$header" == "7F454C46" ]; then
            strip --strip-debug $file || true
        fi
    done

    popd
}

clean_busybox_outdated() {
    echo "[+] removing busybox symlinks not needed anymore"

    pushd "${ROOTDIR}"/usr
    for file in sbin/*; do
        # our script install mostly everything under /usr
        # /sbin/ contains mainly busybox symlink
        # we can safely remove /sbin stuff if we already have it on /usr/sbin
        # this improve the system stability by providing more advanced feature
        # (eg: util-linux blkid and not busybox one)
        if [ -e ../$file ]; then
            rm -f ../$file
        fi
    done
    popd
}

#
# Configuration
#
g8os_root() {
    # Copy init
    echo "[+] installing init script"
    cp "${CONFDIR}/init" "${ROOTDIR}/init"
    chmod +x "${ROOTDIR}/init"

    cp "${CONFDIR}/init-debug" "${ROOTDIR}/init-debug"
    chmod +x "${ROOTDIR}/init-debug"

    # Ensure minimal system directories and symlinks
    echo "[+] creating default directories and files"
    mkdir -p "${ROOTDIR}"/mnt/root
    mkdir -p "${ROOTDIR}"/var/run
    mkdir -p "${ROOTDIR}"/var/log
    mkdir -p "${ROOTDIR}"/var/lock
    mkdir -p "${ROOTDIR}"/var/cache/containers

    # Ensure minimal login logs
    touch "${ROOTDIR}"/var/log/lastlog
    touch "${ROOTDIR}"/var/log/wtmp

    # Legacy mtab symlink
    pushd "${ROOTDIR}/etc"
    ln -sf /proc/mounts mtab
    popd

    # Ensure /run -> /var/run
    pushd "${ROOTDIR}"
    rm -f run
    ln -sf var/run run
    popd

    if [ ! -e "${ROOTDIR}"/dev/console ]; then
        # mknod need to be run as root
        mknod -m 622 "${ROOTDIR}"/dev/console c 5 1 || mknod_die
    fi

    echo "[+] installing g8os configuration"
    mkdir -p "${ROOTDIR}"/etc/g8os
    cp -a "${CONFDIR}"/g8os/* "${ROOTDIR}"/etc/g8os/
    cp -a "${CONFDIR}"/g8os-conf/* "${ROOTDIR}"/etc/g8os/conf/

    # System configuration
    cp -a "${CONFDIR}"/udhcp "${ROOTDIR}"/usr/share/
    cp -a "${CONFDIR}"/nftables.conf "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/nsswitch.conf "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/hosts "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/passwd "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/profile "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/group "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/shells "${ROOTDIR}"/etc/
}

#
# Extensions support
#
build_extensions() {
    pushd "${EXTENDIR}"
    echo "[+] entering extensions system"

    for extension in *; do
        # skip if no extensions found
        [[ $extension == '*' ]] && break

        if [ ! -d "${extension}" ]; then
            echo "[-] ${extension}: not a directory"
            continue
        fi

        pushd "${extension}"

        if [ ! -f "${extension}.sh" ]; then
            echo "[-] ${extension}: no callable script found"
            continue
        fi

        echo "[+] building extension: ${extension}"

        # call extension
        . ./"${extension}.sh"

        popd
    done

    echo "[+] extensions executed"

    popd
}

#
# Helpers
#
get_size() {
    du -shc --apparent-size $1 | tail -1 | awk '{ print $1 }'
}

end_summary() {
    root_size=$(get_size "${ROOTDIR}")
    kernel_size=$(get_size "${WORKDIR}"/vmlinuz.efi)

    echo "[+] --- initramfs ready ---"
    echo "[+] initramfs root size: $root_size"
    echo "[+] kernel size: $kernel_size"
}

#
# Files cleaner
#
remove_staging() {
    echo "[+] cleaning ${WORKDIR}"
    rm -rf "${WORKDIR}"/*

    echo "[+] source cleared"
}

remove_root() {
    echo "[+] cleaning ${ROOTDIR}"
    rm -rf "${ROOTDIR}"/*

    echo "[+] root cleared"
}

#
# Main stuff
#
main() {
    #
    # Display some informations
    #
    echo "================================"
    echo "=  Zero-OS 0-Initramfs Builder ="
    echo "================================"
    echo ""

    #
    # Let's do the job
    #
    prepare

    if [[ $DO_CLEAN == 1 ]]; then
        remove_staging
        exit 0
    fi

    if [[ $DO_MRPROPER == 1 ]]; then
        remove_staging
        remove_root
        exit 0
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_DOWNLOAD == 1 ]]; then
        download_all
        extract_all
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_BUSYBOX == 1 ]]; then
        build_busybox
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_TOOLS == 1 ]]; then
        build_fuse
        build_openssl
        build_certs
        build_parted
        build_linuxutil
        build_btrfs
        build_zerotier
        build_dnsmasq
        build_nftables
        build_iproute2
        build_socat
        build_qemu
        build_libvirt
        build_dmidecode
        build_unionfs
        build_gorocksdb
        build_eudev
        build_kmod
        build_dropbear
        build_smartmon
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_CORES == 1 ]]; then
        build_cores
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_EXTENSIONS == 1 ]]; then
        build_extensions
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_KERNEL == 1 ]] || [[ $DO_KMODULES == 1 ]]; then
        ensure_libs
        clean_root
        optimize_size
        clean_busybox_outdated
        g8os_root
        build_kernel
        end_summary
    fi
}

main
