echo "========================="
echo "[7/8] 安装 Isaac Gym Preview 4"
echo "========================="

# 工作目录（建议放在系统盘，代码量不大）
cd ~ || exit 1


ISAACGYM_TAR="IsaacGym_Preview_4_Package.tar.gz"

if [ ! -f "$ISAACGYM_TAR" ]; then
    echo "❌ 未找到 $ISAACGYM_TAR"
    echo "👉 请先从 NVIDIA 官网下载 Isaac Gym Preview 4 并上传到服务器"
    exit 1
fi

# 2. 解压
tar -xzf $ISAACGYM_TAR

# 3. 进入 python 目录并安装
cd isaacgym/python || exit 1
pip install -e .

echo "Isaac Gym 安装完成 ✅"
