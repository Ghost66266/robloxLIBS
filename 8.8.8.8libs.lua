-- [[ ECLIPSE UI LIBRARY V50 | PROFESSIONAL GRADE ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Flags = {},
    Theme = {
        Main = Color3.fromRGB(25, 25, 25),
        Sidebar = Color3.fromRGB(30, 30, 30),
        Section = Color3.fromRGB(35, 35, 35),
        Stroke = Color3.fromRGB(60, 60, 60), -- Bordure fine grise
        Accent = Color3.fromRGB(119, 56, 255), -- Violet Premium
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150)
    },
    Open = true
}

-- [ 1. UTILS & GRAPHICS ] --
local function Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

local function MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

local function AddStroke(Obj, Color, Thickness)
    Create("UIStroke", {Parent = Obj, Color = Color or Library.Theme.Stroke, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function AddCorner(Obj, Radius)
    Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

local function Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Props):Play()
end

-- [ 2. CONFIG SYSTEM ] --
function Library:SaveConfig(Name)
    if not isfolder("WindConfigs") then makefolder("WindConfigs") end
    local json = HttpService:JSONEncode(Library.Flags)
    writefile("WindConfigs/"..Name..".json", json)
end

function Library:LoadConfig(Name)
    if isfile("WindConfigs/"..Name..".json") then
        local data = HttpService:JSONDecode(readfile("WindConfigs/"..Name..".json"))
        for k,v in pairs(data) do Library.Flags[k] = v end
        return true
    end
    return false
end

-- [ 3. WINDOW ] --
function Library:Window(Config)
    local Title = Config.Title or "Eclipse UI"
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Eclipse_"..Title then v:Destroy() end end
    
    local GUI = Create("ScreenGui", {Name = "Eclipse_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    -- Main Container
    local Main = Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 600, 0, 420),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Main, ClipsDescendants = false
    })
    AddCorner(Main, 8); AddStroke(Main, Library.Theme.Accent, 1) -- Bordure Accent autour du menu
    
    -- Topbar
    local Topbar = Create("Frame", {
        Name = "Topbar", Parent = Main, Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Library.Theme.Sidebar, BackgroundTransparency = 0
    })
    AddCorner(Topbar, 8); MakeDraggable(Topbar, Main)
    -- Cache le bas arrondi de la topbar
    Create("Frame", {Parent = Topbar, Size = UDim2.new(1,0,0,5), Position = UDim2.new(0,0,1,-5), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0})

    Create("TextLabel", {
        Parent = Topbar, Text = Title, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = "Left"
    })

    -- Sidebar (Tabs)
    local Sidebar = Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 0)})
    
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -10), Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1, ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    -- Content Area
    local ContentFrame = Create("Frame", {
        Name = "Content", Parent = Main, Size = UDim2.new(1, -170, 1, -50), Position = UDim2.new(0, 165, 0, 45),
        BackgroundTransparency = 1, ClipsDescendants = true
    })

    -- [ TAB SYSTEM ] --
    local WindowFuncs = {}
    local FirstTab = true
    
    function WindowFuncs:Tab(Name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 140, 0, 32),
            BackgroundColor3 = Library.Theme.Main, Text = Name,
            TextColor3 = Library.Theme.TextDim, Font = Enum.Font.GothamMedium, TextSize = 13,
            AutoButtonColor = false
        })
        AddCorner(TabBtn, 6)
        
        local Page = Create("ScrollingFrame", {
            Parent = ContentFrame, Size = UDim2.new(1, 0, 1, 0), Visible = false,
            BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8), SortOrder = "LayoutOrder"})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10)})
        
        Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    Tween(v, {BackgroundColor3 = Library.Theme.Main, TextColor3 = Library.Theme.TextDim}) 
                end 
            end
            for _, v in pairs(ContentFrame:GetChildren()) do v.Visible = false end
            Tween(TabBtn, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Text})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            TabBtn.BackgroundColor3 = Library.Theme.Accent; TabBtn.TextColor3 = Library.Theme.Text
        end

        -- [ COMPONENTS ] --
        local TabFuncs = {}
        
        function TabFuncs:Section(Text)
            local SecFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1})
            Create("TextLabel", {
                Parent = SecFrame, Text = Text, Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = "Left"
            })
        end

        function TabFuncs:Button(Text, Callback)
            local BtnFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Library.Theme.Section})
            AddCorner(BtnFrame, 6); AddStroke(BtnFrame, Library.Theme.Stroke)
            
            local Btn = Create("TextButton", {
                Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = Text, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13
            })
            
            Btn.MouseButton1Click:Connect(function()
                Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Accent}); task.wait(0.1)
                Tween(BtnFrame, {BackgroundColor3 = Library.Theme.Section})
                pcall(Callback)
            end)
        end

        function TabFuncs:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local TglFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Library.Theme.Section})
            AddCorner(TglFrame, 6); AddStroke(TglFrame, Library.Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = TglFrame, Text = Text, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Left"
            })
            
            local Switch = Create("Frame", {
                Parent = TglFrame, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main
            })
            AddCorner(Switch, 10)
            
            local Dot = Create("Frame", {
                Parent = Switch, Size = UDim2.new(0, 16, 0, 16),
                Position = Library.Flags[Flag] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1,1,1)
            })
            AddCorner(Dot, 8)
            
            local Btn = Create("TextButton", {Parent = TglFrame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
            
            Btn.MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]
                local State = Library.Flags[Flag]
                Tween(Switch, {BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.Main})
                Tween(Dot, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if Callback then Callback(State) end
            end)
        end

        function TabFuncs:Slider(Text, Flag, Min, Max, Default, Callback)
            Library.Flags[Flag] = Default or Min
            local SldFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Theme.Section})
            AddCorner(SldFrame, 6); AddStroke(SldFrame, Library.Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = SldFrame, Text = Text, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Left"
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = SldFrame, Text = tostring(Library.Flags[Flag]), Size = UDim2.new(0, 40, 0, 25), Position = UDim2.new(1, -50, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Right"
            })
            
            local Bar = Create("Frame", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 0, 32), BackgroundColor3 = Library.Theme.Main})
            AddCorner(Bar, 2)
            
            local Fill = Create("Frame", {
                Parent = Bar, Size = UDim2.new((Library.Flags[Flag] - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = Library.Theme.Accent
            })
            AddCorner(Fill, 2)
            
            local Btn = Create("TextButton", {Parent = SldFrame, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
            local Dragging = false
            
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Val = math.floor(Min + ((Max - Min) * SizeX))
                Library.Flags[Flag] = Val
                ValueLabel.Text = tostring(Val)
                Tween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.05)
                if Callback then Callback(Val) end
            end
            
            Btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end
        
        function TabFuncs:Dropdown(Text, Flag, Items, Callback)
            local DropFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Library.Theme.Section, ClipsDescendants = true})
            AddCorner(DropFrame, 6); AddStroke(DropFrame, Library.Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = DropFrame, Text = Text, Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = "Left"
            })
            
            local Arrow = Create("ImageLabel", {
                Parent = DropFrame, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0, 8), BackgroundTransparency = 1, ImageColor3 = Library.Theme.TextDim
            })
            
            local Open = false
            local Height = 36 + (#Items * 25) + 5
            
            local Btn = Create("TextButton", {Parent = DropFrame, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Text = ""})
            Btn.MouseButton1Click:Connect(function()
                Open = not Open
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, Open and Height or 36)})
                Tween(Arrow, {Rotation = Open and 180 or 0})
            end)
            
            local ListFrame = Create("Frame", {
                Parent = DropFrame, Size = UDim2.new(1, -10, 0, #Items * 25), Position = UDim2.new(0, 5, 0, 36), BackgroundTransparency = 1
            })
            Create("UIListLayout", {Parent = ListFrame, Padding = UDim.new(0, 2)})
            
            for _, Item in pairs(Items) do
                local ItemBtn = Create("TextButton", {
                    Parent = ListFrame, Size = UDim2.new(1, 0, 0, 25), BackgroundColor3 = Library.Theme.Main,
                    Text = Item, TextColor3 = Library.Theme.TextDim, Font = Enum.Font.Gotham, TextSize = 12
                })
                AddCorner(ItemBtn, 4)
                ItemBtn.MouseButton1Click:Connect(function()
                    Library.Flags[Flag] = Item
                    Label.Text = Text .. ": " .. Item
                    Open = false
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 36)})
                    Tween(Arrow, {Rotation = 0})
                    if Callback then Callback(Item) end
                end)
            end
        end

        return TabFuncs
    end
    
    return WindowFuncs
end

return Library
