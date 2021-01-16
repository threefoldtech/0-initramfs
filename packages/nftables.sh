NFTABLES_VERSION="0.9.1"
NFTABLES_CHECKSUM="e2facbcad6c5d9bd87a0bf5081a31522"
NFTABLES_LINK="https://www.netfilter.org/projects/nftables/files/nftables-${NFTABLES_VERSION}.tar.bz2"

LIBNFTNL_VERSION="1.1.3"
LIBNFTNL_CHECKSUM="e2a7af0a85c283b2cc837c09635b6bca"
LIBNFTNL_LINK="http://www.iptables.org/projects/libnftnl/files/libnftnl-${LIBNFTNL_VERSION}.tar.bz2"

LIBMNL_VERSION="1.0.4"
LIBMNL_CHECKSUM="be9b4b5328c6da1bda565ac5dffadb2d"
LIBMNL_LINK="https://netfilter.org/projects/libmnl/files/libmnl-${LIBMNL_VERSION}.tar.bz2"

download_nftables() {
    download_file $NFTABLES_LINK $NFTABLES_CHECKSUM
    download_file $LIBNFTNL_LINK $LIBNFTNL_CHECKSUM
    download_file $LIBMNL_LINK $LIBMNL_CHECKSUM
}

extract_nftables() {
    if [ ! -d "nftables-${NFTABLES_VERSION}" ]; then
        echo "[+] extracting: nftables-${NFTABLES_VERSION}"
        tar -xf ${DISTFILES}/nftables-${NFTABLES_VERSION}.tar.bz2 -C .
    fi

    if [ ! -d "libnftnl-${LIBNFTNL_VERSION}" ]; then
        echo "[+] extracting: libnftnl-${LIBNFTNL_VERSION}"
        tar -xf ${DISTFILES}/libnftnl-${LIBNFTNL_VERSION}.tar.bz2 -C .
    fi

    if [ ! -d "libmnl-${LIBMNL_VERSION}" ]; then
        echo "[+] extracting: libmnl-${LIBMNL_VERSION}"
        tar -xf ${DISTFILES}/libmnl-${LIBMNL_VERSION}.tar.bz2 -C .
    fi
}

build_libmnl() {
    echo "[+] building libmnl"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-sysroot=${ROOTDIR}

    make ${MAKEOPTS}
    make DESTDIR=${ROOTDIR} install
}

build_libnftnl() {
    echo "[+] building libnftnl"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-sysroot=${ROOTDIR}

    make ${MAKEOPTS}
    make DESTDIR=${ROOTDIR} install
}

prepare_nftables() {
    echo "[+] preparing nftables"

    # LIBS fixes readline link
    LIBS="-lncurses -lmnl -lnftnl" ./configure \
        --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-debug \
        --with-cli \
        --with-json \
        --with-mini-gmp \
        --with-sysroot=${ROOTDIR} \
        --disable-man-doc
}

compile_nftables() {
    echo "[+] compiling nftables"
    make V=1 ${MAKEOPTS}
}

install_nftables() {
    echo "[+] installing nftables"
    make DESTDIR=${ROOTDIR} install
}

build_nftables() {
    pushd "${WORKDIR}/libmnl-${LIBMNL_VERSION}"
    build_libmnl
    popd

    pushd "${WORKDIR}/libnftnl-${LIBNFTNL_VERSION}"
    build_libnftnl
    popd

    pushd "${WORKDIR}/nftables-${NFTABLES_VERSION}"

    prepare_nftables
    compile_nftables
    install_nftables

    popd
}

registrar_nftables() {
    DOWNLOADERS+=(download_nftables)
    EXTRACTORS+=(extract_nftables)
}

registrar_nftables
