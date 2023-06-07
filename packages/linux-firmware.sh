FIRMWARE_VERSION="20230515"
FIRMWARE_CHECKSUM="fa8477de02a7c16ebf0ed599c6a03367"
FIRMWARE_LINK="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-${FIRMWARE_VERSION}.tar.gz"

download_firmware() {
    download_file $FIRMWARE_LINK $FIRMWARE_CHECKSUM
}

extract_firmware() {
    if [ ! -d "linux-firmware-${FIRMWARE_VERSION}" ]; then
        echo "[+] extracting: linux-firmware-${FIRMWARE_VERSION}"
        tar -xf ${DISTFILES}/linux-firmware-${FIRMWARE_VERSION}.tar.gz -C .
    fi
}

prepare_firmware() {
    echo "[+] preparing linux-firmware"
    fcount=$(grep -E "^(File:|Link:)" WHENCE | wc -l)

    echo "[+] building custom linux-firmware files list"

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

    echo "[+] original firmware found: ${fcount} files"
    echo "[+] filtered firmware kept: ${ccount} files"
}


install_firmware() {
    echo "[+] installing custom linux-firmware"

    # using original copy-firmware script but with our
    # custom WHENCE file modified
    destdir="${ROOTDIR}/lib/firmware" ./copy-firmware.sh -v

    # restore original file
    mv WHENCE.original WHENCE
}

build_firmware() {
    pushd "${WORKDIR}/linux-firmware-${FIRMWARE_VERSION}"

    prepare_firmware
    install_firmware

    popd
}

registrar_firmware() {
    DOWNLOADERS+=(download_firmware)
    EXTRACTORS+=(extract_firmware)
}

registrar_firmware
