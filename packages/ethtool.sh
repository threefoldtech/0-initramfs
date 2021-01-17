ETHTOOL_PKGNAME="ethtool"
ETHTOOL_VERSION="5.1"
ETHTOOL_CHECKSUM="fe774357084027e3739f17ad76cbab4d"
ETHTOOL_LINK="https://mirrors.edge.kernel.org/pub/software/network/ethtool/ethtool-${ETHTOOL_VERSION}.tar.xz"

download_ethtool() {
    download_file $ETHTOOL_LINK $ETHTOOL_CHECKSUM
}

extract_ethtool() {
    if [ ! -d "${ETHTOOL_PKGNAME}-${ETHTOOL_VERSION}" ]; then
        progress "extracting: ${ETHTOOL_PKGNAME}-${ETHTOOL_VERSION}"
        tar -xf ${DISTFILES}/${ETHTOOL_PKGNAME}-${ETHTOOL_VERSION}.tar.xz -C .
    fi
}

prepare_ethtool() {
    progress "preparing: ${ETHTOOL_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_ethtool() {
    progress "compiling: ${ETHTOOL_PKGNAME}"

    make ${MAKEOPTS}
}

install_ethtool() {
    progress "installing: ${ETHTOOL_PKGNAME}"

    cp -av ethtool "${ROOTDIR}"/usr/bin/
}

build_ethtool() {
    pushd "${WORKDIR}/${ETHTOOL_PKGNAME}-${ETHTOOL_VERSION}"

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
