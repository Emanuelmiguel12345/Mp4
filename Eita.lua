--[[
    🛡️ ONYX MINER v6.0 (SAFE GUARD EDITION)
    "Segurança máxima. Mineração precisa."
    
    [CHANGELOG]
    > REMOVIDO: Espadas e Picaretas (Apenas Shovels)
    > ADICIONADO: Sistema Anti-Ban (Cooldown estrito de 1.6s)
    > Lógica de clique humanizada
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // 🎨 CONFIGURAÇÃO & TEMA //
local THEME = {
    Background = Color3.fromRGB(20, 20, 25),
    Header = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(0, 200, 255), -- Azul Seguro
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(150, 150, 160),
    Success = Color3.fromRGB(50, 255, 140),
    Warning = Color3.fromRGB(255, 200, 50),
    Dropdown = Color3.fromRGB(30, 30, 35)
}

local SETTINGS = {
    CurrentTool = "Shovel1", 
    ToolsList = {"Shovel1", "Shovel2"}, -- Apenas pás conforme pedido
    SafetyCooldown = 1.6 -- 1.6s para garantir (margem de erro do servidor)
}

local State = {
    Enabled = false,
    DropdownOpen = false,
    RenderConnection = nil,
    LastClickTime = 0
}

-- // 🛠️ UI CONSTRUCTION //

if CoreGui:FindFirstChild("OnyxSafeUI") then CoreGui.OnyxSafeUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OnyxSafeUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- :: Main Container ::
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015667347"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.4
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- :: Header ::
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = THEME.Header
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "ONYX <font color=\"rgb(0,200,255)\">SAFE</font> v6"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = THEME.Text
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

local HFix = Instance.new("Frame")
HFix.Size = UDim2.new(1, 0, 0, 10)
HFix.Position = UDim2.new(0, 0, 1, -10)
HFix.BackgroundColor3 = THEME.Header
HFix.BorderSizePixel = 0
HFix.Parent = Header

-- Status
local StatusText = Instance.new("TextLabel")
StatusText.Text = "STANDBY"
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 10
StatusText.TextColor3 = THEME.SubText
StatusText.Size = UDim2.new(0, 100, 1, 0)
StatusText.Position = UDim2.new(1, -110, 0, 0)
StatusText.TextXAlignment = Enum.TextXAlignment.Right
StatusText.BackgroundTransparency = 1
StatusText.Parent = Header

-- :: Dropdown ::
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(0.9, 0, 0, 35)
DropdownBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
DropdownBtn.BackgroundColor3 = THEME.Dropdown
DropdownBtn.Text = "Ferramenta: " .. SETTINGS.CurrentTool
DropdownBtn.TextColor3 = THEME.Text
DropdownBtn.Font = Enum.Font.GothamMedium
DropdownBtn.TextSize = 13
DropdownBtn.AutoButtonColor = false
DropdownBtn.Parent = MainFrame

Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 8)
local DStroke = Instance.new("UIStroke", DropdownBtn)
DStroke.Color = Color3.fromRGB(50, 50, 60)
DStroke.Thickness = 1

local DropList = Instance.new("Frame")
DropList.Size = UDim2.new(0.9, 0, 0, 0)
DropList.Position = UDim2.new(0.05, 0, 0.48, 0)
DropList.BackgroundColor3 = THEME.Dropdown
DropList.Visible = false
DropList.ZIndex = 5
DropList.Parent = MainFrame
Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 8)

local ListLayout = Instance.new("UIListLayout", DropList)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- :: Toggle Button ::
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
ToggleBtn.BackgroundColor3 = THEME.Dropdown
ToggleBtn.Text = "INICIAR (SAFE MODE)"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.TextColor3 = THEME.SubText
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- // 🧠 LÓGICA DROPDOWN //
local function UpdateDropdown()
    for _, c in pairs(DropList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, toolName in ipairs(SETTINGS.ToolsList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundTransparency = 1
        btn.Text = toolName
        btn.TextColor3 = THEME.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.ZIndex = 6
        btn.Parent = DropList
        btn.MouseButton1Click:Connect(function()
            SETTINGS.CurrentTool = toolName
            DropdownBtn.Text = "Ferramenta: " .. toolName
            State.DropdownOpen = false
            DropList.Visible = false
            TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 0)}):Play()
        end)
    end
end

