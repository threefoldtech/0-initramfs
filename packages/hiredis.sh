HIREDIS_PKGNAME="hiredis"
HIREDIS_VERSION="1.0.0"
HIREDIS_CHECKSUM="209ae570cdee65a5143ea6db8ac07fe3"
HIREDIS_LINK="https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz"

download_hiredis() {
    download_file $HIREDIS_LINK $HIREDIS_CHECKSUM hiredis-${HIREDIS_VERSION}.tar.gz
}

extract_hiredis() {
    if [ ! -d "${HIREDIS_PKGNAME}-${HIREDIS_VERSION}" ]; then
        echo "[+] extracting: ${HIREDIS_PKGNAME}-${HIREDIS_VERSION}"
        tar -xf ${DISTFILES}/${HIREDIS_PKGNAME}-${HIREDIS_VERSION}.tar.gz -C .
    fi
}

prepare_hiredis() {
    echo "[+] configuring: ${HIREDIS_PKGNAME}"
}

compile_hiredis() {
    echo "[+] compiling: ${HIREDIS_PKGNAME}"

    make ${MAKEOPTS}
}

install_hiredis() {
    echo "[+] installing: ${HIREDIS_PKGNAME}"

    make DESTDIR="${ROOTDIR}" PREFIX=/usr install
}

build_hiredis() {
    pushd "${WORKDIR}/${HIREDIS_PKGNAME}-${HIREDIS_VERSION}"

    prepare_hiredis
    compile_hiredis
    install_hiredis

    popd
}

registrar_hiredis() {
    DOWNLOADERS+=(download_hiredis)
    EXTRACTORS+=(extract_hiredis)
}

registrar_hiredis
