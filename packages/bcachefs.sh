BCACHEFS_TOOLS_VERSION="1.7.0"
BCACHEFS_TOOLS_CHECKSUM="73a2cb3730c496713fdce6791d4a752c"
BCACHEFS_TOOLS_LINK="https://github.com/koverstreet/bcachefs-tools/archive/refs/tags/v${BCACHEFS_TOOLS_VERSION}.tar.gz"

download_bcachefs_tools() {
    download_file $BCACHEFS_TOOLS_LINK $BCACHEFS_TOOLS_CHECKSUM bcachefs-tools-${BCACHEFS_TOOLS_VERSION}.tar.gz
}

extract_bcachefs_tools() {
    if [ ! -d "bcachefs-tools-${BCACHEFS_TOOLS_VERSION}" ]; then
        echo "[+] extracting: bcachefs-tools-${BCACHEFS_TOOLS_VERSION}"
        tar -xf ${DISTFILES}/bcachefs-tools-${BCACHEFS_TOOLS_VERSION}.tar.gz -C .
    fi
}

compile_bcachefs_tools() {
    make ${MAKEOPTS}
}

install_bcachefs_tools() {
    make PREFIX=/usr DESTDIR=${ROOTDIR} install
}

build_bcachefs_tools() {
    pushd "${WORKDIR}/bcachefs-tools-${BCACHEFS_TOOLS_VERSION}"

    compile_bcachefs_tools
    install_bcachefs_tools

    popd
}

registrar_bcachefs_tools() {
    DOWNLOADERS+=(download_bcachefs_tools)
    EXTRACTORS+=(extract_bcachefs_tools)
}

registrar_bcachefs_tools
