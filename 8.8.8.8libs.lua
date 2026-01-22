-- [[ ECLIPSE UI V60 | CHAMELEON ENGINE (REAL-TIME THEME) ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    Flags = {},
    Registry = {}, -- Stocke tous les objets pour les repeindre
    Theme = {
        Main = Color3.fromRGB(25, 25, 30),
        Sidebar = Color3.fromRGB(20, 20, 25),
        Section = Color3.fromRGB(32, 32, 38),
        Stroke = Color3.fromRGB(50, 50, 55),
        Accent = Color3.fromRGB(115, 80, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(145, 145, 155)
    },
    Rainbow = false
}

-- [ 1. SYSTEME DE REGISTRE (Le Secret du Temps Réel) ] --
local function Register(Obj, Type)
    table.insert(Library.Registry, {Obj = Obj, Type = Type})
    return Obj
end

function Library:RefreshTheme()
    for _, Item in pairs(Library.Registry) do
        local Obj = Item.Obj
        local Type = Item.Type
        if Obj and Obj.Parent then
            if Type == "Main" then Tween(Obj, {BackgroundColor3 = Library.Theme.Main})
            elseif Type == "Sidebar" then Tween(Obj, {BackgroundColor3 = Library.Theme.Sidebar})
            elseif Type == "Section" then Tween(Obj, {BackgroundColor3 = Library.Theme.Section})
            elseif Type == "Stroke" then if Obj:IsA("UIStroke") then Tween(Obj, {Color = Library.Theme.Stroke}) end
            elseif Type == "Accent" then Tween(Obj, {BackgroundColor3 = Library.Theme.Accent})
            elseif Type == "AccentText" then Tween(Obj, {TextColor3 = Library.Theme.Accent})
            elseif Type == "Text" then Tween(Obj, {TextColor3 = Library.Theme.Text})
            elseif Type == "TextDim" then Tween(Obj, {TextColor3 = Library.Theme.TextDim})
            end
        end
    end
end

-- [ 2. UTILS ] --
local function Create(Class, Props)
    local Obj = Instance.new(Class)
    for k, v in pairs(Props) do Obj[k] = v end
    return Obj
end

local function AddStroke(Obj, Type)
    local Stroke = Create("UIStroke", {Parent = Obj, Color = Library.Theme.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    Register(Stroke, Type or "Stroke")
    return Stroke
end

local function AddCorner(Obj, Radius)
    return Create("UICorner", {Parent = Obj, CornerRadius = UDim.new(0, Radius or 6)})
end

function Tween(Obj, Props, Time)
    TweenService:Create(Obj, TweenInfo.new(Time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Props):Play()
end

local function MakeDraggable(Top, Main)
    local Dragging, DragStart, StartPos
    Top.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = i.Position; StartPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local Delta = i.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ RAINBOW LOOP ] --
task.spawn(function()
    while true do
        if Library.Rainbow then
            local Hue = tick() % 5 / 5
            Library.Theme.Accent = Color3.fromHSV(Hue, 1, 1)
            Library:RefreshTheme() -- Met à jour tout le menu en temps réel
        end
        RunService.RenderStepped:Wait()
    end
end)

-- [ 3. SAVE SYSTEM ] --
function Library:SaveConfig(Name)
    if not isfolder("WindConfigs") then makefolder("WindConfigs") end
    writefile("WindConfigs/"..Name..".json", HttpService:JSONEncode(Library.Flags))
end
function Library:LoadConfig(Name)
    if isfile("WindConfigs/"..Name..".json") then
        local data = HttpService:JSONDecode(readfile("WindConfigs/"..Name..".json"))
        for k,v in pairs(data) do Library.Flags[k] = v end
        return true
    end
end

-- [ 4. MAIN ] --
function Library:Window(Config)
    local Title = Config.Title or "Eclipse"
    for _,v in pairs(CoreGui:GetChildren()) do if v.Name == "Eclipse_"..Title then v:Destroy() end end
    local GUI = Create("ScreenGui", {Name = "Eclipse_"..Title, Parent = CoreGui, IgnoreGuiInset = true})
    
    local Main = Register(Create("Frame", {Parent = GUI, Size = UDim2.new(0, 600, 0, 420), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Library.Theme.Main}), "Main")
    AddCorner(Main, 8); AddStroke(Main, "Accent")
    
    local Topbar = Register(Create("Frame", {Parent = Main, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Library.Theme.Sidebar}), "Sidebar")
    AddCorner(Topbar, 8); MakeDraggable(Topbar, Main); Create("Frame", {Parent = Topbar, Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,1,-10), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0})
    Register(Create("TextLabel", {Parent = Topbar, Text = Title, Size = UDim2.new(0,200,1,0), Position = UDim2.new(0,15,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "GothamBold", TextSize = 16, TextXAlignment = "Left"}), "Text")
    
    local TabHolder = Register(Create("ScrollingFrame", {Parent = Main, Size = UDim2.new(0,160,1,-40), Position = UDim2.new(0,0,0,40), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0, ScrollBarThickness = 0}), "Sidebar")
    Create("UIListLayout", {Parent = TabHolder, SortOrder = "LayoutOrder", Padding = UDim.new(0,5)}); Create("UIPadding", {Parent = TabHolder, PaddingTop = UDim.new(0,10)})
    local ContentHolder = Create("Frame", {Parent = Main, Size = UDim2.new(1,-160,1,-40), Position = UDim2.new(0,160,0,40), BackgroundTransparency = 1})

    local Funcs = {}
    local First = true

    function Funcs:Tab(Name)
        local TabBtn = Register(Create("TextButton", {Parent = TabHolder, Size = UDim2.new(1,0,0,32), BackgroundColor3 = Library.Theme.Main, Text = Name, TextColor3 = Library.Theme.TextDim, Font = "GothamMedium", TextSize = 13, AutoButtonColor = false}), "Main")
        AddCorner(TabBtn, 6)
        
        local Page = Create("ScrollingFrame", {Parent = ContentHolder, Size = UDim2.new(1,0,1,0), Visible = false, BackgroundTransparency = 1, ScrollBarThickness = 2})
        Create("UIListLayout", {Parent = Page, SortOrder = "LayoutOrder", Padding = UDim.new(0,10)}); Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)})
        Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,Page.UIListLayout.AbsoluteContentSize.Y + 20) end)

        TabBtn.MouseButton1Click:Connect(function()
            for _,v in pairs(TabHolder:GetChildren()) do if v:IsA("TextButton") then Tween(v, {BackgroundColor3 = Library.Theme.Main, TextColor3 = Library.Theme.TextDim}) end end
            for _,v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            Tween(TabBtn, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Text})
            Page.Visible = true
        end)
        if First then First = false; Page.Visible = true; TabBtn.BackgroundColor3 = Library.Theme.Accent; TabBtn.TextColor3 = Library.Theme.Text end

        local TFuncs = {}
        function TFuncs:Section(Text)
            local F = Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
            Register(Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = "GothamBold", TextSize = 12, TextXAlignment = "Left"}), "AccentText")
        end
        function TFuncs:Toggle(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or false
            local F = Register(Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,36), BackgroundColor3 = Library.Theme.Section}), "Section"); AddCorner(F, 6); AddStroke(F, "Stroke")
            Register(Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local Switch = Register(Create("Frame", {Parent = F, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-50,0.5,-10), BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main}), Library.Flags[Flag] and "Accent" or "Main"); AddCorner(Switch, 10)
            local Dot = Create("Frame", {Parent = Switch, Size = UDim2.new(0,16,0,16), Position = Library.Flags[Flag] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3 = Color3.new(1,1,1)}); AddCorner(Dot, 8)
            Create("TextButton", {Parent = F, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}).MouseButton1Click:Connect(function()
                Library.Flags[Flag] = not Library.Flags[Flag]
                Tween(Switch, {BackgroundColor3 = Library.Flags[Flag] and Library.Theme.Accent or Library.Theme.Main})
                Tween(Dot, {Position = Library.Flags[Flag] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
                if Callback then Callback(Library.Flags[Flag]) end
            end)
        end
        function TFuncs:Button(Text, Callback)
            local B = Register(Create("TextButton", {Parent = Page, Size = UDim2.new(1,0,0,32), BackgroundColor3 = Library.Theme.Section, Text = Text, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13}), "Section"); AddCorner(B, 6); AddStroke(B, "Stroke")
            B.MouseButton1Click:Connect(function() Tween(B, {BackgroundColor3 = Library.Theme.Accent}); task.wait(0.1); Tween(B, {BackgroundColor3 = Library.Theme.Section}); pcall(Callback) end)
        end
        function TFuncs:ColorPicker(Text, Flag, Default, Callback)
            Library.Flags[Flag] = Default or Color3.new(1,1,1)
            local F = Register(Create("Frame", {Parent = Page, Size = UDim2.new(1,0,0,36), BackgroundColor3 = Library.Theme.Section}), "Section"); AddCorner(F, 6); AddStroke(F, "Stroke")
            Register(Create("TextLabel", {Parent = F, Text = Text, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Library.Theme.Text, Font = "Gotham", TextSize = 13, TextXAlignment = "Left"}), "Text")
            local P = Create("TextButton", {Parent = F, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-50,0.5,-10), BackgroundColor3 = Library.Flags[Flag], Text = ""}); AddCorner(P, 4)
            -- Hacky randomizer for demo
            P.MouseButton1Click:Connect(function() 
                local C = Color3.fromHSV(math.random(),1,1); Library.Flags[Flag] = C; P.BackgroundColor3 = C 
                if Callback then Callback(C) end
            end)
        end
        return TFuncs
    end
    return Funcs
end
return Library
