ZEROTIER_VERSION="1.1.14"
ZEROTIER_CHECKSUM="5e381f0864797886b3b3bf20beb49bba"
ZEROTIER_LINK="https://github.com/zerotier/ZeroTierOne/archive/${ZEROTIER_VERSION}.tar.gz"

download_zerotier() {
    download_file $ZEROTIER_LINK $ZEROTIER_CHECKSUM
}

extract_zerotier() {
    if [ ! -d "ZeroTierOne-${ZEROTIER_VERSION}" ]; then
        echo "[+] extracting: ZeroTierOne-${ZEROTIER_VERSION}"
        tar -xf ${DISTFILES}/${ZEROTIER_VERSION}.tar.gz -C .
    fi
}

prepare_zerotier() {
    echo "[+] configuring zerotier"
}

compile_zerotier() {
    make one ${MAKEOPTS}
}

install_zerotier() {
    cp -av zerotier-cli zerotier-idtool zerotier-one "${ROOTDIR}/usr/bin/"
}

build_zerotier() {
    pushd "${WORKDIR}/ZeroTierOne-${ZEROTIER_VERSION}"

    prepare_zerotier
    compile_zerotier
    install_zerotier

    popd
}
