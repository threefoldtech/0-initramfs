TCPDUMP_PKGNAME="tcpdump"
TCPDUMP_VERSION="4.9.2"
TCPDUMP_CHECKSUM="9bbc1ee33dab61302411b02dd0515576"
TCPDUMP_LINK="https://www.tcpdump.org/release/tcpdump-${TCPDUMP_VERSION}.tar.gz"

download_tcpdump() {
    download_file $TCPDUMP_LINK $TCPDUMP_CHECKSUM
}

extract_tcpdump() {
    if [ ! -d "${TCPDUMP_PKGNAME}-${TCPDUMP_VERSION}" ]; then
        progress "extracting: ${TCPDUMP_PKGNAME}-${TCPDUMP_VERSION}"
        tar -xf ${DISTFILES}/${TCPDUMP_PKGNAME}-${TCPDUMP_VERSION}.tar.gz -C .
    fi
}

prepare_tcpdump() {
    progress "preparing: ${TCPDUMP_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-smb \
        --with-system-libpcap \
        --without-smi
}

compile_tcpdump() {
    progress "compiling: ${TCPDUMP_PKGNAME}"

    make ${MAKEOPTS}
}

install_tcpdump() {
    progress "installing: ${TCPDUMP_PKGNAME}"

    make DESTDIR=${ROOTDIR} install

    # remove duplicated binary
    rm -f ${ROOTDIR}/usr/sbin/tcpdump.${TCPDUMP_VERSION}
}

build_tcpdump() {
    pushd "${WORKDIR}/${TCPDUMP_PKGNAME}-${TCPDUMP_VERSION}"

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
