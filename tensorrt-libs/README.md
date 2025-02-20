# TensorRT Libs Snap

This snap includes the `libnvinfer-bin` and `libnvinfer-samples` .deb packages
and provides the `tensorrt-libs-cuda-12` content interface that other snaps
can plug into. The snaps that plug into this content interface should provide a
`tensorrt-libs-wrapper` script that calls the `tensorrt-libs-provider-wrapper`
script from this snap in order to set up the `$LD_LIBRARY_PATH`.  This should
be in `$SNAP/tensorrt-libs/bin/tensorrt-libs-provider-wrapper`.
