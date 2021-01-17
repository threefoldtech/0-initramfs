DMIDECODE_PKGNAME="dmidecode"
DMIDECODE_VERSION="3.2"
DMIDECODE_CHECKSUM="9cc2e27e74ade740a25b1aaf0412461b"
DMIDECODE_LINK="http://ftp.igh.cnrs.fr/pub/nongnu/dmidecode/dmidecode-${DMIDECODE_VERSION}.tar.xz"

download_dmidecode() {
    download_file $DMIDECODE_LINK $DMIDECODE_CHECKSUM
}

extract_dmidecode() {
    if [ ! -d "${DMIDECODE_PKGNAME}-${DMIDECODE_VERSION}" ]; then
        progress "extracting: ${DMIDECODE_PKGNAME}-${DMIDECODE_VERSION}"
        tar -xf ${DISTFILES}/${DMIDECODE_PKGNAME}-${DMIDECODE_VERSION}.tar.xz -C .
    fi
}

compile_dmidecode() {
    progress "compiling: ${DMIDECODE_PKGNAME}"

    make ${MAKEOPTS}
}

install_dmidecode() {
    progress "installing: ${DMIDECODE_PKGNAME}"

    cp -av dmidecode "${ROOTDIR}"/usr/bin/
}

build_dmidecode() {
    pushd "${WORKDIR}/${DMIDECODE_PKGNAME}-${DMIDECODE_VERSION}"

    # not supported for arm
    return

    compile_dmidecode
    install_dmidecode

    popd
}

registrar_dmidecode() {
    DOWNLOADERS+=(download_dmidecode)
    EXTRACTORS+=(extract_dmidecode)
}

registrar_dmidecode
