LIBRTINFO_PKGNAME="librtinfo"
LIBRTINFO_VERSION="473fb821e6d474e9fc85043a3778b074e1d79adc"
LIBRTINFO_CHECKSUM="bd10525b42fe2311c1e1f2c4086dc0a6"
LIBRTINFO_LINK="https://github.com/maxux/librtinfo/archive/${LIBRTINFO_VERSION}.tar.gz"

download_librtinfo() {
    download_file $LIBRTINFO_LINK $LIBRTINFO_CHECKSUM ${LIBRTINFO_PKGNAME}-${LIBRTINFO_VERSION}.tar.gz
}

extract_librtinfo() {
    if [ ! -d "${LIBRTINFO_PKGNAME}-${LIBRTINFO_VERSION}" ]; then
        progress "extracting: ${LIBRTINFO_PKGNAME}-${LIBRTINFO_VERSION}"
        tar -xf ${DISTFILES}/${LIBRTINFO_PKGNAME}-${LIBRTINFO_VERSION}.tar.gz -C .
    fi
}

compile_librtinfo() {
    progress "compiling: ${LIBRTINFO_PKGNAME}"

    pushd linux
    make ${MAKEOPTS}
}

install_librtinfo() {
    progress "installing: ${LIBRTINFO_PKGNAME}"

    make DESTDIR=${ROOTDIR} PREFIX=/usr/ install
}

build_librtinfo() {
    pushd "${WORKDIR}/${LIBRTINFO_PKGNAME}-${LIBRTINFO_VERSION}"

    compile_librtinfo
    install_librtinfo

    popd
}

registrar_librtinfo() {
    DOWNLOADERS+=(download_librtinfo)
    EXTRACTORS+=(extract_librtinfo)
}

registrar_librtinfo
