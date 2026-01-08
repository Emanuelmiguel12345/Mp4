--[[
    Title: PRO MINING AUTOMATION - EXPERT EDITION (UI/UX REDESIGN)
    Author: Gemini (20 Years Exp Emulation)
    Framework: Modern Luau + TweenService V2
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // CONFIGURAÇÕES E ESTILO //
local CONFIG = {
    GuiIndex = 22,
    ClickCooldown = 1.05, -- Otimizado
    ResetWaitTime = 2.8,
    SelectedTool = "Shovel1", -- Padrão
    Colors = {
        Background = Color3.fromRGB(18, 18, 22),
        Panel = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(0, 220, 130), -- Verde Tech
        Inactive = Color3.fromRGB(60, 60, 65),
        TextData = Color3.fromRGB(255, 255, 255),
        TextDesc = Color3.fromRGB(160, 160, 170),
        Error = Color3.fromRGB(255, 80, 80)
    }
}

local State = {
    Running = false,
    LastClickTime = 0,
    IsResetting = false
}

-- // UTILITÁRIOS DE UI //
local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or CONFIG.Colors.Inactive
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function AnimateClick(obj)
    TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset - 2, obj.Size.Y.Scale, obj.Size.Y.Offset - 2)}):Play()
    task.wait(0.1)
    TweenService:Create(obj, TweenInfo.new(0.1), {Size = UDim2.new(obj.Size.X.Scale, obj.Size.X.Offset + 2, obj.Size.Y.Scale, obj.Size.Y.Offset + 2)}):Play()
end

-- // CONSTRUÇÃO DA INTERFACE //
if CoreGui:FindFirstChild("ProMinerExpert") then CoreGui.ProMinerExpert:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProMinerExpert"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- Main Frame (Glassmorphism inspired)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 230) -- Aumentado para caber o seletor
Main.Position = UDim2.new(0.5, -150, 0.4, 0)
Main.BackgroundColor3 = CONFIG.Colors.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
CreateCorner(Main, 14)
CreateStroke(Main, CONFIG.Colors.Inactive, 1.5)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Text = "AUTO MINER <font color=\"rgb(0,220,130)\"><b>v3</b></font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = CONFIG.Colors.TextData
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 40)
Divider.BackgroundColor3 = CONFIG.Colors.Inactive
Divider.BorderSizePixel = 0
Divider.Parent = Main

-- // SELETOR DE PÁ (NOVA FUNCIONALIDADE) //
local ToolLabel = Instance.new("TextLabel")
ToolLabel.Text = "SELECIONE A FERRAMENTA"
ToolLabel.Font = Enum.Font.GothamMedium
ToolLabel.TextSize = 10
ToolLabel.TextColor3 = CONFIG.Colors.TextDesc
ToolLabel.Size = UDim2.new(1, -30, 0, 15)
ToolLabel.Position = UDim2.new(0, 15, 0, 50)
ToolLabel.TextXAlignment = Enum.TextXAlignment.Left
ToolLabel.BackgroundTransparency = 1
ToolLabel.Parent = Main

local ToolContainer = Instance.new("Frame")
ToolContainer.Size = UDim2.new(1, -30, 0, 35)
ToolContainer.Position = UDim2.new(0, 15, 0, 70)
ToolContainer.BackgroundColor3 = CONFIG.Colors.Panel
ToolContainer.Parent = Main
CreateCorner(ToolContainer, 8)

local BtnShovel1 = Instance.new("TextButton")
BtnShovel1.Name = "Shovel1"
BtnShovel1.Size = UDim2.new(0.5, -2, 1, -4)
BtnShovel1.Position = UDim2.new(0, 2, 0, 2)
BtnShovel1.BackgroundColor3 = CONFIG.Colors.Accent -- Começa selecionado
BtnShovel1.Text = "SHOVEL 1"
BtnShovel1.Font = Enum.Font.GothamBold
BtnShovel1.TextSize = 12
BtnShovel1.TextColor3 = CONFIG.Colors.Background
BtnShovel1.Parent = ToolContainer
CreateCorner(BtnShovel1, 6)

local BtnShovel2 = Instance.new("TextButton")
BtnShovel2.Name = "Shovel2"
BtnShovel2.Size = UDim2.new(0.5, -2, 1, -4)
BtnShovel2.Position = UDim2.new(0.5, 0, 0, 2)
BtnShovel2.BackgroundColor3 = Color3.new(0,0,0)
BtnShovel2.BackgroundTransparency = 1
BtnShovel2.Text = "SHOVEL 2"
BtnShovel2.Font = Enum.Font.GothamBold
BtnShovel2.TextSize = 12
BtnShovel2.TextColor3 = CONFIG.Colors.TextDesc
BtnShovel2.Parent = ToolContainer
CreateCorner(BtnShovel2, 6)

-- // FUNÇÃO DE SELEÇÃO VISUAL //
local function UpdateToolSelection(selectedBtn, otherBtn, toolName)
    CONFIG.SelectedTool = toolName
    
    -- Animação do botão selecionado
    TweenService:Create(selectedBtn, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.Colors.Accent, BackgroundTransparency = 0, TextColor3 = CONFIG.Colors.Background}):Play()
    
    -- Animação do botão desmarcado
    TweenService:Create(otherBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, TextColor3 = CONFIG.Colors.TextDesc}):Play()
    
    AnimateClick(selectedBtn)
end

