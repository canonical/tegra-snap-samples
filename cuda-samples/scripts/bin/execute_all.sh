#! /usr/bin/bash

set -e

CUDA_SAMPLES=$(cat $SNAP/etc/cuda-samples.list)

for s in $CUDA_SAMPLES
do
	$SNAP/bin/execute_from_target_dir.sh $s
done
