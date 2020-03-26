CERTS_VERSION="20190110"
CERTS_CHECKSUM="e19d56b1ec337f0841c8af944b509537"
CERTS_LINK="http://ftp.fr.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_${CERTS_VERSION}_all.deb"

download_certs() {
    download_file $CERTS_LINK $CERTS_CHECKSUM
}

extract_certs() {
    if [ ! -d "ca-certificates-${CERTS_VERSION}" ]; then
        echo "[+] extracting: ca-certificates-${CERTS_VERSION}"

        mkdir -p "ca-certificates-${CERTS_VERSION}/temp"
        pushd "ca-certificates-${CERTS_VERSION}/temp"
        ar x ${DISTFILES}/ca-certificates_${CERTS_VERSION}_all.deb
        tar -xf data.tar.xz -C ..
        popd

        rm -rf "ca-certificates-${CERTS_VERSION}/temp"
    fi
}

prepare_certs() {
    echo "[+] preparing ca-certificates"

    pushd usr/share/ca-certificates/
    find * -name '*.crt' | LC_ALL=C sort > ../../../etc/ca-certificates.conf
    popd

    if [ ! -f .patched_ca-certificates-20150426-root.patch ]; then
        echo "[+] applying patch"
        patch -p1 < ${PATCHESDIR}/ca-certificates-20150426-root.patch
        sed -i s/'openssl rehash'/c_rehash/g usr/sbin/update-ca-certificates
        touch .patched_ca-certificates-20150426-root.patch
    fi
}

compile_certs() {
    echo "[+] building certificate database"
    sh usr/sbin/update-ca-certificates --root .
}

install_certs() {
    cp -av * "${ROOTDIR}"
    rm -f "${ROOTDIR}"/ca-certificates-20150426-root.patch
}

build_certs() {
    pushd "${WORKDIR}/ca-certificates-${CERTS_VERSION}"

    prepare_certs
    compile_certs
    install_certs

    popd
}

registrar_certs() {
    DOWNLOADERS+=(download_certs)
    EXTRACTORS+=(extract_certs)
}

registrar_certs
