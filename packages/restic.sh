RESTIC_VERSION="0.9.3"
RESTIC_CHECKSUM="6818e3744cec489a7f0da4f0e3beafeb"
RESTIC_LINK="https://github.com/restic/restic/archive/v${RESTIC_VERSION}.tar.gz"

download_restic() {
    download_file $RESTIC_LINK $RESTIC_CHECKSUM restic-${RESTIC_VERSION}.tar.gz
}

extract_restic() {
    if [ ! -d "restic-${RESTIC_VERSION}" ]; then
        echo "[+] extracting: restic-${RESTIC_VERSION}"
        tar -xf ${DISTFILES}/restic-${RESTIC_VERSION}.tar.gz -C .
    fi
}

prepare_restic() {
    echo "[+] preparing restic"
}

compile_restic() {
    echo "[+] compiling restic"
    go run build.go
}

install_restic() {
    echo "[+] installing restic"
    cp -a restic "${ROOTDIR}/usr/bin/"
}

build_restic() {
    pushd "${WORKDIR}/restic-${RESTIC_VERSION}"

    prepare_restic
    compile_restic
    install_restic

    popd
}

registrar_restic() {
    DOWNLOADERS+=(download_restic)
    EXTRACTORS+=(extract_restic)
}

registrar_restic

