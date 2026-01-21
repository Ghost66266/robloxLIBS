-- [[ 8.8.8.8 ELITE UI LIBRARY ]] --
-- [[ VERSION: 2.0.0 | TOTAL STABILITY & VISUALS ]] --

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {}

-- CONFIGURATION DU THÈME
local Theme = {
    Main = Color3.fromRGB(12, 12, 14),
    Section = Color3.fromRGB(20, 20, 24),
    Accent = Color3.fromRGB(170, 0, 255), -- VIOLET ÉLITE
    Outline = Color3.fromRGB(40, 40, 45),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- UTILITAIRES D'ANIMATION
local function Tween(obj, time, prop)
    TS:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), prop):Play()
end

-- [[ EFFET ONDE DE CHOC VIOLETTE (RIPPLE) ]] --
local function CreateRipple(obj)
    task.spawn(function()
        local Circle = Instance.new("ImageLabel")
        Circle.Name = "RippleEffect"
        Circle.Parent = obj
        Circle.BackgroundColor3 = Color3.new(1, 1, 1)
        Circle.BackgroundTransparency = 1
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Theme.Accent -- VIOLET FLASHY
        Circle.ImageTransparency = 0.2
        Circle.ZIndex = 15
        
        local RelX = Mouse.X - obj.AbsolutePosition.X
        local RelY = Mouse.Y - obj.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, RelX, 0, RelY)
        Circle.AnchorPoint = Vector2.new(0.5, 0.5)
        Circle.Size = UDim2.new(0, 0, 0, 0)
        
        local T = TS:Create(Circle, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5),
            ImageTransparency = 1
        })
        T:Play()
        T.Completed:Wait()
        Circle:Destroy()
    end)
end

-- [[ WELCOME SCREEN MODIFIABLE ]] --
function Library:CreateWelcomeScreen(customText)
    if CoreGui:FindFirstChild("8888_Welcome") then CoreGui["8888_Welcome"]:Destroy() end
    
    local WelcomeGui = Instance.new("ScreenGui", CoreGui)
    WelcomeGui.Name = "8888_Welcome"
    WelcomeGui.IgnoreGuiInset = true
    WelcomeGui.DisplayOrder = 100
    
    local Background = Instance.new("Frame", WelcomeGui)
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.new(0,0,0)
    Background.BackgroundTransparency = 1
    
    local TextLabel = Instance.new("TextLabel", WelcomeGui)
    TextLabel.Size = UDim2.new(1, 0, 0, 100)
    TextLabel.Position = UDim2.new(0, 0, 0.5, -50)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = customText or "8.8.8.8 <font color='#AA00FF'>VIRTUAL</font> INTERFACE"
    TextLabel.RichText = true
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 1
    TextLabel.TextTransparency = 1
    
    Tween(Background, 0.5, {BackgroundTransparency = 0.5})
    Tween(TextLabel, 1.2, {TextSize = 75, TextTransparency = 0})
    
    task.wait(3)
    
    Tween(TextLabel, 1, {TextSize = 100, TextTransparency = 1})
    Tween(Background, 1, {BackgroundTransparency = 1})
    Debris:AddItem(WelcomeGui, 1.2)
end

