-- [[ FLUX UI | STEP 1.5 : FIXED & VISIBLE ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Registry = {},
    Theme = {
        Main = Color3.fromRGB(20, 20, 25),
        Sidebar = Color3.fromRGB(15, 15, 20), -- Un peu plus sombre pour le contraste
        Section = Color3.fromRGB(28, 28, 33),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(160, 160, 160),
        Stroke = Color3.fromRGB(50, 50, 55),
        Accent = Color3.fromRGB(0, 140, 255),
    }
}

-- [ UTILS ] --
local Utils = {}

function Utils:Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props):Play()
end

function Utils:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

function Utils:AddCorner(Obj, Radius)
    Utils:Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

function Utils:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Utils:Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}, 0.05) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ THEME ENGINE ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    if Type == "Main" then Obj.BackgroundColor3 = Library.Theme.Main
    elseif Type == "Sidebar" then Obj.BackgroundColor3 = Library.Theme.Sidebar
    elseif Type == "Section" then Obj.BackgroundColor3 = Library.Theme.Section
    elseif Type == "Text" then Obj.TextColor3 = Library.Theme.Text
    elseif Type == "TextDim" then Obj.TextColor3 = Library.Theme.TextDim
    elseif Type == "Stroke" then Obj.Color = Library.Theme.Stroke
    elseif Type == "Accent" then 
        if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then Obj.TextColor3 = Library.Theme.Accent 
        else Obj.BackgroundColor3 = Library.Theme.Accent end
    end
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj, Type = Item.Obj, Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" or Type == "Sidebar" or Type == "Section" then Utils:Tween(Obj, {BackgroundColor3 = Library.Theme[Type]})
            elseif Type == "Text" or Type == "TextDim" then Utils:Tween(Obj, {TextColor3 = Library.Theme[Type]})
            elseif Type == "Stroke" then Utils:Tween(Obj, {Color = Library.Theme.Stroke})
            elseif Type == "Accent" then 
                if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then Utils:Tween(Obj, {TextColor3 = Library.Theme.Accent}) 
                else Utils:Tween(Obj, {BackgroundColor3 = Library.Theme.Accent}) end
            end
        end
    end
end

