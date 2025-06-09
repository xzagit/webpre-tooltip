#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Web版数据查看器 - 支持 Parquet、CSV、JSON、JSONL 格式
基于 Flask 和 Bootstrap 构建
"""

import os
import pandas as pd
import numpy as np
import pyarrow.parquet as pq
from flask import Flask, render_template, request, jsonify, send_file, flash, redirect, url_for, session
from werkzeug.utils import secure_filename
import json
import io
import base64
import matplotlib
matplotlib.use('Agg')  # 使用非交互式后端
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import font_manager
import uuid
import shutil
import time
from datetime import timedelta

# 设置中文字体支持
plt.rcParams['font.sans-serif'] = ['Arial Unicode MS', 'SimHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'  # 在生产环境中应该设置为随机字符串
app.permanent_session_lifetime = timedelta(hours=24)  # 会话有效期24小时

# 配置
BASE_UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'csv', 'json', 'jsonl', 'parquet', 'pq'}
MAX_FILE_SIZE = 500 * 1024 * 1024  # 500MB

# 确保基础上传文件夹存在
os.makedirs(BASE_UPLOAD_FOLDER, exist_ok=True)

# 使用全局字典存储用户数据（DataFrame不能直接存储在session中）
user_data_store = {}

# 用于管理会话数据的函数
def get_session_id():
    """获取或创建会话ID"""
    if 'session_id' not in session:
        session.permanent = True
        session['session_id'] = str(uuid.uuid4())
    return session['session_id']

def get_user_upload_folder():
    """获取用户特定的上传文件夹"""
    session_id = get_session_id()
    user_folder = os.path.join(BASE_UPLOAD_FOLDER, session_id)
    os.makedirs(user_folder, exist_ok=True)
    return user_folder

def get_user_data():
    """获取用户的数据状态"""
    session_id = get_session_id()
    
    # 初始化用户数据存储
    if session_id not in user_data_store:
        user_data_store[session_id] = {
            'df': None,
            'filename': None,
            'file_info': None
        }
    
    return user_data_store[session_id]

def update_user_data(key, value):
    """更新用户数据"""
    session_id = get_session_id()
    
    # 确保用户数据已初始化
    if session_id not in user_data_store:
        user_data_store[session_id] = {
            'df': None,
            'filename': None,
            'file_info': None
        }
    
    # 更新数据
    user_data_store[session_id][key] = value
    session.modified = True

# 添加自定义的Jinja2过滤器
@app.template_filter('format_number')
def format_number(value):
    """格式化数字，添加千分位分隔符"""
    try:
        if isinstance(value, (int, float)):
            return f"{value:,}"
        return str(value)
    except:
        return str(value)

# 添加Jinja2全局函数
@app.template_global()
def min_func(*args):
    """min函数的Jinja2包装器"""
    return min(*args)

@app.template_global()
def max_func(*args):
    """max函数的Jinja2包装器"""
    return max(*args)

# 将内置函数添加到Jinja2环境
app.jinja_env.globals['min'] = min
app.jinja_env.globals['max'] = max

def allowed_file(filename):
    """检查文件扩展名是否被允许"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_file_size_mb(file_path):
    """获取文件大小（MB）"""
    return os.path.getsize(file_path) / (1024 * 1024)

def process_dataframe(df):
    """处理DataFrame，转换不可哈希类型"""
    for column in df.columns:
        try:
            # 获取非空值的第一个元素来检查类型
            sample = next((x for x in df[column] if pd.notna(x)), None)
            
            # 检查是否为不可哈希类型（字典、列表、数组等）
            if isinstance(sample, (dict, list, np.ndarray)) or (
                hasattr(sample, '__iter__') and not isinstance(sample, (str, bytes))):
                # 将不可哈希类型转换为字符串
                df[column] = df[column].apply(
                    lambda x: str(x) if x is not None and pd.notna(x) else x
                )
        except Exception:
            # 如果检查过程中出错，保险起见也转换为字符串
            df[column] = df[column].astype(str)
    
    return df

