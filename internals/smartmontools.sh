SMARTMON_VERSION="6.5"
SMARTMON_CHECKSUM="093aeec3f8f39fa9a37593c4012d3156"
SMARTMON_LINK="https://netcologne.dl.sourceforge.net/project/smartmontools/smartmontools/6.5/smartmontools-${SMARTMON_VERSION}.tar.gz"

download_smartmon() {
    download_file $SMARTMON_LINK $SMARTMON_CHECKSUM
}

extract_smartmon() {
    if [ ! -d "smartmontools-${SMARTMON_VERSION}.tar.gz" ]; then
        echo "[+] extracting: smartmontools-${SMARTMON_VERSION}"
        tar -xf ${DISTFILES}/smartmontools-${SMARTMON_VERSION}.tar.gz -C .
    fi
}

prepare_smartmon() {
    echo "[+] preparing smartmontools"
    ./configure --prefix /usr
}

compile_smartmon() {
    echo "[+] compiling smartmontools"
    make ${MAKEOPTS}
}

install_smartmon() {
    echo "[+] installing smartmontools"
    make DESTDIR="${ROOTDIR}" install
}

build_smartmon() {
    pushd "${WORKDIR}/smartmontools-${SMARTMON_VERSION}"

    prepare_smartmon
    compile_smartmon
    install_smartmon

    popd
}

