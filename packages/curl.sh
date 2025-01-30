CURL_VERSION="8.11.1"
CURL_CHECKSUM="25e65a5156ca4928060b61cb051813db"
CURL_LINK="https://curl.se/download/curl-${CURL_VERSION}.tar.xz"

download_curl() {
    download_file $CURL_LINK $CURL_CHECKSUM
}

extract_curl() {
    if [ ! -d "curl-${CURL_VERSION}" ]; then
        echo "[+] extracting: curl-${CURL_VERSION}"
        tar -xf ${DISTFILES}/curl-${CURL_VERSION}.tar.xz -C .
    fi
}

prepare_curl() {
    echo "[+] configuring curl"

    autoreconf -f -i -s
    ./configure --prefix=${ROOTDIR}/usr \
        --disable-debug --enable-optimize --disable-curldebug --disable-symbol-hiding --disable-rt \
        --disable-ftp --disable-ldap --disable-ldaps --disable-rtsp --disable-proxy --disable-dict \
        --disable-telnet --disable-tftp --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher \
        --disable-manual --disable-libcurl-option --disable-sspi --without-brotli --without-librtmp --without-winidn \
        --disable-threaded-resolver --without-libpsl --without-zstd \
        --with-openssl
}

compile_curl() {
    make ${MAKEOPTS}
}

install_curl() {
    make install
}

build_curl() {
    pushd "${WORKDIR}/curl-${CURL_VERSION}"

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
