#!/bin/bash
#
# Copyright (c) 2023, Intel Corporation. All rights reserved.<BR>
# SPDX-License-Identifier: Apache-2.0
#
set -e

CURR_DIR=$(readlink -f "$(dirname "$0")")
TDX_TOOLS_DIR=$(realpath "${CURR_DIR}/../tdx-tools")
ARTIFACTS_DIR=$(realpath "${CURR_DIR}/../artifacts")
UBUNTU_ISO_DIR="${ARTIFACTS_DIR}/ubuntu-iso"
UBUNTU_ISO_FILENAME="jammy-server-cloudimg-amd64.img"
RELEASE="2023ww30"
REPO_LOCAL="/srv/artifacts"
OFFICIAL_UBUNTU_IMAGE="https://cloud-images.ubuntu.com/jammy/current/"
DCAP_REPO_URL="https://download.01.org/intel-sgx/sgx-dcap/1.17/linux/distro/ubuntu22.04-server/sgx_debian_local_repo.tgz"
DCAP_REPO_FILENAME="sgx_debian_local_repo.tgz"

TDX_MVP_VERSION_KERNEL="5.19.17-mvp25v4+0"
TDX_MVP_VERSION_QEMU="7.0.50+mvp11+21"
TDX_MVP_VERSION_LIBVIRT="8.6.0-2022.11.17.mvp1"
TDX_MVP_VERSION_OVMF="2023.03.07-stable202302.mvp9"
#TDX_MVP_VERSION_MODULE="1.0.03.03-mvp30"

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

check_tool() {
    [[ "$(command -v $1)" ]] || { error "$1 is not installed" 1>&2 ; }
}

pre_check() {
    info "Check msr-tools..."
    if [[ ! "$(command -v rdmsr)" ]]; then
        sudo apt install msr-tools
        ok "Install msr-tools for rdmsr"
    fi

    info "Check whether TDX is enabled in BIOS..."
    retval=$(sudo rdmsr -f 11:11 0x1401)
    if [[ "$retval" == 1 ]]; then
        ok "TDX is enabled on the host"
    else
        error "TDX is not enabled on the host. Please run ${TDX_TOOLS_DIR}/utils/check-tdx-host.sh for more information"
    fi

    info "Check whether TDX kernel is installed on the host..."
    kernel_str=$(uname -a)
    if [[ ${kernel_str} != *"${TDX_MVP_VERSION_KERNEL}"* ]]; then
        error "Kernel is the version ${TDX_MVP_VERSION_KERNEL} from TDX release $RELEASE..."
    fi
    ok "TDX kernel is installed at version ${TDX_MVP_VERSION_KERNEL} from TDX release $RELEASE."

    info "Check whether TDX qemu is installed on the host..."
    qemu_str=$(apt list --installed | grep qemu)
    if [[ ${qemu_str} != *"${TDX_MVP_VERSION_QEMU}"* ]]; then
        error "qemu is the version ${TDX_MVP_VERSION_QEMU} from TDX release $RELEASE..."
    fi
    ok "TDX qemu is installed at version ${TDX_MVP_VERSION_QEMU} from TDX release $RELEASE."

    info "Check whether TDX libvirt is installed on the host..."
    libvirt_str=$(apt list --installed | grep libvirt)
    if [[ ${libvirt_str} != *"${TDX_MVP_VERSION_LIBVIRT}"* ]]; then
        error "libvirt is the version ${TDX_MVP_VERSION_LIBVIRT} from TDX release $RELEASE..."
    fi
    ok "TDX libvirt is installed at version ${TDX_MVP_VERSION_LIBVIRT} from TDX release $RELEASE."

    info "Check whether TDX OVMF is installed on the host..."
    ovmf_str=$(apt list --installed | grep ovmf)
    if [[ ${ovmf_str} != *"${TDX_MVP_VERSION_OVMF}"* ]]; then
        error "TDX ovmf is the version ${TDX_MVP_VERSION_OVMF} from TDX release $RELEASE..."
    fi
    ok "TDX ovmf is installed at version ${TDX_MVP_VERSION_OVMF} from TDX release $RELEASE."

    info "Check whether TDX OVMF is installed on the host..."
    seam_str=$(apt list --installed | grep seam-module)
    if [[ ${seam_str} != *"${TDX_MVP_VERSION_MODULE}"* ]]; then
        error "TDX module is the version ${TDX_MVP_VERSION_MODULE} from TDX release $RELEASE..."
    fi
    ok "TDX module is installed at version ${TDX_MVP_VERSION_MODULE} from TDX release $RELEASE."
}

