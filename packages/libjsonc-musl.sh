JSONC_MUSL_PKGNAME="json-c"
JSONC_MUSL_VERSION="0.13.1-20180305"
JSONC_MUSL_CHECKSUM="20dba7bf773599a0842745a2fe5b7cd3"
JSONC_MUSL_LINK="https://github.com/json-c/json-c/archive/json-c-${JSONC_MUSL_VERSION}.tar.gz"

download_jsonc_musl() {
    download_file $JSONC_MUSL_LINK $JSONC_MUSL_CHECKSUM
}

extract_jsonc_musl() {
    if [ ! -d "${JSONC_MUSL_PKGNAME}-json-c-${JSONC_MUSL_VERSION}" ]; then
        progress "extracting: ${JSONC_MUSL_PKGNAME}-${JSONC_MUSL_PKGNAME}-${JSONC_MUSL_VERSION}"
        tar -xf ${DISTFILES}/${JSONC_MUSL_PKGNAME}-${JSONC_MUSL_VERSION}.tar.gz -C .
    fi
}

prepare_jsonc_musl() {
    progress "configuring: ${JSONC_MUSL_PKGNAME}"

    CC="${MUSLSYSDIR}/bin/musl-gcc" ./configure --prefix=/ \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-shared \
        --enable-static
}

compile_jsonc_musl() {
    progress "compiling: ${JSONC_MUSL_PKGNAME}"

    make ${MAKEOPTS}
}

install_jsonc_musl() {
    progress "installing: ${JSONC_MUSL_PKGNAME}"

    make DESTDIR="${MUSLROOTDIR}" install
}

build_jsonc_musl() {
    pushd "${MUSLWORKDIR}/${JSONC_MUSL_PKGNAME}-${JSONC_MUSL_PKGNAME}-${JSONC_MUSL_VERSION}"

    prepare_jsonc_musl
    compile_jsonc_musl
    install_jsonc_musl

    popd
}

registrar_jsonc_musl() {
    DOWNLOADERS+=(download_jsonc_musl)
    EXTRACTORS+=(extract_jsonc_musl)
}

registrar_jsonc_musl
