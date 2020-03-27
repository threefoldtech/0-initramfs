ZLIB_MUSL_PKGNAME="zlib"
ZLIB_MUSL_VERSION="1.2.11"
ZLIB_MUSL_CHECKSUM="85adef240c5f370b308da8c938951a68"
ZLIB_MUSL_LINK="https://www.zlib.net/zlib-${ZLIB_MUSL_VERSION}.tar.xz"

download_zlib_musl() {
    download_file $ZLIB_MUSL_LINK $ZLIB_MUSL_CHECKSUM
}

extract_zlib_musl() {
    if [ ! -d "${ZLIB_MUSL_PKGNAME}-${ZLIB_MUSL_VERSION}" ]; then
        echo "[+] extracting: ${ZLIB_MUSL_PKGNAME}-${ZLIB_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${ZLIB_MUSL_PKGNAME}-${ZLIB_MUSL_VERSION}.tar.xz -C .
    fi
}

prepare_zlib_musl() {
    echo "[+] configuring: ${ZLIB_MUSL_PKGNAME}"

    CC="musl-gcc" ./configure --prefix /
}

compile_zlib_musl() {
    echo "[+] compiling: ${ZLIB_MUSL_PKGNAME}"

    make ${MAKEOPTS}
}

install_zlib_musl() {
    echo "[+] installing: ${ZLIB_MUSL_PKGNAME}"

    make DESTDIR="${MUSLROOTDIR}" install
}

build_zlib_musl() {
    pushd "${MUSLWORKDIR}/${ZLIB_MUSL_PKGNAME}-${ZLIB_MUSL_VERSION}"

    prepare_zlib_musl
    compile_zlib_musl
    install_zlib_musl

    popd
}

registrar_zlib_musl() {
    DOWNLOADERS+=(download_zlib_musl)
    EXTRACTORS+=(extract_zlib_musl)
}

registrar_zlib_musl
