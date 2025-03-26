# nvpmodel

This snap packages the `nvpmodel` and the `jetson_clocks` utilities which can be used to set a determined power mode (e.g., `7W`, `15W`, `25W`, `MAXN_SUPER`, etc...) and read the mode that was configured, displaying the system clocks (CPU, GPU, and EMC) and the fan status of a Jetson device.

The following website can be consulted, for more information about the NVIDIA power modes on Jetson devices.

[Supported Modes and Power Efficiency](https://docs.nvidia.com/jetson/archives/r36.4.3/DeveloperGuide/SD/PlatformPowerAndPerformance/JetsonOrinNanoSeriesJetsonOrinNxSeriesAndJetsonAgxOrinSeries.html#sd-platformpowerandperformance-supportedmodesandpowerefficiency)

This snap doesn't require any extra build steps for the software it provides since it uses staging packages, such as some specific NVIDIA L4T packages (i.e., `nvidia-l4t-nvpmodel`, `nvidia-l4t-core` and `nvidia-l4t-tools`) to provide runtime libraries and binaries.

Some `layouts` were defined to bind-mount directories from inside the snap to a different location in the execution environment. This is necessary because the tools expect certain libraries and configuration files in hard-coded paths by default.

# Build, install and run the snap.

This snap has no external dependencies for being built and installed, there is just needed to run `snapcraft`, install the resulting snap using the `--dangerous` flag, connect all necessary interfaces, and finally restart the snap, this last step is needed because inside the snap there are two services (i.e., `nvpower` and `nvpmodel`) which need the set-power-management-mode interface to be connected to be properly executed.

```
$ snapcraft -v --destructive-mode
$ sudo snap install --dangerous nvpmodel_1.0_arm64.snap

$ sudo snap connect nvpmodel:hardware-observe
$ sudo snap connect nvpmodel:set-power-management-mode
$ sudo snap connect nvpmodel:shutdown
$ sudo snap connect nvpmodel:dbus-consumer nvpmodel:dbus-provider
$ sudo snap restart nvpmodel
```

# Update and read the power management mode.

The command shown below can be used to update the power management mode of a `Jetson Orin Nano 8GB` device, `-m 0` corresponds on this case to `15W`, when switching between power modes the snap might request the system to be rebooted.

```
$ sudo snap run nvpmodel.nvpmodel -m 0
```

The following command can be used to retrieve the power management mode that is currently set on a device.

```
$ sudo snap run nvpmodel.nvpmodel --query
NV Power Mode: 15W
0
```

The command below can be used to monitor the system clocks (CPU, GPU, and EMC) and the fan status.

```
$ sudo snap run nvpmodel.jetson-clocks-show
SOC family:tegra234  Machine:NVIDIA Jetson Orin Nano Developer Kit
Online CPUs: 0-5
cpu0:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=960000 IdleStates: WFI=1 c7=1
cpu1:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=729600 IdleStates: WFI=1 c7=1
cpu2:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=729600 IdleStates: WFI=1 c7=1
cpu3:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=960000 IdleStates: WFI=1 c7=1
cpu4:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=729600 IdleStates: WFI=1 c7=1
cpu5:  Online=1 Governor=ondemand MinFreq=729600 MaxFreq=1510400 CurrentFreq=729600 IdleStates: WFI=1 c7=1
GPU MinFreq=306000000 MaxFreq=624750000 CurrentFreq=306000000
Active GPU TPCs: 4
EMC MinFreq=204000000 MaxFreq=2133000000 CurrentFreq=665600000 FreqOverride=0
Failed to retrieve unit state: Access denied
Failed to retrieve unit state: Access denied
FAN Dynamic Speed Control=kernel hwmon0_pwm1=88
```

As can be seen on the example above, the settings corresponds to the `15W` power mode that was set by `nvpmodel`.

It is important to note that the `Failed to retrieve unit state: Access denied` messages displayed when running `snap run nvpmodel.jetson-clocks-show` does not represent an issue, those are only displayed because `jetson_clocks` tries to make some `systemctl` calls to monitor if two services are active, but those are not relevant for the use case of this snap application.
