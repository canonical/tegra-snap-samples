# Cuda Samples

This snap packages software coming from Nvidia's [cuda-samples
repository](https://github.com/NVIDIA/cuda-samples/)

It depends on the cuda toolkit for compilation and the tensorrt-libs-cuda-12
content interface from the [tensorrt-libs
snap](https://github.com/canonical/tensorrt-libs-snap/) to access the cuda and
tensorrt runtime libraries. It is also dependent on the graphics-core22
interface from the [nvidia-tegra-runtime
snap](https://github.com/canonical/nvidia-tegra-runtime-snap).

The graphics-core22 interface for now only provides access to several runtime
libraries necessary to communicate with the GPU but not other graphics
libraries (X11, Wayland, OpenGL etc.).  So inside this snap we execute the
`graphics-core22-wrapper` which will call the
`graphics-core22-provider-wrapper` from the driver snap which will set up our
library paths to the proper values for our applications to function. This needs
to then be included in the command chain before calling the actual command.

In order for strict confinement to work, we need the hardware-observe and
opengl interfaces. There is one cuda sample that requires a special device node
that we give access to using the system-files interface.

The samples are built using the Makefile from the root directory of the
cuda-samples sources. Some samples will require write permissions in the
working directory they are being executed from. Therefore we use an install and
post-refresh hook to copy the compiled sources plus the data into the
`$SNAP_DATA` directory which allows for read and write operations. In the build
step we search for all executable samples and create appropriate symbolic links
from the `$SNAP/usr/bin` directory to the destination in `$SNAP_DATA`. The
wrapper script that is used to execute the samples takes the name of a sample
as an argument and will first follow the symlink into `$SNAP_DATA` before
executing the specified sample.

# Build, Install and Run Samples
In order for the snap to work, you must first install the
[nvidia-tegra-runtime
snap](https://github.com/canonical/nvidia-tegra-runtime-snap) and the
[tensorrt-libs snap](https://github.com/canonical/tensorrt-libs-snap/).
Afterwards, build this snap by calling `snapcraft` from the root directory and
install it using the `--dangerous` flag. Then connect the interfaces:

```
$ snapcraft
$ sudo snap install --dangerous ./cuda-samples_12.6_arm64.snap
$
$ sudo snap connect cuda-samples:graphics-core22 nvidia-tegra-runtime:graphics-core22
$ sudo snap connect cuda-samples:tensorrt-libs-cuda-12 cuda-runtime:tensorrt-libs-cuda-12
$ sudo snap connect cuda-samples:system-files
$ sudo snap connect cuda-samples:hardware-observe
```

A list of all sample commands can be found in
[cuda-samples.list](cuda-samples-list/cuda-samples.list).

A given sample can be executed with:
```
sudo snap run cuda-samples.cuda-samples <sample_name>
```
and replacing <sample_name> with any sample from the list.

Most commands can be run without `sudo` if the user is part of the `render` and
`video` groups. Some samples however will need write permission on some input
files which are owned by `root` inside the snap, for example
`batchedLabelMarkersAndLabelCompressionNPP`. These need to be run with `sudo`.

In order to execute all available cuda samples at once, this can be done with:
```
sudo snap run cuda-samples.all
```
