--[[ 
    TITAN UI FRAMEWORK V300 | LEVIATHAN EDITION
    ARCH: OBJECT ORIENTED | ENGINE: ACRYLIC & SIGNALS
    AUTHOR: GHOST66266 & AI
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- [ 1. CUSTOM SIGNAL MODULE (PRO EVENT HANDLING) ] --
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({_bindable = Instance.new("BindableEvent")}, Signal) end
function Signal:Connect(callback) return self._bindable.Event:Connect(callback) end
function Signal:Fire(...) self._bindable:Fire(...) end
function Signal:Destroy() self._bindable:Destroy() end

-- [ 2. ACRYLIC BLUR MODULE (WINDOWS 11 STYLE) ] --
local Acrylic = {Blur = nil, Base = nil}
function Acrylic:Enable()
    if self.Blur then return end
    local Part = Instance.new("Part", Workspace)
    Part.Name = "AcrylicBlur"; Part.Transparency = 1; Part.Anchored = true; Part.CanCollide = false
    Part.CastShadow = false; Part.Position = Camera.CFrame.Position
    
    local Depth = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
    Depth.FarIntensity = 0; Depth.FocusDistance = 51.6; Depth.InFocusRadius = 50
    Depth.NearIntensity = 1; Depth.Name = "TitanDepth"
    
    self.Blur = Depth; self.Base = Part
    
    RunService.RenderStepped:Connect(function()
        Part.CFrame = Camera.CFrame * CFrame.new(0, 0, -10)
    end)
end

-- [ 3. LIBRARY CORE ] --
local Library = {
    Version = "3.0.0",
    Flags = {},
    Registry = {},
    Theme = {
        Main = Color3.fromRGB(18, 18, 22),
        Sidebar = Color3.fromRGB(14, 14, 18),
        Section = Color3.fromRGB(24, 24, 28),
        Stroke = Color3.fromRGB(45, 45, 50),
        Divider = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(110, 90, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(140, 140, 140),
        Glow = Color3.fromRGB(110, 90, 255)
    },
    Rainbow = false,
    Open = true
}

-- [ UTILITIES ] --
local Utility = {}

function Utility:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

function Utility:Tween(Obj, Props, Time, Style)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props):Play()
end

function Utility:AddStroke(Obj, Color, Thickness, Transparency)
    local S = Utility:Create("UIStroke", {Parent = Obj, Color = Color or Library.Theme.Stroke, Thickness = Thickness or 1, Transparency = Transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    table.insert(Library.Registry, {Obj = S, Type = "Stroke"})
    return S
end

function Utility:AddCorner(Obj, Radius)
    return Utility:Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

function Utility:Ripple(Obj)
    task.spawn(function()
        local R = Utility:Create("ImageLabel", {Parent = Obj, BackgroundTransparency = 1, Image = "rbxassetid://266543268", ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0.8, ZIndex = 9})
        local Mouse = Players.LocalPlayer:GetMouse()
        local X, Y = Mouse.X - Obj.AbsolutePosition.X, Mouse.Y - Obj.AbsolutePosition.Y
        R.Position = UDim2.new(0, X, 0, Y); R.Size = UDim2.new(0,0,0,0)
        local Size = math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 1.5
        Utility:Tween(R, {Size = UDim2.new(0, Size, 0, Size), ImageTransparency = 1}, 0.5)
        task.wait(0.5); R:Destroy()
    end)
end

function Utility:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ THEME ENGINE ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    -- Apply initial
    if Type == "Main" then Obj.BackgroundColor3 = Library.Theme.Main
    elseif Type == "Sidebar" then Obj.BackgroundColor3 = Library.Theme.Sidebar
    elseif Type == "Section" then Obj.BackgroundColor3 = Library.Theme.Section
    elseif Type == "Accent" then 
        if Obj:IsA("TextLabel") then Obj.TextColor3 = Library.Theme.Accent 
        elseif Obj:IsA("UIStroke") then Obj.Color = Library.Theme.Accent
        else Obj.BackgroundColor3 = Library.Theme.Accent end
    elseif Type == "Text" then Obj.TextColor3 = Library.Theme.Text
    elseif Type == "TextDim" then Obj.TextColor3 = Library.Theme.TextDim
    end
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj, Type = Item.Obj, Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" or Type == "Sidebar" or Type == "Section" then Utility:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]})
            elseif Type == "Stroke" then if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme.Stroke}) end
            elseif Type == "Text" or Type == "TextDim" then Utility:Tween(Obj, {TextColor3 = Library.Theme[Type]})
            elseif Type == "Accent" then 
                if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme.Accent})
                elseif Obj:IsA("TextLabel") then Utility:Tween(Obj, {TextColor3 = Library.Theme.Accent})
                else Utility:Tween(Obj, {BackgroundColor3 = Library.Theme.Accent}) end
            end
        end
    end
