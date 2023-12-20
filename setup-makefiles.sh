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

# Initialize the helper for common
setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${ANDROID_ROOT}" true

# Warning headers and guards
write_headers "grus pyxis sirius vela"

# The standard common blobs
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# FM radio blobs
printf "\n%s\n" "ifeq (\$(BOARD_HAVE_QCOM_FM),true)" >> "$PRODUCTMK"
write_makefiles "$MY_DIR"/proprietary-files-fm.txt true
echo "endif" >> "$PRODUCTMK"

# NFC blobs
printf "\n%s\n" "ifeq (\$(TARGET_HAS_NFC),true)" >> "$PRODUCTMK"
write_makefiles "$MY_DIR"/proprietary-files-nfc.txt true
echo "endif" >> "$PRODUCTMK"

# Finish
write_footers

if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" -o \
     -s "${MY_DIR}/../${DEVICE}/proprietary-firmware.txt" ]; then
    # Reinitialize the helper for device
    setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

    # Warning headers and guards
    write_headers

    # The standard device blobs
    test -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" &&
        write_makefiles "${MY_DIR}/../${DEVICE}/proprietary-files.txt" true

    # The firmware blobs
    test -s "${MY_DIR}/../${DEVICE}/proprietary-firmware.txt" &&
        append_firmware_calls_to_makefiles

    # Finish
    write_footers
fi
