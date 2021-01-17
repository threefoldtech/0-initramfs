DNSMASQ_PKGNAME="dnsmasq"
DNSMASQ_VERSION="2.80"
DNSMASQ_CHECKSUM="e040e72e6f377a784493c36f9e788502"
DNSMASQ_LINK="http://www.thekelleys.org.uk/dnsmasq/dnsmasq-${DNSMASQ_VERSION}.tar.xz"

download_dnsmasq() {
    download_file $DNSMASQ_LINK $DNSMASQ_CHECKSUM
}

extract_dnsmasq() {
    if [ ! -d "${DNSMASQ_PKGNAME}-${DNSMASQ_VERSION}" ]; then
        progress "extracting: ${DNSMASQ_PKGNAME}-${DNSMASQ_VERSION}"
        tar -xf ${DISTFILES}/${DNSMASQ_PKGNAME}-${DNSMASQ_VERSION}.tar.xz -C .
    fi
}

compile_dnsmasq() {
    progress "compiling: ${DNSMASQ_PKGNAME}"

    make ${MAKEOPTS}
}

install_dnsmasq() {
    progress "installing: ${DNSMASQ_PKGNAME}"

    cp -avL src/dnsmasq "${ROOTDIR}/usr/bin/"
    mkdir -p "${ROOTDIR}"/var/run/dnsmasq
    mkdir -p "${ROOTDIR}"/var/lib/misc

    # symlink dnsmasq to sbin to ensure hardcoded location
    pushd "${ROOTDIR}/usr/sbin/"
    ln -vfs ../bin/dnsmasq dnsmasq
    popd
}

build_dnsmasq() {
    pushd "${WORKDIR}/${DNSMASQ_PKGNAME}-${DNSMASQ_VERSION}"

    compile_dnsmasq
    install_dnsmasq

    popd
}

registrar_dnsmasq() {
    DOWNLOADERS+=(download_dnsmasq)
    EXTRACTORS+=(extract_dnsmasq)
}

registrar_dnsmasq
