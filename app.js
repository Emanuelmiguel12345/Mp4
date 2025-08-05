document.addEventListener('DOMContentLoaded', () => {
    // Elementos DOM
    const dropArea = document.getElementById('dropArea');
    const fileInput = document.getElementById('fileInput');
    const selectFileBtn = document.getElementById('selectFileBtn');
    const queueContainer = document.getElementById('queueContainer');
    const queueList = document.getElementById('queueList');
    const queueCount = document.getElementById('queueCount');
    const clearQueueBtn = document.getElementById('clearQueueBtn');
    const convertAllBtn = document.getElementById('convertAllBtn');
    const downloadAllBtn = document.getElementById('downloadAllBtn');
    const downloadAllContainer = document.getElementById('downloadAllContainer');
    const globalProgressContainer = document.getElementById('globalProgressContainer');
    const globalProgressBar = document.getElementById('globalProgressBar');
    const globalProgressText = document.getElementById('globalProgressText');
    const globalProgressPercent = document.getElementById('globalProgressPercent');
    const settingsToggle = document.getElementById('settingsToggle');
    const settingsContent = document.getElementById('settingsContent');
    const qualitySelect = document.getElementById('qualitySelect');
    const outputFormat = document.getElementById('outputFormat');
    const errorModal = document.getElementById('errorModal');
    const errorMessage = document.getElementById('errorMessage');
    const modalClose = document.getElementById('modalClose');
    const modalOk = document.getElementById('modalOk');

    // Configurações
    const MAX_FILE_SIZE = 500 * 1024 * 1024; // 500MB
    const SUPPORTED_FORMATS = ['.mp4', '.webm', '.mov', '.avi', '.mkv'];
    
    // Estado da aplicação
    let conversionQueue = [];
    let convertedFiles = [];
    let isConverting = false;
    
    // Configuração do FFmpeg
    const { createFFmpeg, fetchFile } = FFmpeg;
    const ffmpeg = createFFmpeg({ 
        log: true,
        corePath: 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js',
        progress: ({ ratio }) => {
            const percent = Math.round(ratio * 100);
            updateCurrentConversionProgress(percent);
        }
    });
    
    // Event Listeners
    selectFileBtn.addEventListener('click', () => fileInput.click());
    
    fileInput.addEventListener('change', (e) => {
        if (e.target.files.length) {
            handleFileSelection(Array.from(e.target.files));
        }
    });
    
    clearQueueBtn.addEventListener('click', clearQueue);
    convertAllBtn.addEventListener('click', startConversion);
    downloadAllBtn.addEventListener('click', downloadAllConvertedFiles);
    settingsToggle.addEventListener('click', toggleSettings);
    modalClose.addEventListener('click', closeErrorModal);
    modalOk.addEventListener('click', closeErrorModal);
    
    // Drag and Drop
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
        document.body.addEventListener(eventName, preventDefaults, false);
    });
    
    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, unhighlight, false);
    });
    
    dropArea.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        if (files.length) {
            handleFileSelection(Array.from(files));
        }
    });
    
    // Funções principais
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    function highlight() {
        dropArea.classList.add('highlight');
    }
    
    function unhighlight() {
        dropArea.classList.remove('highlight');
    }
    
    function toggleSettings() {
        settingsContent.classList.toggle('hidden');
    }
    
    function handleFileSelection(files) {
        const validFiles = files.filter(file => {
            const fileExtension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
            
            if (!SUPPORTED_FORMATS.includes(fileExtension)) {
                showError(`Formato não suportado: ${file.name}. Formatos aceitos: ${SUPPORTED_FORMATS.join(', ')}`);
                return false;
            }
            
            if (file.size > MAX_FILE_SIZE) {
                showError(`Arquivo muito grande: ${file.name}. Limite: 500MB`);
                return false;
            }
            
            return true;
        });
        
        if (validFiles.length === 0) return;
        
        addFilesToQueue(validFiles);
        showToast(`${validFiles.length} arquivo(s) adicionado(s) à fila`);
    }
    
    function addFilesToQueue(files) {
        files.forEach(file => {
            // Verificar se o arquivo já está na fila
            const isDuplicate = conversionQueue.some(item => 
                item.file.name === file.name && item.file.size === file.size
            );
            
            if (!isDuplicate) {
                conversionQueue.push({
                    file,
                    status: 'pending',
                    progress: 0,
                    element: null
                });
            }
        });
        
        updateQueueDisplay();
    }
    
    function updateQueueDisplay() {
        queueList.innerHTML = '';
        
        conversionQueue.forEach((item, index) => {
            const queueItem = document.createElement('div');
            queueItem.className = `queue-item ${item.status}`;
            
            queueItem.innerHTML = `
                <div class="queue-item-info">
                    <i class="fas ${getFileIcon(item.file.name)} queue-item-icon"></i>
                    <div class="queue-item-details">
                        <div class="queue-item-name" title="${item.file.name}">${item.file.name}</div>
                        <div class="queue-item-size">${formatFileSize(item.file.size)}</div>
                    </div>
                </div>
                <div class="queue-item-status status-${item.status}">
                    ${getStatusText(item.status, item.progress)}
                </div>
                <div class="queue-item-actions">
                    ${item.status === 'pending' ? `
                        <button class="queue-item-btn remove" data-index="${index}">
                            <i class="fas fa-times"></i>
                        </button>
                    ` : ''}
                </div>
            `;
            
            queueList.appendChild(queueItem);
            item.element = queueItem;
            
            // Adicionar evento de remoção
            if (item.status === 'pending') {
                const removeBtn = queueItem.querySelector('.remove');
                removeBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    removeFromQueue(index);
                });
            }
        });
        
        queueCount.textContent = `${conversionQueue.length} ${conversionQueue.length === 1 ? 'item' : 'itens'}`;
        queueContainer.classList.remove('hidden');
        
        // Mostrar/ocultar botão de converter tudo
        const hasPendingItems = conversionQueue.some(item => item.status === 'pending');
        convertAllBtn.style.display = hasPendingItems ? 'flex' : 'none';
    }
    
    function getFileIcon(filename) {
        const extension = filename.substring(filename.lastIndexOf('.')).toLowerCase();
        
        switch(extension) {
            case '.mp4': return 'fa-file-video';
            case '.webm': return 'fa-file-video';
            case '.mov': return 'fa-file-video';
            case '.avi': return 'fa-file-video';
            case '.mkv': return 'fa-file-video';
            default: return 'fa-file';
        }
    }
    
    function getStatusText(status, progress) {
        switch(status) {
            case 'pending': return 'Na fila';
            case 'converting': return `${progress}%`;
            case 'completed': return 'Pronto';
            case 'error': return 'Erro';
            default: return '';
        }
    }
    
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    function removeFromQueue(index) {
        if (conversionQueue[index].status === 'converting') {
            showError('Não é possível remover um arquivo durante a conversão');
            return;
        }
        
        conversionQueue.splice(index, 1);
        updateQueueDisplay();
        
        if (conversionQueue.length === 0) {
            queueContainer.classList.add('hidden');
        }
    }
    
    function clearQueue() {
        // Só remove itens que não estão sendo convertidos
        conversionQueue = conversionQueue.filter(item => item.status === 'converting');
        updateQueueDisplay();
        
        if (conversionQueue.length === 0) {
            queueContainer.classList.add('hidden');
        } else {
            showError('Alguns arquivos não puderam ser removidos pois estão em processo de conversão');
        }
    }
    
    async function startConversion() {
        if (isConverting) {
            showError('Já existe uma conversão em andamento');
            return;
        }
        
        const pendingItems = conversionQueue.filter(item => item.status === 'pending');
        if (pendingItems.length === 0) {
            showError('Nenhum arquivo pendente para conversão');
            return;
        }
        
        isConverting = true;
        convertedFiles = [];
        globalProgressContainer.classList.remove('hidden');
        
        // Carregar FFmpeg se necessário
        if (!ffmpeg.isLoaded()) {
            globalProgressText.textContent = 'Carregando FFmpeg...';
            try {
                await ffmpeg.load();
            } catch (error) {
                console.error('Erro ao carregar FFmpeg:', error);
                showError('Falha ao carregar o conversor. Por favor, recarregue a página.');
                isConverting = false;
                return;
            }
        }
        
        // Converter cada arquivo na fila
        for (let i = 0; i < conversionQueue.length; i++) {
            const item = conversionQueue[i];
            
            if (item.status !== 'pending') continue;
            
            try {
                item.status = 'converting';
                item.progress = 0;
                updateQueueItem(i);
                
                globalProgressText.textContent = `Convertendo: ${item.file.name}`;
                updateGlobalProgress(i, conversionQueue.length);
                
                // Configurações de conversão
                const quality = qualitySelect.value;
                const format = outputFormat.value;
                const outputFilename = item.file.name.replace(/\.[^/.]+$/, '') + '.' + format;
                
                // Escrever o arquivo no sistema de arquivos FFmpeg
                ffmpeg.FS('writeFile', 'input', await fetchFile(item.file));
                
                // Comando de conversão baseado nas configurações
                let command = ['-i', 'input'];
                
                // Configurações de qualidade para MP3
                if (format === 'mp3') {
                    const bitrates = ['320k', '192k', '128k'];
                    command.push('-b:a', bitrates[quality], '-q:a', quality);
                }
                
                // Configurações para outros formatos
                if (format === 'wav') {
                    command.push('-acodec', 'pcm_s16le');
                } else if (format === 'ogg') {
                    command.push('-acodec', 'libvorbis');
                } else if (format === 'aac') {
                    command.push('-acodec', 'aac', '-b:a', '192k');
                }
                
                command.push('output.' + format);
                
                // Executar conversão
                await ffmpeg.run(...command);
                
                // Ler o resultado
                const data = ffmpeg.FS('readFile', 'output.' + format);
                
                // Criar blob para download
                const mimeType = getMimeType(format);
                const blob = new Blob([data.buffer], { type: mimeType });
                const url = URL.createObjectURL(blob);
                
                // Atualizar status
                item.status = 'completed';
                item.progress = 100;
                item.output = {
                    blob,
                    url,
                    filename: outputFilename
                };
                
                updateQueueItem(i);
                convertedFiles.push(item);
                
                // Limpar arquivos temporários
                try {
                    ffmpeg.FS('unlink', 'input');
                    ffmpeg.FS('unlink', 'output.' + format);
                } catch (error) {
                    console.error('Erro ao limpar arquivos temporários:', error);
                }
                
            } catch (error) {
                console.error('Erro na conversão:', error);
                item.status = 'error';
                updateQueueItem(i);
                showError(`Falha ao converter ${item.file.name}: ${error.message}`);
                
                // Tentar limpar arquivos temporários em caso de erro
                try {
                    ffmpeg.FS('unlink', 'input');
                    ffmpeg.FS('unlink', 'output.' + outputFormat.value);
                } catch (cleanError) {
                    console.error('Erro ao limpar arquivos temporários:', cleanError);
                }
            }
        }
        
        // Finalizar processo
        isConverting = false;
        globalProgressText.textContent = 'Conversão concluída!';
        globalProgressPercent.textContent = '100%';
        globalProgressBar.style.width = '100%';
        
        // Mostrar botão de download todos
        if (convertedFiles.length > 0) {
            downloadAllContainer.classList.remove('hidden');
        }
    }
    
    function getMimeType(format) {
        switch(format) {
            case 'mp3': return 'audio/mpeg';
            case 'wav': return 'audio/wav';
            case 'ogg': return 'audio/ogg';
            case 'aac': return 'audio/aac';
            default: return 'audio/mpeg';
        }
    }
    
    function updateQueueItem(index) {
        const item = conversionQueue[index];
        if (!item.element) return;
        
        // Atualizar status
        const statusElement = item.element.querySelector('.queue-item-status');
        if (statusElement) {
            statusElement.className = `queue-item-status status-${item.status}`;
            statusElement.textContent = getStatusText(item.status, item.progress);
        }
        
        // Atualizar ações
        const actionsElement = item.element.querySelector('.queue-item-actions');
        if (actionsElement) {
            actionsElement.innerHTML = item.status === 'pending' ? `
                <button class="queue-item-btn remove" data-index="${index}">
                    <i class="fas fa-times"></i>
                </button>
            ` : '';
            
            if (item.status === 'pending') {
                const removeBtn = actionsElement.querySelector('.remove');
                removeBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    removeFromQueue(index);
                });
            }
        }
    }
    
    function updateCurrentConversionProgress(percent) {
        const convertingItem = conversionQueue.find(item => item.status === 'converting');
        if (convertingItem) {
            convertingItem.progress = percent;
            updateQueueItem(conversionQueue.indexOf(convertingItem));
            
            // Atualizar progresso global
            const convertingIndex = conversionQueue.findIndex(item => item.status === 'converting');
            const totalItems = conversionQueue.length;
            const itemProgress = percent / 100;
            const globalPercent = Math.round(((convertingIndex + itemProgress) / totalItems) * 100);
            
            globalProgressBar.style.width = `${globalPercent}%`;
            globalProgressPercent.textContent = `${globalPercent}%`;
        }
    }
    
    function updateGlobalProgress(currentIndex, totalItems) {
        const percent = Math.round((currentIndex / totalItems) * 100);
        globalProgressBar.style.width = `${percent}%`;
        globalProgressPercent.textContent = `${percent}%`;
    }
    
    function downloadAllConvertedFiles() {
        if (convertedFiles.length === 0) return;
        
        if (convertedFiles.length === 1) {
            // Download único se houver apenas um arquivo
            const item = convertedFiles[0];
            triggerDownload(item.output.url, item.output.filename);
        } else {
            // Criar ZIP para múltiplos arquivos (usando biblioteca JSZip)
            showToast('Preparando arquivos para download...', 'info');
            
            // Carregar JSZip dinamicamente
            const script = document.createElement('script');
            script.src = 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js';
            script.onload = async () => {
                try {
                    const JSZip = window.JSZip;
                    const zip = new JSZip();
                    
                    // Adicionar cada arquivo ao ZIP
                    for (const item of convertedFiles) {
                        if (item.status === 'completed') {
                            const blob = item.output.blob;
                            zip.file(item.output.filename, blob);
                        }
                    }
                    
                    // Gerar o arquivo ZIP
                    const content = await zip.generateAsync({ type: 'blob' });
                    const url = URL.createObjectURL(content);
                    
                    // Trigger download
                    triggerDownload(url, 'conversao_arquivos.zip');
                    
                    // Limpar
                    URL.revokeObjectURL(url);
                    
                } catch (error) {
                    console.error('Erro ao criar ZIP:', error);
                    showError('Falha ao criar arquivo ZIP. Baixe os arquivos individualmente.');
                }
            };
            
            script.onerror = () => {
                showError('Falha ao carregar o compactador. Baixe os arquivos individualmente.');
            };
            
            document.body.appendChild(script);
        }
    }
    
    function triggerDownload(url, filename) {
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        
        // Não revogar a URL imediatamente para permitir que o download complete
        setTimeout(() => {
            URL.revokeObjectURL(url);
        }, 10000);
    }
    
    function showError(message) {
        errorMessage.textContent = message;
        errorModal.classList.add('active');
        
        // Registrar erro no console
        console.error(message);
    }
    
    function closeErrorModal() {
        errorModal.classList.remove('active');
    }
    
    function showToast(message, type = 'success') {
        const backgroundColor = type === 'success' ? '#10b981' : type === 'error' ? '#f43f5e' : '#6366f1';
        
        Toastify({
            text: message,
            duration: 3000,
            close: true,
            gravity: "top",
            position: "right",
            stopOnFocus: true,
            style: {
                background: backgroundColor,
                borderRadius: "8px",
                boxShadow: "0 4px 12px rgba(0, 0, 0, 0.2)"
            }
        }).showToast();
    }
});