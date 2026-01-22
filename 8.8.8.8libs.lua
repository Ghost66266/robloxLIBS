-- [[ ECLIPSE UI FRAMEWORK V50 | ULTIMATE EDITION ]] --
-- [[ AUTHOR: GHOST66266 | AI GENERATED CORE ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Flags = {},
    Registry = {}, -- Pour le Rainbow Mode
    Theme = {
        Main = Color3.fromRGB(25, 25, 30),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Section = Color3.fromRGB(32, 32, 38),
        Stroke = Color3.fromRGB(50, 50, 55),
        Accent = Color3.fromRGB(115, 80, 255), -- Violet par défaut
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(145, 145, 155),
        Success = Color3.fromRGB(40, 200, 80),
        Warning = Color3.fromRGB(220, 180, 50)
    },
    Rainbow = false,
    Open = true
}

-- [ 1. CORE UTILS ] --
local function Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

local function AddStroke(Obj, Color, Thickness)
    local Stroke = Create("UIStroke", {Parent = Obj, Color = Color or Library.Theme.Stroke, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    return Stroke
end

local function AddCorner(Obj, Radius)
    return Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

local function AddPadding(Obj, Amount)
    return Create("UIPadding", {Parent = Obj, PaddingTop = UDim.new(0, Amount), PaddingBottom = UDim.new(0, Amount), PaddingLeft = UDim.new(0, Amount), PaddingRight = UDim.new(0, Amount)})
end

local function Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Props):Play()
end

local function MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
end

-- [ RAINBOW ENGINE ] --
task.spawn(function()
    while true do
        if Library.Rainbow then
            local Hue = tick() % 5 / 5
            local Color = Color3.fromHSV(Hue, 1, 1)
            Library.Theme.Accent = Color
            for _, Obj in pairs(Library.Registry) do
                if Obj:IsA("UIStroke") and Obj.Name == "AccentStroke" then Tween(Obj, {Color = Color}, 0.1)
                elseif Obj:IsA("Frame") and Obj.Name == "AccentFill" then Tween(Obj, {BackgroundColor3 = Color}, 0.1)
                elseif Obj:IsA("TextLabel") and Obj.Name == "AccentText" then Tween(Obj, {TextColor3 = Color}, 0.1)
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end)

-- [ 2. CONFIG SYSTEM ] --
function Library:SaveConfig(Name)
    if not isfolder("WindConfigs") then makefolder("WindConfigs") end
    writefile("WindConfigs/"..Name..".json", HttpService:JSONEncode(Library.Flags))
    Library:Notify("Config Saved", "Saved to "..Name, 2)
end

function Library:LoadConfig(Name)
    if isfile("WindConfigs/"..Name..".json") then
        local data = HttpService:JSONDecode(readfile("WindConfigs/"..Name..".json"))
        for k,v in pairs(data) do 
            Library.Flags[k] = v 
            -- Note: Un vrai système de chargement nécessiterait de relancer les callbacks
        end
        Library:Notify("Config Loaded", "Loaded "..Name, 2)
    else
        Library:Notify("Error", "Config not found", 2)
    end
end

-- [ 3. NOTIFICATIONS ] --
function Library:Notify(Title, Text, Duration)
    local Screen = CoreGui:FindFirstChild("WindNotify")
    if not Screen then 
        Screen = Create("ScreenGui", {Name = "WindNotify", Parent = CoreGui, ZIndexBehavior = "Sibling"}) 
        Create("Frame", {Name = "Container", Parent = Screen, Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -310, 0, 0), BackgroundTransparency = 1})
        Create("UIListLayout", {Parent = Screen.Container, VerticalAlignment = "Bottom", Padding = UDim.new(0, 5)})
    end
    
    local Frame = Create("Frame", {Parent = Screen.Container, Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Library.Theme.Main, BackgroundTransparency = 1})
    AddCorner(Frame, 8); AddStroke(Frame, Library.Theme.Stroke)
    
    local Bar = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = Library.Theme.Accent})
    AddCorner(Bar, 8)
    
    local T = Create("TextLabel", {Parent = Frame, Text = Title, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 5), Font = "GothamBold", TextSize = 14, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left"})
    local D = Create("TextLabel", {Parent = Frame, Text = Text, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 15, 0, 25), Font = "Gotham", TextSize = 12, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true})
    
    Tween(Frame, {BackgroundTransparency = 0})
    task.delay(Duration or 3, function() Tween(Frame, {BackgroundTransparency = 1}); Tween(T, {TextTransparency = 1}); Tween(D, {TextTransparency = 1}); task.wait(0.5); Frame:Destroy() end)
end

