FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# ------------------ 基础环境 ------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/conda/envs/isaac-env/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# ------------------ 系统依赖 ------------------
RUN apt-get update && apt-get install -y \
    wget git vim \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libx11-6 \
    libegl1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    && rm -rf /var/lib/apt/lists/*

# ------------------ 安装 Miniconda ------------------
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh

# 接受 Anaconda 官方 ToS（非交互环境必须）
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# ------------------ 创建 Conda 环境 ------------------
RUN conda create -n isaac-env python=3.8 -y && conda clean -afy
SHELL ["conda", "run", "-n", "isaac-env", "/bin/bash", "-c"]

# ------------------ PyTorch ------------------
RUN pip install \
    --timeout 300 \
    --retries 10 \
    torch==2.4.1 torchvision \
    --index-url https://download.pytorch.org/whl/cu121 \
    -i https://pypi.tuna.tsinghua.edu.cn/simple

# ------------------ Isaac Gym ------------------
WORKDIR /opt
COPY IsaacGym_Preview_4_Package.tar.gz .

RUN rm -rf /opt/isaacgym && \
    tar -xzf IsaacGym_Preview_4_Package.tar.gz && \
    rm IsaacGym_Preview_4_Package.tar.gz

WORKDIR /opt/isaacgym/python
RUN pip install -e .

# ------------------ 常用库 ------------------
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --default-timeout=1000 \
    --no-cache-dir \
    tensorboardX tensorboard matplotlib scipy

WORKDIR /workspace
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate isaac-env" >> ~/.bashrc
CMD ["bash"]
