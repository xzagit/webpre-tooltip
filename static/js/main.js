// 主要JavaScript功能

// 注意: 导出和关闭功能已简化为直接链接，不再需要JavaScript确认

// 拖拽上传功能
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM Content Loaded');
    
    const dragDropArea = document.getElementById('file-upload-area') || document.getElementById('drag-drop-area');
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
        // 添加一个抖动效果
        dragDropArea.animate([
            { transform: 'translateY(0)' },
            { transform: 'translateY(-5px)' },
            { transform: 'translateY(0)' }
        ], {
            duration: 300,
            iterations: 1
        });
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
                    <small class="text-muted">正在上传文件...</small>
                `;
            }
            
            // 使用外部上传处理函数，如果存在
            if (typeof handleDirectUpload === 'function') {
                handleDirectUpload(file);
            }
            // 否则使用表单提交
            else if (fileForm) {
                fileForm.submit();
            } 
            else {
                // 如果找不到表单，使用默认上传表单
                const form = document.getElementById('upload-form');
                if (form) {
                    form.submit();
                } else {
                    console.error('找不到上传表单');
                }
            }
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
    // 检查页面加载类型，如果是刷新则清除状态
    if (performance.getEntriesByType) {
        const navEntries = performance.getEntriesByType('navigation');
        if (navEntries.length > 0 && navEntries[0].type === 'reload') {
            // 页面刷新，清除隐藏列状态
            sessionStorage.removeItem('hiddenColumns');
        }
    }
    
    initDataTable();
    initSearchFeatures();
    initFilterFeatures();
    initStatistics();
    initFlashMessages();
    
    // 初始化快捷操作按钮
    initQuickActions();
    
    // 初始化表格列调整功能
    initTableColumnResize();
    
    // 初始化列展开/折叠功能
    initColumnToggle();
    
    // 初始化列可见性控制
    initColumnVisibility();
    
    // 加载列可见性状态（必须在initColumnVisibility之后）
    loadGlobalColumnVisibilityState();
    
    // 初始化列统计信息
    updateColumnStats();
    
    // 优化表格布局
    optimizeTableLayout();
    
    // 处理响应式表格
    handleResponsiveTable();
    
    // 增强分页交互
    enhancePaginationInteraction();
    
    // 初始化所有tooltips
    initTooltips();
});

// 监听页面卸载事件
window.addEventListener('beforeunload', function() {
    // 保存当前状态（防止意外关闭）
    if (typeof saveGlobalColumnVisibilityState === 'function') {
        saveGlobalColumnVisibilityState();
    }
});

// 监听页面隐藏事件（用户切换标签页等）
document.addEventListener('visibilitychange', function() {
    if (document.hidden && typeof saveGlobalColumnVisibilityState === 'function') {
        // 页面变为不可见时保存状态
        saveGlobalColumnVisibilityState();
    }
});

// 更新列统计信息
function updateColumnStats() {
    const visibleCount = document.querySelectorAll('.data-table th').length - globalHiddenColumns.size;
    const hiddenCount = globalHiddenColumns.size;
    
    const visibleElement = document.getElementById('visibleColumnsCount');
    const hiddenElement = document.getElementById('hiddenColumnsCount');
    
    if (visibleElement) {
        visibleElement.classList.add('updating');
        setTimeout(() => {
            visibleElement.textContent = visibleCount;
            visibleElement.classList.remove('updating');
        }, 100);
    }
    
    if (hiddenElement) {
        hiddenElement.classList.add('updating');
        setTimeout(() => {
            hiddenElement.textContent = hiddenCount;
            hiddenElement.classList.remove('updating');
        }, 100);
    }
}

// 显示所有列
function showAllColumns() {
    const buttons = document.querySelectorAll('.column-visibility-btn');
    buttons.forEach(button => {
        const columnIndex = parseInt(button.getAttribute('data-column-index'));
        if (globalHiddenColumns.has(columnIndex)) {
            globalHiddenColumns.delete(columnIndex);
            button.classList.remove('column-hidden');
            const icon = button.querySelector('i');
            if (icon) {
                icon.className = 'fas fa-eye';
            }
            button.setAttribute('title', '点击隐藏此列');
            
            // 显示表格列
            toggleTableColumn(columnIndex, true);
            
            // 更新tooltip
            const tooltipInstance = bootstrap.Tooltip.getInstance(button);
            if (tooltipInstance) {
                tooltipInstance.setContent({ '.tooltip-inner': '点击隐藏此列' });
            }
        }
    });
    
    saveGlobalColumnVisibilityState();
    updateColumnStats();
}

// 隐藏所有列（保留第一列）
function hideAllColumns() {
    const buttons = document.querySelectorAll('.column-visibility-btn');
    buttons.forEach((button, index) => {
        // 保留第一列不隐藏
        if (index === 0) return;
        
        const columnIndex = parseInt(button.getAttribute('data-column-index'));
        if (!globalHiddenColumns.has(columnIndex)) {
            globalHiddenColumns.add(columnIndex);
            button.classList.add('column-hidden');
            const icon = button.querySelector('i');
            if (icon) {
                icon.className = 'fas fa-eye-slash';
            }
            button.setAttribute('title', '点击显示此列');
            
            // 隐藏表格列
            toggleTableColumn(columnIndex, false);
            
            // 更新tooltip
            const tooltipInstance = bootstrap.Tooltip.getInstance(button);
            if (tooltipInstance) {
                tooltipInstance.setContent({ '.tooltip-inner': '点击显示此列' });
            }
        }
    });
    
    saveGlobalColumnVisibilityState();
    updateColumnStats();
}

// 初始化快捷操作按钮
function initQuickActions() {
    const showAllBtn = document.getElementById('showAllColumnsBtn');
    const hideAllBtn = document.getElementById('hideAllColumnsBtn');
    
    if (showAllBtn) {
        showAllBtn.addEventListener('click', function() {
            showAllColumns();
            
            // 添加视觉反馈
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
        });
    }
    
    if (hideAllBtn) {
        hideAllBtn.addEventListener('click', function() {
            hideAllColumns();
            
            // 添加视觉反馈
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = '';
            }, 150);
        });
    }
}

// 简化版列管理功能
function initColumnVisibilityOnly() {
    const columnsList = document.getElementById('columnsList');
    const showAllBtn = document.getElementById('showAllColumnsBtn');
    
    if (!columnsList) return;
    
    // 添加全部显示按钮事件
    if (showAllBtn) {
        showAllBtn.addEventListener('click', function() {
            showAllColumns();
        });
    }
}

// 执行列搜索
function performColumnSearch(searchTerm) {
    const columnItems = document.querySelectorAll('.modern-column-item');
    const columnsList = document.getElementById('columnsList');
    let visibleCount = 0;
    let hasResults = false;
    
    // 移除之前的搜索结果提示
    const existingNoResults = columnsList.querySelector('.no-search-results');
    if (existingNoResults) {
        existingNoResults.remove();
    }
    
    const existingCount = columnsList.querySelector('.search-results-count');
    if (existingCount) {
        existingCount.remove();
    }
    
    if (!searchTerm) {
        clearColumnSearch();
        return;
    }
    
    columnItems.forEach(item => {
        const columnNameElement = item.querySelector('.column-name-text');
        if (!columnNameElement) return;
        
        const columnName = columnNameElement.textContent.toLowerCase();
        const matches = columnName.includes(searchTerm);
        
        if (matches) {
            item.classList.remove('search-hidden');
            item.classList.add('search-highlight');
            visibleCount++;
            hasResults = true;
            
            // 高亮匹配的文本
            highlightSearchMatch(columnNameElement, searchTerm);
        } else {
            item.classList.add('search-hidden');
            item.classList.remove('search-highlight');
            
            // 清除高亮
            clearHighlight(columnNameElement);
        }
    });
    
    // 显示搜索结果计数
    if (hasResults) {
        const countElement = document.createElement('div');
        countElement.className = 'search-results-count';
        countElement.textContent = `找到 ${visibleCount} 个匹配的列`;
        columnsList.appendChild(countElement);
    } else {
        // 显示无结果提示
        const noResultsElement = document.createElement('div');
        noResultsElement.className = 'no-search-results';
        noResultsElement.innerHTML = `
            <i class="fas fa-search"></i><br>
            未找到包含 "${searchTerm}" 的列
        `;
        columnsList.appendChild(noResultsElement);
    }
    
    // 如果列表是折叠状态，自动展开以显示搜索结果
    if (columnsList.classList.contains('collapsed') && hasResults) {
        const toggleBtn = document.getElementById('toggleColumnsBtn');
        if (toggleBtn && !toggleBtn.classList.contains('expanded')) {
            toggleBtn.click();
        }
    }
}

// 清空列搜索
function clearColumnSearch() {
    const columnItems = document.querySelectorAll('.modern-column-item');
    const columnsList = document.getElementById('columnsList');
    
    columnItems.forEach(item => {
        item.classList.remove('search-hidden', 'search-highlight');
        
        // 清除高亮
        const columnNameElement = item.querySelector('.column-name-text');
        if (columnNameElement) {
            clearHighlight(columnNameElement);
        }
    });
    
    // 移除搜索结果提示
    const existingNoResults = columnsList.querySelector('.no-search-results');
    if (existingNoResults) {
        existingNoResults.remove();
    }
    
    const existingCount = columnsList.querySelector('.search-results-count');
    if (existingCount) {
        existingCount.remove();
    }
}

// 高亮搜索匹配的文本
function highlightSearchMatch(element, searchTerm) {
    const originalText = element.getAttribute('data-original-text') || element.textContent;
    
    // 保存原始文本
    if (!element.getAttribute('data-original-text')) {
        element.setAttribute('data-original-text', originalText);
    }
    
    const regex = new RegExp(`(${escapeRegExp(searchTerm)})`, 'gi');
    const highlightedText = originalText.replace(regex, '<mark class="search-highlight-text">$1</mark>');
    
    element.innerHTML = highlightedText;
}

// 清除高亮
function clearHighlight(element) {
    const originalText = element.getAttribute('data-original-text');
    if (originalText) {
        element.textContent = originalText;
    }
}

// 转义正则表达式特殊字符
function escapeRegExp(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

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

// 表格宽度自适应和滚动优化
function optimizeTableLayout() {
    const tableContainer = document.querySelector('.resizable-table-container');
    const table = document.querySelector('.data-table');
    
    if (!tableContainer || !table) return;
    
    // 计算表格理想宽度
    const containerWidth = tableContainer.parentElement.clientWidth;
    const columns = table.querySelectorAll('th');
    
    // 设置表格最大宽度为容器宽度
    table.style.maxWidth = containerWidth + 'px';
    
    // 智能调整列宽
    const columnCount = columns.length;
    const idealColumnWidth = Math.max(120, (containerWidth - 80) / columnCount); // 减去行号列宽度
    
    columns.forEach((th, index) => {
        if (index === 0) {
            // 行号列固定宽度
            th.style.width = '60px';
            th.style.minWidth = '60px';
            th.style.maxWidth = '60px';
        } else {
            // 其他列自适应
            const headerText = th.textContent;
            const estimatedWidth = Math.max(
                idealColumnWidth,
                headerText.length * 8 + 40, // 根据文本长度估算
                100 // 最小宽度
            );
            th.style.width = Math.min(estimatedWidth, 300) + 'px'; // 最大300px
        }
    });
    
    // 同步设置表格数据列宽度
    const rows = table.querySelectorAll('tbody tr');
    rows.forEach(row => {
        const cells = row.querySelectorAll('td');
        cells.forEach((cell, index) => {
            const correspondingHeader = columns[index];
            if (correspondingHeader) {
                cell.style.width = correspondingHeader.style.width;
                cell.style.minWidth = correspondingHeader.style.minWidth;
                cell.style.maxWidth = correspondingHeader.style.maxWidth;
            }
        });
    });
}

// 智能列宽调整
function smartColumnResize() {
    const table = document.querySelector('.data-table');
    const container = document.querySelector('.resizable-table-container');
    
    if (!table || !container) return;
    
    const availableWidth = container.clientWidth - 20; // 留出边距
    const columns = table.querySelectorAll('th');
    const visibleColumns = Array.from(columns).filter(col => {
        const index = Array.from(columns).indexOf(col);
        return !globalHiddenColumns.has(index - 1); // 排除行号列
    });
    
    if (visibleColumns.length === 0) return;
    
    // 计算当前表格宽度
    let currentWidth = 0;
    visibleColumns.forEach(col => {
        currentWidth += col.offsetWidth;
    });
    
    // 如果表格宽度超出容器，进行智能调整
    if (currentWidth > availableWidth) {
        const scaleFactor = availableWidth / currentWidth * 0.95; // 留5%缓冲
        
        visibleColumns.forEach(col => {
            const currentWidth = col.offsetWidth;
            const newWidth = Math.max(80, currentWidth * scaleFactor); // 最小80px
            col.style.width = newWidth + 'px';
            
            // 同步更新数据列
            const columnIndex = Array.from(columns).indexOf(col);
            const dataCells = table.querySelectorAll(`td:nth-child(${columnIndex + 1})`);
            dataCells.forEach(cell => {
                cell.style.width = newWidth + 'px';
            });
        });
    }
}

// 表格自适应观察器
function initTableResizeObserver() {
    const container = document.querySelector('.resizable-table-container');
    if (!container) return;
    
    // 使用 ResizeObserver 监听容器大小变化
    if (window.ResizeObserver) {
        const resizeObserver = new ResizeObserver(debounce(() => {
            optimizeTableLayout();
            smartColumnResize();
            handleResponsiveTable();
        }, 250));
        
        resizeObserver.observe(container);
    } else {
        // 降级到 resize 事件
        window.addEventListener('resize', debounce(() => {
            optimizeTableLayout();
            smartColumnResize();
            handleResponsiveTable();
        }, 250));
    }
}

// 快速跳转到页面功能
function initQuickPageJump() {
    const paginationContainer = document.querySelector('.pagination-container');
    if (!paginationContainer) return;
    
    // 添加快速跳转输入框
    const quickJump = document.createElement('div');
    quickJump.className = 'quick-page-jump mt-3';
    quickJump.innerHTML = `
        <div class="input-group input-group-sm justify-content-center" style="max-width: 200px; margin: 0 auto;">
            <span class="input-group-text">跳转到</span>
            <input type="number" class="form-control text-center" id="quickPageInput" min="1" max="${Math.ceil(parseInt(document.querySelector('.pagination-info').textContent.match(/共 (\d+) 页/)?.[1] || 1))}" placeholder="页码">
            <button class="btn btn-outline-primary" type="button" id="quickPageBtn">
                <i class="fas fa-arrow-right"></i>
            </button>
        </div>
    `;
    
    paginationContainer.appendChild(quickJump);
    
    // 绑定事件
    const input = document.getElementById('quickPageInput');
    const button = document.getElementById('quickPageBtn');
    
    const jumpToPage = () => {
        const pageNum = parseInt(input.value);
        const maxPage = parseInt(input.getAttribute('max'));
        
        if (pageNum && pageNum >= 1 && pageNum <= maxPage) {
            const currentUrl = new URL(window.location);
            currentUrl.searchParams.set('page', pageNum);
            window.location.href = currentUrl.toString();
        } else {
            input.classList.add('is-invalid');
            setTimeout(() => input.classList.remove('is-invalid'), 2000);
        }
    };
    
    button.addEventListener('click', jumpToPage);
    input.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            jumpToPage();
        }
    });
}

// 页面加载完成后初始化表格布局和交互增强功能
document.addEventListener('DOMContentLoaded', function() {
    // 优化表格布局
    optimizeTableLayout();
    
    // 初始化响应式表格处理
    handleResponsiveTable();
    
    // 增强分页按钮交互
    enhancePaginationInteraction();
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
let globalHiddenColumns = new Set();

// 从sessionStorage加载隐藏列状态
function loadGlobalColumnVisibilityState() {
    const savedState = sessionStorage.getItem('hiddenColumns');
    if (savedState) {
        try {
            const hiddenColumnIndices = JSON.parse(savedState);
            globalHiddenColumns = new Set(hiddenColumnIndices);
            
            // 应用保存的状态
            globalHiddenColumns.forEach(columnIndex => {
                const button = document.querySelector(`button[data-column-index="${columnIndex}"]`);
                if (button) {
                    button.classList.add('column-hidden');
                    const icon = button.querySelector('i');
                    if (icon) {
                        icon.className = 'fas fa-eye-slash';
                    }
                    button.setAttribute('title', '点击显示此列');
                    
                    // 隐藏对应的表格列
                    toggleTableColumn(columnIndex, false);
                    
                    // 更新tooltip
                    const tooltipInstance = bootstrap.Tooltip.getInstance(button);
                    if (tooltipInstance) {
                        tooltipInstance.dispose();
                        new bootstrap.Tooltip(button);
                    }
                }
            });
            
            // 更新列统计信息
            updateColumnStats();
        } catch (e) {
            console.warn('Failed to load column visibility state:', e);
            sessionStorage.removeItem('hiddenColumns');
        }
    }
}

// 保存隐藏列状态到sessionStorage
function saveGlobalColumnVisibilityState() {
    sessionStorage.setItem('hiddenColumns', JSON.stringify([...globalHiddenColumns]));
}

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
            
            // 更新全局状态
            if (isHidden) {
                globalHiddenColumns.add(columnIndex);
            } else {
                globalHiddenColumns.delete(columnIndex);
            }
            
            // 更新图标和提示文本
            const icon = this.querySelector('i');
            if (isHidden) {
                icon.className = 'fas fa-eye-slash';
                this.setAttribute('title', '点击显示此列');
            } else {
                icon.className = 'fas fa-eye';
                this.setAttribute('title', '点击隐藏此列');
            }
            
            // 切换表格列的可见性
            toggleTableColumn(columnIndex, !isHidden);
            
            // 保存状态
            saveGlobalColumnVisibilityState();
            
            // 更新列统计信息
            updateColumnStats();
            
            // 重新初始化tooltip以更新提示文本
            const tooltipInstance = bootstrap.Tooltip.getInstance(this);
            if (tooltipInstance) {
                tooltipInstance.dispose();
                new bootstrap.Tooltip(this);
            }
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
