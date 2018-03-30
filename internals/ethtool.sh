ETHTOOL_VERSION="4.15"
ETHTOOL_CHECKSUM="1d9a82de6c9131d1caa626f77c6cdb57"
ETHTOOL_LINK="https://mirrors.edge.kernel.org/pub/software/network/ethtool/ethtool-${ETHTOOL_VERSION}.tar.xz"

download_ethtool() {
    download_file $ETHTOOL_LINK $ETHTOOL_CHECKSUM
}

extract_ethtool() {
    if [ ! -d "ethtool-${ETHTOOL_VERSION}" ]; then
        echo "[+] extracting: ethtool-${ETHTOOL_VERSION}"
        tar -xf ${DISTFILES}/ethtool-${ETHTOOL_VERSION}.tar.xz -C .
    fi
}

prepare_ethtool() {
    echo "[+] preparing ethtool"
    ./configure
}

compile_ethtool() {
    echo "[+] compiling ethtool"
    make ${MAKEOPTS}
}

install_ethtool() {
    echo "[+] installing ethtool"
    cp -av ethtool "${ROOTDIR}"/usr/bin/
}

build_ethtool() {
    pushd "${WORKDIR}/ethtool-${ETHTOOL_VERSION}"

    prepare_ethtool
    compile_ethtool
    install_ethtool

    popd
}

registrar_ethtool() {
    DOWNLOADERS+=(download_ethtool)
    EXTRACTORS+=(extract_ethtool)
}

registrar_ethtool
