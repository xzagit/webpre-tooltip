// 主要JavaScript功能

// 注意: 导出和关闭功能已简化为直接链接，不再需要JavaScript确认

// 拖拽上传功能
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM Content Loaded');
    
    const dragDropArea = document.getElementById('drag-drop-area');
    const fileInput = document.getElementById('file-input');
    const fileForm = document.getElementById('file-form');
    
    if (dragDropArea && fileInput) {
        // 防止默认拖拽行为
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dragDropArea.addEventListener(eventName, preventDefaults, false);
            document.body.addEventListener(eventName, preventDefaults, false);
        });
        
        // 高亮拖拽区域
        ['dragenter', 'dragover'].forEach(eventName => {
            dragDropArea.addEventListener(eventName, highlight, false);
        });
        
        ['dragleave', 'drop'].forEach(eventName => {
            dragDropArea.addEventListener(eventName, unhighlight, false);
        });
        
        // 处理文件拖拽
        dragDropArea.addEventListener('drop', handleDrop, false);
        
        // 点击上传区域
        dragDropArea.addEventListener('click', () => {
            fileInput.click();
        });
        
        // 文件选择变化
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                handleFiles(this.files);
            }
        });
    }
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    function highlight(e) {
        dragDropArea.classList.add('drag-over');
    }
    
    function unhighlight(e) {
        dragDropArea.classList.remove('drag-over');
    }
    
    function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    }
    
    function handleFiles(files) {
        if (files.length > 0) {
            const file = files[0];
            fileInput.files = files;
            
            // 显示文件信息
            const fileName = file.name;
            const fileSize = (file.size / 1024 / 1024).toFixed(2);
            
            const uploadText = dragDropArea.querySelector('.upload-text');
            if (uploadText) {
                uploadText.innerHTML = `
                    <div class="text-success">
                        <i class="fas fa-check-circle"></i>
                        已选择文件: ${fileName} (${fileSize} MB)
                    </div>
                    <small class="text-muted">点击"上传文件"按钮开始处理</small>
                `;
            }
        }
    }
});

// 数据表格功能
function initDataTable() {
    // 表格行点击高亮
    const tableRows = document.querySelectorAll('.data-table tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('click', function() {
            // 移除其他行的高亮
            tableRows.forEach(r => r.classList.remove('table-active'));
            // 添加当前行的高亮
            this.classList.add('table-active');
        });
    });
    
    // 为没有title属性的表格单元格添加title
    const tableCells = document.querySelectorAll('.data-table td:not([title])');
    tableCells.forEach(cell => {
        if (cell.scrollWidth > cell.clientWidth) {
            cell.setAttribute('title', cell.textContent);
            cell.setAttribute('data-bs-toggle', 'tooltip');
            cell.setAttribute('data-bs-placement', 'top');
        }
    });
    
    // 为没有title属性的表头添加title
    const tableHeaders = document.querySelectorAll('.data-table th:not([title])');
    tableHeaders.forEach(header => {
        if (header.scrollWidth > header.clientWidth || header.textContent.length > 15) {
            header.setAttribute('title', header.textContent);
            header.setAttribute('data-bs-toggle', 'tooltip');
            header.setAttribute('data-bs-placement', 'top');
        }
    });
    
    // 初始化所有工具提示
    initTooltips();
}

// 搜索功能增强
function initSearchFeatures() {
    const searchInput = document.getElementById('search-input');
    const searchButton = document.getElementById('search-button');
    
    if (searchInput) {
        // 回车键搜索
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                if (searchButton) {
                    searchButton.click();
                }
            }
        });
        
        // 输入时的实时提示
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            const query = this.value.trim();
            
            if (query.length > 0) {
                searchTimeout = setTimeout(() => {
                    // 这里可以添加实时搜索建议功能
                    console.log('搜索建议:', query);
                }, 500);
            }
        });
    }
}

// 筛选功能
function initFilterFeatures() {
    const filterColumn = document.getElementById('filter-column');
    const filterOperator = document.getElementById('filter-operator');
    const filterValue = document.getElementById('filter-value');
    
    if (filterColumn && filterOperator) {
        filterColumn.addEventListener('change', function() {
            const column = this.value;
            if (column) {
                // 根据列类型调整操作符选项
                updateFilterOperators(column);
            }
        });
    }
}

function updateFilterOperators(column) {
    // 这里可以根据列的数据类型动态更新操作符选项
    // 暂时使用静态操作符列表
}

// 统计图表功能
function initStatistics() {
    // 为统计卡片添加动画效果
    const statCards = document.querySelectorAll('.stats-card');
    
    // 使用 Intersection Observer 来触发动画
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    });
    
    statCards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
        observer.observe(card);
    });
}

function showExportLoading() {
    const exportButtons = document.querySelectorAll('[onclick*="confirmExport"]');
    exportButtons.forEach(button => {
        button.disabled = true;
        const originalText = button.innerHTML;
        button.setAttribute('data-original-text', originalText);
        button.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>导出中...';
    });
}

