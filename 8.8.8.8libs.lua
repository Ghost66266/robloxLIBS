local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}

-- THEME "NEVER-VIOLET" (Style sombre propre avec accent violet)
local Theme = {
    Main        = Color3.fromRGB(20, 20, 20),       -- Fond principal
    Sidebar     = Color3.fromRGB(15, 15, 15),       -- Barre latérale
    Section     = Color3.fromRGB(28, 28, 28),       -- Fond des boites de section
    Accent      = Color3.fromRGB(170, 0, 255),      -- Ton Violet
    Text        = Color3.fromRGB(255, 255, 255),
    TextDark    = Color3.fromRGB(170, 170, 170),
    Outline     = Color3.fromRGB(50, 50, 50),
    ToggleOff   = Color3.fromRGB(40, 40, 40)
}

-- [ UTILITAIRES ] --
local function GetTextSize(text, font, size)
    return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(10000, 10000))
end

local function CreateRipple(obj)
    obj.ClipsDescendants = true
    task.spawn(function()
        local Mouse = Players.LocalPlayer:GetMouse()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.Image = "rbxassetid://266543268"
        Ripple.ImageColor3 = Theme.Accent
        Ripple.ImageTransparency = 0.6
        Ripple.ZIndex = 9
        local CenterX, CenterY = obj.AbsolutePosition.X + obj.AbsoluteSize.X/2, obj.AbsolutePosition.Y + obj.AbsoluteSize.Y/2
        Ripple.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local Tween = TS:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3, 0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3),
            ImageTransparency = 1
        })
        Tween:Play()
        Tween.Completed:Wait()
        Ripple:Destroy()
    end)
end

-- [ ANIMATION DE BIENVENUE ] --
function Library:Welcome(TitleText, SubText)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "Intro"
    Screen.IgnoreGuiInset = true
    Screen.DisplayOrder = 10000

    local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    Blur.Size = 0

    local MainFrame = Instance.new("Frame", Screen)
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.new(0,0,0)
    MainFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", MainFrame)
    Label.Size = UDim2.new(1, 0, 0, 150)
    Label.Position = UDim2.new(0, 0, 0.4, 0)
    Label.BackgroundTransparency = 1
    Label.Text = TitleText or "LIBRARY"
    Label.TextColor3 = Theme.Accent
    Label.Font = Enum.Font.GothamBlack
    Label.TextSize = 80
    Label.TextTransparency = 1
    
    local Sub = Instance.new("TextLabel", MainFrame)
    Sub.Size = UDim2.new(1, 0, 0, 50)
    Sub.Position = UDim2.new(0, 0, 0.55, 0)
    Sub.BackgroundTransparency = 1
    Sub.Text = SubText or "LOADING..."
    Sub.TextColor3 = Theme.Text
    Sub.Font = Enum.Font.GothamBold
    Sub.TextSize = 25
    Sub.TextTransparency = 1

    TS:Create(Blur, TweenInfo.new(1), {Size = 24}):Play()
    TS:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.3)
    TS:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Back), {TextTransparency = 0, Position = UDim2.new(0,0,0.45,0)}):Play()
    task.wait(0.2)
    TS:Create(Sub, TweenInfo.new(1, Enum.EasingStyle.Back), {TextTransparency = 0, Position = UDim2.new(0,0,0.58,0)}):Play()
    
    task.wait(2.5)
    
    TS:Create(Label, TweenInfo.new(0.5), {TextTransparency = 1, Position = UDim2.new(0,0,0.4,0)}):Play()
    TS:Create(Sub, TweenInfo.new(0.5), {TextTransparency = 1, Position = UDim2.new(0,0,0.65,0)}):Play()
    TS:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TS:Create(Blur, TweenInfo.new(0.5), {Size = 0}):Play()
    task.wait(0.5)
    Screen:Destroy()
    Blur:Destroy()
end

