-- [[ 8.8.8.8 HUB | V2.6 ULTIMATE UI ]] --
-- [[ BASE: V2.5 | ADDED: REAL-TIME WATERMARK + SNAPLINES + NOTIFS ]] --

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInput = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Workspace = game:GetService("Workspace"),
    VirtualUser = game:GetService("VirtualUser"),
    Stats = game:GetService("Stats")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local IsMobile = not Services.UserInput.KeyboardEnabled
local DeviceTag = IsMobile and "MOBILE" or "PC"

-- ==================================================================
-- [1] CONFIGURATION
-- ==================================================================
local Settings = {
    -- Combat
    Aimbot_PC = not IsMobile, Aimbot_Mobile = IsMobile,
    AimPart = "Head", Sensitivity = 3, AimKey = Enum.UserInputType.MouseButton2,
    TeamCheck = true, WallCheck = true, FOV_Radius = 150, ShowFOV = true,

    -- Visuals
    ESP_Enabled = true, ESP_Box = true, ESP_Chams = true, ESP_Names = true,
    ESP_HealthBar = true, ESP_Distance = true, ESP_Weapon = true, ESP_Snaplines = false, -- NOUVEAU
    ESP_MaxDistance = 2500,

    -- Player & Misc
    Speed_Active = false, Speed_Value = 16,
    Jump_Active = false, Jump_Value = 50,
    FOV_Changer = false, FOV_Value = 90,
    Watermark = true -- NOUVEAU
}

-- ==================================================================
-- [2] CHARGEMENT UI (TA LIBRARY)
-- ==================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ghost66266/robloxLIBS/refs/heads/main/8.8.8.8libs.lua"))()
local Window = Library:CreateWindow({
    Name = "8.8.8.8 HUB",
    Intro = "V2.6 " .. DeviceTag,
    Color = Color3.fromRGB(119, 120, 255)
})

-- ==================================================================
-- [3] MOBILE TOGGLE BUTTON (INCHANGÉ)
-- ==================================================================
if IsMobile then
    local ScreenGui = Instance.new("ScreenGui", Services.CoreGui)
    local ToggleBtn = Instance.new("TextButton", ScreenGui)
    ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
    ToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBtn.Text = "8.8.8.8"; ToggleBtn.TextColor3 = Color3.fromRGB(119, 120, 255)
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)
    local S = Instance.new("UIStroke", ToggleBtn); S.Color = Color3.fromRGB(119, 120, 255); S.Thickness = 2
    ToggleBtn.MouseButton1Click:Connect(function() Services.VirtualUser:SetKeyDown(Enum.KeyCode.RightShift); wait(0.05); Services.VirtualUser:SetKeyUp(Enum.KeyCode.RightShift) end)
end

-- ==================================================================
-- [4] MENU TABS
-- ==================================================================
local TabCombat = Window:AddTab("Combat")
local TabVisuals = Window:AddTab("Visuals")
local TabPlayer = Window:AddTab("Player")
local TabSettings = Window:AddTab("Settings")

-- Combat
if IsMobile then
    TabCombat:AddToggle("Auto-Lock (Mobile)", true, function(v) Settings.Aimbot_Mobile = v end)
else
    TabCombat:AddToggle("Aimbot (PC)", true, function(v) Settings.Aimbot_PC = v end)
    TabCombat:AddSlider("Smoothness", 1, 10, 3, function(v) Settings.Sensitivity = v end)
end
TabCombat:AddToggle("Team Check", true, function(v) Settings.TeamCheck = v end)
TabCombat:AddToggle("Wall Check (V9)", true, function(v) Settings.WallCheck = v end)

-- Visuals
TabVisuals:AddToggle("Master ESP", true, function(v) Settings.ESP_Enabled = v end)
TabVisuals:AddToggle("Snaplines (Lignes)", false, function(v) Settings.ESP_Snaplines = v end) -- AJOUT
TabVisuals:AddToggle("Box Gradient", true, function(v) Settings.ESP_Box = v end)
TabVisuals:AddToggle("Chams (Glow)", true, function(v) Settings.ESP_Chams = v end)
TabVisuals:AddToggle("Names & Weapon", true, function(v) Settings.ESP_Names = v; Settings.ESP_Weapon = v end)
TabVisuals:AddSlider("Render Dist", 500, 5000, 2500, function(v) Settings.ESP_MaxDistance = v end)

