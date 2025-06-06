@echo off
chcp 65001 >nul
echo 🎉 Web数据预览器 - 工具提示版本
echo ========================================

echo 🔍 检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误：需要Python 3.7+，请先安装Python
    pause
    exit /b 1
)

if not exist "venv" (
    echo 📦 创建虚拟环境...
    python -m venv venv
)

echo 🔄 激活虚拟环境...
call venv\Scripts\activate.bat

echo 📥 安装依赖包...
pip install -r requirements.txt

echo 🚀 启动应用...
echo 访问地址：http://127.0.0.1:10013
echo 按 Ctrl+C 停止服务
python app.py
pause
