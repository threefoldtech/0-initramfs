SQLITE3_PKGNAME="sqlite"
SQLITE3_VERSION="3340000" # 3.34.0
SQLITE3_CHECKSUM="7f33c9db7b713957fcb9271fe9049fef"
SQLITE3_LINK="https://www.sqlite.org/2020/sqlite-autoconf-${SQLITE3_VERSION}.tar.gz"

download_sqlite3() {
    download_file $SQLITE3_LINK $SQLITE3_CHECKSUM
}

extract_sqlite3() {
    if [ ! -d "${SQLITE3_PKGNAME}-autoconf-${SQLITE3_VERSION}" ]; then
        echo "[+] extracting: ${SQLITE3_PKGNAME}-${SQLITE3_VERSION}"
        tar -xf ${DISTFILES}/${SQLITE3_PKGNAME}-autoconf-${SQLITE3_VERSION}.tar.gz
    fi
}

prepare_sqlite3() {
    echo "[+] configuring: ${SQLITE3_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_sqlite3() {
    echo "[+] compiling: ${SQLITE3_PKGNAME}"
    make ${MAKEOPTS}
}

install_sqlite3() {
    echo "[+] installing: ${SQLITE3_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_sqlite3() {
    pushd "${WORKDIR}/${SQLITE3_PKGNAME}-autoconf-${SQLITE3_VERSION}"

    prepare_sqlite3
    compile_sqlite3
    install_sqlite3

    popd
}

registrar_sqlite3() {
    DOWNLOADERS+=(download_sqlite3)
    EXTRACTORS+=(extract_sqlite3)
}

registrar_sqlite3
