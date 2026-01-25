-- [[ 8.8.8.8 PROJECT | V55 MOBILE & PC ULTIMATE ]] --
-- [[ AUTO-DETECT DEVICE + PLAYER CARD + NO LAG ]] --

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInput = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace"),
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- 1. DETECTION INTELLIGENTE (MOBILE VS PC)
local IsMobile = Services.UserInput.TouchEnabled and not Services.UserInput.KeyboardEnabled

if not Drawing then 
    -- Sécurité pour certains executeurs mobile qui n'ont pas Drawing
    return warn("Exploit not supported (Missing Drawing Lib)") 
end

-- --- CONFIGURATION (SETTINGS) ---
local Settings = {
    -- COMBAT
    Aimbot = false,
    AimPart = "Head",
    Sensitivity = 3,
    -- Adaptation automatique de la touche : Taper (Mobile) ou Clic Droit (PC)
    AimKey = IsMobile and Enum.UserInputType.MouseButton1 or Enum.UserInputType.MouseButton2,
    
    -- VISUALS
    ESP_Enabled = true,
    ESP_Box = true,         
    ESP_Skeleton = true,    
    ESP_Snaplines = false,   
    ESP_Names = true,       
    ESP_HealthBar = true,
    ESP_DistLimit = 1500, -- Optimisation distance
    
    ESP_Color = Color3.fromRGB(255, 60, 60),
    TeamCheck = true,

    -- WORLD / MISC
    CameraFOV = 100,
    EnableFOVChange = false,
    Crosshair = false,

    -- UI SETTINGS
    ShowWatermark = true,
    ShowFOV = true,
    FOV_Radius = IsMobile and 130 or 150 -- Rayon plus petit sur mobile
}

-- --- UI LIBRARY ---
local Library = {}
local UIConfig = {
    Main = Color3.fromRGB(25, 25, 30),
    Sidebar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 140, 255), -- Bleu Cyber
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Item = Color3.fromRGB(40, 40, 45)
}

function Library:Tween(obj, props, time)
    local info = TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    Services.TweenService:Create(obj, info, props):Play()
end

function Library:Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

function Library:CreateWindow()
    if Services.CoreGui:FindFirstChild("Project8888_V55") then Services.CoreGui.Project8888_V55:Destroy() end
    
    local Screen = Library:Create("ScreenGui", {Name = "Project8888_V55", Parent = Services.CoreGui, ResetOnSpawn = false})
    
    -- TAILLE ADAPTATIVE
    -- Mobile : Plus compact (340x300) | PC : Large (550x400)
    local WinSize = IsMobile and UDim2.new(0, 340, 0, 300) or UDim2.new(0, 550, 0, 400)
    
    local Main = Library:Create("Frame", {
        Parent = Screen, Size = WinSize, Position = UDim2.new(0.5,0,0.5,0), 
        AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = UIConfig.Main, 
        ClipsDescendants = true, Active = true, Draggable = true
    })
    Library:Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    Library:Create("UIStroke", {Parent = Main, Color = Color3.fromRGB(50,50,55), Thickness = 1})

    -- Sidebar
    local Sidebar = Library:Create("Frame", {Parent = Main, Size = UDim2.new(0, 110, 1, 0), BackgroundColor3 = UIConfig.Sidebar, BorderSizePixel = 0})
    Library:Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    Library:Create("Frame", {Parent = Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1,-10,0,0), BackgroundColor3 = UIConfig.Sidebar, BorderSizePixel=0})
    
    -- Title: 8.8.8.8 HUB
    local Title = Library:Create("TextLabel", {Parent = Sidebar, Text = "8.8.8.8", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = UIConfig.Accent, Position = UDim2.new(0,0,0,10)})
    Library:Create("TextLabel", {Parent = Title, Text = "HUB V55", Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = UIConfig.TextDark})

    -- Containers
    local TabContainer = Library:Create("Frame", {Parent = Sidebar, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1})
    Library:Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local PagesContainer = Library:Create("Frame", {Parent = Main, Size = UDim2.new(1, -120, 1, -20), Position = UDim2.new(0, 120, 0, 10), BackgroundTransparency = 1})

    -- PLAYER CARD (Bas Gauche)
    local Card = Library:Create("Frame", {
        Parent = Screen, Size = UDim2.new(0, 200, 0, 50), Position = UDim2.new(0, 10, 1, -60),
        BackgroundColor3 = UIConfig.Main, BackgroundTransparency = 0.1, Visible = Settings.ShowWatermark
    })
    Library:Create("UICorner", {Parent = Card, CornerRadius = UDim.new(0, 8)})
    Library:Create("UIStroke", {Parent = Card, Color = UIConfig.Item, Thickness = 1})

    local Avatar = Library:Create("ImageLabel", {
        Parent = Card, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0.5, -15),
        BackgroundColor3 = UIConfig.Item, Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    })
    Library:Create("UICorner", {Parent = Avatar, CornerRadius = UDim.new(1, 0)})
    
    task.spawn(function()
        local content, isReady = Services.Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then Avatar.Image = content end
    end)

    Library:Create("TextLabel", {
        Parent = Card, Text = LocalPlayer.DisplayName, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 50, 0, 5),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
    })
    Library:Create("TextLabel", {
        Parent = Card, Text = "@" .. LocalPlayer.Name, Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 50, 0, 25),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextColor3 = UIConfig.TextDark, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
    })

    -- BOUTON MOBILE / TOUCHE PC
    if IsMobile then
        -- Bouton Rouage Tactile
        local MobBtn = Library:Create("TextButton", {
            Parent = Screen, Text = "⚙", Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = UIConfig.Main, TextColor3 = UIConfig.Accent, Font = Enum.Font.GothamBold, TextSize = 24
        })
        Library:Create("UICorner", {Parent = MobBtn, CornerRadius = UDim.new(1,0)})
        Library:Create("UIStroke", {Parent = MobBtn, Color = UIConfig.Accent, Thickness = 2})
        MobBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
    else
        -- Touche Insert
        Services.UserInput.InputBegan:Connect(function(i,p) if not p and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)
    end
    
    return {Tabs = TabContainer, Pages = PagesContainer, Main = Main, Card = Card}
