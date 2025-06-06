#!/bin/bash
# 精确的 Docker 构建上下文验证脚本

echo "=== 精确 Docker 构建上下文验证 ==="
echo

# 检查关键文件是否被 .dockerignore 排除
echo "1. 检查关键文件与 .dockerignore 规则匹配..."

# 定义关键文件列表
CRITICAL_FILES=(
    "Dockerfile"
    "app.py"
    "demo_tooltip.py" 
    "requirements.txt"
    "VERSION.txt"
    "PROJECT_INFO.txt"
    "test/test_long_columns.csv"
)

echo "   关键文件列表:"
for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo "     ✓ $file 存在"
    else
        echo "     ✗ $file 不存在"
    fi
done

echo
echo "2. 分析 .dockerignore 规则..."
if [[ -f ".dockerignore" ]]; then
    echo "   .dockerignore 内容："
    grep -v '^#' .dockerignore | grep -v '^$' | sed 's/^/     /'
    
    echo
    echo "3. 测试每个关键文件是否会被排除..."
    
    # 测试 Dockerfile
    echo "   Dockerfile:"
    if grep -q '^Dockerfile$' .dockerignore; then
        echo "     ✗ 被明确排除"
    elif grep -q '^Dockerfile\*' .dockerignore; then
        echo "     ⚠️  可能被通配符排除"
    else
        echo "     ✓ 不会被排除"
    fi
    
    # 测试 app.py
    echo "   app.py:"
    if grep -q '^app\.py$' .dockerignore; then
        echo "     ✗ 被明确排除"
    elif grep -q '^\*\.py$' .dockerignore; then
        echo "     ✗ 被 *.py 排除"
    else
        echo "     ✓ 不会被排除"
    fi
    
    # 测试 test/test_long_columns.csv
    echo "   test/test_long_columns.csv:"
    if grep -q '^test/test_long_columns\.csv$' .dockerignore; then
        echo "     ✗ 被明确排除"
    elif grep -q '^\*\.csv$' .dockerignore; then
        if grep -q '^!test/test_long_columns\.csv$' .dockerignore; then
            echo "     ✓ 被 *.csv 排除但有例外规则"
        else
            echo "     ✗ 被 *.csv 排除且无例外规则"
        fi
    else
        echo "     ✓ 不会被排除"
    fi
    
else
    echo "   .dockerignore 不存在"
fi

echo
echo "4. 手动构建上下文测试..."
BUILD_CONTEXT="/tmp/manual_docker_context"
rm -rf "$BUILD_CONTEXT"
mkdir -p "$BUILD_CONTEXT"

# 复制基础文件
echo "   复制基础文件..."
cp Dockerfile "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ Dockerfile" || echo "     ✗ Dockerfile"
cp app.py "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ app.py" || echo "     ✗ app.py"  
cp demo_tooltip.py "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ demo_tooltip.py" || echo "     ✗ demo_tooltip.py"
cp requirements.txt "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ requirements.txt" || echo "     ✗ requirements.txt"
cp VERSION.txt "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ VERSION.txt" || echo "     ✗ VERSION.txt"
cp PROJECT_INFO.txt "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ PROJECT_INFO.txt" || echo "     ✗ PROJECT_INFO.txt"

# 复制目录
echo "   复制目录..."
cp -r static "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ static/" || echo "     ✗ static/"
cp -r templates "$BUILD_CONTEXT/" 2>/dev/null && echo "     ✓ templates/" || echo "     ✗ templates/"

# 复制测试文件
echo "   复制测试文件..."
mkdir -p "$BUILD_CONTEXT/test" 2>/dev/null
cp test/test_long_columns.csv "$BUILD_CONTEXT/test/" 2>/dev/null && echo "     ✓ test/test_long_columns.csv" || echo "     ✗ test/test_long_columns.csv"

echo
echo "5. 验证构建上下文..."
cd "$BUILD_CONTEXT"
echo "   构建上下文内容:"
ls -la

echo
echo "6. 模拟 Dockerfile 执行验证..."
if [[ -f "Dockerfile" ]]; then
    echo "   ✓ 可以读取 Dockerfile"
    
    # 模拟关键的 COPY 命令
    echo "   模拟 COPY 命令:"
    
    echo "     COPY PROJECT_INFO.txt VERSION.txt ./"
    [[ -f "PROJECT_INFO.txt" && -f "VERSION.txt" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
    echo "     COPY requirements.txt ./"
    [[ -f "requirements.txt" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
    echo "     COPY static/ ./static/"
    [[ -d "static" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
    echo "     COPY templates/ ./templates/"
    [[ -d "templates" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
    echo "     COPY test/test_long_columns.csv ./test_long_columns.csv"
    [[ -f "test/test_long_columns.csv" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
    echo "     COPY app.py demo_tooltip.py ./"
    [[ -f "app.py" && -f "demo_tooltip.py" ]] && echo "       ✓ 成功" || echo "       ✗ 失败"
    
else
    echo "   ✗ 无法读取 Dockerfile - 这就是 Docker 错误的原因！"
fi

echo
echo "7. 清理"
cd /
rm -rf "$BUILD_CONTEXT"

echo
echo "=== 验证完成 ==="
