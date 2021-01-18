KMOD_PKGNAME="kmod"
KMOD_VERSION="26"
KMOD_CHECKSUM="1129c243199bdd7db01b55a61aa19601"
KMOD_LINK="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-${KMOD_VERSION}.tar.xz"

download_kmod() {
    download_file $KMOD_LINK $KMOD_CHECKSUM
}

extract_kmod() {
    if [ ! -d "${KMOD_PKGNAME}-${KMOD_VERSION}" ]; then
        progress "extracting: ${KMOD_PKGNAME}-${KMOD_VERSION}"
        tar -xf ${DISTFILES}/${KMOD_PKGNAME}-${KMOD_VERSION}.tar.xz -C .
    fi
}

prepare_kmod() {
    progress "preparing: ${KMOD_PKGNAME}"

    ./configure --prefix=/usr \
        --with-sysroot=${ROOTDIR}/lib \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --with-xz \
        --with-zlib
}

compile_kmod() {
    progress "compiling: ${KMOD_PKGNAME}"

    make ${MAKEOPTS}
}

install_kmod() {
    progress "installing: ${KMOD_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install

    pushd "${ROOTDIR}"
    for target in depmod insmod lsmod modinfo modprobe rmmod; do
        rm -f sbin/$target
        ln -sfv ../usr/bin/kmod sbin/$target
    done
    popd
}

build_kmod() {
    pushd "${WORKDIR}/${KMOD_PKGNAME}-${KMOD_VERSION}"

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