-- Player
TabPlayer:AddToggle("Speed Hack", false, function(v) Settings.Speed_Active = v end)
TabPlayer:AddSlider("Speed Value", 16, 200, 16, function(v) Settings.Speed_Value = v end)
TabPlayer:AddToggle("Jump Hack", false, function(v) Settings.Jump_Active = v end)
TabPlayer:AddSlider("Jump Value", 50, 300, 50, function(v) Settings.Jump_Value = v end)
TabPlayer:AddToggle("POV Changer", false, function(v) Settings.FOV_Changer = v end)
TabPlayer:AddSlider("POV Value", 70, 120, 90, function(v) Settings.FOV_Value = v end)

-- Settings
TabSettings:AddToggle("Show Watermark", true, function(v) Settings.Watermark = v end)
TabSettings:AddToggle("Show FOV Circle", true, function(v) Settings.ShowFOV = v end)
TabSettings:AddSlider("FOV Radius", 50, 500, Settings.FOV_Radius, function(v) Settings.FOV_Radius = v end)

-- ==================================================================
-- [5] WATERMARK & STATS (NOUVEAU)
-- ==================================================================
local WatermarkGui = Instance.new("ScreenGui", Services.CoreGui)
local WFrame = Instance.new("Frame", WatermarkGui)
WFrame.Size = UDim2.new(0, 240, 0, 25)
WFrame.Position = UDim2.new(0.5, -120, 0, 5)
WFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", WFrame).CornerRadius = UDim.new(0, 6)
local WStroke = Instance.new("UIStroke", WFrame); WStroke.Color = Color3.fromRGB(119, 120, 255); WStroke.Thickness = 1.5

local WText = Instance.new("TextLabel", WFrame)
WText.Size = UDim2.new(1, 0, 1, 0); WText.BackgroundTransparency = 1; WText.TextColor3 = Color3.new(1,1,1); WText.Font = Enum.Font.Code; WText.TextSize = 12

Services.RunService.Heartbeat:Connect(function()
    if Settings.Watermark then
        WFrame.Visible = true
        local fps = math.floor(1 / Services.RunService.RenderStepped:Wait())
        local ping = math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        WText.Text = "8.8.8.8 HUB | FPS: "..fps.." | Ping: "..ping.."ms"
    else
        WFrame.Visible = false
    end
end)

-- ==================================================================
-- [6] WALLCHECK & AIMBOT (INCHANGÉ)
-- ==================================================================
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Parts = Camera:GetPartsObscuringTarget({TargetPart.Position}, {LocalPlayer.Character})
    for _, Part in pairs(Parts) do
        if Part.Transparency < 0.3 and Part.CanCollide == true and Part.Name ~= "HumanoidRootPart" then return false end
    end
    return true
end

