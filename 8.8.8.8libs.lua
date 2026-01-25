-- [[ 8.8.8.8 UI LIBRARY V1.4 ]] --
-- [[ ANIMATED: TRANSITIONS, POP-UP, HOVERS ]] --

local Library = {}
local Services = {
    Players = game:GetService("Players"),
    UserInput = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local IsMobile = not Services.UserInput.KeyboardEnabled

-- Configuration des Couleurs
local UIConfig = {
    Main = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 140, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Item = Color3.fromRGB(40, 40, 45),
    Hover = Color3.fromRGB(55, 55, 60)
}

function Library:Tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    Services.TweenService:Create(obj, info, props):Play()
end

function Library:Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

function Library:MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    Services.UserInput.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(Settings)
    local Name = Settings.Name or "8.8.8.8 UI"
    local SubTitle = Settings.Intro or "V1.4"
    UIConfig.Accent = Settings.Color or UIConfig.Accent

    if Services.CoreGui:FindFirstChild("OnyxLib") then Services.CoreGui.OnyxLib:Destroy() end
    
    local Screen = Library:Create("ScreenGui", {Name = "OnyxLib", Parent = Services.CoreGui, ResetOnSpawn = false, DisplayOrder = 10000})
    local WinSize = IsMobile and UDim2.new(0, 340, 0, 320) or UDim2.new(0, 550, 0, 400)
    
    local Main = Library:Create("Frame", {
        Parent = Screen, Size = WinSize, Position = UDim2.new(0.5,0,0.5,0), 
        AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = UIConfig.Main, 
        ClipsDescendants = true, Active = true, Draggable = true, Visible = false
    })
    
    local MainScale = Instance.new("UIScale", Main); MainScale.Scale = 0 

    Library:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    Library:Create("UIStroke", {Parent = Main, Color = Color3.fromRGB(50,50,55), Thickness = 1})

    local Sidebar = Library:Create("Frame", {Parent = Main, Size = UDim2.new(0, 110, 1, 0), BackgroundColor3 = UIConfig.Sidebar, BorderSizePixel = 0})
    Library:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    Library:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = UIConfig.Sidebar, BorderSizePixel=0})
    
    local TitleLabel = Library:Create("TextLabel", {Parent = Sidebar, Text = Name, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = UIConfig.Accent, Position = UDim2.new(0,0,0,10)})
    Library:Create("TextLabel", {Parent = TitleLabel, Text = SubTitle, Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = UIConfig.TextDark})

    local TabContainer = Library:Create("Frame", {Parent = Sidebar, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1})
    Library:Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PagesContainer = Library:Create("Frame", {Parent = Main, Size = UDim2.new(1, -120, 1, -20), Position = UDim2.new(0, 120, 0, 10), BackgroundTransparency = 1})

    local Card = Library:Create("Frame", {Parent = Screen, Size = UDim2.new(0, 200, 0, 50), Position = UDim2.new(0, 10, 1, -60), BackgroundColor3 = UIConfig.Main, BackgroundTransparency = 0.1, Visible = true})
    Library:Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
    Library:Create("UIStroke", {Parent = Card, Color = UIConfig.Item, Thickness = 1})
    local Avatar = Library:Create("ImageLabel", {Parent = Card, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0.5, -15), BackgroundColor3 = UIConfig.Item, Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"})
    Library:Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    task.spawn(function() local c, r = Services.Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48); if r then Avatar.Image = c end end)
    Library:Create("TextLabel", {Parent = Card, Text = LocalPlayer.DisplayName, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 50, 0, 5), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    Library:Create("TextLabel", {Parent = Card, Text = "@" .. LocalPlayer.Name, Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 50, 0, 25), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextColor3 = UIConfig.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})

    local IsOpen = false
    local function ToggleMenu()
        IsOpen = not IsOpen
        if IsOpen then Main.Visible = true; Library:Tween(MainScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else Library:Tween(MainScale, {Scale = 0}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In); task.delay(0.3, function() if not IsOpen then Main.Visible = false end end) end
    end
    if not IsMobile then ToggleMenu() end

    if IsMobile then
        local MobBtn = Library:Create("TextButton", {Parent = Screen, Text = "⚙", Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0, 50), BackgroundColor3 = UIConfig.Main, TextColor3 = UIConfig.Accent, Font = Enum.Font.GothamBold, TextSize = 26, ZIndex = 1000})
        Library:Create("UICorner", {Parent = MobBtn, CornerRadius = UDim.new(1,0)}); Library:Create("UIStroke", {Parent = MobBtn, Color = UIConfig.Accent, Thickness = 2})
        Library:MakeDraggable(MobBtn); MobBtn.MouseButton1Click:Connect(ToggleMenu)
    else Services.UserInput.InputBegan:Connect(function(i,p) if not p and i.KeyCode == Enum.KeyCode.Insert then ToggleMenu() end end) end

    local WindowFunctions = {}

    function WindowFunctions:AddTab(Name)
        -- Page Creation
        local Page = Library:Create("ScrollingFrame", {
            Parent = PagesContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, 
            ScrollBarThickness = 2, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0)
        })
        Library:Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Library:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,5), PaddingLeft = UDim.new(0,5)})
        
        -- Tab Button
        local Btn = Library:Create("TextButton", {Parent = TabContainer, Size = UDim2.new(1, -10, 0, 35), BackgroundColor3 = UIConfig.Sidebar, Text = Name, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.TextDark, TextSize = 12, AutoButtonColor = false})
        Library:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
        
        local function Activate()
            -- 1. Reset all tabs styling
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    Library:Tween(v, {TextColor3 = UIConfig.TextDark, BackgroundTransparency = 1}) 
                end 
            end
            
            -- 2. Highlight current tab button
            Library:Tween(Btn, {TextColor3 = UIConfig.Accent, BackgroundTransparency = 0.9})

            -- 3. Hide all pages
            for _, v in pairs(PagesContainer:GetChildren()) do 
                if v:IsA("ScrollingFrame") then v.Visible = false end 
            end
            
            -- 4. Show and Animate New Page (Slide Up Effect)
            Page.Visible = true
            Page.Position = UDim2.new(0, 0, 0, 20) -- Start slightly lower
            Library:Tween(Page, {Position = UDim2.new(0,0,0,0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end
        
        Btn.MouseButton1Click:Connect(Activate)
        
        -- Auto Select First Tab
        if #TabContainer:GetChildren() == 2 then Activate() end

        local PageFunctions = {}

        local function AddAnim(Obj)
            Obj.MouseEnter:Connect(function() Library:Tween(Obj, {BackgroundColor3 = UIConfig.Hover}, 0.2) end)
            Obj.MouseLeave:Connect(function() Library:Tween(Obj, {BackgroundColor3 = UIConfig.Item}, 0.2) end)
            Obj.MouseButton1Down:Connect(function() Library:Tween(Obj, {Size = UDim2.new(1, -15, 0, Obj.Size.Y.Offset - 2)}, 0.1) end)
            Obj.MouseButton1Up:Connect(function() Library:Tween(Obj, {Size = UDim2.new(1, -10, 0, Obj.Size.Y.Offset)}, 0.1) end)
        end

        function PageFunctions:AddToggle(Text, Default, Callback)
            local Container = Library:Create("TextButton", {Parent = Page, Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = UIConfig.Item, Text = "", AutoButtonColor = false}); Library:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Library:Create("TextLabel", {Parent = Container, Text = Text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local SwitchBg = Library:Create("Frame", {Parent = Container, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 65)}); Library:Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
            local Dot = Library:Create("Frame", {Parent = SwitchBg, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}); Library:Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})
            AddAnim(Container)
            local function Update()
                if Default then Library:Tween(SwitchBg, {BackgroundColor3 = UIConfig.Accent}); Library:Tween(Dot, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                else Library:Tween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}); Library:Tween(Dot, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.3, Enum.EasingStyle.Back) end
                if Callback then Callback(Default) end
            end
            Container.MouseButton1Click:Connect(function() Default = not Default; Update() end); Update()
        end

        function PageFunctions:AddSlider(Text, Min, Max, Default, Callback)
            local Value = Default or Min
            local Container = Library:Create("Frame", {Parent = Page, Size = UDim2.new(1, -10, 0, 55), BackgroundColor3 = UIConfig.Item}); Library:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Library:Create("TextLabel", {Parent = Container, Text = Text, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            local Val = Library:Create("TextLabel", {Parent = Container, Text = tostring(Value), Size = UDim2.new(0, 30, 0, 25), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.Accent, TextSize = 13})
            local BarBg = Library:Create("Frame", {Parent = Container, Size = UDim2.new(1, -30, 0, 4), Position = UDim2.new(0, 15, 0, 35), BackgroundColor3 = Color3.fromRGB(60, 60, 65)}); Library:Create("UICorner", {Parent = BarBg, CornerRadius = UDim.new(1, 0)})
            local Fill = Library:Create("Frame", {Parent = BarBg, Size = UDim2.new((Value-Min)/(Max-Min), 0, 1, 0), BackgroundColor3 = UIConfig.Accent}); Library:Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
            local Trig = Library:Create("TextButton", {Parent = Container, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
            local function Move(Input) local P = math.clamp((Input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1); local V = math.floor(Min + ((Max - Min) * P)); Value = V; Val.Text = tostring(V); Library:Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05); if Callback then Callback(V) end end
            Trig.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Move(i); local c=Services.UserInput.InputChanged:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then Move(io) end end); local r; r=Services.UserInput.InputEnded:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then c:Disconnect(); r:Disconnect() end end) end end)
        end

        function PageFunctions:AddButton(Text, Callback)
            local Btn = Library:Create("TextButton", {Parent = Page, Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = UIConfig.Item, Text = "", AutoButtonColor = false})
            Library:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            Library:Create("TextLabel", {Parent = Btn, Text = Text, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextColor3 = UIConfig.Text, TextSize = 13})
            AddAnim(Btn)
            Btn.MouseButton1Click:Connect(function() if Callback then Callback() end end)
        end
        return PageFunctions
    end
    function WindowFunctions:ToggleWatermark(Bool) Card.Visible = Bool end
    return WindowFunctions
end

return Library
