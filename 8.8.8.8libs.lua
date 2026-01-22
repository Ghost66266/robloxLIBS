-- [[ FLUX UI | STEP 1: CORE & THEMES ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Registry = {}, -- Stocke les objets pour le changement de couleur en direct
    Theme = {
        Main = Color3.fromRGB(20, 20, 25),       -- Fond Principal
        Sidebar = Color3.fromRGB(15, 15, 20),    -- Barre Latérale
        Section = Color3.fromRGB(25, 25, 30),    -- Fond des éléments
        Text = Color3.fromRGB(240, 240, 240),    -- Texte Blanc
        TextDim = Color3.fromRGB(150, 150, 150), -- Texte Gris
        Stroke = Color3.fromRGB(40, 40, 45),     -- Bordures
        Accent = Color3.fromRGB(0, 120, 255),    -- Couleur Principale (Bleu par défaut)
    },
    ActiveTab = nil
}

-- [ 1. UTILS (ANIMATIONS & OUTILS) ] --
local Utils = {}

function Utils:Tween(Obj, Props, Time)
    -- Animation "Quart" pour un effet très fluide et premium
    TweenService:Create(Obj, TweenInfo.new(Time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Props):Play()
end

function Utils:Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

function Utils:AddCorner(Obj, Radius)
    Utils:Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 8)})
end

function Utils:AddStroke(Obj, Color, Thickness)
    local Stroke = Utils:Create("UIStroke", {Parent = Obj, Color = Color or Library.Theme.Stroke, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    Library:Register(Stroke, "Stroke") -- On l'enregistre pour pouvoir changer sa couleur plus tard
    return Stroke
end

function Utils:MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Utils:Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)}, 0.1) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ 2. THEME ENGINE (LE COEUR DU SYSTÈME) ] --
function Library:Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    -- Applique la couleur immédiatement
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
    -- Cette fonction est appelée quand tu changes une couleur. Elle anime tout le menu.
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

