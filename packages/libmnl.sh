LIBMNL_PKGNAME="libmnl"
LIBMNL_VERSION="1.0.4"
LIBMNL_CHECKSUM="be9b4b5328c6da1bda565ac5dffadb2d"
LIBMNL_LINK="https://netfilter.org/projects/libmnl/files/libmnl-${LIBMNL_VERSION}.tar.bz2"

download_libmnl() {
    download_file $LIBMNL_LINK $LIBMNL_CHECKSUM
}

extract_libmnl() {
    if [ ! -d "${LIBMNL_PKGNAME}-${LIBMNL_VERSION}" ]; then
        progress "extracting: ${LIBMNL_PKGNAME}-${LIBMNL_VERSION}"
        tar -xf ${DISTFILES}/${LIBMNL_PKGNAME}-${LIBMNL_VERSION}.tar.bz2 -C .
    fi
}

prepare_libmnl() {
    progress "prepare: ${LIBMNL_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-sysroot=${ROOTDIR}
}

compile_libmnl() {
    progress "compile: ${LIBMNL_PKGNAME}"

    make ${MAKEOPTS}
}

install_libmnl() {
    progress "install: ${LIBMNL_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
}

build_libmnl() {
    pushd "${WORKDIR}/libmnl-${LIBMNL_VERSION}"

    prepare_libmnl
    compile_libmnl
    install_libmnl

    popd
}

registrar_libmnl() {
    DOWNLOADERS+=(download_libmnl)
    EXTRACTORS+=(extract_libmnl)
}

registrar_libmnl