end

local Window = Library:CreateWindow()

-- Fonctions de la Lib UI (Tabs, Toggles, Sliders)
function Library:AddTab(Name)
    local Page = Library:Create("ScrollingFrame", {Parent = Window.Pages, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 2, Visible = false, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0)})
    Library:Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
    Library:Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,5), PaddingLeft = UDim.new(0,5)})
    
    local Btn = Library:Create("TextButton", {Parent = Window.Tabs, Size = UDim2.new(1, -10, 0, 35), BackgroundColor3 = UIConfig.Sidebar, Text = Name, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.TextDark, TextSize = 12, AutoButtonColor = false})
    Library:Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
    
    local function Activate()
        for _, v in pairs(Window.Pages:GetChildren()) do v.Visible = false end
        for _, v in pairs(Window.Tabs:GetChildren()) do if v:IsA("TextButton") then Library:Tween(v, {TextColor3 = UIConfig.TextDark, BackgroundTransparency = 1}) end end
        Page.Visible = true; Library:Tween(Btn, {TextColor3 = UIConfig.Accent, BackgroundTransparency = 0.9})
    end
    Btn.MouseButton1Click:Connect(Activate)
    if #Window.Tabs:GetChildren() == 2 then Activate() end
    return Page
end

function Library:AddToggle(Page, Text, Flag, Callback)
    local Container = Library:Create("TextButton", {Parent = Page, Size = UDim2.new(1, -10, 0, 40), BackgroundColor3 = UIConfig.Item, Text = "", AutoButtonColor = false})
    Library:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
    Library:Create("TextLabel", {Parent = Container, Text = Text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local SwitchBg = Library:Create("Frame", {Parent = Container, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 65)})
    Library:Create("UICorner", {Parent = SwitchBg, CornerRadius = UDim.new(1, 0)})
    local Dot = Library:Create("Frame", {Parent = SwitchBg, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
    Library:Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})
    
    local function Update()
        if Settings[Flag] then Library:Tween(SwitchBg, {BackgroundColor3 = UIConfig.Accent}); Library:Tween(Dot, {Position = UDim2.new(1, -18, 0.5, -8)})
        else Library:Tween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}); Library:Tween(Dot, {Position = UDim2.new(0, 2, 0.5, -8)}) end
        if Callback then Callback(Settings[Flag]) end
    end
    Container.MouseButton1Click:Connect(function() Settings[Flag] = not Settings[Flag]; Update() end); Update()
