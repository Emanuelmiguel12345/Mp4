--[[
    💠 ABSOLUTE ZERO MINER v4.0 (Selector Edition)
    "A precisão é a chave. Escolha sua ferramenta, domine o jogo."
    
    [CHANGELOG v4.0]
    > Adicionado Sistema de Seleção de Pá (Dropdown)
    > Correção no algoritmo de busca de ferramentas
    > UI Reajustada para acomodar o menu
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // ⚙️ CONFIGURAÇÃO //
local SETTINGS = {
    TargetTool = "Shovel1",     -- Padrão inicial
    AvailableTools = {"Shovel1", "Shovel2"}, -- Lista de pás
    ClickDelay = 1.5,
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(0, 255, 170), -- Cyber Green
        Text = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(50, 50, 60),
        Dropdown = Color3.fromRGB(25, 25, 30)
    }
}

-- // 📦 ESTADO GLOBAL //
local State = {
    Enabled = false,
    LoopConnection = nil,
    RenderConnection = nil,
    DropdownOpen = false
}

-- // 🎨 UI PROFISSIONAL //
if CoreGui:FindFirstChild("AbsoluteZeroUI") then
    CoreGui.AbsoluteZeroUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AbsoluteZeroUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 260, 0, 190) -- Aumentado para caber o menu
MainFrame.Position = UDim2.new(0.5, -130, 0.4, 0)
MainFrame.BackgroundColor3 = SETTINGS.Theme.Main
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false -- Importante para o Dropdown sair da caixa se precisar
MainFrame.Parent = ScreenGui

-- Estilização Base
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 14)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = SETTINGS.Theme.Stroke
UIStroke.Thickness = 1.6
UIStroke.Transparency = 0.5

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "ABSOLUTE <font color=\"rgb(0,255,170)\">ZERO</font> v4"
Title.RichText = true
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextColor3 = SETTINGS.Theme.Text
Title.Size = UDim2.new(1, 0, 0.25, 0)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- Status Text
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "AGUARDANDO..."
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusLabel.Size = UDim2.new(1, 0, 0, 15)
StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- // 🔽 SISTEMA DE DROPDOWN (SELETOR) //
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Name = "DropdownBtn"
DropdownBtn.Size = UDim2.new(0.85, 0, 0.18, 0)
DropdownBtn.Position = UDim2.new(0.075, 0, 0.35, 0)
DropdownBtn.BackgroundColor3 = SETTINGS.Theme.Dropdown
DropdownBtn.Text = "Ferramenta: " .. SETTINGS.TargetTool
DropdownBtn.Font = Enum.Font.GothamBold
DropdownBtn.TextColor3 = SETTINGS.Theme.Text
DropdownBtn.TextSize = 12
DropdownBtn.AutoButtonColor = true
DropdownBtn.Parent = MainFrame

local DCorner = Instance.new("UICorner", DropdownBtn)
DCorner.CornerRadius = UDim.new(0, 6)
local DStroke = Instance.new("UIStroke", DropdownBtn)
DStroke.Color = SETTINGS.Theme.Stroke
DStroke.Thickness = 1

local DropdownList = Instance.new("Frame")
DropdownList.Name = "List"
DropdownList.Size = UDim2.new(1, 0, 0, 0) -- Começa fechado
DropdownList.Position = UDim2.new(0, 0, 1.1, 0)
DropdownList.BackgroundColor3 = SETTINGS.Theme.Main
DropdownList.BorderSizePixel = 0
DropdownList.Visible = false
DropdownList.ZIndex = 5
DropdownList.Parent = DropdownBtn

local DListCorner = Instance.new("UICorner", DropdownList)
DListCorner.CornerRadius = UDim.new(0, 6)
local DListStroke = Instance.new("UIStroke", DropdownList)
DListStroke.Color = SETTINGS.Theme.Accent
DListStroke.Thickness = 1

local ListLayout = Instance.new("UIListLayout", DropdownList)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 2)

-- Função para criar opções do Dropdown
local function RefreshDropdown()
    for _, child in pairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for i, toolName in ipairs(SETTINGS.AvailableTools) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundColor3 = SETTINGS.Theme.Dropdown
        OptBtn.Text = toolName
        OptBtn.TextColor3 = SETTINGS.Theme.Text
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.TextSize = 12
        OptBtn.ZIndex = 6
        OptBtn.Parent = DropdownList
        
        local OCorner = Instance.new("UICorner", OptBtn)
        OCorner.CornerRadius = UDim.new(0, 4)
        
        OptBtn.MouseButton1Click:Connect(function()
            SETTINGS.TargetTool = toolName
            DropdownBtn.Text = "Ferramenta: " .. toolName
            -- Fecha o menu
            State.DropdownOpen = false
            DropdownList.Visible = false
            TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        end)
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    State.DropdownOpen = not State.DropdownOpen
    if State.DropdownOpen then
        RefreshDropdown()
        DropdownList.Visible = true
        TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 65)}):Play()
    else
        TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.2)
        DropdownList.Visible = false
    end
