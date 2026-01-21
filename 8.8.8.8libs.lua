local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
    Main = Color3.fromRGB(10, 10, 12),
    Sidebar = Color3.fromRGB(13, 13, 16),
    Accent = Color3.fromRGB(170, 0, 255), -- Ton Violet
    Outline = Color3.fromRGB(35, 35, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 155),
    Section = Color3.fromRGB(18, 18, 22),
    Trans = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

-- Effet d'onde (Ripple)
local function CreateRipple(parent, pos)
    local Ripple = Instance.new("Frame", parent)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.BackgroundColor3 = Theme.Accent
    Ripple.BackgroundTransparency = 0.8
    Ripple.BorderSizePixel = 0
    Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1,0)
    TS:Create(Ripple, TweenInfo.new(0.4), {Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1}):Play()
    task.delay(0.5, function() Ripple:Destroy() end)
end

function Library:CreateWindow(title)
    local UI = Instance.new("ScreenGui", CoreGui)
    UI.Name = "8888_Premium_Lib"

    local Main = Instance.new("Frame", UI)
    Main.Size = UDim2.new(0, 580, 0, 400)
    Main.Position = UDim2.new(0.5, -290, 0.5, -200)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.Outline

    -- Drag System
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    -- Header Holographique
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header)

    local Scanline = Instance.new("Frame", Header)
    Scanline.Size = UDim2.new(1, 0, 0, 2)
    Scanline.BackgroundColor3 = Theme.Accent
    Scanline.BackgroundTransparency = 0.7
    TS:Create(Scanline, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Text = title or "8.8.8.8 <font color='#AA00FF'>UI</font>"
    TitleLabel.RichText = true
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.BackgroundTransparency = 1

    -- Scrolling Area
    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -20, 1, -65)
    Scroll.Position = UDim2.new(0, 10, 0, 55)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 15)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local WindowActions = {}

    function WindowActions:AddSection(sTitle)
        local Section = Instance.new("Frame", Scroll)
        Section.Size = UDim2.new(0.95, 0, 0, 40)
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.BackgroundColor3 = Theme.Section
        Section.BorderSizePixel = 0
        Instance.new("UICorner", Section)
        local sStroke = Instance.new("UIStroke", Section)
        sStroke.Color = Theme.Outline

        local st = Instance.new("TextLabel", Section)
        st.Size = UDim2.new(1, 0, 0, 25)
        st.Position = UDim2.new(0, 12, 0, -10)
        st.Text = sTitle:upper()
        st.TextColor3 = Theme.Accent
        st.Font = Enum.Font.GothamBold
        st.TextSize = 11
        st.BackgroundTransparency = 1
        st.TextXAlignment = Enum.TextXAlignment.Left

        local Container = Instance.new("Frame", Section)
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)
        Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 15)
        Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

        -- Effet Parallax
        Section.MouseEnter:Connect(function()
            TS:Create(Section, Theme.Trans, {BackgroundColor3 = Color3.fromRGB(22, 22, 28)}):Play()
        end)
        Section.MouseLeave:Connect(function()
            TS:Create(Section, Theme.Trans, {BackgroundColor3 = Theme.Section}):Play()
        end)

        local SectionActions = {}

        function SectionActions:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Container)
            Btn.Size = UDim2.new(0.9, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Main
            Btn.Text = "  " .. text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            Btn.ClipsDescendants = true
            Instance.new("UICorner", Btn)
            Instance.new("UIStroke", Btn).Color = Theme.Outline

            Btn.MouseButton1Click:Connect(function()
                local m = UIS:GetMouseLocation()
                CreateRipple(Btn, Vector2.new(m.X - Btn.AbsolutePosition.X, m.Y - Btn.AbsolutePosition.Y - 36))
                callback()
            end)
        end

        function SectionActions:AddToggle(text, callback)
            local Toggle = Instance.new("TextButton", Container)
            Toggle.Size = UDim2.new(0.9, 0, 0, 32)
            Toggle.BackgroundTransparency = 1
            Toggle.Text = "  " .. text
            Toggle.TextColor3 = Theme.TextDark
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 13
            Toggle.TextXAlignment = Enum.TextXAlignment.Left

            local Box = Instance.new("Frame", Toggle)
            Box.Size = UDim2.new(0, 32, 0, 18)
            Box.Position = UDim2.new(1, -40, 0.5, -9)
            Box.BackgroundColor3 = Theme.Outline
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1,0)

            local Dot = Instance.new("Frame", Box)
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Theme.Text
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            local active = false
            Toggle.MouseButton1Click:Connect(function()
                active = not active
                TS:Create(Box, Theme.Trans, {BackgroundColor3 = active and Theme.Accent or Theme.Outline}):Play()
                TS:Create(Dot, Theme.Trans, {Position = active and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                callback(active)
            end)
        end

        return SectionActions
    end
    return WindowActions
end

return Library