end

-- Rainbow Loop
task.spawn(function()
    while true do
        if Library.Rainbow then Library.Theme.Accent = Color3.fromHSV(tick() % 5 / 5, 1, 1); Library:RefreshTheme() end
        RunService.RenderStepped:Wait()
    end
end)

-- [ CONFIG SYSTEM ] --
function Library:SaveConfig(Name)
    if not isfolder("TitanV3") then makefolder("TitanV3") end
    writefile("TitanV3/"..Name..".json", HttpService:JSONEncode(Library.Flags))
    Library:Notify("System", "Configuration Saved", 2)
end
function Library:LoadConfig(Name)
    if isfile("TitanV3/"..Name..".json") then
        local d = HttpService:JSONDecode(readfile("TitanV3/"..Name..".json"))
        for k,v in pairs(d) do Library.Flags[k] = v end
        Library:Notify("System", "Configuration Loaded", 2)
    end
end

-- [ NOTIFICATIONS ] --
function Library:Notify(Title, Text, Duration)
    local GUI = CoreGui:FindFirstChild("TitanNotify") or Utility:Create("ScreenGui", {Name = "TitanNotify", Parent = CoreGui, ZIndexBehavior = "Sibling"})
    local Container = GUI:FindFirstChild("Container") or Utility:Create("Frame", {Name = "Container", Parent = GUI, Size = UDim2.new(0,300,1,0), Position = UDim2.new(1,-310,0,0), BackgroundTransparency = 1})
    if not Container:FindFirstChild("Layout") then Utility:Create("UIListLayout", {Name = "Layout", Parent = Container, VerticalAlignment = "Bottom", Padding = UDim.new(0,6)}) end
    
    local F = Utility:Create("Frame", {Parent = Container, Size = UDim2.new(1,0,0,0), BackgroundColor3 = Library.Theme.Section, AutomaticSize = "Y", BackgroundTransparency = 0.1})
    Library:Register(F, "Section"); Utility:AddCorner(F, 8); Utility:AddStroke(F, nil, 1)
    
    local Line = Utility:Create("Frame", {Parent = F, Size = UDim2.new(0,3,1,-10), Position = UDim2.new(0,4,0,5), BackgroundColor3 = Library.Theme.Accent}); Library:Register(Line, "Accent"); Utility:AddCorner(Line, 4)
    local T = Utility:Create("TextLabel", {Parent = F, Text = Title, Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,15,0,5), Font = "GothamBold", TextSize = 14, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.Text}); Library:Register(T, "Text")
    local M = Utility:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,15,0,25), Font = "Gotham", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true, AutomaticSize = "Y", TextColor3 = Library.Theme.TextDim}); Library:Register(M, "TextDim")
    
    -- Padding bottom
    Utility:Create("Frame", {Parent = F, Size = UDim2.new(1,0,0,5), Position = UDim2.new(0,0,1,0), BackgroundTransparency = 1})

    Utility:Tween(F, {BackgroundTransparency = 0.1})
    task.delay(Duration or 3, function() Utility:Tween(F, {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0)}); task.wait(0.2); F:Destroy() end)
