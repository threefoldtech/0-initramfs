LIBCAP_MUSL_PKGNAME="libcap"
LIBCAP_MUSL_VERSION="2.33"
LIBCAP_MUSL_CHECKSUM="c23bbc02b13d10c3889ef2b1bed34071"
LIBCAP_MUSL_LINK="https://git.kernel.org/pub/scm/linux/kernel/git/morgan/libcap.git/snapshot/libcap-${LIBCAP_MUSL_VERSION}.tar.gz"

download_libcap_musl() {
    download_file $LIBCAP_MUSL_LINK $LIBCAP_MUSL_CHECKSUM
}

extract_libcap_musl() {
    if [ ! -d "${LIBCAP_MUSL_PKGNAME}-${LIBCAP_MUSL_VERSION}" ]; then
        progress "extracting: ${LIBCAP_MUSL_PKGNAME}-${LIBCAP_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${LIBCAP_MUSL_PKGNAME}-${LIBCAP_MUSL_VERSION}.tar.gz -C .
    fi
}

prepare_libcap_musl() {
    progress "configuring: ${LIBCAP_MUSL_PKGNAME}"

    # disable shared lib
    sed -i 's/all: $(MINLIBNAME)/all:/' libcap/Makefile
    sed -i '/0644 $(MINLIBNAME)/d' libcap/Makefile

    # disable tests
    sed -i '/$(MAKE) -C tests/d' Makefile
}

compile_libcap_musl() {
    progress "compiling: ${LIBCAP_MUSL_PKGNAME}"

    # build 'makenames' with default local compiler
    pushd libcap
    make _makenames
    popd

    # build libcap with target compiler (for cross compilation)
    make ${MAKEOPTS} CC=${MUSLSYSDIR}/bin/musl-gcc LD=${MUSLSYSDIR}/bin/musl-gcc GOLANG=no prefix=/
}

install_libcap_musl() {
    progress "installing: ${LIBCAP_MUSL_PKGNAME}"

    make DESTDIR="${MUSLROOTDIR}" GOLANG=no prefix=/ install
}

build_libcap_musl() {
    pushd "${MUSLWORKDIR}/${LIBCAP_MUSL_PKGNAME}-${LIBCAP_MUSL_VERSION}"

    prepare_libcap_musl
    compile_libcap_musl
    install_libcap_musl

    popd
}

registrar_libcap_musl() {
    DOWNLOADERS+=(download_libcap_musl)
    EXTRACTORS+=(extract_libcap_musl)
}

registrar_libcap_musl
