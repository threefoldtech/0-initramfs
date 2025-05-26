LSHW_VERSION="B.02.20"
LSHW_CHECKSUM="5805eba5f31886582fff673c5dccdb3b"
LSHW_LINK="https://github.com/lyonel/lshw/archive/refs/tags/${LSHW_VERSION}.tar.gz"

download_lshw() {
    download_file $LSHW_LINK $LSHW_CHECKSUM
}

extract_lshw() {
    if [ ! -d "lshw-${LSHW_VERSION}" ]; then
        echo "[+] extracting: lshw-${LSHW_VERSION}"
        tar -xf ${DISTFILES}/lshw-${LSHW_VERSION}.tar.gz -C .
    fi
}

prepare_lshw() {
    echo "[+] configuring lshw"
    export CC="${CC:-gcc}"
    export CXX="${CXX:-g++}"
    export CFLAGS="${CFLAGS:--Os -fomit-frame-pointer}"
    export CXXFLAGS="${CXXFLAGS:--Os -fomit-frame-pointer}"
}

compile_lshw() {
    pushd src
    make ${MAKEOPTS}
    popd
}

install_lshw() {
    pushd src
    make install
    popd
}

build_lshw() {
    pushd "${WORKDIR}/lshw-${LSHW_VERSION}"

    prepare_lshw
    compile_lshw
    install_lshw

    popd
}

registrar_lshw() {
    DOWNLOADERS+=(download_lshw)
    EXTRACTORS+=(extract_lshw)
}

registrar_lshw
