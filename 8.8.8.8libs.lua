-- [[ 8.8.8.8 WIND-UI LIBRARY ]] --
-- [[ VERSION: V20 ARCHITECT | AUTHOR: GHOST66266 ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {}
Library.Windows = {}

-- [ REMPLACE TOUTE LA FONCTION Library:Welcome PAR CELLE-CI ] --
function Library:Welcome(TitleText, SubText)
    -- 1. Nettoyage si une intro existe déjà
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "8888_Intro" then v:Destroy() end end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "8888_Intro"
    Screen.IgnoreGuiInset = true
    Screen.DisplayOrder = 10000 -- FORCE LE PREMIER PLAN (DEVANT TOUT)
    ProtectGui(Screen)

    local Blur = Instance.new("BlurEffect", Lighting); Blur.Size = 0
    local BackFrame = Instance.new("Frame", Screen); BackFrame.Size = UDim2.new(1,0,1,0); BackFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); BackFrame.BackgroundTransparency = 1; BackFrame.ZIndex = 1
    
    local MainLabel = Instance.new("TextLabel", Screen); MainLabel.Size = UDim2.new(1,0,0,150); MainLabel.Position = UDim2.new(0,0,0.4,0); MainLabel.BackgroundTransparency = 1
    MainLabel.Text = string.upper(TitleText or "LIBRARY"); MainLabel.TextColor3 = Library.Theme.Accent; MainLabel.Font = Enum.Font.GothamBlack; MainLabel.TextSize = 0; MainLabel.TextTransparency = 1; MainLabel.ZIndex = 2
    
    local SubLabel = Instance.new("TextLabel", Screen); SubLabel.Size = UDim2.new(1,0,0,50); SubLabel.Position = UDim2.new(0,0,0.55,0); SubLabel.BackgroundTransparency = 1
    SubLabel.Text = string.upper(SubText or "INITIALIZING..."); SubLabel.TextColor3 = Library.Theme.Text; SubLabel.Font = Enum.Font.GothamBold; SubLabel.TextSize = 20; SubLabel.TextTransparency = 1; SubLabel.ZIndex = 2

    -- 2. ANIMATION SÉQUENTIELLE (SANS task.spawn pour bloquer le script)
    Tween(Blur, {Size = 24}, 1)
    Tween(BackFrame, {BackgroundTransparency = 0.1}, 0.5)
    task.wait(0.5)
    
    local T1 = TweenService:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 90, TextTransparency = 0})
    T1:Play()
    task.wait(0.3)
    
    SubLabel.Position = UDim2.new(0,0,0.60,0)
    local T2 = TweenService:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0.55,0), TextTransparency = 0})
    T2:Play()

    task.wait(2.5) -- LE SCRIPT ATTEND ICI

    -- Sortie
    Tween(MainLabel, {TextSize = 0, TextTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(SubLabel, {TextTransparency = 1}, 0.5)
    task.wait(0.2)
    Tween(BackFrame, {BackgroundTransparency = 1}, 0.5)
    Tween(Blur, {Size = 0}, 0.8)
    
    task.wait(0.8)
    Screen:Destroy()
    Blur:Destroy()
    
    -- MAINTENANT LE MENU PEUT S'OUVRIR
end

-- [ 1. CONFIGURATION & THEME ] --
Library.Theme = {
    Main        = Color3.fromRGB(20, 20, 25),       -- Fond Principal
    Sidebar     = Color3.fromRGB(15, 15, 20),       -- Barre Latérale
    Section     = Color3.fromRGB(28, 28, 32),       -- Fond des Sections
    Accent      = Color3.fromRGB(120, 90, 255),     -- Violet Wind
    Text        = Color3.fromRGB(240, 240, 240),    -- Texte Clair
    TextDark    = Color3.fromRGB(140, 140, 150),    -- Texte Sombre
    Outline     = Color3.fromRGB(45, 45, 55),       -- Bordures
    Hover       = Color3.fromRGB(35, 35, 40),       -- Effet Survol
    Input       = Color3.fromRGB(15, 15, 20)        -- Fond Inputs
}

-- [ 2. UTILITAIRES INTERNES ] --

-- Fonction de Tween Rapide
local function Tween(Obj, Props, Time, Style, Dir)
    if not Obj then return end
    local Info = TweenInfo.new(Time or 0.2, Style or Enum.EasingStyle.Quad, Dir or Enum.EasingDirection.Out)
    local T = TweenService:Create(Obj, Info, Props)
    T:Play()
    return T
end

-- Effet "Ripple" (Onde de choc)
local function CreateRipple(Obj)
    if not Obj then return end
    Obj.ClipsDescendants = true
    task.spawn(function()
        local Mouse = Players.LocalPlayer:GetMouse()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = Obj
        Ripple.BackgroundTransparency = 1
        Ripple.Image = "rbxassetid://266543268"
        Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.ImageTransparency = 0.8
        Ripple.ZIndex = 9
        
        local RelativeX = Mouse.X - Obj.AbsolutePosition.X
        local RelativeY = Mouse.Y - Obj.AbsolutePosition.Y
        Ripple.Position = UDim2.new(0, RelativeX, 0, RelativeY)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local T = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 3, 0, math.max(Obj.AbsoluteSize.X, Obj.AbsoluteSize.Y) * 3),
            ImageTransparency = 1
        })
        T:Play()
        T.Completed:Wait()
        Ripple:Destroy()
    end)