end

-- [ WINDOW CREATION ] --
function Library:Window(Config)
    local Window = {Tabs = {}}
    local Title = Config.Title or "Titan V300"
    local Compact = Config.Compact or false
    
    -- Acrylic Blur Init
    Acrylic:Enable()

    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TitanV3_"..Title then v:Destroy() end end
    local GUI = Utility:Create("ScreenGui", {Name = "TitanV3_"..Title, Parent = CoreGui, IgnoreGuiInset = true})

    local Main = Utility:Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Library.Theme.Main, ClipsDescendants = true,
        BackgroundTransparency = 0.05 -- For Acrylic effect
    })
    Library:Register(Main, "Main"); Utility:AddCorner(Main, 10)
    local Glow = Utility:Create("ImageLabel", {
        Parent = Main, Size = UDim2.new(1, 100, 1, 100), Position = UDim2.new(0, -50, 0, -50),
        Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, ZIndex = -1
    })

    -- Size Animation
    Utility:Tween(Main, {Size = Compact and UDim2.new(0, 500, 0, 350) or UDim2.new(0, 750, 0, 480)}, 0.6, Enum.EasingStyle.Back)

    -- Sidebar (Static)
    local SidebarWidth = 200
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, SidebarWidth, 1, 0),
        BackgroundColor3 = Library.Theme.Sidebar, ZIndex = 2
    })
    Library:Register(Sidebar, "Sidebar"); Utility:AddCorner(Sidebar, 10)
    Utility:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel=0}) -- Square fix

    -- Title
    local Logo = Utility:Create("TextLabel", {
        Parent = Sidebar, Text = Title, Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 20, 0, 0),
        Font = "GothamBlack", TextSize = 22, TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"
    })
    Library:Register(Logo, "Accent")

    -- Tab Container
    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -120), Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1, ScrollBarThickness = 0, ZIndex = 3
    })
    Utility:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    -- User Profile (Bottom Sidebar)
    local Profile = Utility:Create("Frame", {
        Parent = Sidebar, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 1, -60),
        BackgroundColor3 = Library.Theme.Section, ZIndex = 3
    })
    Library:Register(Profile, "Section"); Utility:AddCorner(Profile, 8)
    local PImage = Utility:Create("ImageLabel", {Parent = Profile, Size = UDim2.new(0,34,0,34), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1})
    Utility:AddCorner(PImage, 17)
    task.spawn(function() PImage.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
    Library:Register(Utility:Create("TextLabel", {Parent = Profile, Text = Players.LocalPlayer.DisplayName, Size = UDim2.new(1,-50,0,20), Position = UDim2.new(0,50,0,8), Font = "GothamBold", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.Text}), "Text")
    Library:Register(Utility:Create("TextLabel", {Parent = Profile, Text = "User", Size = UDim2.new(1,-50,0,15), Position = UDim2.new(0,50,0,26), Font = "Gotham", TextSize = 11, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.TextDim}), "TextDim")

    -- Content Area (Physically Offset)
    local Content = Utility:Create("Frame", {
        Parent = Main, Size = UDim2.new(1, -SidebarWidth, 1, 0), Position = UDim2.new(0, SidebarWidth, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1
    })
    
    Utility:MakeDraggable(Sidebar, Main)
    
    -- Exit Button
    local Exit = Utility:Create("TextButton", {Parent = Main, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), Text = "×", Font = "Gotham", TextSize = 24, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1, ZIndex = 10})
    Exit.MouseButton1Click:Connect(function() GUI:Destroy() end)

    local FirstTab = true

    function Window:Tab(Name, Icon)
        local Tab = {}
        
        local Btn = Utility:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 170, 0, 36), BackgroundColor3 = Library.Theme.Main,
            Text = "      "..Name, TextColor3 = Library.Theme.TextDim, Font = "GothamBold", TextSize = 13,
            TextXAlignment = "Left", AutoButtonColor = false, ZIndex = 3
        })
        Library:Register(Btn, "Main"); Library:Register(Btn, "TextDim"); Utility:AddCorner(Btn, 8)
        
        local Marker = Utility:Create("Frame", {Parent = Btn, Size = UDim2.new(0,4,0,16), Position = UDim2.new(0,0,0.5,-8), BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1}); Library:Register(Marker, "Accent")

        local Page = Utility:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, ZIndex = 2
        })
        Library:Register(Page, "Accent")
        local Layout = Utility:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 12)})
        Utility:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,25), PaddingLeft = UDim.new(0,25), PaddingRight = UDim.new(0,25), PaddingBottom = UDim.new(0,25)})
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, Layout.AbsoluteContentSize.Y + 50) end)

        Btn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then
                Utility:Tween(v, {BackgroundColor3 = Library.Theme.Main, TextColor3 = Library.Theme.TextDim})
                Utility:Tween(v:FindFirstChild("Frame"), {BackgroundTransparency = 1})
            end end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            Utility:Tween(Btn, {BackgroundColor3 = Library.Theme.Section, TextColor3 = Library.Theme.Text})
            Utility:Tween(Marker, {BackgroundTransparency = 0})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true; Btn.BackgroundColor3 = Library.Theme.Section; Btn.TextColor3 = Library.Theme.Text; Marker.BackgroundTransparency = 0
        end

        -- [ ADVANCED COMPONENTS ] --
        function Tab:Section(Text)
            local S = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            Library:Register(Utility:Create("TextLabel", {Parent = S, Text = Text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = "GothamBlack", TextSize = 14, TextXAlignment = "Left"}), "Accent")
        end

        function Tab:Button(Text, Callback)
            local B = Utility:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Library.Theme.Section, Text = Text, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false})
            Library:Register(B, "Section"); Library:Register(B, "Text"); Utility:AddCorner(B, 6); Utility:AddStroke(B, nil, 1)
            B.MouseButton1Click:Connect(function() Utility:Ripple(B); pcall(Callback) end)
        end

        function Tab:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local C = Utility:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section, Text = "", AutoButtonColor = false})
            Library:Register(C, "Section"); Utility:AddCorner(C, 6); Utility:AddStroke(C, nil, 1)
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            
            local S = Utility:Create("Frame", {Parent = C, Size = UDim2.new(0,46,0,24), Position = UDim2.new(1,-58,0.5,-12), BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main})
            Library:Register(S, Library.Flags[Flag] and "Accent" or "Main"); Utility:AddCorner(S, 12)
            local D = Utility:Create("Frame", {Parent = S, Size = UDim2.new(0,20,0,20), Position = Library.Flags[Flag] and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), BackgroundColor3 = Color3.new(1,1,1)}); Utility:AddCorner(D, 10)
            
            C.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]; local On = Library.Flags[Flag]
                Utility:Tween(S, {BackgroundColor3 = On and Library.Theme.Accent or Library.Theme.Main})
                Utility:Tween(D, {Position = On and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)})
                if Callback then Callback(On) end
            end)
        end

        function Tab:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,60), BackgroundColor3 = Library.Theme.Section})
            Library:Register(C, "Section"); Utility:AddCorner(C, 6); Utility:AddStroke(C, nil, 1)
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,12,0,8), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local V = Library:Register(Utility:Create("TextLabel", {Parent = C, Text = tostring(Default), Size = UDim2.new(0,50,0,20), Position = UDim2.new(1,-62,0,8), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"}), "TextDim")
            
            local Bar = Utility:Create("Frame", {Parent = C, Size = UDim2.new(1,-24,0,6), Position = UDim2.new(0,12,0,38), BackgroundColor3 = Library.Theme.Main}); Library:Register(Bar, "Main"); Utility:AddCorner(Bar, 3)
            local Fill = Utility:Create("Frame", {Parent = Bar, Size = UDim2.new((Default-Min)/(Max-Min),0,1,0), BackgroundColor3 = Library.Theme.Accent}); Library:Register(Fill, "Accent"); Utility:AddCorner(Fill, 3)
            
            local function Update(Input)
                local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Val = math.floor(Min + ((Max - Min) * P))
                Library.Flags[Flag] = Val; V.Text = tostring(Val)
                Utility:Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                if Callback then Callback(Val) end
            end
            
            local Drag = false
            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Drag = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Drag = false end end)
            UserInputService.InputChanged:Connect(function(i) if Drag and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end

        function Tab:Dropdown(Text, Flag, Items, Callback)
            local Open = false
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section, ClipsDescendants = true, ZIndex = 2})
            Library:Register(C, "Section"); Utility:AddCorner(C, 6); Utility:AddStroke(C, nil, 1)
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-40,0,42), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local Ico = Library:Register(Utility:Create("ImageLabel", {Parent = C, Image = "rbxassetid://6031091004", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-32,0,11), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim}), "TextDim")
            
            local List = Utility:Create("ScrollingFrame", {Parent = C, Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,45), BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2}); Library:Register(List, "Main"); Utility:AddCorner(List, 4)
            Utility:Create("UIListLayout", {Parent = List, Padding = UDim.new(0,2)})
            
            local function Load()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _,i in pairs(Items) do
                    local B = Utility:Create("TextButton", {Parent = List, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Text = "  "..i, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"})
                    Library:Register(B, "TextDim")
                    B.MouseButton1Click:Connect(function()
                        Library.Flags[Flag] = i; Library:Register(C:FindFirstChild("TextLabel"), "Text").Text = Text.." : "..i
                        Open = false; Utility:Tween(C, {Size = UDim2.new(1,0,0,42)}); Utility:Tween(Ico, {Rotation = 0})
                        if Callback then Callback(i) end
                    end)
                end
                List.CanvasSize = UDim2.new(0,0,0,#Items*30); List.Size = UDim2.new(1,-24,0, math.min(#Items*30, 150))
            end
            Load()
            
            Utility:Create("TextButton", {Parent = C, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                Open = not Open
                Utility:Tween(C, {Size = UDim2.new(1,0,0, Open and math.min(#Items*30, 150)+55 or 42)})
                Utility:Tween(Ico, {Rotation = Open and 180 or 0})
            end)
        end

        function Tab:ColorPicker(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Color3.new(1,1,1)
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section}); Library:Register(C, "Section"); Utility:AddCorner(C, 6); Utility:AddStroke(C, nil, 1)
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local P = Utility:Create("TextButton", {Parent = C, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-52,0.5,-10), BackgroundColor3 = Library.Flags[Flag], Text = ""}); Utility:AddCorner(P, 4)
            P.MouseButton1Click:Connect(function() local R = Color3.fromHSV(math.random(),0.8,1); Library.Flags[Flag]=R; P.BackgroundColor3=R; if Callback then Callback(R) end end)
        end
        
        function Tab:AddLiveEditor()
            Tab:Section("Interface Settings")
            Tab:ColorPicker("Accent Color", "Accent", Library.Theme.Accent, function(c) Library.Theme.Accent=c; Library:RefreshTheme() end)
            Tab:ColorPicker("Background", "Main", Library.Theme.Main, function(c) Library.Theme.Main=c; Library:RefreshTheme() end)
            Tab:Toggle("Rainbow Mode", "Rainbow", false, function(v) Library.Rainbow=v end)
            Tab:Button("Force Refresh", function() Library:RefreshTheme() end)
        end

        return Tab
    end
    return Window
end

return Library
