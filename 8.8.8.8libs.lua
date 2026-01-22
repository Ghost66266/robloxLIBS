-- [[ 8.8.8.8 WIND-UI LIBRARY ]] --
-- [[ VERSION: V40 TITANIUM | AUTHOR: GHOST66266 & AI ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Flags = {},
    Registry = {},
    Theme = {},
    Connections = {},
    Unloaded = false
}

-- [ 1. CONFIGURATION & THEMES ] --
Library.Themes = {
    Dark = {
        Main = Color3.fromRGB(20, 20, 25), Sidebar = Color3.fromRGB(15, 15, 20),
        Section = Color3.fromRGB(28, 28, 32), Accent = Color3.fromRGB(120, 90, 255),
        Text = Color3.fromRGB(240, 240, 240), TextDark = Color3.fromRGB(140, 140, 150),
        Outline = Color3.fromRGB(20, 20, 25), Control = Color3.fromRGB(255, 255, 255)
    },
    Light = {
        Main = Color3.fromRGB(240, 240, 245), Sidebar = Color3.fromRGB(225, 225, 230),
        Section = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(20, 20, 20), TextDark = Color3.fromRGB(100, 100, 110),
        Outline = Color3.fromRGB(240, 240, 245), Control = Color3.fromRGB(20, 20, 20)
    },
    Midnight = {
        Main = Color3.fromRGB(10, 10, 15), Sidebar = Color3.fromRGB(5, 5, 10),
        Section = Color3.fromRGB(18, 18, 24), Accent = Color3.fromRGB(255, 50, 100),
        Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(120, 120, 130),
        Outline = Color3.fromRGB(10, 10, 15), Control = Color3.fromRGB(200, 200, 255)
    }
}
Library.Theme = Library.Themes.Dark
Library.RainbowMode = false

-- [ 2. SAVE SYSTEM ] --
function Library:SaveConfig(Name)
    local json = HttpService:JSONEncode(Library.Flags)
    writefile("WindUI_"..Name..".json", json)
    Library:Notify("System", "Configuration saved: "..Name, 3)
end

function Library:LoadConfig(Name)
    if isfile("WindUI_"..Name..".json") then
        local json = readfile("WindUI_"..Name..".json")
        local data = HttpService:JSONDecode(json)
        for flag, value in pairs(data) do
            if Library.Flags[flag] ~= nil then
                -- On appelle le callback associé si possible (Logique simplifiée)
                Library.Flags[flag] = value
            end
        end
        Library:Notify("System", "Configuration loaded: "..Name, 3)
    else
        Library:Notify("Error", "Config not found!", 3)
    end
end

-- [ 3. UTILITAIRES ] --
local function Tween(obj, props, time)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function ProtectGui(Gui)
    if syn and syn.protect_gui then syn.protect_gui(Gui); Gui.Parent = CoreGui
    elseif gethui then Gui.Parent = gethui()
    else Gui.Parent = CoreGui end
end

function Library:Notify(Title, Text, Duration)
    -- Système de Notification Simple
    local Screen = CoreGui:FindFirstChild("WindUI_Notifications")
    if not Screen then
        Screen = Instance.new("ScreenGui"); Screen.Name = "WindUI_Notifications"; ProtectGui(Screen)
        local List = Instance.new("Frame", Screen); List.Size = UDim2.new(0, 300, 1, 0); List.Position = UDim2.new(1, -310, 0, 0); List.BackgroundTransparency = 1
        local LL = Instance.new("UIListLayout", List); LL.VerticalAlignment = Enum.VerticalAlignment.Bottom; LL.Padding = UDim.new(0, 5)
    end
    
    local Frame = Instance.new("Frame", Screen.Frame)
    Frame.Size = UDim2.new(1, 0, 0, 60); Frame.BackgroundColor3 = Library.Theme.Main; Frame.BorderSizePixel = 0
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Frame).Color = Library.Theme.Accent
    
    local T = Instance.new("TextLabel", Frame); T.Text = Title; T.Font = Enum.Font.GothamBold; T.TextColor3 = Library.Theme.Accent; T.Size = UDim2.new(1, -10, 0, 20); T.Position = UDim2.new(0, 10, 0, 5); T.BackgroundTransparency = 1; T.TextXAlignment = Enum.TextXAlignment.Left
    local M = Instance.new("TextLabel", Frame); M.Text = Text; M.Font = Enum.Font.Gotham; M.TextColor3 = Library.Theme.Text; M.Size = UDim2.new(1, -10, 0, 30); M.Position = UDim2.new(0, 10, 0, 25); M.BackgroundTransparency = 1; M.TextXAlignment = Enum.TextXAlignment.Left; M.TextWrapped = true

    Tween(Frame, {BackgroundTransparency = 0.1})
    task.delay(Duration or 3, function() Tween(Frame, {BackgroundTransparency = 1}); Frame:Destroy() end)