-- [ WINDOW ] --
function Library:Window(Config)
    local Title = Config.Name or "Flux Fixed"
    
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Flux_"..Title then v:Destroy() end end
    local GUI = Utils:Create("ScreenGui", {Name = "Flux_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Utils:Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
        ClipsDescendants = false
    })
    Library:Register(Main, "Main"); Utils:AddCorner(Main, 8)
    local Stroke = Utils:Create("UIStroke", {Parent = Main, Thickness = 1}); Library:Register(Stroke, "Stroke")

    -- [ SIDEBAR ] --
    local Sidebar = Utils:Create("Frame", {
        Parent = Main, Size = UDim2.new(0, 180, 1, 0),
        ZIndex = 5 -- FORCE L'AFFICHAGE AU DESSUS
    })
    Library:Register(Sidebar, "Sidebar"); Utils:AddCorner(Sidebar, 8)
    
    -- Cache pour le coin droit de la sidebar
    local Hide = Utils:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BorderSizePixel = 0, ZIndex = 5}); Library:Register(Hide, "Sidebar")

    local Logo = Utils:Create("TextLabel", {
        Parent = Sidebar, Text = Title, Size = UDim2.new(1,-20,0,50), Position = UDim2.new(0,15,0,0),
        Font = "GothamBlack", TextSize = 18, BackgroundTransparency = 1, TextXAlignment = "Left", ZIndex = 6
    })
    Library:Register(Logo, "Accent")

    local TabContainer = Utils:Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1,0,1,-60), Position = UDim2.new(0,0,0,60),
        BackgroundTransparency = 1, ScrollBarThickness = 0, ZIndex = 6
    })
    Utils:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    -- [ CONTENT ] --
    local Content = Utils:Create("Frame", {
        Parent = Main, Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1
    })
    
    Utils:MakeDraggable(Sidebar, Main)

    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:Tab(Name)
        local TabFuncs = {}
        
        -- BOUTON DE L'ONGLET
        local Btn = Utils:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 160, 0, 36), AutoButtonColor = false,
            Text = "  "..Name, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left",
            BackgroundTransparency = 1, -- Invisible par défaut pour voir que le texte
            ZIndex = 7
        })
        Library:Register(Btn, "TextDim") -- Texte gris par défaut
        Utils:AddCorner(Btn, 6)

        -- Indicateur coloré à gauche du bouton
        local Marker = Utils:Create("Frame", {
            Parent = Btn, Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundTransparency = 1, ZIndex = 8
        })
        Library:Register(Marker, "Accent")

        -- LA PAGE DE CONTENU
        local Page = Utils:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2, ZIndex = 2
        })
        Utils:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 8)})
        Utils:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

        Btn.MouseButton1Click:Connect(function()
            -- Désactive les autres onglets
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utils:Tween(v, {BackgroundTransparency = 1}) -- Rend le fond invisible
                    Utils:Tween(v, {TextColor3 = Library.Theme.TextDim})
                    Utils:Tween(v:FindFirstChild("Frame"), {BackgroundTransparency = 1}) -- Cache le marqueur
                end
            end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            
            -- Active cet onglet
            Utils:Tween(Btn, {BackgroundTransparency = 0}) -- Affiche le fond
            Utils:Tween(Btn, {BackgroundColor3 = Library.Theme.Section}) -- Couleur de fond active
            Utils:Tween(Btn, {TextColor3 = Library.Theme.Text}) -- Texte blanc
            Utils:Tween(Marker, {BackgroundTransparency = 0}) -- Affiche le marqueur bleu
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            Btn.BackgroundTransparency = 0
            Btn.BackgroundColor3 = Library.Theme.Section
            Btn.TextColor3 = Library.Theme.Text
            Marker.BackgroundTransparency = 0
        end

        -- [ COMPOSANT 1 : BOUTON ] --
        function TabFuncs:Button(Text, Callback)
            local B = Utils:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1,0,0,36), AutoButtonColor = false,
                Text = Text, Font = "GothamMedium", TextSize = 13, ZIndex = 2
            })
            Library:Register(B, "Section"); Library:Register(B, "Text")
            Utils:AddCorner(B, 6)
            
            B.MouseButton1Click:Connect(function()
                Utils:Tween(B, {BackgroundColor3 = Library.Theme.Accent})
                task.wait(0.1)
                Utils:Tween(B, {BackgroundColor3 = Library.Theme.Section})
                pcall(Callback)
            end)
        end

        -- [ COMPOSANT 2 : TOGGLE ] --
        function TabFuncs:Toggle(Text, Default, Callback)
            local State = Default or false
            local Container = Utils:Create("TextButton", {
                Parent = Page, Size = UDim2.new(1,0,0,36), AutoButtonColor = false,
                Text = "", ZIndex = 2
            })
            Library:Register(Container, "Section"); Utils:AddCorner(Container, 6)
            
            local Lab = Utils:Create("TextLabel", {
                Parent = Container, Text = Text, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0),
                Font = "GothamMedium", TextSize = 13, BackgroundTransparency = 1, TextXAlignment = "Left", ZIndex = 3
            })
            Library:Register(Lab, "Text")
            
            local Box = Utils:Create("Frame", {
                Parent = Container, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10),
                ZIndex = 3
            })
            Utils:AddCorner(Box, 10)
            -- Couleur dynamique du Toggle
            if State then Box.BackgroundColor3 = Library.Theme.Accent else Box.BackgroundColor3 = Library.Theme.Main end
            
            local Circle = Utils:Create("Frame", {
                Parent = Box, Size = UDim2.new(0, 16, 0, 16),
                Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1,1,1), ZIndex = 4
            })
            Utils:AddCorner(Circle, 8)
            
            Container.MouseButton1Click:Connect(function()
                State = not State
                -- Animation
                if State then
                    Utils:Tween(Box, {BackgroundColor3 = Library.Theme.Accent})
                    Utils:Tween(Circle, {Position = UDim2.new(1, -18, 0.5, -8)})
                else
                    Utils:Tween(Box, {BackgroundColor3 = Library.Theme.Main})
                    Utils:Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -8)})
                end
                pcall(Callback, State)
            end)
        end

        -- [ COMPOSANT 3 : SLIDER RGB (Pour tester le thème) ] --
        function TabFuncs:ColorSlider(Text, Type, Axis)
            local F = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,50), ZIndex = 2}); Library:Register(F, "Section"); Utils:AddCorner(F, 6)
            local L = Utils:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,10,0,5), BackgroundTransparency=1, TextXAlignment="Left", Font="Gotham", TextSize=12, ZIndex=3}); Library:Register(L, "Text")
            
            local Bar = Utils:Create("Frame", {Parent = F, Size = UDim2.new(1,-20,0,6), Position = UDim2.new(0,10,0,30), ZIndex=3}); Library:Register(Bar, "Main"); Utils:AddCorner(Bar, 3)
            local Fill = Utils:Create("Frame", {Parent = Bar, Size = UDim2.new(0.5,0,1,0), ZIndex=3}); Library:Register(Fill, "Accent"); Utils:AddCorner(Fill, 3)
            local Btn = Utils:Create("TextButton", {Parent = Bar, Size = UDim2.new(1,0,1,0), BackgroundTransparency=1})
            
            Btn.MouseButton1Down:Connect(function()
                local Move = RunService.RenderStepped:Connect(function()
                    local P = math.clamp((Players.LocalPlayer:GetMouse().X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(P,0,1,0)
                    local C = Library.Theme[Type]
                    local R, G, B = C.R, C.G, C.B
                    if Axis == "R" then R = P elseif Axis == "G" then G = P else B = P end
                    Library.Theme[Type] = Color3.new(R,G,B)
                    Library:RefreshTheme()
                end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Move:Disconnect() end end)
            end)
        end

        return TabFuncs
    end
    return WindowFuncs
end

-- [ EXEMPLE ] --
local Window = Library:Window({Name = "FLUX V2"})

local Tab = Window:Tab("Main")
Tab:Button("Test Button", function() print("Click") end)
Tab:Toggle("Enable Hack", true, function(v) print(v) end)

local Theme = Window:Tab("Theme")
Theme:ColorSlider("Accent Red", "Accent", "R")
Theme:ColorSlider("Accent Green", "Accent", "G")
Theme:ColorSlider("Accent Blue", "Accent", "B")
