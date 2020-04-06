ETHTOOL_VERSION="5.1"
ETHTOOL_CHECKSUM="fe774357084027e3739f17ad76cbab4d"
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
