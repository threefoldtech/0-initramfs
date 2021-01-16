RTINFO_PKGNAME="rtinfo"
RTINFO_VERSION="7be022c00d28f4a73da488fa1f7bf8e36f87ea7e"
RTINFO_CHECKSUM="eff05b3883ad9cdc3a34ee26d8bb7809"
RTINFO_LINK="https://github.com/maxux/rtinfo/archive/${RTINFO_VERSION}.tar.gz"

download_rtinfo() {
    download_file $RTINFO_LINK $RTINFO_CHECKSUM ${RTINFO_PKGNAME}-${RTINFO_VERSION}.tar.gz
}

extract_rtinfo() {
    if [ ! -d "${RTINFO_PKGNAME}-${RTINFO_VERSION}" ]; then
        progress "extracting: ${RTINFO_PKGNAME}-${RTINFO_VERSION}"
        tar -xf ${DISTFILES}/${RTINFO_PKGNAME}-${RTINFO_VERSION}.tar.gz -C .
    fi
}

compile_rtinfo() {
    progress "compiling: ${RTINFO_PKGNAME}"

    make CC=$CC ${MAKEOPTS}
}

install_rtinfo() {
    progress "installing: ${RTINFO_PKGNAME}"

    cp -a rtinfo-client "${ROOTDIR}"/usr/bin/
}

build_rtinfo() {
    pushd "${WORKDIR}/${RTINFO_PKGNAME}-${RTINFO_VERSION}"
    pushd rtinfo-client

    compile_rtinfo
    install_rtinfo

    popd
    popd
}

registrar_rtinfo() {
    DOWNLOADERS+=(download_rtinfo)
    EXTRACTORS+=(extract_rtinfo)
}

registrar_rtinfo
