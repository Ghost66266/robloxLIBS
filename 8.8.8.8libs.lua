--[[ 
    TITAN UI FRAMEWORK V210 | FIXED LAYOUT
    AUTHOR: GHOST66266 & AI
    CHANGELOG: Fixed Sidebar overlapping Content buttons
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Version = "2.1.0",
    Open = true,
    Flags = {},
    Registry = {},
    Connections = {},
    Theme = {
        Main        = Color3.fromRGB(25, 25, 30),
        Sidebar     = Color3.fromRGB(20, 20, 25),
        Section     = Color3.fromRGB(32, 32, 38),
        Stroke      = Color3.fromRGB(55, 55, 60),
        Divider     = Color3.fromRGB(50, 50, 55),
        Accent      = Color3.fromRGB(115, 80, 255),
        Text        = Color3.fromRGB(255, 255, 255),
        TextDim     = Color3.fromRGB(150, 150, 155),
    },
    Rainbow = false
}

-- [ UTILITY ] --
local Utility = {}
function Utility:Tween(Obj, Props, Time) TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props):Play() end
function Utility:Create(Class, Props) local Obj = Instance.new(Class); for k,v in pairs(Props) do Obj[k] = v end; return Obj end
function Utility:Connect(Signal, Callback) local Con = Signal:Connect(Callback); table.insert(Library.Connections, Con); return Con end

function Utility:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Utility:Connect(Top.InputBegan, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging=true; DragStart=i.Position; StartPos=Main.Position end end)
    Utility:Connect(UserInputService.InputChanged, function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta=i.Position-DragStart; Main.Position=UDim2.new(StartPos.X.Scale, StartPos.X.Offset+Delta.X, StartPos.Y.Scale, StartPos.Y.Offset+Delta.Y) end end)
    Utility:Connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging=false end end)
end

-- [ THEME ENGINE ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    if Library.Theme[Type] then
        if Obj:IsA("TextLabel") or Obj:IsA("TextButton") or Obj:IsA("TextBox") then
            if Type == "Accent" then Obj.TextColor3 = Library.Theme.Accent else Obj.TextColor3 = Library.Theme[Type] end
        elseif Obj:IsA("UIStroke") then Obj.Color = Library.Theme[Type]
        elseif Obj:IsA("ImageLabel") then Obj.ImageColor3 = Library.Theme[Type]
        else Obj.BackgroundColor3 = Library.Theme[Type] end
    end
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj, Type = Item.Obj, Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" or Type == "Sidebar" or Type == "Section" then Utility:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]})
            elseif Type == "Stroke" then if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme[Type]}) end
            elseif Type == "Text" or Type == "TextDim" then Utility:Tween(Obj, {TextColor3 = Library.Theme[Type]})
            elseif Type == "Accent" then 
                if Obj:IsA("UIStroke") then Utility:Tween(Obj, {Color = Library.Theme.Accent})
                elseif Obj:IsA("TextLabel") then Utility:Tween(Obj, {TextColor3 = Library.Theme.Accent})
                else Utility:Tween(Obj, {BackgroundColor3 = Library.Theme.Accent}) end
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

-- [ SAVE SYSTEM ] --
function Library:SaveConfig(Name)
    if not isfolder("TitanConfigs") then makefolder("TitanConfigs") end
    writefile("TitanConfigs/"..Name..".json", HttpService:JSONEncode(Library.Flags))
    Library:Notify("Saved", "Config saved successfully", 2)
end
function Library:LoadConfig(Name)
    if isfile("TitanConfigs/"..Name..".json") then
        local data = HttpService:JSONDecode(readfile("TitanConfigs/"..Name..".json"))
        for k,v in pairs(data) do Library.Flags[k] = v end
        Library:Notify("Loaded", "Config loaded successfully", 2)
    end
end

