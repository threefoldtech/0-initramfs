JANSSON_PKGNAME="jansson"
JANSSON_VERSION="2.13.1"
JANSSON_CHECKSUM="570af45b8203e95876d71fecd56cee20"
JANSSON_LINK="https://digip.org/jansson/releases/jansson-${JANSSON_VERSION}.tar.gz"

download_jansson() {
    download_file $JANSSON_LINK $JANSSON_CHECKSUM
}

extract_jansson() {
    if [ ! -d "${JANSSON_PKGNAME}-${JANSSON_VERSION}" ]; then
        echo "[+] extracting: ${JANSSON_PKGNAME}-${JANSSON_VERSION}"
        tar -xf ${DISTFILES}/${JANSSON_PKGNAME}-${JANSSON_VERSION}.tar.gz -C .
    fi
}

prepare_jansson() {
    echo "[+] configuring: ${JANSSON_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_jansson() {
    echo "[+] compiling: ${JANSSON_PKGNAME}"

    make ${MAKEOPTS}
}

install_jansson() {
    echo "[+] installing: ${JANSSON_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_jansson() {
    pushd "${WORKDIR}/${JANSSON_PKGNAME}-${JANSSON_VERSION}"

    prepare_jansson
    compile_jansson
    install_jansson

    popd
}

registrar_jansson() {
    DOWNLOADERS+=(download_jansson)
    EXTRACTORS+=(extract_jansson)
}

registrar_jansson
