OPENSSL_PKGNAME="openssl"
OPENSSL_VERSION="1.1.1i"
OPENSSL_CHECKSUM="08987c3cf125202e2b0840035efb392c"
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

    if [ "$BUILDARCH" == "x86" ]; then
        ./config --prefix=/usr shared
    fi

    if [ "$BUILDARCH" == "arm" ]; then
        ./Configure --prefix=/usr shared linux-armv4
    fi

    if [ "$BUILDARCH" == "arm64" ]; then
        ./Configure --prefix=/usr shared linux-aarch64
    fi
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
