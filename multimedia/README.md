# Multimedia

This snap packages several camera and gstreamer utilities that can be used to access the camera or perform some transcoding workloads using hardware or software accelerators.

In order to run this software successfully, we need to make use of several built-in plugins related to camera, network, graphics, multimedia and hardware. Additionally, we need access to some device nodes that are not yet included in any existing interface. In order to access a device node, it needs to be tagged by the snap using a udev rules, otherwise it will not be visible inside the snap environment. For this, we can use the `custom-device` interface. The slot side of this interface can either be part of a gadget snap, or part of the application snap itself (which is the case here). After we create the slot definition with a name for the slot (tegra-camera), we can create a plug definition that specifies we want to plug into the custom-device interface with the name "tegra-camera".

This snap doesn't require any extra build steps for the software it contains, it simply uses staging packages. We need `nvidia-tegra-drivers-36` to provide some platform specific runtime libraries. Additionally, we need multiple gstreamer packages that provide development files and plugins for gstreamer to communicate with the hardware. We use v4l-utils as a generic tool to interface with the cameras. Finally, we also include `unzip` and `wget` since there are no official snaps containing these tools and we want to use them later to be able to download a video file and unpack it for transcoding purposes.

We need to create several different `layouts` in the snap which will bind-mount a directory from inside the snap to a different location in the execution environment. This is necessary because some tools expect certain libraries and configuration files in hard-coded paths. By default however, all files included in the snap will be found under `/snap/multimedida/current`.

The snap also contains the nvargus-daemon as a service which is enabled by default. This daemon will handle the actual communication with the hardware and will act as a middleware between the gstreamer plugins, the nvargus_nvraw tool and the hardware.

# Build, Install and Run Snap

This snap has no external dependencies, in order to build and install it, simply run `snapcraft` from the multimedia directory and install the resulting snap using the `--dangerous` flag. Then, to make it run, simply connect all necessary interfaces.

```
$ snapcraft
$ sudo snap install --dangerous multimedia_1.0_arm64.snap

$ sudo snap connect multimedia:camera
$ sudo snap connect multimedia:hardware-observe
$ sudo snap connect multimedia:kernel-module-observe
$ sudo snap connect multimedia:media-control
$ sudo snap connect multimedia:process-control
$ sudo snap connect multimedia:tegra-camera-plug multimedia:tegra-camera-slot
```

After connecting the interfaces, the nvargus-daemon contained in the snap might have to be restarted:
```
$ sudo snap restart multimedia.nvargus-daemon
```

# List video devices
```
$ sudo snap run tegra-camera.v4l2-ctl --list-devices
```

# Print sensor information with nvargus
```
$ sudo snap run multimedia.nvargus-nvraw --sensorinfo --c 0
```

You can change the sensor being queried by changing the number behind `--c`

# Capture an image with nvargus
```
$ sudo snap run multimedia.nvargus-nvraw --c 0 --format jpg --file /var/snap/multimedia/current/frame-cam0.jpg
```

We create the file in the `$SNAP_DATA` directory of the multimedia snap because we have write access there by default. Access to the home directory requires additional permissions.

# Camera Capture Using Gstreamer

```
# Capture an image
$ sudo snap run multimedia.gst-launch nvarguscamerasrc \
    num-buffers=1 sensor-id=0 ! \
    'video/x-raw(memory:NVMM), width=(int)1920, height=(int)1080,' \ 'format=(string)NV12' ! nvjpegenc ! filesink \
    location=/var/snap/multimedia/current/gst-frame-cam0.jpg

# Capturing Video from the Camera and Record
$ sudo snap run multimedia.gst-launch nvarguscamerasrc \
    num-buffers=300 sensor-id=0 ! \
    'video/x-raw(memory:NVMM), width=(int)1920, height=(int)1080,' \
    'format=(string)NV12, framerate=(fraction)30/1' ! \
    nvv4l2h265enc bitrate=8000000 ! h265parse ! qtmux ! \
    filesink location=/var/snap/multimedia/current/test.mp4
```

Capturing video requires hardware encoders, therefore it is **not** possible on Nano platforms.

# Gstreamer Transcoding
```
$ cd /var/snap/multimedia/current
$ sudo snap run multimedia.wget https://download.blender.org/demo/movies/BBB/bbb_sunflower_1080p_30fps_normal.mp4.zip

$ sudo snap run multimedia.unzip bbb_sunflower_1080p_30fps_normal.mp4.zip

$ sudo snap run multimedia.gst-launch filesrc \
    location=bbb_sunflower_1080p_30fps_normal.mp4 ! qtdemux ! queue ! \
    h264parse ! nvv4l2decoder ! nvv4l2h265enc bitrate=8000000 ! h265parse ! \
    qtmux ! filesink location=riverside-camera-h265-reenc.mp4 -e

$ sudo snap run multimedia.gst-launch filesrc \
    location=riverside-camera-h265-reenc.mp4 ! qtdemux ! queue ! \
    h265parse ! nvv4l2decoder ! nvv4l2av1enc ! matroskamux name=mux ! \
    filesink location=riverside-camera-av1-reenc.mkv -e

$ sudo snap run multimedia.gst-launch filesrc \
    location=riverside-camera-av1-reenc.mkv ! matroskademux ! queue ! \
    nvv4l2decoder ! nvv4l2h264enc bitrate=20000000 ! h264parse ! queue ! \
    qtmux name=mux ! filesink location=riverside-camera-h264-reenc.mp4 -e

$ sudo snap run multimedia.gst-launch filesrc \
    location=riverside-camera-h264-reenc.mp4 ! qtdemux ! \
    h264parse ! nvv4l2decoder ! nvv4l2av1enc ! matroskamux name=mux ! \
    filesink location=riverside-camera-av1-reenc-2x.mkv -e
```
