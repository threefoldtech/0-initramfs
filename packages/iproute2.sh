IPROUTE2_PKGNAME="iproute2"
IPROUTE2_VERSION="5.4.0"
IPROUTE2_CHECKSUM="54d86cadb4cd1d19fd7114b4e53adf51"
IPROUTE2_LINK="https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-${IPROUTE2_VERSION}.tar.xz"

download_iproute2() {
    download_file $IPROUTE2_LINK $IPROUTE2_CHECKSUM
}

extract_iproute2() {
    if [ ! -d "${IPROUTE2_PKGNAME}-${IPROUTE2_VERSION}" ]; then
        progress "extracting: ${IPROUTE2_PKGNAME}-${IPROUTE2_VERSION}"
        tar -xf ${DISTFILES}/${IPROUTE2_PKGNAME}-${IPROUTE2_VERSION}.tar.xz -C .
    fi
}

prepare_iproute2() {
    progress "preparing: ${IPROUTE2_PKGNAME}"

    ./configure

    # disable selinux, not needed
    sed -i /SELINUX/d config.mk
    sed -i /selinux/d config.mk
}

compile_iproute2() {
    progress "compiling: ${IPROUTE2_PKGNAME}"

    make ${MAKEOPTS}
}

install_iproute2() {
    progress "installing: ${IPROUTE2_PKGNAME}"

    # replace busybox symlink with the real binary
    rm -f "${ROOTDIR}"/sbin/ip
    mkdir -p "${ROOTDIR}"/var/run/netns

    make DESTDIR=${ROOTDIR} install
}

build_iproute2() {
    pushd "${WORKDIR}/${IPROUTE2_PKGNAME}-${IPROUTE2_VERSION}"

    prepare_iproute2
    compile_iproute2
    install_iproute2

    popd
}

registrar_iproute2() {
    DOWNLOADERS+=(download_iproute2)
    EXTRACTORS+=(extract_iproute2)
}

registrar_iproute2
