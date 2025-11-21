## Docker

## Unofficial Dockerfile for 3D Gaussian Splatting for Real-Time Radiance Field Rendering
## Bernhard Kerbl, Georgios Kopanas, Thomas Leimkühler, George Drettakis
## https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/

# Use the base image with PyTorch and CUDA support
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

# NOTE:
# Building the libraries for this repository requires cuda *DURING BUILD PHASE*, therefore:
# - The default-runtime for container should be set to "nvidia" in the deamon.json file. See this: https://github.com/NVIDIA/nvidia-docker/issues/1033
# - For the above to work, the nvidia-container-runtime should be installed in your host. Tested with version 1.14.0-rc.2
# - Make sure NVIDIA's drivers are updated in the host machine. Tested with 525.125.06
ENV DEBIAN_FRONTEND=noninteractive
ARG TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6"

RUN pip install torch\>=2 torchvision

RUN apt-get update && \
    apt-get install -y wget git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# COPY ./pyproject.toml /tmp 
# COPY ./src /tmp
# COPY ./notebooks /tmp
# COPY ./requirements.txt /tmp
# COPY ./.pre-commit-config.yaml /tmp
# COPY ./README.md /tmp
COPY ./ /tmp

#big model, don't want to keep a copy
RUN rm -rf /tmp/models 

RUN pip install -e ".[all]" # ALL


WORKDIR /da3

# This error occurs because there’s a conflict between the threading layer used
# by Intel MKL (Math Kernel Library) and the libgomp library, 
# which is typically used by OpenMP for parallel processing. 
# This often happens when libraries like NumPy or SciPy are used in combination
# with a multithreaded application (e.g., your Docker container or Python environment).
# Solution, set threading layer explicitly! (GNU or INTEL)
ENV MKL_THREADING_LAYER=GNU