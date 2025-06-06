# 🚀 Web数据预览器 v2.1 - 跨平台启动指南

## 📋 概述

本指南提供了在Windows、macOS和Linux系统上启动Web数据预览器的详细说明。所有脚本都支持自定义端口号，确保在不同环境下的灵活部署。

## 🎯 功能特性

- ✨ **智能工具提示** - 解决数据截断问题
- 🔒 **会话隔离** - 多用户安全并发
- 📊 **多格式支持** - CSV、JSON、Parquet、Excel
- 📈 **数据可视化** - 多种图表类型
- 🐳 **Docker支持** - 容器化部署

## 📱 系统要求

- **Python**: 3.8 或更高版本
- **内存**: 最低 512MB
- **磁盘**: 最低 100MB 可用空间
- **网络**: 用于访问Python包管理器

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
