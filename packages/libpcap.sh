LIBPCAP_PKGNAME="libpcap"
LIBPCAP_VERSION="1.9.0"
LIBPCAP_CHECKSUM="dffd65cb14406ab9841f421732eb0f33"
LIBPCAP_LINK="https://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz"

download_libpcap() {
    download_file $LIBPCAP_LINK $LIBPCAP_CHECKSUM
}

extract_libpcap() {
    if [ ! -d "${LIBPCAP_PKGNAME}-${LIBPCAP_VERSION}" ]; then
        progress "extracting: ${LIBPCAP_PKGNAME}-${LIBPCAP_VERSION}"
        tar -xf ${DISTFILES}/${LIBPCAP_PKGNAME}-${LIBPCAP_VERSION}.tar.gz -C .
    fi
}

prepare_libpcap() {
    progress "preparing: ${LIBPCAP_PKGNAME}"

    CFLAGS="$CFLAGS -I${ROOTDIR}/usr/include/libnl3" ./configure \
        --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --enable-ipv6 \
        --disable-remote \
        --disable-usb \
        --disable-netmap \
        --disable-bluetooth \
        --disable-dbus \
        --disable-rdma
}

compile_libpcap() {
    progress "compiling: ${LIBPCAP_PKGNAME}"

    make ${MAKEOPTS}
}

install_libpcap() {
    progress "installing: ${LIBPCAP_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
}

build_libpcap() {
    pushd "${WORKDIR}/${LIBPCAP_PKGNAME}-${LIBPCAP_VERSION}"

    prepare_libpcap
    compile_libpcap
    install_libpcap

    popd
}

registrar_libpcap() {
    DOWNLOADERS+=(download_libpcap)
    EXTRACTORS+=(extract_libpcap)
}

registrar_libpcap
