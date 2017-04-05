DROPBEAR_VERSION="2016.74"
DROPBEAR_CHECKSUM="9ad0172731e0f16623937804643b5bd8"
DROPBEAR_LINK="https://matt.ucc.asn.au/dropbear/dropbear-${DROPBEAR_VERSION}.tar.bz2"

download_dropbear() {
    download_file $DROPBEAR_LINK $DROPBEAR_CHECKSUM
}

extract_dropbear() {
    if [ ! -d "dropbear-${DROPBEAR_VERSION}" ]; then
        echo "[+] extracting: dropbear-${DROPBEAR_VERSION}"
        tar -xf ${DISTFILES}/dropbear-${DROPBEAR_VERSION}.tar.bz2 -C .
    fi
}

prepare_dropbear() {
    echo "[+] preparing dropbear"
    ./configure --prefix=/ --disable-shadow

    # changing options
    sed -i '/define DROPBEAR_PASSWORD_ENV/d' options.h
    sed -i '/define INETD_MODE/d' options.h
    sed -i '/define ENABLE_X11FWD/d' options.h
}

compile_dropbear() {
    echo "[+] compiling dropbear"
    make ${MAKEOPTS}
    make scp
}

install_dropbear() {
    echo "[+] installing dropbear"
    make DESTDIR="${ROOTDIR}" install
    cp -a scp "${ROOTDIR}"/bin/

    mkdir -p -m 700 "${ROOTDIR}"/etc/dropbear
    mkdir -p -m 700 "${ROOTDIR}"/root/.ssh
}

build_dropbear() {
    pushd "${WORKDIR}/dropbear-${DROPBEAR_VERSION}"

    prepare_dropbear
    compile_dropbear
    install_dropbear

    popd
}
