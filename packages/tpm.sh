TPM_VERSION="5.2"
TPM_CHECKSUM="0057615ef43b9322d4577fc3bde0e8d6"
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
    make DESTDIR="${ROOTDIR}" install
}

build_tpm() {
    pushd "${WORKDIR}/tpm2-tools-${TPM_VERSION}"

    export PKG_CONFIG_PATH="${ROOTDIR}/usr/lib/pkgconfig/"
    export CFLAGS="-I${ROOTDIR}/usr/include"
    export LDFLAGS="-L${ROOTDIR}/usr/lib"

    prepare_tpm
    compile_tpm
    install_tpm

    unset PKG_CONFIG_PATH
    unset CFLAGS
    unset LDFLAGS

    popd
}

registrar_tpm() {
    DOWNLOADERS+=(download_tpm)
    EXTRACTORS+=(extract_tpm)
}

registrar_tpm