BtnShovel1.MouseButton1Click:Connect(function() UpdateToolSelection(BtnShovel1, BtnShovel2, "Shovel1") end)
BtnShovel2.MouseButton1Click:Connect(function() UpdateToolSelection(BtnShovel2, BtnShovel1, "Shovel2") end)


-- // STATUS E BOTÃO DE START //
local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -30, 0, 30)
StatusContainer.Position = UDim2.new(0, 15, 0, 120)
StatusContainer.BackgroundColor3 = CONFIG.Colors.Panel
StatusContainer.Parent = Main
CreateCorner(StatusContainer, 6)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
StatusDot.BackgroundColor3 = CONFIG.Colors.Inactive
StatusDot.Parent = StatusContainer
CreateCorner(StatusDot, 10)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -30, 1, 0)
StatusText.Position = UDim2.new(0, 25, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Sistema Aguardando..."
StatusText.TextColor3 = CONFIG.Colors.TextDesc
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusContainer

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -30, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0, 165)
ToggleBtn.BackgroundColor3 = CONFIG.Colors.Inactive
ToggleBtn.Text = "DESLIGADO"
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 14
ToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
ToggleBtn.Parent = Main
CreateCorner(ToggleBtn, 8)

-- // LÓGICA DE AUTOMATION //

local function SetStatus(text, type)
    StatusText.Text = text
    local color = CONFIG.Colors.TextDesc
    local dotColor = CONFIG.Colors.Inactive
    
    if type == "Active" then
        color = CONFIG.Colors.Accent
        dotColor = CONFIG.Colors.Accent
    elseif type == "Error" then
        color = CONFIG.Colors.Error
        dotColor = CONFIG.Colors.Error
    end
    
    TweenService:Create(StatusText, TweenInfo.new(0.3), {TextColor3 = color}):Play()
    TweenService:Create(StatusDot, TweenInfo.new(0.3), {BackgroundColor3 = dotColor}):Play()
end

local function EquipSelectedTool()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:WaitForChild("Backpack")
    
    if not char then return end

    -- 1. Verifica se a ferramenta atual já é a correta
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.Name == CONFIG.SelectedTool then
        return -- Já está segurando a certa
    end
    
    -- 2. Se estiver segurando a errada, desequipa
    if currentTool and currentTool.Name ~= CONFIG.SelectedTool then
        currentTool.Parent = backpack
    end
    
    -- 3. Equipa a correta
    local targetTool = backpack:FindFirstChild(CONFIG.SelectedTool)
    if targetTool then
        targetTool.Parent = char
    else
        SetStatus("Ferramenta " .. CONFIG.SelectedTool .. " não encontrada!", "Error")
    end
end

local function Click(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Loop de Mineração
task.spawn(function()
    while true do
        if State.Running then
            -- Garante que a ferramenta certa está equipada CONSTANTEMENTE
            EquipSelectedTool()
            
            local TargetGUI = PlayerGui:GetChildren()[CONFIG.GuiIndex]
            
            if TargetGUI then
                local Movimento = TargetGUI:FindFirstChild("Movimento", true)
                local WinFrame = TargetGUI:FindFirstChild("WinFrame", true)
                local PontoFrame = TargetGUI:FindFirstChild("PontoFrame", true)

                if PontoFrame then
                    local points = 0
                    for _, v in pairs(PontoFrame:GetChildren()) do
                        if v:IsA("GuiObject") and v.Visible then points += 1 end
                    end
                    
                    if points >= 5 and not State.IsResetting then
                        State.IsResetting = true
                        SetStatus("Coletando Recompensas...", "Active")
                        task.wait(CONFIG.ResetWaitTime)
                        
                        -- Reset Click
                        local vp = workspace.CurrentCamera.ViewportSize
                        Click(vp.X/2, vp.Y/2)
                        
                        State.IsResetting = false
                        SetStatus("Reiniciando Ciclo", "Active")
                        task.wait(0.5)
                    end
                end

                if Movimento and WinFrame and not State.IsResetting then
                    if tick() - State.LastClickTime >= CONFIG.ClickCooldown then
                        local mPos = Movimento.AbsolutePosition.X + (Movimento.AbsoluteSize.X / 2)
                        local wStart = WinFrame.AbsolutePosition.X
                        local wEnd = wStart + WinFrame.AbsoluteSize.X
                        
                        if mPos >= wStart and mPos <= wEnd then
                            Click(Movimento.AbsolutePosition.X + (Movimento.AbsoluteSize.X/2), Movimento.AbsolutePosition.Y)
                            State.LastClickTime = tick()
                            SetStatus("ACERTO! AGUARDANDO...", "Active")
                        else
                            SetStatus("Calculando Tempo...", "Active")
                        end
                    end
                end
            else
                SetStatus("GUI do Jogo não detectada!", "Error")
            end
        else
            -- Quando parado
            task.wait(0.5)
        end
        RunService.RenderStepped:Wait()
    end
end)

-- // EVENTO DO BOTÃO PRINCIPAL //
ToggleBtn.MouseButton1Click:Connect(function()
    State.Running = not State.Running
    AnimateClick(ToggleBtn)
    
    if State.Running then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.Colors.Accent, TextColor3 = CONFIG.Colors.Background}):Play()
        ToggleBtn.Text = "ATIVO - FARMANDO"
        SetStatus("Iniciando scripts...", "Active")
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = CONFIG.Colors.Inactive, TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        ToggleBtn.Text = "DESLIGADO"
        SetStatus("Sistema Pausado", "Normal")
    end
end)
