NETCAT_VERSION="1.0"
NETCAT_CHECKSUM="5074bc51989420a1f68716f93322030f"
NETCAT_LINK="http://gentoo.mirrors.ovh.net/gentoo-distfiles/distfiles/nc6-${NETCAT_VERSION}.tar.bz2"

download_netcat() {
    download_file $NETCAT_LINK $NETCAT_CHECKSUM
}

extract_netcat() {
    if [ ! -d "nc6-${NETCAT_VERSION}" ]; then
        echo "[+] extracting: netcat6-${NETCAT_VERSION}"
        tar -xf ${DISTFILES}/nc6-${NETCAT_VERSION}.tar.bz2 -C .
    fi
}

prepare_netcat() {
    echo "[+] configuring netcat"
    ./configure --disable-bluez
}

compile_netcat() {
    make ${MAKEOPTS}
}

install_netcat() {
    cp -avL src/nc6 "${ROOTDIR}/usr/bin/"

    pushd "${ROOTDIR}/usr/bin/"
    ln -fs nc6 nc
    popd
}

build_netcat() {
    pushd "${WORKDIR}/nc6-${NETCAT_VERSION}"

    prepare_netcat
    compile_netcat
    install_netcat

    popd
}
