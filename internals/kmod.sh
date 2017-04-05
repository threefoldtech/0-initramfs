KMOD_VERSION="24"
KMOD_CHECKSUM="08297dfb6f2b3f625f928ca3278528af"
KMOD_LINK="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-${KMOD_VERSION}.tar.xz"

download_kmod() {
    download_file $KMOD_LINK $KMOD_CHECKSUM
}

extract_kmod() {
    if [ ! -d "kmod-${KMOD_VERSION}" ]; then
        echo "[+] extracting: kmod-${KMOD_VERSION}"
        tar -xf ${DISTFILES}/kmod-${KMOD_VERSION}.tar.xz -C .
    fi
}

prepare_kmod() {
    echo "[+] preparing kmod"
    ./configure --prefix=/ --with-xz --with-zlib
}

compile_kmod() {
    echo "[+] compiling kmod"
    make ${MAKEOPTS}
}

install_kmod() {
    echo "[+] installing kmod"
    make DESTDIR="${ROOTDIR}" install

    pushd "${ROOTDIR}"
    for target in depmod insmod lsmod modinfo modprobe rmmod; do
        rm -f sbin/$target
        ln -sfv /bin/kmod sbin/$target
    done
    popd
}

build_kmod() {
    pushd "${WORKDIR}/kmod-${KMOD_VERSION}"

    prepare_kmod
    compile_kmod
    install_kmod

    popd
}
