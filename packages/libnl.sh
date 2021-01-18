LIBNL_PKGNAME="libnl"
LIBNL_VERSION="3.2.25"
LIBNL_CHECKSUM="03f74d0cd5037cadc8cdfa313bbd195c"
LIBNL_LINK="https://www.infradead.org/~tgr/libnl/files/libnl-${LIBNL_VERSION}.tar.gz"

download_libnl() {
    download_file $LIBNL_LINK $LIBNL_CHECKSUM
}

extract_libnl() {
    if [ ! -d "${LIBNL_PKGNAME}-${LIBNL_VERSION}" ]; then
        progress "extracting: ${LIBNL_PKGNAME}-${LIBNL_VERSION}"
        tar -xf ${DISTFILES}/$(basename $LIBNL_LINK) -C .
    fi
}

prepare_libnl() {
    progress "preparing: ${LIBNL_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_libnl() {
    progress "compiling: ${LIBNL_PKGNAME}"

    make ${MAKEOPTS}
}

install_libnl() {
    progress "installing: ${LIBNL_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_libnl() {
    pushd "${WORKDIR}/${LIBNL_PKGNAME}-${LIBNL_VERSION}"

    prepare_libnl
    compile_libnl
    install_libnl

    popd
}

registrar_libnl() {
    DOWNLOADERS+=(download_libnl)
    EXTRACTORS+=(extract_libnl)
}

registrar_libnl
