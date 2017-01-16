QEMU_VERSION="2.8.0"
QEMU_CHECKSUM="17940dce063b6ce450a12e719a6c9c43"
QEMU_LINK="http://wiki.qemu-project.org/download/qemu-${QEMU_VERSION}.tar.bz2"

download_qemu() {
    download_file $QEMU_LINK $QEMU_CHECKSUM
}

extract_qemu() {
    if [ ! -d "qemu-${QEMU_VERSION}" ]; then
        echo "[+] extracting: qemu-${QEMU_VERSION}"
        tar -xf ${DISTFILES}/qemu-${QEMU_VERSION}.tar.bz2 -C .
    fi
}

prepare_qemu() {
    echo "[+] preparing qemu"
    ./configure --prefix="${ROOTDIR}"/usr \
        --target-list="x86_64-softmmu" \
        --enable-kvm \
        --python=/usr/bin/python2 \
        --disable-gtk \
        --disable-sdl
}

compile_qemu() {
    echo "[+] compiling qemu"
    make ${MAKEOPTS}
}

install_qemu() {
    echo "[+] installing qemu"
    make install

    # Cleaning some ROMs not used
    rm -f "${ROOTDIR}"/usr/share/qemu/openbios-*
    rm -f "${ROOTDIR}"/usr/share/qemu/ppc_*
}

build_qemu() {
    pushd "${WORKDIR}/qemu-${QEMU_VERSION}"

    prepare_qemu
    compile_qemu
    install_qemu

    popd
}

