-- [[ PROJECT: RAY-X | RAYFIELD CLONE SOURCE ]] --
-- [[ PARTIE 1 : MOTEUR GRAPHIQUE & CORE ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local RayX = {
    Flags = {},
    Theme = {
        Default = {
            Main = Color3.fromRGB(25, 25, 30),
            Sidebar = Color3.fromRGB(20, 20, 25),
            Section = Color3.fromRGB(30, 30, 35),
            Stroke = Color3.fromRGB(50, 50, 55),
            Text = Color3.fromRGB(240, 240, 240),
            TextDim = Color3.fromRGB(140, 140, 140),
            Accent = Color3.fromRGB(65, 130, 255), -- Rayfield Blue
            Success = Color3.fromRGB(45, 200, 90),
            Warning = Color3.fromRGB(255, 200, 60)
        }
    },
    CurrentTheme = "Default",
    Open = true
}

-- [ UTILITIES ] --
local function Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

local function AddCorner(Obj, Radius)
    return Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 8)})
end

local function AddStroke(Obj, Color, Thickness)
    return Create("UIStroke", {Parent = Obj, Color = Color or RayX.Theme.Default.Stroke, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props):Play()
end

local function MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ NOTIFICATION SYSTEM ] --
function RayX:Notify(Title, Content, Duration)
    local GUI = CoreGui:FindFirstChild("RayX_Notify") or Create("ScreenGui", {Name = "RayX_Notify", Parent = CoreGui, ZIndexBehavior = "Sibling"})
    local List = GUI:FindFirstChild("List") or Create("Frame", {Name = "List", Parent = GUI, Size = UDim2.new(0, 320, 1, 0), Position = UDim2.new(1, -330, 0, 0), BackgroundTransparency = 1})
    if not List:FindFirstChild("Layout") then Create("UIListLayout", {Name = "Layout", Parent = List, VerticalAlignment = "Bottom", Padding = UDim.new(0, 8)}) end
    
    local Frame = Create("Frame", {Parent = List, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = RayX.Theme.Default.Main, AutomaticSize = "Y", BackgroundTransparency = 1})
    AddCorner(Frame, 8); AddStroke(Frame, RayX.Theme.Default.Stroke)
    
    local TitleLabel = Create("TextLabel", {Parent = Frame, Text = Title, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 15, 0, 5), Font = "GothamBold", TextSize = 14, TextColor3 = RayX.Theme.Default.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"})
    local DescLabel = Create("TextLabel", {Parent = Frame, Text = Content, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 15, 0, 30), Font = "Gotham", TextSize = 13, TextColor3 = RayX.Theme.Default.Text, BackgroundTransparency = 1, TextXAlignment = "Left", TextWrapped = true, AutomaticSize = "Y"})
    
    -- Padding bottom
    Create("Frame", {Parent = Frame, Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,0), BackgroundTransparency = 1})

    Tween(Frame, {BackgroundTransparency = 0.1})
    task.delay(Duration or 3, function() Tween(Frame, {BackgroundTransparency = 1}); Frame:Destroy() end)
end

-- [ CONFIG SYSTEM ] --
function RayX:SaveConfig(Name)
    if not isfolder("RayX_Config") then makefolder("RayX_Config") end
    writefile("RayX_Config/"..Name..".json", HttpService:JSONEncode(RayX.Flags))
    RayX:Notify("Configuration", "Saved config: "..Name, 2)
end

function RayX:LoadConfig(Name)
    if isfile("RayX_Config/"..Name..".json") then
        local data = HttpService:JSONDecode(readfile("RayX_Config/"..Name..".json"))
        for k, v in pairs(data) do RayX.Flags[k] = v end
        RayX:Notify("Configuration", "Loaded config: "..Name, 2)
    end
end