function hideExportLoading() {
    const exportButtons = document.querySelectorAll('[onclick*="confirmExport"]');
    exportButtons.forEach(button => {
        button.disabled = false;
        const originalText = button.getAttribute('data-original-text');
        if (originalText) {
            button.innerHTML = originalText;
        }
    });
}

// 闪现消息自动隐藏
function initFlashMessages() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        // 5秒后自动隐藏
        setTimeout(() => {
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-20px)';
            setTimeout(() => {
                alert.remove();
            }, 300);
        }, 5000);
    });
}

// 通用tooltip初始化函数
function initTooltips() {
    // 销毁已存在的tooltips
    const existingTooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    existingTooltips.forEach(element => {
        const tooltipInstance = bootstrap.Tooltip.getInstance(element);
        if (tooltipInstance) {
            tooltipInstance.dispose();
        }
    });
    
    // 重新初始化所有tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl, {
            trigger: 'hover focus',
            delay: { show: 500, hide: 100 }
        });
    });
}

// 页面加载完成后初始化所有功能
document.addEventListener('DOMContentLoaded', function() {
    initDataTable();
    initSearchFeatures();
    initFilterFeatures();
    initStatistics();
    initFlashMessages();
    
    // 初始化表格列调整功能
    initTableColumnResize();
    
    // 初始化列展开/折叠功能
    initColumnToggle();
    
    // 初始化列可见性控制
    initColumnVisibility();
    
    // 初始化所有tooltips
    initTooltips();
});

// 工具函数
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function formatNumber(num) {
    return new Intl.NumberFormat('zh-CN').format(num);
}

// 响应式表格处理
function handleResponsiveTable() {
    const tables = document.querySelectorAll('.table-responsive');
    tables.forEach(table => {
        // 添加滚动提示
        const scrollHint = document.createElement('div');
        scrollHint.className = 'text-muted small mt-2';
        scrollHint.innerHTML = '<i class="fas fa-arrows-alt-h me-1"></i>表格可以左右滚动查看更多列';
        table.parentNode.insertBefore(scrollHint, table.nextSibling);
        
        // 检测滚动状态
        table.addEventListener('scroll', function() {
            const isScrolled = this.scrollLeft > 0;
            if (isScrolled) {
                scrollHint.style.display = 'none';
            } else {
                scrollHint.style.display = 'block';
            }
        });
    });
}

// 初始化响应式功能
document.addEventListener('DOMContentLoaded', function() {
    handleResponsiveTable();
});

// 表格列宽调整功能
document.addEventListener('DOMContentLoaded', function() {
    initializeResizableTable();
});

function initializeResizableTable() {
    const table = document.querySelector('.data-table');
    if (!table) return;
    
    const headers = table.querySelectorAll('th');
    
    headers.forEach((header, index) => {
        // 跳过第一列（行号列）
        if (index === 0) return;
        
        // 创建调整手柄
        const resizeHandle = document.createElement('div');
        resizeHandle.className = 'resize-handle';
        resizeHandle.style.cssText = `
            position: absolute;
            top: 0;
            right: 0;
            width: 5px;
            height: 100%;
            cursor: col-resize;
            background: transparent;
            user-select: none;
        `;
        
        // 确保header是相对定位
        header.style.position = 'relative';
        header.appendChild(resizeHandle);
        
        let isResizing = false;
        let startX = 0;
        let startWidth = 0;
        
        resizeHandle.addEventListener('mousedown', function(e) {
            isResizing = true;
            startX = e.pageX;
            startWidth = header.offsetWidth;
            
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', handleMouseUp);
            
            // 防止文本选择
            e.preventDefault();
            document.body.style.userSelect = 'none';
        });
        
        function handleMouseMove(e) {
            if (!isResizing) return;
            
            const diff = e.pageX - startX;
            const newWidth = Math.max(80, startWidth + diff); // 最小宽度80px
            header.style.width = newWidth + 'px';
            
            // 同时调整对应的td
            const cells = table.querySelectorAll(`tbody tr td:nth-child(${index + 1})`);
            cells.forEach(cell => {
                cell.style.width = newWidth + 'px';
            });
        }
        
        function handleMouseUp() {
            isResizing = false;
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            document.body.style.userSelect = '';
        }
        
        // 悬停效果
        resizeHandle.addEventListener('mouseenter', function() {
            this.style.background = 'rgba(0, 123, 255, 0.3)';
        });
        
        resizeHandle.addEventListener('mouseleave', function() {
            if (!isResizing) {
                this.style.background = 'transparent';
            }
        });
    });
}

