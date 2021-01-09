ZLIB_PKGNAME="zlib"
ZLIB_VERSION="1.2.11"
ZLIB_CHECKSUM="85adef240c5f370b308da8c938951a68"
ZLIB_LINK="https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.xz"

download_zlib() {
    download_file $ZLIB_LINK $ZLIB_CHECKSUM
}

extract_zlib() {
    if [ ! -d "${ZLIB_PKGNAME}-${ZLIB_VERSION}" ]; then
        echo "[+] extracting: ${ZLIB_PKGNAME}-${ZLIB_VERSION}"
        tar -xf ${DISTFILES}/${ZLIB_PKGNAME}-${ZLIB_VERSION}.tar.xz -C .
    fi
}

prepare_zlib() {
    echo "[+] configuring: ${ZLIB_PKGNAME}"

    CC=${BUILDHOST}-gcc ./configure --prefix /usr
}

compile_zlib() {
    echo "[+] compiling: ${ZLIB_PKGNAME}"

    make ${MAKEOPTS}
}

install_zlib() {
    echo "[+] installing: ${ZLIB_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_zlib() {
    pushd "${WORKDIR}/${ZLIB_PKGNAME}-${ZLIB_VERSION}"

    prepare_zlib
    compile_zlib
    install_zlib

    popd
}

registrar_zlib() {
    DOWNLOADERS+=(download_zlib)
    EXTRACTORS+=(extract_zlib)
}

registrar_zlib
