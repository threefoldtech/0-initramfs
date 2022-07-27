TSS_VERSION="3.2.0"
TSS_CHECKSUM="0d60d0df3fd0daae66881a3022281323"
TSS_LINK="https://github.com/tpm2-software/tpm2-tss/releases/download/${TSS_VERSION}/tpm2-tss-${TSS_VERSION}.tar.gz"

download_tss() {
    download_file $TSS_LINK $TSS_CHECKSUM
}

extract_tss() {
    if [ ! -d "tpm2-tss-${TSS_VERSION}" ]; then
        echo "[+] extracting: tpm2-tss-${TSS_VERSION}"
        tar -xf ${DISTFILES}/tpm2-tss-${TSS_VERSION}.tar.gz -C .
    fi
}

prepare_tss() {
    echo "[+] preparing tpm-tss"
    ./configure --prefix=/usr
}

compile_tss() {
    echo "[+] compiling tpm-tss"
    make ${MAKEOPTS}
}

install_tss() {
    echo "[+] installing tpm-tss"
    make install
}

build_tss() {
    pushd "${WORKDIR}/tpm2-tss-${TSS_VERSION}"

    prepare_tss
    compile_tss
    install_tss

    popd
}

registrar_tss() {
    DOWNLOADERS+=(download_tss)
    EXTRACTORS+=(extract_tss)
}

registrar_tss
