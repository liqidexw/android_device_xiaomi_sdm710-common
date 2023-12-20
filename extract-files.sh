#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The mokeeOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup() {
    case "${1}" in
        vendor/lib*/sensors.ssc.so)
            ${PATCHELF} --remove-needed vendor.qti.hardware.display.mapper@2.0.so "${2}"
            ${PATCHELF} --remove-needed vendor.qti.hardware.display.mapper@3.0.so "${2}"
            ;& # Pass-through
        vendor/bin/sensors.qti) ;&
        vendor/lib/camera/components/com.qti.node.eisv2.so) ;&
        vendor/lib/camera/components/com.qti.node.eisv3.so) ;&
        vendor/lib/camera/components/com.qti.stats.aecwrapper.so) ;&
        vendor/lib/camera/components/com.vidhance.node.eis.so) ;&
        vendor/lib/hw/camera.qcom.so) ;&
        vendor/lib/hw/com.qti.chi.override.so) ;&
        vendor/lib/libcamera_nn_stub.so) ;&
        vendor/lib/libsensorcal.so) ;&
        vendor/lib/libsnsapi.so) ;&
        vendor/lib/libsnsdiaglog.so) ;&
        vendor/lib/libssc.so) ;&
        vendor/lib/libswregistrationalgo.so) ;&
        vendor/lib64/libsensorcal.so) ;&
        vendor/lib64/libsnsdiaglog.so) ;&
        vendor/lib64/libssc.so) ;&
        vendor/lib64/sensors.ssc.so)
            ${PATCHELF} --replace-needed "libprotobuf-cpp-full.so" "libprotobuf-cpp-full-v29.so" "${2}"
            ;;
        vendor/lib64/libwvhidl.so) ;&
        vendor/lib64/mediadrm/libwvdrmengine.so)
            ${PATCHELF} --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
    esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                if [ -z "${SRC}" ]; then
                    SRC="${1}"
                else
                    RADIO_SRC="${1}"
                fi
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    extract "${MY_DIR}/proprietary-files-fm.txt" "${SRC}" "${KANG}" --section "${SECTION}"
    extract "${MY_DIR}/proprietary-files-nfc.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -n "$RADIO_SRC" -a -s "${MY_DIR}/../${DEVICE}/proprietary-firmware.txt" ]; then
    extract_firmware "${MY_DIR}/../${DEVICE}/proprietary-firmware.txt" "${RADIO_SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"
