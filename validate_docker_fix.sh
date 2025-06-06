#!/bin/bash
# Docker 问题修复验证脚本
# 验证所有已知的 Docker 构建和运行问题是否已修复

echo "=== Docker 问题修复验证脚本 ==="
echo "检查并修复所有已知的 Docker 相关问题"
echo

ERRORS_FOUND=0

echo "1. 检查核心应用文件是否存在..."
if [[ ! -f "app.py" ]]; then
    echo "   ✗ 错误: app.py 文件不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ app.py 存在 ($(ls -lh app.py | awk '{print $5}'))"
fi

if [[ ! -f "demo_tooltip.py" ]]; then
    echo "   ✗ 错误: demo_tooltip.py 文件不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ demo_tooltip.py 存在"
fi

echo
echo "2. 检查依赖文件..."
if [[ ! -f "requirements.txt" ]]; then
    echo "   ✗ 错误: requirements.txt 文件不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ requirements.txt 存在"
    # 检查是否包含 requests 库
    if grep -q "requests" requirements.txt; then
        echo "   ✓ requirements.txt 包含 requests 库"
    else
        echo "   ✗ 警告: requirements.txt 缺少 requests 库（健康检查需要）"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
fi

echo
echo "3. 检查测试数据文件..."
if [[ ! -f "test/test_long_columns.csv" ]]; then
    echo "   ✗ 错误: test/test_long_columns.csv 文件不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ test/test_long_columns.csv 存在"
fi

echo
echo "4. 检查静态资源..."
if [[ ! -d "static" ]]; then
    echo "   ✗ 错误: static/ 目录不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ static/ 目录存在"
fi

if [[ ! -d "templates" ]]; then
    echo "   ✗ 错误: templates/ 目录不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ templates/ 目录存在"
fi

echo
echo "5. 检查 .dockerignore 配置..."
if [[ ! -f ".dockerignore" ]]; then
    echo "   ✗ 错误: .dockerignore 文件不存在"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
else
    echo "   ✓ .dockerignore 存在"
    
    # 检查是否错误排除了重要文件
    if grep -q "^app.py$" .dockerignore; then
        echo "   ✗ 错误: .dockerignore 排除了 app.py"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    else
        echo "   ✓ app.py 未被 .dockerignore 排除"
    fi
    
    if grep -q "^\*.py$" .dockerignore; then
        echo "   ✗ 错误: .dockerignore 排除了所有 .py 文件"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    else
        echo "   ✓ .py 文件未被批量排除"
    fi
fi

echo
echo "6. 检查 Dockerfile 配置..."
for dockerfile in "Dockerfile" "Dockerfile.optimized" "Dockerfile.light"; do
    if [[ -f "$dockerfile" ]]; then
        echo "   检查 $dockerfile:"
        
        # 检查健康检查是否使用了正确的方法
        if grep -q "import requests" "$dockerfile"; then
            echo "     ✗ 使用了 requests 库进行健康检查（可能缺少依赖）"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        elif grep -q "import urllib.request" "$dockerfile"; then
            echo "     ✓ 使用 urllib.request 进行健康检查"
        else
            echo "     ? 未找到健康检查配置"
        fi
        
        # 检查工作目录设置
        if grep -q "WORKDIR /app" "$dockerfile"; then
            echo "     ✓ 正确设置工作目录 /app"
        else
            echo "     ✗ 工作目录设置可能有问题"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
        
        # 检查 COPY 命令
        if grep -q "COPY app.py demo_tooltip.py" "$dockerfile"; then
            echo "     ✓ 正确复制应用文件"
        else
            echo "     ✗ 应用文件复制可能有问题"
            ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
    fi
done

echo
echo "7. 检查应用启动配置..."
if grep -q "if __name__ == '__main__':" app.py; then
    echo "   ✓ app.py 包含主程序入口"
else
    echo "   ✗ 错误: app.py 缺少主程序入口"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi

# 检查端口配置
if grep -q "10015" app.py; then
    echo "   ✓ app.py 配置了正确的端口 10015"
else
    echo "   ✗ 警告: app.py 可能未配置端口 10015"
fi

echo
echo "8. 生成模拟 Docker 运行测试..."
cat > /tmp/docker_run_test.py << 'EOF'
#!/usr/bin/env python3
import os
import sys

# 模拟 Docker 容器环境
os.environ['FLASK_APP'] = 'app.py'
os.environ['FLASK_ENV'] = 'production'

print("模拟 Docker 容器启动测试:")
print(f"当前工作目录: {os.getcwd()}")
print(f"Python 路径: {sys.executable}")
print(f"环境变量 FLASK_APP: {os.environ.get('FLASK_APP', '未设置')}")

# 检查文件是否存在
files_to_check = ['app.py', 'demo_tooltip.py', 'requirements.txt']
for file in files_to_check:
    if os.path.exists(file):
        print(f"✓ {file} 存在")
    else:
        print(f"✗ {file} 不存在")

# 尝试导入应用
try:
    sys.path.insert(0, '.')
    import app
    print("✓ 成功导入 app 模块")
    if hasattr(app, 'app'):
        print("✓ Flask 应用对象存在")
    else:
        print("✗ Flask 应用对象不存在")
except Exception as e:
    print(f"✗ 导入 app 模块失败: {e}")
EOF

if command -v python3 >/dev/null 2>&1; then
    echo "   运行模拟测试:"
    python3 /tmp/docker_run_test.py 2>&1 | sed 's/^/     /'
else
    echo "   ✗ Python3 不可用，跳过模拟测试"
fi

rm -f /tmp/docker_run_test.py

echo
echo "9. 构建建议..."
if [[ $ERRORS_FOUND -eq 0 ]]; then
    echo "   ✓ 所有检查通过！Docker 构建应该能够成功"
    echo
    echo "   推荐的构建和测试步骤:"
    echo "   1. docker build -t webpre-tooltip ."
    echo "   2. docker run -d -p 10015:10015 --name webpre-test webpre-tooltip"
    echo "   3. docker logs webpre-test"
    echo "   4. curl http://localhost:10015"
    echo "   5. docker stop webpre-test && docker rm webpre-test"
else
    echo "   ✗ 发现 $ERRORS_FOUND 个问题需要修复"
    echo
    echo "   修复建议:"
    echo "   - 确保所有必要文件存在且可访问"
    echo "   - 检查 .dockerignore 不要排除重要文件"
    echo "   - 更新 Dockerfile 健康检查使用 urllib.request"
    echo "   - 确保 requirements.txt 包含所有依赖"
fi

echo
echo "=== 验证完成 ==="
echo "错误数量: $ERRORS_FOUND"

exit $ERRORS_FOUND
