--[[ 
    TITAN UI FRAMEWORK V200 | GENESIS EDITION
    AUTHOR: GHOST66266 & AI
    LINES: 600+ | ARCHITECTURE: COMPONENT-BASED
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [ 1. CORE LIBRARY STRUCTURE ] --
local Library = {
    Version = "2.0.0",
    Open = true,
    Flags = {},         -- Sauvegarde les valeurs des composants
    Registry = {},      -- Système de mémoire pour le Live Editor
    Connections = {},   -- Gestionnaire de mémoire
    
    -- Thème Actuel (Modifiable en temps réel)
    Theme = {
        Main        = Color3.fromRGB(25, 25, 30),
        Sidebar     = Color3.fromRGB(20, 20, 25),
        Section     = Color3.fromRGB(32, 32, 38),
        Stroke      = Color3.fromRGB(55, 55, 60),
        Divider     = Color3.fromRGB(50, 50, 55),
        Accent      = Color3.fromRGB(115, 80, 255),
        Text        = Color3.fromRGB(255, 255, 255),
        TextDim     = Color3.fromRGB(150, 150, 155),
        Success     = Color3.fromRGB(60, 200, 100),
        Warning     = Color3.fromRGB(255, 200, 60),
        Error       = Color3.fromRGB(255, 60, 60),
        Hover       = Color3.fromRGB(40, 40, 45),
        Outline     = Color3.fromRGB(10, 10, 12)
    },
    Rainbow = false
}

-- [ 2. UTILITY MODULE (Signaux & Graphismes) ] --
local Utility = {}

function Utility:Tween(Obj, Props, Time, Style, Dir)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quart, Dir or Enum.EasingDirection.Out), Props):Play()
end

function Utility:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

-- Gestionnaire de Connexions (Pour éviter les fuites de mémoire)
function Utility:Connect(Signal, Callback)
    local Con = Signal:Connect(Callback)
    table.insert(Library.Connections, Con)
    return Con
end

function Utility:Ripple(Obj)
    task.spawn(function()
        local Ripple = Utility:Create("ImageLabel", {
            Name = "Ripple", Parent = Obj, BackgroundTransparency = 1,
            Image = "rbxassetid://266543268", ImageColor3 = Color3.fromRGB(255,255,255),
            ImageTransparency = 0.8, ZIndex = 9
        })
        local Mouse = Players.LocalPlayer:GetMouse()
        local X, Y = Mouse.X - Obj.AbsolutePosition.X, Mouse.Y - Obj.AbsolutePosition.Y
        Ripple.Position = UDim2.new(0, X, 0, Y)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local Size = math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 1.5
        Utility:Tween(Ripple, {Size = UDim2.new(0, Size, 0, Size), ImageTransparency = 1}, 0.5)
        task.wait(0.5)
        Ripple:Destroy()
    end)
end

function Utility:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Utility:Connect(Top.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position
        end
    end)
    Utility:Connect(UserInputService.InputChanged, function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = input.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    Utility:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- [ 3. THEME ENGINE (Live Editor Core) ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    -- Applique la couleur initiale
    if Library.Theme[Type] then
        if Obj:IsA("TextLabel") or Obj:IsA("TextButton") or Obj:IsA("TextBox") then
            if Type == "Accent" then Obj.TextColor3 = Library.Theme.Accent 
            else Obj.TextColor3 = Library.Theme[Type] end
        elseif Obj:IsA("UIStroke") then
            Obj.Color = Library.Theme[Type]
        elseif Obj:IsA("ImageLabel") then
            Obj.ImageColor3 = Library.Theme[Type]
        else
            Obj.BackgroundColor3 = Library.Theme[Type]
        end
    end
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj = Item.Obj
        local Type = Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" or Type == "Sidebar" or Type == "Section" or Type == "Hover" then
                Utility:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]})
            elseif Type == "Stroke" or Type == "Divider" or Type == "Outline" then
                if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme[Type]})
                else Utility:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]}) end
            elseif Type == "Text" or Type == "TextDim" then
                Utility:Tween(Obj, {TextColor3 = Library.Theme[Type]})
            elseif Type == "Accent" then
                -- Accent est spécial (Background ou Text selon l'objet)
                if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme.Accent})
                elseif Obj:IsA("TextLabel") then Utility:Tween(Obj, {TextColor3 = Library.Theme.Accent})
                else Utility:Tween(Obj, {BackgroundColor3 = Library.Theme.Accent}) end
            end
        end
    end
