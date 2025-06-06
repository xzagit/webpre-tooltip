#!/bin/bash
# 验证 Docker 容器启动问题

echo "=== Docker 容器启动问题诊断 ==="
echo

# 检查当前工作目录的文件
echo "1. 当前目录结构:"
echo "   工作目录: $(pwd)"
echo "   文件列表:"
ls -la

echo
echo "2. 检查关键文件:"
echo "   app.py 存在: $(test -f app.py && echo 'Yes' || echo 'No')"
echo "   demo_tooltip.py 存在: $(test -f demo_tooltip.py && echo 'Yes' || echo 'No')"
echo "   requirements.txt 存在: $(test -f requirements.txt && echo 'Yes' || echo 'No')"

if [[ -f "app.py" ]]; then
    echo "   app.py 文件大小: $(ls -lh app.py | awk '{print $5}')"
    echo "   app.py 权限: $(ls -l app.py | awk '{print $1}')"
    echo "   app.py 前5行:"
    head -5 app.py | sed 's/^/     /'
else
    echo "   ✗ app.py 文件不存在！"
fi

echo
echo "3. 测试 Python 执行:"
if [[ -f "app.py" ]]; then
    echo "   尝试语法检查:"
    python -m py_compile app.py 2>&1 && echo "     ✓ app.py 语法正确" || echo "     ✗ app.py 语法错误"
    
    echo "   检查 Flask 导入:"
    python -c "from flask import Flask; print('Flask 导入成功')" 2>&1 && echo "     ✓ Flask 可用" || echo "     ✗ Flask 不可用"
    
    echo "   检查应用启动配置:"
    python -c "
import sys
sys.path.insert(0, '.')
try:
    from app import app
    print('     ✓ Flask 应用对象创建成功')
    print(f'     Flask 应用名称: {app.name}')
except Exception as e:
    print(f'     ✗ Flask 应用创建失败: {e}')
" 2>&1
else
    echo "   ✗ 无法测试，app.py 不存在"
fi

echo
echo "4. 环境变量检查:"
echo "   FLASK_APP: ${FLASK_APP:-'未设置'}"
echo "   FLASK_ENV: ${FLASK_ENV:-'未设置'}"
echo "   PYTHONPATH: ${PYTHONPATH:-'未设置'}"
echo "   PATH: $PATH"

echo
echo "5. 网络和端口检查:"
echo "   监听端口 10015:"
netstat -ln 2>/dev/null | grep :10015 || echo "     端口 10015 未被监听"

echo
echo "=== 诊断完成 ==="