-- [ WINDOW CREATION ] --
function RayX:CreateWindow(Settings)
    local Name = Settings.Name or "RayX Interface"
    local Theme = RayX.Theme.Default
    
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "RayX_"..Name then v:Destroy() end end
    local GUI = Create("ScreenGui", {Name = "RayX_"..Name, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Main, ClipsDescendants = true
    })
    AddCorner(Main, 10); AddStroke(Main, Theme.Stroke, 1)

    -- SIDEBAR
    local Sidebar = Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = Theme.Sidebar, ZIndex = 2
    })
    AddCorner(Sidebar, 10)
    -- Fix corner overlap
    Create("Frame", {Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0})

    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar, Text = Name, Size = UDim2.new(1, -20, 0, 60), Position = UDim2.new(0, 15, 0, 0),
        Font = "GothamBlack", TextSize = 18, TextColor3 = Theme.Accent, BackgroundTransparency = 1, TextXAlignment = "Left"
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1, ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 6), HorizontalAlignment = "Center"})

    -- CONTENT AREA
    local Content = Create("Frame", {
        Name = "Content", Parent = Main, Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 200, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true
    })
    
    -- SEARCH BAR (Rayfield Style)
    local Topbar = Create("Frame", {Parent = Content, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1})
    local SearchFrame = Create("Frame", {
        Parent = Topbar, Size = UDim2.new(1, -40, 0, 35), Position = UDim2.new(0, 20, 0.5, -17.5),
        BackgroundColor3 = Theme.Section
    })
    AddCorner(SearchFrame, 8); AddStroke(SearchFrame, Theme.Stroke)
    
    local SearchIcon = Create("ImageLabel", {
        Parent = SearchFrame, Image = "rbxassetid://6031154871", Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10), BackgroundTransparency = 1, ImageColor3 = Theme.TextDim
    })
    
    local SearchInput = Create("TextBox", {
        Parent = SearchFrame, Text = "", PlaceholderText = "Search...", Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 40, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text,
        Font = "Gotham", TextSize = 14, TextXAlignment = "Left"
    })

    -- Drag Logic
    MakeDraggable(Sidebar, Main)
    MakeDraggable(Topbar, Main)

    -- Exit Button (Hidden in Search area but logical)
    local CloseBtn = Create("TextButton", {Parent = Main, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0, 15), Text = "X", Font = "GothamBold", BackgroundTransparency = 1, TextColor3 = Theme.TextDim, ZIndex = 10})
    CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:CreateTab(TabName, IconId)
        local Tab = {}
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 180, 0, 36), BackgroundColor3 = Theme.Sidebar,
            Text = "      "..TabName, TextColor3 = Theme.TextDim, Font = "GothamMedium", TextSize = 13,
            TextXAlignment = "Left", AutoButtonColor = false
        })
        AddCorner(TabBtn, 6)
        
        -- Icon
        if IconId then
            local Icon = Create("ImageLabel", {
                Parent = TabBtn, Image = "rbxassetid://"..tostring(IconId), Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, -8), BackgroundTransparency = 1, ImageColor3 = Theme.TextDim
            })
        end

        local Page = Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
            BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
        })
        local PageLayout = Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 12)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20)})
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextDim})
                end
            end
            for _, v in pairs(Content:GetChildren()) do if v.Name ~= "Frame" then v.Visible = false end end -- Hide other pages
            
            Tween(TabBtn, {BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            TabBtn.BackgroundColor3 = Theme.Section; TabBtn.TextColor3 = Theme.Text
        end

        -- ... CONTINUED IN PART 2 ...
        -- [[ PARTIE 2 : COMPOSANTS RAYFIELD ]] --

        function Tab:CreateSection(Text)
            local SectionLabel = Create("TextLabel", {
                Parent = Page, Text = Text, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
                TextColor3 = Theme.TextDim, Font = "GothamBold", TextSize = 12, TextXAlignment = "Left"
            })
        end

        function Tab:CreateButton(Config)
            local Btn = Create("TextButton", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Section,
                Text = "", AutoButtonColor = false
            })
            AddCorner(Btn, 8); AddStroke(Btn, Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = Btn, Text = Config.Name, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            
            local Icon = Create("ImageLabel", {
                Parent = Btn, Image = "rbxassetid://6031068420", Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10), BackgroundTransparency = 1, ImageColor3 = Theme.TextDim
            })

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Accent})
                task.wait(0.1)
                Tween(Btn, {BackgroundColor3 = Theme.Section})
                pcall(Config.Callback)
            end)
        end

        function Tab:CreateToggle(Config)
            RayX.Flags[Config.Flag] = Config.CurrentValue or false
            
            local Container = Create("TextButton", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Section,
                Text = "", AutoButtonColor = false
            })
            AddCorner(Container, 8); AddStroke(Container, Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            
            local Switch = Create("Frame", {
                Parent = Container, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = RayX.Flags[Config.Flag] and Theme.Accent or Theme.Main
            })
            AddCorner(Switch, 10); AddStroke(Switch, Theme.Stroke, 1)
            
            local Dot = Create("Frame", {
                Parent = Switch, Size = UDim2.new(0, 12, 0, 12),
                Position = RayX.Flags[Config.Flag] and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6),
                BackgroundColor3 = Theme.Text
            })
            AddCorner(Dot, 6)
            
            Container.MouseButton1Click:Connect(function()
                RayX.Flags[Config.Flag] = not RayX.Flags[Config.Flag]
                local State = RayX.Flags[Config.Flag]
                Tween(Switch, {BackgroundColor3 = State and Theme.Accent or Theme.Main})
                Tween(Dot, {Position = State and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 4, 0.5, -6)})
                if Config.Callback then Config.Callback(State) end
            end)
        end

        function Tab:CreateSlider(Config)
            RayX.Flags[Config.Flag] = Config.CurrentValue or Config.Range[1]
            local Min, Max = Config.Range[1], Config.Range[2]
            
            local Container = Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Section
            })
            AddCorner(Container, 8); AddStroke(Container, Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name, Size = UDim2.new(1, -20, 0, 25), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            
            local ValueLabel = Create("TextLabel", {
                Parent = Container, Text = tostring(RayX.Flags[Config.Flag])..(Config.Suffix or ""),
                Size = UDim2.new(0, 50, 0, 25), Position = UDim2.new(1, -15, 0, 0), AnchorPoint = Vector2.new(1,0),
                BackgroundTransparency = 1, TextColor3 = Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Right"
            })

            local SliderBar = Create("Frame", {
                Parent = Container, Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 32),
                BackgroundColor3 = Theme.Main
            })
            AddCorner(SliderBar, 3)
            
            local Fill = Create("Frame", {
                Parent = SliderBar, Size = UDim2.new((RayX.Flags[Config.Flag] - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = Theme.Accent
            })
            AddCorner(Fill, 3)
            
            local Trigger = Create("TextButton", {
                Parent = SliderBar, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""
            })
            
            local Dragging = false
            local function Update(Input)
                local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX))
                RayX.Flags[Config.Flag] = Value
                ValueLabel.Text = tostring(Value)..(Config.Suffix or "")
                Tween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.05)
                if Config.Callback then Config.Callback(Value) end
            end
            
            Trigger.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
        end

        function Tab:CreateInput(Config)
            local Container = Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Theme.Section
            })
            AddCorner(Container, 8); AddStroke(Container, Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            
            local Box = Create("TextBox", {
                Parent = Container, Size = UDim2.new(0, 180, 0, 30), Position = UDim2.new(1, -15, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Theme.Main, Text = "", PlaceholderText = Config.PlaceholderText or "Input...",
                TextColor3 = Theme.Text, Font = "Gotham", TextSize = 12
            })
            AddCorner(Box, 6); AddStroke(Box, Theme.Stroke)
            
            Box.FocusLost:Connect(function()
                if Config.Callback then Config.Callback(Box.Text) end
                if Config.RemoveTextAfterFocusLost then Box.Text = "" end
            end)
        end

        function Tab:CreateDropdown(Config)
            local Open = false
            local Container = Create("Frame", {
                Parent = Page, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Section, ClipsDescendants = true
            })
            AddCorner(Container, 8); AddStroke(Container, Theme.Stroke)
            
            local Label = Create("TextLabel", {
                Parent = Container, Text = Config.Name, Size = UDim2.new(1, -40, 0, 42), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = "GothamMedium", TextSize = 13, TextXAlignment = "Left"
            })
            
            local Icon = Create("ImageLabel", {
                Parent = Container, Image = "rbxassetid://6031091004", Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -35, 0, 11), BackgroundTransparency = 1, ImageColor3 = Theme.TextDim
            })
            
            local List = Create("ScrollingFrame", {
                Parent = Container, Size = UDim2.new(1, -20, 0, 100), Position = UDim2.new(0, 10, 0, 45),
                BackgroundColor3 = Theme.Main, BorderSizePixel = 0, ScrollBarThickness = 2
            })
            AddCorner(List, 6); Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 2)})
            
            for _, Item in pairs(Config.Options) do
                local Btn = Create("TextButton", {
                    Parent = List, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
                    Text = "  "..Item, TextColor3 = Theme.TextDim, Font = "Gotham", TextSize = 12, TextXAlignment = "Left"
                })
                Btn.MouseButton1Click:Connect(function()
                    RayX.Flags[Config.Flag] = Item
                    Label.Text = Config.Name .. " : " .. Item
                    if Config.Callback then Config.Callback(Item) end
                    Open = false
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 42)})
                    Tween(Icon, {Rotation = 0})
                end)
            end
            List.CanvasSize = UDim2.new(0,0,0, #Config.Options * 30)

            local Trigger = Create("TextButton", {Parent = Container, Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, Text = ""})
            Trigger.MouseButton1Click:Connect(function()
                Open = not Open
                Tween(Container, {Size = UDim2.new(1, 0, 0, Open and 150 or 42)})
                Tween(Icon, {Rotation = Open and 180 or 0})
            end)
        end
        
        -- [ THEME MANAGER INCLUDED ] --
        function Tab:AddThemeManager()
            Tab:CreateSection("Theme Settings")
            Tab:CreateButton({Name = "Dark Theme", Callback = function() RayX.Theme.Default.Main = Color3.fromRGB(25,25,30); RayX.Theme.Default.Accent = Color3.fromRGB(65, 130, 255) end})
            Tab:CreateButton({Name = "Light Theme", Callback = function() RayX.Theme.Default.Main = Color3.fromRGB(240,240,240); RayX.Theme.Default.Accent = Color3.fromRGB(0, 120, 215) end})
        end

        return Tab
    end

    return WindowFuncs
end

return RayX
