#!/bin/bash
set -e

# ---------------- 配置 ----------------
ENV_NAME="isaacgym_env"
PYTHON_VERSION="3.8"
PYTORCH_VERSION="2.4.1"
CUDA_VERSION="11.8"
# --------------------------------------

echo "========================="
echo "开始安装 conda 环境和 PyTorch"
echo "========================="

# 1️⃣ 初始化 conda
echo "[1/6] 初始化 conda..."
if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    echo "找不到 conda，请检查 Miniconda 是否安装在 ~/miniconda3"
    exit 1
fi

# 2️⃣ 创建环境（如果不存在）
echo "[2/6] 创建 conda 环境 $ENV_NAME ..."
if conda env list | grep -q "$ENV_NAME"; then
    echo "环境 $ENV_NAME 已存在，跳过创建"
else
    conda create -n $ENV_NAME python=$PYTHON_VERSION -y
fi

# 3️⃣ 激活环境
echo "[3/6] 激活环境 $ENV_NAME ..."
conda activate $ENV_NAME


# 4️⃣ 安装 PyTorch 2.4.1 + CUDA 11.8
echo "[4/6] 安装 PyTorch $PYTORCH_VERSION + CUDA $CUDA_VERSION ..."
conda install pytorch==$PYTORCH_VERSION torchvision torchaudio pytorch-cuda=$CUDA_VERSION -c pytorch -c nvidia -y

# 5️⃣ 安装常用 Python 包
echo "[5/6] 安装常用 Python 包..."
pip install matplotlib scipy numpy pandas gym

# 6️⃣ 测试环境
echo "[6/6] 测试安装是否成功..."
python3 - << EOF
import sys
import torch

print("Python 版本:", sys.version)
print("Conda 环境:", "$ENV_NAME")
print("PyTorch 版本:", torch.__version__)
print("CUDA 可用:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU 名称:", torch.cuda.get_device_name(0))
EOF

echo "========================="
echo "环境安装完成 ✅"
echo "激活环境：conda activate $ENV_NAME"
echo "========================="
