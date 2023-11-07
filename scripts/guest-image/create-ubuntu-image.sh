#!/bin/bash
#
# Copyright (c) 2023, Intel Corporation. All rights reserved.<BR>
# SPDX-License-Identifier: Apache-2.0
#

#
# Create a Ubuntu EFI cloud TDX guest image. It can run on any Linux system with
# required tool installed like qemu-img, virt-customize, virt-install, etc. It is
# not required to run on a TDX capable system.
#

CURR_DIR=$(dirname "$(realpath $0)")
USE_OFFICIAL_IMAGE=true
FORCE_RECREATE=false
OFFICIAL_UBUNTU_IMAGE="https://cloud-images.ubuntu.com/jammy/current/"
CLOUD_IMG="jammy-server-cloudimg-amd64.img"
GUEST_IMG="tdx-guest-ubuntu-22.04.qcow2"
SIZE=20
GUEST_USER="tdx"
GUEST_PASSWORD="123456"
GUEST_HOSTNAME="tdx-guest"
GUEST_REPO=""
LOCAL_UBUNTU_ISO_PATH=""
AI_WORKLOAD=false

ok() {
    echo -e "\e[1;32mSUCCESS: $*\e[0;0m"
}

error() {
    echo -e "\e[1;31mERROR: $*\e[0;0m"
    cleanup
    exit 1
}

warn() {
    echo -e "\e[1;33mWARN: $*\e[0;0m"
}

check_tool() {
    [[ "$(command -v $1)" ]] || { error "$1 is not installed" 1>&2 ; }
}

usage() {
    cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h                        Show this help
  -c                        Create customize image (not from Ubuntu official cloud image)
  -f                        Force to recreate the output image
  -n                        Guest host name, default is "tdx-guest"
  -u                        Guest user name, default is "tdx"
  -p                        Guest password, default is "123456"
  -s                        Specify the size of guest image
  -o <output file>          Specify the output file, default is tdx-guest-ubuntu-22.04.qcow2.
                            Please make sure the suffix is qcow2. Due to permission consideration,
                            the output file will be put into /tmp/<output file>.
  -r <guest repo>           Specify the directory including guest packages, generated by build-repo.sh
  -a			    Install amx & cnap demo
EOM
}

process_args() {
    while getopts "o:s:n:u:p:r:i:fcha" option; do
        case "$option" in
        o) GUEST_IMG=$OPTARG ;;
        s) SIZE=$OPTARG ;;
        i) LOCAL_UBUNTU_ISO_PATH=$OPTARG ;;
        n) GUEST_HOSTNAME=$OPTARG ;;
        u) GUEST_USER=$OPTARG ;;
        p) GUEST_PASSWORD=$OPTARG ;;
        r) GUEST_REPO=$OPTARG ;;
        f) FORCE_RECREATE=true ;;
        c) USE_OFFICIAL_IMAGE=false ;;
	a) AI_WORKLOAD=true ;;
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

    if [[ "${CLOUD_IMG}" == "${GUEST_IMG}" ]]; then
        error "Please specify a different name for guest image via -o"
    fi

    if [[ -f "${GUEST_IMG}" ]]; then
        if [[ ${FORCE_RECREATE} != "true" ]]; then
            error "Guest image ${GUEST_IMG} already exist, please specify -f if want force to recreate"
        fi
    fi

    if [[ -z ${GUEST_REPO} ]]; then
        error "No guest repository provided, skip to install TDX packages..."
    else
        if [[ ! -d ${GUEST_REPO} ]]; then
            error "The guest repo directory ${GUEST_REPO} does not exists..."
        fi
    fi

    if [[ ${GUEST_IMG} != *.qcow2 ]]; then
        error "The output file should be qcow2 format with the suffix .qcow2."
    fi
    
}

download_image() {
    # Get the checksum file first
    if [[ -f ${CURR_DIR}/"SHA256SUMS" ]]; then
        rm ${CURR_DIR}/"SHA256SUMS"
    fi

    wget "${OFFICIAL_UBUNTU_IMAGE}/SHA256SUMS"

    while :; do
        # Download the cloud image if not exists
        if [[ ! -f ${CLOUD_IMG} ]]; then
            wget -O ${CURR_DIR}/${CLOUD_IMG} ${OFFICIAL_UBUNTU_IMAGE}/${CLOUD_IMG}
        fi

        # calculate the checksum
        download_sum=$(sha256sum ${CURR_DIR}/${CLOUD_IMG} | awk '{print $1}')
        found=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" == *"$CLOUD_IMG"* ]]; then
                if [[ "${line%% *}" != ${download_sum} ]]; then
                    echo "Invalid download file according to sha256sum, re-download"
                    rm ${CURR_DIR}/${CLOUD_IMG}
                else
                    ok "Verify the checksum for Ubuntu cloud image."
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
}

create_guest_image() {
    if [ ${USE_OFFICIAL_IMAGE} != "true" ]; then
        echo "Only support download the image from ${OFFICIAL_UBUNTU_IMAGE}"
        exit 1
    fi

    if [[ -z ${LOCAL_UBUNTU_ISO_PATH} ]]; then
        download_image

        cp ${CURR_DIR}/${CLOUD_IMG} /tmp/${GUEST_IMG}
        ok "Copy the ${CLOUD_IMG} => /tmp/${GUEST_IMG}"
    else
        cp ${LOCAL_UBUNTU_ISO_PATH} /tmp/${GUEST_IMG}
        ok "Copy the ${LOCAL_UBUNTU_ISO_PATH} => /tmp/${GUEST_IMG}"
    fi
}