DropdownBtn.MouseButton1Click:Connect(function()
    State.DropdownOpen = not State.DropdownOpen
    if State.DropdownOpen then
        UpdateDropdown()
        DropList.Visible = true
        TweenService:Create(DropList, TweenInfo.new(0.3), {Size = UDim2.new(0.9, 0, 0, 60)}):Play() -- Altura ajustada para 2 itens
    else
        TweenService:Create(DropList, TweenInfo.new(0.2), {Size = UDim2.new(0.9, 0, 0, 0)}):Play()
        task.wait(0.2)
        DropList.Visible = false
    end
end)

-- // ⚡ LÓGICA SEGURA //

local function ClickScreen()
    local vp = workspace.CurrentCamera.ViewportSize
    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 1)
    task.wait(0.05) 
    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 1)
end

local function GetTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChild(SETTINGS.CurrentTool)
    if tool then return tool end
    return LocalPlayer:WaitForChild("Backpack"):FindFirstChild(SETTINGS.CurrentTool)
end

local function CoreLogic()
    if not State.Enabled then return end
    
    local tool = GetTool()
    
    -- 1. Equipar
    if tool and tool.Parent ~= LocalPlayer.Character then
        StatusText.Text = "EQUIPANDO..."
        StatusText.TextColor3 = THEME.Warning
        tool.Parent = LocalPlayer.Character
        return
    end
    
    if not tool then 
        StatusText.Text = "NO TOOL"
        StatusText.TextColor3 = Color3.fromRGB(255, 50, 50)
        return 
    end

    -- 2. Detectar UI
    local DigUI = PlayerGui:FindFirstChild("DigUI", true)
    if not DigUI and tool:FindFirstChild("Handle") then
        local uiInTool = tool.Handle:FindFirstChild("DigUI")
        if uiInTool then DigUI = uiInTool end
    end

    if not DigUI or not DigUI.Parent then
        -- Se não tem UI aberta, tenta ativar a ferramenta
        -- Mas respeitando um cooldown básico para não spammar equip
        if tick() - State.LastClickTime >= 0.5 then
             tool:Activate()
             StatusText.Text = "BUSCANDO..."
             StatusText.TextColor3 = THEME.SubText
        end
        return
    end

    -- 3. MINIGAME ATIVO
    local Movimento = DigUI:FindFirstChild("Movimento", true)
    local WinFrame = DigUI:FindFirstChild("WinFrame", true)

    if Movimento and WinFrame then
        -- Magnetismo Visual (Sempre ativo no render, aqui só confirmamos)
        WinFrame.Position = Movimento.Position
        
        -- CHECAGEM DE SEGURANÇA (COOLDOWN)
        local TimeSinceLast = tick() - State.LastClickTime
        
        if TimeSinceLast >= SETTINGS.SafetyCooldown then
            StatusText.Text = "CLICK (SAFE)"
            StatusText.TextColor3 = THEME.Success
            
            ClickScreen()
            
            -- Tenta evento remoto de forma segura
            local remote = ReplicatedStorage:FindFirstChild("DigControl") or ReplicatedStorage:FindFirstChild("Dig")
            if remote and remote:IsA("RemoteEvent") then
                pcall(function() remote:FireServer("click", tool, 0) end)
            end
            
            State.LastClickTime = tick()
        else
            -- Mostra quanto tempo falta (Visual Feedback)
            local remaining = math.ceil((SETTINGS.SafetyCooldown - TimeSinceLast) * 10) / 10
            StatusText.Text = "WAIT: " .. tostring(remaining) .. "s"
            StatusText.TextColor3 = THEME.Warning
        end
    end
end

-- // CONTROLE //
local function SetState(bool)
    State.Enabled = bool
    if bool then
        State.LastClickTime = 0 -- Reseta timer
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.new(0,0,0)}):Play()
        ToggleBtn.Text = "PARAR SISTEMA"
        TweenService:Create(Shadow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageColor3 = THEME.Accent}):Play()
        
        -- Loop Lógico (Roda rápido para checar estado, mas clica devagar)
        task.spawn(function()
            while State.Enabled do
                CoreLogic()
                task.wait(0.1) -- Checagem leve
            end
        end)
        
        -- Loop Visual (Magnetismo fluído sem ban)
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
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = THEME.Dropdown, TextColor3 = THEME.SubText}):Play()
        ToggleBtn.Text = "INICIAR (SAFE MODE)"
        StatusText.Text = "STANDBY"
        StatusText.TextColor3 = THEME.SubText
        TweenService:Create(Shadow, TweenInfo.new(0.5), {ImageColor3 = Color3.new(0,0,0)}):Play()
        
        if State.RenderConnection then
            State.RenderConnection:Disconnect()
            State.RenderConnection = nil
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function() SetState(not State.Enabled) end)
UpdateDropdown()
