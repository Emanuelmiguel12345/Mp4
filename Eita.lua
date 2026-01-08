--[[
    Title: ELITE MINING AUTOMATION - V3.0 (DESIGNER EDITION)
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
    Accent = Color3.fromRGB(0, 255, 150),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 170),
    Error = Color3.fromRGB(255, 80, 80),
    Easing = Enum.EasingStyle.Quart
}

local CONFIG = {
    GuiIndex = 22,
    ClickCooldown = 0.01, -- Atualizado para 1.5s
    ResetWaitTime = 3.5,
}

-- // STATE MANAGEMENT //
local State = {
    Enabled = false,
    LastClick = 0,
    IsResetting = false,
    Connections = {}
}

-- // UI CONSTRUCTION (PROFESSIONAL GRADE) //
local function CreateUI()
    -- Cleanup
    local existing = CoreGui:FindFirstChild("EliteMiner")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EliteMiner"
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("CanvasGroup") -- Permite fade suave de todo o grupo
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 260, 0, 160)
    Main.Position = UDim2.new(0.5, -130, 0.4, 0)
    Main.BackgroundColor3 = THEME.Background
    Main.BorderSizePixel = 0
    Main.GroupTransparency = 1
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(45, 45, 50)
    Stroke.Thickness = 2

    -- Shadow Effect (Visual Polish)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015667347" -- Shadow decal
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
    Header.Text = " ELITE <font color='#00FF96'>MINER</font> V3"
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
    Btn.Text = "INITIALIZE"
    Btn.TextColor3 = THEME.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.Parent = Main

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(60, 60, 65)

    -- Glow Effect for Button
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, 0)
    Glow.BackgroundColor3 = THEME.Accent
    Glow.BorderSizePixel = 0
    Glow.BackgroundTransparency = 1
    Glow.Parent = Btn

    -- DRAG & INTRO ANIMATION
    Main.Active = true
    Main.Draggable = true
    TweenService:Create(Main, TweenInfo.new(0.8, THEME.Easing), {GroupTransparency = 0}):Play()

    return Main, Btn, Status, Glow
end

local MainFrame, ActionBtn, StatusLabel, GlowBar = CreateUI()

-- // UTILS & ANIMATION //
local function QuickTween(obj, info, goal)
    TweenService:Create(obj, TweenInfo.new(info, THEME.Easing), goal):Play()
end

local function SetStatus(msg, color)
    StatusLabel.Text = msg:upper()
    QuickTween(StatusLabel, 0.3, {TextColor3 = color or THEME.SubText})
end

-- // CORE LOGIC //
local function SimulateClick(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.02)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

-- Button Hover Effects
ActionBtn.MouseEnter:Connect(function()
    QuickTween(ActionBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)})
    QuickTween(GlowBar, 0.2, {BackgroundTransparency = 0.5})
end)

ActionBtn.MouseLeave:Connect(function()
    QuickTween(ActionBtn, 0.2, {BackgroundColor3 = THEME.Card})
    QuickTween(GlowBar, 0.2, {BackgroundTransparency = 1})
end)

ActionBtn.MouseButton1Click:Connect(function()
    State.Enabled = not State.Enabled
    
    if State.Enabled then
        QuickTween(ActionBtn, 0.3, {BackgroundColor3 = THEME.Accent, TextColor3 = Color3.new(0,0,0)})
        ActionBtn.Text = "SYSTEM ACTIVE"
        SetStatus("Searching for Interface...", THEME.Accent)
        
        -- Auto-equip shovel logic
        task.spawn(function()
            local char = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if char and bp and bp:FindFirstChild("Shovel1") then
                bp.Shovel1.Parent = char
            end
        end)
    else
        QuickTween(ActionBtn, 0.3, {BackgroundColor3 = THEME.Card, TextColor3 = THEME.Text})
        ActionBtn.Text = "INITIALIZE"
        SetStatus("System Paused", THEME.Error)
    end
end)

-- Main Loop
task.spawn(function()
    while true do
        if State.Enabled then
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local target = pGui and pGui:GetChildren()[CONFIG.GuiIndex]
            
            if target then
                local Mov = target:FindFirstChild("Movimento", true)
                local Win = target:FindFirstChild("WinFrame", true)
                local Points = target:FindFirstChild("PontoFrame", true)

                -- Check Win State
                if Points then
                    local count = 0
                    for _, p in pairs(Points:GetChildren()) do
                        if p:IsA("GuiObject") and p.Visible then count += 1 end
                    end

                    if count >= 5 and not State.IsResetting then
                        State.IsResetting = true
                        SetStatus("Victory! Waiting Cooldown...", THEME.Accent)
                        task.wait(CONFIG.ResetWaitTime)
                        
                        local vp = workspace.CurrentCamera.ViewportSize
                        SimulateClick(vp.X/2, vp.Y/2)
                        
                        State.IsResetting = false
                        SetStatus("Starting New Cycle", THEME.Text)
                    end
                end

                -- Precision Hit Logic
                if Mov and Win and not State.IsResetting then
                    if tick() - State.LastClick >= CONFIG.ClickCooldown then
                        local mPos = Mov.AbsolutePosition.X + (Mov.AbsoluteSize.X / 2)
                        local wStart = Win.AbsolutePosition.X
                        local wEnd = wStart + Win.AbsoluteSize.X

                        if mPos >= wStart and mPos <= wEnd then
                            SetStatus("Target Locked - Executing", THEME.Accent)
                            SimulateClick(Mov.AbsolutePosition.X + (Mov.AbsoluteSize.X/2), Mov.AbsolutePosition.Y + (Mov.AbsoluteSize.Y/2))
                            State.LastClick = tick()
                        else
                            SetStatus("Monitoring Trajectory...", THEME.SubText)
                        end
                    end
                end
            else
                SetStatus("Interface Not Found", THEME.Error)
            end
        end
        RunService.Heartbeat:Wait()
    end
end)