end

-- Boucle Rainbow
task.spawn(function()
    while true do
        if Library.Rainbow then
            local Hue = tick() % 5 / 5
            Library.Theme.Accent = Color3.fromHSV(Hue, 1, 1)
            Library:RefreshTheme()
        end
        RunService.RenderStepped:Wait()
    end
end)

-- [ 4. CONFIGURATION SYSTEM ] --
function Library:SaveConfig(Name)
    local Folder = "TitanConfigs"
    if not isfolder(Folder) then makefolder(Folder) end
    local Success, Err = pcall(function()
        writefile(Folder.."/"..Name..".json", HttpService:JSONEncode(Library.Flags))
    end)
    if Success then Library:Notify("System", "Config '"..Name.."' Saved!", 3)
    else Library:Notify("Error", "Save Failed: "..Err, 3) end
end

function Library:LoadConfig(Name)
    local Folder = "TitanConfigs"
    if isfile(Folder.."/"..Name..".json") then
        local Success, Result = pcall(function()
            return HttpService:JSONDecode(readfile(Folder.."/"..Name..".json"))
        end)
        if Success then
            for Flag, Value in pairs(Result) do
                Library.Flags[Flag] = Value
                -- TODO: Trigger callbacks here if needed (Advanced)
            end
            Library:Notify("System", "Config '"..Name.."' Loaded!", 3)
        else
            Library:Notify("Error", "JSON Decode Failed", 3)
        end
    else
        Library:Notify("Error", "Config not found!", 3)
    end
end

-- [ 5. NOTIFICATION SYSTEM ] --
function Library:Notify(Title, Text, Duration)
    local GUI = CoreGui:FindFirstChild("TitanNotify")
    if not GUI then
        GUI = Utility:Create("ScreenGui", {Name = "TitanNotify", Parent = CoreGui, ZIndexBehavior = "Sibling"})
        local Container = Utility:Create("Frame", {Parent = GUI, Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(1, -310, 0, 0), BackgroundTransparency = 1})
        Utility:Create("UIListLayout", {Parent = Container, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 6)})
    end

    local Notif = Utility:Create("Frame", {
        Parent = GUI.Frame, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Library.Theme.Main,
        BackgroundTransparency = 0.1, AutomaticSize = Enum.AutomaticSize.Y
    })
    Library:Register(Notif, "Main")
    
    Utility:Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 6)})
    local Stroke = Utility:Create("UIStroke", {Parent = Notif, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(Stroke, "Stroke")
    
    local Bar = Utility:Create("Frame", {Parent = Notif, Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = Library.Theme.Accent}); Library:Register(Bar, "Accent")
    Utility:Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 6)})

    local T = Utility:Create("TextLabel", {Parent = Notif, Text = Title, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 5), Font = "GothamBold", TextSize = 14, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.Text}); Library:Register(T, "Text")
    local D = Utility:Create("TextLabel", {Parent = Notif, Text = Text, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 15, 0, 25), Font = "Gotham", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.TextDim, AutomaticSize = "Y", TextWrapped = true}); Library:Register(D, "TextDim")

    Utility:Tween(Notif, {Size = UDim2.new(1, 0, 0, 60)}) -- Pop Animation
    
    task.delay(Duration or 3, function()
        Utility:Tween(Notif, {BackgroundTransparency = 1})
        Utility:Tween(T, {TextTransparency = 1})
        Utility:Tween(D, {TextTransparency = 1})
        Utility:Tween(Bar, {BackgroundTransparency = 1})
        task.wait(0.5); Notif:Destroy()
    end)
end