// 表格列大小调整功能
function initTableColumnResize() {
    const table = document.querySelector('.data-table');
    if (!table) return;
    
    let isResizing = false;
    let currentColumn = null;
    let startX = 0;
    let startWidth = 0;
    
    // 创建调整指示器
    const resizeIndicator = document.createElement('div');
    resizeIndicator.className = 'column-resize-indicator';
    document.body.appendChild(resizeIndicator);
    
    // 为每个可调整的表头添加事件监听器
    const headers = table.querySelectorAll('th:not(:last-child)');
    
    headers.forEach(header => {
        // 鼠标移动事件 - 检测是否在调整区域
        header.addEventListener('mousemove', function(e) {
            if (isResizing) return;
            
            const rect = this.getBoundingClientRect();
            const isInResizeZone = e.clientX > rect.right - 8;
            
            if (isInResizeZone) {
                this.style.cursor = 'col-resize';
                this.classList.add('resizing');
            } else {
                this.style.cursor = 'default';
                this.classList.remove('resizing');
            }
        });
        
        // 鼠标离开事件
        header.addEventListener('mouseleave', function() {
            if (!isResizing) {
                this.style.cursor = 'default';
                this.classList.remove('resizing');
            }
        });
        
        // 鼠标按下事件 - 开始调整
        header.addEventListener('mousedown', function(e) {
            const rect = this.getBoundingClientRect();
            const isInResizeZone = e.clientX > rect.right - 8;
            
            if (isInResizeZone) {
                isResizing = true;
                currentColumn = this;
                startX = e.clientX;
                startWidth = this.offsetWidth;
                
                // 显示调整指示器
                resizeIndicator.style.display = 'block';
                resizeIndicator.style.left = e.clientX + 'px';
                
                // 添加全局样式
                document.body.style.cursor = 'col-resize';
                document.body.style.userSelect = 'none';
                
                e.preventDefault();
            }
        });
    });
    
    // 全局鼠标移动事件 - 调整列宽
    document.addEventListener('mousemove', function(e) {
        if (!isResizing || !currentColumn) return;
        
        const deltaX = e.clientX - startX;
        const newWidth = Math.max(60, startWidth + deltaX); // 最小宽度60px
        
        // 更新列宽
        currentColumn.style.width = newWidth + 'px';
        
        // 更新对应的数据单元格宽度
        const columnIndex = Array.from(currentColumn.parentNode.children).indexOf(currentColumn);
        const rows = table.querySelectorAll('tbody tr');
        rows.forEach(row => {
            const cell = row.children[columnIndex];
            if (cell) {
                cell.style.width = newWidth + 'px';
            }
        });
        
        // 更新调整指示器位置
        resizeIndicator.style.left = e.clientX + 'px';
    });
    
    // 全局鼠标释放事件 - 结束调整
    document.addEventListener('mouseup', function() {
        if (isResizing) {
            isResizing = false;
            
            // 隐藏调整指示器
            resizeIndicator.style.display = 'none';
            
            // 清理样式
            if (currentColumn) {
                currentColumn.classList.remove('resizing');
                currentColumn.style.cursor = 'default';
            }
            
            document.body.style.cursor = 'default';
            document.body.style.userSelect = 'auto';
            
            currentColumn = null;
        }
    });
}

// 列展开/折叠功能
function initColumnToggle() {
    const toggleBtn = document.getElementById('toggleColumnsBtn');
    const columnsList = document.getElementById('columnsList');
    
    if (!toggleBtn || !columnsList) return;
    
    let isExpanded = false;
    
    toggleBtn.addEventListener('click', function() {
        isExpanded = !isExpanded;
        
        if (isExpanded) {
            // 展开状态
            columnsList.classList.remove('collapsed');
            toggleBtn.classList.add('expanded');
            toggleBtn.querySelector('span').textContent = '折叠';
            toggleBtn.title = '折叠列列表';
        } else {
            // 折叠状态
            columnsList.classList.add('collapsed');
            toggleBtn.classList.remove('expanded');
            toggleBtn.querySelector('span').textContent = '展开';
            toggleBtn.title = '展开列列表';
        }
    });
    
    // 初始化为折叠状态
    columnsList.classList.add('collapsed');
}

// 列可见性控制功能
function initColumnVisibility() {
    const visibilityButtons = document.querySelectorAll('.column-visibility-btn');
    
    visibilityButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const columnName = this.getAttribute('data-column');
            const columnIndex = parseInt(this.getAttribute('data-column-index'));
            
            // 切换按钮状态
            const isHidden = this.classList.toggle('column-hidden');
            
            // 更新图标
            const icon = this.querySelector('i');
            if (isHidden) {
                icon.className = 'fas fa-eye-slash';
                this.title = '显示列';
            } else {
                icon.className = 'fas fa-eye';
                this.title = '隐藏列';
            }
            
            // 切换表格列的可见性
            toggleTableColumn(columnIndex, !isHidden);
        });
    });
}

// 切换表格列可见性
function toggleTableColumn(columnIndex, visible) {
    const table = document.querySelector('.data-table');
    if (!table) return;
    
    // 调整索引（因为第一列是行号列）
    const targetIndex = columnIndex + 1;
    
    // 切换表头可见性
    const headerCell = table.querySelector(`thead tr th:nth-child(${targetIndex + 1})`);
    if (headerCell) {
        headerCell.style.display = visible ? '' : 'none';
    }
    
    // 切换所有数据行对应列的可见性
    const dataCells = table.querySelectorAll(`tbody tr td:nth-child(${targetIndex + 1})`);
    dataCells.forEach(cell => {
        cell.style.display = visible ? '' : 'none';
    });
}
