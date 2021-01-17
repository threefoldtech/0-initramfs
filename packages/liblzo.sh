LIBLZO_PKGNAME="lzo"
LIBLZO_VERSION="2.10"
LIBLZO_CHECKSUM="39d3f3f9c55c87b1e5d6888e1420f4b5"
LIBLZO_LINK="http://www.oberhumer.com/opensource/lzo/download/lzo-${LIBLZO_VERSION}.tar.gz"

download_liblzo() {
    download_file $LIBLZO_LINK $LIBLZO_CHECKSUM
}

extract_liblzo() {
    if [ ! -d "${LIBLZO_PKGNAME}-${LIBLZO_VERSION}" ]; then
        progress "extracting: ${LIBLZO_PKGNAME}-${LIBLZO_VERSION}"
        tar -xf ${DISTFILES}/${LIBLZO_PKGNAME}-${LIBLZO_VERSION}.tar.gz -C .
    fi
}

prepare_liblzo() {
    progress "configuring: ${LIBLZO_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_liblzo() {
    progress "compiling: ${LIBLZO_PKGNAME}"

    make ${MAKEOPTS}
}

install_liblzo() {
    progress "installing: ${LIBLZO_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_liblzo() {
    pushd "${WORKDIR}/${LIBLZO_PKGNAME}-${LIBLZO_VERSION}"

    prepare_liblzo
    compile_liblzo
    install_liblzo

    popd
}

registrar_liblzo() {
    DOWNLOADERS+=(download_liblzo)
    EXTRACTORS+=(extract_liblzo)
}

registrar_liblzo