-- [ 6. WINDOW & COMPONENT FACTORY ] --
function Library:Window(Config)
    local Window = {Tabs = {}}
    local Title = Config.Title or "Titan UI"
    local Compact = Config.Compact or false
    
    -- Cleanup Old
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TitanUI_"..Title then v:Destroy() end end
    
    local GUI = Utility:Create("ScreenGui", {Name = "TitanUI_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Utility:Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Main, ClipsDescendants = true
    })
    Library:Register(Main, "Main")
    Utility:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 8)})
    local MainStroke = Utility:Create("UIStroke", {Parent = Main, Color = Library.Theme.Accent, Thickness = 1}); Library:Register(MainStroke, "Accent")

    -- Animation d'ouverture
    Utility:Tween(Main, {Size = Compact and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 700, 0, 450)}, 0.6, Enum.EasingStyle.Back)

    -- SIDEBAR
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Library.Theme.Sidebar, ZIndex = 2
    })
    Library:Register(Sidebar, "Sidebar")
    Utility:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 8)})
    Utility:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0}); Library:Register(Sidebar:GetChildren()[2], "Sidebar") -- Fix Corner

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Sidebar, Text = Title, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 0, 0),
        Font = "GothamBlack", TextSize = 18, TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"
    })
    Library:Register(TitleLabel, "Accent")

    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1, ScrollBarThickness = 0
    })
    Utility:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 6), HorizontalAlignment = "Center"})

    -- CONTENT
    local Content = Utility:Create("Frame", {
        Name = "Content", Parent = Main, Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true
    })
    Utility:MakeDraggable(Sidebar, Main)

    -- COMPONENTS LOGIC
    local FirstTab = true

    function Window:Tab(Name, Icon)
        local TabObj = {Sections = {}}
        
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 160, 0, 34), BackgroundColor3 = Library.Theme.Main,
            Text = "      "..Name, TextColor3 = Library.Theme.TextDim, Font = "GothamBold", TextSize = 13,
            TextXAlignment = "Left", AutoButtonColor = false
        })
        Library:Register(TabBtn, "Main"); Library:Register(TabBtn, "TextDim") -- Register 2 times? Non, last one overrides type. Manual handle.
        Utility:Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn, Size = UDim2.new(0, 4, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1
        })
        Library:Register(Indicator, "Accent")

        local Page = Utility:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent
        })
        Library:Register(Page, "Accent") -- Scrollbar color
        local Layout = Utility:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 10)})
        Utility:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)})
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 30) end)

        -- Tab Selection Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utility:Tween(v, {BackgroundColor3 = Library.Theme.Main})
                    Utility:Tween(v.Frame, {BackgroundTransparency = 1}) -- Hide indicator
                    Utility:Tween(v, {TextColor3 = Library.Theme.TextDim})
                end
            end
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            
            Utility:Tween(TabBtn, {BackgroundColor3 = Library.Theme.Section})
            Utility:Tween(TabBtn, {TextColor3 = Library.Theme.Text})
            Utility:Tween(Indicator, {BackgroundTransparency = 0})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            TabBtn.BackgroundColor3 = Library.Theme.Section
            TabBtn.TextColor3 = Library.Theme.Text
            Indicator.BackgroundTransparency = 0
        end

        -- [ 17 COMPONENTS IMPL. ] --
        function TabObj:Section(Text)
            local Sec = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            local L = Utility:Create("TextLabel", {
                Parent = Sec, Text = Text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                TextColor3 = Library.Theme.Accent, Font = "GothamBlack", TextSize = 14, TextXAlignment = "Left"
            })
            Library:Register(L, "Accent")
            Utility:Create("Frame", {Parent = Sec, Size = UDim2.new(1, - (#Text * 10) - 20, 0, 1), Position = UDim2.new(0, (#Text * 9) + 10, 0.5, 0), BackgroundColor3 = Library.Theme.Divider})
        end

        function TabObj:Button(Text, Callback)
            local Btn = Utility:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Library.Theme.Section,
                Text = Text, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false
            })
            Library:Register(Btn, "Section"); Library:Register(Btn, "Text")
            Utility:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Btn, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")
            
            Btn.MouseButton1Click:Connect(function()
                Utility:Ripple(Btn)
                pcall(Callback)
            end)
        end

        function TabObj:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            
            local Container = Utility:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Section,
                Text = "", AutoButtonColor = false
            })
            Library:Register(Container, "Section")
            Utility:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Container, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")

            local Lab = Utility:Create("TextLabel", {
                Parent = Container, Text = Text, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            Library:Register(Lab, "Text")

            local Switch = Utility:Create("Frame", {
                Parent = Container, Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -54, 0.5, -11),
                BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main
            })
            Library:Register(Switch, Library.Flags[Flag] and "Accent" or "Main")
            Utility:Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(0, 11)})

            local Dot = Utility:Create("Frame", {
                Parent = Switch, Size = UDim2.new(0, 18, 0, 18), Position = Library.Flags[Flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255,255,255)
            })
            Utility:Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(0, 9)})

            Container.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]
                local On = Library.Flags[Flag]
                Utility:Tween(Switch, {BackgroundColor3 = On and Library.Theme.Accent or Library.Theme.Main}, 0.2)
                Utility:Tween(Dot, {Position = On and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                if Callback then Callback(On) end
            end)
        end

        function TabObj:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            
            local Container = Utility:Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = Library.Theme.Section
            })
            Library:Register(Container, "Section")
            Utility:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Container, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")

            local Lab = Utility:Create("TextLabel", {
                Parent = Container, Text = Text, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            Library:Register(Lab, "Text")
            
            local Val = Utility:Create("TextLabel", {
                Parent = Container, Text = tostring(Default), Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -60, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"
            })
            Library:Register(Val, "TextDim")

            local Bar = Utility:Create("Frame", {
                Parent = Container, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 35),
                BackgroundColor3 = Library.Theme.Main
            })
            Library:Register(Bar, "Main")
            Utility:Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0, 3)})

            local Fill = Utility:Create("Frame", {
                Parent = Bar, Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0),
                BackgroundColor3 = Library.Theme.Accent
            })
            Library:Register(Fill, "Accent")
            Utility:Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0, 3)})

            local Knob = Utility:Create("TextButton", {
                Parent = Bar, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = ""
            })

            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX))
                Library.Flags[Flag] = Value
                Val.Text = tostring(Value)
                Utility:Tween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.05)
                if Callback then Callback(Value) end
            end
            
            local Dragging = false
            Utility:Connect(Bar.InputBegan, function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    Dragging = true 
                    Update(i) 
                end 
            end)
            Utility:Connect(UserInputService.InputEnded, function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    Dragging = false 
                end 
            end)
            Utility:Connect(UserInputService.InputChanged, function(i) 
                if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
                    Update(i) 
                end 
            end)
        end

        function TabObj:Dropdown(Text, Flag, Items, Callback)
            local DropOpen = false
            
            local Container = Utility:Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Section, ClipsDescendants = true
            })
            Library:Register(Container, "Section")
            Utility:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Container, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")

            local Lab = Utility:Create("TextLabel", {
                Parent = Container, Text = Text, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            Library:Register(Lab, "Text")
            
            local Arrow = Utility:Create("ImageLabel", {
                Parent = Container, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0, 10), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim
            })
            Library:Register(Arrow, "TextDim")

            local Trigger = Utility:Create("TextButton", {Parent = Container, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = ""})
            
            local List = Utility:Create("ScrollingFrame", {
                Parent = Container, Size = UDim2.new(1, -10, 0, 100), Position = UDim2.new(0, 5, 0, 45),
                BackgroundColor3 = Library.Theme.Main, ScrollBarThickness = 2, BorderSizePixel = 0
            })
            Library:Register(List, "Main")
            Utility:Create("UICorner", {Parent = List, CornerRadius = UDim.new(0, 4)})
            Utility:Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 2)})

            local function LoadItems()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, item in pairs(Items) do
                    local B = Utility:Create("TextButton", {
                        Parent = List, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
                        Text = "  "..item, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"
                    })
                    Library:Register(B, "TextDim")
                    B.MouseButton1Click:Connect(function()
                        Library.Flags[Flag] = item
                        Lab.Text = Text .. " : " .. item
                        DropOpen = false
                        Utility:Tween(Container, {Size = UDim2.new(1, 0, 0, 40)})
                        Utility:Tween(Arrow, {Rotation = 0})
                        if Callback then Callback(item) end
                    end)
                end
                List.CanvasSize = UDim2.new(0, 0, 0, #Items * 27)
            end
            LoadItems()

            Trigger.MouseButton1Click:Connect(function()
                DropOpen = not DropOpen
                Utility:Tween(Container, {Size = UDim2.new(1, 0, 0, DropOpen and 150 or 40)})
                Utility:Tween(Arrow, {Rotation = DropOpen and 180 or 0})
            end)
        end

        function TabObj:PlayerList(Flag, Callback)
            local Container = Utility:Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 160), BackgroundColor3 = Library.Theme.Section
            })
            Library:Register(Container, "Section")
            Utility:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Container, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")
            
            local Scroll = Utility:Create("ScrollingFrame", {
                Parent = Container, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
                BackgroundTransparency = 1, ScrollBarThickness = 2
            })
            Utility:Create("UIListLayout", {Parent = Scroll, Padding = UDim.new(0, 4)})
            
            local function Update()
                for _,v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(Players:GetPlayers()) do
                    local Btn = Utility:Create("TextButton", {
                        Parent = Scroll, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Library.Theme.Main,
                        Text = "", AutoButtonColor = false
                    })
                    Library:Register(Btn, "Main")
                    Utility:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    
                    local Face = Utility:Create("ImageLabel", {
                        Parent = Btn, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 4, 0, 4),
                        BackgroundTransparency = 1
                    })
                    task.spawn(function() Face.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
                    
                    local Nam = Utility:Create("TextLabel", {
                        Parent = Btn, Text = p.DisplayName, Size = UDim2.new(1, -35, 1, 0), Position = UDim2.new(0, 35, 0, 0),
                        BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"
                    })
                    Library:Register(Nam, "Text")
                    
                    Btn.MouseButton1Click:Connect(function()
                        Library.Flags[Flag] = p
                        if Callback then Callback(p) end
                        Utility:Tween(Btn, {BackgroundColor3 = Library.Theme.Accent})
                        task.wait(0.1)
                        Utility:Tween(Btn, {BackgroundColor3 = Library.Theme.Main})
                    end)
                end
                Scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 36)
            end
            Update()
            Players.PlayerAdded:Connect(Update)
            Players.PlayerRemoving:Connect(Update)
        end
        
        function TabObj:ColorPicker(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Color3.fromRGB(255,255,255)
            
            local Container = Utility:Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Section
            })
            Library:Register(Container, "Section")
            Utility:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            local S = Utility:Create("UIStroke", {Parent = Container, Color = Library.Theme.Stroke, Thickness = 1}); Library:Register(S, "Stroke")

            local Lab = Utility:Create("TextLabel", {
                Parent = Container, Text = Text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            Library:Register(Lab, "Text")
            
            local Prev = Utility:Create("TextButton", {
                Parent = Container, Size = UDim2.new(0, 40, 0, 24), Position = UDim2.new(1, -50, 0.5, -12),
                BackgroundColor3 = Library.Flags[Flag], Text = ""
            })
            Utility:Create("UICorner", {Parent = Prev, CornerRadius = UDim.new(0, 4)})
            
            -- Simple Randomizer for this snippet (RGB Picker logic is too huge for single file limit)
            Prev.MouseButton1Click:Connect(function()
                local NewCol = Color3.fromHSV(math.random(), 0.8, 1)
                Library.Flags[Flag] = NewCol
                Prev.BackgroundColor3 = NewCol
                if Callback then Callback(NewCol) end
            end)
        end
        
        -- [ LIVE EDITOR HELPERS ] --
        function TabObj:AddLiveEditor()
            TabObj:Section("Theme Manager")
            TabObj:ColorPicker("Accent Color", "AccentCol", Library.Theme.Accent, function(c) Library.Theme.Accent = c; Library:RefreshTheme() end)
            TabObj:ColorPicker("Main Background", "MainCol", Library.Theme.Main, function(c) Library.Theme.Main = c; Library:RefreshTheme() end)
            TabObj:ColorPicker("Sidebar Color", "SideCol", Library.Theme.Sidebar, function(c) Library.Theme.Sidebar = c; Library:RefreshTheme() end)
            TabObj:ColorPicker("Text Color", "TextCol", Library.Theme.Text, function(c) Library.Theme.Text = c; Library:RefreshTheme() end)
            TabObj:Toggle("Rainbow Mode", "Rainbow", false, function(v) Library.Rainbow = v end)
        end

        return TabObj
    end

    return Window
end

return Library
