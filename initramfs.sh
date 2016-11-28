#!/bin/bash
set -e

KERNEL_VERSION="4.7.2"
KERNEL_CHECKSUM="ae493473d074185205a54bc8ad49c3b4"

BUSYBOX_VERSION="1.25.1"
BUSYBOX_CHECKSUM="4f4c5de50b479b11ff636d7d8eb902a2"

FUSE_VERSION="2.9.7"
FUSE_CHECKSUM="91c97e5ae0a40312115dfecc4887bd9d"

CERTS_VERSION="20161102"
CERTS_CHECKSUM="5f26fc332ef3c588814c21bf4766ffa1"

PARTED_VERSION="3.2"
PARTED_CHECKSUM="0247b6a7b314f8edeb618159fa95f9cb"

LINUXUTILS_VERSION="2.29"
LINUXUTILS_CHECKSUM="07b6845f48a421ad5844aa9d58edb837"

REDIS_VERSION="3.2.5"
REDIS_CHECKSUM="d3d2b4dd4b2a3e07ee6f63c526b66b08"

ZEROTIER_VERSION="1.1.14"
ZEROTIER_CHECKSUM="5e381f0864797886b3b3bf20beb49bba"

BTRFS_VERSION="4.8"
BTRFS_CHECKSUM="51f907a15c60fd43a7e97a03b24928a1"

DNSMASQ_VERSION="2.76"
DNSMASQ_CHECKSUM="00f5ee66b4e4b7f14538bf62ae3c9461"

# Branch/Tags name
CORES_VERSION="master"
IPFS_VERSION="v0.4.4"



# You need to use absolutes path
DISTFILES="${PWD}/archives"
WORKDIR="${PWD}/staging"
CONFDIR="${PWD}/config"
ROOTDIR="${PWD}/root"

MAKEOPTS="-j 4"

KERNEL_LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VERSION}.tar.xz"
BUSYBOX_LINK="https://www.busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
FUSE_LINK="https://github.com/libfuse/libfuse/archive/fuse-${FUSE_VERSION}.tar.gz"
CERTS_LINK="http://ftp.fr.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_${CERTS_VERSION}_all.deb"
PARTED_LINK="http://ftp.gnu.org/gnu/parted/parted-${PARTED_VERSION}.tar.xz"
LINUXUTILS_LINK="https://www.kernel.org/pub/linux/utils/util-linux/v2.29/util-linux-${LINUXUTILS_VERSION}.tar.xz"
REDIS_LINK="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"
BTRFS_LINK="https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${BTRFS_VERSION}.tar.xz"
ZEROTIER_LINK="https://github.com/zerotier/ZeroTierOne/archive/${ZEROTIER_VERSION}.tar.gz"
DNSMASQ_LINK="http://www.thekelleys.org.uk/dnsmasq/dnsmasq-${DNSMASQ_VERSION}.tar.xz"

#
# Flags
#
OPTS=$(getopt -o dbtckh --long download,busybox,tools,cores,kernel,help -n 'parse-options' -- "$@")
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

    eval set -- "$OPTS"
fi

while true; do
    case "$1" in
        -d | --download) DO_DOWNLOAD=1; shift ;;
        -b | --busybox)  DO_BUSYBOX=1;  shift ;;
        -t | --tools)    DO_TOOLS=1;    shift ;;
        -c | --cores)    DO_CORES=1;    shift ;;
        -k | --kernel)   DO_KERNEL=1;   shift ;;
        -h | --help)
            echo "Usage:"
            echo " -d --download    only download and extract archives"
            echo " -b --busybox     only (re)build busybox"
            echo " -t --tools       only (re)build tools (ssl, fuse, ...)"
            echo " -c --cores       only (re)build core0 and coreX"
            echo " -k --kernel      only (re)build kernel (produce final image)"
            echo " -h --help        display this help message"
            exit 1
        shift ;;

        -- ) shift; break ;;
        * ) break ;;
    esac
done

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
download() {
    pushd $DISTFILES

    download_file $KERNEL_LINK $KERNEL_CHECKSUM
    download_file $BUSYBOX_LINK $BUSYBOX_CHECKSUM
    download_file $FUSE_LINK $FUSE_CHECKSUM
    download_file $CERTS_LINK $CERTS_CHECKSUM
    download_file $PARTED_LINK $PARTED_CHECKSUM
    download_file $LINUXUTILS_LINK $LINUXUTILS_CHECKSUM
    download_file $REDIS_LINK $REDIS_CHECKSUM
    download_file $BTRFS_LINK $BTRFS_CHECKSUM
    download_file $ZEROTIER_LINK $ZEROTIER_CHECKSUM
    download_file $DNSMASQ_LINK $DNSMASQ_CHECKSUM

    popd
}

