-- ================= BAN LIST =================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local BannedPlayers = {
    ["davittthu"] = true
}

if BannedPlayers[LocalPlayer.Name] then
    LocalPlayer:Kick("Você está permanentemente banido de usar este script.")
    return
end

-- ================= UI LIBRARY MELHORADA (REDz HUB MOD) =================
-- Esta seção substitui o loadstring do pastebin por uma versão visualmente melhorada
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Configs_HUB = {
    Hub = Color3.fromRGB(20, 20, 25), -- Cor de fundo mais escura/azulada
    Corner = UDim.new(0, 8), -- Bordas mais arredondadas
    Stroke = Color3.fromRGB(60, 60, 80),
    TextColor = Color3.fromRGB(255, 255, 255),
    DarkText = Color3.fromRGB(170, 170, 170),
    Font = Enum.Font.FredokaOne
}

local Buttons_Hub = {
    Size = 30,
    TextSize = 14
}

local function Create(instance, name, parent)
    local new = Instance.new(instance, parent)
    new.Name = name or instance
    return new
end

local function SetConfigs(Element, Props)
    for Property, Value in pairs(Props) do
        Element[Property] = Value
    end
    return Element
end

local function Corner(parent, radius)
    local new = Create("UICorner", "Corner", parent)
    new.CornerRadius = radius or Configs_HUB.Corner
    return new
end

local function Stroke(parent, Colorstk, stkmode)
    local new = Create("UIStroke", "Stroke", parent)
    new.ApplyStrokeMode = stkmode or "Border"
    new.Color = Colorstk or Configs_HUB.Stroke
    new.Thickness = 1
    return new
end

local ScreenGui = Create("ScreenGui", "REDz HUB IMPROVED", CoreGui)

-- Remove UI antiga se existir
local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
    ScreenFind:Destroy()
end

local Menu_Notifi = SetConfigs(Create("Frame", "Notificações", ScreenGui), {
    Size = UDim2.new(0, 300, 1, 0),
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1
})

local ListLayout_Notifi = SetConfigs(Create("UIListLayout", "ListLayout", Menu_Notifi), {
    Padding = UDim.new(0, 10),
    VerticalAlignment = "Bottom",
    HorizontalAlignment = "Right"
})

function MakeNotifi(Configs)
    local Title = Configs.Title or "REDz HUB"
    local text = Configs.Text or "Notificação"
    local time = Configs.Time or 5

    local FrameContainer = SetConfigs(Create("Frame", "Frame", Menu_Notifi), {
        Size = UDim2.new(0, 250, 0, 70),
        BackgroundColor3 = Configs_HUB.Hub,
        BackgroundTransparency = 0.1
    })
    Corner(FrameContainer)
    Stroke(FrameContainer)
    
    -- Gradiente suave na notificação
    local NotifGradient = Create("UIGradient", "Gradient", FrameContainer)
    NotifGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
    }
    NotifGradient.Rotation = 45

    local TextLabel = SetConfigs(Create("TextLabel", "Title", FrameContainer), {
        Size = UDim2.new(1, -30, 0, 25),
        Font = Configs_HUB.Font,
        BackgroundTransparency = 1,
        Text = Title,
        TextSize = 18,
        Position = UDim2.new(0, 10, 0, 5),
        TextXAlignment = "Left",
        TextColor3 = Configs_HUB.TextColor
    })

    local TextDesc = SetConfigs(Create("TextLabel", "Text", FrameContainer), {
        Size = UDim2.new(1, -10, 0, 35),
        Position = UDim2.new(0, 10, 0, 30),
        TextSize = 14,
        TextColor3 = Configs_HUB.DarkText,
        TextXAlignment = "Left",
        Text = text,
        Font = Enum.Font.SourceSansBold,
        BackgroundTransparency = 1,
        TextWrapped = true
    })

    -- Barra de tempo
    local TimeBar = SetConfigs(Create("Frame", "TimeBar", FrameContainer), {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Color3.fromRGB(0, 255, 150),
        BorderSizePixel = 0
    })
    Corner(TimeBar, UDim.new(0, 0))

    -- Animação de Entrada
    FrameContainer.Position = UDim2.new(1, 300, 0, 0)
    TweenService:Create(FrameContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    -- Animação da Barra
    TweenService:Create(TimeBar, TweenInfo.new(time, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(time, function()
        if FrameContainer then
            local tweenOut = TweenService:Create(FrameContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 0, 0)})
            tweenOut:Play()
            tweenOut.Completed:Wait()
            FrameContainer:Destroy()
        end
    end)
end

-- Janela Principal
local Menu = SetConfigs(Create("Frame", "Menu Inicial", ScreenGui), {
    Size = UDim2.new(0, 500, 0, 300),
    BackgroundColor3 = Configs_HUB.Hub,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Active = true,
    Draggable = true,
    ClipsDescendants = true
})
Corner(Menu)
Stroke(Menu, Color3.fromRGB(50,50,70))

-- Gradiente Principal do Menu
local MainGradient = Create("UIGradient", "MainGradient", Menu)
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
MainGradient.Rotation = 45

local TopBar = SetConfigs(Create("Frame", "Top Bar", Menu), {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1
})

local Title = SetConfigs(Create("TextLabel", "Title", TopBar), {
    Text = "REDz HUB",
    BackgroundTransparency = 1,
    TextColor3 = Configs_HUB.TextColor,
    TextSize = 22,
    Position = UDim2.new(0, 20, 0, 0),
    Size = UDim2.new(1, -100, 1, 0),
    Font = Configs_HUB.Font,
    TextXAlignment = "Left"
})

-- Separador
local Separator = SetConfigs(Create("Frame", "Sep", TopBar), {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Configs_HUB.Stroke,
    BorderSizePixel = 0
})

local CloseBTN = SetConfigs(Create("TextButton", "Close", TopBar), {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -40, 0, 0),
    Text = "X",
    TextSize = 20,
    TextColor3 = Color3.fromRGB(255, 100, 100),
    BackgroundTransparency = 1,
    Font = Configs_HUB.Font
})

