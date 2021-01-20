CONTAINERD_PKGNAME="containerd"
CONTAINERD_VERSION="ae2f3fdfd1a435fe83fb083e4db9fa63a9e0a13e"
CONTAINERD_CHECKSUM="73e6d4bad082e69e530c8ab5a9ee5118"
CONTAINERD_LINK="https://github.com/containerd/containerd/archive/${CONTAINERD_VERSION}.tar.gz"
CONTAINERD_HOME="${GOPATH}/src/github.com/containerd"

download_containerd() {
    download_file $CONTAINERD_LINK $CONTAINERD_CHECKSUM ${CONTAINERD_PKGNAME}-${CONTAINERD_VERSION}.tar.gz
}

extract_containerd() {
    if [ ! -d "${CONTAINERD_PKGNAME}-${CONTAINERD_VERSION}" ]; then
        progress "extracting: ${CONTAINERD_PKGNAME}-${CONTAINERD_VERSION}"
        tar -xf ${DISTFILES}/${CONTAINERD_PKGNAME}-${CONTAINERD_VERSION}.tar.gz -C .
    fi
}

prepare_containerd() {
    progress "preparing: ${CONTAINERD_PKGNAME}"

    mkdir -p "${CONTAINERD_HOME}"
    rm -rf "${CONTAINERD_HOME}/containerd"

    ln -s ${PWD} "${CONTAINERD_HOME}/containerd"
}

compile_containerd() {
    progress "compiling: ${CONTAINERD_PKGNAME}"

    pushd ${CONTAINERD_HOME}/containerd
    CGO_ENABLED=1 make CGO_CFLAGS="$CFLAGS" CGO_LDFLAGS="$LDFLAGS" ${MAKEOPTS}
    popd
}

install_containerd() {
    progress "installing: ${CONTAINERD_PKGNAME}"

    cp -av bin/* "${RUNDIR}/usr/bin/"

    mkdir -p "${RUNDIR}/etc/containerd"
    mkdir -p "${RUNDIR}/etc/zinit"

    cp -av ${CONFDIR}/packages/${CONTAINERD_PKGNAME}/config.toml "${RUNDIR}/etc/containerd/"
    cp -av ${CONFDIR}/packages/${CONTAINERD_PKGNAME}/containerd.yaml "${RUNDIR}/etc/zinit/"
}

build_containerd() {
    pushd "${WORKDIR}/${CONTAINERD_PKGNAME}-${CONTAINERD_VERSION}"

    prepare_containerd
    compile_containerd
    install_containerd

    popd
}

registrar_containerd() {
    DOWNLOADERS+=(download_containerd)
    EXTRACTORS+=(extract_containerd)
}

registrar_containerd
