FIRMWARE_PKGNAME="linux-firmware"
FIRMWARE_VERSION="20191215"
FIRMWARE_CHECKSUM="0d019854c8a0b0e81514bc968d1a56c7"
FIRMWARE_LINK="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-${FIRMWARE_VERSION}.tar.gz"

download_firmware() {
    download_file $FIRMWARE_LINK $FIRMWARE_CHECKSUM
}

extract_firmware() {
    if [ ! -d "${FIRMWARE_PKGNAME}-${FIRMWARE_VERSION}" ]; then
        progress "extracting: ${FIRMWARE_PKGNAME}-${FIRMWARE_VERSION}"
        tar -xf ${DISTFILES}/${FIRMWARE_PKGNAME}-${FIRMWARE_VERSION}.tar.gz -C .
    fi
}

prepare_firmware() {
    progress "preparing: ${FIRMWARE_PKGNAME}"
    fcount=$(grep -E "^(File:|Link:)" WHENCE | wc -l)

    progress "building custom linux-firmware files list"

    # exclude rtiwifi driver
    exclude="rtlwifi"

    # include some network and scsi driver
    include="bnx2|brcm|cxgb|myri|mellanox|netronome|qat|qed|ql2|qlogic|rt|RTL|ti"

    # building a custom list of firmware
    grep -E "^(File:|Link:)" WHENCE | grep -v $exclude | grep -E "....: \"?($include)" > WHENCE.custom

    # replacing original list with our custom list
    cp WHENCE WHENCE.original
    cp WHENCE.custom WHENCE

    ccount=$(grep -E "^(File:|Link:)" WHENCE | wc -l)

    progress "original firmware found: ${fcount} files"
    progress "filtered firmware kept: ${ccount} files"
}


install_firmware() {
    progress "installing custom linux-firmware"

    # using original copy-firmware script but with our
    # custom WHENCE file modified
    destdir="${ROOTDIR}/lib/firmware" ./copy-firmware.sh -v

    # restore original file
    mv WHENCE.original WHENCE
}

build_firmware() {
    pushd "${WORKDIR}/${FIRMWARE_PKGNAME}-${FIRMWARE_VERSION}"

    # not needed for arm, afaik
    return

    prepare_firmware
    install_firmware

    popd
}

registrar_firmware() {
    DOWNLOADERS+=(download_firmware)
    EXTRACTORS+=(extract_firmware)
}

registrar_firmware
