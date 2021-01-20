SHIMLOGS_PKGNAME="shim-logs"
SHIMLOGS_VERSION="0.3"
SHIMLOGS_CHECKSUM="f2b3ceaca8abe09fe6b96b694569d0a3"
SHIMLOGS_LINK="https://github.com/threefoldtech/shim-logs/archive/v${SHIMLOGS_VERSION}.tar.gz"

download_shimlogs() {
    download_file $SHIMLOGS_LINK $SHIMLOGS_CHECKSUM ${SHIMLOGS_PKGNAME}-${SHIMLOGS_VERSION}.tar.gz
}

extract_shimlogs() {
    if [ ! -d "${SHIMLOGS_PKGNAME}-${SHIMLOGS_VERSION}" ]; then
        progress "extracting: ${SHIMLOGS_PKGNAME}-${SHIMLOGS_VERSION}"
        tar -xf ${DISTFILES}/${SHIMLOGS_PKGNAME}-${SHIMLOGS_VERSION}.tar.gz -C .
    fi
}

prepare_shimlogs() {
    progress "preparing: ${SHIMLOGS_PKGNAME}"

    sed -i s/'CFLAGS  ='/'CFLAGS  +='/ Makefile
    sed -i s/'LDFLAGS ='/'LDFLAGS +='/ Makefile
}

compile_shimlogs() {
    progress "compiling: ${SHIMLOGS_PKGNAME}"

    make CC=$CC ${MAKEOPTS}
}

install_shimlogs() {
    progress "installing: ${SHIMLOGS_PKGNAME}"

    mkdir -p "${RUNDIR}/usr/bin"

    cp -a shim-logs "${RUNDIR}"/usr/bin/
}

build_shimlogs() {
    pushd "${WORKDIR}/${SHIMLOGS_PKGNAME}-${SHIMLOGS_VERSION}"

    prepare_shimlogs
    compile_shimlogs
    install_shimlogs

    popd
}

registrar_shimlogs() {
    DOWNLOADERS+=(download_shimlogs)
    EXTRACTORS+=(extract_shimlogs)
}

registrar_shimlogs
