READLINE_PKGNAME="readline"
READLINE_VERSION="8.1"
READLINE_CHECKSUM="e9557dd5b1409f5d7b37ef717c64518e"
READLINE_LINK="https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz"

download_readline() {
    download_file $READLINE_LINK $READLINE_CHECKSUM
}

extract_readline() {
    if [ ! -d "${READLINE_PKGNAME}-${READLINE_VERSION}" ]; then
        progress "extracting: ${READLINE_PKGNAME}-${READLINE_VERSION}"
        tar -xf ${DISTFILES}/${READLINE_PKGNAME}-${READLINE_VERSION}.tar.gz -C .
    fi
}

prepare_readline() {
    progress "configuring: ${READLINE_PKGNAME}"

    ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST}
}

compile_readline() {
    progress "compiling: ${READLINE_PKGNAME}"

    make ${MAKEOPTS}
}

install_readline() {
    progress "installing: ${READLINE_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_readline() {
    pushd "${WORKDIR}/${READLINE_PKGNAME}-${READLINE_VERSION}"

    prepare_readline
    compile_readline
    install_readline

    popd
}

registrar_readline() {
    DOWNLOADERS+=(download_readline)
    EXTRACTORS+=(extract_readline)
}

registrar_readline
