OPENSSH_VERSION="9.8p1"
OPENSSH_CHECKSUM="bc04ff77796758c0b37bd0bc9314cd3f"
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

    # remove possible leftover configuration
    # otherwise 'make install' will not overwrite them
    rm -rf "${ROOTDIR}/etc/ssh"

    make DESTDIR="${ROOTDIR}" install-nokeys

    mkdir -p -m 700 "${ROOTDIR}/root/.ssh"

    if [ "${BUILDMODE}" == "release" ]; then
        echo "[+] hardening openssh server settings"

        # hardening authentication
        sed -i 's/#Port 22/Port 34022/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#UsePAM no/UsePAM no/g' "${ROOTDIR}"/etc/ssh/sshd_config
    else
        echo "[+] enable debug ssh settings"

        # keep debugging mode more permissive
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' "${ROOTDIR}"/etc/ssh/sshd_config
        sed -i 's/#KbdInteractiveAuthentication yes/KbdInteractiveAuthentication yes/g' "${ROOTDIR}"/etc/ssh/sshd_config
    fi

    unset CFLAGS
    unset LDFLAGS
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
