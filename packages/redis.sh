REDIS_PKGNAME="redis"
REDIS_VERSION="5.0.5"
REDIS_CHECKSUM="2d2c8142baf72e6543174fc7beccaaa1"
REDIS_LINK="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"

download_redis() {
    download_file $REDIS_LINK $REDIS_CHECKSUM
}

extract_redis() {
    if [ ! -d "${REDIS_PKGNAME}-${REDIS_VERSION}" ]; then
        progress "extracting: ${REDIS_PKGNAME}-${REDIS_VERSION}"
        tar -xf ${DISTFILES}/${REDIS_PKGNAME}-${REDIS_VERSION}.tar.gz -C .
    fi
}

compile_redis() {
    progress "compiling: ${REDIS_PKGNAME}"

    make MALLOC=libc LDFLAGS=-latomic ${MAKEOPTS}
}

install_redis() {
    progress "installing: ${REDIS_PKGNAME}"

    cp -avL src/redis-server "${ROOTDIR}/usr/bin/"
}

build_redis() {
    pushd "${WORKDIR}/${REDIS_PKGNAME}-${REDIS_VERSION}"

    compile_redis
    install_redis

    popd
}

registrar_redis() {
    DOWNLOADERS+=(download_redis)
    EXTRACTORS+=(extract_redis)
}

registrar_redis
