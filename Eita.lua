--[[
    Title: ELITE MINING AUTOMATION - V4.0 (SHOVEL SELECTOR EDITION)
    Author: Gemini (Advanced UI/UX Implementation)
    Language: Luau
    Safety Level: High (1.5s Cooldown)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- // DESIGN SYSTEM & CONFIG //
local THEME = {
    Background = Color3.fromRGB(15, 15, 18),
    Card = Color3.fromRGB(25, 25, 30),
    Accent = Color3.fromRGB(0, 255, 150), -- Verde Neon
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 170),
    Error = Color3.fromRGB(255, 80, 80),
    Selection = Color3.fromRGB(255, 170, 0), -- Laranja para seleção
    Easing = Enum.EasingStyle.Quart
}

local CONFIG = {
    GuiIndex = 22,
    ClickCooldown = 1.5,
    ResetWaitTime = 3.5,
}

-- // STATE MANAGEMENT //
local State = {
    Enabled = false,
    LastClick = 0,
    IsResetting = false,
    SelectedTool = nil
}

-- // UI CONSTRUCTION //
local function CreateUI()
    -- Cleanup
    local existing = CoreGui:FindFirstChild("EliteMinerV4")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EliteMinerV4"
    ScreenGui.Parent = CoreGui

    -- MAIN FRAME
    local Main = Instance.new("CanvasGroup")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 280, 0, 170)
    Main.Position = UDim2.new(0.5, -140, 0.4, 0)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Main.GroupTransparency = 1
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(45, 45, 50)
    Stroke.Thickness = 2

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015667347"
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Parent = Main

    -- Header
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = " ELITE <font color='#00FF96'>MINER</font> V4 SELECTOR"
    Header.RichText = true
    Header.TextColor3 = THEME.Text
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 14
    Header.Parent = Main

    -- Status Subtitle
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 40)
    Status.BackgroundTransparency = 1
    Status.Text = "SYSTEM STANDBY"
    Status.TextColor3 = THEME.SubText
    Status.Font = Enum.Font.GothamMedium
    Status.TextSize = 10
    Status.Parent = Main

    -- Interaction Button
    local Btn = Instance.new("TextButton")
    Btn.Name = "Toggle"
    Btn.Size = UDim2.new(1, -40, 0, 45)
    Btn.Position = UDim2.new(0, 20, 1, -65)
    Btn.BackgroundColor3 = THEME.Card
    Btn.Text = "SELECT SHOVEL & START"
    Btn.TextColor3 = THEME.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.Parent = Main
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    -- Selection Frame (Hidden initially)
    local SelectFrame = Instance.new("ScrollingFrame")
    SelectFrame.Name = "Selector"
    SelectFrame.Size = UDim2.new(0, 280, 0, 120) -- Tamanho do menu de pás
    SelectFrame.Position = UDim2.new(0.5, -140, 1, 10) -- Aparece embaixo do Main
    SelectFrame.BackgroundColor3 = THEME.Background
    SelectFrame.BorderSizePixel = 0
    SelectFrame.Visible = false
    SelectFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto ajustar
    SelectFrame.ScrollBarThickness = 4
    SelectFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SelectFrame.Parent = ScreenGui -- Parentado na ScreenGui para não cortar

    Instance.new("UICorner", SelectFrame).CornerRadius = UDim.new(0, 8)
    local SelStroke = Instance.new("UIStroke", SelectFrame)
    SelStroke.Color = THEME.Accent
    SelStroke.Thickness = 1

    local GridLayout = Instance.new("UIGridLayout", SelectFrame)
    GridLayout.CellSize = UDim2.new(0, 60, 0, 60)
    GridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local Padding = Instance.new("UIPadding", SelectFrame)
    Padding.PaddingTop = UDim.new(0,10)
    Padding.PaddingBottom = UDim.new(0,10)

    -- Animation Start
    TweenService:Create(Main, TweenInfo.new(0.8, THEME.Easing), {GroupTransparency = 0}):Play()

    return Main, Btn, Status, SelectFrame
end

local MainFrame, ActionBtn, StatusLabel, SelectFrame = CreateUI()

-- // UTILS //
local function QuickTween(obj, info, goal)
    TweenService:Create(obj, TweenInfo.new(info, THEME.Easing), goal):Play()
end

local function SetStatus(msg, color)
    StatusLabel.Text = msg:upper()
    QuickTween(StatusLabel, 0.3, {TextColor3 = color or THEME.SubText})
end

-- // INVENTORY LOGIC //
local function GetShovels()
    local shovels = {}
    local inventory = {}
    
    -- Gather items from Backpack and Character
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do table.insert(inventory, v) end
    end
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do 
            if v:IsA("Tool") then table.insert(inventory, v) end 
        end
    end

    -- Filter for Shovels
    for _, item in pairs(inventory) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            -- Verifica se tem "shovel", "pá" ou "pa" no nome
            if name:find("shovel") or name:find("pá") or name:find("pa") or name:find("pickaxe") then
                table.insert(shovels, item)
            end
        end
    end
    return shovels
