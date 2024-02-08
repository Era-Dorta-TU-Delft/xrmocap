# Please build this dockerfile with nvidia-container-runtime
# Last cudatoolkit from conda is 11.8, so that is the last version we can use
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Install apt packages
RUN apt-get update && \
    apt-get install -y \
        wget git vim \
        make curl \
        libblas-dev liblapack-dev libatlas-base-dev\
    && \
    apt-get autoclean

# Install mamba
RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3-$(uname)-$(uname -m).sh -b && \
    rm Miniforge3-$(uname)-$(uname -m).sh

# Update in bashrc
RUN echo "source /root/miniforge3/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "mamba deactivate" >> /root/.bashrc

# Prepare python env
ARG PY_VER
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba create -n openxrlab python=$PY_VER -y && \
    mamba activate openxrlab && \
    mamba install ffmpeg -y && \
    mamba clean -y --all

# Prepare pytorch env
ARG CUDA_VER
ARG TORCH_VER
ARG TORCHV_VER
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    mamba install pytorch==$TORCH_VER torchvision==$TORCHV_VER pytorch-cuda=$CUDA_VER cudatoolkit=$CUDA_VER -c pytorch -c nvidia -y && \
    mamba clean -y --all

# Prepare pytorch3d env
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    mamba install -c fvcore -c iopath -c conda-forge fvcore iopath && \
    mamba install -c bottler nvidiacub && \
    mamba install pytorch3d -c pytorch3d && \
    mamba clean -y --all

# Prepare pip env
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip install pre-commit interrogate coverage pytest && \
    pip install xrprimer && \
    pip cache purge

# Install build requirements
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip install -r https://raw.githubusercontent.com/openxrlab/xrmocap/main/requirements/build.txt && \
    pip cache purge

# Install test requirements
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip install -r https://raw.githubusercontent.com/openxrlab/xrmocap/main/requirements/test.txt && \
    pip cache purge

# Install mmhuman3d
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    cd /opt && \
    git clone https://github.com/open-mmlab/mmhuman3d.git && \
    cd mmhuman3d && pip install -e . && \
    pip cache purge

# Re-install numpy+scipy for mm-repos and smplx
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip uninstall scipy numpy -y && \
    pip install numpy==1.23.5 scipy==1.10.0 && \
    pip cache purge

# Re-install opencv for headless system
# For cudagl base image, please remove both and re-install opencv-python
RUN . /root/miniforge3/etc/profile.d/conda.sh && \
    . /root/miniforge3/etc/profile.d/mamba.sh && \
    mamba activate openxrlab && \
    pip uninstall opencv-python opencv-python-headless -y && \
    pip install opencv-python-headless && \
    pip cache purge
