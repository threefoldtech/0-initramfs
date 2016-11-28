DNSMASQ_VERSION="2.76"
DNSMASQ_CHECKSUM="00f5ee66b4e4b7f14538bf62ae3c9461"
DNSMASQ_LINK="http://www.thekelleys.org.uk/dnsmasq/dnsmasq-${DNSMASQ_VERSION}.tar.xz"

download_dnsmasq() {
    download_file $DNSMASQ_LINK $DNSMASQ_CHECKSUM
}

extract_dnsmasq() {
    if [ ! -d "dnsmasq-${DNSMASQ_VERSION}" ]; then
        echo "[+] extracting: dnsmasq-${DNSMASQ_VERSION}"
        tar -xf ${DISTFILES}/dnsmasq-${DNSMASQ_VERSION}.tar.xz -C .
    fi
}

prepare_dnsmasq() {
    echo "[+] configuring dnsmasq"
}

compile_dnsmasq() {
    make ${MAKEOPTS}
}

install_dnsmasq() {
    cp -avL src/dnsmasq "${ROOTDIR}/usr/bin/"
}

build_dnsmasq() {
    pushd "${WORKDIR}/dnsmasq-${DNSMASQ_VERSION}"

    prepare_dnsmasq
    compile_dnsmasq
    install_dnsmasq

    popd
}
