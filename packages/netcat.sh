NETCAT_MAJOR="110"
NETCAT_VERSION="20180111"
NETCAT_CHECKSUM="691e734b398bbbe2225feffdd21f63b7"
NETCAT_LINK="http://gentoo.mirrors.ovh.net/gentoo-distfiles/distfiles/nc${NETCAT_MAJOR}.${NETCAT_VERSION}.tar.xz"

download_netcat() {
    download_file $NETCAT_LINK $NETCAT_CHECKSUM
}

extract_netcat() {
    if [ ! -d "nc${NETCAT_MAJOR}" ]; then
        echo "[+] extracting: netcat-${NETCAT_MAJOR}"
        tar -xf ${DISTFILES}/nc${NETCAT_MAJOR}.${NETCAT_VERSION}.tar.xz -C .
    fi
}

prepare_netcat() {
    sed -i -e '/#define HAVE_BIND/s:#define:#undef:' netcat.c
    sed -i -e '/#define FD_SETSIZE 16/s:16:1024: #34250' netcat.c
}

compile_netcat() {
    echo "[+] building: netcat"
    make CC=$CC nc
}

install_netcat() {
    echo "[+] installing: netcat"
    cp -avL nc "${ROOTDIR}/usr/bin/"
}

build_netcat() {
    pushd "${WORKDIR}/nc${NETCAT_MAJOR}"

    prepare_netcat
    compile_netcat
    install_netcat

    popd
}

registrar_netcat() {
    DOWNLOADERS+=(download_netcat)
    EXTRACTORS+=(extract_netcat)
}

registrar_netcat
