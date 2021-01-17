RESTIC_VERSION="0.9.2"
RESTIC_CHECKSUM="dd08f71f2df5901d6b3e3faf3b4f6d2a"
RESTIC_LINK="https://github.com/restic/restic/archive/v${RESTIC_VERSION}.tar.gz"

download_restic() {
    download_file $RESTIC_LINK $RESTIC_CHECKSUM restic-${RESTIC_VERSION}.tar.gz
}

extract_restic() {
    if [ ! -d "restic-${RESTIC_VERSION}" ]; then
        progress "extracting: restic-${RESTIC_VERSION}"
        tar -xf ${DISTFILES}/restic-${RESTIC_VERSION}.tar.gz -C .
    fi
}

prepare_restic() {
    progress "preparing restic"
}

compile_restic() {
    progress "compiling restic"
    go run build.go
}

install_restic() {
    progress "installing restic"
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

