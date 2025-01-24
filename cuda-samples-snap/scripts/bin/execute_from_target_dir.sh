#! /usr/bin/bash

set -e

CMD=$SNAP/usr/bin/$1
TARGET=$(readlink -f $CMD)
TARGET_DIR=$(dirname $TARGET)

cd $TARGET_DIR
$(basename $CMD)
