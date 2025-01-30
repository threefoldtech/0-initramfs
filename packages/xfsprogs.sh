XFSPROGS_VERSION="6.12.0"
XFSPROGS_CHECKSUM="c2f1ddf241f2ce7ea2669de595a4f766"
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
    ./configure --prefix "${ROOTDIR}"/usr
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
