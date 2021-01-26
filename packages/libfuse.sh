FUSE_PKGNAME="libfuse-fuse"
FUSE_VERSION="2.9.9"
FUSE_CHECKSUM="23009734faca2f62d337e3a59be4c280"
FUSE_LINK="https://github.com/libfuse/libfuse/archive/fuse-${FUSE_VERSION}.tar.gz"

download_fuse() {
    download_file $FUSE_LINK $FUSE_CHECKSUM
}

extract_fuse() {
    if [ ! -d "${FUSE_PKGNAME}-${FUSE_VERSION}" ]; then
        progress "extracting: ${FUSE_PKGNAME}-${FUSE_VERSION}"
        tar -xf ${DISTFILES}/fuse-${FUSE_VERSION}.tar.gz -C .
    fi
}

prepare_fuse() {
    progress "preparing: ${FUSE_PKGNAME}"

    if [ "${BUILDARCH}" == "arm64" ]; then
        if [ ! -f .patched_libfuse-arm64-uint64.patch ]; then
            progress "patching: ${FUSE_PKGNAME}"
            patch -p1 < ${PATCHESDIR}/libfuse-arm64-uint64.patch
            touch .patched_libfuse-arm64-uint64.patch
        fi
    fi

    ./makeconf.sh
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_fuse() {
    progress "compiling: ${FUSE_PKGNAME}"

    make ${MAKEOPTS}
}

install_fuse() {
    progress "installing: ${FUSE_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_fuse() {
    pushd "${WORKDIR}/${FUSE_PKGNAME}-${FUSE_VERSION}"

    prepare_fuse
    compile_fuse
    install_fuse

    popd
}

registrar_fuse() {
    DOWNLOADERS+=(download_fuse)
    EXTRACTORS+=(extract_fuse)
}

registrar_fuse
