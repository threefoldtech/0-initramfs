OPENSSH_PKGNAME="openssh"
OPENSSH_VERSION="8.4p1"
OPENSSH_CHECKSUM="8f897870404c088e4aa7d1c1c58b526b"
OPENSSH_LINK="https://ftp.fr.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz"

download_openssh() {
    download_file $OPENSSH_LINK $OPENSSH_CHECKSUM
}

extract_openssh() {
    if [ ! -d "${OPENSSH_PKGNAME}-${OPENSSH_VERSION}" ]; then
        progress "extracting: ${OPENSSH_PKGNAME}-${OPENSSH_VERSION}"
        tar -xf ${DISTFILES}/${OPENSSH_PKGNAME}-${OPENSSH_VERSION}.tar.gz -C .
    fi
}

prepare_openssh() {
    progress "preparing: ${OPENSSH_PKGNAME}"

    make distclean

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
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
    progress "compiling: ${OPENSSH_PKGNAME}"

    make ${MAKEOPTS}
}

install_openssh() {
    progress "installing: ${OPENSSH_PKGNAME}"

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
