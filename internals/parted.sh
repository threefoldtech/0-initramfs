PARTED_VERSION="3.2"
PARTED_CHECKSUM="0247b6a7b314f8edeb618159fa95f9cb"
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
    echo "[+] configuring parted"
    ./configure --prefix "${ROOTDIR}"/usr --disable-device-mapper

    if [ ! -f .patched_parted-3.2-devmapper.patch ]; then
        echo "[+] applying patch"
        patch -p1 < ${PATCHESDIR}/parted-3.2-devmapper.patch
        touch .patched_parted-3.2-devmapper.patch
    fi
}

compile_parted() {
    make ${MAKEOPTS}
}

install_parted() {
    make install
}

build_parted() {
    pushd "${WORKDIR}/parted-${PARTED_VERSION}"

    prepare_parted
    compile_parted
    install_parted

    popd
}
