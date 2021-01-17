SEEKTIME_PKGNAME="seektime"
SEEKTIME_VERSION="0.1"
SEEKTIME_CHECKSUM="f16c0d67e9539219261a406bcd395729"
SEEKTIME_LINK="https://github.com/threefoldtech/seektime/archive/v${SEEKTIME_VERSION}.tar.gz"

download_seektime() {
    download_file $SEEKTIME_LINK $SEEKTIME_CHECKSUM ${SEEKTIME_PKGNAME}-v${SEEKTIME_VERSION}.tar.gz
}

extract_seektime() {
    if [ ! -d "${SEEKTIME_PKGNAME}-${SEEKTIME_VERSION}" ]; then
        progress "extracting: ${SEEKTIME_PKGNAME}-v${SEEKTIME_VERSION}"
        tar -xf ${DISTFILES}/${SEEKTIME_PKGNAME}-v${SEEKTIME_VERSION}.tar.gz -C .
    fi
}

compile_seektime() {
    progress "compiling: ${SEEKTIME_PKGNAME}"

    make ${MAKEOPTS}
}

install_seektime() {
    progress "installing: ${SEEKTIME_PKGNAME}"

    cp -avL seektime "${ROOTDIR}/usr/bin/"
}

build_seektime() {
    pushd "${WORKDIR}/${SEEKTIME_PKGNAME}-${SEEKTIME_VERSION}"

    compile_seektime
    install_seektime

    popd
}

registrar_seektime() {
    DOWNLOADERS+=(download_seektime)
    EXTRACTORS+=(extract_seektime)
}

registrar_seektime
