XZ_PKGNAME="xz"
XZ_VERSION="5.2.5"
XZ_CHECKSUM="0d270c997aff29708c74d53f599ef717"
XZ_LINK="https://tukaani.org/xz/xz-${XZ_VERSION}.tar.gz"

download_xz() {
    download_file $XZ_LINK $XZ_CHECKSUM
}

extract_xz() {
    if [ ! -d "${XZ_PKGNAME}-${XZ_VERSION}" ]; then
        progress "extracting: ${XZ_PKGNAME}-${XZ_VERSION}"
        tar -xf ${DISTFILES}/${XZ_PKGNAME}-${XZ_VERSION}.tar.gz -C .
    fi
}

prepare_xz() {
    progress "preparing: ${XZ_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_xz() {
    progress "compiling: ${XZ_PKGNAME}"

    make ${MAKEOPTS}
}

install_xz() {
    progress "installing: ${XZ_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_xz() {
    pushd "${WORKDIR}/${XZ_PKGNAME}-${XZ_VERSION}"

    prepare_xz
    compile_xz
    install_xz

    popd
}

registrar_xz() {
    DOWNLOADERS+=(download_xz)
    EXTRACTORS+=(extract_xz)
}

registrar_xz
