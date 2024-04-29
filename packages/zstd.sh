ZSTD_VERSION="1.5.6"
ZSTD_CHECKSUM="5a473726b3445d0e5d6296afd1ab6854"
ZSTD_LINK="https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz"

download_zstd() {
    download_file $ZSTD_LINK $ZSTD_CHECKSUM
}

extract_zstd() {
    if [ ! -d "zstd-${ZSTD_VERSION}" ]; then
        echo "[+] extracting: zstd-${ZSTD_VERSION}"
        tar -xf ${DISTFILES}/zstd-${ZSTD_VERSION}.tar.gz -C .
    fi
}

compile_zstd() {
    make ${MAKEOPTS}
}

install_zstd() {
    make PREFIX=/usr install
}

build_zstd() {
    pushd "${WORKDIR}/zstd-${ZSTD_VERSION}"

    compile_zstd
    install_zstd

    popd
}

registrar_zstd() {
    DOWNLOADERS+=(download_zstd)
    EXTRACTORS+=(extract_zstd)
}

registrar_zstd
