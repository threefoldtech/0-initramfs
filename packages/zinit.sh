ZINIT_VERSION="0.2.11"
ZINIT_HASH="e1d6a6f0ff604e58735cd7bd127e5c78"
ZINIT_BINARY="https://github.com/threefoldtech/zinit/releases/download/v${ZINIT_VERSION}/zinit"

download_zinit() {
    download_file ${ZINIT_BINARY} ${ZINIT_HASH} "zinit-${ZINIT_VERSION}"
}

install_zinit() {
    echo "[+] copying binaries"
    filepath="${DISTFILES}/zinit-${ZINIT_VERSION}"
    chmod +x ${filepath}
    cp -a "${filepath}" "${ROOTDIR}/sbin/zinit"
}

build_zinit() {
    install_zinit
}

registrar_zinit() {
    DOWNLOADERS+=(download_zinit)
}

registrar_zinit
