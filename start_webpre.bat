@echo off
REM ================================================================
REM Web数据预览器 v2.1 - Windows启动脚本
REM 支持指定端口号启动服务
REM ================================================================

setlocal EnableDelayedExpansion

REM 设置颜色输出
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

echo %ESC%[92m
echo ================================================================
echo  Web数据预览器 v2.1 - Windows启动脚本
echo  支持工具提示、会话隔离和Docker部署
echo ================================================================
echo %ESC%[0m

REM 检查参数
set DEFAULT_PORT=10015
set PORT=%DEFAULT_PORT%

if "%1"=="" (
    echo %ESC%[93m使用默认端口: %DEFAULT_PORT%%ESC%[0m
) else (
    if "%1"=="-h" (
        goto :help
    )
    if "%1"=="--help" (
        goto :help
    )
    set PORT=%1
    echo %ESC%[93m使用指定端口: %PORT%%ESC%[0m
)

REM 验证端口号
echo %PORT%| findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 (
    echo %ESC%[91m错误: 端口号必须是数字%ESC%[0m
    goto :help
)

if %PORT% LSS 1024 (
    echo %ESC%[93m警告: 端口号小于1024可能需要管理员权限%ESC%[0m
)

if %PORT% GTR 65535 (
    echo %ESC%[91m错误: 端口号不能大于65535%ESC%[0m
    goto :help
)

echo.
echo %ESC%[96m正在检查环境...%ESC%[0m

REM 检查Python
python --version >nul 2>&1
if errorlevel 1 (
    echo %ESC%[91m错误: 未找到Python，请先安装Python 3.8+%ESC%[0m
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 显示Python版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo %ESC%[92m✓ Python版本: %PYTHON_VERSION%%ESC%[0m

REM 检查requirements.txt
if not exist requirements.txt (
    echo %ESC%[91m错误: 未找到requirements.txt文件%ESC%[0m
    pause
    exit /b 1
)

REM 检查app.py
if not exist app.py (
    echo %ESC%[91m错误: 未找到app.py文件%ESC%[0m
    pause
    exit /b 1
)

echo %ESC%[92m✓ 应用文件检查完成%ESC%[0m

REM 创建uploads目录
if not exist uploads (
    mkdir uploads
    echo %ESC%[92m✓ 创建uploads目录%ESC%[0m
)

echo.
echo %ESC%[96m正在检查Python依赖...%ESC%[0m

REM 检查关键依赖
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo %ESC%[93m正在安装Python依赖...%ESC%[0m
    pip install -r requirements.txt
    if errorlevel 1 (
        echo %ESC%[91m错误: 依赖安装失败%ESC%[0m
        pause
        exit /b 1
    )
) else (
    echo %ESC%[92m✓ Python依赖已安装%ESC%[0m
)

REM 检查端口占用
netstat -an | findstr ":%PORT% " >nul 2>&1
if not errorlevel 1 (
    echo %ESC%[93m警告: 端口 %PORT% 可能已被占用%ESC%[0m
    echo 如果启动失败，请尝试使用其他端口
    echo.
)

echo.
echo %ESC%[96m启动配置:%ESC%[0m
echo   端口: %PORT%
echo   模式: 生产模式
echo   访问: http://127.0.0.1:%PORT%
echo   访问: http://localhost:%PORT%
echo.

REM 设置环境变量
set FLASK_PORT=%PORT%
set FLASK_ENV=production
set FLASK_DEBUG=false

echo %ESC%[92m正在启动Web数据预览器...%ESC%[0m
echo %ESC%[93m按 Ctrl+C 停止服务%ESC%[0m
echo.

REM 启动应用
python app.py --port %PORT%

if errorlevel 1 (
    echo.
    echo %ESC%[91m应用启动失败！%ESC%[0m
    echo.
    echo %ESC%[96m故障排除建议:%ESC%[0m
    echo 1. 检查端口 %PORT% 是否被占用
    echo 2. 检查Python依赖是否完整安装
    echo 3. 检查app.py文件是否存在
    echo 4. 尝试使用其他端口号
    echo.
    pause
    exit /b 1
)

goto :end

:help
echo.
echo %ESC%[96m用法:%ESC%[0m
echo   start_webpre.bat [端口号]
echo.
echo %ESC%[96m示例:%ESC%[0m
echo   start_webpre.bat          # 使用默认端口 10015
echo   start_webpre.bat 8080     # 使用端口 8080
echo   start_webpre.bat 3000     # 使用端口 3000
echo.
echo %ESC%[96m参数:%ESC%[0m
echo   端口号    可选，指定Web服务端口 (1024-65535)
echo   -h, --help  显示此帮助信息
echo.
echo %ESC%[96m功能特性:%ESC%[0m
echo   • 智能工具提示 - 解决数据截断问题
echo   • 会话隔离 - 多用户安全并发
echo   • 多格式支持 - CSV、JSON、Parquet、Excel
echo   • 数据可视化 - 多种图表类型
echo.
pause
exit /b 0

:end
echo.
echo %ESC%[92m服务已停止%ESC%[0m
pause
