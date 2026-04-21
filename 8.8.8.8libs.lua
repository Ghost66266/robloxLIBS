-- ======================================================================
-- FUTUR UI LIBRARY - FIVEM STYLE (CORE ENGINE)
-- ======================================================================
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local FuturUI = {}

-- Styles et Couleurs par défaut (Thème Cyber/FiveM)
local Theme = {
    Background = Color3.fromRGB(15, 15, 20), -- Sombre translucide
    Sidebar = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(120, 50, 255), -- Violet Néon (Style TZX)
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    ElementBG = Color3.fromRGB(30, 30, 35),
    HoverBG = Color3.fromRGB(45, 45, 55)
}

-- Fonction utilitaire pour les animations fluides
local function Tween(instance, properties, duration, style)
    style = style or Enum.EasingStyle.Quint
    local tweenInfo = TweenInfo.new(duration, style, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Fonction pour créer des coins arrondis
local function AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

-- Fonction pour créer un contour Néon (Effet 3D/Futuriste)
local function AddStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- ======================================================================
-- CREATION DE LA FENETRE PRINCIPALE
-- ======================================================================
function FuturUI:CreateWindow(Config)
    local TitleText = Config.Name or "Futur Menu"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FuturUI_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    -- Le DropShadow (Effet 3D derrière la fenêtre)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "DropShadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(0, 640, 0, 440)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceScale = 1
    Shadow.Parent = ScreenGui

    -- Main Frame (La fenêtre principale)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = 0.1 -- Effet verre
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = Shadow
    AddCorner(MainFrame, 8)
    AddStroke(MainFrame, Theme.Accent, 1.5) -- Contour Néon

    -- Sidebar (Menu de gauche)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
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

    -- Conteneur des pages
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -150, 1, 0)
    PageContainer.Position = UDim2.new(0, 150, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Animation d'ouverture (Effet Pop 3D)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Rotation = -2
    Shadow.ImageTransparency = 1
    
    Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400), Rotation = 0}, 0.6, Enum.EasingStyle.Exponential)
    Tween(Shadow, {ImageTransparency = 0.5}, 0.6)

    -- Système de Drag (Déplacement propre)
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

    -- Objet Window retourné pour créer les onglets
    local Window = {
        CurrentTab = nil
    }
    
    -- ======================================================================
    -- CREATION DES ONGLETS (TABS)
    -- ======================================================================
    function Window:CreateTab(TabName)
        -- Le bouton dans la Sidebar
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0.9, 0, 0, 35)
        TabButton.BackgroundColor3 = Theme.Sidebar
        TabButton.Text = TabName
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextColor3 = Theme.TextDim
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        AddCorner(TabButton, 6)
        
        -- La page contenant les éléments
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page

        -- Animation Hover sur le bouton Tab
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Page then
                Tween(TabButton, {TextColor3 = Theme.Text}, 0.2)
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Page then
                Tween(TabButton, {TextColor3 = Theme.TextDim}, 0.2)
            end
        end)

        -- Logique de clic sur l'onglet
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then Window.CurrentTab.Visible = false end
            Window.CurrentTab = Page
            Page.Visible = true
            
            -- Animation de transition de la page (Glissement vers le bas + Fade)
            Page.Position = UDim2.new(0, 10, 0, 20)
            Page.CanvasPosition = Vector2.new(0,0)
            Tween(Page, {Position = UDim2.new(0, 10, 0, 10)}, 0.4, Enum.EasingStyle.Quart)

            -- Reset couleurs des autres tabs
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextDim}, 0.2)
                end
            end
            Tween(TabButton, {BackgroundColor3 = Theme.HoverBG, TextColor3 = Theme.Accent}, 0.3)
        end)

        -- Auto-sélection du premier tab
        if not Window.CurrentTab then
            TabButton.MouseButton1Click:Wait() -- Petite astuce pour cliquer automatiquement le premier
            TabButton.MouseButton1Click:Fire()
        end

        local TabElements = {}

        -- ======================================================================
        -- ELEMENTS UI : BOUTON (Avec effet 3D Pop)
        -- ======================================================================
        function TabElements:CreateButton(btnText, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 40)
            Button.BackgroundColor3 = Theme.ElementBG
            Button.Text = btnText
            Button.Font = Enum.Font.GothamBold
            Button.TextColor3 = Theme.Text
            Button.TextSize = 14
            Button.AutoButtonColor = false
            Button.Parent = Page
            AddCorner(Button, 6)
            local Stroke = AddStroke(Button, Theme.Background, 1)

            -- Effet 3D Hover
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.HoverBG}, 0.2)
                Tween(Stroke, {Color = Theme.Accent}, 0.2)
                Tween(Button.UIScale or Instance.new("UIScale", Button), {Scale = 1.02}, 0.2) -- Pop effect
            end)
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundColor3 = Theme.ElementBG}, 0.2)
                Tween(Stroke, {Color = Theme.Background}, 0.2)
                if Button:FindFirstChild("UIScale") then
                    Tween(Button.UIScale, {Scale = 1}, 0.2)
                end
            end)

            Button.MouseButton1Click:Connect(function()
                -- Effet de clic
                local scale = Button:FindFirstChild("UIScale") or Instance.new("UIScale", Button)
                scale.Scale = 0.95
                Tween(scale, {Scale = 1.02}, 0.3, Enum.EasingStyle.Elastic)
                pcall(callback)
            end)
        end

        -- ======================================================================
        -- ELEMENTS UI : TOGGLE
        -- ======================================================================
        function TabElements:CreateToggle(tglText, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
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

            -- Le bouton physique du toggle
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
            ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleBtn.BackgroundColor3 = Theme.Background
            ToggleBtn.Text = ""
            ToggleBtn.Parent = ToggleFrame
            AddCorner(ToggleBtn, 10)
            AddStroke(ToggleBtn, Theme.TextDim, 1)

            -- Le cercle à l'intérieur
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
                pcall(callback, enabled)
            end)
        end

        return TabElements
    end

    return Window
end

return FuturUI