def load_parquet_file(file_path):
    """加载Parquet文件"""
    try:
        # 先尝试打开文件但不加载全部数据
        parquet_file = pq.ParquetFile(file_path)
        num_rows = parquet_file.metadata.num_rows
        
        # 使用pandas直接读取parquet文件
        df = pd.read_parquet(file_path)
        
    except Exception as e:
        raise ValueError(f"无法识别为有效的Parquet文件: {str(e)}")
    
    return process_dataframe(df)

def load_csv_file(file_path):
    """加载CSV文件"""
    try:
        # 尝试自动检测编码
        encodings = ['utf-8', 'gbk', 'gb2312', 'latin1', 'cp1252']
        df = None
        
        for encoding in encodings:
            try:
                # 先读取一小部分来检测分隔符
                sample = pd.read_csv(file_path, encoding=encoding, nrows=5)
                
                # 检测可能的分隔符
                separators = [',', ';', '\t', '|']
                best_sep = ','
                max_cols = 1
                
                for sep in separators:
                    try:
                        test_df = pd.read_csv(file_path, encoding=encoding, sep=sep, nrows=5)
                        if test_df.shape[1] > max_cols:
                            max_cols = test_df.shape[1]
                            best_sep = sep
                    except:
                        continue
                
                # 读取完整文件
                df = pd.read_csv(file_path, encoding=encoding, sep=best_sep)
                break
                
            except UnicodeDecodeError:
                continue
            except Exception as e:
                if encoding == encodings[-1]:  # 最后一个编码也失败了
                    raise e
                continue
        
        if df is None:
            raise ValueError("无法读取CSV文件，可能是编码问题")
            
    except Exception as e:
        raise ValueError(f"无法读取CSV文件: {str(e)}")
    
    return process_dataframe(df)

def load_json_file(file_path):
    """加载JSON文件"""
    try:
        # 尝试不同的JSON读取方式
        try:
            # 尝试直接读取为DataFrame
            df = pd.read_json(file_path, orient='records')
        except:
            try:
                # 尝试读取为普通JSON然后转换
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                if isinstance(data, list):
                    df = pd.DataFrame(data)
                elif isinstance(data, dict):
                    # 如果是字典，尝试找到列表数据
                    for key, value in data.items():
                        if isinstance(value, list) and len(value) > 0:
                            df = pd.DataFrame(value)
                            break
                    else:
                        # 如果没有找到列表，将字典转换为单行DataFrame
                        df = pd.DataFrame([data])
                else:
                    raise ValueError("JSON格式不支持转换为表格")
            except:
                # 最后尝试按行读取
                df = pd.read_json(file_path, lines=True)
            
    except Exception as e:
        raise ValueError(f"无法读取JSON文件: {str(e)}")
    
    return process_dataframe(df)

def load_jsonl_file(file_path):
    """加载JSONL文件"""
    try:
        # JSONL文件每行都是一个JSON对象
        df = pd.read_json(file_path, lines=True)
            
    except Exception as e:
        raise ValueError(f"无法读取JSONL文件: {str(e)}")
    
    return process_dataframe(df)

def load_data_file(file_path):
    """加载数据文件 - 支持多种格式"""
    # 根据文件扩展名选择加载方法
    file_ext = os.path.splitext(file_path)[1].lower()
    
    if file_ext in ['.parquet', '.pq']:
        return load_parquet_file(file_path)
    elif file_ext == '.csv':
        return load_csv_file(file_path)
    elif file_ext == '.json':
        return load_json_file(file_path)
    elif file_ext == '.jsonl':
        return load_jsonl_file(file_path)
    else:
        raise ValueError(f"不支持的文件格式: {file_ext}")

