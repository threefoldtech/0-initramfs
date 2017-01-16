OPENSSL_VERSION="1.0.2j"
OPENSSL_CHECKSUM="96322138f0b69e61b7212bc53d5e912b"
OPENSSL_LINK="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"

download_openssl() {
    download_file $OPENSSL_LINK $OPENSSL_CHECKSUM
}

extract_openssl() {
    if [ ! -d "openssl-${OPENSSL_VERSION}" ]; then
        echo "[+] extracting: openssl-${OPENSSL_VERSION}"
        tar -xf ${DISTFILES}/openssl-${OPENSSL_VERSION}.tar.gz -C .
    fi
}

prepare_openssl() {
    echo "[+] preparing openssl"
    ./config --prefix=/usr
}

compile_openssl() {
    echo "[+] compiling openssl"
    make ${MAKEOPTS}
}

install_openssl() {
    make INSTALL_PREFIX="${ROOTDIR}"/usr install
}

build_openssl() {
    pushd "${WORKDIR}/openssl-${OPENSSL_VERSION}"

    prepare_openssl
    compile_openssl
    install_openssl

    popd
}