config_guest_env() {
    virt-customize -a /tmp/${GUEST_IMG} \
        --copy-in /etc/environment:/etc
    ok "Copy host's environment file to guest for http_proxy"
}

resize_guest_image() {
    qemu-img resize /tmp/${GUEST_IMG} +${SIZE}G
    virt-customize -a /tmp/${GUEST_IMG} \
        --run-command 'growpart /dev/sda 1' \
        --run-command 'resize2fs /dev/sda1' \
        --run-command 'systemctl mask pollinate.service'
    ok "Resize the guest image to ${SIZE}G"
}

config_cloud_init() {
    pushd ${CURR_DIR}/cloud-init-data
    [ -e /tmp/ciiso.iso ] && rm /tmp/ciiso.iso
    cp user-data.template user-data.yaml
    cp meta-data.template meta-data

    # configure the user-data
    cat <<EOT >> user-data.yaml

user: $GUEST_USER
password: $GUEST_PASSWORD
chpasswd: { expire: False }
EOT
    CLDARGS=' -a user-data.yaml:cloud-config '
    if [[ ${AI_WORKLOAD} == "true"  ]]; then
    	CLDARGS+=' -a ../scripts/install_cnap_docker.sh:x-shellscript '
    fi

    cloud-init devel make-mime $CLDARGS > user-data

    # configure the meta-dta
    cat <<EOT >> meta-data

local-hostname: $GUEST_HOSTNAME
EOT

    ok "Generate configuration for cloud-init..."
    genisoimage -output /tmp/ciiso.iso -volid cidata -joliet -rock user-data meta-data
    ok "Generate the cloud-init ISO image..."
    popd

    virt-install --memory 4096 --vcpus 4 --name tdx-config-cloud-init \
        --disk /tmp/${GUEST_IMG} \
        --disk /tmp/ciiso.iso,device=cdrom \
        --os-type Linux \
        --os-variant ubuntu21.10 \
        --virt-type kvm \
        --graphics none \
        --import 
    ok "Complete cloud-init..."
    sleep 1

    virsh destroy tdx-config-cloud-init || true
    virsh undefine tdx-config-cloud-init || true
}

install_tdx_guest_packages() {
    if [[ -z ${GUEST_REPO} ]]; then
        return
    fi
    REPO_NAME=$(basename $(realpath ${GUEST_REPO}))
    virt-customize -a /tmp/${GUEST_IMG} \
        --run-command "mkdir -p /srv/guest_repo/" \
        --copy-in ${GUEST_REPO}/amd64/:/srv/guest_repo/ \
        --copy-in ${GUEST_REPO}/all/:/srv/guest_repo/ \
        --copy-in ${GUEST_REPO}/sgx_debian_local_repo/pool/main/libt/libtdx-attest/:/srv/guest_repo/ \
        --run-command "cd /srv/guest_repo/all && dpkg -i *.deb || true" \
        --run-command "cd /srv/guest_repo/amd64 && dpkg -i *.deb || true" \
        --run-command "cd /srv/guest_repo/libtdx-attest && dpkg -i *.deb || true" \
        --run-command "apt --fix-broken -y install"
    ok "Install the TDX guest packages into guest image..."
}

install_tdx_measure_tool() {
    virt-customize -a /tmp/${GUEST_IMG} \
        --run-command "python3 -m pip install pytdxmeasure"
    ok "Install the TDX measurement tool..."
}

install_ai_workload() {
    if [[ ${AI_WORKLOAD} == "true"  ]]; then
    	virt-customize -a /tmp/${GUEST_IMG} \
		--run ${CURR_DIR}/scripts/install_ai_workload.sh \
		--copy-in ${CURR_DIR}/scripts/run_ai_workload.sh:/root/example_ai_workload
    fi
}

install_cnap() {
    if [[ ${AI_WORKLOAD} == "true"  ]]; then
	virt-customize -a /tmp/${GUEST_IMG} \
		--run-command "mkdir -p /root/example_cnap" \
		--copy-in ${CURR_DIR}/scripts/run_cnap_docker.sh:/root/example_cnap \
		--copy-in ${CURR_DIR}/scripts/stop_cnap_docker.sh:/root/example_cnap
    fi
}

cleanup() {
    if [[ -f ${CURR_DIR}/"SHA256SUMS" ]]; then
        rm ${CURR_DIR}/"SHA256SUMS"
    fi
    ok "Cleanup!"
}

check_tool qemu-img
check_tool virt-customize
check_tool virt-install
check_tool genisoimage

process_args "$@"

#
# Check user permission
#
if (( $EUID != 0 )); then
    warn "Current user is not root, please use root permission via \"sudo\" or make sure current user has correct "\
         "permission by configuring /etc/libvirt/qemu.conf"
    warn "Please refer https://libvirt.org/drvqemu.html#posix-users-groups"
    sleep 5
fi

set -ex
create_guest_image
config_guest_env
resize_guest_image
config_cloud_init
install_tdx_guest_packages
install_tdx_measure_tool
install_ai_workload
install_cnap
cleanup

ok "Please get the output TDX guest image file at /tmp/${GUEST_IMG}"
