TPM_VERSION="5.2"
TPM_CHECKSUM="bf050f002fe510e1daecd39044e1122d"
TPM_LINK="https://github.com/tpm2-software/tpm2-tools/releases/download/${TPM_VERSION}/tpm2-tools-${TPM_VERSION}.tar.gz"

download_tpm() {
    download_file $TPM_LINK $TPM_CHECKSUM
}

extract_tpm() {
    if [ ! -d "tpm2-tools-${TPM_VERSION}" ]; then
        echo "[+] extracting: tpm2-tools-${TPM_VERSION}"
        tar -xf ${DISTFILES}/tpm2-tools-${TPM_VERSION}.tar.gz -C .
    fi
}

prepare_tpm() {
    echo "[+] preparing tpm"
    ./configure --prefix=/usr
}

compile_tpm() {
    echo "[+] compiling tpm"
    make ${MAKEOPTS}
}

install_tpm() {
    echo "[+] installing tpm"
    make install
}

build_tpm() {
    pushd "${WORKDIR}/tpm2-tools-${TPM_VERSION}"

    prepare_tpm
    compile_tpm
    install_tpm

    popd
}

registrar_tpm() {
    DOWNLOADERS+=(download_tpm)
    EXTRACTORS+=(extract_tpm)
}

registrar_tpm
