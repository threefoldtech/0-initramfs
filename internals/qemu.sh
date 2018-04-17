QEMU_REPOSITORY="https://github.com/maxux/qemu"
QEMU_BRANCH="zerodb"

download_qemu() {
    download_git $QEMU_REPOSITORY $QEMU_BRANCH
}

extract_qemu() {
    echo "[+] refreshing: qemu-${QEMU_BRANCH}"
    rm -rf ./qemu-${QEMU_BRANCH}
    cp -a ${DISTFILES}/qemu ./qemu-${QEMU_BRANCH}
}

prepare_qemu() {
    echo "[+] disable debug zerodb"
    sed -i '/#define DEBUG/d' block/zerodb.c

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
    pushd "${WORKDIR}/qemu-${QEMU_BRANCH}"

    prepare_qemu
    compile_qemu
    install_qemu

    popd
}

registrar_qemu() {
    DOWNLOADERS+=(download_qemu)
    EXTRACTORS+=(extract_qemu)
}

registrar_qemu
