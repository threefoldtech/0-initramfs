HAVEGED_PKGNAME="haveged"
HAVEGED_VERSION="1.9.4"
HAVEGED_CHECKSUM="95867032bb3f2abd36179f92e328e651"
HAVEGED_LINK="https://github.com/jirka-h/haveged/archive/${HAVEGED_VERSION}.tar.gz"

download_haveged() {
    download_file $HAVEGED_LINK $HAVEGED_CHECKSUM ${HAVEGED_PKGNAME}-${HAVEGED_VERSION}.tar.gz
}

extract_haveged() {
    if [ ! -d "${HAVEGED_PKGNAME}-${HAVEGED_VERSION}" ]; then
        progress "extracting: ${HAVEGED_PKGNAME}-${HAVEGED_VERSION}"
        tar -xf ${DISTFILES}/${HAVEGED_PKGNAME}-${HAVEGED_VERSION}.tar.gz -C .
    fi
}

prepare_haveged() {
    progress "configuring: ${HAVEGED_PKGNAME}"

    ./configure --prefix=/usr \
        --build ${BUILDCOMPILE} \
        --host ${BUILDHOST}
}

compile_haveged() {
    progress "compiling: ${HAVEGED_PKGNAME}"

    make ${MAKEOPTS}
}

install_haveged() {
    progress "installing: ${HAVEGED_PKGNAME}"

    cp -avL src/.libs/haveged "${ROOTDIR}/usr/bin/"
    cp -avL src/.libs/libhavege.s* "${ROOTDIR}/usr/lib/"
}

build_haveged() {
    pushd "${WORKDIR}/${HAVEGED_PKGNAME}-${HAVEGED_VERSION}"

    prepare_haveged
    compile_haveged
    install_haveged

    popd
}

registrar_haveged() {
    DOWNLOADERS+=(download_haveged)
    EXTRACTORS+=(extract_haveged)
}

registrar_haveged