-- [ NOTIFICATIONS ] --
function Library:Notify(Title, Text, Duration)
    local GUI = CoreGui:FindFirstChild("TitanNotify") or Utility:Create("ScreenGui", {Name = "TitanNotify", Parent = CoreGui})
    local List = GUI:FindFirstChild("List") or Utility:Create("Frame", {Name = "List", Parent = GUI, Size = UDim2.new(0,300,1,0), Position = UDim2.new(1,-310,0,0), BackgroundTransparency = 1})
    if not List:FindFirstChild("Layout") then Utility:Create("UIListLayout", {Name = "Layout", Parent = List, VerticalAlignment = "Bottom", Padding = UDim.new(0,5)}) end
    
    local F = Utility:Create("Frame", {Parent = List, Size = UDim2.new(1,0,0,60), BackgroundColor3 = Library.Theme.Main, BackgroundTransparency = 0.1})
    Library:Register(F, "Main"); Utility:Create("UICorner", {Parent = F, CornerRadius = UDim.new(0,6)})
    Library:Register(Utility:Create("UIStroke", {Parent = F, Color = Library.Theme.Stroke}), "Stroke")
    Library:Register(Utility:Create("Frame", {Parent = F, Size = UDim2.new(0,4,1,0), BackgroundColor3 = Library.Theme.Accent}), "Accent")
    
    Library:Register(Utility:Create("TextLabel", {Parent = F, Text = Title, Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,15,0,5), Font = "GothamBold", TextSize = 14, BackgroundTransparency = 1, TextXAlignment = "Left", TextColor3 = Library.Theme.Text}), "Text")
    Library:Register(Utility:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,-20,0,0), Position = UDim2.new(0,15,0,25), Font = "Gotham", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true, AutomaticSize = "Y", TextColor3 = Library.Theme.TextDim}), "TextDim")
    
    task.delay(Duration or 3, function() F:Destroy() end)
end

