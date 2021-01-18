BMON_PKGNAME="bmon"
BMON_VERSION="4.0"
BMON_CHECKSUM="8ec83f7e6f6a8a41c60c3ffdc9605e69"
BMON_LINK="https://github.com/tgraf/bmon/releases/download/v4.0/bmon-${BMON_VERSION}.tar.gz"

download_bmon() {
    download_file $BMON_LINK $BMON_CHECKSUM
}

extract_bmon() {
    if [ ! -d "${BMON_PKGNAME}-${BMON_VERSION}" ]; then
        progress "extracting: ${BMON_PKGNAME}-${BMON_VERSION}"
        tar -xf ${DISTFILES}/${BMON_PKGNAME}-${BMON_VERSION}.tar.gz -C .
    fi
}

prepare_bmon() {
    progress "preparing: ${BMON_PKGNAME}"

    LIBNL_CFLAGS="-I${ROOTDIR}/usr/include/libnl3" ./configure \
        --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_bmon() {
    progress "compiling: ${BMON_PKGNAME}"

    make ${MAKEOPTS}
}

install_bmon() {
    progress "installing: ${BMON_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_bmon() {
    pushd "${WORKDIR}/${BMON_PKGNAME}-${BMON_VERSION}"

    prepare_bmon
    compile_bmon
    install_bmon

    popd
}

registrar_bmon() {
    DOWNLOADERS+=(download_bmon)
    EXTRACTORS+=(extract_bmon)
}

registrar_bmon
