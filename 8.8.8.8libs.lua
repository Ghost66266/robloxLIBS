local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {} -- La table principale

-- Propriétés du Thème
local Theme = {
    PrimaryBg = Color3.fromRGB(12, 12, 15),
    SecondaryBg = Color3.fromRGB(16, 16, 19),
    Accent = Color3.fromRGB(170, 0, 255), -- Violet néon
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 155),
    Border = Color3.fromRGB(30, 30, 35)
}

-- Fonction utilitaire pour le Drag (plus fluide)
local function MakeDraggable(obj)
    local dragging, dragStartPos, initialMousePos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = obj.Position
            initialMousePos = input.Position
        end
    end)
    obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - initialMousePos
            local newX = dragStartPos.X.Offset + delta.X
            local newY = dragStartPos.Y.Offset + delta.Y
            obj.Position = UDim2.new(dragStartPos.X.Scale, newX, dragStartPos.Y.Scale, newY)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Fonction pour les ondes de clic
local function CreateRipple(parent, pos)
    local Ripple = Instance.new("Frame", parent)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.BackgroundColor3 = Theme.Accent
    Ripple.BackgroundTransparency = 0.8
    Ripple.BorderSizePixel = 0
    Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1,0) -- Rond parfait

    TS:Create(Ripple, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5, 0, math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.4, function() Ripple:Destroy() end)
end

