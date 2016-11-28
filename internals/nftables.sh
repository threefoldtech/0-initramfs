NFTABLES_VERSION="0.6"
NFTABLES_CHECKSUM="fd320e35fdf14b7be795492189b13dae"
NFTABLES_LINK="https://www.netfilter.org/projects/nftables/files/nftables-${NFTABLES_VERSION}.tar.bz2"

download_nftables() {
    download_file $NFTABLES_LINK $NFTABLES_CHECKSUM
}

extract_nftables() {
    if [ ! -d "nftables-${NFTABLES_VERSION}" ]; then
        echo "[+] extracting: nftables-${NFTABLES_VERSION}"
        tar -xf ${DISTFILES}/nftables-${NFTABLES_VERSION}.tar.bz2 -C .
    fi
}

prepare_nftables() {
    echo "[+] preparing nftables"
    ./configure --prefix "${ROOTDIR}"/usr --disable-debug --without-cli
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
    pushd "${WORKDIR}/nftables-${NFTABLES_VERSION}"

    prepare_nftables
    compile_nftables
    install_nftables

    popd
}
