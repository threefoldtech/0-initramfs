NFTABLES_VERSION="1.1.1"
NFTABLES_CHECKSUM="f0a71bcd8c112be7594851b39d4a45c3"
NFTABLES_LINK="https://www.netfilter.org/projects/nftables/files/nftables-${NFTABLES_VERSION}.tar.xz"

LIBNFTNL_VERSION="1.2.8"
LIBNFTNL_CHECKSUM="b0517646bbf47a8cf6ce67aeaeb201c4"
LIBNFTNL_LINK="http://www.iptables.org/projects/libnftnl/files/libnftnl-${LIBNFTNL_VERSION}.tar.xz"

LIBMNL_VERSION="1.0.5"
LIBMNL_CHECKSUM="0bbb70573119ec5d49435114583e7a49"
LIBMNL_LINK="https://netfilter.org/projects/libmnl/files/libmnl-${LIBMNL_VERSION}.tar.bz2"

download_nftables() {
    download_file $NFTABLES_LINK $NFTABLES_CHECKSUM
    download_file $LIBNFTNL_LINK $LIBNFTNL_CHECKSUM
    download_file $LIBMNL_LINK $LIBMNL_CHECKSUM
}

extract_nftables() {
    if [ ! -d "nftables-${NFTABLES_VERSION}" ]; then
        echo "[+] extracting: nftables-${NFTABLES_VERSION}"
        tar -xf ${DISTFILES}/nftables-${NFTABLES_VERSION}.tar.xz -C .
    fi

    if [ ! -d "libnftnl-${LIBNFTNL_VERSION}" ]; then
        echo "[+] extracting: libnftnl-${LIBNFTNL_VERSION}"
        tar -xf ${DISTFILES}/libnftnl-${LIBNFTNL_VERSION}.tar.xz -C .
    fi

    if [ ! -d "libmnl-${LIBMNL_VERSION}" ]; then
        echo "[+] extracting: libmnl-${LIBMNL_VERSION}"
        tar -xf ${DISTFILES}/libmnl-${LIBMNL_VERSION}.tar.bz2 -C .
    fi
}

build_libmnl() {
    echo "[+] building libmnl"

    ./configure --prefix "${ROOTDIR}"/usr/

    make ${MAKEOPTS}
    make install
}

build_libnftnl() {
    echo "[+] building libnftnl"

    export LIBMNL_CFLAGS="-I${ROOTDIR}/usr/include"
    export LIBMNL_LIBS="-L${ROOTDIR}/usr/lib -lmnl"

    ./configure --prefix "${ROOTDIR}"/usr/

    make ${MAKEOPTS}
    make install
}

prepare_nftables() {
    echo "[+] preparing nftables"

    export LIBNFTNL_CFLAGS="-I${ROOTDIR}/usr/include"
    export LIBNFTNL_LIBS="-L${ROOTDIR}/usr/lib -lnftnl"

    ./configure --prefix="/usr" \
        --disable-debug \
        --with-json \
        --with-mini-gmp \
        --disable-man-doc
}

compile_nftables() {
    echo "[+] compiling nftables"
    make ${MAKEOPTS}
}

install_nftables() {
    echo "[+] installing nftables"
    make DESTDIR=${ROOTDIR} install

    unset LIBMNL_CFLAGS
    unset LIBMNL_LIBS
    unset LIBNFTNL_CFLAGS
    unset LIBNFTNL_LIBS
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
