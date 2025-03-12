# tegra-snap-samples

This repository contains several different sample snap definitions that can be used to build different application snaps to run GPU workloads on Nvidia Tegra platforms.

Each sample snap directory contains another README file going into further detail on what the snap contains and how it can be built and run.
In general, each snap can be built by simply navigating to its directory and executing `snapcraft`. For example:
```
cd nvidia-tegra-runtime
snapcraft -v
```

The snaps should be built on an arm64 host as this is the architecture of the Tegra platforms and cross-building snaps is not yet well supported.

# [nvidia-tegra-runtime](nvidia-tegra-runtime)

Tegra runtime and cuda support libraries provided by the L4T packages from the [Nvidia’s archive](https://repo.download.nvidia.com/jetson).

# [tensorrt-libs](tensorrt-libs)

Contains TensorRT and cuda runtime libraries and exposes a content interface that other snaps can plug into in order to access them.

# [cuda-samples](cuda-samples)

Packages software coming from Nvidia's [cuda-samples repository](https://github.com/NVIDIA/cuda-samples/).

# [tensorrt-samples](tensorrt-samples)

Packages software coming from Nvidia's TensorRT samples, contained in the `libnvinfer-samples` .deb package from [nvidia's software repository](https://repo.download.nvidia.com/jetson/).

# [cudnn-samples](cudnn-samples)

Packages software coming from the `libcudnn9-samples` .deb package from [nvidia's software repository](https://repo.download.nvidia.com/jetson/).

# [multimedia](multimedia)

Packages several camera and gstreamer utilities that can be used to access the camera or perform some transcoding workloads using hardware or software accelerators.

# [nvidia-container-runtime](nvidia-container-runtime/)

This directory contains supporting files needed in order to enable the nvidia container runtime for docker on Ubuntu Core.