end

-- Système de Drag (Déplacement fluide)
local function MakeDraggable(DragPoint, MainFrame)
    local Dragging, DragInput, DragStart, StartPos
    
    DragPoint.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)
    
    DragPoint.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            -- Interpolation pour fluidité
            local TargetPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = TargetPos}):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
end

-- Protection GUI
local function ProtectGui(Gui)
    if syn and syn.protect_gui then
        syn.protect_gui(Gui)
        Gui.Parent = CoreGui
    elseif gethui then
        Gui.Parent = gethui()
    else
        Gui.Parent = CoreGui
    end
end

-- [ 3. CONSTRUCTEUR DE FENÊTRE ] --
function Library:CreateWindow(Config)
    local WindowName = Config.Title or "WindUI"
    local Size = Config.Size or UDim2.new(0, 650, 0, 400)
    
    -- Nettoyage ancien
    for _, ui in pairs(CoreGui:GetChildren()) do
        if ui.Name == "WindUI_" .. WindowName then ui:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WindUI_" .. WindowName
    ScreenGui.IgnoreGuiInset = true
    ProtectGui(ScreenGui)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 0, 0, 0) -- Animation d'ouverture
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Library.Theme.Main
    Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Library.Theme.Outline
    Stroke.Thickness = 1
    
    -- Animation Ouverture
    Tween(Main, {Size = Size}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    -- Sidebar (Gauche)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Library.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
    
    -- Fix Sidebar Corner (Pour qu'elle soit carrée à droite)
    local SidebarFix = Instance.new("Frame", Sidebar)
    SidebarFix.BorderSizePixel = 0
    SidebarFix.BackgroundColor3 = Library.Theme.Sidebar
    SidebarFix.Size = UDim2.new(0, 10, 1, 0)
    SidebarFix.Position = UDim2.new(1, -10, 0, 0)
    SidebarFix.ZIndex = 0

    -- Titre
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, -20, 0, 50)
    Title.Position = UDim2.new(0, 20, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "<b>" .. string.upper(WindowName) .. "</b>"
    Title.RichText = true
    Title.TextColor3 = Library.Theme.Text
    Title.Font = Enum.Font.GothamMedium
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 70)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    
    -- Zone de Contenu (Droite)
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -180, 1, 0)
    Content.Position = UDim2.new(0, 180, 0, 0)
    Content.BackgroundTransparency = 1
    
    local ContentPad = Instance.new("UIPadding", Content)
    ContentPad.PaddingTop = UDim.new(0, 20)
    ContentPad.PaddingLeft = UDim.new(0, 20)
    ContentPad.PaddingRight = UDim.new(0, 20)
    ContentPad.PaddingBottom = UDim.new(0, 20)

    -- Drag & Toggle Key
    MakeDraggable(Sidebar, Main)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then -- TOUCHE PAR DÉFAUT
            Main.Visible = not Main.Visible
        end
    end)

    -- [ GESTION DES ONGLETS ] --
    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:AddTab(Name, Icon)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        
        local Indicator = Instance.new("Frame", TabBtn)
        Indicator.Size = UDim2.new(0, 4, 0.6, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.BackgroundColor3 = Library.Theme.Accent
        Indicator.Transparency = 1
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)
        
        local TabLabel = Instance.new("TextLabel", TabBtn)
        TabLabel.Size = UDim2.new(1, -30, 1, 0)
        TabLabel.Position = UDim2.new(0, 25, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = Name
        TabLabel.TextColor3 = Library.Theme.TextDark
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Page = Instance.new("ScrollingFrame", Content)
        Page.Name = Name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.Accent
        Page.Visible = false
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 10)
        
        -- Auto Resize Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            -- Reset others
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn.TextLabel, {TextColor3 = Library.Theme.TextDark})
                    Tween(btn.Frame, {Transparency = 1})
                end
            end
            for _, p in pairs(Content:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            
            -- Active current
            Page.Visible = true
            Tween(TabLabel, {TextColor3 = Library.Theme.Text})
            Tween(Indicator, {Transparency = 0})
        end)

        if FirstTab then
            Page.Visible = true
            TabLabel.TextColor3 = Library.Theme.Text
            Indicator.Transparency = 0
            FirstTab = false
		end

        -- [ GESTION DES ELEMENTS ] --
        local TabFuncs = {}

        function TabFuncs:AddSection(Title)
            local Section = Instance.new("Frame", Page)
            Section.BackgroundColor3 = Library.Theme.Section
            Section.Size = UDim2.new(1, 0, 0, 30) -- Height auto adjusted
            Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
            Instance.new("UIStroke", Section).Color = Library.Theme.Outline
            
            local SecTitle = Instance.new("TextLabel", Section)
            SecTitle.Size = UDim2.new(1, -20, 0, 30)
            SecTitle.Position = UDim2.new(0, 10, 0, 0)
            SecTitle.BackgroundTransparency = 1
            SecTitle.Text = Title
            SecTitle.TextColor3 = Library.Theme.TextDark
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 11
            SecTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local Container = Instance.new("Frame", Section)
            Container.Size = UDim2.new(1, -20, 0, 0)
            Container.Position = UDim2.new(0, 10, 0, 30)
            Container.BackgroundTransparency = 1
            
            local List = Instance.new("UIListLayout", Container)
            List.Padding = UDim.new(0, 6)
            
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -20, 0, List.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 40)
            end)

            local SecFuncs = {}

            -- BUTTON
            function SecFuncs:AddButton(Text, Callback)
                local Btn = Instance.new("TextButton", Container)
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Library.Theme.Main
                Btn.Text = Text
                Btn.TextColor3 = Library.Theme.Text
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 12
                Btn.AutoButtonColor = false
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", Btn).Color = Library.Theme.Outline
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.Hover}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.Main}) end)
                Btn.MouseButton1Click:Connect(function()
                    CreateRipple(Btn)
                    pcall(Callback)
                end)
            end

            -- TOGGLE
            function SecFuncs:AddToggle(Text, Default, Callback)
                local Tgl = Instance.new("TextButton", Container)
                Tgl.Size = UDim2.new(1, 0, 0, 32)
                Tgl.BackgroundTransparency = 1
                Tgl.Text = ""
                
                local Lab = Instance.new("TextLabel", Tgl)
                Lab.Size = UDim2.new(1, -50, 1, 0)
                Lab.BackgroundTransparency = 1
                Lab.Text = Text
                Lab.TextColor3 = Library.Theme.Text
                Lab.Font = Enum.Font.GothamMedium
                Lab.TextSize = 12
                Lab.TextXAlignment = Enum.TextXAlignment.Left
                
                local Outer = Instance.new("Frame", Tgl)
                Outer.Size = UDim2.new(0, 40, 0, 20)
                Outer.AnchorPoint = Vector2.new(1, 0.5)
                Outer.Position = UDim2.new(1, 0, 0.5, 0)
                Outer.BackgroundColor3 = Default and Library.Theme.Accent or Library.Theme.Outline
                Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
                
                local Circle = Instance.new("Frame", Outer)
                Circle.Size = UDim2.new(0, 16, 0, 16)
                Circle.Position = Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                Circle.BackgroundColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
                
                local State = Default
                Tgl.MouseButton1Click:Connect(function()
                    State = not State
                    Tween(Outer, {BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.Outline})
                    Tween(Circle, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                    pcall(Callback, State)
                end)
            end

            -- SLIDER
            function SecFuncs:AddSlider(Text, Min, Max, Default, Callback)
                local SldFrame = Instance.new("Frame", Container)
                SldFrame.Size = UDim2.new(1, 0, 0, 45)
                SldFrame.BackgroundTransparency = 1
                
                local Lab = Instance.new("TextLabel", SldFrame)
                Lab.Size = UDim2.new(1, 0, 0, 20)
                Lab.BackgroundTransparency = 1
                Lab.Text = Text
                Lab.TextColor3 = Library.Theme.Text
                Lab.Font = Enum.Font.GothamMedium
                Lab.TextSize = 12
                Lab.TextXAlignment = Enum.TextXAlignment.Left
                
                local Val = Instance.new("TextLabel", SldFrame)
                Val.Size = UDim2.new(1, 0, 0, 20)
                Val.BackgroundTransparency = 1
                Val.Text = tostring(Default)
                Val.TextColor3 = Library.Theme.TextDark
                Val.Font = Enum.Font.GothamBold
                Val.TextSize = 12
                Val.TextXAlignment = Enum.TextXAlignment.Right
                
                local Bar = Instance.new("Frame", SldFrame)
                Bar.Size = UDim2.new(1, 0, 0, 6)
                Bar.Position = UDim2.new(0, 0, 0, 28)
                Bar.BackgroundColor3 = Library.Theme.Outline
                Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
                
                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
                Fill.BackgroundColor3 = Library.Theme.Accent
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                
                local Dragging = false
                local function Update(Input)
                    local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local V = math.floor(Min + ((Max - Min) * P))
                    Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                    Val.Text = tostring(V)
                    pcall(Callback, V)
                end
                
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
            end
            
            -- DROPDOWN
            function SecFuncs:AddDropdown(Text, Items, Default, Callback)
                local Drop = Instance.new("Frame", Container)
                Drop.Size = UDim2.new(1, 0, 0, 32)
                Drop.BackgroundTransparency = 1
                Drop.ClipsDescendants = true
                
                local Btn = Instance.new("TextButton", Drop)
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Library.Theme.Main
                Btn.Text = ""
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", Btn).Color = Library.Theme.Outline
                
                local Lab = Instance.new("TextLabel", Btn)
                Lab.Size = UDim2.new(1, -30, 1, 0)
                Lab.Position = UDim2.new(0, 10, 0, 0)
                Lab.BackgroundTransparency = 1
                Lab.Text = Text .. ": " .. (Default or "...")
                Lab.TextColor3 = Library.Theme.Text
                Lab.Font = Enum.Font.GothamMedium
                Lab.TextSize = 12
                Lab.TextXAlignment = Enum.TextXAlignment.Left
                
                local Arrow = Instance.new("ImageLabel", Btn)
                Arrow.Size = UDim2.new(0, 20, 0, 20)
                Arrow.Position = UDim2.new(1, -25, 0.5, -10)
                Arrow.BackgroundTransparency = 1
                Arrow.Image = "rbxassetid://6031091004"
                Arrow.ImageColor3 = Library.Theme.TextDark
                
                local List = Instance.new("ScrollingFrame", Drop)
                List.Size = UDim2.new(1, 0, 0, 0)
                List.Position = UDim2.new(0, 0, 0, 35)
                List.BackgroundColor3 = Library.Theme.Main
                List.BorderSizePixel = 0
                List.ScrollBarThickness = 2
                
                local ListL = Instance.new("UIListLayout", List)
                ListL.Padding = UDim.new(0, 2)
                
                local Open = false
                
                Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Tween(Drop, {Size = UDim2.new(1, 0, 0, Open and (math.min(#Items, 5) * 27 + 40) or 32)})
                    Tween(Arrow, {Rotation = Open and 180 or 0})
                    Tween(List, {Size = UDim2.new(1, 0, 0, Open and (math.min(#Items, 5) * 27) or 0)})
                end)
                
                for _, item in pairs(Items) do
                    local IB = Instance.new("TextButton", List)
                    IB.Size = UDim2.new(1, 0, 0, 25)
                    IB.BackgroundColor3 = Library.Theme.Main
                    IB.Text = "  " .. item
                    IB.TextColor3 = Library.Theme.TextDark
                    IB.Font = Enum.Font.Gotham
                    IB.TextSize = 12
                    IB.TextXAlignment = Enum.TextXAlignment.Left
                    
                    IB.MouseButton1Click:Connect(function()
                        Open = false
                        Lab.Text = Text .. ": " .. item
                        Tween(Drop, {Size = UDim2.new(1, 0, 0, 32)})
                        Tween(Arrow, {Rotation = 0})
                        pcall(Callback, item)
                    end)
                end
                List.CanvasSize = UDim2.new(0, 0, 0, #Items * 27)
            end

            -- TEXTBOX
            function SecFuncs:AddTextbox(Text, Callback)
                local BoxFrame = Instance.new("Frame", Container)
                BoxFrame.Size = UDim2.new(1, 0, 0, 32)
                BoxFrame.BackgroundColor3 = Library.Theme.Main
                Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 4)
                Instance.new("UIStroke", BoxFrame).Color = Library.Theme.Outline
                
                local Input = Instance.new("TextBox", BoxFrame)
                Input.Size = UDim2.new(1, -10, 1, 0)
                Input.Position = UDim2.new(0, 10, 0, 0)
                Input.BackgroundTransparency = 1
                Input.Text = ""
                Input.PlaceholderText = Text
                Input.TextColor3 = Library.Theme.Text
                Input.PlaceholderColor3 = Library.Theme.TextDark
                Input.Font = Enum.Font.GothamMedium
                Input.TextSize = 12
                Input.TextXAlignment = Enum.TextXAlignment.Left
                
                Input.FocusLost:Connect(function()
                    pcall(Callback, Input.Text)
                end)
            end

            return SecFuncs
        end
        return TabFuncs
    end
    return WindowFuncs
end

return Library
