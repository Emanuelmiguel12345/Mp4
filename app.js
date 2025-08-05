document.addEventListener('DOMContentLoaded', () => {
    // Elementos DOM
    const dropArea = document.getElementById('dropArea');
    const fileInput = document.getElementById('fileInput');
    const selectFileBtn = document.getElementById('selectFileBtn');
    const fileInfo = document.getElementById('fileInfo');
    const fileName = document.getElementById('fileName');
    const fileSize = document.getElementById('fileSize');
    const cancelBtn = document.getElementById('cancelBtn');
    const convertBtn = document.getElementById('convertBtn');
    const downloadBtn = document.getElementById('downloadBtn');
    const progressContainer = document.getElementById('progressContainer');
    const progressBar = document.getElementById('progressBar');
    const progressText = document.getElementById('progressText');
    
    let selectedFile = null;
    const MAX_FILE_SIZE = 100 * 1024 * 1024; // 100MB
    
    // Configuração do FFmpeg
    const { createFFmpeg, fetchFile } = FFmpeg;
    const ffmpeg = createFFmpeg({ 
        log: true,
        progress: ({ ratio }) => {
            const percent = Math.round(ratio * 100);
            progressBar.style.setProperty('--progress', `${percent}%`);
            progressText.textContent = `Convertendo... ${percent}%`;
        }
    });
    
    // Event Listeners
    selectFileBtn.addEventListener('click', () => fileInput.click());
    
    fileInput.addEventListener('change', (e) => {
        if (e.target.files.length) {
            handleFileSelection(e.target.files[0]);
        }
    });
    
    cancelBtn.addEventListener('click', resetUI);
    
    convertBtn.addEventListener('click', convertToMP3);
    
    downloadBtn.addEventListener('click', downloadMP3);
    
    // Drag and Drop
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, highlight, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, unhighlight, false);
    });
    
    function highlight() {
        dropArea.classList.add('highlight');
    }
    
    function unhighlight() {
        dropArea.classList.remove('highlight');
    }
    
    dropArea.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const file = dt.files[0];
        if (file) {
            handleFileSelection(file);
        }
    });
    
    // Funções principais
    function handleFileSelection(file) {
        // Verificar tipo e tamanho do arquivo
        if (!file.name.endsWith('.mp4')) {
            showError('Por favor, selecione um arquivo MP4 válido.');
            return;
        }
        
        if (file.size > MAX_FILE_SIZE) {
            showError('O arquivo é muito grande. O limite é 100MB.');
            return;
        }
        
        selectedFile = file;
        updateFileInfo(file);
        
        // Mostrar UI de conversão
        convertBtn.classList.remove('hidden');
        fileInfo.classList.remove('hidden');
        dropArea.querySelector('.upload-content').classList.add('hidden');
    }
    
    function updateFileInfo(file) {
        fileName.textContent = file.name;
        fileSize.textContent = formatFileSize(file.size);
    }
    
    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    async function convertToMP3() {
        if (!selectedFile) return;
        
        try {
            // Configurar UI durante a conversão
            convertBtn.disabled = true;
            progressContainer.classList.remove('hidden');
            progressBar.style.setProperty('--progress', '0%');
            progressText.textContent = 'Iniciando conversão...';
            
            // Carregar FFmpeg se necessário
            if (!ffmpeg.isLoaded()) {
                progressText.textContent = 'Carregando FFmpeg...';
                await ffmpeg.load();
            }
            
            // Escrever o arquivo no sistema de arquivos FFmpeg
            ffmpeg.FS('writeFile', 'input.mp4', await fetchFile(selectedFile));
            
            // Executar comando de conversão
            progressText.textContent = 'Convertendo...';
            await ffmpeg.run('-i', 'input.mp4', '-q:a', '0', '-map', 'a', 'output.mp3');
            
            // Ler o resultado
            const data = ffmpeg.FS('readFile', 'output.mp3');
            
            // Criar blob para download
            const blob = new Blob([data.buffer], { type: 'audio/mp3' });
            const url = URL.createObjectURL(blob);
            
            // Configurar botão de download
            downloadBtn.onclick = () => {
                const a = document.createElement('a');
                a.href = url;
                a.download = selectedFile.name.replace('.mp4', '.mp3') || 'audio.mp3';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            };
            
            // Mostrar botão de download
            convertBtn.classList.add('hidden');
            downloadBtn.classList.remove('hidden');
            progressText.textContent = 'Conversão concluída!';
            
        } catch (error) {
            console.error('Erro na conversão:', error);
            showError('Ocorreu um erro durante a conversão. Tente novamente.');
            resetUI();
        }
    }
    
    function downloadMP3() {
        // O download é tratado no evento onclick configurado durante a conversão
    }
    
    function resetUI() {
        selectedFile = null;
        fileInput.value = '';
        fileInfo.classList.add('hidden');
        convertBtn.classList.add('hidden');
        downloadBtn.classList.add('hidden');
        progressContainer.classList.add('hidden');
        dropArea.querySelector('.upload-content').classList.remove('hidden');
        convertBtn.disabled = false;
    }
    
    function showError(message) {
        alert(message); // Em uma versão real, substituir por um toast ou modal bonito
        resetUI();
    }
});