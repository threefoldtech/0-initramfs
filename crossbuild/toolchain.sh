#!/bin/bash
set -ex

# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
MAKEOPTS="-j5"
BUILD_ARCH="armv6j-hardfloat-linux-gnueabi"
BUILD_HOST="x86_64-pc-linux-gnu"
BUILD_PREFIX="/usr/local"
BUILD_ROOT="${BUILD_PREFIX}/${BUILD_ARCH}"

mkdir -p /opt/tmp/cross-compile
pushd /opt/tmp/cross-compile

dependencies() {
    apt-get update
    apt-get install -y curl git xz-utils lbzip2 build-essential texinfo python3 patchelf
    apt-get install -y wget build-essential xz-utils libgmp3-dev libmpc-dev gawk bc linux-headers-generic libncurses5-dev
}

initramdeps() {
    # xsltproc: eudev
    # gperf: eudev
    # autopoint: netcat6
    # bison:
    # flex:
    apt-get install -y pkg-config m4 bison flex autoconf libtool autogen autopoint xsltproc gperf
}

toolchain() {
    BINUTILS_VERSION="2.34"
    MPFR_VERSION="4.1.0"
    GCC_VERSION="9.3.0"
    GLIBC_VERSION="2.32"
    LIBTOOL_VERSION="2.4.6"

    rm -rf binutils-${BINUTILS_VERSION}
    rm -rf mpfr-${MPFR_VERSION}
    rm -rf gcc-${GCC_VERSION}
    rm -rf gcc-${GCC_VERSION}-build
    rm -rf glibc-${GLIBC_VERSION}
    rm -rf glibc-${GLIBC_VERSION}-build
    rm -rf libtool-${LIBTOOL_VERSION}
    # rm -rf linux-4.9.35

    wget -c http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz
    wget -c http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
    wget -c http://ftp.gnu.org/gnu/libc/glibc-${GLIBC_VERSION}.tar.xz
    wget -c https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.35.tar.xz
    wget -c https://ftpmirror.gnu.org/libtool/libtool-${LIBTOOL_VERSION}.tar.gz

    tar -xf binutils-${BINUTILS_VERSION}.tar.xz
    tar -xf gcc-${GCC_VERSION}.tar.xz
    tar -xf glibc-${GLIBC_VERSION}.tar.xz
    tar -xf linux-4.9.35.tar.xz
    tar -xf libtool-${LIBTOOL_VERSION}.tar.gz

    pushd linux-4.9.35
    make ARCH=arm INSTALL_HDR_PATH=${BUILD_ROOT} headers_install
    popd

    pushd binutils-${BINUTILS_VERSION}
    ./configure --prefix=${BUILD_PREFIX} --target=${BUILD_ARCH}
    make ${MAKEOPTS}
    make install
    popd

    mkdir -p gcc-${GCC_VERSION}-build
    pushd gcc-${GCC_VERSION}-build
    ../gcc-${GCC_VERSION}/configure \
        --prefix=${BUILD_PREFIX} \
        --enable-languages="c,c++" \
        --disable-multilib \
        --host=${BUILD_HOST} \
        --build=${BUILD_HOST} \
        --target=${BUILD_ARCH} \
        --with-sysroot=/

    make ${MAKEOPTS} all-gcc
    make install-gcc
    popd

    mkdir -p glibc-${GLIBC_VERSION}-build
    pushd glibc-${GLIBC_VERSION}-build
    ../glibc-${GLIBC_VERSION}/configure --prefix=${BUILD_ROOT} \
        --disable-multilib \
        --target=${BUILD_ARCH} \
        --host=${BUILD_ARCH} \
        --build=${BUILD_HOST} \
        --enable-add-ons

    make install-bootstrap-headers=yes install-headers

    make -j4 csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o ${BUILD_ROOT}/lib
    ${BUILD_ARCH}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${BUILD_ROOT}/lib/libc.so
    touch ${BUILD_ROOT}/include/gnu/stubs.h

    popd

    pushd gcc-${GCC_VERSION}-build
    make ${MAKEOPTS} all-target-libgcc
    make install-target-libgcc
    popd

    # libstdc
    pushd glibc-${GLIBC_VERSION}-build
    make ${MAKEOPTS}
    make install
    popd

    # libstdc++
    pushd gcc-${GCC_VERSION}-build
    make ${MAKEOPTS}
    make install
    popd

    popd



    #cp -a ld-* libns* libm* libdl* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/libresolv* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/libgcc* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/librt* /mnt/tmp/0-initramfs/root/lib/

    # libtool
    # pushd libtool-${LIBTOOL_VERSION}
    # ./configure --prefix=${BUILD_PREFIX} --host=${BUILD_ARCH} --program-prefix=${BUILD_ARCH}-
    # make ${MAKEOPTS}
    # make install
    # popd

    # validate toolchain
    armv6j-hardfloat-linux-gnueabi-gcc confirm.c -o /dev/null
}

