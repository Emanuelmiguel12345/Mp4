local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    GuiIndex = 22,
    ClickCooldown = 1.6, 
    ResetWaitTime = 3,
    Colors = {
        Background = Color3.fromRGB(20, 20, 25),
        Surface    = Color3.fromRGB(30, 30, 35),
        Primary    = Color3.fromRGB(0, 255, 170),
        Secondary  = Color3.fromRGB(100, 100, 255),
        Off        = Color3.fromRGB(60, 60, 65),
        Text       = Color3.fromRGB(240, 240, 240),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Error      = Color3.fromRGB(255, 80, 80)
    }
}

local State = {
    Running = false,
    LastClickTime = 0,
    IsResetting = false
}

for _, old in pairs(CoreGui:GetChildren()) do
    if old.Name == "ProMinerUltimate" then old:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProMinerUltimate"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 170)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
MainFrame.BackgroundColor3 = CONFIG.Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = CONFIG.Colors.Surface
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "AUTO MINER <b>v2.2</b>"
TitleLabel.RichText = true
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = CONFIG.Colors.Text
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -30, 0, 30)
StatusContainer.Position = UDim2.new(0, 15, 0, 55)
StatusContainer.BackgroundColor3 = CONFIG.Colors.Surface
StatusContainer.Parent = MainFrame
Instance.new("UICorner", StatusContainer).CornerRadius = UDim.new(0, 8)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -10, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Pronto"
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 13
StatusText.TextColor3 = CONFIG.Colors.TextDim
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusContainer

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, -30, 0, 50)
ToggleButton.Position = UDim2.new(0, 15, 0, 100)
ToggleButton.BackgroundColor3 = CONFIG.Colors.Surface
ToggleButton.Text = "DESATIVADO"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.TextColor3 = CONFIG.Colors.Text
ToggleButton.ZIndex = 10
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 12)

local function animateToggle(active)
    local info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local targetColor = active and CONFIG.Colors.Primary or CONFIG.Colors.Surface
    local targetText = active and "ATIVADO" or "DESATIVADO"
    
    TweenService:Create(ToggleButton, info, {BackgroundColor3 = targetColor}):Play()
    ToggleButton.Text = targetText
    ToggleButton.TextColor3 = active and CONFIG.Colors.Background or CONFIG.Colors.Text
end

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    State.Running = not State.Running
    animateToggle(State.Running)
    
    if State.Running then
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if char and backpack and backpack:FindFirstChild("Shovel1") then
            backpack.Shovel1.Parent = char
        end
    end
end)

task.spawn(function()
    while true do
        if not State.Running then task.wait(0.5) continue end

        local children = PlayerGui:GetChildren()
        local TargetGUI = children[CONFIG.GuiIndex]

        if TargetGUI then
            local Movimento = TargetGUI:FindFirstChild("Movimento", true)
            local WinFrame = TargetGUI:FindFirstChild("WinFrame", true)
            local PontoFrame = TargetGUI:FindFirstChild("PontoFrame", true)

            if PontoFrame then
                local visiblePoints = 0
                for _, p in pairs(PontoFrame:GetChildren()) do
                    if p:IsA("GuiObject") and p.Visible then visiblePoints = visiblePoints + 1 end
                end

                if visiblePoints >= 5 and not State.IsResetting then
                    State.IsResetting = true
                    StatusText.Text = "Vitoria! Resetando..."
                    task.wait(CONFIG.ResetWaitTime)
                    local vp = workspace.CurrentCamera.ViewportSize
                    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 1)
                    State.IsResetting = false
                end
            end

            if Movimento and WinFrame and not State.IsResetting then
                if tick() - State.LastClickTime >= CONFIG.ClickCooldown then
                    local mAbs = Movimento.AbsolutePosition
                    local mSize = Movimento.AbsoluteSize
                    local wAbs = WinFrame.AbsolutePosition
                    local wSize = WinFrame.AbsoluteSize
                    local mCenter = mAbs.X + (mSize.X / 2)

                    if mCenter >= wAbs.X and mCenter <= (wAbs.X + wSize.X) then
                        StatusText.Text = "Clicking!"
                        VirtualInputManager:SendMouseButtonEvent(mAbs.X + (mSize.X/2), mAbs.Y + (mSize.Y/2), 0, true, game, 1)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(mAbs.X + (mSize.X/2), mAbs.Y + (mSize.Y/2), 0, false, game, 1)
                        State.LastClickTime = tick()
                    end
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end)
