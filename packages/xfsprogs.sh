XFSPROGS_VERSION="5.4.0"
XFSPROGS_CHECKSUM="61232b1cc453780517d9b0c12ff1699b"
XFSPROGS_LINK="https://mirrors.edge.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/xfsprogs-${XFSPROGS_VERSION}.tar.xz"

download_xfsprogs() {
    download_file $XFSPROGS_LINK $XFSPROGS_CHECKSUM
}

extract_xfsprogs() {
    if [ ! -d "xfsprogs-${XFSPROGS_VERSION}" ]; then
        echo "[+] extracting: xfsprogs-${XFSPROGS_VERSION}"
        tar -xf ${DISTFILES}/xfsprogs-${XFSPROGS_VERSION}.tar.xz -C .
    fi
}

prepare_xfsprogs() {
    echo "[+] configuring xfsprogs"
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_xfsprogs() {
    make ${MAKEOPTS}
}

install_xfsprogs() {
    make DESTDIR="${ROOTDIR}" install
}

build_xfsprogs() {
    pushd "${WORKDIR}/xfsprogs-${XFSPROGS_VERSION}"

    prepare_xfsprogs
    compile_xfsprogs
    install_xfsprogs

    popd
}

registrar_xfsprogs() {
    DOWNLOADERS+=(download_xfsprogs)
    EXTRACTORS+=(extract_xfsprogs)
}

registrar_xfsprogs