golang() {
    curl https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz > /tmp/go1.8.linux-amd64.tar.gz
    tar -C /usr/local -xzf /tmp/go1.8.linux-amd64.tar.gz
    mkdir -p /gopath
}

golang_env() {
    export PATH=$PATH:/usr/local/go/bin
    export GOPATH=/gopath
}

usertools() {
    # git clone https://github.com/zero-os/0-initramfs /opt/0-initramfs

    # cd /opt/0-initramfs
    # bash initramfs.sh --download


    #
    #
    #
    #

    # wget -c http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.tar.gz
    wget -c http://download.savannah.gnu.org/releases/attr/attr-2.4.47.src.tar.gz
    wget -c https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.24.tar.xz
    # wget -c https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-24.tar.gz
    # wget -c https://www.kernel.org/pub/linux/utils/util-linux/v2.30/util-linux-2.30.2.tar.xz
    wget -c https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.43.6/e2fsprogs-1.43.6.tar.xz
    wget -c https://zlib.net/zlib-1.2.11.tar.xz
    wget -c https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.0.tar.gz
    wget -c http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
    wget -c http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz

    # tar -xvf gettext-0.19.tar.gz
    tar -xvf attr-2.4.47.src.tar.gz
    tar -xvf libcap-2.24.tar.xz
    # tar -xvf kmod-24.tar.gz
    # tar -xvf util-linux-2.30.2.tar.xz
    tar -xvf e2fsprogs-1.43.6.tar.xz
    tar -xvf zlib-1.2.11.tar.xz
    tar -xvf lzo-2.10.tar.gz
    tar -xvf ncurses-6.0.tar.gz
    tar -xvf gperf-3.1.tar.gz

    # pushd gettext-0.19
    # ./configure --prefix ${BUILD_PREFIX} --build=${BUILD_HOST} --host=${BUILD_ARCH} \
    #     --disable-libasprintf \
    #     --disable-java
    #
    # make -j 5
    # make install
    # popd

    pushd zlib-1.2.11
    export CC=${BUILD_ARCH}-gcc
    ./configure --shared --prefix=${BUILD_ROOT} --uname=linux
    make ${MAKEOPTS}
    make install
    unset CC
    popd

    pushd lzo-2.10
    ./configure --prefix ${BUILD_ROOT} --build=${BUILD_HOST} --host=${BUILD_ARCH}
    make ${MAKEOPTS}
    make install
    popd

    # -- libcap
    pushd attr-2.4.47
    ./configure --prefix ${BUILD_ROOT} --build=${BUILD_HOST} --host=${BUILD_ARCH} --enable-gettext=no
    make ${MAKEOPTS}
    make install install-lib

    pushd /usr/local/armv6j-hardfloat-linux-gnueabi/lib/
    ln -sf libattr.so.1 libattr.so
    popd

    popd

    # -- core0
    pushd libcap-2.24
    make BUILD_CC=gcc CC=${BUILD_ARCH}-gcc AR=${BUILD_ARCH}-ar
    make prefix=${BUILD_ROOT} BUILD_CC=gcc CC=${BUILD_ARCH}-gcc AR=${BUILD_ARCH}-ar RAISE_SETFCAP=no install
    cp -rv ${BUILD_ROOT}/lib64/* ${BUILD_ROOT}/lib/
    popd

    # pushd kmod-24
    # ./configure --prefix ${BUILD_ROOT} --build=${BUILD_HOST} --host=${BUILD_ARCH} \
    #     --enable-shared \
    #     --disable-static \
    #     --enable-tools \
    #     --disable-debug \
    #     --disable-gtk-doc \
    #     --without-xz \
    #     --without-zlib \
    #     --disable-python
    # make ${MAKEOPTS}
    # make install
    # popd

    # -- btrfs
    pushd e2fsprogs-1.43.6
    ./configure --prefix ${BUILD_ROOT} --build=${BUILD_HOST} --host=${BUILD_ARCH}
    make ${MAKEOPTS}
    make install install-libs
    popd

    # -- parted
    pushd ncurses-6.0
    export CPPFLAGS="-P"

    ./configure --prefix=${BUILD_ROOT} --build=${BUILD_HOST} --host=${BUILD_ARCH} --enable-widec
    make ${MAKEOPTS}
    make install

    unset CPPFLAGS
    popd
}

dependencies
initramdeps
toolchain
# golang
# golang_env
# usertools

