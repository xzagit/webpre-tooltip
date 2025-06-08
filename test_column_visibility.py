#!/usr/bin/env python3
"""
测试列可见性状态持久化功能的脚本
"""

import json
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException

def test_column_visibility_persistence():
    """测试列可见性状态在页面跳转后是否持久化"""
    
    # 配置Chrome选项
    chrome_options = Options()
    chrome_options.add_argument('--headless')  # 无头模式
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-gpu')
    
    driver = None
    
    try:
        driver = webdriver.Chrome(options=chrome_options)
        wait = WebDriverWait(driver, 10)
        
        print("🚀 开始测试列可见性状态持久化功能...")
        
        # 1. 访问主页
        print("1. 访问主页...")
        driver.get("http://127.0.0.1:10015")
        
        # 2. 上传测试文件（如果没有数据）
        print("2. 检查是否有数据...")
        try:
            # 尝试找到数据浏览链接
            data_link = wait.until(EC.element_to_be_clickable((By.LINK_TEXT, "浏览数据")))
            print("   ✅ 找到数据，跳过上传步骤")
        except TimeoutException:
            print("   ❌ 没有找到数据，需要先上传文件")
            return False
        
        # 3. 进入数据浏览页面
        print("3. 进入数据浏览页面...")
        data_link.click()
        
        # 等待页面加载
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "data-table")))
        
        # 4. 查找列可见性控制按钮
        print("4. 查找列可见性控制按钮...")
        visibility_buttons = driver.find_elements(By.CLASS_NAME, "column-visibility-btn")
        
        if not visibility_buttons:
            print("   ❌ 没有找到列可见性控制按钮")
            return False
        
        print(f"   ✅ 找到 {len(visibility_buttons)} 个列可见性控制按钮")
        
        # 5. 隐藏第一列
        print("5. 隐藏第一列...")
        first_button = visibility_buttons[0]
        column_name = first_button.get_attribute('data-column')
        column_index = first_button.get_attribute('data-column-index')
        
        print(f"   隐藏列: {column_name} (索引: {column_index})")
        first_button.click()
        
        time.sleep(0.5)  # 等待状态更新
        
        # 检查按钮状态是否改变
        if 'column-hidden' in first_button.get_attribute('class'):
            print("   ✅ 列已隐藏，按钮状态已更新")
        else:
            print("   ❌ 列隐藏失败")
            return False
        
        # 6. 点击第一行进入详情页
        print("6. 点击第一行进入详情页...")
        first_row = wait.until(EC.element_to_be_clickable((By.CLASS_NAME, "clickable-row")))
        first_row.click()
        
        # 等待详情页加载
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "row-preview-container")))
        print("   ✅ 进入数据详情页")
        
        # 7. 返回数据浏览页面
        print("7. 返回数据浏览页面...")
        back_button = wait.until(EC.element_to_be_clickable((By.LINK_TEXT, "返回数据表")))
        back_button.click()
        
        # 等待页面加载
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "data-table")))
        
        # 8. 检查列的隐藏状态是否保持
        print("8. 检查列的隐藏状态是否保持...")
        
        # 重新获取按钮元素
        visibility_buttons = driver.find_elements(By.CLASS_NAME, "column-visibility-btn")
        first_button = None
        
        for button in visibility_buttons:
            if button.get_attribute('data-column-index') == column_index:
                first_button = button
                break
        
        if first_button and 'column-hidden' in first_button.get_attribute('class'):
            print("   ✅ 列隐藏状态已保持！功能正常工作")
            success = True
        else:
            print("   ❌ 列隐藏状态丢失，功能未正常工作")
            success = False
        
        # 9. 测试页面刷新重置功能
        print("9. 测试页面刷新重置功能...")
        driver.refresh()
        
        # 等待页面重新加载
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, "data-table")))
        
        # 重新获取按钮元素
        visibility_buttons = driver.find_elements(By.CLASS_NAME, "column-visibility-btn")
        first_button = None
        
        for button in visibility_buttons:
            if button.get_attribute('data-column-index') == column_index:
                first_button = button
                break
        
        if first_button and 'column-hidden' not in first_button.get_attribute('class'):
            print("   ✅ 页面刷新后列状态已重置！功能正常工作")
            success = success and True
        else:
            print("   ❌ 页面刷新后列状态未重置")
            success = False
        
        return success
        
    except WebDriverException as e:
        print(f"❌ WebDriver错误: {e}")
        print("提示：请确保已安装Chrome浏览器和ChromeDriver")
        return False
    except Exception as e:
        print(f"❌ 测试过程中发生错误: {e}")
        return False
    finally:
        if driver:
            driver.quit()

def main():
    """主函数"""
    print("=" * 60)
    print("测试列可见性状态持久化功能")
    print("=" * 60)
    
    result = test_column_visibility_persistence()
    
    print("\n" + "=" * 60)
    if result:
        print("🎉 测试通过！列可见性状态持久化功能正常工作")
    else:
        print("❌ 测试失败！需要检查功能实现")
    print("=" * 60)
    
    return result

if __name__ == "__main__":
    main()