-- [ MAIN WINDOW ] --
function Library:Window(Config)
    local Window = {}
    local Title = Config.Title or "Titan UI"
    local Compact = Config.Compact or false
    
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TitanUI_"..Title then v:Destroy() end end
    local GUI = Utility:Create("ScreenGui", {Name = "TitanUI_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Utility:Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Library.Theme.Main, ClipsDescendants = true
    })
    Library:Register(Main, "Main"); Utility:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0,8)})
    Library:Register(Utility:Create("UIStroke", {Parent = Main, Color = Library.Theme.Accent, Thickness = 1}), "Accent")
    
    Utility:Tween(Main, {Size = Compact and UDim2.new(0,500,0,350) or UDim2.new(0,700,0,450)}, 0.5)

    -- [[ FIX: SIDEBAR Z-INDEX & CONTENT PADDING ]] --
    local SidebarWidth = 180
    
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, SidebarWidth, 1, 0), BackgroundColor3 = Library.Theme.Sidebar, ZIndex = 2
    })
    Library:Register(Sidebar, "Sidebar"); Utility:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0,8)})
    -- Fix corner
    Library:Register(Utility:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0}), "Sidebar")
    
    Library:Register(Utility:Create("TextLabel", {Parent = Sidebar, Text = Title, Size = UDim2.new(1,-20,0,50), Position = UDim2.new(0,20,0,0), Font = "GothamBlack", TextSize = 18, TextColor3 = Library.Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"}), "Accent")
    
    local TabContainer = Utility:Create("ScrollingFrame", {Parent = Sidebar, Size = UDim2.new(1,0,1,-60), Position = UDim2.new(0,0,0,60), BackgroundTransparency = 1, ScrollBarThickness = 0, ZIndex = 3})
    Utility:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0,6), HorizontalAlignment = "Center"})
    
    -- [[ CONTENT AREA: PUSHED TO THE RIGHT ]] --
    local Content = Utility:Create("Frame", {
        Name = "Content", Parent = Main, 
        Size = UDim2.new(1, -SidebarWidth, 1, 0), 
        Position = UDim2.new(0, SidebarWidth, 0, 0), -- Décalage physique
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1
    })
    
    Utility:MakeDraggable(Sidebar, Main)
    
    -- Close Button
    local Close = Utility:Create("TextButton", {Parent = Main, Size = UDim2.new(0,30,0,30), Position = UDim2.new(1,-35,0,5), Text = "X", Font = "GothamBold", BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, ZIndex = 5})
    Library:Register(Close, "TextDim"); Close.MouseButton1Click:Connect(function() GUI:Destroy() end)

    local FirstTab = true

    function Window:Tab(Name)
        local Tab = {}
        
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 160, 0, 34), BackgroundColor3 = Library.Theme.Main,
            Text = "      "..Name, TextColor3 = Library.Theme.TextDim, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left", AutoButtonColor = false, ZIndex = 3
        })
        Library:Register(TabBtn, "Main"); Library:Register(TabBtn, "TextDim")
        Utility:Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0,6)})
        
        local Indicator = Utility:Create("Frame", {Parent = TabBtn, Size = UDim2.new(0,4,0,16), Position = UDim2.new(0,0,0.5,-8), BackgroundColor3 = Library.Theme.Accent, BackgroundTransparency = 1, ZIndex = 4})
        Library:Register(Indicator, "Accent")

        local Page = Utility:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, ZIndex = 2
        })
        Library:Register(Page, "Accent")
        local Layout = Utility:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0,10)})
        -- [[ PADDING FIX: Empêche les boutons de toucher le bord gauche ]] --
        Utility:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,20), PaddingLeft = UDim.new(0,20), PaddingRight = UDim.new(0,20)})
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y+40) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then 
                Utility:Tween(v, {BackgroundColor3 = Library.Theme.Main}); Utility:Tween(v, {TextColor3 = Library.Theme.TextDim})
                Utility:Tween(v:FindFirstChild("Frame"), {BackgroundTransparency = 1})
            end end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            Utility:Tween(TabBtn, {BackgroundColor3 = Library.Theme.Section}); Utility:Tween(TabBtn, {TextColor3 = Library.Theme.Text})
            Utility:Tween(Indicator, {BackgroundTransparency = 0})
            Page.Visible = true
        end)
        
        if FirstTab then FirstTab=false; Page.Visible=true; TabBtn.BackgroundColor3=Library.Theme.Section; TabBtn.TextColor3=Library.Theme.Text; Indicator.BackgroundTransparency=0 end

        -- [ COMPONENTS ] --
        function Tab:Section(Text)
            local F = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            Library:Register(Utility:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = "GothamBlack", TextSize = 14, TextXAlignment = "Left"}), "Accent")
            Library:Register(Utility:Create("Frame", {Parent = F, Size = UDim2.new(1,-(#Text*10)-20,0,1), Position = UDim2.new(0,(#Text*9)+10,0.5,0), BackgroundColor3 = Library.Theme.Divider}), "Divider")
        end

        function Tab:Button(Text, Callback)
            local Btn = Utility:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,36), BackgroundColor3 = Library.Theme.Section, Text = Text, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false})
            Library:Register(Btn, "Section"); Library:Register(Btn, "Text"); Utility:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0,6)})
            Library:Register(Utility:Create("UIStroke", {Parent = Btn, Color = Library.Theme.Stroke}), "Stroke")
            Btn.MouseButton1Click:Connect(function() 
                Utility:Tween(Btn, {BackgroundColor3 = Library.Theme.Accent}); task.wait(0.1)
                Utility:Tween(Btn, {BackgroundColor3 = Library.Theme.Section}); pcall(Callback) 
            end)
        end

        function Tab:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local C = Utility:Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Library.Theme.Section, Text = "", AutoButtonColor = false})
            Library:Register(C, "Section"); Utility:Create("UICorner", {Parent = C, CornerRadius = UDim.new(0,6)})
            Library:Register(Utility:Create("UIStroke", {Parent = C, Color = Library.Theme.Stroke}), "Stroke")
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            
            local S = Utility:Create("Frame", {Parent = C, Size = UDim2.new(0,44,0,22), Position = UDim2.new(1,-54,0.5,-11), BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main})
            Library:Register(S, Library.Flags[Flag] and "Accent" or "Main"); Utility:Create("UICorner", {Parent = S, CornerRadius = UDim.new(0,11)})
            local D = Utility:Create("Frame", {Parent = S, Size = UDim2.new(0,18,0,18), Position = Library.Flags[Flag] and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9), BackgroundColor3 = Color3.new(1,1,1)}); Utility:Create("UICorner", {Parent = D, CornerRadius = UDim.new(0,9)})
            
            C.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]; local On = Library.Flags[Flag]
                Utility:Tween(S, {BackgroundColor3 = On and Library.Theme.Accent or Library.Theme.Main})
                Utility:Tween(D, {Position = On and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
                if Callback then Callback(On) end
            end)
        end

        function Tab:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,55), BackgroundColor3 = Library.Theme.Section})
            Library:Register(C, "Section"); Utility:Create("UICorner", {Parent = C, CornerRadius = UDim.new(0,6)})
            Library:Register(Utility:Create("UIStroke", {Parent = C, Color = Library.Theme.Stroke}), "Stroke")
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-10,0,25), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local V = Library:Register(Utility:Create("TextLabel", {Parent = C, Text = tostring(Default), Size = UDim2.new(0,50,0,25), Position = UDim2.new(1,-60,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"}), "TextDim")
            
            local B = Utility:Create("Frame", {Parent = C, Size = UDim2.new(1,-20,0,6), Position = UDim2.new(0,10,0,35), BackgroundColor3 = Library.Theme.Main}); Library:Register(B, "Main"); Utility:Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,3)})
            local F = Utility:Create("Frame", {Parent = B, Size = UDim2.new((Default-Min)/(Max-Min),0,1,0), BackgroundColor3 = Library.Theme.Accent}); Library:Register(F, "Accent"); Utility:Create("UICorner", {Parent = F, CornerRadius = UDim.new(0,3)})
            
            local Dragging = false
            local function Update(Input)
                local P = math.clamp((Input.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
                local Val = math.floor(Min + ((Max - Min) * P))
                Library.Flags[Flag] = Val; V.Text = tostring(Val)
                Utility:Tween(F, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                if Callback then Callback(Val) end
            end
            Utility:Connect(B.InputBegan, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
            Utility:Connect(UserInputService.InputEnded, function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            Utility:Connect(UserInputService.InputChanged, function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end

        function Tab:Dropdown(Text, Flag, Items, Callback)
            local Open = false
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Library.Theme.Section, ClipsDescendants = true})
            Library:Register(C, "Section"); Utility:Create("UICorner", {Parent = C, CornerRadius = UDim.new(0,6)})
            Library:Register(Utility:Create("UIStroke", {Parent = C, Color = Library.Theme.Stroke}), "Stroke")
            
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-40,0,40), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local Arrow = Library:Register(Utility:Create("ImageLabel", {Parent = C, Image = "rbxassetid://6031091004", Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-30,0,10), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim}), "TextDim")
            
            local List = Utility:Create("ScrollingFrame", {Parent = C, Size = UDim2.new(1,-10,0,100), Position = UDim2.new(0,5,0,45), BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2}); Library:Register(List, "Main"); Utility:Create("UICorner", {Parent = List, CornerRadius = UDim.new(0,4)})
            Utility:Create("UIListLayout", {Parent = List, Padding = UDim.new(0,2)})
            
            local function Load()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _,i in pairs(Items) do
                    local B = Utility:Create("TextButton", {Parent = List, Size = UDim2.new(1,0,0,25), BackgroundTransparency = 1, Text = "  "..i, TextColor3 = Library.Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"})
                    Library:Register(B, "TextDim")
                    B.MouseButton1Click:Connect(function()
                        Library.Flags[Flag] = i; Library:Register(C:FindFirstChild("TextLabel"), "Text").Text = Text.." : "..i
                        Open = false; Utility:Tween(C, {Size = UDim2.new(1,0,0,40)}); Utility:Tween(Arrow, {Rotation = 0})
                        if Callback then Callback(i) end
                    end)
                end
                List.CanvasSize = UDim2.new(0,0,0,#Items * 27)
            end
            Load()
            
            Utility:Create("TextButton", {Parent = C, Size = UDim2.new(1,0,0,40), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                Open = not Open
                Utility:Tween(C, {Size = UDim2.new(1,0,0,Open and 150 or 40)})
                Utility:Tween(Arrow, {Rotation = Open and 180 or 0})
            end)
        end
        
        function Tab:PlayerList(Flag, Callback)
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,160), BackgroundColor3 = Library.Theme.Section}); Library:Register(C, "Section")
            Utility:Create("UICorner", {Parent = C, CornerRadius = UDim.new(0,6)}); Library:Register(Utility:Create("UIStroke", {Parent = C, Color = Library.Theme.Stroke}), "Stroke")
            local Scroll = Utility:Create("ScrollingFrame", {Parent = C, Size = UDim2.new(1,-10,1,-10), Position = UDim2.new(0,5,0,5), BackgroundTransparency = 1, ScrollBarThickness = 2}); Utility:Create("UIListLayout", {Parent = Scroll, Padding = UDim.new(0,4)})
            
            local function Update()
                for _,v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _,p in pairs(Players:GetPlayers()) do
                    local B = Utility:Create("TextButton", {Parent = Scroll, Size = UDim2.new(1,0,0,32), BackgroundColor3 = Library.Theme.Main, Text = "", AutoButtonColor = false}); Library:Register(B, "Main")
                    Utility:Create("UICorner", {Parent = B, CornerRadius = UDim.new(0,4)})
                    local Img = Utility:Create("ImageLabel", {Parent = B, Size = UDim2.new(0,24,0,24), Position = UDim2.new(0,4,0,4), BackgroundTransparency = 1})
                    task.spawn(function() Img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
                    Library:Register(Utility:Create("TextLabel", {Parent = B, Text = p.DisplayName, Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0,35,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"}), "Text")
                    B.MouseButton1Click:Connect(function() Library.Flags[Flag] = p; if Callback then Callback(p) end; Utility:Tween(B, {BackgroundColor3 = Library.Theme.Accent}); task.wait(0.1); Utility:Tween(B, {BackgroundColor3 = Library.Theme.Main}) end)
                end
                Scroll.CanvasSize = UDim2.new(0,0,0,#Players:GetPlayers()*36)
            end
            Update(); Players.PlayerAdded:Connect(Update)
        end
        
        function Tab:ColorPicker(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Color3.new(1,1,1)
            local C = Utility:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Library.Theme.Section}); Library:Register(C, "Section")
            Utility:Create("UICorner", {Parent = C, CornerRadius = UDim.new(0,6)}); Library:Register(Utility:Create("UIStroke", {Parent = C, Color = Library.Theme.Stroke}), "Stroke")
            Library:Register(Utility:Create("TextLabel", {Parent = C, Text = Text, Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local P = Utility:Create("TextButton", {Parent = C, Size = UDim2.new(0,40,0,24), Position = UDim2.new(1,-50,0.5,-12), BackgroundColor3 = Library.Flags[Flag], Text = ""}); Utility:Create("UICorner", {Parent = P, CornerRadius = UDim.new(0,4)}); Library:Register(Utility:Create("UIStroke", {Parent = P, Color = Library.Theme.Stroke}), "Stroke")
            P.MouseButton1Click:Connect(function() local R = Color3.fromHSV(math.random(),1,1); Library.Flags[Flag]=R; P.BackgroundColor3=R; if Callback then Callback(R) end end)
        end
        
        function Tab:AddLiveEditor()
            Tab:Section("Theme Engine")
            Tab:ColorPicker("Accent Color", "Accent", Library.Theme.Accent, function(c) Library.Theme.Accent=c; Library:RefreshTheme() end)
            Tab:ColorPicker("Main Color", "Main", Library.Theme.Main, function(c) Library.Theme.Main=c; Library:RefreshTheme() end)
            Tab:ColorPicker("Sidebar Color", "Sidebar", Library.Theme.Sidebar, function(c) Library.Theme.Sidebar=c; Library:RefreshTheme() end)
            Tab:Toggle("Rainbow Mode", "Rainbow", false, function(v) Library.Rainbow=v end)
        end

        return Tab
    end
    return Window
end

return Library
