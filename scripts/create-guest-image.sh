#!/bin/bash
#
# Copyright (c) 2023, Intel Corporation. All rights reserved.<BR>
# SPDX-License-Identifier: Apache-2.0
#

set -e

CURR_DIR=$(readlink -f "$(dirname "$0")")
TDX_TOOLS_DIR=$(realpath "${CURR_DIR}/../tdx-tools")
GUEST_IMAGE_TOOL_DIR="${CURR_DIR}/guest-image"
ARTIFACTS_DIR=$(realpath "${CURR_DIR}/../artifacts")
UBUNTU_ISO_DIR="${ARTIFACTS_DIR}/ubuntu-iso"
UBUNTU_ISO_FILENAME="jammy-server-cloudimg-amd64.img"
RELEASE="2023ww44"
OFFICIAL_UBUNTU_IMAGE="https://cloud-images.ubuntu.com/jammy/current/"
GUEST_IMG="tdx-guest.qcow2"
GUEST_HOSTNAME="tdx-guest"
GUEST_USER="tdx"
GUEST_PASSWORD=""
SIZE=20

info() {
    echo -e "\e[1;33mINFO: $*\e[0;0m"
}

ok() {
    echo -e "\e[1;32mSUCCESS: $*\e[0;0m"
}

error() {
    echo -e "\e[1;31mERROR: $*\e[0;0m"
    exit 1
}

warn() {
    echo -e "\e[1;33mWARN: $*\e[0;0m"
}

usage() {
    cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h                        Show this help
  -f                        Force to recreate the output image
  -n                        Guest host name, default is "tdx-guest"
  -u                        Guest user name, default is "tdx"
  -p                        Guest password, must provide from command line
  -s                        Specify the size of guest image
  -o <output file>          Specify the output file, default is td-guest.qcow2.
                            Please make sure the suffix is qcow2. Due to permission consideration,
                            the output file will be put into /tmp/<output file>.
EOM
}

process_args() {
    while getopts "o:s:n:u:p:fh" option; do
        case "$option" in
        o) GUEST_IMG=$OPTARG ;;
        s) SIZE=$OPTARG ;;
        n) GUEST_HOSTNAME=$OPTARG ;;
        u) GUEST_USER=$OPTARG ;;
        p) GUEST_PASSWORD=$OPTARG ;;
        f) FORCE_RECREATE=true ;;
        h)
            usage
            exit 0
            ;;
        *)
            echo "Invalid option '-$OPTARG'"
            usage
            exit 1
            ;;
        esac
    done

    if [[ -f "${GUEST_IMG}" ]]; then
        if [[ ${FORCE_RECREATE} != "true" ]]; then
            error "Guest image ${GUEST_IMG} already exist, please specify -f if want force to recreate"
        fi
    fi

    if [[ ${GUEST_IMG} != *.qcow2 ]]; then
        error "The output file should be qcow2 format with the suffix .qcow2."
    fi

    if [[ -z ${GUEST_PASSWORD} ]]; then
        error "Please specify the guest password."
    fi
}

pre_check() {
    if [[ ! -d ${ARTIFACTS_DIR}/${RELEASE} ]]; then
        error "Please run ./init.sh firstly to download software stack."
    fi

    if [[ ! -f ${UBUNTU_ISO_DIR}/${UBUNTU_ISO_FILENAME} ]]; then
        error "Please run ./init.sh firstly to download Ubuntu ISO image."
    fi

    if [[ ! "$(command -v virt-customize)" ]]; then
        error "virt-customize is not installed, please run 'sudo apt install libguestfs-tools'"
    fi

    if [[ ! "$(command -v virt-install)" ]]; then
        error "virt-customize is not installed, please run 'sudo apt install virtinst'"
    fi

    if [[ ! "$(command -v genisoimage)" ]]; then
        error "virt-customize is not installed, please run 'sudo apt install genisoimage'"
    fi
}

process_args "$@"
pre_check

sudo ${GUEST_IMAGE_TOOL_DIR}/create-ubuntu-image.sh \
    -i ${UBUNTU_ISO_DIR}/${UBUNTU_ISO_FILENAME} \
    -n ${GUEST_HOSTNAME} \
    -u ${GUEST_USER} \
    -p ${GUEST_PASSWORD} \
    -r "${ARTIFACTS_DIR}/${RELEASE}/mvp-tdx-stack-guest-ubuntu-22.04/jammy/" \
    -o ${GUEST_IMG} \
    -s ${SIZE} \
    -f

cp /tmp/${GUEST_IMG} ${CURR_DIR}/
ok "Copy /tmp/${GUEST_IMG} => ${CURR_DIR}/${GUEST_IMG}"
