CURL_VERSION="7_65_1"
CURL_CHECKSUM="651706b87c501317030ec317dd84f3ef"
CURL_LINK="https://github.com/curl/curl/archive/curl-${CURL_VERSION}.tar.gz"

download_curl() {
    download_file $CURL_LINK $CURL_CHECKSUM
}

extract_curl() {
    # curl-curl is not a script mistake
    if [ ! -d "curl-curl-${CURL_VERSION}" ]; then
        echo "[+] extracting: curl-${CURL_VERSION}"
        tar -xf ${DISTFILES}/curl-${CURL_VERSION}.tar.gz -C .
    fi
}

prepare_curl() {
    echo "[+] configuring curl"

    autoreconf -f -i -s

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-debug \
        --enable-optimize \
        --disable-curldebug \
        --disable-symbol-hiding \
        --disable-rt \
        --disable-ftp \
        --disable-ldap \
        --disable-ldaps \
        --disable-rtsp \
        --disable-proxy \
        --disable-dict \
        --disable-telnet \
        --disable-tftp \
        --disable-pop3 \
        --disable-imap \
        --disable-smb \
        --disable-smtp \
        --disable-gopher \
        --disable-manual \
        --disable-libcurl-option \
        --disable-sspi \
        --disable-ntlm-wb \
        --without-brotli \
        --without-librtmp \
        --without-winidn \
        --disable-threaded-resolver \
        --with-openssl \
        --with-ssl=${ROOTDIR}/usr/lib \
        --with-ca-path=${ROOTDIR}/etc/ssl/certs
}

compile_curl() {
    make ${MAKEOPTS}
}

install_curl() {
    make DESTDIR=${ROOTDIR} install
}

build_curl() {
    # curl-curl is not a script mistake
    pushd "${WORKDIR}/curl-curl-${CURL_VERSION}"

    prepare_curl
    compile_curl
    install_curl

    popd
}

registrar_curl() {
    DOWNLOADERS+=(download_curl)
    EXTRACTORS+=(extract_curl)
}

registrar_curl
