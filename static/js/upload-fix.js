// 修复上传文件需要两次提交的bug
document.addEventListener('DOMContentLoaded', function() {
    // 文件选择处理
    const fileInput = document.getElementById('file-input');
    const uploadForm = document.getElementById('upload-form');
    const dragDropArea = document.getElementById('file-upload-area');
    
    if (fileInput) {
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                handleDirectUpload(this.files[0]);
            }
        });
    }
    
    // 处理文件拖放上传
    if (dragDropArea) {
        dragDropArea.addEventListener('drop', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const dt = e.dataTransfer;
            const files = dt.files;
            
            if (files.length > 0) {
                const file = files[0];
                // 检查文件类型是否被允许
                const fileExtension = file.name.split('.').pop().toLowerCase();
                const allowedExtensions = ['csv', 'json', 'jsonl', 'parquet', 'pq'];
                
                if (allowedExtensions.includes(fileExtension)) {
                    handleDirectUpload(file);
                } else {
                    alert('不支持的文件格式。请上传 CSV, JSON, JSONL 或 Parquet 格式文件。');
                }
            }
            
            // 取消高亮状态
            dragDropArea.classList.remove('drag-over');
        });
    }
    
    // 直接处理上传文件
    function handleDirectUpload(file) {
        // 显示文件信息
        if (dragDropArea) {
            const uploadText = dragDropArea.querySelector('.upload-text');
            if (uploadText) {
                const fileSize = (file.size / 1024 / 1024).toFixed(2);
                uploadText.innerHTML = `
                    <div class="text-success">
                        <i class="fas fa-check-circle"></i>
                        已选择文件: ${file.name} (${fileSize} MB)
                    </div>
                    <small class="text-muted">正在上传文件...</small>
                    <div class="spinner-border text-primary mt-3" role="status">
                        <span class="visually-hidden">上传中...</span>
                    </div>
                `;
            }
        }
        
        // 显示上传进度模态框
        const uploadModal = document.createElement('div');
        uploadModal.innerHTML = `
            <div class="modal fade" id="uploadModal" tabindex="-1" data-bs-backdrop="static">
                <div class="modal-dialog modal-sm">
                    <div class="modal-content">
                        <div class="modal-body text-center p-4">
                            <div class="spinner-border text-primary mb-3" role="status">
                                <span class="visually-hidden">上传中...</span>
                            </div>
                            <h5 class="mb-3">正在上传文件</h5>
                            <p class="mb-1">${file.name}</p>
                            <p class="text-muted small">文件大小: ${formatFileSize(file.size)}</p>
                            <div class="progress mt-3">
                                <div class="progress-bar progress-bar-striped progress-bar-animated" 
                                     role="progressbar" style="width: 100%"></div>
                            </div>
                            <p class="mt-3 text-muted small">请耐心等待，上传完成后将自动跳转</p>
                        </div>
                    </div>
                </div>
            </div>
        `;
        document.body.appendChild(uploadModal);
        
        const modal = new bootstrap.Modal(document.getElementById('uploadModal'));
        modal.show();
        
        // 使用表单提交方式上传
        if (uploadForm) {
            // 设置文件到表单的文件输入
            if (fileInput) {
                // 创建一个新的 FileList 对象
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(file);
                fileInput.files = dataTransfer.files;
            }
            // 提交表单
            uploadForm.submit();
        } else {
            // 回退到fetch上传
            const formData = new FormData();
            formData.append('file', file);
            
            fetch('/upload', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (response.ok) {
                    window.location.href = '/data';
                } else {
                    modal.hide();
                    alert('文件上传失败，请重试');
                }
            })
            .catch(error => {
                modal.hide();
                console.error('上传错误:', error);
                alert('文件上传失败: ' + error.message);
            });
        }
    }
    
    // 格式化文件大小
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    // 检查文件类型是否合法
    function isValidFileType(filename) {
        const allowedExtensions = ['csv', 'json', 'jsonl', 'parquet', 'pq'];
        const ext = filename.split('.').pop().toLowerCase();
        return allowedExtensions.includes(ext);
    }
});
