# nvidia-tegra-runtime

This snap packages the nvidia-tegra-drivers-36 .deb package from the
[ubuntu-tegra/updates
ppa](https://launchpad.net/~ubuntu-tegra/+archive/ubuntu/updates) which
contains the firmware and core files for nvidia tegra GPUs in order to run the
CUDA toolkit.

It includes the `nvidia-smi` tool to query information about the GPU. In order
to function, the tool needs access to the firmware files which should be
installed on the system. On Classic, the firmware should be installed with the
`linux-firmware-nvidia-tegra` package. On Core, the firmware is part of the
kernel snap.

Access to the core files to external snaps is given using the graphics-core22
interface which should eventually also include more graphics libraries (X11,
Wayland, Vulkan etc.). The graphics-core22-provider-wrapper included in this
snap is taken from the [nvidia-core22
snap](https://github.com/snapcore/nvidia-core22) and the `$LD_LIBRARY_PATH`
extended by `${SELF}/usr/lib/${ARCH_TRIPLET}/nvidia` to point to the shared
objects from the nvidia-tegra-runtime package.
the name of the snap doesn't change.

This snap needs access to several different device nodes on the system. The
access to these device nodes is provided by the existing `hardware-observe`
interface.

# Build, Install and Run nvidia-smi From the root directory, you need to run
the `snapcraft` command on an arm64 device. The installation needs to be done
using the `--dangerous` flag as it's an offline snap. Then you need to go ahead
and connect all the remaining interfaces:

```
$ snapcraft
$ sudo snap install --dangerous nvidia-tegra-runtime_36.4_arm64.snap
$ sudo snap connect nvidia-tegra-runtime:hardware-observe
```

The nvidia-smi tool can then be run with:
```
$ sudo snap run nvidia-tegra-runtime.nvidia-smi
```

The command needs to be run with `sudo` if the user is not part of the `video`
and `render` groups.

The output should look like this:
```
ubuntu@ubuntu:~$ snap run nvidia-tegra-runtime.nvidia-smi
Wed Dec  4 13:48:28 2024
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 540.4.0                Driver Version: 540.4.0      CUDA Version: 12.4     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  Orin (nvgpu)                  N/A  | N/A              N/A |                  N/A |
| N/A   N/A  N/A               N/A /  N/A | Not Supported        |     N/A          N/A |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+

+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
+---------------------------------------------------------------------------------------+
```
