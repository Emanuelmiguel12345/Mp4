--[[
    Title: ELITE MINING AUTOMATION - MULTI-SHOVEL EDITION
    Author: Gemini (AI Technical Partner)
    Version: 4.0 (Inventory Intelligent)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- // CONFIGURAÇÕES //
local CONFIG = {
    GuiIndex = 22,
    ClickCooldown = 1.5,
    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(0, 180, 255),
        Success = Color3.fromRGB(0, 255, 150),
        Panel = Color3.fromRGB(25, 25, 30),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

local State = {
    Running = false,
    LastClickTime = 0,
    SelectedShovel = nil,
    IsResetting = false
}

-- // LIMPEZA //
if CoreGui:FindFirstChild("EliteMinerUI") then CoreGui.EliteMinerUI:Destroy() end

-- // UI PRINCIPAL //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteMinerUI"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
MainFrame.BackgroundColor3 = CONFIG.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "ELITE MINER <font color='#00B4FF'>PRO</font>"
Title.RichText = true
Title.TextColor3 = CONFIG.Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Container de Seleção de Pá (Escondido por padrão)
local ShovelSelection = Instance.new("ScrollingFrame")
ShovelSelection.Name = "Selection"
ShovelSelection.Size = UDim2.new(1, -20, 0, 100)
ShovelSelection.Position = UDim2.new(0, 10, 0, 45)
ShovelSelection.BackgroundTransparency = 1
ShovelSelection.Visible = false
ShovelSelection.CanvasSize = UDim2.new(0, 0, 0, 0)
ShovelSelection.ScrollBarThickness = 2
ShovelSelection.Parent = MainFrame

local UIList = Instance.new("UIListLayout", ShovelSelection)
UIList.Orientation = Enum.Orientation.Horizontal
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Botão principal
local MainBtn = Instance.new("TextButton")
MainBtn.Size = UDim2.new(1, -40, 0, 45)
MainBtn.Position = UDim2.new(0, 20, 0, 100)
MainBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MainBtn.Text = "BUSCAR PÁS..."
MainBtn.Font = Enum.Font.GothamBlack
MainBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MainBtn.TextSize = 14
MainBtn.Parent = MainFrame
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 8)

-- // LÓGICA DE SELEÇÃO DE ITENS //
local function CreateShovelCard(tool)
    local Card = Instance.new("ImageButton")
    Card.Size = UDim2.new(0, 80, 0, 80)
    Card.BackgroundColor3 = CONFIG.Theme.Panel
    Card.Image = "rbxassetid://" .. tool.TextureId:match("%d+") or "0"
    Card.Parent = ShovelSelection
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 20)
    NameLabel.Position = UDim2.new(0, 0, 1, -20)
    NameLabel.BackgroundTransparency = 0.5
    NameLabel.BackgroundColor3 = Color3.new(0,0,0)
    NameLabel.Text = tool.Name
    NameLabel.TextColor3 = Color3.new(1,1,1)
    NameLabel.TextSize = 10
    NameLabel.Font = Enum.Font.GothamMedium
    NameLabel.Parent = Card

    Card.MouseButton1Click:Connect(function()
        State.SelectedShovel = tool.Name
        ShovelSelection.Visible = false
        MainBtn.Visible = true
        MainBtn.Text = "INICIAR: " .. tool.Name:upper()
        MainBtn.BackgroundColor3 = CONFIG.Theme.Accent
    end)
end

local function ScanShovels()
    ShovelSelection.Visible = true
    MainBtn.Visible = false
    -- Limpa lista anterior
    for _, child in pairs(ShovelSelection:GetChildren()) do
        if child:IsA("ImageButton") then child:Destroy() end
    end

    local found = {}
    -- Busca na Backpack e no Personagem
    local locations = {LocalPlayer.Backpack, LocalPlayer.Character}
    for _, loc in pairs(locations) do
        for _, item in pairs(loc:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("shovel") or item.Name:lower():find("pá")) then
                table.insert(found, item)
            end
        end
    end

    if #found == 0 then
        MainBtn.Visible = true
        MainBtn.Text = "NENHUMA PÁ ENCONTRADA"
        ShovelSelection.Visible = false
    else
        for _, tool in pairs(found) do
            CreateShovelCard(tool)
        end
    end
end

-- // LÓGICA DE MINERAÇÃO //
task.spawn(function()
    while true do
        if not State.Running or not State.SelectedShovel then 
            task.wait(0.5) 
            continue 
        end

        local char = LocalPlayer.Character
        local bp = LocalPlayer.Backpack
        
        -- Garante que a pá selecionada está na mão
        local tool = char:FindFirstChild(State.SelectedShovel) or bp:FindFirstChild(State.SelectedShovel)
        if tool and tool.Parent ~= char then
            tool.Parent = char
        end

        local TargetGUI = LocalPlayer.PlayerGui:GetChildren()[CONFIG.GuiIndex]
        if TargetGUI then
            local Movimento = TargetGUI:FindFirstChild("Movimento", true)
            local WinFrame = TargetGUI:FindFirstChild("WinFrame", true)

            if Movimento and WinFrame and tick() - State.LastClickTime >= CONFIG.ClickCooldown then
                local mPos = Movimento.AbsolutePosition.X + (Movimento.AbsoluteSize.X / 2)
                local wPos = WinFrame.AbsolutePosition
                
                if mPos >= wPos.X and mPos <= (wPos.X + WinFrame.AbsoluteSize.X) then
                    VirtualInputManager:SendMouseButtonEvent(mPos, Movimento.AbsolutePosition.Y, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(mPos, Movimento.AbsolutePosition.Y, 0, false, game, 1)
                    State.LastClickTime = tick()
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end)

-- // EVENTOS //
MainBtn.MouseButton1Click:Connect(function()
    if not State.SelectedShovel then
        ScanShovels()
    else
        State.Running = not State.Running
        MainBtn.Text = State.Running and "PARAR AUTOMAÇÃO" or "INICIAR: " .. State.SelectedShovel:upper()
        MainBtn.BackgroundColor3 = State.Running and Color3.fromRGB(200, 50, 50) or CONFIG.Theme.Accent
    end
end)

-- Arrastar UI
local UserInputService = game:GetService("UserInputService")
local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