CloseBTN.MouseButton1Click:Connect(function()
    TweenService:Create(Menu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

local ScrollTab = SetConfigs(Create("ScrollingFrame", "ScrollBar", Menu), {
    Size = UDim2.new(0, 140, 1, -45),
    Position = UDim2.new(0, 0, 0, 45),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    ScrollingDirection = "Y",
    AutomaticCanvasSize = "Y",
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Configs_HUB.Stroke
})

local ListLayout_Tabs = SetConfigs(Create("UIListLayout", "ListLayout", ScrollTab), {
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Center
})
SetConfigs(Create("UIPadding", "Pad", ScrollTab), {
    PaddingTop = UDim.new(0, 10)
})

local Containers = SetConfigs(Create("Frame", "Containers", Menu), {
    Size = UDim2.new(1, -150, 1, -45),
    Position = UDim2.new(0, 150, 0, 45),
    BackgroundTransparency = 1
})

-- Divisória Vertical
local V_Sep = SetConfigs(Create("Frame", "VSep", Menu), {
    Size = UDim2.new(0, 1, 1, -45),
    Position = UDim2.new(0, 145, 0, 45),
    BackgroundColor3 = Configs_HUB.Stroke,
    BorderSizePixel = 0
})

function AddInfo(Configs)
    Title.Text = Configs.Title or "REDz HUB"
end

function NewTab(Configs)
    local TabNameStr = Configs.Name or "Tab"
    
    local TabButton = SetConfigs(Create("TextButton", "TabBtn", ScrollTab), {
        Size = UDim2.new(0, 120, 0, 30),
        BackgroundColor3 = Configs_HUB.Hub,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    Corner(TabButton, UDim.new(0, 6))

    local TabTitle = SetConfigs(Create("TextLabel", "Title", TabButton), {
        Size = UDim2.new(1, 0, 1, 0),
        Text = TabNameStr,
        TextColor3 = Configs_HUB.DarkText,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundTransparency = 1
    })

    local Container = SetConfigs(Create("ScrollingFrame", TabNameStr, Containers), {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 2,
        AutomaticCanvasSize = "Y",
        CanvasSize = UDim2.new(0,0,0,0)
    })
    SetConfigs(Create("UIListLayout", "Layout", Container), { Padding = UDim.new(0, 6), HorizontalAlignment = "Center" })
    SetConfigs(Create("UIPadding", "Pad", Container), { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

    -- Lógica de Seleção de Aba
    TabButton.MouseButton1Click:Connect(function()
        for _, v in pairs(Containers:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        Container.Visible = true

        for _, v in pairs(ScrollTab:GetChildren()) do
            if v:IsA("TextButton") then
                TweenService:Create(v.Title, TweenInfo.new(0.3), {TextColor3 = Configs_HUB.DarkText}):Play()
            end
        end
        TweenService:Create(TabTitle, TweenInfo.new(0.3), {TextColor3 = Configs_HUB.TextColor}):Play()
    end)

    -- Selecionar a primeira aba automaticamente
    if #ScrollTab:GetChildren() == 2 then -- 1 é UIListLayout, 2 é o primeiro botão
        Container.Visible = true
        TabTitle.TextColor3 = Configs_HUB.TextColor
    end

    return Container
end

function AddToggle(parent, Configs)
    local name = Configs.Name or "Toggle"
    local Default = Configs.Default or false
    local Callback = Configs.Callback or function() end
    
    local MainFrame = SetConfigs(Create("Frame", "ToggleFrame", parent), {
        Size = UDim2.new(0.95, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    })
    Corner(MainFrame, UDim.new(0, 6))
    Stroke(MainFrame, Configs_HUB.Stroke)

    local Label = SetConfigs(Create("TextLabel", "Label", MainFrame), {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Configs_HUB.TextColor,
        TextXAlignment = "Left",
        BackgroundTransparency = 1
    })

    local Toggler = SetConfigs(Create("TextButton", "Toggler", MainFrame), {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        Text = ""
    })
    Corner(Toggler, UDim.new(1, 0))

    local Circle = SetConfigs(Create("Frame", "Circle", Toggler), {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    })
    Corner(Circle, UDim.new(1, 0))

    local state = Default
    
    local function Update()
        if state then
            TweenService:Create(Toggler, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, 0)}):Play()
        else
            TweenService:Create(Toggler, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
        end
        Callback(state)
    end
    
    Update() -- Define estado inicial

    Toggler.MouseButton1Click:Connect(function()
        state = not state
        Update()
    end)
    -- Clicar no frame inteiro também ativa
    local InvisibleBtn = Create("TextButton", "Inv", MainFrame)
    InvisibleBtn.Size = UDim2.new(1, -50, 1, 0)
    InvisibleBtn.BackgroundTransparency = 1
    InvisibleBtn.Text = ""
    InvisibleBtn.MouseButton1Click:Connect(function()
        state = not state
        Update()
    end)
end

function AddButton(parent, Configs)
    local name = Configs.Name or "Button"
    local Callback = Configs.Callback or function() end

    local Btn = SetConfigs(Create("TextButton", "Button", parent), {
        Size = UDim2.new(0.95, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        Text = "",
        AutoButtonColor = false
    })
    Corner(Btn, UDim.new(0, 6))
    Stroke(Btn, Configs_HUB.Stroke)

    local Label = SetConfigs(Create("TextLabel", "Label", Btn), {
        Size = UDim2.new(1, 0, 1, 0),
        Text = name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Configs_HUB.TextColor,
        BackgroundTransparency = 1
    })

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        Callback()
    end)
end

function AddDropdown(parent, Configs)
    local name = Configs.Name or "Dropdown"
    local options = Configs.Options or {}
    local default = Configs.Default or options[1]
    local Callback = Configs.Callback or function() end

    local DropFrame = SetConfigs(Create("Frame", "DropFrame", parent), {
        Size = UDim2.new(0.95, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        ClipsDescendants = true
    })
    Corner(DropFrame, UDim.new(0, 6))
    Stroke(DropFrame, Configs_HUB.Stroke)

    local Label = SetConfigs(Create("TextLabel", "Label", DropFrame), {
        Size = UDim2.new(1, -30, 0, 35),
        Position = UDim2.new(0, 10, 0, 0),
        Text = name .. ": " .. tostring(default),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        TextColor3 = Configs_HUB.TextColor,
        TextXAlignment = "Left",
        BackgroundTransparency = 1
    })

    local Arrow = SetConfigs(Create("TextLabel", "Arrow", DropFrame), {
        Size = UDim2.new(0, 30, 0, 35),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        Text = "v",
        TextColor3 = Configs_HUB.DarkText,
        Font = Enum.Font.FredokaOne,
        BackgroundTransparency = 1,
        TextSize = 16
    })

    local OptionList = SetConfigs(Create("ScrollingFrame", "List", DropFrame), {
        Size = UDim2.new(1, -10, 0, 0), -- Altura dinâmica
        Position = UDim2.new(0, 5, 0, 35),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2
    })
    SetConfigs(Create("UIListLayout", "Layout", OptionList), { Padding = UDim.new(0, 2) })

    local open = false
    local contentHeight = math.min(#options * 25, 150)

    local function Toggle()
        open = not open
        if open then
            TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, 35 + contentHeight + 5)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
            OptionList.Size = UDim2.new(1, -10, 0, contentHeight)
            OptionList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
        else
            TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0.95, 0, 0, 35)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
        end
    end

    local Trigger = Create("TextButton", "Trigger", DropFrame)
    Trigger.Size = UDim2.new(1, 0, 0, 35)
    Trigger.BackgroundTransparency = 1
    Trigger.Text = ""
    Trigger.MouseButton1Click:Connect(Toggle)

    for _, opt in ipairs(options) do
        local OptBtn = SetConfigs(Create("TextButton", "Opt", OptionList), {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            Text = tostring(opt),
            TextColor3 = Configs_HUB.DarkText,
            Font = Enum.Font.Gotham,
            TextSize = 13
        })
        Corner(OptBtn, UDim.new(0, 4))
        
        OptBtn.MouseButton1Click:Connect(function()
            Callback(opt)
            Label.Text = name .. ": " .. tostring(opt)
            Toggle()
        end)
    end
    
    Callback(default) -- set init
end

-- ================= SERVICES DO USUÁRIO =================
local DigControl = ReplicatedStorage:WaitForChild("DigControl")

-- ================= VARS =================
local AutoFarm = false
local AutoSell = false
local SelectedShovel = 1
local AutoFarmSpeed = 2
local WalkSpeedValue = 16

local Digging = false
local LastWalkSpeed = 16

-- ================= CONFIGURAÇÃO DA UI DO USUÁRIO =================

AddInfo({
    Title = "EMANUELMIGRBLX : Auto Dig", -- NOME ALTERADO AQUI
    Font = Enum.Font.FredokaOne
})

MakeNotifi({
    Title = "EMANUELMIGRBLX", -- NOME ALTERADO AQUI
    Text = "Script carregado com sucesso! UI Melhorada.",
    Time = 4
})

local Tab = NewTab({Name = "Inicio"})
local ConfigTab = NewTab({Name = "Config"})

-- ================= INICIO =================
AddToggle(Tab, {
    Name = "Auto Farm",
    Default = false,
    Callback = function(v)
        AutoFarm = v
    end
})

AddToggle(Tab, {
    Name = "Auto Sell",
    Default = false,
    Callback = function(v)
        AutoSell = v
    end
})

AddDropdown(Tab, {
    Name = "Selecionar Shovel",
    Options = {"1","2","3","4","5","6"},
    Default = "1",
    Callback = function(v)
        SelectedShovel = tonumber(v)
    end
})

AddDropdown(Tab, {
    Name = "Velocidade Auto Farm (seg)",
    Options = {"1","2","3","4","5","6","7","8","9","10"},
    Default = "2",
    Callback = function(v)
        AutoFarmSpeed = tonumber(v)
    end
})

-- ================= CONFIG =================
AddDropdown(ConfigTab, {
    Name = "Velocidade do Personagem",
    Options = {"16","25","35","50","70","100"},
    Default = "16",
    Callback = function(v)
        WalkSpeedValue = tonumber(v)
    end
})

AddButton(ConfigTab, {
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- ================= FUNÇÕES DO GAME =================
local function equipShovel()
    local char = LocalPlayer.Character
    if not char then return nil end

    local shovelName = "Shovel"..SelectedShovel
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end

    local tool = backpack:FindFirstChild(shovelName) or char:FindFirstChild(shovelName)
    if tool and tool.Parent ~= char then
        tool.Parent = char
    end
    return tool
end

local function dig()
    if Digging then return end
    Digging = true

    local tool = equipShovel()
    if not tool then
        Digging = false
        return
    end

    DigControl:FireServer("start", tool, 0)
    task.wait(1.2)

    for i = 1, 5 do
        if not AutoFarm then break end
        DigControl:FireServer("click", tool)
        task.wait(0.85)
    end

    DigControl:FireServer("finish", tool, 0)
    Digging = false
end

-- ================= LOOP OTIMIZADO =================
task.spawn(function()
    while true do
        if AutoFarm and not Digging then
            dig()
            task.wait(AutoFarmSpeed)
        else
            task.wait(0.4)
        end

        if AutoSell then
            local sell = ReplicatedStorage:FindFirstChild("SellItem")
            if sell then
                sell:FireServer("ALL")
            end
        end

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= WalkSpeedValue then
                hum.WalkSpeed = WalkSpeedValue
                LastWalkSpeed = WalkSpeedValue
            end
        end
    end
end)
