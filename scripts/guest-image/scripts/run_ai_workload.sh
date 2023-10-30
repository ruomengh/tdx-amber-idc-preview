#!/bin/bash

DIR='/root/example_ai_workload'
BENCH_DIR='models/benchmarks'

THREADS=16
AMX_DISABLE=false
WARMUP_STEPS=1000
STEPS=1500
BATCH_SIZE=1

usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
  -b <batch_size>	    The size of the batch, 1 default
  -t <thread_count>         The OMP thread count, 16 default
  -w <warmup_steps>	    The steps of the warmup, 1000 default
  -s <steps>		    The steps, 1500 default
  -d 			    Disable AMX
  -h                        Show this help
EOM
}
process_args() {
    while getopts ":b:t:w:s:dh" option; do
        case "$option" in
	    b) BATCH_SIZE=$OPTARG;;
            t) THREADS=$OPTARG;;
	    w) WARMUP_STEPS=$OPTARG;;
	    s) STEPS=$OPTARG;;
            d) AMX_DISABLE=true;;
            h) usage
               exit 0
               ;;
            *)
               echo "Invalid option '-$OPTARG'"
               usage
               exit 1
               ;;
        esac
    done
}

process_args "$@"

python3 -m pip install intel-tensorflow-avx512==2.11.0 numpy google-api-python-client tensorflow

pushd $DIR/$BENCH_DIR

if [[ $AMX_DISABLE == "true"  ]]; then
    export DNNL_MAX_CPU_ISA=AVX512_CORE
    echo "============"
    echo "AMX Disabled!"
    echo "============"
else	
    export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
    echo "============"
    echo "AMX Enabled!"
    echo "============"
fi
export OMP_NUM_THREADS=$THREADS
export KMP_AFFINITY=granularity=fine,verbose,compact

python3 launch_benchmark.py \
    --benchmark-only --framework tensorflow --model-name mobilenet_v1 \
    --mode inference --precision bfloat16 --batch-size $BATCH_SIZE \
    --in-graph /root/example_ai_workload/mobilenet_v1_1.0_224_frozen.pb \
    --num-intra-threads $THREADS --num-inter-threads 1 --verbose  input_height=224 input_width=224 warmup_steps=$WARMUP_STEPS steps=$STEPS input_layer='input' output_layer='MobilenetV1/Predictions/Reshape_1'

popd
