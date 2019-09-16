OPENSSL_VERSION="1.0.2s"
OPENSSL_CHECKSUM="98ec4e085962689b91d25e1dcdfc14a2"
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

    # Setting custom CFLAGS, ensure shared library compiles
    export CFLAGS="-fPIC"
    ./config --prefix=/usr shared
}

compile_openssl() {
    echo "[+] compiling openssl"
    make ${MAKEOPTS}
}

install_openssl() {
    make INSTALL_PREFIX="${ROOTDIR}" install_sw

    # Removing useless ssl extra files
    rm -rf "${ROOTDIR}"/usr/ssl

    # Cleaning CFLAGS
    unset CFLAGS
}

build_openssl() {
    pushd "${WORKDIR}/openssl-${OPENSSL_VERSION}"

    prepare_openssl
    compile_openssl
    install_openssl

    popd
}

registrar_openssl() {
    DOWNLOADERS+=(download_openssl)
    EXTRACTORS+=(extract_openssl)
}

registrar_openssl