download_artifacts() {
    if [[ ${1} == "-r" ]]; then
        info "Reinitialize the environment..."
        rm ${ARTIFACTS_DIR} -fr
        mkdir -o ${ARTIFACTS_DIR}
    fi

    if [[ ! -d ${ARTIFACTS_DIR} ]]; then
        mkdir -p ${ARTIFACTS_DIR}
    fi

    pushd ${ARTIFACTS_DIR}

    info "Download TDX MVP Release packages..."
    if [[ ! -f "${REPO_LOCAL}/${RELEASE}.tar.gz" ]]; then
	error "${REPO_LOCAL}/${RELEASE}.tar.gz does not exist"
    fi
    if [[ ! -f "${RELEASE}.tar.gz" ]]; then
	cp ${REPO_LOCAL}/${RELEASE}.tar.gz .
        ok "Copy TDX stack repo file..."
        tar zxvf ${RELEASE}.tar.gz
        ok "Extract TDX stack repo file..."
    else
        ok "TDX stack release is already at ${ARTIFACTS_DIR}/${RELEASE}/"
    fi

    info "Download DCAP packages..."
    pushd ${RELEASE}/mvp-tdx-stack-guest-ubuntu-22.04/jammy/
    if [[ ! -f ${DCAP_REPO_FILENAME} ]]; then
        wget --show-progress -O ${DCAP_REPO_FILENAME} ${DCAP_REPO_URL}
        tar xf sgx_debian_local_repo.tgz
    fi
    popd

    popd
}

download_ubuntu_iso_image() {
    info "Download Ubuntu official ISO images..."

    # Get the checksum file first
    mkdir -p ${UBUNTU_ISO_DIR}

    pushd ${UBUNTU_ISO_DIR}

    if [[ -f "SHA256SUMS" ]]; then
        rm "SHA256SUMS"
    fi

    wget "${OFFICIAL_UBUNTU_IMAGE}/SHA256SUMS"

    while :; do
        # Download the cloud image if not exists
        if [[ ! -f ${UBUNTU_ISO_FILENAME} ]]; then
            wget -O ${UBUNTU_ISO_FILENAME} ${OFFICIAL_UBUNTU_IMAGE}/${UBUNTU_ISO_FILENAME}
        fi

        # calculate the checksum
        download_sum=$(sha256sum ${UBUNTU_ISO_FILENAME} | awk '{print $1}')
        found=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" == *"$UBUNTU_ISO_FILENAME"* ]]; then
                if [[ "${line%% *}" != ${download_sum} ]]; then
                    echo "Invalid download file according to sha256sum, re-download"
                    rm ${UBUNTU_ISO_FILENAME}
                else
                    ok "Verify the checksum for Ubuntu cloud image."
                    ok "Ubuntu ISO image is ready at ${UBUNTU_ISO_DIR}/${UBUNTU_ISO_FILENAME}"
                    popd
                    return
                fi
                found=true
            fi
        done <"SHA256SUMS"
        if [[ $found != "true" ]]; then
            echo "Invalid SHA256SUM file"
            exit 1
        fi
    done
    popd
}

#pre_check
download_artifacts
download_ubuntu_iso_image
