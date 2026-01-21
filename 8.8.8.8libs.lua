local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

-- THEME "NEVER-VIOLET" REFINED
local Theme = {
    Main        = Color3.fromRGB(20, 20, 20),
    Sidebar     = Color3.fromRGB(15, 15, 15),
    Section     = Color3.fromRGB(25, 25, 25),
    Accent      = Color3.fromRGB(170, 0, 255),
    Text        = Color3.fromRGB(255, 255, 255),
    TextDark    = Color3.fromRGB(150, 150, 150),
    Outline     = Color3.fromRGB(45, 45, 45),
    ToggleOff   = Color3.fromRGB(35, 35, 35)
}

-- [ FONCTION ONDE DE CHOC ] --
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
        Ripple.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        TS:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3, 0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3),
            ImageTransparency = 1
        }):Play()
        task.wait(0.6); Ripple:Destroy()
    end)
end

-- [ ANIMATION BIENVENUE (Celle que tu aimes) ] --
function Library:Welcome(TitleText, SubText)
    -- Si tu veux modifier le texte, c'est via les arguments TitleText et SubText
    local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "Intro"; Screen.IgnoreGuiInset = true; Screen.DisplayOrder = 10000
    local Blur = Instance.new("BlurEffect", game:GetService("Lighting")); Blur.Size = 0
    local MainFrame = Instance.new("Frame", Screen); MainFrame.Size = UDim2.new(1, 0, 1, 0); MainFrame.BackgroundColor3 = Color3.new(0,0,0); MainFrame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", MainFrame); Label.Size = UDim2.new(1, 0, 0, 150); Label.Position = UDim2.new(0, 0, 0.4, 0); Label.BackgroundTransparency = 1
    Label.Text = TitleText or "LIBRARY"; Label.TextColor3 = Theme.Accent; Label.Font = Enum.Font.GothamBlack; Label.TextSize = 80; Label.TextTransparency = 1
    
    local Sub = Instance.new("TextLabel", MainFrame); Sub.Size = UDim2.new(1, 0, 0, 50); Sub.Position = UDim2.new(0, 0, 0.55, 0); Sub.BackgroundTransparency = 1
    Sub.Text = SubText or "LOADING..."; Sub.TextColor3 = Theme.Text; Sub.Font = Enum.Font.GothamBold; Sub.TextSize = 25; Sub.TextTransparency = 1

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
    task.wait(0.5); Screen:Destroy(); Blur:Destroy()
end

