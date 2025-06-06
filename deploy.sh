#!/bin/bash
# 快速部署脚本

set -e

echo "=== Web数据预览器 v2.1 快速部署 ==="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 停止已存在的容器
if [ "$(docker ps -q -f name=webpre-tooltip)" ]; then
    echo "停止已存在的容器..."
    docker stop webpre-tooltip
fi

if [ "$(docker ps -aq -f name=webpre-tooltip)" ]; then
    echo "删除已存在的容器..."
    docker rm webpre-tooltip
fi

# 构建镜像
echo "构建Docker镜像..."
docker build -t webpre-tooltip:v2.1 .

# 运行容器
echo "启动容器..."
docker run -d \
    --name webpre-tooltip \
    --restart unless-stopped \
    -p 10015:10015 \
    -v $(pwd)/uploads:/app/uploads \
    webpre-tooltip:v2.1

# 等待容器启动
echo "等待应用启动..."
sleep 10

# 检查容器状态
if [ "$(docker ps -q -f name=webpre-tooltip)" ]; then
    echo "✓ 部署成功！"
    echo "访问地址: http://localhost:10015"
    echo "查看日志: docker logs webpre-tooltip"
    echo "停止应用: docker stop webpre-tooltip"
else
    echo "✗ 部署失败，请检查日志: docker logs webpre-tooltip"
    exit 1
fi
