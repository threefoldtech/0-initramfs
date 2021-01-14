KMOD_VERSION="26"
KMOD_CHECKSUM="1129c243199bdd7db01b55a61aa19601"
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

    export LDFLAGS="-L${ROOTDIR}/lib"

    ./configure --prefix=/ \
        --with-sysroot=${ROOTDIR}/lib \
        --build ${BUILDCOMPILE} \
        --host ${BUILDHOST} \
        --with-xz \
        --with-zlib

    unset LDFLAGS
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

registrar_kmod() {
    DOWNLOADERS+=(download_kmod)
    EXTRACTORS+=(extract_kmod)
}

registrar_kmod
