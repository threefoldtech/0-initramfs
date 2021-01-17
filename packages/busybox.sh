BUSYBOX_PKGNAME="busybox"
BUSYBOX_VERSION="1.32.1"
BUSYBOX_CHECKSUM="6273c550ab6a32e8ff545e00e831efc5"
BUSYBOX_LINK="https://www.busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"

download_busybox() {
    download_file $BUSYBOX_LINK $BUSYBOX_CHECKSUM
}

extract_busybox() {
    if [ ! -d "${BUSYBOX_PKGNAME}-${BUSYBOX_VERSION}" ]; then
        progress "extracting: ${BUSYBOX_PKGNAME}-${BUSYBOX_VERSION}"
        tar -xf ${DISTFILES}/${BUSYBOX_PKGNAME}-${BUSYBOX_VERSION}.tar.bz2 -C .
    fi
}

prepare_busybox() {
    progress "preparing: ${BUSYBOX_PKGNAME} configuration"

    cp "${CONFDIR}/build/busybox-config" .config
}

compile_busybox() {
    progress "compiling: ${BUSYBOX_PKGNAME}"

    make ARCH=${BUILDARCH} CROSS_COMPILE=${BUILDHOST}- ${MAKEOPTS}
}

install_busybox() {
    progress "installing: ${BUSYBOX_PKGNAME}"

    # make install
    make ARCH=${BUILDARCH} CROSS_COMPILE=${BUILDHOST}- install
    cp -av _install/* "${ROOTDIR}/"
}

build_busybox() {
    pushd "${WORKDIR}/${BUSYBOX_PKGNAME}-${BUSYBOX_VERSION}"

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
