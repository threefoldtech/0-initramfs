REDIS_VERSION="7.2.1"
REDIS_CHECKSUM="005718dbfcba41e05e2a932c28d8e17b"
REDIS_LINK="http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz"

download_redis() {
    download_file $REDIS_LINK $REDIS_CHECKSUM
}

extract_redis() {
    if [ ! -d "redis-${REDIS_VERSION}" ]; then
        echo "[+] extracting: redis-${REDIS_VERSION}"
        tar -xf ${DISTFILES}/redis-${REDIS_VERSION}.tar.gz -C .
    fi
}

prepare_redis() {
    echo "[+] preparing redis"
    make distclean
}

compile_redis() {
    make ${MAKEOPTS}
}

install_redis() {
    cp -avL src/redis-server "${ROOTDIR}/usr/bin/"
}

build_redis() {
    pushd "${WORKDIR}/redis-${REDIS_VERSION}"

    prepare_redis
    compile_redis
    install_redis

    popd
}

registrar_redis() {
    DOWNLOADERS+=(download_redis)
    EXTRACTORS+=(extract_redis)
}

registrar_redis