-- [ FENÊTRE PRINCIPALE ] --
function Library:CreateWindow(Settings)
    if CoreGui:FindFirstChild(Settings.Name) then CoreGui[Settings.Name]:Destroy() end
    
    local UI = Instance.new("ScreenGui", CoreGui)
    UI.Name = Settings.Name
    UI.DisplayOrder = 100

    local Main = Instance.new("Frame", UI)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 700, 0, 450)
    Main.Position = UDim2.new(0.5, -350, 0.5, -225)
    Main.BackgroundColor3 = Theme.Main
    Main.ClipsDescendants = true
    
    -- Coins arrondis
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    -- Bordure subtile
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Theme.Outline
    Stroke.Thickness = 1

    -- Sidebar (Gauche)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    
    local SidebarTitle = Instance.new("TextLabel", Sidebar)
    SidebarTitle.Size = UDim2.new(1, -20, 0, 60)
    SidebarTitle.Position = UDim2.new(0, 20, 0, 0)
    SidebarTitle.Text = string.upper(Settings.Name)
    SidebarTitle.Font = Enum.Font.GothamBlack
    SidebarTitle.TextSize = 24
    SidebarTitle.TextColor3 = Theme.Text
    SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
    SidebarTitle.BackgroundTransparency = 1
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    -- Contenu des pages (Droite)
    local Pages = Instance.new("Frame", Main)
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -190, 1, -20)
    Pages.Position = UDim2.new(0, 190, 0, 10)
    Pages.BackgroundTransparency = 1

    -- Drag System
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Sidebar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- [ GESTION DES ONGLETS (TABS) ] --
    local WindowFunctions = {}
    local FirstTab = true

    function WindowFunctions:AddTab(TabName, IconId)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        
        local Title = Instance.new("TextLabel", TabButton)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Position = UDim2.new(0, 50, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = TabName
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextColor3 = Theme.TextDark
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Indicateur actif (Barre verticale à gauche)
        local Indicator = Instance.new("Frame", TabButton)
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.Transparency = 1
        
        -- Icône (Optionnelle)
        if IconId then
            local Icon = Instance.new("ImageLabel", TabButton)
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(0, 20, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://" .. IconId
            Icon.ImageColor3 = Theme.TextDark
        end

        -- La Page associée à l'onglet
        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Name = TabName
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        
        -- Layout en Grille pour les Sections (Comme sur l'image)
        local Grid = Instance.new("UIGridLayout", Page)
        Grid.CellSize = UDim2.new(0.48, 0, 0, 0) -- Largeur auto via script plus tard si besoin
        Grid.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
        Grid.SortOrder = Enum.SortOrder.LayoutOrder

        -- Animation Changement d'onglet
        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TS:Create(v.TextLabel, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play()
                    TS:Create(v.Frame, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    if v:FindFirstChild("ImageLabel") then TS:Create(v.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Theme.TextDark}):Play() end
                end
            end
            for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
            
            Page.Visible = true
            TS:Create(Title, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play()
            TS:Create(Indicator, TweenInfo.new(0.3), {Transparency = 0}):Play()
            if TabButton:FindFirstChild("ImageLabel") then TS:Create(TabButton.ImageLabel, TweenInfo.new(0.3), {ImageColor3 = Theme.Text}):Play() end
        end)

        if FirstTab then
            Page.Visible = true
            Title.TextColor3 = Theme.Text
            Indicator.Transparency = 0
            if TabButton:FindFirstChild("ImageLabel") then TabButton.ImageLabel.ImageColor3 = Theme.Text end
            FirstTab = false
        end

        -- [ GESTION DES SECTIONS ] --
        local TabFunctions = {}
        
        function TabFunctions:AddSection(SectionName)
            local SectionFrame = Instance.new("Frame", Page)
            SectionFrame.BackgroundColor3 = Theme.Section
            SectionFrame.Size = UDim2.new(0.48, 0, 0, 200) -- Hauteur sera auto
            Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 6)
            
            local Header = Instance.new("TextLabel", SectionFrame)
            Header.Size = UDim2.new(1, -20, 0, 30)
            Header.Position = UDim2.new(0, 10, 0, 5)
            Header.BackgroundTransparency = 1
            Header.Text = SectionName
            Header.Font = Enum.Font.GothamBold
            Header.TextSize = 13
            Header.TextColor3 = Theme.Text
            Header.TextXAlignment = Enum.TextXAlignment.Left

            local Line = Instance.new("Frame", SectionFrame)
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0, 35)
            Line.BackgroundColor3 = Theme.Outline
            Line.BorderSizePixel = 0
            
            local Container = Instance.new("Frame", SectionFrame)
            Container.Size = UDim2.new(1, -20, 1, -40)
            Container.Position = UDim2.new(0, 10, 0, 40)
            Container.BackgroundTransparency = 1
            
            local List = Instance.new("UIListLayout", Container)
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Padding = UDim.new(0, 6)
            
            -- Redimensionnement auto de la section
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(0.48, 0, 0, List.AbsoluteContentSize.Y + 50)
                -- Ajuster la hauteur de la page si besoin (Scroll)
                local contentHeight = 0
                for _, c in pairs(Page:GetChildren()) do
                    if c:IsA("Frame") then contentHeight = math.max(contentHeight, c.AbsolutePosition.Y + c.AbsoluteSize.Y - Page.AbsolutePosition.Y) end
                end
                Page.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
            end)

            local SectionFunctions = {}

            -- [ TOGGLE ] --
            function SectionFunctions:AddToggle(Text, Default, Callback)
                local ToggleFrame = Instance.new("TextButton", Container)
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Text = ""
                ToggleFrame.AutoButtonColor = false

                local Label = Instance.new("TextLabel", ToggleFrame)
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = Text
                Label.TextColor3 = Theme.TextDark
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                
                -- Switch Background
                local Switch = Instance.new("Frame", ToggleFrame)
                Switch.Size = UDim2.new(0, 36, 0, 18)
                Switch.Position = UDim2.new(1, -36, 0.5, -9)
                Switch.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
                
                -- Switch Circle
                local Circle = Instance.new("Frame", Switch)
                Circle.Size = UDim2.new(0, 14, 0, 14)
                Circle.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                Circle.BackgroundColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

                local Enabled = Default
                ToggleFrame.MouseButton1Click:Connect(function()
                    Enabled = not Enabled
                    
                    TS:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Enabled and Theme.Accent or Theme.ToggleOff}):Play()
                    TS:Create(Circle, TweenInfo.new(0.2), {Position = Enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    TS:Create(Label, TweenInfo.new(0.2), {TextColor3 = Enabled and Theme.Text or Theme.TextDark}):Play()
                    
                    pcall(Callback, Enabled)
                end)
            end

            -- [ BUTTON ] --
            function SectionFunctions:AddButton(Text, Callback)
                local Btn = Instance.new("TextButton", Container)
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Theme.Main
                Btn.Text = Text
                Btn.TextColor3 = Theme.Text
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 12
                Btn.AutoButtonColor = false
                Btn.ClipsDescendants = true
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", Btn).Color = Theme.Outline

                Btn.MouseEnter:Connect(function() TS:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play() end)
                Btn.MouseLeave:Connect(function() TS:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Main}):Play() end)
                
                Btn.MouseButton1Click:Connect(function()
                    CreateRipple(Btn)
                    pcall(Callback)
                end)
            end

            -- [ SLIDER ] --
            function SectionFunctions:AddSlider(Text, Min, Max, Default, Callback)
                local SliderFrame = Instance.new("Frame", Container)
                SliderFrame.Size = UDim2.new(1, 0, 0, 45)
                SliderFrame.BackgroundTransparency = 1
                
                local Label = Instance.new("TextLabel", SliderFrame)
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.Text = Text
                Label.TextColor3 = Theme.TextDark
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                
                local ValueLabel = Instance.new("TextLabel", SliderFrame)
                ValueLabel.Size = UDim2.new(1, 0, 0, 20)
                ValueLabel.Text = tostring(Default)
                ValueLabel.TextColor3 = Theme.Text
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 13
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.BackgroundTransparency = 1
                
                local Bar = Instance.new("Frame", SliderFrame)
                Bar.Size = UDim2.new(1, 0, 0, 4)
                Bar.Position = UDim2.new(0, 0, 0, 30)
                Bar.BackgroundColor3 = Theme.Outline
                Instance.new("UICorner", Bar)
                
                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Instance.new("UICorner", Fill)

                local Sliding = false
                
                local function Update(Input)
                    local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    TS:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
                    local Value = math.floor(Min + ((Max - Min) * SizeX))
                    ValueLabel.Text = tostring(Value)
                    pcall(Callback, Value)
                end
                
                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = true
                        Update(input)
                    end
                end)
                
                UIS.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then
                        Update(input)
                    end
                end)
                
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = false
                    end
                end)
            end

            return SectionFunctions -- Retourne les fonctions pour la Section
        end
        return TabFunctions -- Retourne les fonctions pour l'Onglet
    end
    return WindowFunctions -- Retourne les fonctions pour la Fenêtre
end

return Library
