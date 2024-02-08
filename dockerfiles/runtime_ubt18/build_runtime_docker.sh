#!/bin/bash
set -x 
CUDA_VER=11.8 # Newest CUDA version that we can use, see dockerfile for more info
PY_VER=3.10 # Last version with pytorch3d support
MMCV_VER=1.7.0 # Last version compatible with this repo
TORCH_VER=2.0.1 # Version 2.1.0 has a bug with the gcc compiler and newer versions are not compatible with pytorch3d
TORCHV_VER=0.15.2 # Corresponding version for pytorch 2.0.1
CUDA_VER_DIGIT=${CUDA_VER//./}
PY_VER_DIGIT=${PY_VER//./}
MMCV_VER_DIGIT=${MMCV_VER//./}
TORCH_VER_DIGIT=${TORCH_VER//./}
FINAL_TAG="openxrlab/xrmocap_runtime:ubuntu2204_x64_cuda${CUDA_VER_DIGIT}_py${PY_VER_DIGIT}_torch${TORCH_VER_DIGIT}_mmcv${MMCV_VER_DIGIT}"
echo "tag to build: $FINAL_TAG"
BUILD_ARGS="--build-arg CUDA_VER=${CUDA_VER} --build-arg PY_VER=${PY_VER} --build-arg MMCV_VER=${MMCV_VER} --build-arg TORCH_VER=${TORCH_VER} --build-arg TORCHV_VER=${TORCHV_VER}"
# build according to Dockerfile
TAG=${FINAL_TAG}_not_compatible
docker build -t $TAG -f dockerfiles/runtime_ubt18/Dockerfile $BUILD_ARGS --progress=plain .
# Install mpr and mmcv-full with GPU
CONTAINER_ID=$(docker run -it --gpus all -d $TAG)
docker exec -ti $CONTAINER_ID sh -c "
    . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip install -U openmim && \
    mim install mmcv-full==${MMCV_VER} && \    
    pip install git+https://github.com/rmbashirov/minimal_pytorch_rasterizer.git && \
    pip cache purge
"

docker commit $CONTAINER_ID $FINAL_TAG
docker rm -f $CONTAINER_ID
docker rmi $TAG
echo "Successfully tagged $FINAL_TAG"
