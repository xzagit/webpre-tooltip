#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
会话隔离演示脚本

本脚本演示如何使用支持会话隔离的数据查看器。
在浏览器中，会话是通过cookie自动管理的。
如果使用API方式访问，则需要保持会话cookie。
"""

import requests
import webbrowser
import time
import os

# 服务器URL配置
SERVER_URL = "http://localhost:1015"

def demo_browser_access():
    """演示使用浏览器访问"""
    print("正在打开浏览器...")
    webbrowser.open(SERVER_URL)
    print("提示: 尝试在不同的浏览器或隐私模式打开相同的链接，将看到不同的会话")
    print("每个会话都是相互隔离的，上传的文件互不影响")

def demo_api_access():
    """演示使用API访问（保持会话）"""
    # 创建会话对象
    session = requests.Session()
    
    # 1. 访问首页获取Cookie
    print("1. 创建会话并获取Cookie")
    response = session.get(SERVER_URL)
    
    # 显示会话cookie
    cookies = session.cookies.get_dict()
    print(f"   会话Cookie: {cookies}")
    
    # 2. 上传示例文件
    print("\n2. 上传示例文件")
    # 首先创建一个测试文件
    test_file = "test_session_demo.csv"
    with open(test_file, "w") as f:
        f.write("id,name,value\n")
        f.write("1,示例,100\n")
        f.write("2,演示,200\n")
    
    # 上传文件
    with open(test_file, "rb") as f:
        response = session.post(f"{SERVER_URL}/upload", files={"file": f})
    
    # 3. 访问数据页面
    print("\n3. 访问数据页面")
    response = session.get(f"{SERVER_URL}/data")
    print(f"   响应状态: {response.status_code}")
    
    # 4. 模拟另一个会话访问
    print("\n4. 模拟另一个客户端（不共享会话）")
    another_session = requests.Session()
    response = another_session.get(f"{SERVER_URL}/data")
    print(f"   响应状态: {response.status_code}")
    print("   新客户端无法访问数据页面，因为没有上传过文件")
    
    # 5. 清理文件
    print("\n5. 清理文件")
    session.get(f"{SERVER_URL}/close_file")
    
    # 删除测试文件
    if os.path.exists(test_file):
        os.remove(test_file)
        print(f"   删除测试文件: {test_file}")
    
    print("\n演示完成!")

if __name__ == "__main__":
    # 选择演示方式
    print("会话隔离演示")
    print("===========")
    print("1. 在浏览器中演示")
    print("2. 使用API演示")
    choice = input("请选择演示方式 (1/2): ")
    
    if choice == "1":
        demo_browser_access()
    else:
        demo_api_access()