end

-- [ 4. FENETRE PRINCIPALE ] --
function Library:CreateWindow(Config)
    local Window = {Elements = {}}
    local Name = Config.Title or "WindUI"
    local Compact = Config.Compact or false
    
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "WindUI_"..Name then v:Destroy() end end
    local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "WindUI_"..Name; ProtectGui(ScreenGui)
    
    local Main = Instance.new("Frame", ScreenGui); Main.Name = "Main"
    Main.Size = Compact and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 650, 0, 450)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Library.Theme.Main; Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Dragging Logic
    local Dragging, DragStart, StartPos
    Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, Compact and 140 or 180, 1, 0); Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    local Title = Instance.new("TextLabel", Sidebar); Title.Text = "<b>"..Name.."</b>"; Title.RichText = true; Title.TextColor3 = Library.Theme.Text; Title.Size = UDim2.new(1, -20, 0, 50); Title.Position = UDim2.new(0, 20, 0, 0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("ScrollingFrame", Sidebar); TabContainer.Size = UDim2.new(1, 0, 1, -60); TabContainer.Position = UDim2.new(0, 0, 0, 60); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
    
    local Content = Instance.new("Frame", Main); Content.Size = UDim2.new(1, -(Compact and 140 or 180), 1, 0); Content.Position = UDim2.new(0, (Compact and 140 or 180), 0, 0); Content.BackgroundTransparency = 1
    local ContentPad = Instance.new("UIPadding", Content); ContentPad.PaddingTop = UDim.new(0, 20); ContentPad.PaddingLeft = UDim.new(0, 20); ContentPad.PaddingRight = UDim.new(0, 20)

    -- [ RAINBOW LOOP ] --
    task.spawn(function()
        while ScreenGui.Parent do
            if Library.RainbowMode then
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 1, 1)
                Library.Theme.Accent = color
                -- Ici il faudrait une fonction Refresh() globale, simplifiée pour l'exemple
                Title.TextColor3 = color
            end
            task.wait(0.05)
        end
    end)

    function Window:AddTab(Name, IconId)
        local Tab = {Active = false}
        local TabBtn = Instance.new("TextButton", TabContainer); TabBtn.Size = UDim2.new(1, 0, 0, 40); TabBtn.BackgroundTransparency = 1; TabBtn.Text = ""
        local TabLabel = Instance.new("TextLabel", TabBtn); TabLabel.Text = Name; TabLabel.TextColor3 = Library.Theme.TextDark; TabLabel.BackgroundTransparency = 1; TabLabel.Size = UDim2.new(1, -30, 1, 0); TabLabel.Position = UDim2.new(0, 20, 0, 0); TabLabel.Font = Enum.Font.GothamMedium; TabLabel.TextSize = 13; TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        if IconId then
             -- Logic Icone
        end
        
        local Page = Instance.new("ScrollingFrame", Content); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = false; Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Library.Theme.Accent
        local PageList = Instance.new("UIListLayout", Page); PageList.Padding = UDim.new(0, 10); PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v.TextLabel, {TextColor3 = Library.Theme.TextDark}) end end
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            Tween(TabLabel, {TextColor3 = Library.Theme.Text}); Page.Visible = true
        end)

        -- [ COMPOSANTS ] --
        function Tab:AddGroupBox(Title)
            local Group = {}
            local Box = Instance.new("Frame", Page); Box.BackgroundColor3 = Library.Theme.Section; Box.Size = UDim2.new(1, 0, 0, 100)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
            
            local BoxTitle = Instance.new("TextLabel", Box); BoxTitle.Text = Title; BoxTitle.Size = UDim2.new(1, -20, 0, 30); BoxTitle.Position = UDim2.new(0, 10, 0, 0); BoxTitle.BackgroundTransparency = 1; BoxTitle.TextColor3 = Library.Theme.TextDark; BoxTitle.Font = Enum.Font.GothamBold; BoxTitle.TextSize = 12; BoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local Container = Instance.new("Frame", Box); Container.Size = UDim2.new(1, -20, 0, 0); Container.Position = UDim2.new(0, 10, 0, 35); Container.BackgroundTransparency = 1
            local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, 5); List.SortOrder = Enum.SortOrder.LayoutOrder
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y)
                Box.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 45)
            end)

            function Group:AddButton(Text, Callback)
                local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 32); Btn.BackgroundColor3 = Library.Theme.Main; Btn.Text = Text; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Btn.MouseButton1Click:Connect(Callback)
                return Btn
            end

            function Group:AddToggle(Text, Flag, Default, Callback)
                Library.Flags[Flag] = Default or false
                local TglBtn = Instance.new("TextButton", Container); TglBtn.Size = UDim2.new(1, 0, 0, 32); TglBtn.BackgroundTransparency = 1; TglBtn.Text = ""
                local Label = Instance.new("TextLabel", TglBtn); Label.Text = Text; Label.Size = UDim2.new(1, -50, 1, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.Text; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
                local Check = Instance.new("Frame", TglBtn); Check.Size = UDim2.new(0, 20, 0, 20); Check.Position = UDim2.new(1, -25, 0.5, -10); Check.BackgroundColor3 = Library.Theme.Main; Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 4)
                local Fill = Instance.new("Frame", Check); Fill.Size = UDim2.new(1, -4, 1, -4); Fill.Position = UDim2.new(0, 2, 0, 2); Fill.BackgroundColor3 = Library.Theme.Accent; Fill.BackgroundTransparency = Library.Flags[Flag] and 0 or 1; Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

                TglBtn.MouseButton1Click:Connect(function()
                    Library.Flags[Flag] = not Library.Flags[Flag]
                    Tween(Fill, {BackgroundTransparency = Library.Flags[Flag] and 0 or 1})
                    if Callback then Callback(Library.Flags[Flag]) end
                end)
            end

            function Group:AddColorPicker(Text, Flag, Default, Callback)
                Library.Flags[Flag] = Default or Color3.fromRGB(255, 255, 255)
                local Frame = Instance.new("Frame", Container); Frame.Size = UDim2.new(1, 0, 0, 32); Frame.BackgroundTransparency = 1
                local Label = Instance.new("TextLabel", Frame); Label.Text = Text; Label.Size = UDim2.new(1, -50, 1, 0); Label.BackgroundTransparency = 1; Label.TextColor3 = Library.Theme.Text; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
                local Preview = Instance.new("TextButton", Frame); Preview.Size = UDim2.new(0, 40, 0, 20); Preview.Position = UDim2.new(1, -45, 0.5, -10); Preview.BackgroundColor3 = Library.Flags[Flag]; Preview.Text = ""
                Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
                
                -- Simple Color Randomizer for demo (Real picker is huge code)
                Preview.MouseButton1Click:Connect(function()
                    local RandomCol = Color3.fromHSV(math.random(), 1, 1)
                    Library.Flags[Flag] = RandomCol
                    Preview.BackgroundColor3 = RandomCol
                    if Callback then Callback(RandomCol) end
                end)
            end

            function Group:AddPlayerList(Flag, Callback)
                local PList = Instance.new("ScrollingFrame", Container); PList.Size = UDim2.new(1, 0, 0, 150); PList.BackgroundColor3 = Library.Theme.Main; PList.ScrollBarThickness = 2
                local Layout = Instance.new("UIListLayout", PList); Layout.Padding = UDim.new(0, 2)
                
                local function Update()
                    for _, v in pairs(PList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, p in pairs(Players:GetPlayers()) do
                        local Btn = Instance.new("TextButton", PList); Btn.Size = UDim2.new(1, 0, 0, 25); Btn.BackgroundTransparency = 1; Btn.Text = "  " .. p.DisplayName; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.Gotham; Btn.TextSize = 12; Btn.TextXAlignment = Enum.TextXAlignment.Left
                        Btn.MouseButton1Click:Connect(function()
                            Library.Flags[Flag] = p
                            if Callback then Callback(p) end
                            Library:Notify("Selected", "Player: "..p.Name, 2)
                        end)
                    end
                    PList.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
                end
                Update()
                Players.PlayerAdded:Connect(Update)
                Players.PlayerRemoving:Connect(Update)
            end
            
            -- Inline Layout Helper
            function Group:SetInline(State)
                if State then List.FillDirection = Enum.FillDirection.Horizontal; List.Wraps = true 
                else List.FillDirection = Enum.FillDirection.Vertical end
            end

            return Group
        end

        -- Alias pour compatibilité
        function Tab:AddSection(Title) return Tab:AddGroupBox(Title) end
        
        return Tab
    end
    
    -- [ SETTINGS TAB ] --
    local Settings = Window:AddTab("Settings")
    local ThemeGroup = Settings:AddGroupBox("Themes & Config")
    
    ThemeGroup:AddButton("Save Config", function() Library:SaveConfig("MySettings") end)
    ThemeGroup:AddButton("Load Config", function() Library:LoadConfig("MySettings") end)
    
    ThemeGroup:AddToggle("Rainbow Mode", "Rainbow", false, function(v) 
        Library.RainbowMode = v 
    end)
    
    ThemeGroup:AddToggle("Compact Mode", "Compact", false, function(v)
        Library:Notify("Info", "Restart script to apply size change", 3)
    end)

    return Window
end

return Library
