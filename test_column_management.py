#!/usr/bin/env python3
"""
列管理功能测试脚本
测试新的列管理UI和功能
"""

import pandas as pd
import os
import tempfile
import json

def create_test_data():
    """创建测试数据"""
    # 创建一个有很多列的测试数据集
    data = {
        'ID': range(1, 101),
        'Name': [f'User_{i}' for i in range(1, 101)],
        'Email': [f'user{i}@example.com' for i in range(1, 101)],
        'Age': [20 + (i % 50) for i in range(100)],
        'City': [f'City_{i%10}' for i in range(100)],
        'Country': [f'Country_{i%5}' for i in range(100)],
        'Salary': [30000 + (i * 1000) for i in range(100)],
        'Department': [f'Dept_{i%8}' for i in range(100)],
        'Position': [f'Position_{i%6}' for i in range(100)],
        'Experience_Years': [i % 20 for i in range(100)],
        'Skills': [f'Skill_{i%15}' for i in range(100)],
        'Manager': [f'Manager_{i%12}' for i in range(100)],
        'Start_Date': [f'2020-{(i%12)+1:02d}-{(i%28)+1:02d}' for i in range(100)],
        'Performance_Score': [4.0 + (i % 10) / 10 for i in range(100)],
        'Bonus': [i * 100 for i in range(100)],
        'Status': ['Active' if i % 3 == 0 else 'Inactive' for i in range(100)],
        'Notes': [f'Note for user {i}' for i in range(1, 101)],
        'Last_Login': [f'2024-01-{(i%30)+1:02d}' for i in range(100)],
        'Projects_Count': [i % 15 for i in range(100)],
        'Training_Hours': [i * 2 for i in range(100)]
    }
    
    df = pd.DataFrame(data)
    return df

def save_test_file(df, filename="test_column_management.csv"):
    """保存测试文件"""
    test_dir = "/Users/xuziao/workplace/service/webpre-tooltip/webpre-tooltip/uploads/test"
    os.makedirs(test_dir, exist_ok=True)
    
    filepath = os.path.join(test_dir, filename)
    df.to_csv(filepath, index=False)
    
    print(f"测试文件已保存到: {filepath}")
    print(f"文件包含 {len(df)} 行, {len(df.columns)} 列")
    print(f"列名: {list(df.columns)}")
    
    return filepath

def print_column_info(df):
    """打印列信息"""
    print("\n=== 列信息 ===")
    for i, col in enumerate(df.columns):
        print(f"{i+1:2d}. {col:<20} - {df[col].dtype}")

def test_column_visibility_features():
    """测试列可见性功能"""
    print("\n=== 列管理功能测试指南 ===")
    print("1. 列统计信息:")
    print("   - 显示列数量")
    print("   - 隐藏列数量") 
    print("   - 总列数")
    
    print("\n2. 快捷操作:")
    print("   - 全部显示按钮")
    print("   - 全部隐藏按钮（保留第一列）")
    
    print("\n3. 列搜索功能:")
    print("   - 搜索框可以快速找到特定列")
    print("   - 支持模糊搜索")
    print("   - 高亮显示匹配结果")
    print("   - 显示搜索结果数量")
    
    print("\n4. 状态持久化:")
    print("   - 页面导航时保持列隐藏状态")
    print("   - 页面刷新时重置为显示所有列")
    
    print("\n5. 交互体验:")
    print("   - 现代化的UI设计")
    print("   - 平滑的动画效果")
    print("   - 响应式设计")
    print("   - 直观的图标和提示")

if __name__ == "__main__":
    print("创建列管理功能测试数据...")
    df = create_test_data()
    
    # 保存测试文件
    filepath = save_test_file(df)
    
    # 打印列信息
    print_column_info(df)
    
    # 测试指南
    test_column_visibility_features()
    
    print(f"\n请在浏览器中访问: http://127.0.0.1:10015")
    print(f"上传文件: {filepath}")
    print("测试新的列管理功能!")
