#!/bin/bash
set -e

# Host dependancies (ubuntu 16.04):
#  - golang 1.7.1
#  - curl libtool gettext m4 autoconf uuid-dev libncurses5-dev libreadline-dev bc

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

    mkdir -p "${DISTFILES}"
    mkdir -p "${WORKDIR}"
    mkdir -p "${ROOTDIR}"
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
    curl -L --progress-bar -C - -o "${output}" $1

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
}

compile_kernel() {
    echo "[+] compiling the kernel"
    make ${MAKEOPTS}
}

install_kernel() {
    ls -alh arch/x86/boot/bzImage
    return
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
    pushd coreX && go build && popd

    echo "[+] compiling core0"
    pushd core0 && go build && popd
}

install_cores() {
    echo "[+] copying binaries"
    cp -av coreX/coreX core0/core0 "${ROOTDIR}/sbin/"
}

build_cores() {
    # We need to prepare first to download code
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

#
# Dynamic libraries management
#
ensure_libs() {
    echo "[+] verifing libraries dependancies"
    pushd "${ROOTDIR}"

    if [ ! -e lib64 ]; then ln -s usr/lib lib64; fi
    if [ ! -e lib ]; then ln -s lib64 lib; fi

    # Copiyng ld-dependancy
    ld=$(ldd /bin/bash | grep ld-linux | awk '{ print $1 }')
    cp -aL $ld lib/

    for file in $(find -type f -executable); do
        # Looking for dynamic libraries shared
        libs=$(ldd $file 2>&1 | grep '=>' | grep -v '=>  (' | awk '{ print $3 }' || true)

        # Checking each libraries
        for lib in $libs; do
            libname=$(basename $lib)

            # Library found
            if [ -e lib/$libname ]; then
                continue
            fi

            # Grabbing library from host
            cp -aL $lib usr/lib/
        done
    done

    popd
}

#
# Cleaner
#
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

    # copy init
    cp "${CONFDIR}/init" "${ROOTDIR}/init"
    chmod +x "${ROOTDIR}/init"
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
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_CORES == 1 ]]; then
        build_cores
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_KERNEL == 1 ]]; then
        ensure_libs
        clean_root
        build_kernel
    fi
}

main
