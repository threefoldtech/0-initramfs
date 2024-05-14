LIBAIO_VERSION="0.3.113"
LIBAIO_CHECKSUM="605237f35de238dfacc83bcae406d95d"
LIBAIO_LINK="https://pagure.io/libaio/archive/libaio-${LIBAIO_VERSION}/libaio-${LIBAIO_VERSION}.tar.gz"

download_libaio() {
    download_file $LIBAIO_LINK $LIBAIO_CHECKSUM
}

extract_libaio() {
    if [ ! -d "libaio-${LIBAIO_VERSION}" ]; then
        echo "[+] extracting: libaio-${LIBAIO_VERSION}"
        tar -xf ${DISTFILES}/libaio-${LIBAIO_VERSION}.tar.gz -C .
    fi
}

compile_libaio() {
    make ${MAKEOPTS}
}

install_libaio() {
    make install
}

build_libaio() {
    pushd "${WORKDIR}/libaio-${LIBAIO_VERSION}"

    compile_libaio
    install_libaio

    popd
}

registrar_libaio() {
    DOWNLOADERS+=(download_libaio)
    EXTRACTORS+=(extract_libaio)
}

registrar_libaio
