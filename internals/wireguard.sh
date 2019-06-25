WIREGUARD_VERSION="0.0.20190601"
WIREGUARD_CHECKSUM="eeeabbbd5592987b5308d1cc495f756f"
WIREGUARD_LINK="https://git.zx2c4.com/WireGuard/snapshot/WireGuard-${WIREGUARD_VERSION}.tar.xz"

download_wireguard() {
    download_file $WIREGUARD_LINK $WIREGUARD_CHECKSUM
}

extract_wireguard() {
    if [ ! -d "WireGuard-${WIREGUARD_VERSION}" ]; then
        echo "[+] extracting: WireGuard-${WIREGUARD_VERSION}"
        tar -xf ${DISTFILES}/WireGuard-${WIREGUARD_VERSION}.tar.xz -C .
    fi
}

prepare_wireguard() {
    echo "[+] preparing wireguard"
    # link wireguard directory into kernel tree
    ./contrib/kernel-tree/jury-rig.sh ${WORKDIR}/linux-${KERNEL_VERSION}
}

compile_wireguard() {
    echo "[+] compiling wireguard (tools)"
    pushd src/tools
    make ${MAKEOPTS}
    popd
}

install_wireguard() {
    echo "[+] installing wireguard (tools)"
    pushd src/tools
    make DESTDIR=${ROOTDIR} install
    popd
}

build_wireguard() {
    pushd "${WORKDIR}/WireGuard-${WIREGUARD_VERSION}"

    prepare_wireguard
    compile_wireguard
    install_wireguard

    popd
}

registrar_wireguard() {
    DOWNLOADERS+=(download_wireguard)
    EXTRACTORS+=(extract_wireguard)
}

registrar_wireguard