def generate_statistics(df):
    """生成数据统计信息"""
    stats = {}
    
    # 基本信息
    stats['basic'] = {
        'rows': df.shape[0],
        'columns': df.shape[1],
        'memory_usage': f"{df.memory_usage(deep=True).sum() / 1024 / 1024:.2f} MB"
    }
    
    try:
        # 数值列统计
        numeric_cols = df.select_dtypes(include=['number']).columns
        if len(numeric_cols) > 0:
            stats['numeric'] = df[numeric_cols].describe().round(4).to_dict()
        else:
            stats['numeric'] = {}
        
        # 非数值列统计
        non_numeric_cols = df.select_dtypes(exclude=['number']).columns
        stats['categorical'] = {}
        for col in non_numeric_cols:
            try:
                stats['categorical'][col] = {
                    'unique_count': df[col].nunique(),
                    'most_common': str(df[col].value_counts().index[0]) if len(df[col].value_counts()) > 0 else '无',
                    'null_count': df[col].isna().sum()
                }
            except Exception as e:
                print(f"处理列 '{col}' 时出错: {str(e)}")
                stats['categorical'][col] = {
                    'unique_count': '计算错误',
                    'most_common': '计算错误',
                    'null_count': '计算错误'
                }
        
        # 缺失值信息
        missing = df.isna().sum()
        stats['missing'] = missing[missing > 0].to_dict()
    
    except Exception as e:
        print(f"生成统计信息时出错: {str(e)}")
        # 提供最小的统计信息以避免模板渲染错误
        stats['numeric'] = {}
        stats['categorical'] = {}
        stats['missing'] = {}
    
    return stats

def create_visualization(df, chart_type, x_column, y_column=None):
    """创建数据可视化图表"""
    plt.clf()  # 清除之前的图表
    fig, ax = plt.subplots(figsize=(10, 6))
    
    try:
        if chart_type == 'bar':
            if y_column:
                df.groupby(x_column)[y_column].mean().plot(kind='bar', ax=ax)
            else:
                df[x_column].value_counts().head(10).plot(kind='bar', ax=ax)
        elif chart_type == 'line':
            if y_column:
                df.plot(x=x_column, y=y_column, kind='line', ax=ax)
            else:
                df[x_column].plot(kind='line', ax=ax)
        elif chart_type == 'scatter':
            if y_column:
                df.plot.scatter(x=x_column, y=y_column, ax=ax)
            else:
                ax.text(0.5, 0.5, "散点图需要选择两个数值列", 
                       horizontalalignment='center', verticalalignment='center')
        elif chart_type == 'hist':
            df[x_column].plot.hist(bins=30, ax=ax)
        elif chart_type == 'box':
            if y_column:
                df.boxplot(column=y_column, by=x_column, ax=ax)
            else:
                df.boxplot(column=x_column, ax=ax)
        elif chart_type == 'heatmap':
            # 选择数值列
            numeric_cols = df.select_dtypes(include=['number']).columns.tolist()
            if len(numeric_cols) > 1:
                corr = df[numeric_cols].corr()
                sns.heatmap(corr, annot=True, cmap='coolwarm', ax=ax)
            else:
                ax.text(0.5, 0.5, "需要至少两个数值列才能创建热力图", 
                       horizontalalignment='center', verticalalignment='center')
        
        plt.tight_layout()
        
        # 将图表转换为base64字符串
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=100, bbox_inches='tight')
        img_buffer.seek(0)
        img_b64 = base64.b64encode(img_buffer.getvalue()).decode()
        
        return img_b64
        
    except Exception as e:
        # 如果出错，返回错误信息
        ax.text(0.5, 0.5, f"生成图表时出错: {str(e)}", 
               horizontalalignment='center', verticalalignment='center')
        plt.tight_layout()
        
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=100, bbox_inches='tight')
        img_buffer.seek(0)
        img_b64 = base64.b64encode(img_buffer.getvalue()).decode()
        
        return img_b64

@app.route('/')
def index():
    """主页"""
    user_data = get_user_data()
    return render_template('index.html', current_data=user_data)