#
# Extract all archives
#
extract() {
    pushd "$WORKDIR"

    if [ ! -d "linux-${KERNEL_VERSION}" ]; then
        echo "[+] extracting: linux-${KERNEL_VERSION}"
        tar -xf ${DISTFILES}/linux-${KERNEL_VERSION}.tar.xz -C .
    fi

    if [ ! -d "busybox-${BUSYBOX_VERSION}" ]; then
        echo "[+] extracting: busybox-${BUSYBOX_VERSION}"
        tar -xf ${DISTFILES}/busybox-${BUSYBOX_VERSION}.tar.bz2 -C .
    fi

    if [ ! -d "libfuse-fuse-${FUSE_VERSION}" ]; then
        echo "[+] extracting: fuse-${FUSE_VERSION}"
        tar -xf ${DISTFILES}/fuse-${FUSE_VERSION}.tar.gz -C .
    fi

    if [ ! -d "ca-certificates-${CERTS_VERSION}" ]; then
        echo "[+] extracting: ca-certificates-${CERTS_VERSION}"

        mkdir -p "ca-certificates-${CERTS_VERSION}/temp"
        pushd "ca-certificates-${CERTS_VERSION}/temp"
        ar x ${DISTFILES}/ca-certificates_${CERTS_VERSION}_all.deb
        tar -xf data.tar.xz -C ..
        popd

        rm -rf "ca-certificates-${CERTS_VERSION}/temp"
    fi

    if [ ! -d "parted-${PARTED_VERSION}" ]; then
        echo "[+] extracting: parted-${PARTED_VERSION}"
        tar -xf ${DISTFILES}/parted-${PARTED_VERSION}.tar.xz -C .
    fi

    if [ ! -d "util-linux-${LINUXUTILS_VERSION}" ]; then
        echo "[+] extracting: util-linux-${LINUXUTILS_VERSION}"
        tar -xf ${DISTFILES}/util-linux-${LINUXUTILS_VERSION}.tar.xz -C .
    fi

    if [ ! -d "redis-${REDIS_VERSION}" ]; then
        echo "[+] extracting: redis-${REDIS_VERSION}"
        tar -xf ${DISTFILES}/redis-${REDIS_VERSION}.tar.gz -C .
    fi

    if [ ! -d "btrfs-progs-${BTRFS_VERSION}" ]; then
        echo "[+] extracting: btrfs-progs-${BTRFS_VERSION}"
        tar -xf ${DISTFILES}/btrfs-progs-v${BTRFS_VERSION}.tar.xz -C .
    fi

    if [ ! -d "ZeroTierOne-${ZEROTIER_VERSION}" ]; then
        echo "[+] extracting: ZeroTierOne-${ZEROTIER_VERSION}"
        tar -xf ${DISTFILES}/${ZEROTIER_VERSION}.tar.gz -C .
    fi

    if [ ! -d "dnsmasq-${DNSMASQ_VERSION}" ]; then
        echo "[+] extracting: dnsmasq-${DNSMASQ_VERSION}"
        tar -xf ${DISTFILES}/dnsmasq-${DNSMASQ_VERSION}.tar.xz -C .
    fi

    popd
}


#
# Builders
#

# busybox
prepare_busybox() {
    echo "[+] copying busybox configuration"
    cp "${CONFDIR}/busybox-config" .config
}

compile_busybox() {
    echo "[+] compiling busybox"
    make ${MAKEOPTS}
}

