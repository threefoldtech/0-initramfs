OPENSSL_PKGNAME="openssl"
OPENSSL_VERSION="1.1.1d"
OPENSSL_CHECKSUM="3be209000dbc7e1b95bcdf47980a3baa"
OPENSSL_LINK="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"

download_openssl() {
    download_file $OPENSSL_LINK $OPENSSL_CHECKSUM
}

extract_openssl() {
    if [ ! -d "${OPENSSL_PKGNAME}-${OPENSSL_VERSION}" ]; then
        progress "extracting: ${OPENSSL_PKGNAME}-${OPENSSL_VERSION}"
        tar -xf ${DISTFILES}/${OPENSSL_PKGNAME}-${OPENSSL_VERSION}.tar.gz -C .
    fi
}

prepare_openssl() {
    progress "preparing: ${OPENSSL_PKGNAME}"

    # ./config --prefix=/usr shared
    ./Configure --prefix=/usr shared linux-armv4
}

compile_openssl() {
    progress "compiling: ${OPENSSL_PKGNAME}"

    make ${MAKEOPTS}
}

install_openssl() {
    progress "installing: ${OPENSSL_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install_sw

    # Removing useless ssl extra files
    rm -rf "${ROOTDIR}"/usr/ssl
}

build_openssl() {
    pushd "${WORKDIR}/${OPENSSL_PKGNAME}-${OPENSSL_VERSION}"

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