@app.route('/upload', methods=['POST'])
def upload_file():
    """处理文件上传"""
    if 'file' not in request.files:
        flash('没有选择文件')
        return redirect(url_for('index'))
    
    file = request.files['file']
    
    if file.filename == '':
        flash('没有选择文件')
        return redirect(url_for('index'))
    
    if file and allowed_file(file.filename):
        try:
            # 获取用户特定的上传文件夹
            upload_folder = get_user_upload_folder()
            
            # 清理之前的文件（可选，避免占用过多空间）
            for old_file in os.listdir(upload_folder):
                old_file_path = os.path.join(upload_folder, old_file)
                if os.path.isfile(old_file_path):
                    os.remove(old_file_path)
            
            filename = secure_filename(file.filename)
            file_path = os.path.join(upload_folder, filename)
            file.save(file_path)
            
            # 检查文件大小
            file_size = get_file_size_mb(file_path)
            if file_size > 500:  # 如果文件大于500MB，给出警告但继续加载
                flash(f'文件大小为{file_size:.1f}MB，可能会导致加载缓慢', 'warning')
            
            # 加载数据
            df = load_data_file(file_path)
            
            # 存储用户特定数据
            file_info = {
                'format': os.path.splitext(filename)[1].upper(),
                'size_mb': file_size,
                'rows': df.shape[0],
                'columns': df.shape[1]
            }
            
            # 更新用户会话数据
            update_user_data('df', df)
            update_user_data('filename', filename)
            update_user_data('file_info', file_info)
            
            flash(f'成功加载文件 {filename}', 'success')
            
        except Exception as e:
            flash(f'加载文件时出错: {str(e)}', 'error')
            
    else:
        flash('文件格式不支持。支持的格式: CSV, JSON, JSONL, Parquet', 'error')
    
    return redirect(url_for('index'))

@app.route('/data')
def view_data():
    """查看数据页面"""
    user_data = get_user_data()
    if user_data['df'] is None:
        flash('请先上传一个数据文件', 'warning')
        return redirect(url_for('index'))
    
    # 获取分页参数
    page = request.args.get('page', 1, type=int)
    per_page = 50  # 每页显示50行
    
    df = user_data['df']
    
    # 应用搜索和筛选
    search = request.args.get('search', '')
    search_column = request.args.get('search_column', 'all')
    filter_column = request.args.get('filter_column', '')
    filter_operator = request.args.get('filter_operator', '')
    filter_value = request.args.get('filter_value', '')
    
    filtered_df = df.copy()
    
    # 应用筛选
    if filter_column and filter_operator and filter_value:
        try:
            if filter_operator == 'eq':
                try:
                    value = float(filter_value)
                except ValueError:
                    value = filter_value
                filtered_df = filtered_df[filtered_df[filter_column] == value]
            elif filter_operator == 'ne':
                try:
                    value = float(filter_value)
                except ValueError:
                    value = filter_value
                filtered_df = filtered_df[filtered_df[filter_column] != value]
            elif filter_operator == 'gt':
                value = float(filter_value)
                filtered_df = filtered_df[filtered_df[filter_column] > value]
            elif filter_operator == 'lt':
                value = float(filter_value)
                filtered_df = filtered_df[filtered_df[filter_column] < value]
            elif filter_operator == 'gte':
                value = float(filter_value)
                filtered_df = filtered_df[filtered_df[filter_column] >= value]
            elif filter_operator == 'lte':
                value = float(filter_value)
                filtered_df = filtered_df[filtered_df[filter_column] <= value]
            elif filter_operator == 'contains':
                filtered_df = filtered_df[filtered_df[filter_column].astype(str).str.contains(filter_value, na=False)]
        except Exception as e:
            flash(f'筛选时出错: {str(e)}', 'error')
    
    # 应用搜索
    if search:
        if search_column == 'all':
            # 搜索所有列
            mask = filtered_df.astype(str).apply(lambda x: x.str.contains(search, case=False, na=False)).any(axis=1)
            filtered_df = filtered_df[mask]
        else:
            # 搜索特定列
            filtered_df = filtered_df[filtered_df[search_column].astype(str).str.contains(search, case=False, na=False)]
    
    # 分页
    total_rows = len(filtered_df)
    start_idx = (page - 1) * per_page
    end_idx = start_idx + per_page
    page_data = filtered_df.iloc[start_idx:end_idx]
    
    # 转换为字典格式用于模板渲染
    data_dict = {
        'columns': page_data.columns.tolist(),
        'data': page_data.values.tolist(),
        'total_rows': total_rows,
        'page': page,
        'per_page': per_page,
        'has_prev': page > 1,
        'has_next': end_idx < total_rows,
        'prev_page': page - 1 if page > 1 else None,
        'next_page': page + 1 if end_idx < total_rows else None
    }
    
    return render_template('data.html', 
                         data=data_dict, 
                         current_data=user_data,
                         search=search,
                         search_column=search_column,
                         filter_column=filter_column,
                         filter_operator=filter_operator,
                         filter_value=filter_value)

