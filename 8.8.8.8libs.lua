-- ======================================================================
-- VULCAN UI LIBRARY - RED EDITION
-- ======================================================================
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Protection pour Studio / Exécuteur
local TargetGui = (pcall(function() return CoreGui end) and CoreGui) or game.Players.LocalPlayer:WaitForChild("PlayerGui")

local VulcanUI = {}

-- Thème Vulcan (Rouge et Sombre)
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Sidebar = Color3.fromRGB(18, 18, 18),
    Accent = Color3.fromRGB(255, 0, 0), -- VULCAN RED
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(130, 130, 130),
    ElementBG = Color3.fromRGB(25, 25, 25),
    HoverBG = Color3.fromRGB(40, 20, 20) -- Rouge très sombre pour le survol
}

-- Fonctions utilitaires
local function Tween(instance, properties, duration, style)
    style = style or Enum.EasingStyle.Quint
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- ======================================================================
-- 1. ÉCRAN DE CHARGEMENT ANIMÉ (FULL SCREEN)
-- ======================================================================
function VulcanUI:ShowLoading(textString)
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "VulcanLoader"
    LoadingGui.IgnoreGuiInset = true -- TRÈS IMPORTANT : Prend TOUT l'écran, même la barre du haut
    LoadingGui.ResetOnSpawn = false
    LoadingGui.Parent = TargetGui

    local Background = Instance.new("Frame")
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Presque noir absolu
    Background.BorderSizePixel = 0
    Background.Parent = LoadingGui

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, 0, 0, 100)
    LoadingText.Position = UDim2.new(0, 0, 0.5, -50)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = ""
    LoadingText.TextColor3 = Theme.Accent
    LoadingText.Font = Enum.Font.GothamBlack
    LoadingText.TextSize = 50
    LoadingText.Parent = Background

    -- Animation lettre par lettre
    local displayedText = ""
    for i = 1, #textString do
        displayedText = displayedText .. string.sub(textString, i, i)
        LoadingText.Text = displayedText
        
        LoadingText.TextSize = 65
        Tween(LoadingText, {TextSize = 55}, 0.2)
        task.wait(0.15)
    end

    task.wait(0.6) -- Pause quand le mot est fini

    -- Fade Out
    local fadeBg = Tween(Background, {BackgroundTransparency = 1}, 0.5)
    local fadeTxt = Tween(LoadingText, {TextTransparency = 1}, 0.5)
    
    fadeBg.Completed:Wait() -- Attend que l'animation finisse
    LoadingGui:Destroy()
end

