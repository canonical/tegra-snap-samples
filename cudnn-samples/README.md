# cuDNN samples

This snap packages software coming from the `libcudnn9-samples` .deb package from [nvidia's sbsa software repository](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa).

For compilation, we need cuda and cudnn libraries. We stage the `nvidia-l4t-cuda` L4T package directly and implement the `tensorrt-libs-cuda-13` content interface provided by the [tensorrt-libs snap](../tensorrt-libs/) for the necessary cuda and tensorrt runtime libraries. The missing hardware-specific cuda libraries are provided by the [nvidia-tegra-runtime snap](../nvidia-tegra-runtime/). We also need to plug into the hardware-observe, microstack-support, network-bind and opengl interfaces for the necessary hardware access.

In this snap, we package the 4 cuDNN samples `conv_sample`, `mnistCUDNN`, `RNN_v8.0` and multiHeadAttention. The samples are built by navigating to the respective directories in `$CRAFT_PART_INSTALL/usr/src/cudnn_samples_v9` and running `cmake` and `cmake --build`. In the `multiHeadAttention` sample, we need to make some additional changes to the sources in order to execute the samples correctly.

The `attn_ref.py` file will be executed with the `python` binary which isn't available in the build environment, so we run it with `python3` instead. We also need to cast `np.shape(w)[0]` to an integer inside the `attn_ref.py` file.

We use an install and a post-refresh hook to copy the `cudnn_samples_v9` directory from inside the snap to the snap's `$SNAP_DATA` directories. This is necessary because some samples will need write access to execute correctly. As part of the build process, we will create symbolic links to the corresponding executables in the `$SNAP_DATA` directory. We also include a wrapper (`launchers/execute_from_target_dir.sh`) that will be part of the command-chain that follows the symlink to the location it points to in order to execute the sample from there.

# Build, Install and Run Samples

In order for the snap to work, you must first install the [tensorrt-libs snap](../tensorrt-libs/).
Afterwards, build this snap by calling `snapcraft` from the root directory and
install it using the `--dangerous` flag. Then connect the interfaces:

```
$ snapcraft
$ sudo snap install --dangerous cudnn-samples_1.0_arm64.snap

$ sudo snap connect cudnn-samples:hardware-observe
$ sudo snap connect cudnn-samples:microstack-support
$ sudo snap connect cudnn-samples:network-bind
$ sudo snap connect cudnn-samples:tensorrt-libs-cuda-13 tensorrt-libs:tensorrt-libs-cuda-13
$ sudo snap connect cudnn-samples:gpu-2404 nvidia-tegra-runtime:gpu-2404
```

You can find a list of commands to execute by running the following:
```
$ snap info cudnn-samples
```

It shouldn show something like the following:
```
...
commands:
  - cudnn-samples.conv-sample
  - cudnn-samples.mnist-cudnn-sample
  - cudnn-samples.multi-head-attention-sample
  - cudnn-samples.rnn-sample
...
```

Make sure to run the commands with `sudo` like this:
```
sudo snap run cudnn-samples.conv-sample
```
