#! /usr/bin/bash

set -e

CMD=$SNAP/usr/bin/$1
TARGET=$(readlink -f $CMD)
TARGET_DIR=$(dirname $TARGET)

export LD_LIBRARY_PATH=$SNAP/graphics/opt/nvidia/l4t-gpu-libs/openrm:$LD_LIBRARY_PATH

cd $TARGET_DIR
$(basename $CMD)