@app.route('/statistics')
def view_statistics():
    """查看统计信息页面"""
    try:
        user_data = get_user_data()
        if user_data['df'] is None:
            flash('请先上传一个数据文件', 'warning')
            return redirect(url_for('index'))
        
        # 确保DataFrame可用
        df = user_data['df']
        if not isinstance(df, pd.DataFrame):
            flash('数据格式错误，无法生成统计信息', 'error')
            return redirect(url_for('index'))
        
        stats = generate_statistics(df)
        return render_template('statistics.html', stats=stats, current_data=user_data)
    
    except Exception as e:
        flash(f'生成统计信息时出错: {str(e)}', 'error')
        return redirect(url_for('index'))

@app.route('/visualization')
def view_visualization():
    """查看数据可视化页面"""
    user_data = get_user_data()
    if user_data['df'] is None:
        flash('请先上传一个数据文件', 'warning')
        return redirect(url_for('index'))
    
    df = user_data['df']
    columns = df.columns.tolist()
    numeric_columns = df.select_dtypes(include=['number']).columns.tolist()
    
    return render_template('visualization.html', 
                         current_data=user_data,
                         columns=columns,
                         numeric_columns=numeric_columns)

@app.route('/generate_chart', methods=['POST'])
def generate_chart():
    """生成图表"""
    user_data = get_user_data()
    if user_data['df'] is None:
        return jsonify({'error': '没有数据可用于生成图表'})
    
    chart_type = request.json.get('chart_type')
    x_column = request.json.get('x_column')
    y_column = request.json.get('y_column')
    
    try:
        img_b64 = create_visualization(user_data['df'], chart_type, x_column, y_column)
        return jsonify({'image': img_b64})
    except Exception as e:
        return jsonify({'error': f'生成图表时出错: {str(e)}'})

@app.route('/export/<format>')
def export_data(format):
    """导出数据"""
    user_data = get_user_data()
    if user_data['df'] is None:
        flash('没有数据可以导出', 'warning')
        return redirect(url_for('index'))
    
    df = user_data['df']
    filename_base = os.path.splitext(user_data['filename'] or 'data')[0]
    
    try:
        if format == 'csv':
            output = io.StringIO()
            df.to_csv(output, index=False, encoding='utf-8')
            output.seek(0)
            
            return send_file(
                io.BytesIO(output.getvalue().encode('utf-8')),
                mimetype='text/csv',
                as_attachment=True,
                download_name=f'{filename_base}.csv'
            )
            
        elif format == 'json':
            output = io.StringIO()
            df.to_json(output, orient='records', force_ascii=False, indent=2)
            output.seek(0)
            
            return send_file(
                io.BytesIO(output.getvalue().encode('utf-8')),
                mimetype='application/json',
                as_attachment=True,
                download_name=f'{filename_base}.json'
            )
            
        elif format == 'jsonl':
            output = io.StringIO()
            df.to_json(output, orient='records', lines=True, force_ascii=False)
            output.seek(0)
            
            return send_file(
                io.BytesIO(output.getvalue().encode('utf-8')),
                mimetype='application/json',
                as_attachment=True,
                download_name=f'{filename_base}.jsonl'
            )
            
        elif format == 'excel':
            output = io.BytesIO()
            df.to_excel(output, index=False)
            output.seek(0)
            
            return send_file(
                output,
                mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                as_attachment=True,
                download_name=f'{filename_base}.xlsx'
            )
            
        elif format == 'parquet':
            output = io.BytesIO()
            df.to_parquet(output, index=False)
            output.seek(0)
            
            return send_file(
                output,
                mimetype='application/octet-stream',
                as_attachment=True,
                download_name=f'{filename_base}.parquet'
            )
            
    except Exception as e:
        flash(f'导出数据时出错: {str(e)}', 'error')
        return redirect(url_for('index'))

