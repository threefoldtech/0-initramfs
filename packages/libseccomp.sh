LIBSECCOMP_PKGNAME="libseccomp"
LIBSECCOMP_VERSION="2.5.1"
LIBSECCOMP_CHECKSUM="150ccf132ecf26598430c5addf3a543e"
LIBSECCOMP_LINK="https://github.com/seccomp/libseccomp/archive/v${LIBSECCOMP_VERSION}.tar.gz"

download_libseccomp() {
    download_file $LIBSECCOMP_LINK $LIBSECCOMP_CHECKSUM ${LIBSECCOMP_PKGNAME}-${LIBSECCOMP_VERSION}.tar.gz
}

extract_libseccomp() {
    if [ ! -d "${LIBSECCOMP_PKGNAME}-${LIBSECCOMP_VERSION}" ]; then
        progress "extracting: ${LIBSECCOMP_PKGNAME}-${LIBSECCOMP_VERSION}"
        tar -xf ${DISTFILES}/${LIBSECCOMP_PKGNAME}-${LIBSECCOMP_VERSION}.tar.gz -C .
    fi
}

prepare_libseccomp() {
    progress "configuring: ${LIBSECCOMP_PKGNAME}"

    ./autogen.sh
    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_libseccomp() {
    progress "compiling: ${LIBSECCOMP_PKGNAME}"

    make ${MAKEOPTS}
}

install_libseccomp() {
    progress "installing: ${LIBSECCOMP_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_libseccomp() {
    pushd "${WORKDIR}/${LIBSECCOMP_PKGNAME}-${LIBSECCOMP_VERSION}"

    prepare_libseccomp
    compile_libseccomp
    install_libseccomp

    popd
}

registrar_libseccomp() {
    DOWNLOADERS+=(download_libseccomp)
    EXTRACTORS+=(extract_libseccomp)
}

registrar_libseccomp
