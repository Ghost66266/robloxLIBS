-- [[ 8.8.8.8 WIND-UI LIBRARY ]] --
-- [[ VERSION: V32 LIVE EDITOR | AUTHOR: GHOST66266 ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Library = {}
Library.Registry = {} -- Stocke tous les objets pour les mettre à jour en direct
Library.ActiveWindow = nil

-- [ 1. THEMES ] --
Library.Themes = {
	Dark = {
		Main = Color3.fromRGB(20, 20, 25), Sidebar = Color3.fromRGB(15, 15, 20),
		Section = Color3.fromRGB(28, 28, 32), Accent = Color3.fromRGB(120, 90, 255),
		Text = Color3.fromRGB(240, 240, 240), TextDark = Color3.fromRGB(140, 140, 150),
		Outline = Color3.fromRGB(20, 20, 25), Control = Color3.fromRGB(255, 255, 255)
	},
	Light = {
		Main = Color3.fromRGB(240, 240, 245), Sidebar = Color3.fromRGB(225, 225, 230),
		Section = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(0, 120, 215),
		Text = Color3.fromRGB(20, 20, 20), TextDark = Color3.fromRGB(100, 100, 110),
		Outline = Color3.fromRGB(240, 240, 245), Control = Color3.fromRGB(20, 20, 20)
	},
	Midnight = {
		Main = Color3.fromRGB(10, 10, 15), Sidebar = Color3.fromRGB(5, 5, 10),
		Section = Color3.fromRGB(18, 18, 24), Accent = Color3.fromRGB(255, 50, 100),
		Text = Color3.fromRGB(255, 255, 255), TextDark = Color3.fromRGB(120, 120, 130),
		Outline = Color3.fromRGB(10, 10, 15), Control = Color3.fromRGB(200, 200, 255)
	}
}
Library.Theme = Library.Themes.Dark -- Défaut
Library.CornerRadius = 6 -- Rayon d'arrondi global par défaut

-- [ 2. SYSTÈME DE MISE À JOUR LIVE ] --
local function AddToRegistry(Type, Instance)
	table.insert(Library.Registry, {Type = Type, Obj = Instance})
end

function Library:Refresh()
	-- Met à jour TOUT ce qui est à l'écran avec les nouvelles couleurs
	for _, Item in pairs(Library.Registry) do
		local Obj = Item.Obj
		local Type = Item.Type
		if not Obj or not Obj.Parent then goto continue end
		
		if Type == "Main" then Obj.BackgroundColor3 = Library.Theme.Main; Obj.BorderColor3 = Library.Theme.Main
		elseif Type == "Sidebar" then Obj.BackgroundColor3 = Library.Theme.Sidebar
		elseif Type == "Section" then Obj.BackgroundColor3 = Library.Theme.Section
		elseif Type == "Text" then Obj.TextColor3 = Library.Theme.Text
		elseif Type == "TextDark" then Obj.TextColor3 = Library.Theme.TextDark
		elseif Type == "Accent" then Obj.BackgroundColor3 = Library.Theme.Accent
		elseif Type == "AccentText" then Obj.TextColor3 = Library.Theme.Accent
		elseif Type == "Control" then Obj.TextColor3 = Library.Theme.Control
		elseif Type == "Outline" then 
            if Obj:IsA("UIStroke") then Obj.Color = Library.Theme.Outline 
            else Obj.BackgroundColor3 = Library.Theme.Outline end
		end
		-- Mise à jour des arrondis
		if Obj:IsA("UICorner") and Type == "CornerMain" then Obj.CornerRadius = UDim.new(0, Library.CornerRadius) end
		if Obj:IsA("UICorner") and Type == "CornerSection" then Obj.CornerRadius = UDim.new(0, Library.CornerRadius + 3) end
		
		::continue::
	end
end

-- [ 3. UTILITAIRES ] --
local function Tween(obj, props, time)
	game:GetService("TweenService"):Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function ProtectGui(Gui)
	if syn and syn.protect_gui then syn.protect_gui(Gui); Gui.Parent = CoreGui
	elseif gethui then Gui.Parent = gethui()
	else Gui.Parent = CoreGui end
end

-- [ 4. WINDOW ] --
function Library:CreateWindow(Config)
	local WindowName = Config.Title or "WindUI"
	local Size = Config.Size or UDim2.new(0, 650, 0, 400)
	for _, ui in pairs(CoreGui:GetChildren()) do if ui.Name == "WindUI_" .. WindowName then ui:Destroy() end end
	
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "WindUI_" .. WindowName; ScreenGui.IgnoreGuiInset = true; ProtectGui(ScreenGui)

	local Main = Instance.new("Frame", ScreenGui); Main.Name = "Main"; Main.Size = UDim2.new(0,0,0,0); Main.Position = UDim2.new(0.5,0,0.5,0); Main.AnchorPoint = Vector2.new(0.5,0.5); Main.BackgroundColor3 = Library.Theme.Main; Main.ClipsDescendants = true; Main.BorderSizePixel = 0
	AddToRegistry("Main", Main)
	
	local MainCorner = Instance.new("UICorner", Main); MainCorner.CornerRadius = UDim.new(0, Library.CornerRadius)
	AddToRegistry("CornerMain", MainCorner)

	local Sidebar = Instance.new("Frame", Main); Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 180, 1, 0); Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Sidebar.BorderSizePixel = 0
	AddToRegistry("Sidebar", Sidebar)
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, Library.CornerRadius); AddToRegistry("CornerMain", Sidebar:FindFirstChild("UICorner"))

	local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, -20, 0, 50); Title.Position = UDim2.new(0, 20, 0, 10); Title.BackgroundTransparency = 1; Title.Text = "<b>" .. string.upper(WindowName) .. "</b>"; Title.RichText = true; Title.TextColor3 = Library.Theme.Text; Title.Font = Enum.Font.GothamMedium; Title.TextSize = 18; Title.TextXAlignment = Enum.TextXAlignment.Left
	AddToRegistry("Text", Title)

	-- CONTROLS
	local Controls = Instance.new("Frame", Main); Controls.Size = UDim2.new(0, 70, 0, 30); Controls.Position = UDim2.new(1, -75, 0, 10); Controls.BackgroundTransparency = 1
	local CloseBtn = Instance.new("TextButton", Controls); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.BackgroundColor3 = Library.Theme.Main; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Library.Theme.Control; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
	AddToRegistry("Control", CloseBtn); AddToRegistry("Main", CloseBtn)
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local MinBtn = Instance.new("TextButton", Controls); MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -65, 0, 0); MinBtn.BackgroundColor3 = Library.Theme.Main; MinBtn.Text = "-"; MinBtn.TextColor3 = Library.Theme.Control; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
	AddToRegistry("Control", MinBtn); AddToRegistry("Main", MinBtn)
	MinBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

	Tween(Main, {Size = Size}, 0.5)

	local TabContainer = Instance.new("ScrollingFrame", Sidebar); TabContainer.Size = UDim2.new(1,0,1,-70); TabContainer.Position = UDim2.new(0,0,0,70); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; local TabList = Instance.new("UIListLayout", TabContainer); TabList.Padding = UDim.new(0, 5)
	local Content = Instance.new("Frame", Main); Content.Name = "Content"; Content.Size = UDim2.new(1, -180, 1, 0); Content.Position = UDim2.new(0, 180, 0, 0); Content.BackgroundTransparency = 1; local ContentPad = Instance.new("UIPadding", Content); ContentPad.PaddingTop = UDim.new(0,20); ContentPad.PaddingLeft = UDim.new(0,20); ContentPad.PaddingRight = UDim.new(0,20); ContentPad.PaddingBottom = UDim.new(0,20)

	-- Dragging
	local Dragging, DragInput, DragStart, StartPos
	Sidebar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = input.Position; StartPos = Main.Position end end)
	Sidebar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
	UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then local Delta = input.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
	UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

	local WindowFuncs = {}
	local FirstTab = true

	function WindowFuncs:AddTab(Name)
		local TabBtn = Instance.new("TextButton", TabContainer); TabBtn.Size = UDim2.new(1,0,0, 40); TabBtn.BackgroundTransparency = 1; TabBtn.Text = ""
		local Indicator = Instance.new("Frame", TabBtn); Indicator.Size = UDim2.new(0,4,0.6,0); Indicator.Position = UDim2.new(0,0,0.2,0); Indicator.BackgroundColor3 = Library.Theme.Accent; Indicator.Transparency = 1; Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)
		AddToRegistry("Accent", Indicator)
		local TabLabel = Instance.new("TextLabel", TabBtn); TabLabel.Size = UDim2.new(1,-30,1,0); TabLabel.Position = UDim2.new(0,25,0,0); TabLabel.BackgroundTransparency = 1; TabLabel.Text = Name; TabLabel.TextColor3 = Library.Theme.TextDark; TabLabel.Font = Enum.Font.GothamMedium; TabLabel.TextSize = 13; TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		AddToRegistry("TextDark", TabLabel) -- Sera mis à jour

		local Page = Instance.new("ScrollingFrame", Content); Page.Name = Name; Page.Size = UDim2.new(1,0,1,0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Library.Theme.Accent; Page.Visible = false; local PageList = Instance.new("UIListLayout", Page); PageList.Padding = UDim.new(0, 10)
		AddToRegistry("Accent", Page) -- Scrollbar color

		TabBtn.MouseButton1Click:Connect(function()
			for _, btn in pairs(TabContainer:GetChildren()) do if btn:IsA("TextButton") then Tween(btn.TextLabel, {TextColor3 = Library.Theme.TextDark}); Tween(btn.Frame, {Transparency = 1}) end end
			for _, p in pairs(Content:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			Page.Visible = true; Tween(TabLabel, {TextColor3 = Library.Theme.Text}); Tween(Indicator, {Transparency = 0})
		end)
		if FirstTab then Page.Visible = true; TabLabel.TextColor3 = Library.Theme.Text; Indicator.Transparency = 0; FirstTab = false end

		local TabFuncs = {}
		function TabFuncs:AddSection(Title)
			local Section = Instance.new("Frame", Page); Section.BackgroundColor3 = Library.Theme.Section; Section.Size = UDim2.new(1,0,0,30); 
			local SecCorner = Instance.new("UICorner", Section); SecCorner.CornerRadius = UDim.new(0, 9)
			AddToRegistry("Section", Section); AddToRegistry("CornerSection", SecCorner)
			
			local SecTitle = Instance.new("TextLabel", Section); SecTitle.Size = UDim2.new(1,-20,0,30); SecTitle.Position = UDim2.new(0,10,0,0); SecTitle.BackgroundTransparency = 1; SecTitle.Text = Title; SecTitle.TextColor3 = Library.Theme.TextDark; SecTitle.Font = Enum.Font.GothamBold; SecTitle.TextSize = 11; SecTitle.TextXAlignment = Enum.TextXAlignment.Left
			AddToRegistry("TextDark", SecTitle)
			
			local Container = Instance.new("Frame", Section); Container.Size = UDim2.new(1,-20,0,0); Container.Position = UDim2.new(0,10,0,30); Container.BackgroundTransparency = 1
			local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, 6)
			List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Container.Size = UDim2.new(1,-20,0,List.AbsoluteContentSize.Y); Section.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y+40) end)

			local SecFuncs = {}
			function SecFuncs:AddButton(Text, Callback)
				local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1,0,0, 32); Btn.BackgroundColor3 = Library.Theme.Main; Btn.Text = Text; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 12; Btn.AutoButtonColor = false; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
				AddToRegistry("Main", Btn); AddToRegistry("Text", Btn)
				Btn.MouseButton1Click:Connect(function() pcall(Callback) end)
			end
			function SecFuncs:AddToggle(Text, Default, Callback)
				local Tgl = Instance.new("TextButton", Container); Tgl.Size = UDim2.new(1,0,0, 32); Tgl.BackgroundTransparency = 1; Tgl.Text = ""
				local Lab = Instance.new("TextLabel", Tgl); Lab.Size = UDim2.new(1,-50,1,0); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = 12; Lab.TextXAlignment = Enum.TextXAlignment.Left
				AddToRegistry("Text", Lab)
				local Outer = Instance.new("Frame", Tgl); Outer.Size = UDim2.new(0,40,0,20); Outer.AnchorPoint = Vector2.new(1,0.5); Outer.Position = UDim2.new(1,0,0.5,0); Outer.BackgroundColor3 = Default and Library.Theme.Accent or Library.Theme.Main; Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
				-- Pas de registry simple ici car couleur dynamique, on gère au clic
				local Circle = Instance.new("Frame", Outer); Circle.Size = UDim2.new(0,16,0,16); Circle.Position = Default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); Circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
				local State = Default; Tgl.MouseButton1Click:Connect(function() State = not State; Tween(Outer, {BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.Main}); Tween(Circle, {Position = State and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}); pcall(Callback, State) end)
			end
			function SecFuncs:AddSlider(Text, Min, Max, Default, Callback)
				local SldFrame = Instance.new("Frame", Container); SldFrame.Size = UDim2.new(1,0,0, 45); SldFrame.BackgroundTransparency = 1
				local Lab = Instance.new("TextLabel", SldFrame); Lab.Size = UDim2.new(1,0,0,20); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = 12; Lab.TextXAlignment = Enum.TextXAlignment.Left
				AddToRegistry("Text", Lab)
				local Bar = Instance.new("Frame", SldFrame); Bar.Size = UDim2.new(1,0,0,6); Bar.Position = UDim2.new(0,0,0,28); Bar.BackgroundColor3 = Library.Theme.Main; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				AddToRegistry("Main", Bar)
				local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Default-Min)/(Max-Min),0,1,0); Fill.BackgroundColor3 = Library.Theme.Accent; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				AddToRegistry("Accent", Fill)
				local Dragging = false; local function Update(Input) local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local V = math.floor(Min + ((Max - Min) * P)); Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05); pcall(Callback, V) end
				Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end); UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
			end
			function SecFuncs:AddDropdown(Text, Items, Default, Callback)
				local Drop = Instance.new("Frame", Container); Drop.Size = UDim2.new(1,0,0, 32); Drop.BackgroundTransparency = 1; Drop.ClipsDescendants = true
				local Btn = Instance.new("TextButton", Drop); Btn.Size = UDim2.new(1,0,0, 32); Btn.BackgroundColor3 = Library.Theme.Main; Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
				AddToRegistry("Main", Btn)
				local Lab = Instance.new("TextLabel", Btn); Lab.Size = UDim2.new(1,-30,1,0); Lab.Position = UDim2.new(0,10,0,0); Lab.BackgroundTransparency = 1; Lab.Text = Text .. ": " .. (Default or "..."); Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = 12; Lab.TextXAlignment = Enum.TextXAlignment.Left
				AddToRegistry("Text", Lab)
				local List = Instance.new("ScrollingFrame", Drop); List.Size = UDim2.new(1,0,0,0); List.Position = UDim2.new(0,0,0,35); List.BackgroundColor3 = Library.Theme.Main; List.BorderSizePixel = 0; List.ScrollBarThickness = 2
				AddToRegistry("Main", List)
				local Open = false; Btn.MouseButton1Click:Connect(function() Open = not Open; Tween(Drop, {Size = UDim2.new(1,0,0, Open and (math.min(#Items, 5)*27+40) or 32)}) end)
				local ListL = Instance.new("UIListLayout", List); ListL.Padding = UDim.new(0,2)
				for _, item in pairs(Items) do local IB = Instance.new("TextButton", List); IB.Size = UDim2.new(1,0,0,25); IB.BackgroundColor3 = Library.Theme.Main; IB.Text = "  " .. item; IB.TextColor3 = Library.Theme.TextDark; IB.Font = Enum.Font.Gotham; IB.TextSize = 12; IB.TextXAlignment = Enum.TextXAlignment.Left
				AddToRegistry("Main", IB); AddToRegistry("TextDark", IB)
				IB.MouseButton1Click:Connect(function() Open = false; Lab.Text = Text..": "..item; Tween(Drop, {Size = UDim2.new(1,0,0, 32)}); pcall(Callback, item) end) end; List.CanvasSize = UDim2.new(0,0,0,#Items*27)
			end
			return SecFuncs
		end
		return TabFuncs
	end

	function WindowFuncs:AddProfile()
		local Player = Players.LocalPlayer
		TabContainer.Size = UDim2.new(1, 0, 1, -80)
		local ProfileFrame = Instance.new("Frame", Sidebar); ProfileFrame.Size = UDim2.new(1, -20, 0, 50); ProfileFrame.Position = UDim2.new(0, 10, 1, -60); ProfileFrame.BackgroundColor3 = Library.Theme.Main; ProfileFrame.BorderSizePixel = 0; ProfileFrame.ZIndex = 20
		AddToRegistry("Main", ProfileFrame)
		Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)
		local Avatar = Instance.new("ImageLabel", ProfileFrame); Avatar.Size = UDim2.new(0, 36, 0, 36); Avatar.Position = UDim2.new(0, 8, 0.5, 0); Avatar.AnchorPoint = Vector2.new(0, 0.5); Avatar.BackgroundTransparency = 1; Avatar.Image = "rbxassetid://0"; Avatar.ZIndex = 30
		Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
		task.spawn(function() local s,c = pcall(function() return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) if s then Avatar.Image = c end end)
		local DispName = Instance.new("TextLabel", ProfileFrame); DispName.Size = UDim2.new(1, -60, 0, 18); DispName.Position = UDim2.new(0, 52, 0, 8); DispName.BackgroundTransparency = 1; DispName.Text = Player.DisplayName; DispName.TextColor3 = Library.Theme.Text; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 13; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.ZIndex = 30
		AddToRegistry("Text", DispName)
		local UserName = Instance.new("TextLabel", ProfileFrame); UserName.Size = UDim2.new(1, -60, 0, 15); UserName.Position = UDim2.new(0, 52, 0, 26); UserName.BackgroundTransparency = 1; UserName.Text = "@" .. Player.Name; UserName.TextColor3 = Library.Theme.TextDark; UserName.Font = Enum.Font.Gotham; UserName.TextSize = 11; UserName.TextXAlignment = Enum.TextXAlignment.Left; UserName.ZIndex = 30
		AddToRegistry("TextDark", UserName)
	end
	
	-- [ FONCTION MAGIQUE : GÉNÉRATEUR DE SETTINGS ] --
	function WindowFuncs:AddThemeSettings()
		local Settings = WindowFuncs:AddTab("Interface")
		local ThemeSec = Settings:AddSection("Theme Manager")
		
		-- 1. Choisir le preset
		ThemeSec:AddDropdown("Presets", {"Dark", "Light", "Midnight"}, "Dark", function(Val)
			Library.Theme = Library.Themes[Val]
			Library:Refresh()
		end)
		
		-- 2. Personnalisation de l'Accent (Rouge, Vert, Bleu)
		local ColorSec = Settings:AddSection("Accent Color (RGB)")
		local R, G, B = 120, 90, 255 -- Valeurs par défaut du violet
		
		ColorSec:AddSlider("Red", 0, 255, R, function(Val)
			R = Val; Library.Theme.Accent = Color3.fromRGB(R, G, B); Library:Refresh()
		end)
		ColorSec:AddSlider("Green", 0, 255, G, function(Val)
			G = Val; Library.Theme.Accent = Color3.fromRGB(R, G, B); Library:Refresh()
		end)
		ColorSec:AddSlider("Blue", 0, 255, B, function(Val)
			B = Val; Library.Theme.Accent = Color3.fromRGB(R, G, B); Library:Refresh()
		end)

		-- 3. Formes et Boutons
		local UIConfig = Settings:AddSection("Window Config")
		
		UIConfig:AddSlider("Corner Radius", 0, 20, 6, function(Val)
			Library.CornerRadius = Val
			Library:Refresh()
		end)
		
		UIConfig:AddToggle("Show X / - Buttons", true, function(State)
			Controls.Visible = State
		end)
	end

	return WindowFuncs
end
return Library
