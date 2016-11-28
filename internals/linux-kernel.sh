KERNEL_VERSION="4.7.2"
KERNEL_CHECKSUM="ae493473d074185205a54bc8ad49c3b4"
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
    cp "${CONFDIR}/kernel-config" .config

    # FIXME: add patch for secureboot
}

compile_kernel() {
    echo "[+] compiling the kernel"
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
