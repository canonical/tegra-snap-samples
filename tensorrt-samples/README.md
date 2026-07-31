# TensorRT Samples

This snap packages software coming from Nvidia's 
[TensorRT samples](https://github.com/NVIDIA/TensorRT.git).

For compilation, we need to include the packages `cuda-13-2` which contains the
cuda toolkit and runtime libraries.

In order for this snap to work, we need the same interfaces as the
[cuda-samples snap](../cuda-samples/). The
gpu-2404 interface should be provided by the [nvidia-tegra-runtime
snap](../nvidia-tegra-runtime/). The
tensorrt-libs-cuda-13 interface will be provided by the [tensorrt-libs
snap](../tensorrt-libs/) and contains the
necessary cuda and tensorrt runtime libraries.

The `$LD_LIBRARY_PATH` variable will be properly set up using the wrapper
script which will call the tensorrt-libs snap's provider-wrapper.

We build the samples by running cmake from a build directory inside the 
samples' sources and then run `cmake --build` and then only copy the
tensorrt-samples' sources plus the binaries into the final snap. Some samples
require write permissions in the directory they are being executed from, so we
include an install hook that copies the whole directory into `$SNAP_DATA`. The
samples are then executed using a wrapper script that takes the name of a
sample as an argument, directly from the `$SNAP_DATA` directory. A list of
samples can be found in [tensorrt\_samples.txt](tensorrt-samples-list/tensorrt-samples.list).

# Build, Install and Run Samples
In order for the snap to work, you must first install the
[nvidia-tegra-runtime
snap](../nvidia-tegra-runtime/) and the
[tensorrt-libs snap](../tensorrt-libs/).
Afterwards, build this snap by calling `snapcraft` from the root directory and
install it using the `--dangerous` flag. Then connect the interfaces:

```
$ snapcraft
$ sudo snap install --dangerous tensorrt-samples_10.3.0.30-1+cuda12.5_arm64.snap

$ sudo snap connect tensorrt-samples:gpu-2404 nvidia-tegra-runtime:gpu-2404
$ sudo snap connect tensorrt-samples:tensorrt-libs-cuda-13 tensorrt-libs:tensorrt-libs-cuda-13
$ sudo snap connect tensorrt-samples:hardware-observe
$ sudo snap connect tensorrt-samples:microstack-support
$ sudo snap connect tensorrt-samples:network-bind
```

A given sample can be executed with:
```
sudo snap run tensorrt-samples.tensorrt-samples <sample_name>
```
and replacing <sample_name> with any sample from the list.

Most commands can be executed without sudo if the user is a member of the video
and render groups. Some commands however require write access in some files,
therefore those might need to be executed with `sudo`.
