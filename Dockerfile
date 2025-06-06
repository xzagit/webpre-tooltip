# Web数据预览器 Dockerfile (中国版本 - 带镜像源)
# 基于Python 3.10.18构建的Flask数据查看器应用

FROM python:3.10.18-slim

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# 设置工作目录
WORKDIR /app

# 更换APT源为清华镜像源（适用于中国）
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list

# 安装系统依赖
# 包含字体支持和matplotlib所需的库
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libopenblas-dev \
    gfortran \
    fonts-dejavu-core \
    fonts-liberation \
    fontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置pip使用清华镜像源
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/ && \
    pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# 复制requirements.txt并安装Python依赖
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 复制应用程序文件
COPY app.py .
COPY demo_tooltip.py .
COPY test_tooltip_features.py .
COPY PROJECT_INFO.txt .
COPY README.md .

# 复制静态文件和模板
COPY static/ ./static/
COPY templates/ ./templates/

# 复制测试数据文件（如果存在）
COPY test_long_columns.csv .

# 复制文档目录
COPY docs/ ./docs/

# 创建uploads目录
RUN mkdir -p uploads

# 创建非root用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 设置目录权限
RUN chown -R appuser:appuser /app && \
    chmod -R 755 /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 10015

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:10015/', timeout=5)" || exit 1

# 启动命令
CMD ["python", "app.py"]
