HAVEGED_VERSION="1.9.2"
HAVEGED_CHECKSUM="fb1d8b3dcbb9d06b30eccd8aa500fd31"
HAVEGED_LINK="http://www.issihosts.com/haveged/haveged-${HAVEGED_VERSION}.tar.gz"

download_haveged() {
    download_file $HAVEGED_LINK $HAVEGED_CHECKSUM
}

extract_haveged() {
    if [ ! -d "haveged-${HAVEGED_VERSION}" ]; then
        echo "[+] extracting: haveged-${HAVEGED_VERSION}"
        tar -xf ${DISTFILES}/haveged-${HAVEGED_VERSION}.tar.gz -C .
    fi
}

prepare_haveged() {
    echo "[+] configuring netcat"
    ./configure
}

compile_haveged() {
    make ${MAKEOPTS}
}

install_haveged() {
    cp -avL src/.libs/haveged "${ROOTDIR}/usr/bin/"
    cp -avL src/.libs/libhavege.s* "${ROOTDIR}/usr/lib/"
}

build_haveged() {
    pushd "${WORKDIR}/haveged-${HAVEGED_VERSION}"

    prepare_haveged
    compile_haveged
    install_haveged

    popd
}

registrar_haveged() {
    DOWNLOADERS+=(download_haveged)
    EXTRACTORS+=(extract_haveged)
}

registrar_haveged
