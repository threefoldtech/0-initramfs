NCURSES_PKGNAME="ncurses"
NCURSES_VERSION="6.2"
NCURSES_CHECKSUM="e812da327b1c2214ac1aed440ea3ae8d"
NCURSES_LINK="https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz"

download_ncurses() {
    download_file $NCURSES_LINK $NCURSES_CHECKSUM
}

extract_ncurses() {
    if [ ! -d "${NCURSES_PKGNAME}-${NCURSES_VERSION}" ]; then
        progress "extracting: ${NCURSES_PKGNAME}-${NCURSES_VERSION}"
        tar -xf ${DISTFILES}/${NCURSES_PKGNAME}-${NCURSES_VERSION}.tar.gz -C .
    fi
}

prepare_ncurses() {
    progress "configuring: ${NCURSES_PKGNAME}"

    CFLAGS="$CFLAGS -fPIC" ./configure --prefix=/usr \
        --build=${BUILDCOMPILE} \
        --host=${BUILDHOST} \
        --disable-stripping \
        --without-manpages \
        --disable-database \
        --enable-termcap

    # disable stripping for cross-compilation issue
    # we strip everything ourself later anyway
}

compile_ncurses() {
    progress "compiling: ${NCURSES_PKGNAME}"

    make ${MAKEOPTS}
}

install_ncurses() {
    progress "installing: ${NCURSES_PKGNAME}"

    make DESTDIR="${ROOTDIR}" install
}

build_ncurses() {
    pushd "${WORKDIR}/${NCURSES_PKGNAME}-${NCURSES_VERSION}"

    prepare_ncurses
    compile_ncurses
    install_ncurses

    popd
}

registrar_ncurses() {
    DOWNLOADERS+=(download_ncurses)
    EXTRACTORS+=(extract_ncurses)
}

registrar_ncurses
