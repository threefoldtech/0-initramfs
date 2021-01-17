SNAPPY_PKGNAME="snappy"
SNAPPY_VERSION="1.1.8"
SNAPPY_CHECKSUM="70e48cba7fecf289153d009791c9977f"
SNAPPY_LINK="https://github.com/google/snappy/archive/${SNAPPY_VERSION}.tar.gz"

download_snappy() {
    download_file $SNAPPY_LINK $SNAPPY_CHECKSUM ${SNAPPY_PKGNAME}-${SNAPPY_VERSION}.tar.gz
}

extract_snappy() {
    if [ ! -d "${SNAPPY_PKGNAME}-${SNAPPY_VERSION}" ]; then
        progress "extracting: ${SNAPPY_PKGNAME}-${SNAPPY_VERSION}"
        tar -xf ${DISTFILES}/${SNAPPY_PKGNAME}-${SNAPPY_VERSION}.tar.gz -C .
    fi
}

prepare_snappy() {
    progress "configuring: ${SNAPPY_PKGNAME}"

    cmake -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_C_COMPILER=${BUILDHOST}-gcc \
        -DCMAKE_CXX_COMPILER=${BUILDHOST}-g++ \
        -DHAVE_LIBZ=NO \
        -DHAVE_LIBLZO2=NO
}

compile_snappy() {
    progress "compiling: ${SNAPPY_PKGNAME}"

    make ${MAKEOPTS}
}

install_snappy() {
    progress "installing: ${SNAPPY_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_snappy() {
    pushd "${WORKDIR}/${SNAPPY_PKGNAME}-${SNAPPY_VERSION}"

    prepare_snappy
    compile_snappy
    install_snappy

    popd
}

registrar_snappy() {
    DOWNLOADERS+=(download_snappy)
    EXTRACTORS+=(extract_snappy)
}

registrar_snappy
