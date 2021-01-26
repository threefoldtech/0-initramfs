#!/bin/bash
set -ex

MAKEOPTS="-j24"
TOOLCHAINSCR="${PWD}"
# BUILD_ARCH_GNU="armv6j-hardfloat-linux-gnueabi"
# BUILD_ARCH_MUSL="armv6j-hardfloat-linux-musl"
BUILD_ARCH_GNU="aarch64-linux-gnu"
BUILD_ARCH_MUSL="aarch64-linux-musl"
# BUILD_ARCH_GNU="x86_64-pc-linux-gnu"
# BUILD_ARCH_MUSL="x86_64-pc-linux-musl"
BUILD_ARCH="arm64"
BUILD_HOST="x86_64-pc-linux-gnu"
BUILD_PREFIX="/usr/local"
BUILD_ROOT_GNU="${BUILD_PREFIX}/${BUILD_ARCH_GNU}"
BUILD_ROOT_MUSL="${BUILD_PREFIX}/${BUILD_ARCH_MUSL}"
BUILD_TMPDIR="/mnt/ramfs/cross-compile"

mkdir -p "${BUILD_TMPDIR}"
rm -rf "${BUILD_TMPDIR}/*"

pushd "${BUILD_TMPDIR}"

dependencies() {
    apt-get update
    apt-get install -y curl git xz-utils lbzip2 build-essential texinfo python3 patchelf
    apt-get install -y wget libgmp3-dev libmpc-dev gawk bc linux-headers-generic libncurses5-dev
}

initramdeps() {
    # xsltproc: eudev
    # gperf: eudev
    # autopoint: netcat6
    # bison: kernel
    # flex: kernel
    # docbook-xsl: eudev
    # bsdmainutils: kernel (hexdump)
    # libssl-dev: kernel
    # cmake: snappy
    # xxd: corex-musl
    # kmod: kernel module build (depmod)
    apt-get install -y pkg-config m4 bison flex autoconf libtool autogen \
        autopoint xsltproc gperf gettext docbook-xsl bsdmainutils \
        libssl-dev cmake xxd kmod rsync
}

rustchain() {
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    rustup default 1.46.0
    rustup target add arm-unknown-linux-gnueabi
    rustup target add aarch64-unknown-linux-gnu
    rustup target add x86_64-unknown-linux-musl

    mkdir -p ~/.cargo
    echo '[build]' > ~/.cargo/config
    echo '[target.arm-unknown-linux-gnueabi]' >> ~/.cargo/config
    echo "linker = \"${BUILD_ARCH_GNU}-gcc\"" >> ~/.cargo/config
    echo "" >> ~/.cargo/config
    echo '[target.x86_64-unknown-linux-musl]' >> ~/.cargo/config
    echo "linker = \"/usr/local/${BUILD_ARCH_MUSL}/bin/musl-gcc\"" >> ~/.cargo/config
    echo "" >> ~/.cargo/config
    echo '[target.aarch64-unknown-linux-gnu]' >> ~/.cargo/config
    echo "linker = \"${BUILD_ARCH_GNU}-gcc\"" >> ~/.cargo/config
}

gochain() {
    GOVER="1.14.1"
    curl -L https://dl.google.com/go/go${GOVER}.linux-amd64.tar.gz > /tmp/go${GOVER}.linux-amd64.tar.gz
    tar -C /usr/local -xzf /tmp/go${GOVER}.linux-amd64.tar.gz
    mkdir -p /gopath
}

toolchain() {
    BINUTILS_VERSION="2.34"
    MPFR_VERSION="4.1.0"
    # GCC_VERSION="10.2.0"
    GCC_VERSION="9.3.0"
    GLIBC_VERSION="2.31"
    LIBTOOL_VERSION="2.4.6"
    MUSL_VERSION="1.2.2"
    KERNEL_VERSION="5.10.10"

    rm -rf binutils-${BINUTILS_VERSION}
    rm -rf mpfr-${MPFR_VERSION}
    rm -rf gcc-${GCC_VERSION}
    rm -rf gcc-${GCC_VERSION}-build
    rm -rf glibc-${GLIBC_VERSION}
    rm -rf glibc-${GLIBC_VERSION}-build
    rm -rf libtool-${LIBTOOL_VERSION}
    rm -rf musl-${MUSL_VERSION}
    rm -rf linux-${KERNEL_VERSION}

    wget -c http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz
    wget -c http://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
    wget -c http://ftp.gnu.org/gnu/libc/glibc-${GLIBC_VERSION}.tar.xz
    wget -v https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz
    wget -c https://ftpmirror.gnu.org/libtool/libtool-${LIBTOOL_VERSION}.tar.gz
    wget -c https://musl.libc.org/releases/musl-${MUSL_VERSION}.tar.gz

    tar -xf binutils-${BINUTILS_VERSION}.tar.xz
    tar -xf gcc-${GCC_VERSION}.tar.xz
    tar -xf glibc-${GLIBC_VERSION}.tar.xz
    tar -xf linux-${KERNEL_VERSION}.tar.xz
    tar -xf libtool-${LIBTOOL_VERSION}.tar.gz
    tar -xf musl-${MUSL_VERSION}.tar.gz

    pushd linux-${KERNEL_VERSION}
    make ARCH=${BUILD_ARCH} INSTALL_HDR_PATH=${BUILD_ROOT_GNU} headers_install
    popd

    pushd binutils-${BINUTILS_VERSION}
    ./configure --prefix=${BUILD_PREFIX} --target=${BUILD_ARCH_GNU}
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
        --target=${BUILD_ARCH_GNU} \
        --with-sysroot=/ \
        --disable-libsanitizer

    make ${MAKEOPTS} all-gcc
    make install-gcc
    popd

    mkdir -p glibc-${GLIBC_VERSION}-build
    pushd glibc-${GLIBC_VERSION}-build
    ../glibc-${GLIBC_VERSION}/configure \
        --prefix=${BUILD_ROOT_GNU} \
        --disable-multilib \
        --target=${BUILD_ARCH_GNU} \
        --host=${BUILD_ARCH_GNU} \
        --build=${BUILD_HOST} \
        --enable-add-ons

    make install-bootstrap-headers=yes install-headers

    make -j4 csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o ${BUILD_ROOT_GNU}/lib
    ${BUILD_ARCH_GNU}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${BUILD_ROOT_GNU}/lib/libc.so
    touch ${BUILD_ROOT_GNU}/include/gnu/stubs.h

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

    pushd musl-${MUSL_VERSION}
    ./configure --prefix=${BUILD_ROOT_MUSL} \
        --target=${BUILD_ARCH_GNU} \
        --host=${BUILD_ARCH_GNU} \
        --build=${BUILD_HOST}

    make ${MAKEOPTS}
    make install
    popd

    popd

    #cp -a ld-* libns* libm* libdl* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/libresolv* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/libgcc* /mnt/tmp/0-initramfs/root/lib/
    #cp -a /usr/local/armv6j-hardfloat-linux-gnueabi/lib/librt* /mnt/tmp/0-initramfs/root/lib/

    # validate toolchain
    ${BUILD_ARCH_GNU}-gcc confirm.c -o /tmp/confirm-gnu
    ${BUILD_ROOT_MUSL}/bin/musl-gcc confirm.c -o /tmp/confirm-musl

    file /tmp/confirm-gnu
    file /tmp/confirm-musl
}

dependencies
initramdeps
rustchain
gochain
toolchain

