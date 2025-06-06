#!/bin/bash
# Docker镜像构建脚本

echo "=== Web数据预览器 Docker镜像构建 ==="

# 检查是否在中国
echo "请选择构建版本:"
echo "1) 中国版本 (使用清华镜像源，适合国内服务器)"
echo "2) 国际版本 (使用官方源，适合海外服务器)"
read -p "请输入选择 (1-2): " choice

case $choice in
    1)
        echo "构建中国版本..."
        docker build -t webpre-tooltip:v2.1 .
        ;;
    2)
        echo "构建国际版本..."
        docker build -f Dockerfile_backup -t webpre-tooltip:v2.1 .
        ;;
    *)
        echo "无效选择，使用默认中国版本..."
        docker build -t webpre-tooltip:v2.1 .
        ;;
esac

echo "构建完成！"
echo "运行容器: docker run -d --name webpre-tooltip -p 10015:10015 webpre-tooltip:v2.1"
echo "或使用: docker-compose up -d"
