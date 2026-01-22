-- [[ TITAN X FRAMEWORK | V500 ULTIMATE ]] --
-- [[ PART 1: CORE ENGINE & GRAPHICS ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Version = "5.0.0",
    Open = true,
    Theme = {
        Main = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(25, 25, 30),
        Stroke = Color3.fromRGB(50, 50, 55),
        Accent = Color3.fromRGB(110, 80, 250), -- Violet Premium
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150),
        Hover = Color3.fromRGB(35, 35, 40)
    },
    Connections = {},
    Flags = {},
    UnnamedFlags = 0
}

-- [ MODULE: ACRYLIC BLUR (EFFET VERRE) ] --
local Acrylic = {}
do
    function Acrylic:Create()
        local Effect = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
        Effect.FarIntensity = 0; Effect.FocusDistance = 51.6; Effect.InFocusRadius = 50
        Effect.NearIntensity = 1; Effect.Name = "TitanBlur"
    end
    function Acrylic:Enable(Frame)
        Frame.BackgroundTransparency = 0.05
        -- Simulation du flou (Simplifiée pour tenir dans le script)
        local Blur = Instance.new("BlurEffect", game.Lighting); Blur.Size = 15; Blur.Name = "TitanMenuBlur"
    end
    function Acrylic:Disable()
        if game.Lighting:FindFirstChild("TitanMenuBlur") then game.Lighting.TitanMenuBlur:Destroy() end
    end
end

