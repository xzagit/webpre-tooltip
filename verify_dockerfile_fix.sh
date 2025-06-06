#!/bin/bash
# Dockerfile 修复验证脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info "开始验证Dockerfile修复..."

# 检查关键文件是否存在
FILES_TO_CHECK=(
    "app.py"
    "demo_tooltip.py"
    "PROJECT_INFO.txt"
    "VERSION.txt"
    "static/"
    "templates/"
    "test/test_long_columns.csv"
    "requirements.txt"
)

log_info "检查必要文件..."
for file in "${FILES_TO_CHECK[@]}"; do
    if [[ -e "$file" ]]; then
        log_success "✓ $file 存在"
    else
        log_error "✗ $file 不存在"
        exit 1
    fi
done

# 检查.dockerignore配置
log_info "检查.dockerignore配置..."
if grep -q "!PROJECT_INFO.txt" .dockerignore; then
    log_success "✓ .dockerignore已正确配置PROJECT_INFO.txt"
else
    log_warn "! .dockerignore可能需要调整"
fi

if grep -q "!VERSION.txt" .dockerignore; then
    log_success "✓ .dockerignore已正确配置VERSION.txt"
else
    log_warn "! .dockerignore可能需要调整"
fi

# 检查Dockerfile语法
log_info "检查Dockerfile语法..."
DOCKERFILES=("Dockerfile" "Dockerfile.light" "Dockerfile.optimized")

for dockerfile in "${DOCKERFILES[@]}"; do
    if [[ -f "$dockerfile" ]]; then
        # 检查COPY语句是否正确
        if grep -q "COPY app.py demo_tooltip.py ./" "$dockerfile"; then
            log_success "✓ $dockerfile 中app.py复制语句正确"
        else
            log_error "✗ $dockerfile 中app.py复制语句可能有问题"
        fi
        
        # 检查是否有非法的COPY语句
        if grep -q "COPY.*\*\.py" "$dockerfile"; then
            log_warn "! $dockerfile 使用通配符复制，可能包含不需要的文件"
        fi
    else
        log_warn "! $dockerfile 不存在"
    fi
done

# 生成测试构建命令
log_info "生成测试命令..."
echo ""
echo "如果Docker已安装，可以使用以下命令测试："
echo ""
echo "# 测试轻量级版本"
echo "docker build -f Dockerfile.light -t webpre-tooltip:test-light ."
echo ""
echo "# 测试优化版本"
echo "docker build -f Dockerfile.optimized -t webpre-tooltip:test-optimized ."
echo ""
echo "# 测试原始版本"
echo "docker build -f Dockerfile -t webpre-tooltip:test-original ."
echo ""
echo "# 或使用快速构建脚本"
echo "./build_fast.sh -t light"

log_success "Dockerfile修复验证完成！"
