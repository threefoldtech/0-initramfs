SEEKTIME_VERSION="0.1"
SEEKTIME_CHECKSUM="f16c0d67e9539219261a406bcd395729"
SEEKTIME_LINK="https://github.com/threefoldtech/seektime/archive/v${SEEKTIME_VERSION}.tar.gz"

download_seektime() {
    download_file $SEEKTIME_LINK $SEEKTIME_CHECKSUM seektime-v${SEEKTIME_VERSION}.tar.gz
}

extract_seektime() {
    if [ ! -d "seektime-${SEEKTIME_VERSION}" ]; then
        echo "[+] extracting: seektime-v${SEEKTIME_VERSION}"
        tar -xf ${DISTFILES}/seektime-v${SEEKTIME_VERSION}.tar.gz -C .
    fi
}

prepare_seektime() {
    echo "[+] preparing seektime"
    make mrproper
}

compile_seektime() {
    make ${MAKEOPTS}
}

install_seektime() {
    cp -avL seektime "${ROOTDIR}/usr/bin/"
}

build_seektime() {
    pushd "${WORKDIR}/seektime-${SEEKTIME_VERSION}"

    prepare_seektime
    compile_seektime
    install_seektime

    popd
}

registrar_seektime() {
    DOWNLOADERS+=(download_seektime)
    EXTRACTORS+=(extract_seektime)
}

registrar_seektime
