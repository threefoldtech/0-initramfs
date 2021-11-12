ZINIT_VERSION="0.2.1"
ZINIT_HASH="c7aabd96bc390d2f36795a53f8561ba9"
ZINIT_BINARY="https://github.com/threefoldtech/zinit/releases/download/v${ZINIT_VERSION}/zinit"

download_zinit() {
    download_file ${ZINIT_BINARY} ${ZINIT_HASH}
}

install_zinit() {
    echo "[+] copying binaries"
    chmod +x ${DISTFILES}/zinit
    cp -a ${DISTFILES}/zinit "${ROOTDIR}/sbin/"
}

build_zinit() {
    install_zinit
}

registrar_zinit() {
    DOWNLOADERS+=(download_zinit)
}

registrar_zinit
