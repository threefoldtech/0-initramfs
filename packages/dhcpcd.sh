DHCPCD_PKGNAME="dhcpcd"
DHCPCD_VERSION="7.2.2"
DHCPCD_CHECKSUM="2f17034432ea10415ee84a97ef131128"
DHCPCD_LINK="https://roy.marples.name/downloads/dhcpcd/dhcpcd-${DHCPCD_VERSION}.tar.xz"

download_dhcpcd() {
    download_file $DHCPCD_LINK $DHCPCD_CHECKSUM
}

extract_dhcpcd() {
    if [ ! -d "${DHCPCD_PKGNAME}-${DHCPCD_VERSION}" ]; then
        progress "extracting: ${DHCPCD_PKGNAME}-${DHCPCD_VERSION}"
        tar -xf ${DISTFILES}/${DHCPCD_PKGNAME}-${DHCPCD_VERSION}.tar.xz -C .
    fi
}

prepare_dhcpcd() {
    progress "configuring: ${DHCPCD_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --sysconfdir=/etc
}

compile_dhcpcd() {
    progress "compiling: ${DHCPCD_PKGNAME}"

    make ${MAKEOPTS}
}

install_dhcpcd() {
    progress "installing: ${DHCPCD_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
}

build_dhcpcd() {
    pushd "${WORKDIR}/${DHCPCD_PKGNAME}-${DHCPCD_VERSION}"

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
