# Docker 构建优化指南

## 🚀 构建速度优化总结

原始 Dockerfile 存在以下性能问题：
1. **系统依赖安装慢** - 安装了大量编译工具
2. **Python包编译慢** - pandas、numpy、matplotlib需要本地编译
3. **缺乏多阶段构建** - 编译工具进入了运行时镜像
4. **Docker层缓存不优化** - 文件复制顺序导致缓存失效
5. **构建上下文过大** - 包含了不必要的文件

## 📁 优化版本说明

### 1. Dockerfile.light (推荐)
- **特点**: 使用预编译wheels，避免本地编译
- **优势**: 构建速度最快，镜像较小
- **适用**: 生产环境、快速部署

### 2. Dockerfile.optimized  
- **特点**: 多阶段构建，分离编译和运行环境
- **优势**: 镜像最小，安全性高
- **适用**: 生产环境、资源受限环境

### 3. Dockerfile (原始)
- **特点**: 原始版本，本地编译所有包
- **适用**: 需要特殊编译选项的场景

## 🛠️ 使用方法

### 快速开始

```bash
# 轻量级构建（推荐）
./build_fast.sh -t light -c -r

# 优化版构建
./build_fast.sh -t optimized -c -r

# 清理旧镜像
./build_fast.sh --clean
```

### Docker Compose

```bash
# 生产环境
docker-compose -f docker-compose.optimized.yml up

# 轻量级版本
docker-compose -f docker-compose.optimized.yml --profile light up

# 开发环境
docker-compose -f docker-compose.optimized.yml --profile dev up
```

### 手动构建

```bash
# 启用 BuildKit
export DOCKER_BUILDKIT=1

# 轻量级构建
docker build -f Dockerfile.light -t webpre-tooltip:light .

# 多阶段构建
docker build -f Dockerfile.optimized -t webpre-tooltip:optimized .
```

## ⚡ 性能优化技巧

### 1. 利用Docker缓存
```bash
# 构建时使用缓存
docker build --cache-from webpre-tooltip:light -t webpre-tooltip:light .
```

### 2. 使用.dockerignore
确保 `.dockerignore` 文件存在，减少构建上下文大小。

### 3. 固定版本号
使用 `requirements.optimized.txt` 中的固定版本，避免版本解析时间。

### 4. 预编译wheels
```bash
# 强制使用预编译包
pip install --only-binary=all -r requirements.txt
```

## 📊 性能测试

运行性能测试脚本：
```bash
./test_build_performance.sh
```

预期性能提升：
- **轻量级版本**: 比原始版本快 50-70%
- **优化版本**: 比原始版本快 40-60%
- **镜像大小**: 减少 30-50%

## 🔧 高级优化

### 1. 使用多阶段构建缓存
```dockerfile
# 在构建阶段使用缓存挂载
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

### 2. 并行安装
```dockerfile
# 并行安装系统依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg1 pkg2 pkg3 && \
    rm -rf /var/lib/apt/lists/*
```

### 3. 镜像层优化
- 合并RUN命令减少层数
- 清理安装缓存
- 删除不必要的文件

## 🚨 注意事项

1. **网络环境**: 确保使用了国内镜像源
2. **资源限制**: 为Docker分配足够的内存和CPU
3. **磁盘空间**: 定期清理Docker镜像和缓存
4. **版本兼容**: 固定版本号可能需要定期更新

## 📈 监控构建性能

```bash
# 查看构建历史
docker history webpre-tooltip:light

# 查看镜像大小
docker images | grep webpre-tooltip

# 清理系统
docker system prune -a
```

## 🔄 持续优化建议

1. **定期更新基础镜像**
2. **监控包版本更新**
3. **测试新的优化技术**
4. **关注Docker版本更新**

通过这些优化，Docker构建时间可以从原来的几分钟减少到几十秒，显著提升开发效率！