-- [ 3. WINDOW STRUCTURE ] --
function Library:Window(Config)
    local Title = Config.Name or "Flux UI"
    
    -- Nettoyage ancienne fenêtre
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Flux_"..Title then v:Destroy() end end
    local GUI = Utils:Create("ScreenGui", {Name = "Flux_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    -- Cadre Principal
    local Main = Utils:Create("Frame", {
        Name = "Main", Parent = GUI, Size = UDim2.new(0,0,0,0), -- On part de 0 pour l'animation
        Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5),
        ClipsDescendants = false -- Pour voir l'ombre
    })
    Library:Register(Main, "Main"); Utils:AddCorner(Main, 10); Utils:AddStroke(Main, nil, 1)

    -- Effet d'Ombre (Glow)
    local Glow = Utils:Create("ImageLabel", {
        Parent = Main, Size = UDim2.new(1, 100, 1, 100), Position = UDim2.new(0, -50, 0, -50),
        Image = "rbxassetid://6015897843", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5, BackgroundTransparency = 1, ZIndex = -1
    })

    -- Barre Latérale
    local Sidebar = Utils:Create("Frame", {
        Name = "Sidebar", Parent = Main, Size = UDim2.new(0, 180, 1, 0), ZIndex = 2
    })
    Library:Register(Sidebar, "Sidebar"); Utils:AddCorner(Sidebar, 10)
    -- Patch pour coin carré à droite
    local Patch = Utils:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0), BorderSizePixel = 0}); Library:Register(Patch, "Sidebar")

    -- Titre
    local Logo = Utils:Create("TextLabel", {
        Parent = Sidebar, Text = Title, Size = UDim2.new(1,-20,0,50), Position = UDim2.new(0,15,0,0),
        Font = "GothamBlack", TextSize = 20, BackgroundTransparency = 1, TextXAlignment = "Left"
    })
    Library:Register(Logo, "Accent")

    -- Conteneur Onglets
    local TabContainer = Utils:Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1,0,1,-60), Position = UDim2.new(0,0,0,60),
        BackgroundTransparency = 1, ScrollBarThickness = 0, ZIndex = 3
    })
    Utils:Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    -- Zone de Contenu
    local Content = Utils:Create("Frame", {
        Parent = Main, Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1, ClipsDescendants = true
    })

    -- Animation d'ouverture
    Utils:Tween(Main, {Size = UDim2.new(0, 650, 0, 450)}, 0.6)
    Utils:MakeDraggable(Sidebar, Main)

    -- Logique des Onglets
    local WindowFuncs = {}
    local FirstTab = true

    function WindowFuncs:Tab(Name)
        local TabFuncs = {}
        
        local Btn = Utils:Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(0, 160, 0, 36), AutoButtonColor = false,
            Text = "  "..Name, Font = "GothamBold", TextSize = 13, TextXAlignment = "Left"
        })
        Library:Register(Btn, "Sidebar") -- Au repos, même couleur que sidebar
        Library:Register(Btn, "TextDim") -- Au repos, texte gris
        Utils:AddCorner(Btn, 6)

        local Page = Utils:Create("ScrollingFrame", {
            Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false,
            ScrollBarThickness = 2
        })
        Utils:Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0, 8)})
        Utils:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})

        Btn.MouseButton1Click:Connect(function()
            -- Reset des autres onglets
            for _,v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Utils:Tween(v, {BackgroundColor3 = Library.Theme.Sidebar, TextColor3 = Library.Theme.TextDim})
                end
            end
            for _,v in pairs(Content:GetChildren()) do v.Visible = false end
            
            -- Active l'onglet actuel
            Utils:Tween(Btn, {BackgroundColor3 = Library.Theme.Section, TextColor3 = Library.Theme.Text})
            Page.Visible = true
        end)

        if FirstTab then
            FirstTab = false; Page.Visible = true
            Btn.BackgroundColor3 = Library.Theme.Section
            Btn.TextColor3 = Library.Theme.Text
        end

        -- [ COMPOSANT SIMPLE POUR TESTER : SLIDER RGB ] --
        -- C'est ce qui te permet de modifier les couleurs dans le menu
        function TabFuncs:ColorConfig(Text, ColorType)
            local F = Utils:Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,60)}); Library:Register(F, "Section"); Utils:AddCorner(F, 6)
            local L = Utils:Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1}); Library:Register(L, "Text")
            
            local CurrentColor = Library.Theme[ColorType]
            
            -- Slider Rouge
            local function CreateSlider(Prop, YPos, Val)
                local S = Utils:Create("Frame", {Parent = F, Size = UDim2.new(1,-20,0,4), Position = UDim2.new(0,10,0,YPos), BackgroundColor3 = Color3.fromRGB(40,40,40)}); Utils:AddCorner(S, 2)
                local Fill = Utils:Create("Frame", {Parent = S, Size = UDim2.new(Val/255,0,1,0), BackgroundColor3 = Library.Theme.Accent}); Library:Register(Fill, "Accent"); Utils:AddCorner(Fill, 2)
                local Trigger = Utils:Create("TextButton", {Parent = S, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
                
                Trigger.MouseButton1Down:Connect(function()
                    local Move = RunService.RenderStepped:Connect(function()
                        local Mouse = Players.LocalPlayer:GetMouse()
                        local P = math.clamp((Mouse.X - S.AbsolutePosition.X) / S.AbsoluteSize.X, 0, 1)
                        Fill.Size = UDim2.new(P, 0, 1, 0)
                        
                        -- Mise à jour de la couleur globale
                        local R = (Prop == "R") and math.floor(P*255) or math.floor(Library.Theme[ColorType].R * 255)
                        local G = (Prop == "G") and math.floor(P*255) or math.floor(Library.Theme[ColorType].G * 255)
                        local B = (Prop == "B") and math.floor(P*255) or math.floor(Library.Theme[ColorType].B * 255)
                        
                        Library.Theme[ColorType] = Color3.fromRGB(R,G,B)
                        Library:RefreshTheme() -- MAGIE : Tout le menu change
                    end)
                    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Move:Disconnect() end end)
                end)
            end
            
            CreateSlider("R", 25, CurrentColor.R * 255)
            CreateSlider("G", 35, CurrentColor.G * 255)
            CreateSlider("B", 45, CurrentColor.B * 255)
        end

        return TabFuncs
    end
    return WindowFuncs
end

-- [ EXEMPLE D'UTILISATION IMMEDIATE ] --
local Window = Library:Window({Name = "FLUX V1"})

local Tab = Window:Tab("Settings")

-- Ceci crée 3 sliders RGB qui contrôlent instantanément la couleur du menu
Tab:ColorConfig("Accent Color (Main)", "Accent")
Tab:ColorConfig("Background Color", "Main")
Tab:ColorConfig("Sidebar Color", "Sidebar")
