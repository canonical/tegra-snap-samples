# TensorRT Libs Snap

This snap includes the `tensorrt` and `cuda-13-2` packages and provides the 
`tensorrt-libs-cuda-13` content interface that other snaps can plug into. The 
snaps that plug into this content interface should provide a 
`tensorrt-libs-wrapper` script that calls the `tensorrt-libs-provider-wrapper` 
script from this snap in order to set up the `$LD_LIBRARY_PATH`. This should
be in `$SNAP/tensorrt-libs/bin/tensorrt-libs-provider-wrapper`.

The `tensorrt` package is installed with a specific version which requires also
defining all its dependencies with the accurate versions. This is because
the tensorrt libraries need to be aligned with the installed drivers but they
move independently.
