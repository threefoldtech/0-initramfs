PARTED_VERSION="3.6"
PARTED_CHECKSUM="93d2d8f22baebc5eb65b85da05a79e4e"
PARTED_LINK="http://ftp.gnu.org/gnu/parted/parted-${PARTED_VERSION}.tar.xz"

download_parted() {
    download_file $PARTED_LINK $PARTED_CHECKSUM
}

extract_parted() {
    if [ ! -d "parted-${PARTED_VERSION}" ]; then
        echo "[+] extracting: parted-${PARTED_VERSION}"
        tar -xf ${DISTFILES}/parted-${PARTED_VERSION}.tar.xz -C .
    fi
}

prepare_parted() {
    export LDFLAGS="-L${ROOTDIR}/usr/lib/"
    export CFLAGS="-I${ROOTDIR}/usr/include"

    echo "[+] configuring parted"
    ./configure --prefix "${ROOTDIR}"/usr --disable-device-mapper
}

compile_parted() {
    make ${MAKEOPTS}
}

install_parted() {
    make install

    unset LDFLAGS
    unset CFLAGS
}

build_parted() {
    pushd "${WORKDIR}/parted-${PARTED_VERSION}"

    prepare_parted
    compile_parted
    install_parted

    popd
}

registrar_parted() {
    DOWNLOADERS+=(download_parted)
    EXTRACTORS+=(extract_parted)
}

registrar_parted