@app.route('/close_file')
def close_file():
    """关闭当前文件"""
    session_id = get_session_id()
    user_folder = os.path.join(BASE_UPLOAD_FOLDER, session_id)
    
    # 清理用户文件夹中的文件
    if os.path.exists(user_folder):
        for file_name in os.listdir(user_folder):
            file_path = os.path.join(user_folder, file_name)
            if os.path.isfile(file_path):
                os.remove(file_path)
    
    # 重置用户数据
    user_data = get_user_data()
    user_data['df'] = None
    user_data['filename'] = None
    user_data['file_info'] = None
    
    flash('已关闭当前文件', 'info')
    return redirect(url_for('index'))

@app.route('/test_js')
def test_js():
    """JavaScript功能测试页面"""
    return render_template('test_js.html')

@app.route('/preview')
def view_preview():
    """数据预览页面 - 以JSON格式显示第一行数据"""
    user_data = get_user_data()
    if user_data['df'] is None:
        flash('请先上传一个数据文件', 'warning')
        return redirect(url_for('index'))
    
    df = user_data['df']
    
    # 获取第一行数据
    if len(df) > 0:
        first_row = df.iloc[0]
        # 转换为字典，处理特殊数据类型
        first_row_dict = {}
        for col, value in first_row.items():
            if pd.isna(value):
                first_row_dict[col] = None
            elif isinstance(value, (pd.Timestamp, pd.DatetimeTZDtype)):
                first_row_dict[col] = str(value)
            elif isinstance(value, (int, float, bool)):
                first_row_dict[col] = value
            else:
                first_row_dict[col] = str(value)
        
        # 格式化为美观的JSON字符串
        import json
        json_string = json.dumps(first_row_dict, ensure_ascii=False, indent=2)
    else:
        first_row_dict = {}
        json_string = "{}"
    
    return render_template('preview.html', 
                         current_data=user_data,
                         first_row_dict=first_row_dict,
                         json_string=json_string)

@app.route('/preview/<int:row_index>')
def view_row_preview(row_index):
    """查看指定行的数据预览"""
    user_data = get_user_data()
    if user_data['df'] is None:
        flash('请先上传一个数据文件', 'warning')
        return redirect(url_for('index'))
    
    df = user_data['df']
    
    # 检查行索引是否有效
    if row_index < 0 or row_index >= len(df):
        flash(f'行索引 {row_index} 超出范围 (0-{len(df)-1})', 'error')
        return redirect(url_for('view_data'))
    
    # 获取指定行数据
    row_data = df.iloc[row_index]
    # 转换为字典，处理特殊数据类型
    row_dict = {}
    for col, value in row_data.items():
        if pd.isna(value):
            row_dict[col] = None
        elif isinstance(value, (pd.Timestamp, pd.DatetimeTZDtype)):
            row_dict[col] = str(value)
        elif isinstance(value, (int, float, bool)):
            row_dict[col] = value
        else:
            row_dict[col] = str(value)
    
    # 格式化为美观的JSON字符串
    import json
    json_string = json.dumps(row_dict, ensure_ascii=False, indent=2)
    
    return render_template('row_preview.html', 
                         current_data=user_data,
                         row_index=row_index,
                         row_dict=row_dict,
                         json_string=json_string)

