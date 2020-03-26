WIREGUARD_TOOLS_VERSION="1.0.20200102"
WIREGUARD_TOOLS_CHECKSUM="611eb05e295550f8267092bbf2731fd1"
WIREGUARD_TOOLS_LINK="https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-${WIREGUARD_TOOLS_VERSION}.tar.xz"
WIREGUARD_MODULES_VERSION="0.0.20200105"
WIREGUARD_MODULES_CHECKSUM="c2f2d5803623a71a086eab41c29d9b15"
WIREGUARD_MODULES_LINK="https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-${WIREGUARD_MODULES_VERSION}.tar.xz"

download_wireguard() {
    download_file $WIREGUARD_TOOLS_LINK $WIREGUARD_TOOLS_CHECKSUM
    download_file $WIREGUARD_MODULES_LINK $WIREGUARD_MODULES_CHECKSUM
}

extract_wireguard() {
    if [ ! -d "wireguard-tools-${WIREGUARD_TOOLS_VERSION}" ]; then
        echo "[+] extracting: wireguard-tools-${WIREGUARD_TOOLS_VERSION}"
        tar -xf ${DISTFILES}/wireguard-tools-${WIREGUARD_TOOLS_VERSION}.tar.xz -C .
    fi

    if [ ! -d "wireguard-linux-compat-${WIREGUARD_MODULES_VERSION}" ]; then
        echo "[+] extracting: wireguard-linux-compat-${WIREGUARD_MODULES_VERSION}"
        tar -xf ${DISTFILES}/wireguard-linux-compat-${WIREGUARD_MODULES_VERSION}.tar.xz -C .
    fi
}

prepare_wireguard_modules() {
    echo "[+] preparing wireguard (kernel module)"
    # link wireguard directory into kernel tree
    ./kernel-tree-scripts/jury-rig.sh ${WORKDIR}/linux-${KERNEL_VERSION}
}

compile_wireguard_tools() {
    echo "[+] compiling wireguard (tools)"
    make ${MAKEOPTS}
}

install_wireguard_tools() {
    echo "[+] installing wireguard (tools)"
    make DESTDIR=${ROOTDIR} install
}

build_wireguard() {
    pushd "${WORKDIR}/wireguard-linux-compat-${WIREGUARD_MODULES_VERSION}"
    prepare_wireguard_modules
    popd

    pushd "${WORKDIR}/wireguard-tools-${WIREGUARD_TOOLS_VERSION}/src"
    compile_wireguard_tools
    install_wireguard_tools
    popd
}

registrar_wireguard() {
    DOWNLOADERS+=(download_wireguard)
    EXTRACTORS+=(extract_wireguard)
}

registrar_wireguard
