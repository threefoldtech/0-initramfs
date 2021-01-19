YGGDRASIL_PKGNAME="yggdrasil-go"
YGGDRASIL_VERSION="0.3.15"
YGGDRASIL_CHECKSUM="7e94c14d66a9d82c73d2a7ac3a9488ad"
YGGDRASIL_LINK="https://github.com/yggdrasil-network/yggdrasil-go/archive/v${YGGDRASIL_VERSION}.tar.gz"
YGGDRASIL_HOME="${GOPATH}/src/github.com/yggdrasil-network/yggdrasil-go"

download_yggdrasil() {
    download_file $YGGDRASIL_LINK $YGGDRASIL_CHECKSUM ${YGGDRASIL_PKGNAME}-${YGGDRASIL_VERSION}.tar.gz
}

extract_yggdrasil() {
    if [ ! -d "${YGGDRASIL_PKGNAME}-${YGGDRASIL_VERSION}" ]; then
        progress "extracting: ${YGGDRASIL_PKGNAME}-${YGGDRASIL_VERSION}"
        tar -xf ${DISTFILES}/${YGGDRASIL_PKGNAME}-${YGGDRASIL_VERSION}.tar.gz -C .
    fi
}

compile_yggdrasil() {
    progress "compiling: ${YGGDRASIL_PKGNAME}"

    ./build
}

install_yggdrasil() {
    progress "installing: ${YGGDRASIL_PKGNAME}"

    cp -av yggdrasil "${ROOTDIR}/usr/bin/"
    cp -av yggdrasilctl "${ROOTDIR}/usr/bin/"
}

build_yggdrasil() {
    pushd "${WORKDIR}/${YGGDRASIL_PKGNAME}-${YGGDRASIL_VERSION}"

    compile_yggdrasil
    install_yggdrasil

    popd
}

registrar_yggdrasil() {
    DOWNLOADERS+=(download_yggdrasil)
    EXTRACTORS+=(extract_yggdrasil)
}

registrar_yggdrasil