-- [ FENÊTRE PRINCIPALE RECADRÉE ] --
function Library:CreateWindow(Settings)
    if CoreGui:FindFirstChild(Settings.Name) then CoreGui[Settings.Name]:Destroy() end
    local UI = Instance.new("ScreenGui", CoreGui); UI.Name = Settings.Name; UI.DisplayOrder = 100

    local Main = Instance.new("Frame", UI)
    Main.Name = "Main"; Main.Size = UDim2.new(0, 750, 0, 500) -- Un peu plus large pour l'espace
    Main.Position = UDim2.new(0.5, -375, 0.5, -250); Main.BackgroundColor3 = Theme.Main; Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Theme.Outline; Stroke.Thickness = 1

    -- Sidebar recadrée
    local Sidebar = Instance.new("Frame", Main); Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 200, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar
    
    local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, -25, 0, 70); Title.Position = UDim2.new(0, 25, 0, 0)
    Title.Text = string.upper(Settings.Name); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 26; Title.TextColor3 = Theme.Text; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1

    local TabContainer = Instance.new("ScrollingFrame", Sidebar); TabContainer.Size = UDim2.new(1, 0, 1, -80); TabContainer.Position = UDim2.new(0, 0, 0, 80)
    TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer); TabList.SortOrder = "LayoutOrder"; TabList.Padding = UDim.new(0, 5)

    -- Zone de contenu
    local Pages = Instance.new("Frame", Main); Pages.Name = "Pages"; Pages.Size = UDim2.new(1, -210, 1, -20); Pages.Position = UDim2.new(0, 210, 0, 10); Pages.BackgroundTransparency = 1

    -- Drag
    local dragging, dragInput, dragStart, startPos
    Sidebar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Main.Position end end)
    Sidebar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)

    local Funcs = {}
    local FirstTab = true

    function Funcs:AddTab(Name, Icon)
        local TabBtn = Instance.new("TextButton", TabContainer); TabBtn.Size = UDim2.new(1, 0, 0, 45); TabBtn.BackgroundTransparency = 1; TabBtn.Text = ""
        local TabLabel = Instance.new("TextLabel", TabBtn); TabLabel.Size = UDim2.new(1, -50, 1, 0); TabLabel.Position = UDim2.new(0, 50, 0, 0); TabLabel.Text = Name
        TabLabel.Font = "GothamBold"; TabLabel.TextSize = 14; TabLabel.TextColor3 = Theme.TextDark; TabLabel.TextXAlignment = "Left"; TabLabel.BackgroundTransparency = 1
        local Indicator = Instance.new("Frame", TabBtn); Indicator.Size = UDim2.new(0, 4, 0.6, 0); Indicator.Position = UDim2.new(0, 0, 0.2, 0); Indicator.BackgroundColor3 = Theme.Accent; Indicator.Transparency = 1
        
        local Page = Instance.new("ScrollingFrame", Pages); Page.Name = Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0
        local Grid = Instance.new("UIGridLayout", Page); Grid.CellSize = UDim2.new(0.48, 0, 0, 0); Grid.CellPadding = UDim2.new(0.02, 0, 0.02, 0); Grid.SortOrder = "LayoutOrder"
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then TS:Create(v.TextLabel, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play(); TS:Create(v.Frame, TweenInfo.new(0.3), {Transparency = 1}):Play() end end
            for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
            Page.Visible = true; TS:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Theme.Text}):Play(); TS:Create(Indicator, TweenInfo.new(0.3), {Transparency = 0}):Play()
        end)
        
        if FirstTab then Page.Visible = true; TabLabel.TextColor3 = Theme.Text; Indicator.Transparency = 0; FirstTab = false end

        local TabFuncs = {}
        function TabFuncs:AddSection(SecName)
            local Section = Instance.new("Frame", Page); Section.BackgroundColor3 = Theme.Section; Section.Size = UDim2.new(0.48, 0, 0, 200)
            Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)
            local SecHead = Instance.new("TextLabel", Section); SecHead.Size = UDim2.new(1, -20, 0, 35); SecHead.Position = UDim2.new(0, 15, 0, 0); SecHead.Text = SecName
            SecHead.Font = "GothamBold"; SecHead.TextSize = 14; SecHead.TextColor3 = Theme.Text; SecHead.TextXAlignment = "Left"; SecHead.BackgroundTransparency = 1
            local Line = Instance.new("Frame", Section); Line.Size = UDim2.new(1, 0, 0, 1); Line.Position = UDim2.new(0, 0, 0, 35); Line.BackgroundColor3 = Theme.Outline; Line.BorderSizePixel = 0
            
            local Container = Instance.new("Frame", Section); Container.Size = UDim2.new(1, -20, 1, -45); Container.Position = UDim2.new(0, 10, 0, 45); Container.BackgroundTransparency = 1
            local List = Instance.new("UIListLayout", Container); List.SortOrder = "LayoutOrder"; List.Padding = UDim.new(0, 8)
            
            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(0.48, 0, 0, List.AbsoluteContentSize.Y + 60)
                local maxY = 0
                for _, c in pairs(Page:GetChildren()) do if c:IsA("Frame") then maxY = math.max(maxY, c.AbsolutePosition.Y + c.AbsoluteSize.Y - Page.AbsolutePosition.Y) end end
                Page.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
            end)
            
            local SecFuncs = {}
            function SecFuncs:AddToggle(Text, Default, Callback)
                local Tgl = Instance.new("TextButton", Container); Tgl.Size = UDim2.new(1, 0, 0, 30); Tgl.BackgroundTransparency = 1; Tgl.Text = ""; Tgl.AutoButtonColor = false
                local Lab = Instance.new("TextLabel", Tgl); Lab.Size = UDim2.new(1, -50, 1, 0); Lab.Text = Text; Lab.TextColor3 = Theme.TextDark; Lab.Font = "GothamMedium"; Lab.TextSize = 13; Lab.TextXAlignment = "Left"; Lab.BackgroundTransparency = 1
                local Switch = Instance.new("Frame", Tgl); Switch.Size = UDim2.new(0, 34, 0, 18); Switch.Position = UDim2.new(1, -34, 0.5, -9); Switch.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
                local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); Dot.BackgroundColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
                
                local s = Default
                Tgl.MouseButton1Click:Connect(function() s = not s; TS:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = s and Theme.Accent or Theme.ToggleOff}):Play(); TS:Create(Dot, TweenInfo.new(0.2), {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play(); TS:Create(Lab, TweenInfo.new(0.2), {TextColor3 = s and Theme.Text or Theme.TextDark}):Play(); pcall(Callback, s) end)
            end

            function SecFuncs:AddButton(Text, Callback)
                local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 32); Btn.BackgroundColor3 = Theme.Main; Btn.Text = Text; Btn.TextColor3 = Theme.Text; Btn.Font = "GothamBold"; Btn.TextSize = 12; Btn.AutoButtonColor = false; Btn.ClipsDescendants = true
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", Btn).Color = Theme.Outline
                Btn.MouseEnter:Connect(function() TS:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play() end)
                Btn.MouseLeave:Connect(function() TS:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Main}):Play() end)
                Btn.MouseButton1Click:Connect(function() CreateRipple(Btn); pcall(Callback) end)
            end

            function SecFuncs:AddSlider(Text, Min, Max, Default, Callback)
                local Sld = Instance.new("Frame", Container); Sld.Size = UDim2.new(1, 0, 0, 45); Sld.BackgroundTransparency = 1
                local Lab = Instance.new("TextLabel", Sld); Lab.Size = UDim2.new(1, 0, 0, 20); Lab.Text = Text; Lab.TextColor3 = Theme.TextDark; Lab.Font = "GothamMedium"; Lab.TextSize = 13; Lab.TextXAlignment = "Left"; Lab.BackgroundTransparency = 1
                local Val = Instance.new("TextLabel", Sld); Val.Size = UDim2.new(1, 0, 0, 20); Val.Text = tostring(Default); Val.TextColor3 = Theme.Text; Val.Font = "GothamBold"; Val.TextSize = 13; Val.TextXAlignment = "Right"; Val.BackgroundTransparency = 1
                local Bar = Instance.new("Frame", Sld); Bar.Size = UDim2.new(1, 0, 0, 4); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", Bar)
                local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)
                
                local s = false
                local function U(i) local p = math.clamp((i.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1); TS:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(p,0,1,0)}):Play(); local v = math.floor(Min+(Max-Min)*p); Val.Text = tostring(v); pcall(Callback, v) end
                Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then s = true; U(i) end end)
                UIS.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and s then U(i) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then s = false end end)
            end
            return SecFuncs
        end
        return TabFuncs
    end
    return Funcs
end
return Library