-- ======================================================================
-- 2. SYSTÈME DE NOTIFICATIONS
-- ======================================================================
function VulcanUI:Notify(message)
    local NotifGui = TargetGui:FindFirstChild("VulcanNotifGui")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "VulcanNotifGui"
        NotifGui.ResetOnSpawn = false
        NotifGui.Parent = TargetGui
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 260, 0, 60)
    NotifFrame.Position = UDim2.new(1, 20, 1, -80) -- Caché à droite
    NotifFrame.BackgroundColor3 = Theme.Sidebar
    NotifFrame.Parent = NotifGui
    AddCorner(NotifFrame, 6)
    AddStroke(NotifFrame, Theme.Accent, 1) -- Contour rouge

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -20, 1, -10)
    TextLabel.Position = UDim2.new(0, 10, 0, 5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = message
    TextLabel.TextColor3 = Theme.Text
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = NotifFrame

    -- Animation d'entrée
    Tween(NotifFrame, {Position = UDim2.new(1, -280, 1, -80)}, 0.4)

    -- Disparition auto
    spawn(function()
        task.wait(4)
        local exit = Tween(NotifFrame, {Position = UDim2.new(1, 20, 1, -80), BackgroundTransparency = 1}, 0.4)
        Tween(TextLabel, {TextTransparency = 1}, 0.4)
        Tween(NotifFrame.UIStroke, {Transparency = 1}, 0.4)
        exit.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

-- ======================================================================
-- 3. CRÉATION DU MENU (WINDOW)
-- ======================================================================
function VulcanUI:CreateWindow(Config)
    local TitleText = Config.Name or "Vulcan"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VulcanMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = TargetGui

    -- Ombre 3D
    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(0, 640, 0, 440)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 1
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.Parent = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = Shadow
    AddCorner(MainFrame, 6)
    AddStroke(MainFrame, Theme.Accent, 2) -- Contour Néon Rouge Épais

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Text = TitleText
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18
    Title.TextColor3 = Theme.Accent
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabContainer

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -140, 1, 0)
    PageContainer.Position = UDim2.new(0, 140, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Animation d'ouverture
    MainFrame.Size = UDim2.new(0, 500, 0, 300)
    Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.5)
    Tween(Shadow, {ImageTransparency = 0.4}, 0.5)

    -- Système de Drag
    local dragging, dragInput, dragStart, startPos
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Shadow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local WindowObj = { CurrentTab = nil }
    
    -- ======================================================================
    -- 4. CRÉATION DES ONGLETS ET BOUTONS
    -- ======================================================================
    function WindowObj:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0.9, 0, 0, 35)
        TabButton.BackgroundColor3 = Theme.Sidebar
        TabButton.Text = TabName
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextColor3 = Theme.TextDim
        TabButton.TextSize = 13
        TabButton.Parent = TabContainer
        AddCorner(TabButton, 6)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        TabButton.MouseButton1Click:Connect(function()
            if WindowObj.CurrentTab then WindowObj.CurrentTab.Visible = false end
            WindowObj.CurrentTab = Page
            Page.Visible = true
            
            Page.Position = UDim2.new(0, 10, 0, 20)
            Tween(Page, {Position = UDim2.new(0, 10, 0, 10)}, 0.3)

            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextDim}, 0.2)
                end
            end
            Tween(TabButton, {BackgroundColor3 = Theme.HoverBG, TextColor3 = Theme.Accent}, 0.2)
        end)

        if not WindowObj.CurrentTab then
            TabButton.MouseButton1Click:Fire()
        end

        local Elements = {}

        function Elements:CreateButton(btnText, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 38)
            Button.BackgroundColor3 = Theme.ElementBG
            Button.Text = btnText
            Button.Font = Enum.Font.GothamBold
            Button.TextColor3 = Theme.Text
            Button.TextSize = 14
            Button.AutoButtonColor = false
            Button.Parent = Page
            AddCorner(Button, 6)
            local Stroke = AddStroke(Button, Theme.Background, 1)

            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.HoverBG}, 0.2)
                Tween(Stroke, {Color = Theme.Accent}, 0.2)
            end)
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementBG}, 0.2)
                Tween(Stroke, {Color = Theme.Background}, 0.2)
            end)

            Button.MouseButton1Click:Connect(function()
                callback()
            end)
        end

        function Elements:CreateToggle(tglText, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
            ToggleFrame.BackgroundColor3 = Theme.ElementBG
            ToggleFrame.Parent = Page
            AddCorner(ToggleFrame, 6)
            
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Text = tglText
            ToggleText.Size = UDim2.new(1, -60, 1, 0)
            ToggleText.Position = UDim2.new(0, 10, 0, 0)
            ToggleText.Font = Enum.Font.GothamBold
            ToggleText.TextColor3 = Theme.Text
            ToggleText.TextSize = 14
            ToggleText.BackgroundTransparency = 1
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = ToggleFrame

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
            ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleBtn.BackgroundColor3 = Theme.Background
            ToggleBtn.Text = ""
            ToggleBtn.Parent = ToggleFrame
            AddCorner(ToggleBtn, 10)
            AddStroke(ToggleBtn, Theme.TextDim, 1)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Theme.TextDim
            Circle.Parent = ToggleBtn
            AddCorner(Circle, 8)

            local enabled = false
            ToggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                if enabled then
                    Tween(Circle, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Accent}, 0.3)
                    Tween(ToggleBtn.UIStroke, {Color = Theme.Accent}, 0.3)
                else
                    Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim}, 0.3)
                    Tween(ToggleBtn.UIStroke, {Color = Theme.TextDim}, 0.3)
                end
                callback(enabled)
            end)
        end

        return Elements
    end

    return WindowObj
end

return VulcanUI
