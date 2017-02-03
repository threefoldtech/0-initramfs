CERTS_VERSION="20161130"
CERTS_CHECKSUM="903fd61bf44370efe92f463783e59a9a"
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

    cd usr/share/ca-certificates/
    find * -name '*.crt' | LC_ALL=C sort > ../../../etc/ca-certificates.conf
    cd ../../../

    if [ ! -f ca-certificates-20150426-root.patch ]; then
        echo "[+] downloading patch"
        curl -s https://gist.githubusercontent.com/maxux/a5472530dd88b3480d745388d81e4c7f/raw/373d3b04fb36a28fdf99c6748646335e10317242/ca-certificates-20150426-root.patch > ca-certificates-20150426-root.patch
        patch -p1 < ca-certificates-20150426-root.patch
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