-- [ MODULE: UTILS & ANIMATIONS ] --
local Utils = {}
function Utils:Tween(Obj, Props, Time)
    local Info = TweenInfo.new(Time or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(Obj, Info, Props):Play()
end

function Utils:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k,v in pairs(Props) do Obj[k] = v end
    return Obj
end

function Utils:Ripple(Obj)
    task.spawn(function()
        local Ripple = Utils:Create("ImageLabel", {
            Parent = Obj, BackgroundTransparency = 1, Image = "rbxassetid://266543268",
            ImageColor3 = Color3.new(1,1,1), ImageTransparency = 0.6, ZIndex = 9
        })
        local X, Y = Mouse.X - Obj.AbsolutePosition.X, Mouse.Y - Obj.AbsolutePosition.Y
        Ripple.Position = UDim2.new(0, X, 0, Y); Ripple.Size = UDim2.new(0,0,0,0)
        local Size = math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 1.5
        Utils:Tween(Ripple, {Size = UDim2.new(0, Size, 0, Size), ImageTransparency = 1}, 0.5)
        task.wait(0.5); Ripple:Destroy()
    end)
end

function Utils:Drag(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Utils:Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}, 0.05) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ WINDOW SETUP ] --
function Library:Window(Config)
    local Title = Config.Name or "Titan X"
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "TitanX_"..Title then v:Destroy() end end
    
    local GUI = Utils:Create("ScreenGui", {Name = "TitanX_"..Title, Parent = CoreGui, ZIndexBehavior = "Sibling", IgnoreGuiInset = true})
    Acrylic:Create()

    -- MAIN CONTAINER
    local Main = Utils:Create("Frame", {
        Parent = GUI, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Library.Theme.Main,
        ClipsDescendants = false -- Important pour le Glow
    })
    Utils:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    Utils:Create("UIStroke", {Parent = Main, Color = Library.Theme.Stroke, Thickness = 1})

    -- GLOW EFFECT (L'OMBRE)
    local Glow = Utils:Create("ImageLabel", {
        Parent = Main, Size = UDim2.new(1, 130, 1, 130), Position = UDim2.new(0, -65, 0, -65),
        Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.4,
        BackgroundTransparency = 1, ZIndex = 0
    })

    -- SIDEBAR
    local Sidebar = Utils:Create("Frame", {
        Parent = Main, Size = UDim2.new(0, 200, 1, 0), BackgroundColor3 = Library.Theme.Secondary,
        ZIndex = 2
    })
    Utils:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    Utils:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = Library.Theme.Secondary, BorderSizePixel = 0})

    -- TITLE
    local Logo = Utils:Create("TextLabel", {
        Parent = Sidebar, Text = Title, Size = UDim2.new(1,-20,0,50), Position = UDim2.new(0,15,0,10),
        Font = "GothamBlack", TextSize = 22, TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"
    })
    Utils:Create("TextLabel", {
        Parent = Logo, Text = "VERSION "..Library.Version, Size = UDim2.new(1,0,0,15), Position = UDim2.new(0,0,1,-12),
        Font = "GothamBold", TextSize = 10, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1, TextXAlignment = "Left"
    })

    -- TABS CONTAINER
    local TabContainer = Utils:Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1,0,1,-120), Position = UDim2.new(0,0,0,80),
        BackgroundTransparency = 1, ScrollBarThickness = 0
    })
    Utils:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 6), HorizontalAlignment = "Center"})

    -- CONTENT AREA
    local Content = Utils:Create("Frame", {
        Parent = Main, Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 200, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true
    })
    
    -- TOPBAR (Search & Close)
    local Topbar = Utils:Create("Frame", {Parent = Content, Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1})
    local CloseBtn = Utils:Create("TextButton", {
        Parent = Topbar, Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-45,0,5),
        Text = "×", Font = "Gotham", TextSize = 28, TextColor3 = Library.Theme.TextDim, BackgroundTransparency = 1
    })
    CloseBtn.MouseButton1Click:Connect(function() 
        Utils:Tween(Main, {Size = UDim2.new(0,0,0,0)}, 0.4)
        Acrylic:Disable()
        task.wait(0.4); GUI:Destroy() 
    end)
    
    Utils:Drag(Sidebar, Main)
    
    -- OUVERTURE ANIMÉE
    Utils:Tween(Main, {Size = UDim2.new(0, 750, 0, 500)}, 0.6)
    Acrylic:Enable(Main)

    local Tabs = {}
    local FirstTab = true

    -- [[ SYSTEME D'ONGLETS ]] --
    function Tabs:Tab(Name, Icon)
        local Tab = {Items = {}}
        local Button = Utils:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 170, 0, 38), BackgroundColor3 = Library.Theme.Secondary,
            Text = "       "..Name, TextColor3 = Library.Theme.TextDim, Font = "GothamMedium", TextSize = 13,
            TextXAlignment = "Left", AutoButtonColor = false
        })
        Utils:Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 6)})
        
        local Marker = Utils:Create("Frame", {
            Parent = Button, Size = UDim2.new(0,4,0,18), Position = UDim2.new(0,0,0.5,-9),
            BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1
        })
        Utils:Create("UICorner", {Parent = Marker, CornerRadius = UDim.new(0,4)})

        local Page = Utils:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1,0,1,-60), Position = UDim2.new(0,0,0,60),
            BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent
        })
        local Layout = Utils:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 10)})
        Utils:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,20), PaddingRight = UDim.new(0,20), PaddingBottom = UDim.new(0,20)})
        
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20) end)

        Button.MouseButton1Click:Connect(function()
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utils:Tween(v, {BackgroundColor3 = Library.Theme.Secondary, TextColor3 = Library.Theme.TextDim})
                    Utils:Tween(v:FindFirstChild("Frame"), {BackgroundTransparency = 1})
                end
            end
            for _,v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            
            Utils:Tween(Button, {BackgroundColor3 = Library.Theme.Hover, TextColor3 = Library.Theme.Text})
            Utils:Tween(Marker, {BackgroundTransparency = 0})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            Button.BackgroundColor3 = Library.Theme.Hover
            Button.TextColor3 = Library.Theme.Text
            Marker.BackgroundTransparency = 0
        end
        -- [[ PART 2: COMPONENT LOGIC ]] --

        -- SECTION HEADER
        function Tab:Section(Text)
            local F = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            Utils:Create("TextLabel", {
                Parent = F, Text = Text, Size = UDim2.new(1,0,1,0), Font = "GothamBold", TextSize = 14,
                TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"
            })
        end

        -- BUTTON
        function Tab:Button(Text, Callback)
            local Btn = Utils:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Secondary,
                Text = Text, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13,
                AutoButtonColor = false
            })
            Utils:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 8)})
            Utils:Create("UIStroke", {Parent = Btn, Color = Library.Theme.Stroke, Thickness = 1})
            
            Btn.MouseEnter:Connect(function() Utils:Tween(Btn, {BackgroundColor3 = Library.Theme.Hover}) end)
            Btn.MouseLeave:Connect(function() Utils:Tween(Btn, {BackgroundColor3 = Library.Theme.Secondary}) end)
            
            Btn.MouseButton1Click:Connect(function()
                Utils:Ripple(Btn)
                pcall(Callback)
            end)
        end

        -- TOGGLE
        function Tab:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local Tgl = Utils:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Secondary,
                Text = "", AutoButtonColor = false
            })
            Utils:Create("UICorner", {Parent = Tgl, CornerRadius = UDim.new(0, 8)})
            Utils:Create("UIStroke", {Parent = Tgl, Color = Library.Theme.Stroke, Thickness = 1})
            
            Utils:Create("TextLabel", {
                Parent = Tgl, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13,
                TextXAlignment = "Left"
            })
            
            local Switch = Utils:Create("Frame", {
                Parent = Tgl, Size = UDim2.new(0,44,0,22), Position = UDim2.new(1,-54,0.5,-11),
                BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main
            })
            Utils:Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(0,11)})
            
            local Dot = Utils:Create("Frame", {
                Parent = Switch, Size = UDim2.new(0,18,0,18),
                Position = Library.Flags[Flag] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
                BackgroundColor3 = Color3.new(1,1,1)
            })
            Utils:Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(0,9)})
            
            Tgl.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]
                local State = Library.Flags[Flag]
                Utils:Tween(Switch, {BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.Main})
                Utils:Tween(Dot, {Position = State and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
                if Callback then Callback(State) end
            end)
        end

        -- SLIDER
        function Tab:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            local Sld = Utils:Create("Frame", {
                Parent = Page, Size = UDim2.new(1,0,0,55), BackgroundColor3 = Library.Theme.Secondary
            })
            Utils:Create("UICorner", {Parent = Sld, CornerRadius = UDim.new(0, 8)})
            Utils:Create("UIStroke", {Parent = Sld, Color = Library.Theme.Stroke, Thickness = 1})
            
            Utils:Create("TextLabel", {
                Parent = Sld, Text = Text, Size = UDim2.new(1,-10,0,25), Position = UDim2.new(0,12,0,5),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13,
                TextXAlignment = "Left"
            })
            
            local ValueText = Utils:Create("TextLabel", {
                Parent = Sld, Text = tostring(Default), Size = UDim2.new(0,50,0,25), Position = UDim2.new(1,-60,0,5),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12,
                TextXAlignment = "Right"
            })
            
            local Bar = Utils:Create("Frame", {
                Parent = Sld, Size = UDim2.new(1,-24,0,6), Position = UDim2.new(0,12,0,38),
                BackgroundColor3 = Library.Theme.Main
            })
            Utils:Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(0,3)})
            
            local Fill = Utils:Create("Frame", {
                Parent = Bar, Size = UDim2.new((Default-Min)/(Max-Min),0,1,0),
                BackgroundColor3 = Library.Theme.Accent
            })
            Utils:Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(0,3)})
            
            local Drag = false
            local function Update(Input)
                local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Val = math.floor(Min + ((Max - Min) * P))
                Library.Flags[Flag] = Val
                ValueText.Text = tostring(Val)
                Utils:Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                if Callback then Callback(Val) end
            end
            
            Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Drag = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Drag = false end end)
            UserInputService.InputChanged:Connect(function(i) if Drag and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end
        
        -- DROPDOWN
        function Tab:Dropdown(Text, Flag, Options, Callback)
            local Open = false
            local Drop = Utils:Create("Frame", {
                Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Secondary, ClipsDescendants = true
            })
            Utils:Create("UICorner", {Parent = Drop, CornerRadius = UDim.new(0, 8)})
            Utils:Create("UIStroke", {Parent = Drop, Color = Library.Theme.Stroke, Thickness = 1})
            
            Utils:Create("TextLabel", {
                Parent = Drop, Text = Text, Size = UDim2.new(1,-40,0,42), Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13,
                TextXAlignment = "Left"
            })
            
            local Arrow = Utils:Create("ImageLabel", {
                Parent = Drop, Image = "rbxassetid://6031091004", Size = UDim2.new(0,20,0,20),
                Position = UDim2.new(1,-32,0,11), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim
            })
            
            local List = Utils:Create("ScrollingFrame", {
                Parent = Drop, Size = UDim2.new(1,-24,0,100), Position = UDim2.new(0,12,0,45),
                BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2
            })
            Utils:Create("UICorner", {Parent = List, CornerRadius = UDim.new(0,4)})
            Utils:Create("UIListLayout", {Parent = List, Padding = UDim.new(0,2)})
            
            for _, Option in pairs(Options) do
                local Btn = Utils:Create("TextButton", {
                    Parent = List, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1,
                    Text = "  "..Option, TextColor3 = Library.Theme.TextDim, Font = "Gotham",
                    TextSize = 12, TextXAlignment = "Left"
                })
                Btn.MouseButton1Click:Connect(function()
                    Library.Flags[Flag] = Option
                    if Callback then Callback(Option) end
                    Open = false
                    Utils:Tween(Drop, {Size = UDim2.new(1,0,0,42)})
                    Utils:Tween(Arrow, {Rotation = 0})
                end)
            end
            List.CanvasSize = UDim2.new(0,0,0, #Options * 30)
            
            local Trigger = Utils:Create("TextButton", {Parent = Drop, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, Text = ""})
            Trigger.MouseButton1Click:Connect(function()
                Open = not Open
                Utils:Tween(Drop, {Size = UDim2.new(1,0,0, Open and 150 or 42)})
                Utils:Tween(Arrow, {Rotation = Open and 180 or 0})
            end)
        end
        
        -- KEYBIND
        function Tab:Keybind(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Enum.KeyCode.RightControl
            local Key = Utils:Create("Frame", {
                Parent = Page, Size = UDim2.new(1,0,0,42), BackgroundColor3 = Library.Theme.Secondary
            })
            Utils:Create("UICorner", {Parent = Key, CornerRadius = UDim.new(0, 8)})
            Utils:Create("UIStroke", {Parent = Key, Color = Library.Theme.Stroke, Thickness = 1})
            
            Utils:Create("TextLabel", {
                Parent = Key, Text = Text, Size = UDim2.new(1,-100,1,0), Position = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13,
                TextXAlignment = "Left"
            })
            
            local BindBtn = Utils:Create("TextButton", {
                Parent = Key, Size = UDim2.new(0,80,0,24), Position = UDim2.new(1,-90,0.5,-12),
                BackgroundColor3 = Library.Theme.Main, Text = Library.Flags[Flag].Name,
                TextColor3 = Library.Theme.TextDim, Font = "GothamBold", TextSize = 11
            })
            Utils:Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0,4)})
            
            local Listening = false
            BindBtn.MouseButton1Click:Connect(function()
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Library.Theme.Accent
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Library.Flags[Flag] = input.KeyCode
                    BindBtn.Text = input.KeyCode.Name
                    BindBtn.TextColor3 = Library.Theme.TextDim
                    Listening = false
                    if Callback then Callback(input.KeyCode) end
                end
            end)
        end

        return Tab
    end
    return Tabs
end

return Library
