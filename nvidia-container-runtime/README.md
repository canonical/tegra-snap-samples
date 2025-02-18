# Nvidia Container Runtime

This directory contains supporting files needed in order to enable the nvidia container runtime for docker on Ubuntu Core.

In order to run docker containers using the nvidia container runtime, we need to install the docker snap on Ubuntu Core. This snap already exists so we don't have to build it manually.

In order to use the docker snap, we need to pass runtime libraries and device nodes in the form of a "Container Device Interface" (CDI) specification whereas on a classic Ubuntu image we can use the CSV format.

In order to generate the CDI specification, we can adapt the CSV files that are shipped with the nvidia-tegra-drivers-36 .deb package from the [ubuntu-tegra/updates ppa](https://launchpad.net/~ubuntu-tegra/+archive/ubuntu/updates/+packages). The modification is done by simply changing the path of the files listed in `drivers.csv` to the path where it will be found inside the docker snap. The modified CSV files are contained in this directory. The CDI specification can then be generated from within the docker snap. The docker snap will only find the necessary runtime libraries to pass to the container runtime, when it is connected to the `graphics-core22` interface of the [nvidia-tegra-runtime snap](../nvidia-tegra-runtime) which needs to be built and installed before.

Install the docker snap and connect it to the `graphics-core22` interface:
```
$ sudo snap install docker
$ sudo snap connect docker:graphics-core22 nvidia-tegra-runtime:graphics-core22
```

To generate the CDI specification, navigate to the directory containing the CSV files, spawn the shell environment of the docker snap and run the command. We also need to generate the runtime configuration for the docker daemon:
```
$ sudo snap run --shell docker

# nvidia-ctk cdi generate --mode=csv --format=yaml \
    --csv.file=./devices.csv,./drivers.csv \
    --output=$SNAP_DATA/etc/nvidia-container-runtime/cdi/nvidia.yaml

# nvidia-ctk runtime configure --runtime=docker --config=$SNAP_DATA/config/daemon.json
```

We then need to copy the configuration for the container runtime into the correct directory. For this, take the file [config.toml](config.toml) and place it in `/var/snap/docker/current/nvidia-container-runtime`.

```
sudo cp config.toml /var/snap/docker/current/etc/nvidia-container-runtime
```

Then we need to exit the docker shell environment and restart the docker daemon by disabling and re-enabling the docker snap:
```
$ sudo snap disable docker
$ sudo snap enable docker
```

In this case we'll run a TensorRT container, so we'll create a testing script that will be mounted inside the container:
```
$ mkdir ~/container_test
$ cd ~/container_test
$ cat > run_tensorrt.sh
echo "OS release,Kernel version"
(. /etc/os-release; echo "${PRETTY_NAME}"; uname -r) | paste -s -d,
echo
NVIDIA_SMI=$(find /snap/docker -name nvidia-smi | head -n 1)
$NVIDIA_SMI -q
echo
exec bash -o pipefail -c "
cd /workspace/tensorrt/samples
make -j4
cd /workspace/tensorrt/bin
./sample_onnx_mnist
retstatus=\${PIPESTATUS[0]}
echo "Test exited with status code: ${retstatus}" >&2
exit ${retstatus}
"
```

We can then run a container like this:
```
$ sudo docker run --runtime=nvidia --gpus all --rm -v $(pwd):/sh_input \
    nvcr.io/nvidia/tensorrt:24.11-py3-igpu bash /sh_input/run_tensorrt.sh
```

Note that on boot, the GPU is deactivated by default and will only activate once a GPU workload is run. Therefore, passing the CDI spec to the container runtime might fail if it specifies non-existent device nodes.

This can be circumvented by running `nvidia-smi` for example. This is exposed as an app in the [nvidia-tegra-runtime snap](../nvidia-tegra-runtime) which needs to be installed as a prerequisit. It can then be run like this:
```
$ sudo snap run nvidia-tegra-runtime.nvidia-smi
```
