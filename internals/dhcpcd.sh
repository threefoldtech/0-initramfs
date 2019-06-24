DHCPCD_VERSION="7.2.2"
DHCPCD_CHECKSUM="2f17034432ea10415ee84a97ef131128"
DHCPCD_LINK="https://roy.marples.name/downloads/dhcpcd/dhcpcd-${DHCPCD_VERSION}.tar.xz"

download_dhcpcd() {
    download_file $DHCPCD_LINK $DHCPCD_CHECKSUM
}

extract_dhcpcd() {
    if [ ! -d "dhcpcd-${DHCPCD_VERSION}" ]; then
        echo "[+] extracting: dhcpcd-${DHCPCD_VERSION}"
        tar -xf ${DISTFILES}/dhcpcd-${DHCPCD_VERSION}.tar.xz -C .
    fi
}

prepare_dhcpcd() {
    echo "[+] configuring dhcpcd"
    ./configure --prefix=/usr --sysconfdir=/etc
}

compile_dhcpcd() {
    make ${MAKEOPTS}
}

install_dhcpcd() {
    make DESTDIR=${ROOTDIR} install
}

build_dhcpcd() {
    pushd "${WORKDIR}/dhcpcd-${DHCPCD_VERSION}"

    prepare_dhcpcd
    compile_dhcpcd
    install_dhcpcd

    popd
}

registrar_dhcpcd() {
    DOWNLOADERS+=(download_dhcpcd)
    EXTRACTORS+=(extract_dhcpcd)
}

registrar_dhcpcd
