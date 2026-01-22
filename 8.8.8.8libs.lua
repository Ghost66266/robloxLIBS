-- [[ TITAN V600 | OBSIDIAN EDITION ]] --
-- [[ PART 1: CORE ENGINE ]] --

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local Library = {
    Version = "6.0.0",
    Open = true,
    Theme = {
        Main = Color3.fromRGB(15, 15, 20),
        Sidebar = Color3.fromRGB(10, 10, 15),
        Section = Color3.fromRGB(20, 20, 25),
        Stroke = Color3.fromRGB(40, 40, 45),
        Divider = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(0, 140, 255), -- Obsidian Blue
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(130, 130, 130),
    },
    Flags = {},
    Registry = {},
    Rainbow = false
}

-- [ UTILITIES ] --
local Utils = {}

function Utils:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

function Utils:Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Props):Play()
end

function Utils:AddStroke(Obj, Color, Thickness)
    local S = Utils:Create("UIStroke", {Parent = Obj, Color = Color or Library.Theme.Stroke, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    table.insert(Library.Registry, {Obj = S, Type = "Stroke"})
    return S
end

function Utils:AddCorner(Obj, Radius)
    return Utils:Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

function Utils:Ripple(Obj)
    task.spawn(function()
        local R = Utils:Create("ImageLabel", {Parent = Obj, BackgroundTransparency = 1, Image = "rbxassetid://266543268", ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0.8, ZIndex = 9})
        local Mouse = Players.LocalPlayer:GetMouse()
        local X, Y = Mouse.X - Obj.AbsolutePosition.X, Mouse.Y - Obj.AbsolutePosition.Y
        R.Position = UDim2.new(0, X, 0, Y); R.Size = UDim2.new(0,0,0,0)
        local Size = math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 1.5
        Utils:Tween(R, {Size = UDim2.new(0, Size, 0, Size), ImageTransparency = 1}, 0.5)
        task.wait(0.5); R:Destroy()
    end)
end

function Utils:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ ACRYLIC BLUR ] --
function Utils:Acrylic(Frame)
    Frame.BackgroundTransparency = 0.1
    local Blur = Instance.new("BlurEffect", game.Lighting); Blur.Size = 15; Blur.Name = "TitanBlur"
    local Drag = Instance.new("UICorner", Frame); Drag.CornerRadius = UDim.new(0, 10)
end

-- [ THEME ENGINE ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    if Type == "Main" then Obj.BackgroundColor3 = Library.Theme.Main
    elseif Type == "Sidebar" then Obj.BackgroundColor3 = Library.Theme.Sidebar
    elseif Type == "Section" then Obj.BackgroundColor3 = Library.Theme.Section
    elseif Type == "Accent" then 
        if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then Obj.TextColor3 = Library.Theme.Accent 
        elseif Obj:IsA("UIStroke") then Obj.Color = Library.Theme.Accent 
        else Obj.BackgroundColor3 = Library.Theme.Accent end
    elseif Type == "Text" then Obj.TextColor3 = Library.Theme.Text
    end
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj, Type = Item.Obj, Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" or Type == "Sidebar" or Type == "Section" then Utils:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]})
            elseif Type == "Stroke" then if Obj:IsA("UIStroke") then Utils:Tween(Obj, {Color = Library.Theme.Stroke}) end
            elseif Type == "Text" then Utils:Tween(Obj, {TextColor3 = Library.Theme.Text})
            elseif Type == "Accent" then 
                if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then Utils:Tween(Obj, {TextColor3 = Library.Theme.Accent})
                elseif Obj:IsA("UIStroke") then Utils:Tween(Obj, {Color = Library.Theme.Accent})
                else Utils:Tween(Obj, {BackgroundColor3 = Library.Theme.Accent}) end
            end
        end
    end
end

task.spawn(function()
    while true do
        if Library.Rainbow then Library.Theme.Accent = Color3.fromHSV(tick() % 5 / 5, 1, 1); Library:RefreshTheme() end
        RunService.RenderStepped:Wait()
    end
end)

-- [ WINDOW ] --
function Library:Window(Config)
    local Window = {}
    local Title = Config.Name or "Titan V600"
    
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Titan_"..Title then v:Destroy() end end
    local GUI = Utils:Create("ScreenGui", {Name = "Titan_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Utils:Create("Frame", {Parent = GUI, Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Library.Theme.Main, ClipsDescendants = false})
    Library:Register(Main, "Main"); Utils:AddCorner(Main, 10); Utils:AddStroke(Main, Library.Theme.Stroke, 1)
    Utils:Acrylic(Main)
    
    -- Glow Shadow
    Utils:Create("ImageLabel", {Parent = Main, Size = UDim2.new(1,100,1,100), Position = UDim2.new(0,-50,0,-50), Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, ZIndex = -1})

    Utils:Tween(Main, {Size = UDim2.new(0, 750, 0, 500)}, 0.5)

    local Sidebar = Utils:Create("Frame", {Parent = Main, Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = Library.Theme.Sidebar, ZIndex = 2})
    Library:Register(Sidebar, "Sidebar"); Utils:AddCorner(Sidebar, 10)
    Utils:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0})

    local Logo = Utils:Create("TextLabel", {Parent = Sidebar, Text = Title, Size = UDim2.new(1,-20,0,60), Position = UDim2.new(0,20,0,0), Font = "GothamBlack", TextSize = 22, TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"})
    Library:Register(Logo, "Accent")

    local TabHolder = Utils:Create("ScrollingFrame", {Parent = Sidebar, Size = UDim2.new(1,0,1,-70), Position = UDim2.new(0,0,0,70), BackgroundTransparency = 1, ScrollBarThickness = 0, ZIndex = 3})
    Utils:Create("UIListLayout", {Parent = TabHolder, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    local Content = Utils:Create("Frame", {Parent = Main, Size = UDim2.new(1,-200,1,0), Position = UDim2.new(0,200,0,0), BackgroundTransparency = 1, ClipsDescendants = true})
    Utils:MakeDraggable(Sidebar, Main)

    -- Exit
    Utils:Create("TextButton", {Parent = Main, Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-40,0,0), Text = "×", Font = "Gotham", TextSize = 24, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1}).MouseButton1Click:Connect(function() GUI:Destroy() end)
    -- [[ PART 2: TABS & BASICS ]] --

    local FirstTab = true

    function Window:Tab(Name, Icon)
        local Tab = {}
        local Btn = Utils:Create("TextButton", {
            Parent = TabHolder, Size = UDim2.new(0, 170, 0, 38), BackgroundColor3 = Library.Theme.Main,
            Text = "      "..Name, TextColor3 = Library.Theme.TextDim, Font = "GothamBold", TextSize = 13,
            TextXAlignment = "Left", AutoButtonColor = false, ZIndex = 3
        })
        Library:Register(Btn, "Main"); Utils:AddCorner(Btn, 8)
        
        local Marker = Utils:Create("Frame", {Parent = Btn, Size = UDim2.new(0,4,0,18), Position = UDim2.new(0,0,0.5,-9), BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1})
        Library:Register(Marker, "Accent")

        local Page = Utils:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, ZIndex = 2
        })
        Library:Register(Page, "Accent")
        local Layout = Utils:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 10)})
        Utils:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,25), PaddingLeft = UDim.new(0,25), PaddingRight = UDim.new(0,25), PaddingBottom = UDim.new(0,25)})
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+50) end)

        Btn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then
                Utils:Tween(v, {BackgroundColor3 = Library.Theme.Main, TextColor3 = Library.Theme.TextDim})
                Utils:Tween(v:FindFirstChild("Frame"), {BackgroundTransparency = 1})
            end end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            Utils:Tween(Btn, {BackgroundColor3 = Library.Theme.Section, TextColor3 = Library.Theme.Text})
            Utils:Tween(Marker, {BackgroundTransparency = 0})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true; Btn.BackgroundColor3 = Library.Theme.Section; Btn.TextColor3 = Library.Theme.Text; Marker.BackgroundTransparency = 0
        end

        function Tab:Section(Text)
            local F = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            Library:Register(Utils:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = "GothamBlack", TextSize = 14, TextXAlignment = "Left"}), "Accent")
        end

        function Tab:Button(Text, Callback)
            local B = Utils:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section, Text = Text, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false})
            Library:Register(B, "Section"); Library:Register(B, "Text"); Utils:AddCorner(B, 6); Utils:AddStroke(B, nil, 1)
            B.MouseButton1Click:Connect(function() Utils:Ripple(B); pcall(Callback) end)
        end

        function Tab:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local C = Utils:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section, Text = "", AutoButtonColor = false})
            Library:Register(C, "Section"); Utils:AddCorner(C, 6); Utils:AddStroke(C, nil, 1)
            Library:Register(Utils:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            
            local S = Utils:Create("Frame", {Parent = C, Size = UDim2.new(0,46,0,24), Position = UDim2.new(1,-58,0.5,-12), BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main})
            Library:Register(S, Library.Flags[Flag] and "Accent" or "Main"); Utils:AddCorner(S, 12)
            local D = Utils:Create("Frame", {Parent = S, Size = UDim2.new(0,20,0,20), Position = Library.Flags[Flag] and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), BackgroundColor3 = Color3.new(1,1,1)}); Utils:AddCorner(D, 10)
            
            C.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]; local On = Library.Flags[Flag]
                Utils:Tween(S, {BackgroundColor3 = On and Library.Theme.Accent or Library.Theme.Main})
                Utils:Tween(D, {Position = On and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)})
                if Callback then Callback(On) end
            end)
        end
        
        function Tab:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            local C = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,60), BackgroundColor3 = Library.Theme.Section})
            Library:Register(C, "Section"); Utils:AddCorner(C, 6); Utils:AddStroke(C, nil, 1)
            Library:Register(Utils:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-10,0,25), Position = UDim2.new(0,12,0,8), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local V = Library:Register(Utils:Create("TextLabel", {Parent = C, Text = tostring(Default), Size = UDim2.new(0,50,0,25), Position = UDim2.new(1,-62,0,8), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"}), "TextDim")
            local B = Utils:Create("Frame", {Parent = C, Size = UDim2.new(1,-24,0,6), Position = UDim2.new(0,12,0,38), BackgroundColor3 = Library.Theme.Main}); Library:Register(B, "Main"); Utils:AddCorner(B, 3)
            local F = Utils:Create("Frame", {Parent = B, Size = UDim2.new((Default-Min)/(Max-Min),0,1,0), BackgroundColor3 = Library.Theme.Accent}); Library:Register(F, "Accent"); Utils:AddCorner(F, 3)
            
            local function Upd(Input)
                local P = math.clamp((Input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1); local Val = math.floor(Min + ((Max - Min) * P))
                Library.Flags[Flag] = Val; V.Text = tostring(Val); Utils:Tween(F, {Size = UDim2.new(P, 0, 1, 0)}, 0.05); if Callback then Callback(Val) end
            end
            local D = false
            B.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then D=true; Upd(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then D=false end end)
            UserInputService.InputChanged:Connect(function(i) if D and i.UserInputType == Enum.UserInputType.MouseMovement then Upd(i) end end)
        end
        -- [[ PART 3: ADVANCED & LIVE EDITOR ]] --

        function Tab:Dropdown(Text, Flag, Items, Callback)
            local Open = false
            local C = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section, ClipsDescendants = true, ZIndex = 2})
            Library:Register(C, "Section"); Utils:AddCorner(C, 6); Utils:AddStroke(C, nil, 1)
            
            Library:Register(Utils:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-40,0,42), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local Ico = Library:Register(Utils:Create("ImageLabel", {Parent = C, Image = "rbxassetid://6031091004", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-32,0,11), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim}), "TextDim")
            
            local List = Utils:Create("ScrollingFrame", {Parent = C, Size = UDim2.new(1,-24,0,100), Position = UDim2.new(0,12,0,45), BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2}); Library:Register(List, "Main"); Utils:AddCorner(List, 4)
            Utils:Create("UIListLayout", {Parent = List, Padding = UDim.new(0,2)})
            
            local function Load()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _,i in pairs(Items) do
                    local B = Utils:Create("TextButton", {Parent = List, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Text = "  "..i, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"})
                    Library:Register(B, "TextDim")
                    B.MouseButton1Click:Connect(function()
                        Library.Flags[Flag] = i; Library:Register(C:FindFirstChild("TextLabel"), "Text").Text = Text.." : "..i
                        Open = false; Utils:Tween(C, {Size = UDim2.new(1,0,0,42)}); Utils:Tween(Ico, {Rotation = 0})
                        if Callback then Callback(i) end
                    end)
                end
                List.CanvasSize = UDim2.new(0,0,0,#Items*30); List.Size = UDim2.new(1,-24,0, math.min(#Items*30, 150))
            end
            Load()
            
            Utils:Create("TextButton", {Parent = C, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                Open = not Open
                Utils:Tween(C, {Size = UDim2.new(1,0,0, Open and math.min(#Items*30, 150)+55 or 42)})
                Utils:Tween(Ico, {Rotation = Open and 180 or 0})
            end)
        end

        function Tab:ColorPicker(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Color3.new(1,1,1)
            local C = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Section}); Library:Register(C, "Section"); Utils:AddCorner(C, 6); Utils:AddStroke(C, nil, 1)
            Library:Register(Utils:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local P = Utils:Create("TextButton", {Parent = C, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-52,0.5,-10), BackgroundColor3 = Library.Flags[Flag], Text = ""}); Utils:AddCorner(P, 4)
            
            -- Simulated RGB Picker (Randomizer for brevity)
            P.MouseButton1Click:Connect(function() 
                local R = Color3.fromHSV(math.random(),0.8,1); Library.Flags[Flag]=R; P.BackgroundColor3=R; if Callback then Callback(R) end 
            end)
        end
        
        function Tab:AddLiveEditor()
            Tab:Section("Theme Engine")
            Tab:ColorPicker("Accent Color", "Accent", Library.Theme.Accent, function(c) Library.Theme.Accent=c; Library:RefreshTheme() end)
            Tab:ColorPicker("Main Color", "Main", Library.Theme.Main, function(c) Library.Theme.Main=c; Library:RefreshTheme() end)
            Tab:Toggle("Rainbow Mode", "Rainbow", false, function(v) Library.Rainbow=v end)
            Tab:Button("Force Refresh", function() Library:RefreshTheme() end)
        end

        return Tab
    end
    return Window
end

return Library
