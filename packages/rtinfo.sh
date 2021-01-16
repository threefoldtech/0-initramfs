RTINFO_VERSION="7be022c00d28f4a73da488fa1f7bf8e36f87ea7e"
RTINFO_CHECKSUM="eff05b3883ad9cdc3a34ee26d8bb7809"
RTINFO_LINK="https://github.com/maxux/rtinfo/archive/${RTINFO_VERSION}.tar.gz"

LIBRTINFO_VERSION="473fb821e6d474e9fc85043a3778b074e1d79adc"
LIBRTINFO_CHECKSUM="bd10525b42fe2311c1e1f2c4086dc0a6"
LIBRTINFO_LINK="https://github.com/maxux/librtinfo/archive/${LIBRTINFO_VERSION}.tar.gz"

download_rtinfo() {
    download_file $RTINFO_LINK $RTINFO_CHECKSUM rtinfo-${RTINFO_VERSION}.tar.gz
    download_file $LIBRTINFO_LINK $LIBRTINFO_CHECKSUM librtinfo-${LIBRTINFO_VERSION}.tar.gz
}

extract_rtinfo() {
    if [ ! -d "rtinfo-${RTINFO_VERSION}" ]; then
        echo "[+] extracting: rtinfo-${RTINFO_VERSION}"
        tar -xf ${DISTFILES}/rtinfo-${RTINFO_VERSION}.tar.gz -C .
    fi

    if [ ! -d "librtinfo-${LIBRTINFO_VERSION}" ]; then
        echo "[+] extracting: librtinfo-${LIBRTINFO_VERSION}"
        tar -xf ${DISTFILES}/librtinfo-${LIBRTINFO_VERSION}.tar.gz -C .
    fi
}

build_librtinfo() {
    echo "[+] building librtinfo"

    pushd linux
    make ${MAKEOPTS}
    make DESTDIR=${ROOTDIR} PREFIX=/usr/ install
}

prepare_rtinfo() {
    echo "[+] preparing rtinfo (client)"
}

compile_rtinfo() {
    echo "[+] compiling rtinfo (client)"
    make CC=$CC ${MAKEOPTS}
}

install_rtinfo() {
    echo "[+] installing rtinfo (client)"
    cp -a rtinfo-client "${ROOTDIR}"/usr/bin/
}

build_rtinfo() {
    pushd "${WORKDIR}/librtinfo-${LIBRTINFO_VERSION}"
    build_librtinfo
    popd

    pushd "${WORKDIR}/rtinfo-${RTINFO_VERSION}"
    pushd rtinfo-client

    prepare_rtinfo
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
