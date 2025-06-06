#!/bin/bash
# ================================================================
# Web数据预览器 v2.1 - macOS启动脚本
# 支持指定端口号启动服务
# ================================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_PORT=10015
PORT=${1:-$DEFAULT_PORT}

# 显示标题
echo -e "${GREEN}"
echo "================================================================"
echo " Web数据预览器 v2.1 - macOS启动脚本"
echo " 支持工具提示、会话隔离和Docker部署"
echo "================================================================"
echo -e "${NC}"

# 帮助函数
show_help() {
    echo -e "${CYAN}用法:${NC}"
    echo "  ./start_webpre_macos.sh [端口号]"
    echo ""
    echo -e "${CYAN}示例:${NC}"
    echo "  ./start_webpre_macos.sh          # 使用默认端口 10015"
    echo "  ./start_webpre_macos.sh 8080     # 使用端口 8080"
    echo "  ./start_webpre_macos.sh 3000     # 使用端口 3000"
    echo ""
    echo -e "${CYAN}参数:${NC}"
    echo "  端口号       可选，指定Web服务端口 (1024-65535)"
    echo "  -h, --help   显示此帮助信息"
    echo ""
    echo -e "${CYAN}功能特性:${NC}"
    echo "  • 智能工具提示 - 解决数据截断问题"
    echo "  • 会话隔离 - 多用户安全并发"
    echo "  • 多格式支持 - CSV、JSON、Parquet、Excel"
    echo "  • 数据可视化 - 多种图表类型"
    echo ""
    exit 0
}

# 检查帮助参数
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# 验证端口号
if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}错误: 端口号必须是数字${NC}"
    show_help
fi

if [ "$PORT" -lt 1024 ]; then
    echo -e "${YELLOW}警告: 端口号小于1024可能需要管理员权限${NC}"
fi

if [ "$PORT" -gt 65535 ]; then
    echo -e "${RED}错误: 端口号不能大于65535${NC}"
    show_help
fi

if [ "$1" ]; then
    echo -e "${YELLOW}使用指定端口: $PORT${NC}"
else
    echo -e "${YELLOW}使用默认端口: $PORT${NC}"
fi

echo ""
echo -e "${CYAN}正在检查环境...${NC}"

# 检查Python
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo -e "${RED}错误: 未找到Python，请先安装Python 3.8+${NC}"
        echo "安装建议:"
        echo "  方式一: brew install python3"
        echo "  方式二: 从 https://www.python.org/downloads/ 下载"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

# 检查Python版本
PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
echo -e "${GREEN}✓ Python版本: $PYTHON_VERSION${NC}"

# 检查pip
if ! command -v pip3 &> /dev/null; then
    if ! command -v pip &> /dev/null; then
        echo -e "${RED}错误: 未找到pip${NC}"
        exit 1
    else
        PIP_CMD="pip"
    fi
else
    PIP_CMD="pip3"
fi

# 检查必需文件
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}错误: 未找到requirements.txt文件${NC}"
    exit 1
fi

if [ ! -f "app.py" ]; then
    echo -e "${RED}错误: 未找到app.py文件${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 应用文件检查完成${NC}"

# 创建uploads目录
if [ ! -d "uploads" ]; then
    mkdir -p uploads
    echo -e "${GREEN}✓ 创建uploads目录${NC}"
fi

echo ""
echo -e "${CYAN}正在检查Python依赖...${NC}"

# 检查关键依赖
if ! $PYTHON_CMD -c "import flask" 2>/dev/null; then
    echo -e "${YELLOW}正在安装Python依赖...${NC}"
    $PIP_CMD install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误: 依赖安装失败${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Python依赖已安装${NC}"
fi

# 检查端口占用 (macOS)
if lsof -i :$PORT >/dev/null 2>&1; then
    echo -e "${YELLOW}警告: 端口 $PORT 可能已被占用${NC}"
    echo "如果启动失败，请尝试使用其他端口"
    echo ""
fi

echo ""
echo -e "${CYAN}启动配置:${NC}"
echo "  端口: $PORT"
echo "  模式: 生产模式"
echo "  访问: http://127.0.0.1:$PORT"
echo "  访问: http://localhost:$PORT"
echo ""

# 设置环境变量
export FLASK_PORT=$PORT
export FLASK_ENV=production
export FLASK_DEBUG=false

echo -e "${GREEN}正在启动Web数据预览器...${NC}"
echo -e "${YELLOW}按 Ctrl+C 停止服务${NC}"
echo ""

# 添加信号处理
cleanup() {
    echo ""
    echo -e "${GREEN}服务已停止${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# 启动应用
$PYTHON_CMD app.py --port $PORT

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}应用启动失败！${NC}"
    echo ""
    echo -e "${CYAN}故障排除建议:${NC}"
    echo "1. 检查端口 $PORT 是否被占用: lsof -i :$PORT"
    echo "2. 检查Python依赖是否完整安装"
    echo "3. 检查app.py文件是否存在"
    echo "4. 尝试使用其他端口号"
    echo "5. 检查系统防火墙设置"
    echo ""
    exit 1
fi
