#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
测试会话隔离功能
这个脚本模拟两个不同的客户端同时访问数据查看器，确保它们的数据是相互隔离的
"""

import requests
import threading
import time
import os
import random
import string

# 配置
BASE_URL = "http://localhost:1015"
TEST_FILE1 = "test1.csv"
TEST_FILE2 = "test2.csv"

def create_test_files():
    """创建测试CSV文件"""
    # 文件1内容
    with open(TEST_FILE1, 'w') as f:
        f.write("id,name,value\n")
        for i in range(10):
            f.write(f"{i},用户{i},{random.randint(1, 100)}\n")
    
    # 文件2内容
    with open(TEST_FILE2, 'w') as f:
        f.write("code,product,price\n")
        for i in range(10):
            f.write(f"P{i},产品{i},{random.randint(100, 999)}\n")
    
    print(f"已创建测试文件: {TEST_FILE1} 和 {TEST_FILE2}")

def client_session(client_id, test_file):
    """模拟一个客户端会话"""
    session = requests.Session()
    
    print(f"客户端 {client_id}: 开始会话")
    
    # 1. 访问首页获取Cookie
    response = session.get(f"{BASE_URL}/")
    if response.status_code != 200:
        print(f"客户端 {client_id}: 无法访问首页，状态码: {response.status_code}")
        return
    
    # 2. 上传文件
    files = {'file': open(test_file, 'rb')}
    response = session.post(f"{BASE_URL}/upload", files=files)
    if response.status_code != 200:
        print(f"客户端 {client_id}: 文件上传失败，状态码: {response.status_code}")
        return
    
    print(f"客户端 {client_id}: 已上传文件 {test_file}")
    
    # 3. 浏览数据页面
    response = session.get(f"{BASE_URL}/data")
    if response.status_code != 200:
        print(f"客户端 {client_id}: 无法访问数据页面，状态码: {response.status_code}")
    else:
        # 检查页面内容是否包含预期数据
        expected_content = "产品" if "product" in test_file else "用户"
        if expected_content in response.text:
            print(f"客户端 {client_id}: 数据页面正确显示了 {test_file} 的内容")
        else:
            print(f"客户端 {client_id}: 数据页面未显示预期内容！")
    
    # 4. 保持会话一段时间
    time.sleep(5)
    
    # 5. 再次检查数据页面，确认仍能访问
    response = session.get(f"{BASE_URL}/data")
    if response.status_code != 200:
        print(f"客户端 {client_id}: 第二次数据页面访问失败，状态码: {response.status_code}")
    else:
        print(f"客户端 {client_id}: 第二次数据页面访问成功，会话保持有效")
    
    # 6. 关闭文件
    response = session.get(f"{BASE_URL}/close_file")
    print(f"客户端 {client_id}: 已关闭文件")
    
    # 清理资源
    files['file'].close()
    print(f"客户端 {client_id}: 会话结束")

def run_test():
    """运行测试"""
    # 创建测试文件
    create_test_files()
    
    # 启动两个客户端线程
    threads = []
    t1 = threading.Thread(target=client_session, args=(1, TEST_FILE1))
    t2 = threading.Thread(target=client_session, args=(2, TEST_FILE2))
    
    threads.append(t1)
    threads.append(t2)
    
    t1.start()
    time.sleep(1)  # 稍微延迟启动第二个线程
    t2.start()
    
    # 等待所有线程完成
    for t in threads:
        t.join()
    
    # 清理测试文件
    if os.path.exists(TEST_FILE1):
        os.remove(TEST_FILE1)
    if os.path.exists(TEST_FILE2):
        os.remove(TEST_FILE2)
    
    print("测试完成")

if __name__ == "__main__":
    run_test()
