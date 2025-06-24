LSHW_VERSION="B.02.20"
LSHW_CHECKSUM="5805eba5f31886582fff673c5dccdb3b"
LSHW_LINK="https://github.com/lyonel/lshw/archive/refs/tags/${LSHW_VERSION}.tar.gz"

download_lshw() {
    download_file $LSHW_LINK $LSHW_CHECKSUM lshw-${LSHW_VERSION}.tar.gz
}

extract_lshw() {
    if [ ! -d "lshw-${LSHW_VERSION}" ]; then
        echo "[+] extracting: lshw-${LSHW_VERSION}"
        tar -xf ${DISTFILES}/lshw-${LSHW_VERSION}.tar.gz -C . 
    fi
}

prepare_lshw() {
    echo "[+] configuring lshw"
}

compile_lshw() {
    pushd src
    make ${MAKEOPTS}
    popd
}

install_lshw() {
    echo "[+] installing lshw to initramfs"
    
    # Install the lshw binary
    install -D -m 755 src/lshw "${ROOTDIR}/usr/bin/lshw"
    
    # Install the ID files to the proper location
    mkdir -p "${ROOTDIR}/usr/share/lshw"
    install -p -m 0644 pci.ids "${ROOTDIR}/usr/share/lshw/"
    install -p -m 0644 usb.ids "${ROOTDIR}/usr/share/lshw/"
    install -p -m 0644 oui.txt "${ROOTDIR}/usr/share/lshw/"
    install -p -m 0644 manuf.txt "${ROOTDIR}/usr/share/lshw/"
    install -p -m 0644 pnp.ids "${ROOTDIR}/usr/share/lshw/"
    install -p -m 0644 pnpid.txt "${ROOTDIR}/usr/share/lshw/"
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
