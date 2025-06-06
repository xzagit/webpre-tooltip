#!/usr/bin/env python3
"""
测试tooltip功能的脚本
"""

import requests
from bs4 import BeautifulSoup
import time

def test_tooltip_functionality():
    """测试tooltip功能"""
    print("🚀 开始测试tooltip功能...")
    
    base_url = "http://127.0.0.1:5002"
    
    try:
        # 1. 测试主页是否可以访问
        print("\n🔍 测试主页访问...")
        response = requests.get(base_url)
        if response.status_code == 200:
            print("✅ 主页访问成功")
        else:
            print(f"❌ 主页访问失败，状态码: {response.status_code}")
            return False
            
        # 2. 上传测试文件
        print("\n🔍 上传测试文件...")
        files = {'file': open('/Users/xuziao/workplace/daily/dailypython/read_pre/webpre/test_long_columns.csv', 'rb')}
        upload_response = requests.post(f"{base_url}/upload", files=files)
        files['file'].close()
        
        if upload_response.status_code == 200:
            print("✅ 测试文件上传成功")
        else:
            print(f"❌ 文件上传失败，状态码: {upload_response.status_code}")
            return False
            
        # 3. 测试数据页面的tooltip
        print("\n🔍 测试数据页面tooltip...")
        data_response = requests.get(f"{base_url}/data")
        if data_response.status_code == 200:
            soup = BeautifulSoup(data_response.text, 'html.parser')
            
            # 检查表头是否有tooltip属性
            table_headers = soup.find_all('th', attrs={'data-bs-toggle': 'tooltip'})
            if table_headers:
                print(f"✅ 找到 {len(table_headers)} 个带tooltip的表头")
                for header in table_headers[:3]:  # 显示前3个
                    title = header.get('title', '')
                    text = header.get_text(strip=True)
                    print(f"   表头: '{text}' -> tooltip: '{title}'")
            else:
                print("❌ 未找到带tooltip的表头")
                return False
                
            # 检查数据单元格是否有tooltip属性  
            data_cells = soup.find_all('td', attrs={'data-bs-toggle': 'tooltip'})
            if data_cells:
                print(f"✅ 找到 {len(data_cells)} 个带tooltip的数据单元格")
            else:
                print("❌ 未找到带tooltip的数据单元格")
                return False
                
            # 检查侧边栏列名是否有tooltip
            column_names = soup.find_all('small', class_='column-name')
            tooltip_columns = [col for col in column_names if col.get('data-bs-toggle') == 'tooltip']
            if tooltip_columns:
                print(f"✅ 找到 {len(tooltip_columns)} 个带tooltip的侧边栏列名")
            else:
                print("❌ 侧边栏列名未设置tooltip")
                return False
                
        else:
            print(f"❌ 数据页面访问失败，状态码: {data_response.status_code}")
            return False
            
        # 4. 测试主页预览的tooltip
        print("\n🔍 测试主页预览tooltip...")
        home_response = requests.get(base_url)
        if home_response.status_code == 200:
            soup = BeautifulSoup(home_response.text, 'html.parser')
            
            preview_headers = soup.find('div', class_='table-container')
            if preview_headers:
                preview_th = preview_headers.find_all('th', attrs={'data-bs-toggle': 'tooltip'})
                preview_td = preview_headers.find_all('td', attrs={'data-bs-toggle': 'tooltip'})
                
                if preview_th:
                    print(f"✅ 主页预览表头有 {len(preview_th)} 个tooltip")
                else:
                    print("❌ 主页预览表头未设置tooltip")
                    
                if preview_td:
                    print(f"✅ 主页预览数据有 {len(preview_td)} 个tooltip")
                else:
                    print("❌ 主页预览数据未设置tooltip")
            else:
                print("❌ 未找到主页预览表格")
                
        print("\n🎉 Tooltip功能测试完成！")
        return True
        
    except Exception as e:
        print(f"❌ 测试过程中出错: {str(e)}")
        return False

if __name__ == "__main__":
    # 等待服务器启动
    print("等待服务器启动...")
    time.sleep(2)
    
    test_tooltip_functionality()
