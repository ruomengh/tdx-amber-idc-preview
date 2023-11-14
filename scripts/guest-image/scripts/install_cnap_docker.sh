#!/bin/sh

set -e

IMAGE_REGISTRY="cnap"
IMGAE_TAG="latest"

configure_kernel() {
    tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
    modprobe overlay
    modprobe br_netfilter
}

containerd_docker_proxy() {
    # config proxy
    HTTPS_PROXY=$(echo $HTTPS_PROXY)
    if [ -z $HTTPS_PROXY ]; then
        HTTPS_PROXY=$(echo $https_proxy)
    fi

    HTTP_PROXY=$(echo $HTTP_PROXY)
    if [ -z $HTTP_PROXY ]; then
        HTTP_PROXY=$(echo $http_proxy)
    fi

    NO_PROXY=$(echo $NO_PROXY)
    if [ -z $NO_PROXY ]; then
        NO_PROXY=$(echo $no_proxy)
    fi

    mkdir -p /etc/systemd/system/containerd.service.d/
    tee /etc/systemd/system/containerd.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTPS_PROXY}"
Environment="NO_PROXY=${NO_PROXY}"
EOF

    mkdir -p /etc/systemd/system/docker.service.d/
    tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTPS_PROXY}"
Environment="NO_PROXY=${NO_PROXY}"
EOF
}

configure_container() {
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
    systemctl daemon-reload
    systemctl restart containerd
    systemctl enable containerd
    systemctl restart docker
    systemctl enable docker
}

build_cnap_images() {
    git clone -b demo https://github.com/intel/cloud-native-ai-pipeline.git
    cd cloud-native-ai-pipeline
    ./tools/docker_image_manager.sh -a build -r ${IMAGE_REGISTRY} -g ${IMGAE_TAG} -c cnap-streaming
    ./tools/docker_image_manager.sh -a build -r ${IMAGE_REGISTRY} -g ${IMGAE_TAG} -c cnap-inference
}

pull_redis_offical_image() {
    docker pull redis:7.0
}

# export env var
while read env_var; do
    export "$env_var"
done < /etc/environment

configure_kernel
containerd_docker_proxy
configure_container
build_cnap_images
pull_redis_offical_image
