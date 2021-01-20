RUNC_PKGNAME="runc"
RUNC_VERSION="1.0.0-rc9"
RUNC_CHECKSUM="e88bcb1a33e7ff0bfea495f7263826c2"
RUNC_LINK="https://github.com/opencontainers/runc/archive/v${RUNC_VERSION}.tar.gz"
RUNC_HOME="${GOPATH}/src/github.com/opencontainers"

download_runc() {
    download_file $RUNC_LINK $RUNC_CHECKSUM ${RUNC_PKGNAME}-${RUNC_VERSION}.tar.gz
}

extract_runc() {
    if [ ! -d "${RUNC_PKGNAME}-${RUNC_VERSION}" ]; then
        progress "extracting: ${RUNC_PKGNAME}-${RUNC_VERSION}"
        tar -xf ${DISTFILES}/${RUNC_PKGNAME}-${RUNC_VERSION}.tar.gz -C .
    fi
}

prepare_runc() {
    progress "preparing: ${RUNC_PKGNAME}"

    mkdir -p "${RUNC_HOME}"
    rm -rf "${RUNC_HOME}/runc"

    ln -s ${PWD} "${RUNC_HOME}/runc"
}

compile_runc() {
    progress "compiling: ${RUNC_PKGNAME}"

    pushd ${RUNC_HOME}/runc
    CGO_ENABLED=1 make CGO_CFLAGS="$CFLAGS" CGO_LDFLAGS="$LDFLAGS" BUILDTAGS='seccomp' ${MAKEOPTS}
    popd
}

install_runc() {
    progress "installing: ${RUNC_PKGNAME}"

    mkdir -p "${RUNDIR}/usr/bin"

    cp -av runc "${RUNDIR}/usr/bin/"
}

build_runc() {
    pushd "${WORKDIR}/${RUNC_PKGNAME}-${RUNC_VERSION}"

    prepare_runc
    compile_runc
    install_runc

    popd
}

registrar_runc() {
    DOWNLOADERS+=(download_runc)
    EXTRACTORS+=(extract_runc)
}

registrar_runc
