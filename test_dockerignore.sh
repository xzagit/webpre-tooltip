#!/bin/bash
# 测试 .dockerignore 配置是否正确

echo "=== .dockerignore 配置测试 ==="
echo

# 创建临时目录模拟 Docker 构建上下文
TEST_DIR="/tmp/docker_context_test"
echo "1. 创建测试目录: $TEST_DIR"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

echo "2. 复制项目文件到测试目录..."
cp -r . "$TEST_DIR/"

echo "3. 模拟 Docker 构建上下文过滤..."
cd "$TEST_DIR"

# 读取 .dockerignore 并应用规则
if [[ -f ".dockerignore" ]]; then
    echo "   应用 .dockerignore 规则..."
    
    # 简单模拟 dockerignore 处理 (实际 Docker 的逻辑更复杂)
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 跳过注释和空行
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*\; ]] && continue
        
        # 处理否定规则 (!)
        if [[ "$line" =~ ^! ]]; then
            pattern="${line#!}"
            echo "     包含: $pattern"
            continue
        fi
        
        # 普通排除规则
        if [[ -f "$line" || -d "$line" ]]; then
            echo "     排除: $line"
            rm -rf "$line" 2>/dev/null
        fi
        
        # 通配符规则
        if [[ "$line" == *"*"* ]]; then
            for file in $line; do
                if [[ -f "$file" || -d "$file" ]]; then
                    echo "     排除: $file (通配符)"
                    rm -rf "$file" 2>/dev/null
                fi
            done
        fi
    done < .dockerignore
else
    echo "   警告: .dockerignore 文件不存在"
fi

echo
echo "4. 检查关键文件是否保留:"
echo "   Dockerfile: $(test -f Dockerfile && echo '✓ 存在' || echo '✗ 被排除')"
echo "   Dockerfile.optimized: $(test -f Dockerfile.optimized && echo '✓ 存在' || echo '✗ 被排除')"
echo "   Dockerfile.light: $(test -f Dockerfile.light && echo '✓ 存在' || echo '✗ 被排除')"
echo "   app.py: $(test -f app.py && echo '✓ 存在' || echo '✗ 被排除')"
echo "   requirements.txt: $(test -f requirements.txt && echo '✓ 存在' || echo '✗ 被排除')"
echo "   VERSION.txt: $(test -f VERSION.txt && echo '✓ 存在' || echo '✗ 被排除')"
echo "   PROJECT_INFO.txt: $(test -f PROJECT_INFO.txt && echo '✓ 存在' || echo '✗ 被排除')"

echo
echo "5. 检查应该被排除的文件:"
echo "   .git: $(test -d .git && echo '✗ 未排除' || echo '✓ 已排除')"
echo "   __pycache__: $(test -d __pycache__ && echo '✗ 未排除' || echo '✓ 已排除')"
echo "   build_fast.sh: $(test -f build_fast.sh && echo '✗ 未排除' || echo '✓ 已排除')"
echo "   .dockerignore: $(test -f .dockerignore && echo '✗ 未排除' || echo '✓ 已排除')"

echo
echo "6. 当前测试目录内容:"
ls -la

echo
echo "7. 清理测试目录"
cd /
rm -rf "$TEST_DIR"

echo "=== 测试完成 ==="
