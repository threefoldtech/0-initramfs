BMON_VERSION="4.0"
BMON_CHECKSUM="8ec83f7e6f6a8a41c60c3ffdc9605e69"
BMON_LINK="https://github.com/tgraf/bmon/releases/download/v${BMON_VERSION}/bmon-${BMON_VERSION}.tar.gz"

download_bmon() {
    download_file $BMON_LINK $BMON_CHECKSUM
}

extract_bmon() {
    if [ ! -d "bmon-${BMON_VERSION}" ]; then
        echo "[+] extracting: bmon-${BMON_VERSION}"
        tar -xf ${DISTFILES}/bmon-${BMON_VERSION}.tar.gz -C .
    fi
}

prepare_bmon() {
    echo "[+] preparing bmon"
    ./configure --prefix /usr
}

compile_bmon() {
    make ${MAKEOPTS}
}

install_bmon() {
    make DESTDIR=${ROOTDIR} install
}

build_bmon() {
    pushd "${WORKDIR}/bmon-${BMON_VERSION}"

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
