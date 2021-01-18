CONFUSE_PKGNAME="confuse"
CONFUSE_VERSION="3.3"
CONFUSE_CHECKSUM="a183cef2cecdd3783436ff8de500d274"
CONFUSE_LINK="https://github.com/libconfuse/libconfuse/releases/download/v${CONFUSE_VERSION}/confuse-${CONFUSE_VERSION}.tar.xz"

download_confuse() {
    download_file $CONFUSE_LINK $CONFUSE_CHECKSUM
}

extract_confuse() {
    if [ ! -d "${CONFUSE_PKGNAME}-${CONFUSE_VERSION}" ]; then
        progress "extracting: ${CONFUSE_PKGNAME}-${CONFUSE_VERSION}"
        tar -xf ${DISTFILES}/${CONFUSE_PKGNAME}-${CONFUSE_VERSION}.tar.xz -C .
    fi
}

prepare_confuse() {
    progress "preparing: ${CONFUSE_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_confuse() {
    progress "compiling: ${CONFUSE_PKGNAME}"

    make ${MAKEOPTS}
}

install_confuse() {
    progress "installing: ${CONFUSE_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_confuse() {
    pushd "${WORKDIR}/${CONFUSE_PKGNAME}-${CONFUSE_VERSION}"

    prepare_confuse
    compile_confuse
    install_confuse

    popd
}

registrar_confuse() {
    DOWNLOADERS+=(download_confuse)
    EXTRACTORS+=(extract_confuse)
}

registrar_confuse
