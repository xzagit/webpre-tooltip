# 🚀 Web数据预览器 v2.1 - 现代化数据查看器

[![Docker](https://img.shields.io/badge/Docker-支持-blue.svg)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-green.svg)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-2.3+-red.svg)](https://flask.palletsprojects.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 概述

Web数据预览器是一个现代化的数据查看和分析工具，支持多种数据格式，提供直观的Web界面和强大的数据处理能力。本项目特别针对Docker构建进行了深度优化，实现了**50-70%的构建速度提升**。

## ✨ 核心特性

### 🎯 数据处理
- 📊 **多格式支持** - CSV、JSON、JSONL、Parquet、Excel等
- 🔄 **智能编码检测** - 自动识别文件编码
- 📈 **实时数据统计** - 即时生成数据报告
- 🎨 **数据可视化** - 多种图表类型

### 💡 用户体验  
- ✨ **智能工具提示** - 解决数据截断显示问题
- 🔒 **会话隔离** - 支持多用户安全并发访问
- 📱 **响应式设计** - 适配各种屏幕尺寸
- ⚡ **快速预览** - 大文件秒级加载

### 🚀 部署优势
- 🐳 **Docker优化** - 三种构建模式，最快50秒部署
- ☁️ **云原生支持** - 完整的容器化解决方案
- 🔧 **一键部署** - 智能构建脚本
- 📊 **性能监控** - 内置构建性能测试

## 🚀 快速开始

### 🐳 Docker部署 (推荐)

Docker部署是**最快最简单**的方式，我们提供了三种优化版本：

#### 方式一：一键快速部署

```bash
# 下载快速构建脚本
chmod +x build_fast.sh

# 轻量级构建 (推荐，50-70%更快)
./build_fast.sh -t light -c -r

# 访问应用
open http://localhost:10016
```

#### 方式二：Docker Compose

```bash
# 生产环境 (优化版)
docker-compose -f docker-compose.optimized.yml up -d

# 轻量级版本
docker-compose -f docker-compose.optimized.yml --profile light up -d

# 开发环境 (支持热重载)
docker-compose -f docker-compose.optimized.yml --profile dev up -d
```

#### 方式三：手动构建

```bash
# 启用 BuildKit 优化
export DOCKER_BUILDKIT=1

# 轻量级构建 (最快)
docker build -f Dockerfile.light -t webpre-tooltip:light .

# 优化构建 (最小镜像)
docker build -f Dockerfile.optimized -t webpre-tooltip:optimized .

# 运行容器
docker run -d --name webpre-tooltip -p 10015:10015 \
  -v $(pwd)/uploads:/app/uploads webpre-tooltip:light
```

### 🏃‍♂️ 原生部署

#### 方式一：通用启动

```bash
# Python直接启动 (支持端口参数)
python app.py --port 8080
python3 app.py --port 8080  # Linux/macOS

# 查看所有参数
python app.py --help
```

#### 方式二：平台专用脚本

## 🖥️ Windows 系统

### 启动脚本
```batch
start_webpre.bat [端口号]
```

### 使用示例
```batch
# 使用默认端口 10015
start_webpre.bat

# 使用自定义端口 8080
start_webpre.bat 8080

# 查看帮助
start_webpre.bat -h
```

### 系统要求
- Windows 10 或更高版本
- PowerShell 或 Command Prompt
- Python 3.8+ (建议从 https://www.python.org/ 下载)

### 常见问题
1. **Python未找到**: 确保Python已添加到PATH环境变量
2. **权限不足**: 以管理员身份运行命令提示符
3. **端口被占用**: 使用其他端口号或结束占用进程

## 🍎 macOS 系统

### 启动脚本
```bash
./start_webpre_macos.sh [端口号]
```

### 使用示例
```bash
# 使用默认端口 10015
./start_webpre_macos.sh

# 使用自定义端口 8080
./start_webpre_macos.sh 8080

# 查看帮助
./start_webpre_macos.sh -h
```

### 系统要求
- macOS 10.14 或更高版本
- Terminal.app 或 iTerm2
- Python 3.8+ (可通过 Homebrew 安装: `brew install python3`)

### 安装依赖 (如需要)
```bash
# 使用 Homebrew 安装 Python
brew install python3

# 或者下载安装包
# https://www.python.org/downloads/mac-osx/
```

### 常见问题
1. **权限被拒绝**: 确保脚本有执行权限 `chmod +x start_webpre_macos.sh`
2. **Python版本过低**: 使用 `python3` 而非 `python`
3. **端口被占用**: 使用 `lsof -i :端口号` 查看占用进程

## 🐧 Linux 系统

### 启动脚本
```bash
./start_webpre_linux.sh [端口号]
```

### 使用示例
```bash
# 使用默认端口 10015
./start_webpre_linux.sh

# 使用自定义端口 8080
./start_webpre_linux.sh 8080

# 查看帮助
./start_webpre_linux.sh -h
```

### 系统要求
- Linux 发行版 (Ubuntu 18.04+, CentOS 7+, 等)
- Bash shell
- Python 3.8+

### 安装依赖

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

#### CentOS/RHEL
```bash
sudo yum install python3 python3-pip
# 或者使用 dnf (较新版本)
sudo dnf install python3 python3-pip
```

#### Fedora
```bash
sudo dnf install python3 python3-pip
```

#### Arch Linux
```bash
sudo pacman -S python python-pip
```

### 常见问题
1. **权限被拒绝**: 
   ```bash
   chmod +x start_webpre_linux.sh
   ```
2. **依赖安装失败**: 检查网络连接和包管理器配置
3. **防火墙阻止**: 
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 端口号
   
   # CentOS/RHEL
   sudo firewall-cmd --add-port=端口号/tcp --permanent
   sudo firewall-cmd --reload
   ```

## 🐳 Docker 部署 (推荐)

如果您的系统支持Docker，推荐使用容器化部署：

```bash
# 构建镜像
docker build -t webpre-tooltip:v2.1 .

# 运行容器 (自定义端口)
docker run -d --name webpre-tooltip -p 8080:10015 webpre-tooltip:v2.1

# 使用 Docker Compose
docker-compose up -d
```

## ⚡ 快速启动命令

### 所有平台通用
```bash
# Python直接启动 (支持端口参数)
python app.py --port 8080
python3 app.py --port 8080  # Linux/macOS

# 查看所有参数
python app.py --help
```

### 参数说明
- `--port, -p`: 指定端口号 (1024-65535)
- `--host`: 指定监听地址 (默认: 0.0.0.0)
- `--debug`: 启用调试模式

## 🌐 访问方式

启动成功后，可通过以下方式访问：

- **本地访问**: http://127.0.0.1:端口号
- **局域网访问**: http://您的IP地址:端口号
- **默认端口**: 10015

### 示例URL
```
http://127.0.0.1:10015    # 默认端口
http://127.0.0.1:8080     # 自定义端口
http://192.168.1.100:8080 # 局域网访问
```

## 🔧 环境变量配置

可以通过环境变量覆盖默认配置：

```bash
# 设置端口
export FLASK_PORT=8080

# 设置调试模式
export FLASK_DEBUG=true

# 设置生产模式
export FLASK_ENV=production
```

### Windows 环境变量
```batch
set FLASK_PORT=8080
set FLASK_DEBUG=false
```

## 🐛 故障排除

### 通用问题

#### 1. Python未找到
**症状**: "python"不是内部或外部命令
**解决**:
- Windows: 重新安装Python并勾选"Add to PATH"
- macOS: 使用 `python3` 而非 `python`
- Linux: 安装python3包

#### 2. 端口被占用
**症状**: Address already in use
**解决**:
```bash
# 查找占用进程
# Windows
netstat -ano | findstr :端口号

# macOS/Linux
lsof -i :端口号

# 或使用其他端口号
```

#### 3. 依赖安装失败
**症状**: pip install 失败
**解决**:
```bash
# 升级pip
python -m pip install --upgrade pip

# 使用清华源 (中国用户)
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/

# 用户安装 (避免权限问题)
pip install --user -r requirements.txt
```

#### 4. 权限问题
**症状**: Permission denied
**解决**:
```bash
# 添加执行权限 (Linux/macOS)
chmod +x start_webpre_*.sh

# 用户安装Python包
pip install --user package_name
```

### 平台特定问题

#### Windows
- **杀毒软件阻止**: 将项目文件夹添加到杀毒软件白名单
- **PowerShell执行策略**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

#### macOS
- **Gatekeeper警告**: `xattr -d com.apple.quarantine start_webpre_macos.sh`
- **Python证书问题**: 运行 `/Applications/Python\ 3.x/Install\ Certificates.command`

#### Linux
- **SELinux阻止**: `sudo setsebool -P httpd_can_network_connect 1`
- **防火墙设置**: 确保端口在防火墙中开放

## 🔧 故障排除

### Docker 相关问题

#### "python: can't open file '/app/app.py'" 错误

**问题**：容器启动时找不到 app.py 文件

**原因**：`.dockerignore` 配置不当或健康检查依赖缺失

**解决方案**：

1. 检查 `.dockerignore` 确保未排除重要文件
2. 确保 `requirements.txt` 包含所有必要依赖
3. 使用修复后的 Dockerfile（已使用 urllib.request 替代 requests）

**验证修复**：

```bash
# 运行验证脚本
./validate_docker_fix.sh

# 如果所有检查通过，尝试构建
docker build -t webpre-tooltip .
docker run -d -p 10015:10015 --name webpre-test webpre-tooltip
```

#### 构建速度慢

**解决方案**：使用优化版 Dockerfile

```bash
./build_fast.sh optimized  # 使用优化版构建
./build_fast.sh light      # 使用轻量版构建
```

### 应用性能问题

- **大文件上传**：建议文件大小 < 100MB
- **内存不足**：调整 Docker 内存限制或使用数据采样
- **中文显示**：容器已配置中文字体支持

### 常见运行错误

- **端口占用**：使用 `docker ps` 检查运行中的容器
- **权限问题**：确保 uploads 目录可写
- **依赖错误**：重新构建镜像获取最新依赖

## 🐳 Docker优化详解

我们针对Docker构建进行了深度优化，解决了原始构建中的性能瓶颈：

### 🔧 优化技术

1. **多阶段构建** - 分离编译环境和运行环境
2. **预编译Wheels** - 避免本地编译大型包
3. **构建缓存优化** - 智能文件复制顺序
4. **镜像层优化** - 减少层数和体积
5. **BuildKit加速** - 并行构建和缓存挂载

### 📊 性能对比

| 构建类型 | 构建时间 | 镜像大小 | 适用场景 |
|---------|---------|---------|---------|
| 原始版本 | ~5分钟 | ~1.2GB | 特殊编译需求 |
| 优化版本 | ~2分钟 | ~800MB | 生产环境 |
| 轻量级版本 | ~1分钟 | ~600MB | 快速部署 |

### 🎯 选择建议

- **生产环境**: 使用 `Dockerfile.optimized` (最安全最小)
- **快速部署**: 使用 `Dockerfile.light` (最快速)
- **开发调试**: 使用开发模式的Docker Compose

### 🛠️ 构建脚本功能

```bash
# 查看所有选项
./build_fast.sh --help

# 性能测试对比
./test_build_performance.sh

# 清理旧镜像
./build_fast.sh --clean
```

### 🚀 Docker快速命令

```bash
# 一键轻量级构建并运行
./build_fast.sh -t light -c -r

# 开发环境 (支持热重载)
docker-compose -f docker-compose.optimized.yml --profile dev up -d

# 查看构建性能
./test_build_performance.sh

# 清理所有Docker资源
docker system prune -a
```

## 📖 使用指南

### 🔄 数据上传

1. 访问Web界面
2. 点击"选择文件"或拖拽文件到上传区域
3. 支持的格式：CSV、JSON、JSONL、Parquet、Excel
4. 自动检测编码和格式

### 📊 数据查看

- **表格视图**: 分页浏览数据
- **统计信息**: 自动生成数据报告
- **可视化**: 多种图表类型
- **导出功能**: 支持多种格式导出

### 💡 工具提示

- 鼠标悬停在列标题上查看完整列名
- 点击数据单元格查看完整内容
- 侧边栏显示列信息和统计

## 🔧 高级配置

### Docker环境变量

```bash
# 在docker run中使用
docker run -e FLASK_PORT=8080 -e FLASK_DEBUG=false webpre-tooltip:light

# 在docker-compose.yml中设置
environment:
  - FLASK_ENV=production
  - MAX_CONTENT_LENGTH=200
```

### 性能调优

```bash
# 设置上传限制 (MB)
export MAX_CONTENT_LENGTH=100

# 设置会话超时时间 (秒)
export SESSION_TIMEOUT=3600

# 启用缓存
export ENABLE_CACHE=true
```

## 📚 项目结构

```
webpre-tooltip/
├── app.py                          # 主应用文件
├── requirements.txt                 # Python依赖 (原始)
├── requirements.optimized.txt       # Python依赖 (优化版)
├── Dockerfile                       # Docker构建文件 (原始)
├── Dockerfile.light                 # Docker构建文件 (轻量级)
├── Dockerfile.optimized             # Docker构建文件 (优化版)
├── docker-compose.optimized.yml     # Docker Compose配置
├── build_fast.sh                    # 快速构建脚本
├── test_build_performance.sh        # 性能测试脚本
├── .dockerignore                    # Docker忽略文件
├── .gitignore                       # Git忽略文件
├── DOCKER_OPTIMIZATION.md           # Docker优化文档
├── static/                          # 静态资源
│   ├── css/
│   └── js/
├── templates/                       # 模板文件
├── uploads/                         # 上传文件目录
├── test/                           # 测试文件
└── docs/                           # 文档目录
```

## 🚨 Docker故障排除

### 构建问题

#### 构建过慢

```bash
# 使用轻量级版本
./build_fast.sh -t light

# 清理Docker缓存
docker system prune -a

# 启用BuildKit
export DOCKER_BUILDKIT=1
```

#### 镜像过大

```bash
# 使用优化版本
./build_fast.sh -t optimized

# 查看镜像层
docker history webpre-tooltip:light

# 多阶段构建
docker build -f Dockerfile.optimized -t webpre-tooltip:optimized .
```

### 运行问题

#### 容器无法启动

```bash
# 查看日志
docker logs webpre-tooltip

# 检查端口占用
docker ps -a

# 重新构建
./build_fast.sh -t light --no-cache
```

#### 性能问题

```bash
# 查看资源使用
docker stats webpre-tooltip

# 增加内存限制
docker run -m 1g webpre-tooltip:light

# 使用优化配置
docker-compose -f docker-compose.optimized.yml up -d
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🆘 获取帮助

- 📖 查看 [Docker优化指南](DOCKER_OPTIMIZATION.md) 获取详细优化说明
- 📚 查看 [文档目录](docs/) 获取使用指南
- 🐛 在 [Issues](../../issues) 中报告问题
- 💬 在 [Discussions](../../discussions) 中讨论功能需求

## 🔗 相关链接

- [Docker优化指南](DOCKER_OPTIMIZATION.md)
- [工具提示实现指南](docs/TOOLTIP_IMPLEMENTATION_GUIDE.md)
- [项目完成报告](docs/TOOLTIP_COMPLETION_REPORT.md)

---

**🎉 享受快速的数据预览体验！**

通过Docker优化，您现在可以：
- ⚡ **50-70%更快的构建速度**
- 🎯 **三种部署模式选择**
- 🛠️ **一键部署脚本**
- 📊 **内置性能监控**

立即体验：`./build_fast.sh -t light -c -r`
