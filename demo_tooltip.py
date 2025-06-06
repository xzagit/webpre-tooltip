#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
工具提示功能快速演示脚本
"""

import webbrowser
import time
import os
import subprocess
import signal
import sys
from threading import Timer

def show_demo():
    """显示工具提示功能演示"""
    print("🎉 工具提示功能演示")
    print("=" * 50)
    
    # 启动Flask应用
    print("📡 正在启动Web应用...")
    
    # 使用子进程启动应用
    env = os.environ.copy()
    process = subprocess.Popen([
        sys.executable, "-c", 
        "from app import app; app.run(debug=False, host='127.0.0.1', port=10013)"
    ], cwd=os.path.dirname(os.path.abspath(__file__)))
    
    # 等待服务器启动
    time.sleep(3)
    
    print("🌐 应用已启动在 http://127.0.0.1:10013")
    
    try:
        # 自动打开浏览器
        print("🔄 正在打开浏览器...")
        webbrowser.open('http://127.0.0.1:10013')
        
        # 等待一会儿后打开演示页面
        time.sleep(2)
        print("🎯 打开工具提示演示页面...")
        webbrowser.open('http://127.0.0.1:10013/tooltip_demo')
        
        print("\n✨ 演示说明：")
        print("1. 主页：上传 test_long_columns.csv 文件测试工具提示")
        print("2. 数据页面：悬停在截断的列名和数据上查看完整内容")
        print("3. 演示页面：展示所有工具提示功能")
        print("\n按 Ctrl+C 退出演示")
        
        # 保持运行
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n👋 正在关闭演示...")
        process.terminate()
        process.wait()
        print("✅ 演示已结束")

if __name__ == "__main__":
    try:
        show_demo()
    except Exception as e:
        print(f"❌ 演示启动失败: {e}")
        print("💡 请手动运行: python app.py")
