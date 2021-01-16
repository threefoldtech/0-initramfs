SMARTMON_VERSION="7.0"
SMARTMON_CHECKSUM="b2a80e4789af23d67dfe1e88a997abbf"
SMARTMON_LINK="https://netcologne.dl.sourceforge.net/project/smartmontools/smartmontools/${SMARTMON_VERSION}/smartmontools-${SMARTMON_VERSION}.tar.gz"

download_smartmon() {
    download_file $SMARTMON_LINK $SMARTMON_CHECKSUM
}

extract_smartmon() {
    if [ ! -d "smartmontools-${SMARTMON_VERSION}" ]; then
        echo "[+] extracting: smartmontools-${SMARTMON_VERSION}"
        tar -xf ${DISTFILES}/smartmontools-${SMARTMON_VERSION}.tar.gz -C .
    fi
}

prepare_smartmon() {
    echo "[+] preparing smartmontools"
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
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

registrar_smartmon() {
    DOWNLOADERS+=(download_smartmon)
    EXTRACTORS+=(extract_smartmon)
}

registrar_smartmon
