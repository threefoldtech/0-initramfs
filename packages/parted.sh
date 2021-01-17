PARTED_PKGNAME="parted"
PARTED_VERSION="3.3"
PARTED_CHECKSUM="090655d05f3c471aa8e15a27536889ec"
PARTED_LINK="http://ftp.gnu.org/gnu/parted/parted-${PARTED_VERSION}.tar.xz"

download_parted() {
    download_file $PARTED_LINK $PARTED_CHECKSUM
}

extract_parted() {
    if [ ! -d "${PARTED_PKGNAME}-${PARTED_VERSION}" ]; then
        progress "extracting: ${PARTED_PKGNAME}-${PARTED_VERSION}"
        tar -xf ${DISTFILES}/${PARTED_PKGNAME}-${PARTED_VERSION}.tar.xz -C .
    fi
}

prepare_parted() {
    progress "configuring: ${PARTED_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-device-mapper
}

compile_parted() {
    progress "compiling: ${PARTED_PKGNAME}"

    make LDFLAGS="-L${ROOTDIR}/lib -lblkid -luuid" ${MAKEOPTS}
}

install_parted() {
    progress "installing: ${PARTED_PKGNAME}"

    make DESTDIR=${ROOTDIR} install
}

build_parted() {
    pushd "${WORKDIR}/${PARTED_PKGNAME}-${PARTED_VERSION}"

    prepare_parted
    compile_parted
    install_parted

    popd
}

registrar_parted() {
    DOWNLOADERS+=(download_parted)
    EXTRACTORS+=(extract_parted)
}

registrar_parted
