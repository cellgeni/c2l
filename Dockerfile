# base image maintained by the NVIDIA CUDA Installer Team - https://hub.docker.com/r/nvidia/cuda/
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# install os packages
RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        curl \
        unzip \
        g++ \
        vim \
        wget \
        ca-certificates \
        git \
	python3 python3-dev python3-venv python-is-python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV VENV_PATH="/env"
ENV PATH="${VENV_PATH}/bin:$PATH"

RUN python -m venv "${VENV_PATH}"

RUN pip install scvi-tools
RUN pip install jupyterlab papermill
RUN pip install scvi-tools


# install cell2location 
COPY . cell2location
RUN pip install -e /cell2location

COPY Dockerfile /docker/
RUN chmod -R 755 /docker
