#!/usr/bin/env bash
TAG="openxrlab/xrmocap_runtime:ubuntu2204_x64_cuda118_py310_torch201_mmcv170"
# modify data mount below
VOLUMES="-v /home/era/code/xrmocap:/workspace/xrmocap -v /home/era/code/xrmocap/data:/workspace/xrmocap/data"
WORKDIR="-w /workspace/xrmocap"
docker run --gpus all -it --shm-size=24g $VOLUMES $WORKDIR $TAG $@