-- --- MAIN WINDOW ---
function Library:CreateWindow(title)
    local UI_INSTANCE = Instance.new("ScreenGui", CoreGui)
    UI_INSTANCE.Name = "8888_Library_" .. os.time() -- Unique name
    UI_INSTANCE.DisplayOrder = 999 -- Toujours au-dessus

    local Main = Instance.new("Frame", UI_INSTANCE)
    Main.Size = UDim2.new(0, 580, 0, 420)
    Main.Position = UDim2.new(0.5, -290, 0.5, -210)
    Main.BackgroundColor3 = Theme.PrimaryBg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    
    MakeDraggable(Main)

    -- Holographic Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.SecondaryBg
    Header.BorderSizePixel = 0
    Header.ClipsDescendants = true

    local HeaderTitle = Instance.new("TextLabel", Header)
    HeaderTitle.Size = UDim2.new(1, 0, 1, 0)
    HeaderTitle.Text = title or "8.8.8.8 UI"
    HeaderTitle.TextColor3 = Theme.Accent
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 22
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.RichText = true

    local Scanline = Instance.new("Frame", Header) -- Effet Scanline
    Scanline.Size = UDim2.new(1, 0, 0, 2)
    Scanline.BackgroundColor3 = Theme.Accent
    Scanline.BackgroundTransparency = 0.8
    Scanline.Position = UDim2.new(0,0,0, -2) -- Commence hors écran
    TS:Create(Scanline, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

    -- Sidebar (Navigation ou Infos)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 160, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = Theme.SecondaryBg
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar)
    local SidebarStroke = Instance.new("UIStroke", Sidebar)
    SidebarStroke.Color = Theme.Border
    SidebarStroke.Thickness = 1

    local NavContainer = Instance.new("Frame", Sidebar)
    NavContainer.Size = UDim2.new(1, -20, 1, -20)
    NavContainer.Position = UDim2.new(0, 10, 0, 10)
    NavContainer.BackgroundTransparency = 1
    local NavLayout = Instance.new("UIListLayout", NavContainer)
    NavLayout.Padding = UDim.new(0, 8)
    NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Area (Scrolling)
    local ContentArea = Instance.new("ScrollingFrame", Main)
    ContentArea.Size = UDim2.new(1, -180, 1, -70)
    ContentArea.Position = UDim2.new(0, 170, 0, 60)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ScrollBarThickness = 6
    ContentArea.ScrollBarColor3 = Theme.Accent
    ContentArea.CanvasSize = UDim2.new(0,0,0,0)
    ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local ContentLayout = Instance.new("UIListLayout", ContentArea)
    ContentLayout.Padding = UDim.new(0, 12)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Widgets = {} -- Les fonctions pour créer des widgets

    -- Base de section (pour l'effet Parallax)
    function Widgets:AddSection(title)
        local SectionWrapper = Instance.new("Frame", ContentArea)
        SectionWrapper.Size = UDim2.new(1, 0, 0, 0)
        SectionWrapper.AutomaticSize = Enum.AutomaticSize.Y
        SectionWrapper.BackgroundTransparency = 1
        SectionWrapper.LayoutOrder = ContentLayout:GetChildren() and #ContentLayout:GetChildren() + 1 or 1 -- Assure l'ordre

        local Section = Instance.new("Frame", SectionWrapper)
        Section.Size = UDim2.new(1, -10, 0, 30)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.BackgroundColor3 = Theme.SecondaryBg
        Section.BorderSizePixel = 0
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
        local SectionStroke = Instance.new("UIStroke", Section)
        SectionStroke.Color = Theme.Border
        SectionStroke.Thickness = 1

        local TitleLabel = Instance.new("TextLabel", Section)
        TitleLabel.Size = UDim2.new(1, 0, 0, 25)
        TitleLabel.Position = UDim2.new(0, 15, 0, -10)
        TitleLabel.Text = title:upper()
        TitleLabel.TextColor3 = Theme.Accent
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 10
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local InnerContainer = Instance.new("Frame", Section)
        InnerContainer.Size = UDim2.new(1, -20, 1, 0)
        InnerContainer.Position = UDim2.new(0, 10, 0, 15)
        InnerContainer.BackgroundTransparency = 1
        local InnerLayout = Instance.new("UIListLayout", InnerContainer)
        InnerLayout.Padding = UDim.new(0, 8)
        InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        InnerLayout.FillDirection = Enum.FillDirection.Vertical

        local PaddingTop = Instance.new("UIPadding", InnerContainer)
        PaddingTop.PaddingTop = UDim.new(0, 15)
        local PaddingBottom = Instance.new("UIPadding", InnerContainer)
        PaddingBottom.PaddingBottom = UDim.new(0, 10)

        -- Parallax Effect
        local originalOffset = Section.Position.Y.Offset
        SectionWrapper.MouseEnter:Connect(function()
            TS:Create(Section, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = -1, Position = UDim2.new(0, -2, 0, originalOffset - 2)}):Play()
            TS:Create(SectionStroke, TweenInfo.new(0.2), {Color = Theme.Accent, Transparency = 0.5}):Play()
        end)
        SectionWrapper.MouseLeave:Connect(function()
            TS:Create(Section, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = 0, Position = UDim2.new(0, 0, 0, originalOffset)}):Play()
            TS:Create(SectionStroke, TweenInfo.new(0.2), {Color = Theme.Border, Transparency = 0}):Play()
        end)

        return {
            Container = InnerContainer,
            AddLabel = function(text, color)
                local Label = Instance.new("TextLabel", InnerContainer)
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = color or Theme.TextMuted
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
            end,
            AddDescription = function(text, color)
                local Desc = Instance.new("TextLabel", InnerContainer)
                Desc.Size = UDim2.new(1, 0, 0, 0)
                Desc.AutomaticSize = Enum.AutomaticSize.Y
                Desc.BackgroundTransparency = 1
                Desc.Text = text
                Desc.TextColor3 = color or Theme.TextMuted
                Desc.Font = Enum.Font.Gotham
                Desc.TextSize = 12
                Desc.TextWrapped = true
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UIPadding", Desc).PaddingLeft = UDim.new(0,5)
            end,
            AddButton = function(btnText, callback)
                local Btn = Instance.new("TextButton", InnerContainer)
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.BackgroundColor3 = Theme.Accent
                Btn.BackgroundTransparency = 0.85
                Btn.Text = btnText
                Btn.TextColor3 = Theme.Text
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 14
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                
                -- Depth Hover
                local originalScale = Btn.Size
                Btn.MouseEnter:Connect(function()
                    TS:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.7, Size = UDim2.new(1, 2, 0, 37)}):Play()
                end)
                Btn.MouseLeave:Connect(function()
                    TS:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85, Size = originalScale}):Play()
                end)

                Btn.MouseButton1Click:Connect(function(x, y)
                    CreateRipple(Btn, Vector2.new(x, y)) -- Click Ripple
                    TS:Create(Btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
                    task.delay(0.1, function() TS:Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play() end)
                    callback()
                end)
            end,
            AddToggle = function(text, callback)
                local ToggleBtn = Instance.new("TextButton", InnerContainer)
                ToggleBtn.Size = UDim2.new(1, 0, 0, 30)
                ToggleBtn.BackgroundTransparency = 1
                ToggleBtn.Text = ""

                local Label = Instance.new("TextLabel", ToggleBtn)
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.Text = text
                Label.TextColor3 = Theme.TextMuted
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1

                local Box = Instance.new("Frame", ToggleBtn)
                Box.Size = UDim2.new(0, 30, 0, 16)
                Box.Position = UDim2.new(1, -40, 0.5, -8)
                Box.BackgroundColor3 = Theme.Border
                Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

                local Dot = Instance.new("Frame", Box)
                Dot.Size = UDim2.new(0, 12, 0, 12)
                Dot.Position = UDim2.new(0, 2, 0.5, -6)
                Dot.BackgroundColor3 = Theme.Text
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

                local active = false
                ToggleBtn.MouseButton1Click:Connect(function()
                    active = not active
                    TS:Create(Box, TweenInfo.new(0.3), {BackgroundColor3 = active and Theme.Accent or Theme.Border}):Play()
                    TS:Create(Dot, TweenInfo.new(0.3), {Position = active and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                    callback(active)
                end)
            end,
            AddSlider = function(label, min, max, initial, callback)
                local SliderFrame = Instance.new("Frame", InnerContainer)
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.BackgroundTransparency = 1
                
                local SliderLabel = Instance.new("TextLabel", SliderFrame)
                SliderLabel.Size = UDim2.new(0.7, 0, 0, 15)
                SliderLabel.Position = UDim2.new(0,0,0,0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = label
                SliderLabel.TextColor3 = Theme.TextMuted
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextSize = 12

                local ValueLabel = Instance.new("TextLabel", SliderFrame)
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 15)
                ValueLabel.Position = UDim2.new(0.7,0,0,0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(initial)
                ValueLabel.TextColor3 = Theme.Accent
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextSize = 12

                local Bar = Instance.new("Frame", SliderFrame)
                Bar.Size = UDim2.new(1, 0, 0, 4)
                Bar.Position = UDim2.new(0, 0, 0, 25)
                Bar.BackgroundColor3 = Theme.Border
                Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

                local Knob = Instance.new("Frame", Bar)
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, -6)
                Knob.BackgroundColor3 = Theme.Accent
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

                local KnobGlow = Instance.new("ImageLabel", Knob) -- Neon Glow
                KnobGlow.Size = UDim2.new(2, 0, 2, 0)
                KnobGlow.Position = UDim2.new(-0.5, 0, -0.5, 0)
                KnobGlow.Image = "rbxassetid://6015667343" -- Soft glow texture
                KnobGlow.ImageColor3 = Theme.Accent
                KnobGlow.BackgroundTransparency = 1
                KnobGlow.ImageTransparency = 0.5

                local dragging = false
                local function UpdateSlider(input)
                    local mouseX = input.Position.X - Bar.AbsolutePosition.X
                    local percent = math.clamp(mouseX / Bar.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * percent
                    value = math.floor(value + 0.5) -- Arrondir à l'entier le plus proche

                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, 0, 0.5, -6)
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end
        }
    end

    return {
        AddSection = Widgets.AddSection,
        Header = HeaderTitle -- Pour d'éventuelles modifications du titre externe
    }
end

-- --- COMMENT UN UTILISATEUR VA INTÉGRER TA LIBRAIRIE ---
-- ```lua
-- local Library = require(chemin_vers_ta_librairie) -- Si c'est un ModuleScript
-- local UI = Library:CreateWindow("Project 8888")
-- 
-- local Info = UI:AddSection("System Information")
-- Info:AddLabel("Status: Online", Color3.new(0, 1, 0))
-- Info:AddLabel("Version: 1.0.0", Color3.fromRGB(170, 0, 255))
-- Info:AddDescription("This is a highly advanced UI framework for Roblox exploits, featuring dynamic animations and a futuristic aesthetic. Enjoy the power of 8.8.8.8 UI.", Theme.TextMuted)
-- Info:AddButton("Copy Discord Link", function()
--     setclipboard("discord.gg/8888")
-- end)
-- 
-- local Settings = UI:AddSection("Client Settings")
-- Settings:AddToggle("Infinite Jump", function(state)
--     print("Infinite Jump: " .. tostring(state))
--     -- CODE DE L'EXPLOIT ICI
-- end)
-- Settings:AddSlider("WalkSpeed", 0, 100, 16, function(value)
--     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
-- end)
-- Settings:AddButton("Execute Script", function()
--     print("Script Executed!")
-- end)
-- ```

return Library
