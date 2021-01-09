BUSYBOX_VERSION="1.32.1"
BUSYBOX_CHECKSUM="6273c550ab6a32e8ff545e00e831efc5"
BUSYBOX_LINK="https://www.busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"

download_busybox() {
    download_file $BUSYBOX_LINK $BUSYBOX_CHECKSUM
}

extract_busybox() {
    if [ ! -d "busybox-${BUSYBOX_VERSION}" ]; then
        echo "[+] extracting: busybox-${BUSYBOX_VERSION}"
        tar -xf ${DISTFILES}/busybox-${BUSYBOX_VERSION}.tar.bz2 -C .
    fi
}

prepare_busybox() {
    echo "[+] copying busybox configuration"
    cp "${CONFDIR}/build/busybox-config" .config
}

compile_busybox() {
    echo "[+] compiling busybox"

    make ARCH=${BUILDARCHKW} CROSS_COMPILE=${BUILDHOST}-
    # make ${MAKEOPTS}
}

install_busybox() {
    # make install
    make ARCH=${BUILDARCHKW} CROSS_COMPILE=${BUILDHOST}- install
    cp -av _install/* "${ROOTDIR}/"
}

build_busybox() {
    pushd "${WORKDIR}/busybox-${BUSYBOX_VERSION}"

    prepare_busybox
    compile_busybox
    install_busybox

    popd
}

registrar_busybox() {
    DOWNLOADERS+=(download_busybox)
    EXTRACTORS+=(extract_busybox)
}

registrar_busybox
