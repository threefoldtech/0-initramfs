KERNEL_VERSION="4.9.11"
KERNEL_CHECKSUM="98761ce71c603199fe6fcce600c60772"
KERNEL_LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VERSION}.tar.xz"

download_kernel() {
    download_file $KERNEL_LINK $KERNEL_CHECKSUM
}

extract_kernel() {
    if [ ! -d "linux-${KERNEL_VERSION}" ]; then
        echo "[+] extracting: linux-${KERNEL_VERSION}"
        tar -xf ${DISTFILES}/linux-${KERNEL_VERSION}.tar.xz -C .
    fi
}

prepare_kernel() {
    echo "[+] copying kernel configuration"
    cp "${CONFDIR}/kernel-config-generic" .config

    # FIXME: add patch for secureboot
}

compile_kernel() {
    echo "[+] compiling the kernel (modules)"
    make ${MAKEOPTS} modules
    make INSTALL_MOD_PATH="${ROOTDIR}" modules_install

    echo "[+] compiling the kernel (vmlinuz)"
    make ${MAKEOPTS}
}

install_kernel() {
    cp arch/x86/boot/bzImage "${WORKDIR}"/vmlinuz.efi
    echo "[+] kernel installed: ${WORKDIR}/vmlinuz.efi"
}

build_kernel() {
    pushd "${WORKDIR}/linux-${KERNEL_VERSION}"

    prepare_kernel
    compile_kernel
    install_kernel

    popd
}