@app.route('/tooltip_demo')
def tooltip_demo():
    """工具提示功能演示页面"""
    return render_template('tooltip_demo.html')

# 清理过期会话的功能
# 内存中数据清理计时器（每小时检查一次）
last_cleanup_time = time.time()
CLEANUP_INTERVAL = 3600  # 1小时

@app.before_request
def cleanup_old_sessions():
    """清理过期的会话数据"""
    global last_cleanup_time
    
    # 每隔一段时间才执行清理操作
    current_time = time.time()
    if current_time - last_cleanup_time < CLEANUP_INTERVAL:
        return
    
    # 更新最后清理时间
    last_cleanup_time = current_time
    
    try:
        # 1. 清理内存中的过期数据 - 获取所有活跃会话ID
        active_sessions = set()
        for session_id in user_data_store.keys():
            # 检查文件夹最后修改时间
            user_folder = os.path.join(BASE_UPLOAD_FOLDER, session_id)
            if os.path.exists(user_folder):
                # 如果文件夹在过去24小时内有修改，视为活跃
                if current_time - os.path.getmtime(user_folder) < 86400:  # 86400秒 = 1天
                    active_sessions.add(session_id)
        
        # 清理不活跃的会话数据
        inactive_sessions = set(user_data_store.keys()) - active_sessions
        for session_id in inactive_sessions:
            if session_id in user_data_store:
                del user_data_store[session_id]
                print(f"已清理不活跃会话: {session_id}")
        
        # 2. 清理文件系统中的过期文件夹
        if os.path.exists(BASE_UPLOAD_FOLDER):
            for folder_name in os.listdir(BASE_UPLOAD_FOLDER):
                folder_path = os.path.join(BASE_UPLOAD_FOLDER, folder_name)
                
                # 跳过非目录
                if not os.path.isdir(folder_path):
                    continue
                
                # 如果文件夹名不在活跃会话中并且超过1天未修改，则删除
                if (folder_name not in active_sessions and 
                    current_time - os.path.getmtime(folder_path) > 86400):  # 86400秒 = 1天
                    try:
                        shutil.rmtree(folder_path)
                        print(f"已清理过期文件夹: {folder_path}")
                    except Exception as e:
                        print(f"清理文件夹失败: {folder_path}, 错误: {str(e)}")
    except Exception as e:
        print(f"清理过期会话时出错: {str(e)}")

if __name__ == '__main__':
    import argparse
    import sys
    
    # 解析命令行参数
    parser = argparse.ArgumentParser(description='Web数据预览器 v2.1')
    parser.add_argument('--port', '-p', type=int, default=10015,
                        help='指定服务端口号 (默认: 10015)')
    parser.add_argument('--host', default='0.0.0.0',
                        help='指定服务地址 (默认: 0.0.0.0)')
    parser.add_argument('--debug', action='store_true',
                        help='启用调试模式')
    
    args = parser.parse_args()
    
    # 验证端口号
    if args.port < 1024 or args.port > 65535:
        print(f"错误: 端口号必须在1024-65535之间，当前值: {args.port}")
        sys.exit(1)
    
    # 从环境变量获取配置（优先级高于命令行参数）
    port = int(os.environ.get('FLASK_PORT', args.port))
    debug = os.environ.get('FLASK_DEBUG', '').lower() == 'true' or args.debug
    
    print(f"正在启动Web数据预览器 v2.1...")
    print(f"服务地址: http://{args.host}:{port}")
    print(f"本地访问: http://127.0.0.1:{port}")
    print(f"调试模式: {'开启' if debug else '关闭'}")
    print("按 Ctrl+C 停止服务")
    
    try:
        app.run(debug=debug, host=args.host, port=port)
    except KeyboardInterrupt:
        print("\n服务已停止")
    except Exception as e:
        print(f"启动失败: {str(e)}")
        sys.exit(1)
