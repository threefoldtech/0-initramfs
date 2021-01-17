OPENSSL_MUSL_PKGNAME="openssl"
OPENSSL_MUSL_VERSION="1.1.1d"
OPENSSL_MUSL_CHECKSUM="3be209000dbc7e1b95bcdf47980a3baa"
OPENSSL_MUSL_LINK="https://www.openssl.org/source/openssl-${OPENSSL_MUSL_VERSION}.tar.gz"

download_openssl_musl() {
    download_file $OPENSSL_MUSL_LINK $OPENSSL_MUSL_CHECKSUM
}

extract_openssl_musl() {
    if [ ! -d "${OPENSSL_MUSL_PKGNAME}-${OPENSSL_MUSL_VERSION}" ]; then
        progress "extracting: ${OPENSSL_MUSL_PKGNAME}-${OPENSSL_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${OPENSSL_MUSL_PKGNAME}-${OPENSSL_MUSL_VERSION}.tar.gz -C .
    fi
}

prepare_openssl_musl() {
    progress "preparing: ${OPENSSL_MUSL_PKGNAME}"

    # CC="${MUSLSYSDIR}/bin/musl-gcc" ./Configure --prefix=/ linux-x86_64 no-shared
    CC="${MUSLSYSDIR}/bin/musl-gcc" ./Configure --prefix=/ linux-armv4 no-shared
}

compile_openssl_musl() {
    progress "compiling: ${OPENSSL_MUSL_PKGNAME}"

    make ${MAKEOPTS}
}

install_openssl_musl() {
    progress "installing: ${OPENSSL_MUSL_PKGNAME}"

    make DESTDIR="${MUSLROOTDIR}" install_sw
}

build_openssl_musl() {
    pushd "${MUSLWORKDIR}/${OPENSSL_MUSL_PKGNAME}-${OPENSSL_MUSL_VERSION}"

    prepare_openssl_musl
    compile_openssl_musl
    install_openssl_musl

    popd
}

registrar_openssl_musl() {
    DOWNLOADERS+=(download_openssl_musl)
    EXTRACTORS+=(extract_openssl_musl)
}

registrar_openssl_musl