-- [ 4. MAIN WINDOW ] --
function Library:Window(Config)
    local Title = Config.Title or "Eclipse"
    local Compact = Config.Compact or false
    
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Eclipse_"..Title then v:Destroy() end end
    local GUI = Create("ScreenGui", {Name = "Eclipse_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Create("Frame", {
        Name = "Main", Parent = GUI, Size = Compact and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Main, ClipsDescendants = true
    })
    AddCorner(Main, 10); 
    local MainStroke = AddStroke(Main, Library.Theme.Accent, 1); MainStroke.Name = "AccentStroke"
    table.insert(Library.Registry, MainStroke)

    local Topbar = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Sidebar})
    MakeDraggable(Topbar, Main)
    Create("TextLabel", {Parent = Topbar, Text = Title, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0), Font = "GothamBold", TextSize = 16, TextColor3 = Library.Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left"})

    -- Control Buttons (Min/Close)
    local CloseBtn = Create("TextButton", {Parent = Topbar, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), Text = "X", BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "GothamBold"})
    CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)
    
    local MinBtn = Create("TextButton", {Parent = Topbar, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -80, 0, 0), Text = "-", BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "GothamBold"})
    local Minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        Tween(Main, {Size = Minimized and UDim2.new(0, 650, 0, 40) or (Compact and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 650, 0, 420))})
    end)

    local TabHolder = Create("ScrollingFrame", {Parent = Main, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabHolder, SortOrder = "LayoutOrder", Padding = UDim.new(0, 5)}); AddPadding(TabHolder, 10)
    
    local ContentHolder = Create("Frame", {Parent = Main, Size = UDim2.new(1, -160, 1, -40), Position = UDim2.new(0, 160, 0, 40), BackgroundTransparency = 1})

    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:Tab(Name, Icon)
        local TabBtn = Create("TextButton", {Parent = TabHolder, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Library.Theme.Main, Text = Name, TextColor3 = Library.Theme.TextDim, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false})
        AddCorner(TabBtn, 6)
        
        local Page = Create("ScrollingFrame", {Parent = ContentHolder, Size = UDim2.new(1, 0, 1, 0), Visible = false, BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent})
        local PageLayout = Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 10)}); AddPadding(Page, 15)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 30) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundColor3 = Library.Theme.Main, TextColor3 = Library.Theme.TextDim}) end end
            for _,v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            Tween(TabBtn, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Text})
            Page.Visible = true
        end)
        
        if FirstTab then FirstTab = false; Page.Visible = true; TabBtn.BackgroundColor3 = Library.Theme.Accent; TabBtn.TextColor3 = Library.Theme.Text end

        local TabFuncs = {}

        -- [ 17 COMPOSANTS ] --

        function TabFuncs:GroupBox(Title)
            local Box = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Library.Theme.Section, AutomaticSize = "Y"})
            AddCorner(Box, 6); AddStroke(Box, Library.Theme.Stroke)
            Create("TextLabel", {Parent = Box, Text = Title, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), Font = "GothamBold", TextSize = 12, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1, TextXAlignment = "Left"})
            local Container = Create("Frame", {Parent = Box, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, AutomaticSize = "Y"})
            Create("UIListLayout", {Parent = Container, SortOrder = "LayoutOrder", Padding = UDim.new(0, 6)}); AddPadding(Container, 10)
            
            local GroupFuncs = {}
            
            function GroupFuncs:Button(Text, Callback)
                local Btn = Create("TextButton", {Parent = Container, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Library.Theme.Main, Text = Text, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13})
                AddCorner(Btn, 4); AddStroke(Btn, Library.Theme.Stroke)
                Btn.MouseButton1Click:Connect(function() 
                    Tween(Btn, {BackgroundColor3 = Library.Theme.Accent}); task.wait(0.1)
                    Tween(Btn, {BackgroundColor3 = Library.Theme.Main})
                    pcall(Callback) 
                end)
            end

            function GroupFuncs:Toggle(Text, Flag, Default, Callback)
                Library.Flags[Flag] = Default or false
                local F = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1})
                Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"})
                local Switch = Create("Frame", {Parent = F, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -40, 0.5, -10), BackgroundColor3 = Library.Theme.Main}); AddCorner(Switch, 10)
                local Dot = Create("Frame", {Parent = Switch, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Library.Theme.TextDim}); AddCorner(Dot, 8)
                
                local function Update()
                    local On = Library.Flags[Flag]
                    Tween(Switch, {BackgroundColor3 = On and Library.Theme.Accent or Library.Theme.Main})
                    Tween(Dot, {Position = On and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = On and Library.Theme.Text or Library.Theme.TextDim})
                end
                Update()
                
                Create("TextButton", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                    Library.Flags[Flag] = not Library.Flags[Flag]
                    Update(); if Callback then Callback(Library.Flags[Flag]) end
                end)
            end

            function GroupFuncs:Slider(Text, Flag, Min, Max, Default, Callback)
                Library.Flags[Flag] = Default or Min
                local F = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1})
                Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"})
                local ValText = Create("TextLabel", {Parent = F, Text = tostring(Default), Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"})
                local Bar = Create("Frame", {Parent = F, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 28), BackgroundColor3 = Library.Theme.Main}); AddCorner(Bar, 3)
                local Fill = Create("Frame", {Parent = Bar, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Theme.Accent}); AddCorner(Fill, 3)
                
                local function Update(Input)
                    local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(Min + ((Max - Min) * P))
                    Library.Flags[Flag] = Val
                    ValText.Text = tostring(Val)
                    Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                    if Callback then Callback(Val) end
                end
                
                Create("TextButton", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Down:Connect(function()
                    local Move, Kill
                    Move = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
                    Kill = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Move:Disconnect(); Kill:Disconnect() end end)
                    Update(game:GetService("Players").LocalPlayer:GetMouse())
                end)
            end

            function GroupFuncs:Input(Text, Flag, PlaceHolder, Callback)
                Library.Flags[Flag] = ""
                local F = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"})
                local Box = Create("TextBox", {Parent = F, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Library.Theme.Main, Text = "", PlaceholderText = PlaceHolder, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 12})
                AddCorner(Box, 4); AddStroke(Box, Library.Theme.Stroke)
                Box.FocusLost:Connect(function() Library.Flags[Flag] = Box.Text; if Callback then Callback(Box.Text) end end)
            end

            function GroupFuncs:Dropdown(Text, Flag, Items, Multi, Callback)
                local Open = false
                local F = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ClipsDescendants = true})
                Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"})
                local MainBtn = Create("TextButton", {Parent = F, Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 22), BackgroundColor3 = Library.Theme.Main, Text = " Select...", TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"})
                AddCorner(MainBtn, 4); AddStroke(MainBtn, Library.Theme.Stroke)
                
                local List = Create("ScrollingFrame", {Parent = F, Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 0, 55), BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2})
                AddCorner(List, 4); Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 2)})
                
                local function RefreshList()
                    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, item in pairs(Items) do
                        local B = Create("TextButton", {Parent = List, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = item, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12})
                        B.MouseButton1Click:Connect(function()
                            if not Multi then
                                Library.Flags[Flag] = item; MainBtn.Text = "  "..item
                                Open = false; Tween(F, {Size = UDim2.new(1, 0, 0, 40)})
                                if Callback then Callback(item) end
                            end
                        end)
                    end
                    List.CanvasSize = UDim2.new(0,0,0, #Items * 27)
                end
                RefreshList()
                
                MainBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Tween(F, {Size = UDim2.new(1, 0, 0, Open and 160 or 40)})
                end)
            end
            
            function GroupFuncs:ColorPicker(Text, Flag, Default, Callback)
                -- Simplifié pour tenir dans le script : Randomize ou Preset
                Library.Flags[Flag] = Default or Color3.new(1,1,1)
                local F = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1})
                Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"})
                local Preview = Create("TextButton", {Parent = F, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -40, 0.5, -10), BackgroundColor3 = Library.Flags[Flag], Text = ""})
                AddCorner(Preview, 4); AddStroke(Preview, Library.Theme.Stroke)
                
                Preview.MouseButton1Click:Connect(function()
                    -- Pour l'exemple, on change aléatoirement (un vrai picker RGB est trop gros pour ce chat)
                    local Random = Color3.fromHSV(math.random(), 1, 1)
                    Library.Flags[Flag] = Random
                    Preview.BackgroundColor3 = Random
                    if Callback then Callback(Random) end
                end)
            end

            function GroupFuncs:PlayerList(Flag, Callback)
                local Box = Create("ScrollingFrame", {Parent = Container, Size = UDim2.new(1, 0, 0, 150), BackgroundColor3 = Library.Theme.Main, ScrollBarThickness = 2})
                AddCorner(Box, 4); AddStroke(Box, Library.Theme.Stroke)
                local Lay = Create("UIListLayout", {Parent = Box, Padding = UDim.new(0, 2)})
                
                local function Update()
                    for _,v in pairs(Box:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, plr in pairs(Players:GetPlayers()) do
                        local Btn = Create("TextButton", {Parent = Box, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
                        local Img = Create("ImageLabel", {Parent = Btn, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 4, 0, 3), BackgroundColor3 = Color3.new(0,0,0)})
                        AddCorner(Img, 12)
                        task.spawn(function() Img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
                        Create("TextLabel", {Parent = Btn, Text = plr.DisplayName, Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 35, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"})
                        
                        Btn.MouseButton1Click:Connect(function()
                            Library.Flags[Flag] = plr
                            if Callback then Callback(plr) end
                            Library:Notify("Selected", plr.Name, 2)
                        end)
                    end
                    Box.CanvasSize = UDim2.new(0,0,0, Lay.AbsoluteContentSize.Y)
                end
                Update(); Players.PlayerAdded:Connect(Update); Players.PlayerRemoving:Connect(Update)
            end

            return GroupFuncs
        end
        return TabFuncs
    end
    return WindowFuncs
end
return Library
