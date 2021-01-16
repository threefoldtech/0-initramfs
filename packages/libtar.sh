LIBTAR_PKGNAME="libtar"
LIBTAR_VERSION="1.2.20"
LIBTAR_CHECKSUM="dcdcdf8cfbbd3df3862198b0897071b6"
LIBTAR_LINK="https://github.com/tklauser/libtar/archive/v${LIBTAR_VERSION}.tar.gz"

download_libtar() {
    download_file $LIBTAR_LINK $LIBTAR_CHECKSUM libtar-${LIBTAR_VERSION}.tar.gz
}

extract_libtar() {
    if [ ! -d "${LIBTAR_PKGNAME}-${LIBTAR_VERSION}" ]; then
        echo "[+] extracting: ${LIBTAR_PKGNAME}-${LIBTAR_VERSION}"
        tar -xf ${DISTFILES}/${LIBTAR_PKGNAME}-${LIBTAR_VERSION}.tar.gz -C .
    fi
}

prepare_libtar() {
    echo "[+] configuring: ${LIBTAR_PKGNAME}"

    autoreconf --force --install

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-sysroot=${ROOTDIR}

    # fix strip fail on cross-compilation
    sed -i s/'stripme=" -s"'/stripme=/g libtool

}

compile_libtar() {
    echo "[+] compiling: ${LIBTAR_PKGNAME}"

    make ${MAKEOPTS}
}

install_libtar() {
    echo "[+] installing: ${LIBTAR_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_libtar() {
    pushd "${WORKDIR}/${LIBTAR_PKGNAME}-${LIBTAR_VERSION}"

    prepare_libtar
    compile_libtar
    install_libtar

    popd
}

registrar_libtar() {
    DOWNLOADERS+=(download_libtar)
    EXTRACTORS+=(extract_libtar)
}

registrar_libtar