install_busybox() {
    make install
    cp -av _install/* "${ROOTDIR}/"
}

build_busybox() {
    pushd "$WORKDIR/busybox-${BUSYBOX_VERSION}"

    prepare_busybox
    compile_busybox
    install_busybox

    popd
}

# libfuse
prepare_fuse() {
    echo "[+] preparing fuse"
    ./makeconf.sh
    ./configure --prefix /usr
}

compile_fuse() {
    echo "[+] compiling fuse"
    make ${MAKEOPTS}
}

install_fuse() {
    make DESTDIR="${ROOTDIR}" install
}

build_fuse() {
    pushd "${WORKDIR}/libfuse-fuse-${FUSE_VERSION}"

    prepare_fuse
    compile_fuse
    install_fuse

    popd
}

# ca-certificates
prepare_certs() {
    echo "[+] preparing ca-certificates"

    cd usr/share/ca-certificates/
    find * -name '*.crt' | LC_ALL=C sort > ../../../etc/ca-certificates.conf
    cd ../../../

    if [ ! -f ca-certificates-20150426-root.patch ]; then
        echo "[+] downloading patch"
        curl -s https://gist.githubusercontent.com/maxux/a5472530dd88b3480d745388d81e4c7f/raw/373d3b04fb36a28fdf99c6748646335e10317242/ca-certificates-20150426-root.patch > ca-certificates-20150426-root.patch
        patch -p1 < ca-certificates-20150426-root.patch
    fi
}

compile_certs() {
    echo "[+] building certificate database"
    sh usr/sbin/update-ca-certificates --root .
}

install_certs() {
    cp -av * "${ROOTDIR}"
    rm -f "${ROOTDIR}"/ca-certificates-20150426-root.patch
}

build_certs() {
    pushd "${WORKDIR}/ca-certificates-${CERTS_VERSION}"

    prepare_certs
    compile_certs
    install_certs

    popd
}

# kernel
prepare_kernel() {
    echo "[+] copying kernel configuration"
    cp "${CONFDIR}/kernel-config" .config

    # FIXME: add patch for secureboot
}

compile_kernel() {
    echo "[+] compiling the kernel"
    make ${MAKEOPTS}
}

install_kernel() {
    cp arch/x86/boot/bzImage "${WORKDIR}"/vmlinuz.efi
    echo "[+] kernel installed: ${WORKDIR}/vmlinuz.efi"
}

build_kernel() {
    pushd "${WORKDIR}/linux-${KERNEL_VERSION}"

    prepare_kernel
    compile_kernel
    install_kernel

    popd
}

# cores
prepare_cores() {
    echo "[+] loading source code: g8os coreX"
    go get -d -v github.com/g8os/coreX

    echo "[+] loading source code: g8os core0"
    go get -d -v github.com/g8os/core0
}

compile_cores() {
    echo "[+] compiling coreX"
    pushd coreX
    go build -ldflags "-s -w"
    popd

    echo "[+] compiling core0"
    pushd core0
    go build -ldflags "-s -w"
    popd
}

install_cores() {
    echo "[+] copying binaries"
    cp -av coreX/coreX core0/core0 "${ROOTDIR}/sbin/"
}

build_cores() {
    # We need to prepare first (download code)
    prepare_cores
    pushd $GOPATH/src/github.com/g8os

    compile_cores
    install_cores

    popd
}

# parted
prepare_parted() {
    echo "[+] configuring parted"
    ./configure --prefix "${ROOTDIR}"/usr --disable-device-mapper

    if [ ! -f parted-3.2-devmapper.patch ]; then
        echo "[+] downloading patch"
        curl -s https://gist.githubusercontent.com/maxux/a5472530dd88b3480d745388d81e4c7f/raw/d5b67d7bd7714178b3ebe35a2836f64ccaa32431/parted-3.2-devmapper.patch > parted-3.2-devmapper.patch
        patch -p1 < parted-3.2-devmapper.patch
    fi
}

compile_parted() {
    make ${MAKEOPTS}
}

install_parted() {
    make install
}

build_parted() {
    pushd "${WORKDIR}/parted-${PARTED_VERSION}"

    prepare_parted
    compile_parted
    install_parted

    popd
}

# util-linux
prepare_linuxutil() {
    echo "[+] configuring util-linux"
    ./configure --prefix "${ROOTDIR}"/usr \
        --disable-libfdisk \
        --disable-mount \
        --disable-zramctl \
        --disable-mountpoint \
        --disable-eject \
        --disable-lslogins \
        --disable-setpriv \
        --disable-agetty \
        --disable-cramfs \
        --disable-bfs \
        --disable-minix \
        --disable-fdformat \
        --disable-wdctl \
        --disable-cal \
        --disable-logger \
        --disable-switch_root \
        --disable-pivot_root \
        --disable-ipcrm \
        --disable-ipcs \
        --disable-kill \
        --disable-last \
        --disable-utmpdump \
        --disable-mesg \
        --disable-raw \
        --disable-rename \
        --disable-login \
        --disable-nologin \
        --disable-sulogin \
        --disable-su \
        --disable-runuser \
        --disable-ul \
        --disable-more \
        --disable-wall \
        --disable-pylibmount \
        --disable-bash-completion \
        --without-python
}

compile_linuxutil() {
    make ${MAKEOPTS}
}

install_linuxutil() {
    make install
}

build_linuxutil() {
    pushd "${WORKDIR}/util-linux-${LINUXUTILS_VERSION}"

    prepare_linuxutil
    compile_linuxutil
    install_linuxutil

    popd
}

# redis
prepare_redis() {
    echo "[+] preparing redis"
    return
}

compile_redis() {
    make ${MAKEOPTS}
}

install_redis() {
    cp -a src/redis-server "${ROOTDIR}"/usr/bin/
}

build_redis() {
    pushd "${WORKDIR}/redis-${REDIS_VERSION}"

    prepare_redis
    compile_redis
    install_redis

    popd
}

# ipfs
prepare_ipfs() {
    echo "[+] loading source code: ipfs"
    go get -d -v github.com/ipfs/go-ipfs

    pushd "$GOPATH/src/github.com/ipfs/go-ipfs"

    if [ "$(git describe)" != "${IPFS_VERSION}" ]; then
        git checkout ${IPFS_VERSION}
    fi

    if [ ! -f ipfs-dist_get.patch ]; then
        echo "[+] downloading patch"
        curl -s https://gist.githubusercontent.com/maxux/a5472530dd88b3480d745388d81e4c7f/raw/040c8c17be8e71035b8484866c3ef69555e1a61d/ipfs-dist_get.patch > ipfs-dist_get.patch
        patch -p0 < ipfs-dist_get.patch
    fi

    popd
}

compile_ipfs() {
    echo "[+] compiling dependancies"
    make deps

    echo "[+] compiling ipfs"
    pushd cmd/ipfs
    go build -i -ldflags="-X "github.com/ipfs/go-ipfs/repo/config".CurrentCommit=d905d48 -w -s"
    popd
}

install_ipfs() {
    echo "[+] installing ipfs"
    cp -a cmd/ipfs/ipfs "${ROOTDIR}"/usr/bin/
}

build_ipfs() {
    prepare_ipfs
    pushd "$GOPATH/src/github.com/ipfs/go-ipfs"

    compile_ipfs
    install_ipfs

    popd
}

# btrfs-progs
prepare_btrfs() {
    echo "[+] configuring btrfs-progs"
    ./configure --prefix /usr --disable-documentation
}

compile_btrfs() {
    make ${MAKEOPTS}
}

install_btrfs() {
    make DESTDIR="${ROOTDIR}" install
}

build_btrfs() {
    pushd "${WORKDIR}/btrfs-progs-v${BTRFS_VERSION}"

    prepare_btrfs
    compile_btrfs
    install_btrfs

    popd
}

# zerotier
prepare_zerotier() {
    echo "[+] configuring zerotier"
}

compile_zerotier() {
    make one ${MAKEOPTS}
}

install_zerotier() {
    cp -av zerotier-cli zerotier-idtool zerotier-one "${ROOTDIR}/usr/bin/"
}

build_zerotier() {
    pushd "${WORKDIR}/ZeroTierOne-${ZEROTIER_VERSION}"

    prepare_zerotier
    compile_zerotier
    install_zerotier

    popd
}

# dnsmasq
prepare_dnsmasq() {
    echo "[+] configuring dnsmasq"
}

compile_dnsmasq() {
    make ${MAKEOPTS}
}

install_dnsmasq() {
    cp -avL src/dnsmasq "${ROOTDIR}/usr/bin/"
}

build_dnsmasq() {
    pushd "${WORKDIR}/dnsmasq-${DNSMASQ_VERSION}"

    prepare_dnsmasq
    compile_dnsmasq
    install_dnsmasq

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

    if [ ! -e "${ROOTDIR}"/dev/console ]; then
        # mknod need to be run as root
        mknod -m 622 "${ROOTDIR}"/dev/console c 5 1 || mknod_die
    fi

    echo "[+] installing g8os configuration"
    cp -a "${CONFDIR}"/g8os "${ROOTDIR}"/etc/
    cp -a "${CONFDIR}"/root "${ROOTDIR}"/root/conf
    cp -a "${CONFDIR}"/udhcp "${ROOTDIR}"/usr/share/
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

    if [[ $DO_ALL == 1 ]] || [[ $DO_DOWNLOAD == 1 ]]; then
        download
        extract
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_BUSYBOX == 1 ]]; then
        build_busybox
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_TOOLS == 1 ]]; then
        build_fuse
        build_certs
        build_parted
        build_linuxutil
        build_redis
        build_ipfs
        build_btrfs
        build_zerotier
        build_dnsmasq
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
