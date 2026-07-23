#!/bin/bash
echo "OS release,Kernel version"
(. /etc/os-release; echo "${PRETTY_NAME}"; uname -r) | paste -s -d,
echo
nvidia-smi -q
echo
exec bash -o pipefail -c "
if [ -f /workspace/tensorrt/samples/Makefile ]; then
  cd /workspace/tensorrt/samples
  make -j4
  cd /workspace/tensorrt/bin
  ./sample_onnx_mnist
else
  cd /workspace/tensorrt/oss
  mkdir -p build
  cd build
  cmake .. \
    -DTRT_LIB_DIR=/usr/lib/aarch64-linux-gnu \
    -DTRT_OUT_DIR=\$(pwd)/out \
    -DBUILD_SAMPLES=ON \
    -DBUILD_PARSERS=OFF \
    -DBUILD_PLUGINS=OFF \
    -DTRT_PLATFORM_ID=aarch64
  cmake --build . --parallel \$(nproc)
  echo \"Fetching tensorrt_sample_data URL\"
  if ! wget -q https://raw.githubusercontent.com/NVIDIA/TensorRT/main/samples/README.md; then
    echo \"Error: failed to fetch the tensorrt_sample_data URL\"
    exit 1
  fi
  sample_data_url=\$(grep -o \"https://github.com/NVIDIA/TensorRT/releases/download/.*zip\" README.md)
  echo \"sample_data_url:\$sample_data_url\"
  if [ -z \"\$sample_data_url\" ]; then
    echo \"Error: sample_data_url is empty\"
    exit 1
  fi
  echo \"Downloading tensorrt_sample_data\"
  if ! wget -q \$sample_data_url; then
    echo \"Error: failed to download the tensorrt_sample_data\"
    exit 1
  fi
  unzip tensorrt_sample_data_*.zip -d /workspace/tensorrt/data
  /workspace/tensorrt/oss/build/out/sample_onnx_mnist
fi
retstatus=\${PIPESTATUS[0]}
echo \"Test exited with status code: \${retstatus}\" >&2
exit \${retstatus}
"