-- [[ FENÊTRE PRINCIPALE ]] --
function Library:CreateWindow(title)
    if CoreGui:FindFirstChild("8888_MainUI") then CoreGui["8888_MainUI"]:Destroy() end

    local UI = Instance.new("ScreenGui", CoreGui)
    UI.Name = "8888_MainUI"
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", UI)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, -275, 0.5, -200)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    
    -- Animation d'affichage
    Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(Main, 0.8, {Size = UDim2.new(0, 550, 0, 400)})

    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.Section
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "8.8.8.8 | UI"
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.RichText = true
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- CONTENEUR DE SECTIONS
    local Container = Instance.new("ScrollingFrame", Main)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -70)
    Container.Position = UDim2.new(0, 10, 0, 60)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.ScrollBarImageColor3 = Theme.Accent
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local List = Instance.new("UIListLayout", Container)
    List.Padding = UDim.new(0, 12)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local WindowActions = {}

    -- [[ AJOUTER SECTION ]] --
    function WindowActions:AddSection(sTitle)
        local SectionFrame = Instance.new("Frame", Container)
        SectionFrame.Name = sTitle .. "_Section"
        SectionFrame.Size = UDim2.new(0.96, 0, 0, 40)
        SectionFrame.BackgroundColor3 = Theme.Section
        SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 8)
        
        local SStroke = Instance.new("UIStroke", SectionFrame)
        SStroke.Color = Theme.Outline
        SStroke.Thickness = 1

        local STitle = Instance.new("TextLabel", SectionFrame)
        STitle.Size = UDim2.new(1, 0, 0, 30)
        STitle.Position = UDim2.new(0, 15, 0, 0)
        STitle.BackgroundTransparency = 1
        STitle.Text = sTitle:upper()
        STitle.TextColor3 = Theme.Accent
        STitle.Font = Enum.Font.GothamBold
        STitle.TextSize = 13
        STitle.TextXAlignment = Enum.TextXAlignment.Left

        local Elements = Instance.new("Frame", SectionFrame)
        Elements.Size = UDim2.new(1, 0, 1, 0)
        Elements.BackgroundTransparency = 1
        local EList = Instance.new("UIListLayout", Elements)
        EList.Padding = UDim.new(0, 8)
        EList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Instance.new("UIPadding", Elements).PaddingTop = UDim.new(0, 35)
        Instance.new("UIPadding", Elements).PaddingBottom = UDim.new(0, 10)

        local SectionActions = {}

        -- [[ BOUTON AVEC EFFETS ]] --
        function SectionActions:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Elements)
            Btn.Size = UDim2.new(0.94, 0, 0, 38)
            Btn.BackgroundColor3 = Theme.Main
            Btn.Text = "  " .. text
            Btn.TextColor3 = Theme.TextDark
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 14
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.ClipsDescendants = true
            Btn.AutoButtonColor = false
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            
            local BStroke = Instance.new("UIStroke", Btn)
            BStroke.Color = Theme.Outline

            Btn.MouseEnter:Connect(function()
                Tween(BStroke, 0.3, {Color = Theme.Accent})
                Tween(Btn, 0.3, {BackgroundColor3 = Color3.fromRGB(18, 18, 22)})
            end)
            
            Btn.MouseLeave:Connect(function()
                Tween(BStroke, 0.3, {Color = Theme.Outline})
                Tween(Btn, 0.3, {BackgroundColor3 = Theme.Main})
            end)

            Btn.MouseButton1Click:Connect(function()
                CreateRipple(Btn) -- L'ONDE VIOLETTE
                callback()
            end)
        end

        -- [[ SLIDER AVEC ANIMATION ]] --
        function SectionActions:AddSlider(text, min, max, default, callback)
            local Sld = Instance.new("Frame", Elements)
            Sld.Size = UDim2.new(0.94, 0, 0, 55)
            Sld.BackgroundTransparency = 1

            local Lab = Instance.new("TextLabel", Sld)
            Lab.Size = UDim2.new(1, 0, 0, 25)
            Lab.Text = "  " .. text .. " : " .. default
            Lab.TextColor3 = Theme.Text
            Lab.Font = "GothamMedium"
            Lab.TextSize = 13; Lab.BackgroundTransparency = 1; Lab.TextXAlignment = "Left"

            local Bar = Instance.new("Frame", Sld)
            Bar.Size = UDim2.new(1, -10, 0, 6); Bar.Position = UDim2.new(0, 5, 0, 35); Bar.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", Bar)

            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)

            local function Update()
                local p = math.clamp((UIS:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Tween(Fill, 0.1, {Size = UDim2.new(p, 0, 1, 0)})
                local v = math.floor(min + (max-min)*p)
                Lab.Text = "  " .. text .. " : " .. v; callback(v)
            end

            local active = false
            Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = true Update() end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
            UIS.InputChanged:Connect(function(i) if active and i.UserInputType == Enum.UserInputType.MouseMovement then Update() end end)
        end

        return SectionActions
    end
    return WindowActions
end

return Library
