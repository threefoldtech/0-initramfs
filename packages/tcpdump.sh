TCPDUMP_VERSION="4.9.2"
TCPDUMP_CHECKSUM="9bbc1ee33dab61302411b02dd0515576"
TCPDUMP_LINK="https://www.tcpdump.org/release/tcpdump-${TCPDUMP_VERSION}.tar.gz"

LIBPCAP_VERSION="1.9.0"
LIBPCAP_CHECKSUM="dffd65cb14406ab9841f421732eb0f33"
LIBPCAP_LINK="https://www.tcpdump.org/release/libpcap-${LIBPCAP_VERSION}.tar.gz"


download_tcpdump() {
    download_file $TCPDUMP_LINK $TCPDUMP_CHECKSUM
    download_file $LIBPCAP_LINK $LIBPCAP_CHECKSUM
}

extract_tcpdump() {
    if [ ! -d "tcpdump-${TCPDUMP_VERSION}" ]; then
        echo "[+] extracting: tcpdump-${TCPDUMP_VERSION}"
        tar -xf ${DISTFILES}/tcpdump-${TCPDUMP_VERSION}.tar.gz -C .
    fi

    if [ ! -d "libpcap-${LIBPCAP_VERSION}" ]; then
        echo "[+] extracting: libpcap-${LIBPCAP_VERSION}"
        tar -xf ${DISTFILES}/libpcap-${LIBPCAP_VERSION}.tar.gz -C .
    fi

}

build_libpcap() {
    echo "[+] preparing libcap"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --enable-ipv6 \
        --disable-remote \
        --disable-usb \
        --disable-netmap \
        --disable-bluetooth \
        --disable-dbus \
        --disable-rdma

    make ${MAKEOPTS}

    # no need to install, tcpdump will automatically find
    # this libpcap on parent directory and static link against it
    # make DESTDIR=${ROOTDIR} install-shared
}

prepare_tcpdump() {
    echo "[+] preparing tcpdump"
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-smb \
        --without-smi
}

compile_tcpdump() {
    echo "[+] compiling tcpdump"
    make ${MAKEOPTS}
}

install_tcpdump() {
    echo "[+] installing tcpdump"
    make DESTDIR=${ROOTDIR} install

    # remove duplicated binary
    rm -f ${ROOTDIR}/usr/sbin/tcpdump.${TCPDUMP_VERSION}
}

build_tcpdump() {
    pushd "${WORKDIR}/libpcap-${LIBPCAP_VERSION}"

    build_libpcap

    popd

    pushd "${WORKDIR}/tcpdump-${TCPDUMP_VERSION}"

    prepare_tcpdump
    compile_tcpdump
    install_tcpdump

    popd
}

registrar_tcpdump() {
    DOWNLOADERS+=(download_tcpdump)
    EXTRACTORS+=(extract_tcpdump)
}

registrar_tcpdump
