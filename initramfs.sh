#!/bin/bash
set -e

# You need to use absolutes path
DISTFILES="${PWD}/archives"
WORKDIR="${PWD}/staging"
CONFDIR="${PWD}/config"
ROOTDIR="${PWD}/root"
INTERNAL="${PWD}/internals/"

MAKEOPTS="-j 4"

#
# Flags
#
OPTS=$(getopt -o dbtcklmh --long download,busybox,tools,cores,kernel,clean,mrproper,help -n 'parse-options' -- "$@")
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
    DO_CLEAN=0
    DO_MRPROPER=0

    eval set -- "$OPTS"
fi

while true; do
    case "$1" in
        -d | --download) DO_DOWNLOAD=1; shift ;;
        -b | --busybox)  DO_BUSYBOX=1;  shift ;;
        -t | --tools)    DO_TOOLS=1;    shift ;;
        -c | --cores)    DO_CORES=1;    shift ;;
        -k | --kernel)   DO_KERNEL=1;   shift ;;
        -l | --clean)    DO_CLEAN=1;    shift ;;
        -m | --mrproper) DO_MRPROPER=1; shift ;;
        -h | --help)
            echo "Usage:"
            echo " -d --download    only download and extract archives"
            echo " -b --busybox     only (re)build busybox"
            echo " -t --tools       only (re)build tools (ssl, fuse, ...)"
            echo " -c --cores       only (re)build core0 and coreX"
            echo " -k --kernel      only (re)build kernel (produce final image)"
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
. "${INTERNAL}"/redis.sh
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
    output=$(basename "$1")
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
    download_redis
    download_btrfs
    download_zerotier
    download_dnsmasq
    download_nftables
    download_iproute2
    download_socat
    download_qemu
    download_libvirt
    download_openssl

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
    extract_redis
    extract_btrfs
    extract_zerotier
    extract_dnsmasq
    extract_nftables
    extract_iproute2
    extract_socat
    extract_qemu
    extract_libvirt
    extract_openssl

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
# Cleaner
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
    rm -rf etc/udev
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

g8os_root() {
    # copy init
    echo "[+] installing init script"
    cp "${CONFDIR}/init" "${ROOTDIR}/init"
    chmod +x "${ROOTDIR}/init"

    # ensure minimal /dev and /mnt
    echo "[+] creating default directories and files"
    mkdir -p "${ROOTDIR}"/mnt/root
    mkdir -p "${ROOTDIR}"/var/run
    mkdir -p "${ROOTDIR}"/var/log

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
    rm -rf "${ROOTDIR}"/root/conf
    cp -a "${CONFDIR}"/root "${ROOTDIR}"/root/conf
    cp -a "${CONFDIR}"/g8os "${ROOTDIR}"/etc/

    # System configuration
    cp -a "${CONFDIR}"/udhcp "${ROOTDIR}"/usr/share/
    cp -a "${CONFDIR}"/nftables.conf "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/nsswitch.conf "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/hosts "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/passwd "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/group "${ROOTDIR}"/etc/
}

get_size() {
    du -shc $1 | tail -1 | awk '{ print $1 }'
}

end_summary() {
    root_size=$(get_size "${ROOTDIR}")
    kernel_size=$(get_size "${WORKDIR}"/vmlinuz.efi)

    echo "[+] --- initramfs ready ---"
    echo "[+] initramfs root size: $root_size"
    echo "[+] kernel size: $kernel_size"
}

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

main() {
    #
    # Display some informations
    #
    echo "================================"
    echo "==   G8OS Initramfs Builder   =="
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
        build_redis
        build_btrfs
        build_zerotier
        build_dnsmasq
        build_nftables
        build_iproute2
        build_socat
        build_qemu
        build_libvirt
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_CORES == 1 ]]; then
        build_cores
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_KERNEL == 1 ]]; then
        ensure_libs
        clean_root
        g8os_root
        build_kernel
        end_summary
    fi
}

main
