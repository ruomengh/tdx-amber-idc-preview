#!/bin/bash

DIR='/root/example_ai_workload'

apt install -y python3-pip

mkdir -p $DIR

cd $DIR

wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v1_8/mobilenet_v1_1.0_224_frozen.pb

git clone https://github.com/IntelAI/models.git

