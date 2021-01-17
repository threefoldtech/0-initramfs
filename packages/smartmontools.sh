SMARTMON_PKGNAME="smartmontools"
SMARTMON_VERSION="7.0"
SMARTMON_CHECKSUM="b2a80e4789af23d67dfe1e88a997abbf"
SMARTMON_LINK="https://netcologne.dl.sourceforge.net/project/smartmontools/smartmontools/${SMARTMON_VERSION}/smartmontools-${SMARTMON_VERSION}.tar.gz"

download_smartmon() {
    download_file $SMARTMON_LINK $SMARTMON_CHECKSUM
}

extract_smartmon() {
    if [ ! -d "${SMARTMON_PKGNAME}-${SMARTMON_VERSION}" ]; then
        progress "extracting: ${SMARTMON_PKGNAME}-${SMARTMON_VERSION}"
        tar -xf ${DISTFILES}/${SMARTMON_PKGNAME}-${SMARTMON_VERSION}.tar.gz -C .
    fi
}

prepare_smartmon() {
    progress "preparing: ${SMARTMON_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_smartmon() {
    progress "compiling: ${SMARTMON_PKGNAME}"

    make ${MAKEOPTS}
}

install_smartmon() {
    progress "installing: ${SMARTMON_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_smartmon() {
    pushd "${WORKDIR}/${SMARTMON_PKGNAME}-${SMARTMON_VERSION}"

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
