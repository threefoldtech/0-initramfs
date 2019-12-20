IPROUTE2_VERSION="5.1.0"
IPROUTE2_CHECKSUM="a2b8349abf4ae00e92155fda22de4d5e"
IPROUTE2_LINK="https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-${IPROUTE2_VERSION}.tar.xz"

download_iproute2() {
    download_file $IPROUTE2_LINK $IPROUTE2_CHECKSUM
}

extract_iproute2() {
    if [ ! -d "iproute2-${IPROUTE2_VERSION}" ]; then
        echo "[+] extracting: iproute2-${IPROUTE2_VERSION}"
        tar -xf ${DISTFILES}/iproute2-${IPROUTE2_VERSION}.tar.xz -C .
    fi
}

prepare_iproute2() {
    echo "[+] preparing iproute2"
    ./configure

    # disable selinux, not needed
    sed -i /SELINUX/d config.mk
    sed -i /selinux/d config.mk
}

compile_iproute2() {
    echo "[+] compiling iproute2"
    make ${MAKEOPTS}
}

install_iproute2() {
    echo "[+] installing iproute2"

    # replace busybox symlink with the real binary
    rm -f "${ROOTDIR}"/sbin/ip
    mkdir -p "${ROOTDIR}"/var/run/netns

    make DESTDIR=${ROOTDIR} install
}

build_iproute2() {
    pushd "${WORKDIR}/iproute2-${IPROUTE2_VERSION}"

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