end)

-- // BOTÃO INICIAR //
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0.25, 0)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.65, 0) -- Ajustado posição
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.Text = "INICIAR SISTEMA"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.TextSize = 14
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner", ToggleBtn)
BtnCorner.CornerRadius = UDim.new(0, 8)

-- // LÓGICA CORE //

local function Notify(msg, color)
    StatusLabel.Text = msg
    StatusLabel.TextColor3 = color or SETTINGS.Theme.Text
end

local function GetShovel()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Busca exata pelo nome selecionado
    local tool = char:FindFirstChild(SETTINGS.TargetTool)
    if tool then return tool end
    
    local bp = LocalPlayer:WaitForChild("Backpack")
    tool = bp:FindFirstChild(SETTINGS.TargetTool)
    if tool then return tool end
    
    return nil
end

local function ClickScreen()
    local vp = workspace.CurrentCamera.ViewportSize
    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 1)
    task.wait() 
    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 1)
end

local function MagnetLogic()
    if not State.Enabled then return end
    
    local tool = GetShovel()
    
    -- 1. Equipar
    if tool and tool.Parent ~= LocalPlayer.Character then
        Notify("Equipando: " .. SETTINGS.TargetTool, SETTINGS.Theme.Text)
        tool.Parent = LocalPlayer.Character
        return
    end

    if not tool then
        Notify("ERRO: " .. SETTINGS.TargetTool .. " não achada!", SETTINGS.Theme.Error)
        return
    end

    -- 2. Busca pela UI de Minigame
    local DigUI = PlayerGui:FindFirstChild("DigUI", true)
    
    -- Fallback: Procura dentro da ferramenta se não achar no PlayerGui
    if not DigUI and tool:FindFirstChild("Handle") then
        local uiInTool = tool.Handle:FindFirstChild("DigUI")
        if uiInTool then DigUI = uiInTool end
    end

    if not DigUI or not DigUI.Parent then
        tool:Activate()
        Notify("Ativando Pá...", SETTINGS.Theme.Text)
        return
    end

    -- 3. Lógica do Magnetismo (Movimento do Frame)
    local Movimento = DigUI:FindFirstChild("Movimento", true)
    local WinFrame = DigUI:FindFirstChild("WinFrame", true)

    if Movimento and WinFrame then
        Notify("MINERANDO...", SETTINGS.Theme.Accent)
        
        -- Cola o WinFrame no Movimento
        WinFrame.Position = Movimento.Position
        
        -- Clica
        ClickScreen()
        
        -- Tenta disparar evento remoto para garantir
        local remote = ReplicatedStorage:FindFirstChild("DigControl") or ReplicatedStorage:FindFirstChild("Dig")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer("click", tool, 0) end)
        end
    else
        Notify("Buscando UI...", SETTINGS.Theme.Text)
    end
end

-- // CONTROLE //

local function StartFarm()
    State.Enabled = true
    
    TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = SETTINGS.Theme.Accent, TextColor3 = Color3.new(0,0,0)}):Play()
    ToggleBtn.Text = "PARAR"
    
    task.spawn(function()
        while State.Enabled do
            MagnetLogic()
            task.wait(SETTINGS.ClickDelay)
        end
    end)
    
    -- Render Loop para visual suave
    State.RenderConnection = RunService.RenderStepped:Connect(function()
        if not State.Enabled then return end
        local DigUI = PlayerGui:FindFirstChild("DigUI", true)
        if DigUI then
            local Movimento = DigUI:FindFirstChild("Movimento", true)
            local WinFrame = DigUI:FindFirstChild("WinFrame", true)
            if Movimento and WinFrame then
                WinFrame.Position = Movimento.Position
            end
        end
    end)
end

local function StopFarm()
    State.Enabled = false
    TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30,30,35), TextColor3 = Color3.fromRGB(200,200,200)}):Play()
    ToggleBtn.Text = "INICIAR SISTEMA"
    Notify("Parado", SETTINGS.Theme.Error)
    
    if State.RenderConnection then
        State.RenderConnection:Disconnect()
        State.RenderConnection = nil
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if State.Enabled then StopFarm() else StartFarm() end
end)
