NFTABLES_VERSION="0.6"
NFTABLES_CHECKSUM="fd320e35fdf14b7be795492189b13dae"
NFTABLES_LINK="https://www.netfilter.org/projects/nftables/files/nftables-${NFTABLES_VERSION}.tar.bz2"

LIBNFTNL_VERSION="1.0.6"
LIBNFTNL_CHECKSUM="6d7f9f161538ca7efd535dcc70caf964"
LIBNFTNL_LINK="http://www.iptables.org/projects/libnftnl/files/libnftnl-${LIBNFTNL_VERSION}.tar.bz2"

download_nftables() {
    download_file $NFTABLES_LINK $NFTABLES_CHECKSUM
    download_file $LIBNFTNL_LINK $LIBNFTNL_CHECKSUM
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
}

build_libnftnl() {
    echo "[+] building libnftnl"
    ./configure --prefix "${ROOTDIR}"/usr/
    make ${MAKEOPTS}
    make install
}

prepare_nftables() {
    echo "[+] preparing nftables"

    export LIBNFTNL_CFLAGS="-I${ROOTDIR}/usr/include"
    export LIBNFTNL_LIBS="-L${ROOTDIR}/usr/lib -lnftnl"

    ./configure --prefix "${ROOTDIR}"/usr --disable-debug --without-cli --with-mini-gmp

    # Force to skip documentation compilation
    echo "all:" > doc/Makefile
}

compile_nftables() {
    echo "[+] compiling nftables"
    make ${MAKEOPTS}
}

install_nftables() {
    echo "[+] installing nftables"
    cp -a src/nft "${ROOTDIR}"/usr/sbin/
}

build_nftables() {
    pushd "${WORKDIR}/libnftnl-${LIBNFTNL_VERSION}"
    build_libnftnl
    popd

    pushd "${WORKDIR}/nftables-${NFTABLES_VERSION}"

    prepare_nftables
    compile_nftables
    install_nftables

    popd
}
