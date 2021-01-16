DMIDECODE_VERSION="3.2"
DMIDECODE_CHECKSUM="9cc2e27e74ade740a25b1aaf0412461b"
DMIDECODE_LINK="http://ftp.igh.cnrs.fr/pub/nongnu/dmidecode/dmidecode-${DMIDECODE_VERSION}.tar.xz"

download_dmidecode() {
    download_file $DMIDECODE_LINK $DMIDECODE_CHECKSUM
}

extract_dmidecode() {
    if [ ! -d "dmidecode-${DMIDECODE_VERSION}" ]; then
        echo "[+] extracting: dmidecode-${DMIDECODE_VERSION}"
        tar -xf ${DISTFILES}/dmidecode-${DMIDECODE_VERSION}.tar.xz -C .
    fi
}

prepare_dmidecode() {
    echo "[+] preparing dmidecode"
}

compile_dmidecode() {
    echo "[+] compiling dmidecode"
    make ${MAKEOPTS}
}

install_dmidecode() {
    echo "[+] installing dmidecode"
    cp -av dmidecode "${ROOTDIR}"/usr/bin/
}

build_dmidecode() {
    pushd "${WORKDIR}/dmidecode-${DMIDECODE_VERSION}"

    # not supported for arm
    return

    prepare_dmidecode
    compile_dmidecode
    install_dmidecode

    popd
}

registrar_dmidecode() {
    DOWNLOADERS+=(download_dmidecode)
    EXTRACTORS+=(extract_dmidecode)
}

registrar_dmidecode
