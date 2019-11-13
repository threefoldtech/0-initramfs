OPENSSH_VERSION="8.0p1"
OPENSSH_CHECKSUM="bf050f002fe510e1daecd39044e1122d"
OPENSSH_LINK="https://ftp.fr.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz"

download_openssh() {
    download_file $OPENSSH_LINK $OPENSSH_CHECKSUM
}

extract_openssh() {
    if [ ! -d "openssh-${OPENSSH_VERSION}" ]; then
        echo "[+] extracting: openssh-${OPENSSH_VERSION}"
        tar -xf ${DISTFILES}/openssh-${OPENSSH_VERSION}.tar.gz -C .
    fi
}

prepare_openssh() {
    echo "[+] preparing openssh"
    export CFLAGS="-I${ROOTDIR}/include"
    export LDFLAGS="-L${ROOTDIR}/lib"
    ./configure --prefix=/usr \
        --sysconfdir=/etc/ssh \
        --without-kerberos5 \
        --without-ldns \
        --with-pie \
        --without-libedit \
        --without-pam \
        --without-selinux \
        --without-shadow \
        --disable-strip \
        --with-privsep-user=root \
        --without-openssl-header-check \
        --with-ssl-dir="${ROOTDIR}"
}

compile_openssh() {
    echo "[+] compiling openssh"
    make ${MAKEOPTS}
}

install_openssh() {
    echo "[+] installing openssh"
    make DESTDIR="${ROOTDIR}" install-nokeys

    mkdir -p -m 700 "${ROOTDIR}"/root/.ssh

    # configuring openssh
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' "${ROOTDIR}"/etc/ssh/sshd_config
}

build_openssh() {
    pushd "${WORKDIR}/openssh-${OPENSSH_VERSION}"

    prepare_openssh
    compile_openssh
    install_openssh

    popd
}

registrar_openssh() {
    DOWNLOADERS+=(download_openssh)
    EXTRACTORS+=(extract_openssh)
}

registrar_openssh
