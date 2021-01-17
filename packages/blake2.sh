BLAKE2_PKGNAME="libb2"
BLAKE2_VERSION="0.98.1"
BLAKE2_CHECKSUM="dedace2ae596f37752943d99392ed100"
BLAKE2_LINK="https://github.com/BLAKE2/libb2/releases/download/v0.98.1/libb2-${BLAKE2_VERSION}.tar.gz"

download_blake2() {
    download_file $BLAKE2_LINK $BLAKE2_CHECKSUM
}

extract_blake2() {
    if [ ! -d "${BLAKE2_PKGNAME}-${BLAKE2_VERSION}" ]; then
        progress "extracting: ${BLAKE2_PKGNAME}-${BLAKE2_VERSION}"
        tar -xf ${DISTFILES}/${BLAKE2_PKGNAME}-${BLAKE2_VERSION}.tar.gz -C .
    fi
}

prepare_blake2() {
    progress "configuring: ${BLAKE2_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_blake2() {
    progress "compiling: ${BLAKE2_PKGNAME}"

    make ${MAKEOPTS}
}

install_blake2() {
    progress "installing: ${BLAKE2_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_blake2() {
    pushd "${WORKDIR}/${BLAKE2_PKGNAME}-${BLAKE2_VERSION}"

    prepare_blake2
    compile_blake2
    install_blake2

    popd
}

registrar_blake2() {
    DOWNLOADERS+=(download_blake2)
    EXTRACTORS+=(extract_blake2)
}

registrar_blake2
