#!/bin/bash
# Docker 快速构建脚本
# 使用各种优化技术加速构建过程

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
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

# 显示帮助信息
show_help() {
    echo "Docker 快速构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -t, --type TYPE     构建类型 (light|optimized|original) [默认: light]"
    echo "  -c, --cache         启用构建缓存"
    echo "  -p, --push          构建后推送到镜像仓库"
    echo "  -r, --run           构建后立即运行"
    echo "  -d, --dev           开发模式构建"
    echo "  --clean             清理旧镜像和缓存"
    echo "  --no-cache          禁用Docker缓存"
    echo "  -h, --help          显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -t light -c -r    # 轻量级构建，启用缓存，构建后运行"
    echo "  $0 -t optimized      # 优化版构建"
    echo "  $0 --clean           # 清理旧镜像"
}

# 默认值
BUILD_TYPE="light"
USE_CACHE=false
PUSH_IMAGE=false
RUN_AFTER_BUILD=false
DEV_MODE=false
CLEAN_ONLY=false
NO_CACHE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -c|--cache)
            USE_CACHE=true
            shift
            ;;
        -p|--push)
            PUSH_IMAGE=true
            shift
            ;;
        -r|--run)
            RUN_AFTER_BUILD=true
            shift
            ;;
        -d|--dev)
            DEV_MODE=true
            shift
            ;;
        --clean)
            CLEAN_ONLY=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查Docker是否运行
if ! docker info >/dev/null 2>&1; then
    log_error "Docker 未运行，请先启动 Docker"
    exit 1
fi

# 启用 BuildKit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# 清理函数
cleanup() {
    log_info "清理旧镜像和缓存..."
    
    # 清理悬空镜像
    docker image prune -f
    
    # 清理旧的webpre-tooltip镜像
    docker images | grep "webpre-tooltip" | grep -v "latest" | awk '{print $3}' | xargs -r docker rmi -f
    
    # 清理构建缓存
    docker builder prune -f
    
    log_success "清理完成"
}

# 如果只是清理，执行后退出
if [[ "$CLEAN_ONLY" == true ]]; then
    cleanup
    exit 0
fi

# 验证构建类型
case $BUILD_TYPE in
    light|optimized|original)
        ;;
    *)
        log_error "无效的构建类型: $BUILD_TYPE"
        log_info "支持的类型: light, optimized, original"
        exit 1
        ;;
esac

# 设置 Dockerfile 和镜像名称
case $BUILD_TYPE in
    light)
        DOCKERFILE="Dockerfile.light"
        IMAGE_NAME="webpre-tooltip:light"
        ;;
    optimized)
        DOCKERFILE="Dockerfile.optimized"
        IMAGE_NAME="webpre-tooltip:optimized"
        ;;
    original)
        DOCKERFILE="Dockerfile"
        IMAGE_NAME="webpre-tooltip:original"
        ;;
esac

# 构建参数
BUILD_ARGS=""
if [[ "$NO_CACHE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --no-cache"
fi

if [[ "$USE_CACHE" == true ]]; then
    BUILD_ARGS="$BUILD_ARGS --cache-from $IMAGE_NAME"
fi

# 开始构建
log_info "开始构建 Docker 镜像..."
log_info "构建类型: $BUILD_TYPE"
log_info "Dockerfile: $DOCKERFILE"
log_info "镜像名称: $IMAGE_NAME"

# 记录构建开始时间
START_TIME=$(date +%s)

# 执行构建
log_info "执行 Docker 构建..."
if docker build $BUILD_ARGS -f $DOCKERFILE -t $IMAGE_NAME .; then
    # 计算构建时间
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    
    log_success "构建完成! 耗时: ${BUILD_TIME}秒"
    
    # 显示镜像信息
    log_info "镜像信息:"
    docker images | grep "webpre-tooltip" | head -5
else
    log_error "构建失败!"
    exit 1
fi

# 推送镜像
if [[ "$PUSH_IMAGE" == true ]]; then
    log_info "推送镜像到仓库..."
    docker push $IMAGE_NAME
    log_success "镜像推送完成"
fi

# 运行容器
if [[ "$RUN_AFTER_BUILD" == true ]]; then
    log_info "启动容器..."
    
    # 停止已存在的容器
    CONTAINER_NAME="webpre-tooltip-${BUILD_TYPE}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    
    # 选择端口
    case $BUILD_TYPE in
        light)
            PORT="10016"
            ;;
        optimized)
            PORT="10015"
            ;;
        original)
            PORT="10018"
            ;;
    esac
    
    # 运行容器
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:10015 \
        -v $(pwd)/uploads:/app/uploads \
        $IMAGE_NAME
    
    log_success "容器已启动，访问地址: http://localhost:$PORT"
fi

log_success "所有操作完成!"
