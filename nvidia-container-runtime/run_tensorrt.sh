#!/bin/bash
echo "OS release,Kernel version"
(. /etc/os-release; echo "\${PRETTY_NAME}"; uname -r) | paste -s -d,
echo
nvidia-smi -q
echo  
exec bash -o pipefail -c "
cd /workspace/tensorrt/samples
make -j4
cd /workspace/tensorrt/bin
./sample_onnx_mnist
retstatus=\${PIPESTATUS[0]}
echo "Test exited with status code: \${retstatus}" >&2
exit \${retstatus}
"
