#!/bin/bash
# Debug Docker 构建问题 - 模拟 Docker COPY 操作

echo "=== Docker 构建调试脚本 ==="
echo "检查 Dockerfile 中的 COPY 指令是否能找到对应文件"
echo

WORKDIR="/tmp/docker_build_test"
echo "1. 创建模拟构建目录: $WORKDIR"
mkdir -p "$WORKDIR"

echo "2. 检查源文件是否存在:"
echo "   app.py: $(ls -la app.py 2>/dev/null || echo '文件不存在')"
echo "   demo_tooltip.py: $(ls -la demo_tooltip.py 2>/dev/null || echo '文件不存在')"
echo "   requirements.txt: $(ls -la requirements.txt 2>/dev/null || echo '文件不存在')"
echo "   test/test_long_columns.csv: $(ls -la test/test_long_columns.csv 2>/dev/null || echo '文件不存在')"

echo
echo "3. 模拟 Docker COPY 操作:"

# 模拟 COPY PROJECT_INFO.txt VERSION.txt ./
echo "   COPY PROJECT_INFO.txt VERSION.txt ./"
if [[ -f "PROJECT_INFO.txt" && -f "VERSION.txt" ]]; then
    cp PROJECT_INFO.txt VERSION.txt "$WORKDIR/" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 文件不存在"
fi

# 模拟 COPY requirements.txt ./
echo "   COPY requirements.txt ./"
if [[ -f "requirements.txt" ]]; then
    cp requirements.txt "$WORKDIR/" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 文件不存在"
fi

# 模拟 COPY static/ ./static/
echo "   COPY static/ ./static/"
if [[ -d "static" ]]; then
    cp -r static "$WORKDIR/" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 目录不存在"
fi

# 模拟 COPY templates/ ./templates/
echo "   COPY templates/ ./templates/"
if [[ -d "templates" ]]; then
    cp -r templates "$WORKDIR/" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 目录不存在"
fi

# 模拟 COPY test/test_long_columns.csv ./test_long_columns.csv
echo "   COPY test/test_long_columns.csv ./test_long_columns.csv"
if [[ -f "test/test_long_columns.csv" ]]; then
    cp test/test_long_columns.csv "$WORKDIR/test_long_columns.csv" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 文件不存在"
fi

# 模拟 COPY app.py demo_tooltip.py ./
echo "   COPY app.py demo_tooltip.py ./"
if [[ -f "app.py" && -f "demo_tooltip.py" ]]; then
    cp app.py demo_tooltip.py "$WORKDIR/" && echo "     ✓ 成功"
else
    echo "     ✗ 失败 - 文件不存在"
    echo "     app.py 存在: $(test -f app.py && echo 'Yes' || echo 'No')"
    echo "     demo_tooltip.py 存在: $(test -f demo_tooltip.py && echo 'Yes' || echo 'No')"
fi

echo
echo "4. 检查构建后的文件结构:"
echo "   构建目录内容:"
ls -la "$WORKDIR/" 2>/dev/null || echo "   目录为空或不存在"

echo
echo "5. 检查 .dockerignore 是否影响文件复制:"
if [[ -f ".dockerignore" ]]; then
    echo "   .dockerignore 存在，检查是否排除了关键文件:"
    if grep -q "^app.py$" .dockerignore; then
        echo "     ✗ app.py 被 .dockerignore 排除"
    else
        echo "     ✓ app.py 未被明确排除"
    fi
    
    if grep -q "^\*.py$" .dockerignore; then
        echo "     ✗ 所有 .py 文件被 .dockerignore 排除"
    else
        echo "     ✓ .py 文件未被批量排除"
    fi
else
    echo "   .dockerignore 不存在"
fi

echo
echo "6. 清理测试目录"
rm -rf "$WORKDIR"

echo "=== 调试完成 ==="