end

function Library:AddSlider(Page, Text, Flag, Min, Max)
    local Container = Library:Create("Frame", {Parent = Page, Size = UDim2.new(1, -10, 0, 55), BackgroundColor3 = UIConfig.Item}); Library:Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
    Library:Create("TextLabel", {Parent = Container, Text = Text, Size = UDim2.new(1, -10, 0, 25), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamSemibold, TextColor3 = UIConfig.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Val = Library:Create("TextLabel", {Parent = Container, Text = tostring(Settings[Flag]), Size = UDim2.new(0, 30, 0, 25), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextColor3 = UIConfig.Accent, TextSize = 13})
    local BarBg = Library:Create("Frame", {Parent = Container, Size = UDim2.new(1, -30, 0, 4), Position = UDim2.new(0, 15, 0, 35), BackgroundColor3 = Color3.fromRGB(60, 60, 65)}); Library:Create("UICorner", {Parent = BarBg, CornerRadius = UDim.new(1, 0)})
    local Fill = Library:Create("Frame", {Parent = BarBg, Size = UDim2.new((Settings[Flag]-Min)/(Max-Min), 0, 1, 0), BackgroundColor3 = UIConfig.Accent}); Library:Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
    local Trig = Library:Create("TextButton", {Parent = Container, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
    
    local function Move(Input)
        local P = math.clamp((Input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
        local V = math.floor(Min + ((Max - Min) * P))
        Settings[Flag] = V; Val.Text = tostring(V); Library:Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
    end
    -- Support Tactile + Souris
    Trig.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then Move(i); local c; c=Services.UserInput.InputChanged:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then Move(io) end end); local r; r=Services.UserInput.InputEnded:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then c:Disconnect(); r:Disconnect() end end) end end)
end

-- --- CONSTRUCTION DU MENU ---
local TabCombat = Library:AddTab("Combat")
Library:AddToggle(TabCombat, "Enabled", "Aimbot")
Library:AddSlider(TabCombat, "Smoothness", "Sensitivity", 1, 15)
Library:AddToggle(TabCombat, "Team Check", "TeamCheck")

local TabVisuals = Library:AddTab("Visuals")
Library:AddToggle(TabVisuals, "Enable ESP", "ESP_Enabled")
Library:AddToggle(TabVisuals, "Box (2D)", "ESP_Box")
Library:AddToggle(TabVisuals, "Skeleton", "ESP_Skeleton")
Library:AddToggle(TabVisuals, "Snaplines", "ESP_Snaplines")
Library:AddToggle(TabVisuals, "Names", "ESP_Names")
Library:AddToggle(TabVisuals, "Health Bar", "ESP_HealthBar")
Library:AddSlider(TabVisuals, "Render Dist", "ESP_DistLimit", 500, 5000)

local TabWorld = Library:AddTab("World")
Library:AddToggle(TabWorld, "Force POV", "EnableFOVChange")
Library:AddSlider(TabWorld, "FOV Angle", "CameraFOV", 70, 120)
Library:AddToggle(TabWorld, "Crosshair", "Crosshair")

local TabSettings = Library:AddTab("Settings")
Library:AddToggle(TabSettings, "Player Card", "ShowWatermark", function(v) Window.Card.Visible = v end)
Library:AddToggle(TabSettings, "Show Radius", "ShowFOV")
Library:AddSlider(TabSettings, "Radius Size", "FOV_Radius", 50, 500)

-- --- MOTEUR (V51 OPTIMISÉ) ---
local Cache = {}
local CrosshairX = Drawing.new("Line"); local CrosshairY = Drawing.new("Line")

local function CreateDrawings()
    local D = {}
    D.Box = Drawing.new("Square"); D.Box.Thickness=1.5; D.Box.Filled=false
    D.Snap = Drawing.new("Line"); D.Snap.Thickness=1
    D.Name = Drawing.new("Text"); D.Name.Size=13; D.Name.Center=true; D.Name.Outline=true; D.Name.Color=Color3.new(1,1,1)
    D.HPBg = Drawing.new("Square"); D.HPBg.Filled=true; D.HPBg.Color=Color3.new(0,0,0); D.HPBg.Transparency=0.5
    D.HP = Drawing.new("Square"); D.HP.Filled=true; D.HP.Color=Color3.new(0,1,0)
    D.Skeleton = {}; for i=1, 15 do table.insert(D.Skeleton, Drawing.new("Line")) end
    return D
end

local function RemoveDrawings(D)
    if not D then return end
    D.Box:Remove(); D.Snap:Remove(); D.Name:Remove(); D.HPBg:Remove(); D.HP:Remove()
    for _,L in pairs(D.Skeleton) do L:Remove() end
end

local function AddToCache(Player) if Player ~= LocalPlayer and not Cache[Player] then Cache[Player] = CreateDrawings() end end
local function RemoveFromCache(Player) if Cache[Player] then RemoveDrawings(Cache[Player]); Cache[Player] = nil end end

for _, P in pairs(Services.Players:GetPlayers()) do AddToCache(P) end
Services.Players.PlayerAdded:Connect(AddToCache)
Services.Players.PlayerRemoving:Connect(RemoveFromCache)

local function GetParts(Player)
    local Char = Player.Character
    if not Char then return nil, nil, nil end
    return Char:FindFirstChild("Head"), Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Torso"), Char:FindFirstChild("Humanoid")
end

local function IsAlly(Player)
    if not Settings.TeamCheck then return false end
    return Player.Team == LocalPlayer.Team
end

-- RENDER
local FOV_Circle = Drawing.new("Circle"); FOV_Circle.Filled=false; FOV_Circle.Thickness=1; FOV_Circle.Color=Color3.new(1,1,1)

Services.RunService.RenderStepped:Connect(function()
    local Mouse = Services.UserInput:GetMouseLocation()
    local ScreenSize = Camera.ViewportSize
    
    -- CROSSHAIR
    if Settings.Crosshair then
        CrosshairX.Visible = true; CrosshairY.Visible = true
        CrosshairX.From = Vector2.new(ScreenSize.X/2 - 8, ScreenSize.Y/2); CrosshairX.To = Vector2.new(ScreenSize.X/2 + 8, ScreenSize.Y/2)
        CrosshairY.From = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2 - 8); CrosshairY.To = Vector2.new(ScreenSize.X/2, ScreenSize.Y/2 + 8)
        CrosshairX.Color = Color3.new(1,0,0); CrosshairY.Color = Color3.new(1,0,0)
    else CrosshairX.Visible = false; CrosshairY.Visible = false end

    if Settings.EnableFOVChange then Camera.FieldOfView = Settings.CameraFOV end

    FOV_Circle.Visible = Settings.ShowFOV; FOV_Circle.Radius = Settings.FOV_Radius; FOV_Circle.Position = Mouse
    
    local Target = nil
    local MinDist = Settings.FOV_Radius

    for Player, Draw in pairs(Cache) do
        local Head, Root, Hum = GetParts(Player)
        
        -- Verification de base
        if not Head or not Root or not Hum or Hum.Health <= 0 then
            Draw.Box.Visible=false; Draw.Snap.Visible=false; Draw.Name.Visible=false; Draw.HPBg.Visible=false; Draw.HP.Visible=false
            for _,L in pairs(Draw.Skeleton) do L.Visible=false end
            continue
        end

        local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
        local Dist = (Camera.CFrame.Position - Root.Position).Magnitude

        -- Optimization distance
        if not OnScreen or Dist > Settings.ESP_DistLimit then
            Draw.Box.Visible=false; Draw.Snap.Visible=false; Draw.Name.Visible=false; Draw.HPBg.Visible=false; Draw.HP.Visible=false
            for _,L in pairs(Draw.Skeleton) do L.Visible=false end
            continue
        end

        local Teammate = IsAlly(Player)
        local ShouldDraw = Settings.ESP_Enabled and not Teammate
        local Color = Settings.ESP_Color

        if ShouldDraw then
            local H = (3000 / Dist) * 1.5; local W = H * 0.6
            local BoxPos = Vector2.new(Pos.X - W/2, Pos.Y - H/2)

            if Settings.ESP_Box then
                Draw.Box.Visible=true; Draw.Box.Size=Vector2.new(W,H); Draw.Box.Position=BoxPos; Draw.Box.Color=Color
            else Draw.Box.Visible=false end

            if Settings.ESP_Snaplines then
                Draw.Snap.Visible=true; Draw.Snap.From=Vector2.new(ScreenSize.X/2, ScreenSize.Y); Draw.Snap.To=Vector2.new(Pos.X, Pos.Y + H/2); Draw.Snap.Color=Color
            else Draw.Snap.Visible=false end

            if Settings.ESP_Names then
                Draw.Name.Visible=true; Draw.Name.Text=Player.Name; Draw.Name.Position=Vector2.new(Pos.X, BoxPos.Y - 16)
            else Draw.Name.Visible=false end

            if Settings.ESP_HealthBar then
                Draw.HPBg.Visible=true; Draw.HPBg.Size=Vector2.new(3, H); Draw.HPBg.Position=Vector2.new(BoxPos.X - 5, BoxPos.Y)
                local HealthY = H * (Hum.Health / Hum.MaxHealth)
                Draw.HP.Visible=true; Draw.HP.Size=Vector2.new(3, HealthY); Draw.HP.Position=Vector2.new(BoxPos.X - 5, BoxPos.Y + (H - HealthY))
            else Draw.HPBg.Visible=false; Draw.HP.Visible=false end

            if Settings.ESP_Skeleton and Dist < 300 then
                local function Line(Idx, P1, P2)
                    local L = Draw.Skeleton[Idx]; if not L then return end
                    local V1, S1 = Camera:WorldToViewportPoint(P1.Position); local V2, S2 = Camera:WorldToViewportPoint(P2.Position)
                    if S1 and S2 then L.Visible=true; L.From=Vector2.new(V1.X,V1.Y); L.To=Vector2.new(V2.X,V2.Y); L.Color=Color else L.Visible=false end
                end
                
                local Char = Player.Character; local T = Char:FindFirstChild("UpperTorso") or Char:FindFirstChild("Torso")
                if T then
                    Line(1, Head, T)
                    local LA, RA = Char:FindFirstChild("LeftUpperArm") or Char:FindFirstChild("Left Arm"), Char:FindFirstChild("RightUpperArm") or Char:FindFirstChild("Right Arm")
                    local LL, RL = Char:FindFirstChild("LeftUpperLeg") or Char:FindFirstChild("Left Leg"), Char:FindFirstChild("RightUpperLeg") or Char:FindFirstChild("Right Leg")
                    if LA then Line(2, T, LA) end; if RA then Line(3, T, RA) end
                    if LL then Line(4, T, LL) end; if RL then Line(5, T, RL) end
                end
            else for _,L in pairs(Draw.Skeleton) do L.Visible=false end end

            if Settings.Aimbot then
                local HeadPos = Camera:WorldToViewportPoint(Head.Position)
                local DistToMouse = (Vector2.new(HeadPos.X, HeadPos.Y) - Mouse).Magnitude
                if DistToMouse < MinDist then MinDist = DistToMouse; Target = Head end
            end
        else
            Draw.Box.Visible=false; Draw.Snap.Visible=false; Draw.Name.Visible=false; Draw.HPBg.Visible=false; Draw.HP.Visible=false
            for _,L in pairs(Draw.Skeleton) do L.Visible=false end
        end
    end

    if Target and Services.UserInput:IsMouseButtonPressed(Settings.AimKey) then
        local Pos = Camera:WorldToViewportPoint(Target.Position)
        -- Protection si mousemoverel n'existe pas
        if mousemoverel then
            mousemoverel((Pos.X - Mouse.X)/Settings.Sensitivity, (Pos.Y - Mouse.Y)/Settings.Sensitivity)
        end
    end
end)

Services.CoreGui.ChildRemoved:Connect(function(c) 
    if c.Name=="Project8888_V55" then 
        FOV_Circle:Remove(); CrosshairX:Remove(); CrosshairY:Remove(); 
        for _, D in pairs(Cache) do RemoveDrawings(D) end 
    end 
end)

pcall(function() 
    local Platform = IsMobile and "MOBILE" or "PC"
    Services.StarterGui:SetCore("SendNotification", {Title="8.8.8.8 V55", Text="Ready on "..Platform, Duration=3}) 
end)
