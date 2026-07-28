# Nvidia Container Runtime

This directory contains supporting files required by the nvidia container runtime for docker on Ubuntu Core.

Before running docker containers using the nvidia container runtime, we need to install the docker snap on Ubuntu Core. This snap already exists so we don't have to build it manually.

In order to use the docker snap, we need to pass runtime libraries and device nodes in the form of a "Container Device Interface" (CDI) specification whereas on a classic Ubuntu image we can use the CSV format.

We can generate the CDI specification by adapting the CSV files that are shipped with the nvidia-l4t-init .deb package from the [Nvidia package repository](https://repo.download.nvidia.com/jetson). The modification is done by simply changing the path of the files listed in `drivers.csv` to the path where it will be found inside the docker snap. The modified CSV files are contained in this directory. The CDI specification can then be generated from within the docker snap. The docker snap will only find the necessary runtime libraries to pass to the container runtime, when it is connected to the `graphics-core22` interface of the [nvidia-tegra-runtime snap](../nvidia-tegra-runtime) which needs to be built and installed before.

Install the docker snap and connect it to the `graphics-core22` interface:
```
$ sudo snap install docker
$ sudo snap connect docker:graphics-core22 nvidia-tegra-runtime:graphics-core22
```

If the nvidia container toolkit is installed on the host, a nvidia-cdi-refresh.service will also be present. This service should be disabled as it will generate an incompatible CDI spec in /var/run/cdi/nvidia.yaml which will have a higher priority than the one we will place in the docker snap's `$SNAP_DATA` directory.
```
$ sudo systemctl disable --now nvidia-cdi-refresh.service nvidia-cdi-refresh.path
$ sudo rm -f /run/cdi/nvidia.yaml
```

To generate the CDI specification, navigate to the directory containing the CSV files, spawn the shell environment of the docker snap and run the command. We also need to generate the runtime configuration for the docker daemon:
```
$ sudo snap run --shell docker -c 'nvidia-ctk cdi generate --mode=csv --format=yaml \
    --csv.file=./devices.csv,./drivers.csv \
    --output=$SNAP_DATA/etc/nvidia-container-runtime/cdi/nvidia.yaml'

$ sudo snap run --shell docker -c 'nvidia-ctk runtime configure --runtime=docker --config=$SNAP_DATA/config/daemon.json'
```

We then need to copy the configuration for the container runtime into the correct directory. For this, take the file [config.toml](config.toml) and place it in `/var/snap/docker/current/nvidia-container-runtime`.

```
$ sudo cp config.toml /var/snap/docker/current/etc/nvidia-container-runtime
```

Then we need to restart the docker daemon by disabling and re-enabling the docker snap:
```
$ sudo snap disable docker
$ sudo snap enable docker
```

Note that on boot, the GPU might be deactivated by default and only activate once a GPU workload is run. Therefore, passing the CDI spec to the container runtime might fail if it specifies non-existent device nodes.

This can be circumvented by running `nvidia-smi` for example. This is exposed as an app in the [nvidia-tegra-runtime snap](../nvidia-tegra-runtime) which needs to be installed as a prerequisit. It can then be run like this:
```
$ sudo snap run nvidia-tegra-runtime.nvidia-smi
```

In this case we'll run a TensorRT container, so we'll create a testing script, [run_tensorrt.sh](run_tensorrt.sh), that will be mounted inside the container. It builds and runs the `sample_onnx_mnist` sample, falling back to building it from the TensorRT OSS sources (downloading the required sample data) when the prebuilt samples aren't shipped in the image.

The testing script is in this project as `run_tensorrt.sh`.

We want to use the most up-to-date tag for the container which should be updated every month.
```
$ current_month=$(date '+%Y-%m')
$ last_month=$(date -d "$current_month-15 last month" '+%y.%m')
$ container_name=${last_month}-py3
```

Since our CDI spec mounts driver files (executables like `nvidia-smi` and `nvidia-cuda-mps-control` included) at their literal path inside the docker snap's content interface (e.g. `/snap/docker/<revision>/graphics/usr/bin/...`), those binaries aren't on the container's default `PATH`. Prepend that directory to `PATH` *inside* the container (so it's added to the image's own `PATH` rather than replacing it), resolving `<revision>` to the docker snap's currently active revision:
```
$ DOCKER_REV=$(readlink -f /snap/docker/current | xargs basename)
$ sudo docker run --runtime=nvidia --gpus all --rm -v $(pwd):/sh_input \
    nvcr.io/nvidia/tensorrt:${container_name} bash -c \
    "export PATH=/snap/docker/${DOCKER_REV}/graphics/usr/sbin:/snap/docker/${DOCKER_REV}/graphics/usr/bin:\$PATH && bash /sh_input/run_tensorrt.sh"
```

We can also verify PyTorch works with the GPU the same way, by running `deviceQuery` in the matching `nvcr.io/nvidia/pytorch` container:
```
$ sudo docker run --runtime=nvidia --gpus all --rm \
    nvcr.io/nvidia/pytorch:${container_name} bash -c \
    "export PATH=/snap/docker/${DOCKER_REV}/graphics/usr/sbin:/snap/docker/${DOCKER_REV}/graphics/usr/bin:\$PATH && deviceQuery"
```
