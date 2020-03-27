LIBWEBSOCKETS_MUSL_PKGNAME="libwebsockets"
LIBWEBSOCKETS_MUSL_VERSION="3.2.0"
LIBWEBSOCKETS_MUSL_CHECKSUM="1d06f5602604e67e6f50cef9857c6b0c"
LIBWEBSOCKETS_MUSL_LINK="https://github.com/warmcat/libwebsockets/archive/v${LIBWEBSOCKETS_MUSL_VERSION}.tar.gz"

download_libwebsockets_musl() {
    download_file $LIBWEBSOCKETS_MUSL_LINK $LIBWEBSOCKETS_MUSL_CHECKSUM ${LIBWEBSOCKETS_MUSL_PKGNAME}-${LIBWEBSOCKETS_MUSL_VERSION}.tar.gz
}

extract_libwebsockets_musl() {
    if [ ! -d "${LIBWEBSOCKETS_MUSL_PKGNAME}-${LIBWEBSOCKETS_MUSL_VERSION}" ]; then
        echo "[+] extracting: ${LIBWEBSOCKETS_MUSL_PKGNAME}-${LIBWEBSOCKETS_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${LIBWEBSOCKETS_MUSL_PKGNAME}-${LIBWEBSOCKETS_MUSL_VERSION}.tar.gz -C .
    fi
}

prepare_libwebsockets_musl() {
    echo "[+] configuring: ${LIBWEBSOCKETS_MUSL_PKGNAME}"

    mkdir -p build && cd build
    CC="musl-gcc" cmake -DLWS_IPV6=ON \
        -DCMAKE_INSTALL_PREFIX=/ \
        -DLWS_UNIX_SOCK=ON \
        -DLWS_WITHOUT_TESTAPPS=ON \
        -DLWS_WITH_SHARED=OFF \
        -DOPENSSL_ROOT_DIR=${MUSLROOTDIR} \
        ..
}

compile_libwebsockets_musl() {
    echo "[+] compiling: ${LIBWEBSOCKETS_MUSL_PKGNAME}"

    make ${MAKEOPTS}
}

install_libwebsockets_musl() {
    echo "[+] installing: ${LIBWEBSOCKETS_MUSL_PKGNAME}"

    make DESTDIR="${MUSLROOTDIR}" install
}

build_libwebsockets_musl() {
    pushd "${MUSLWORKDIR}/${LIBWEBSOCKETS_MUSL_PKGNAME}-${LIBWEBSOCKETS_MUSL_VERSION}"

    prepare_libwebsockets_musl
    compile_libwebsockets_musl
    install_libwebsockets_musl

    popd
}

registrar_libwebsockets_musl() {
    DOWNLOADERS+=(download_libwebsockets_musl)
    EXTRACTORS+=(extract_libwebsockets_musl)
}

registrar_libwebsockets_musl