local FOV_Circle = Drawing.new("Circle"); FOV_Circle.Filled=false; FOV_Circle.Color=Color3.fromRGB(119, 120, 255); FOV_Circle.Thickness=1
Services.RunService.RenderStepped:Connect(function()
    local Center = IsMobile and Camera.ViewportSize/2 or Services.UserInput:GetMouseLocation()
    FOV_Circle.Visible = Settings.ShowFOV; FOV_Circle.Radius = Settings.FOV_Radius; FOV_Circle.Position = Center
    local Target = nil; local MinDist = Settings.FOV_Radius
    for _, Player in pairs(Services.Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            local Head = Player.Character[Settings.AimPart]
            if IsVisible(Head) then
                local HeadPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                local DistToCenter = (Vector2.new(HeadPos.X, HeadPos.Y) - Center).Magnitude
                if OnScreen and DistToCenter < MinDist then MinDist = DistToCenter; Target = Head end
            end
        end
    end
    if Target then
        if IsMobile and Settings.Aimbot_Mobile then Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        elseif not IsMobile and Settings.Aimbot_PC and Services.UserInput:IsMouseButtonPressed(Settings.AimKey) then
            local Pos = Camera:WorldToViewportPoint(Target.Position)
            mousemoverel((Pos.X - Center.X)/Settings.Sensitivity, (Pos.Y - Center.Y)/Settings.Sensitivity)
        end
    end
end)

-- ==================================================================
-- [7] ESP ENGINE (TON CODE + SNAPLINES)
-- ==================================================================
local function Create(Class, Properties)
    local _Instance = Instance.new(Class); for Property, Value in pairs(Properties) do _Instance[Property] = Value end
    return _Instance
end

local function AddESP(plr)
    if Services.CoreGui:FindFirstChild(plr.Name.."_ESP") then Services.CoreGui[plr.Name.."_ESP"]:Destroy() end
    local SG = Create("ScreenGui", {Parent = Services.CoreGui, Name = plr.Name.."_ESP"})
    local Name = Create("TextLabel", {Parent = SG, BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Code, TextSize = 11, Visible = false})
    local Box = Create("Frame", {Parent = SG, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false})
    local BoxS = Create("UIStroke", {Parent = Box, Thickness = 1.5, Color = Color3.fromRGB(119, 120, 255)})
    local Cham = Create("Highlight", {Parent = SG, FillColor = Color3.fromRGB(119, 120, 255), FillTransparency = 0.5, Enabled = false})
    local Line = Drawing.new("Line"); Line.Thickness = 1.5; Line.Color = Color3.fromRGB(119, 120, 255); Line.Visible = false

    Services.RunService.RenderStepped:Connect(function()
        if not plr or not plr.Parent or not plr.Character then 
            SG:Destroy(); Line:Remove(); return 
        end
        local Char = plr.Character; local Root = Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char:FindFirstChild("Humanoid")
        local Enemy = true; if Settings.TeamCheck and plr.Team == LocalPlayer.Team then Enemy = false end

        if Settings.ESP_Enabled and Root and Hum and Hum.Health > 0 and Enemy then
            local Pos, OnScreen = Camera:WorldToScreenPoint(Root.Position)
            local Dist = (Camera.CFrame.Position - Root.Position).Magnitude
            if OnScreen and Dist < Settings.ESP_MaxDistance then
                local Size = 2000 / Dist; local BoxPos = Vector2.new(Pos.X - Size/2, Pos.Y - Size/2)
                if Settings.ESP_Box then Box.Visible=true; Box.Position=UDim2.new(0,BoxPos.X,0,BoxPos.Y); Box.Size=UDim2.new(0,Size,0,Size) else Box.Visible=false end
                if Settings.ESP_Names then Name.Visible=true; Name.Position=UDim2.new(0,Pos.X-50,0,BoxPos.Y-15); Name.Text=plr.Name.." ["..math.floor(Dist/3).."m]" else Name.Visible=false end
                if Settings.ESP_Chams then Cham.Adornee=Char; Cham.Enabled=true else Cham.Enabled=false end
                if Settings.ESP_Snaplines then 
                    Line.Visible = true; Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); Line.To = Vector2.new(Pos.X, Pos.Y) 
                else Line.Visible = false end
            else Box.Visible=false; Name.Visible=false; Cham.Enabled=false; Line.Visible=false end
        else Box.Visible=false; Name.Visible=false; Cham.Enabled=false; Line.Visible=false end
    end)
end
for _, p in pairs(Services.Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Services.Players.PlayerAdded:Connect(AddESP)

-- ==================================================================
-- [8] PLAYER ENGINE
-- ==================================================================
Services.RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Hum = LocalPlayer.Character.Humanoid
        if Settings.Speed_Active then Hum.WalkSpeed = Settings.Speed_Value end
        if Settings.Jump_Active then Hum.UseJumpPower = true; Hum.JumpPower = Settings.Jump_Value end
    end
    if Settings.FOV_Changer then Camera.FieldOfView = Settings.FOV_Value end
end)
