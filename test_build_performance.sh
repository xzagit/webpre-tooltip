#!/bin/bash
# Docker 构建性能测试脚本
# 比较不同构建方式的性能

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

# 启用 BuildKit
export DOCKER_BUILDKIT=1

# 测试结果文件
RESULTS_FILE="build_performance_$(date +%Y%m%d_%H%M%S).txt"

log_info "开始 Docker 构建性能测试"
log_info "结果将保存到: $RESULTS_FILE"

echo "Docker 构建性能测试报告" > $RESULTS_FILE
echo "测试时间: $(date)" >> $RESULTS_FILE
echo "=====================================" >> $RESULTS_FILE
echo "" >> $RESULTS_FILE

# 清理环境
log_info "清理环境..."
docker system prune -f >/dev/null 2>&1

# 测试函数
test_build() {
    local name=$1
    local dockerfile=$2
    local tag=$3
    
    log_info "测试 $name 构建..."
    
    # 记录开始时间
    local start_time=$(date +%s)
    
    # 执行构建
    if docker build -f $dockerfile -t $tag . >/dev/null 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # 获取镜像大小
        local size=$(docker images $tag --format "{{.Size}}")
        
        log_success "$name 构建完成 - 耗时: ${duration}秒, 大小: $size"
        
        # 写入结果
        echo "$name:" >> $RESULTS_FILE
        echo "  构建时间: ${duration}秒" >> $RESULTS_FILE
        echo "  镜像大小: $size" >> $RESULTS_FILE
        echo "  Dockerfile: $dockerfile" >> $RESULTS_FILE
        echo "" >> $RESULTS_FILE
        
        return $duration
    else
        log_warn "$name 构建失败"
        echo "$name: 构建失败" >> $RESULTS_FILE
        echo "" >> $RESULTS_FILE
        return 999
    fi
}

# 测试原始版本
test_build "原始版本" "Dockerfile" "webpre-tooltip:original"
original_time=$?

# 测试优化版本
test_build "优化版本" "Dockerfile.optimized" "webpre-tooltip:optimized"
optimized_time=$?

# 测试轻量级版本
test_build "轻量级版本" "Dockerfile.light" "webpre-tooltip:light"
light_time=$?

# 计算性能提升
echo "性能对比:" >> $RESULTS_FILE
echo "=====================================" >> $RESULTS_FILE

if [[ $original_time -ne 999 && $optimized_time -ne 999 ]]; then
    local improvement=$((original_time - optimized_time))
    local percentage=$((improvement * 100 / original_time))
    echo "优化版本相比原始版本: 节省 ${improvement}秒 (${percentage}%)" >> $RESULTS_FILE
    log_success "优化版本相比原始版本节省: ${improvement}秒 (${percentage}%)"
fi

if [[ $original_time -ne 999 && $light_time -ne 999 ]]; then
    local improvement=$((original_time - light_time))
    local percentage=$((improvement * 100 / original_time))
    echo "轻量级版本相比原始版本: 节省 ${improvement}秒 (${percentage}%)" >> $RESULTS_FILE
    log_success "轻量级版本相比原始版本节省: ${improvement}秒 (${percentage}%)"
fi

# 显示镜像大小对比
echo "" >> $RESULTS_FILE
echo "镜像大小对比:" >> $RESULTS_FILE
echo "=====================================" >> $RESULTS_FILE
docker images | grep "webpre-tooltip" | sort -k2 >> $RESULTS_FILE

log_info "性能测试完成，详细结果请查看: $RESULTS_FILE"

# 显示总结
echo ""
log_info "=== 测试总结 ==="
docker images | grep "webpre-tooltip" | sort -k2