end

-- // CORE LOGIC //
local function StartMining()
    State.Enabled = true
    ActionBtn.Text = "SYSTEM ACTIVE"
    QuickTween(ActionBtn, 0.3, {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.new(0,0,0)})
    SetStatus("Auto-Mining Enabled", THEME.Accent)
    SelectFrame.Visible = false -- Hide selector
end

local function PopulateSelector(shovels)
    -- Clear old buttons
    for _, c in pairs(SelectFrame:GetChildren()) do
        if c:IsA("ImageButton") then c:Destroy() end
    end

    -- Create new buttons for each shovel
    for _, tool in pairs(shovels) do
        local ItemBtn = Instance.new("ImageButton")
        ItemBtn.BackgroundColor3 = THEME.Card
        ItemBtn.Image = tool.TextureId -- Mostra a foto da ferramenta
        if ItemBtn.Image == "" then ItemBtn.Image = "rbxassetid://6034299863" end -- Fallback se nao tiver foto
        ItemBtn.Parent = SelectFrame
        
        Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 6)
        
        -- Name Label
        local NameLbl = Instance.new("TextLabel", ItemBtn)
        NameLbl.Size = UDim2.new(1,0,0,15)
        NameLbl.Position = UDim2.new(0,0,1,-15)
        NameLbl.BackgroundTransparency = 0.5
        NameLbl.BackgroundColor3 = Color3.new(0,0,0)
        NameLbl.TextColor3 = Color3.new(1,1,1)
        NameLbl.TextSize = 8
        NameLbl.Text = tool.Name
        Instance.new("UICorner", NameLbl).CornerRadius = UDim.new(0, 6)

        -- Selection Logic
        ItemBtn.MouseButton1Click:Connect(function()
            -- Equip the tool
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:UnequipTools() end
            tool.Parent = LocalPlayer.Character
            
            State.SelectedTool = tool
            StartMining()
        end)
    end
    
    SelectFrame.Visible = true
    SetStatus("PLEASE SELECT A SHOVEL BELOW", THEME.Selection)
end

-- // BUTTON HANDLER //
ActionBtn.MouseButton1Click:Connect(function()
    if State.Enabled then
        -- Turn OFF
        State.Enabled = false
        ActionBtn.Text = "START MINING"
        QuickTween(ActionBtn, 0.3, {BackgroundColor3 = THEME.Card, TextColor3 = THEME.Text})
        SetStatus("System Paused", THEME.Error)
        SelectFrame.Visible = false
    else
        -- Try to Turn ON
        local shovels = GetShovels()
        
        if #shovels == 0 then
            SetStatus("No Shovel Found!", THEME.Error)
            return
        elseif #shovels == 1 then
            -- Only 1 shovel, auto equip
            local tool = shovels[1]
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:UnequipTools() end
            tool.Parent = LocalPlayer.Character
            StartMining()
        else
            -- Multiple shovels found!
            PopulateSelector(shovels)
        end
    end
end)

-- // CLICK SIMULATION LOOP //
local function SimulateClick(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

task.spawn(function()
    while true do
        if State.Enabled then
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local target = pGui and pGui:GetChildren()[CONFIG.GuiIndex]
            
            if target then
                local Mov = target:FindFirstChild("Movimento", true)
                local Win = target:FindFirstChild("WinFrame", true)
                local Points = target:FindFirstChild("PontoFrame", true)

                -- Win/Reset Logic
                if Points then
                    local count = 0
                    for _, p in pairs(Points:GetChildren()) do
                        if p:IsA("GuiObject") and p.Visible then count += 1 end
                    end

                    if count >= 5 and not State.IsResetting then
                        State.IsResetting = true
                        SetStatus("Victory! Cooldown...", THEME.Accent)
                        task.wait(CONFIG.ResetWaitTime)
                        
                        local vp = workspace.CurrentCamera.ViewportSize
                        SimulateClick(vp.X/2, vp.Y/2)
                        
                        State.IsResetting = false
                        SetStatus("Digging...", THEME.Text)
                    end
                end

                -- Precision Hit Logic
                if Mov and Win and not State.IsResetting then
                    if tick() - State.LastClick >= CONFIG.ClickCooldown then
                        local mPos = Mov.AbsolutePosition.X + (Mov.AbsoluteSize.X / 2)
                        local wStart = Win.AbsolutePosition.X
                        local wEnd = wStart + Win.AbsoluteSize.X

                        -- Se a barra estiver dentro da área verde
                        if mPos >= wStart and mPos <= wEnd then
                            SimulateClick(Mov.AbsolutePosition.X + (Mov.AbsoluteSize.X/2), Mov.AbsolutePosition.Y + (Mov.AbsoluteSize.Y/2))
                            State.LastClick = tick()
                        end
                    end
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end)
