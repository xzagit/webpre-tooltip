#!/bin/bash
# 模拟 Docker 构建过程，验证所有必要文件都可用

echo "=== 模拟 Docker 构建验证 ==="
echo

BUILD_DIR="/tmp/docker_build_simulation"
echo "1. 创建构建上下文: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "2. 复制构建上下文（排除 .dockerignore 指定的文件）..."
# 复制除了 .dockerignore 排除的文件之外的所有文件
rsync -av --exclude-from=.dockerignore . "$BUILD_DIR/"

echo "3. 进入构建目录并检查..."
cd "$BUILD_DIR"

echo "4. 验证 Dockerfile 可读取..."
if [[ -f "Dockerfile" ]]; then
    echo "   ✓ Dockerfile 存在"
    echo "   Dockerfile 大小: $(ls -lh Dockerfile | awk '{print $5}')"
    echo "   Dockerfile 前5行:"
    head -5 Dockerfile | sed 's/^/     /'
else
    echo "   ✗ Dockerfile 不存在 - 这就是错误原因！"
    echo "   当前目录内容:"
    ls -la
    cd /
    rm -rf "$BUILD_DIR"
    exit 1
fi

echo
echo "5. 验证应用程序文件..."
echo "   app.py: $(test -f app.py && echo '✓ 存在' || echo '✗ 缺失')"
echo "   demo_tooltip.py: $(test -f demo_tooltip.py && echo '✓ 存在' || echo '✗ 缺失')"
echo "   requirements.txt: $(test -f requirements.txt && echo '✓ 存在' || echo '✗ 缺失')"

echo
echo "6. 验证静态资源..."
echo "   static/: $(test -d static && echo '✓ 存在' || echo '✗ 缺失')"
echo "   templates/: $(test -d templates && echo '✓ 存在' || echo '✗ 缺失')"

echo
echo "7. 验证测试数据..."
echo "   test/test_long_columns.csv: $(test -f test/test_long_columns.csv && echo '✓ 存在' || echo '✗ 缺失')"

echo
echo "8. 模拟 Docker 构建过程..."
echo "   FROM python:3.10.18-slim ..."
echo "   WORKDIR /app ..."
echo "   COPY PROJECT_INFO.txt VERSION.txt ./ ..."
if [[ -f "PROJECT_INFO.txt" && -f "VERSION.txt" ]]; then
    echo "     ✓ 基础文件复制成功"
else
    echo "     ✗ 基础文件复制失败"
fi

echo "   COPY requirements.txt ./ ..."
if [[ -f "requirements.txt" ]]; then
    echo "     ✓ 依赖文件复制成功"
    echo "     依赖列表:"
    grep -v '^#' requirements.txt | grep -v '^$' | sed 's/^/       /'
else
    echo "     ✗ 依赖文件复制失败"
fi

echo "   COPY static/ ./static/ ..."
if [[ -d "static" ]]; then
    echo "     ✓ 静态文件复制成功"
else
    echo "     ✗ 静态文件复制失败"
fi

echo "   COPY templates/ ./templates/ ..."
if [[ -d "templates" ]]; then
    echo "     ✓ 模板文件复制成功"
else
    echo "     ✗ 模板文件复制失败"
fi

echo "   COPY test/test_long_columns.csv ./test_long_columns.csv ..."
if [[ -f "test/test_long_columns.csv" ]]; then
    echo "     ✓ 测试数据复制成功"
else
    echo "     ✗ 测试数据复制失败"
fi

echo "   COPY app.py demo_tooltip.py ./ ..."
if [[ -f "app.py" && -f "demo_tooltip.py" ]]; then
    echo "     ✓ 应用程序文件复制成功"
else
    echo "     ✗ 应用程序文件复制失败"
fi

echo
echo "9. 验证构建上下文大小..."
CONTEXT_SIZE=$(du -sh . | awk '{print $1}')
echo "   构建上下文大小: $CONTEXT_SIZE"

echo
echo "10. 清理"
cd /
rm -rf "$BUILD_DIR"

echo
echo "=== 模拟构建完成 ==="
echo "如果所有检查都通过，Docker 构建应该会成功！"
