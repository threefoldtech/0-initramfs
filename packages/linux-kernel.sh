KERNEL_VERSION="6.1.32"
KERNEL_CHECKSUM="5d5f7795d6a86dbd7150c295309d5a1a"
KERNEL_LINK="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz"

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
    cp "${CONFDIR}/build/kernel-config-generic" .config

    # Restore original file (in case of a patch was made)
    # This behavior is useful when mixing release/debug build
    if [ -f arch/x86/mm/init_64.c.orig ]; then
        echo "[+] cleaning previous patch"
        mv arch/x86/mm/init_64.c.orig arch/x86/mm/init_64.c
        rm -f .patched_linux-4.9-secureboot-restriction.patch
    fi

    # Nothing more to do in debug mode
    if [ "${BUILDMODE}" = "debug" ]; then
        return
    fi

    if [ ! -f .patched_linux-4.9-secureboot-restriction.patch ]; then
        echo "[+] applying (release) boot-restriction patch"
        patch -b -p0 < ${PATCHESDIR}/linux-4.9-secureboot-restriction.patch
        touch .patched_linux-4.9-secureboot-restriction.patch
    fi
}

compile_kernel() {
    # fix linux-5.4.5 make modules_install issue
    touch modules.builtin.modinfo

    if [[ $DO_ALL == 1 ]] || [[ $DO_KMODULES == 1 ]]; then
        echo "[+] compiling the kernel (modules)"
        make ${MAKEOPTS} modules
        make INSTALL_MOD_PATH="${ROOTDIR}" modules_install
        depmod -a -b "${ROOTDIR}" "${KERNEL_VERSION}-Zero-OS"
    fi

    if [[ $DO_ALL == 1 ]] || [[ $DO_KERNEL == 1 ]]; then
        echo "[+] compiling the kernel (vmlinuz)"
        make ${MAKEOPTS}
    fi
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

registrar_kernel() {
    DOWNLOADERS+=(download_kernel)
    EXTRACTORS+=(extract_kernel)
}

registrar_kernel
