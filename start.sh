#!/bin/bash
# Web数据预览器启动脚本

echo "🎉 Web数据预览器 - 工具提示版本"
echo "=" * 40

# 检查Python版本
echo "🔍 检查Python环境..."
python3 --version || {
    echo "❌ 错误：需要Python 3.7+，请先安装Python"
    exit 1
}

# 检查是否存在虚拟环境
if [ ! -d "venv" ]; then
    echo "📦 创建虚拟环境..."
    python3 -m venv venv
fi

# 激活虚拟环境
echo "🔄 激活虚拟环境..."
source venv/bin/activate

# 安装依赖
echo "📥 安装依赖包..."
pip install -r requirements.txt

# 启动应用
echo "🚀 启动应用..."
echo "访问地址：http://127.0.0.1:10013"
echo "按 Ctrl+C 停止服务"
python app.py
