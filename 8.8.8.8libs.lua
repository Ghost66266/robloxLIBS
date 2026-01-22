-- [[ 8.8.8.8 WIND-UI LIBRARY ]] --
-- [[ VERSION: V31 THEMES & CONTROLS | AUTHOR: GHOST66266 ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Library = {}
Library.Windows = {}

-- [ 1. SYSTEME DE THEMES ] --

-- Les 13 Propriétés de couleur obligatoires
Library.Themes = {
	Dark = {
		Main        = Color3.fromRGB(20, 20, 25),
		Sidebar     = Color3.fromRGB(15, 15, 20),
		Topbar      = Color3.fromRGB(18, 18, 22),
		Section     = Color3.fromRGB(28, 28, 32),
		Accent      = Color3.fromRGB(120, 90, 255),
		Text        = Color3.fromRGB(240, 240, 240),
		TextDark    = Color3.fromRGB(140, 140, 150),
		Outline     = Color3.fromRGB(20, 20, 25), -- Camouflage (Flat)
		Hover       = Color3.fromRGB(35, 35, 40),
		Dropdown    = Color3.fromRGB(25, 25, 30),
		Control     = Color3.fromRGB(255, 255, 255), -- Couleur des icônes X / -
		ControlHover= Color3.fromRGB(45, 45, 50),
		CloseHover  = Color3.fromRGB(200, 50, 50)
	},
	Light = {
		Main        = Color3.fromRGB(240, 240, 245),
		Sidebar     = Color3.fromRGB(225, 225, 230),
		Topbar      = Color3.fromRGB(230, 230, 235),
		Section     = Color3.fromRGB(255, 255, 255),
		Accent      = Color3.fromRGB(100, 100, 255), -- Bleu plus vif
		Text        = Color3.fromRGB(20, 20, 20),    -- Texte Sombre
		TextDark    = Color3.fromRGB(100, 100, 110),
		Outline     = Color3.fromRGB(240, 240, 245), -- Camouflage
		Hover       = Color3.fromRGB(215, 215, 220),
		Dropdown    = Color3.fromRGB(235, 235, 240),
		Control     = Color3.fromRGB(20, 20, 20),
		ControlHover= Color3.fromRGB(200, 200, 210),
		CloseHover  = Color3.fromRGB(255, 80, 80)
	},
	Midnight = {
		Main        = Color3.fromRGB(10, 10, 15),
		Sidebar     = Color3.fromRGB(5, 5, 10),
		Topbar      = Color3.fromRGB(8, 8, 12),
		Section     = Color3.fromRGB(18, 18, 24),
		Accent      = Color3.fromRGB(80, 180, 255), -- Cyan Néon
		Text        = Color3.fromRGB(255, 255, 255),
		TextDark    = Color3.fromRGB(120, 120, 130),
		Outline     = Color3.fromRGB(10, 10, 15),
		Hover       = Color3.fromRGB(25, 25, 35),
		Dropdown    = Color3.fromRGB(20, 20, 25),
		Control     = Color3.fromRGB(200, 200, 255),
		ControlHover= Color3.fromRGB(30, 30, 40),
		CloseHover  = Color3.fromRGB(200, 0, 50)
	}
}

-- Thème par défaut
Library.Theme = Library.Themes.Dark

-- Configuration des Tailles (Par défaut)
Library.Sizes = {
	Tab = 40,
	Element = 34,
	Slider = 45,
	SectionGap = 6
}
Library.TextSize = {
	Title = 18, Tab = 13, Section = 11, Element = 12
}

-- Fonction pour changer le thème avant de créer la fenêtre
function Library:SetTheme(ThemeNameOrTable)
	if type(ThemeNameOrTable) == "string" and Library.Themes[ThemeNameOrTable] then
		Library.Theme = Library.Themes[ThemeNameOrTable]
	elseif type(ThemeNameOrTable) == "table" then
		Library.Theme = ThemeNameOrTable -- Thème custom
	end
end

-- [ 2. UTILITAIRES ] --
local function Tween(obj, props, time, style, dir)
	if not obj then return end
	local T = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	T:Play()
	return T
end

local function CreateRipple(Btn)
	if not Btn then return end
	Btn.ClipsDescendants = true
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Ripple = Instance.new("ImageLabel", Btn); Ripple.Name = "Ripple"; Ripple.BackgroundTransparency = 1; Ripple.Image = "rbxassetid://266543268"; Ripple.ImageColor3 = Library.Theme.Accent; Ripple.ImageTransparency = 0.6; Ripple.ZIndex = 15
		local Rx, Ry = Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, Rx, 0, Ry); Ripple.AnchorPoint = Vector2.new(0.5, 0.5); Ripple.Size = UDim2.new(0,0,0,0)
		local T = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y)*3.5, 0, math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y)*3.5), ImageTransparency = 1})
		T:Play(); T.Completed:Wait(); Ripple:Destroy()
	end)
end

local function AddClickEffect(Btn)
	local Scale = Instance.new("UIScale", Btn)
	Btn.AnchorPoint = Vector2.new(0.5, 0.5)
	Btn.Position = UDim2.new(Btn.Position.X.Scale, Btn.Position.X.Offset + (Btn.Size.X.Offset/2), Btn.Position.Y.Scale, Btn.Position.Y.Offset + (Btn.Size.Y.Offset/2))
	Btn.MouseButton1Down:Connect(function() Tween(Scale, {Scale = 0.97}, 0.05) end)
	Btn.MouseButton1Up:Connect(function() Tween(Scale, {Scale = 1}, 0.05) end)
	Btn.MouseLeave:Connect(function() Tween(Scale, {Scale = 1}, 0.05) end)
end

local function MakeDraggable(DragPoint, Main)
	local Dragging, DragInput, DragStart, StartPos
	DragPoint.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = input.Position; StartPos = Main.Position end end)
	DragPoint.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
	UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then local Delta = input.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

local function ProtectGui(Gui)
	if syn and syn.protect_gui then syn.protect_gui(Gui); Gui.Parent = CoreGui
	elseif gethui then Gui.Parent = gethui()
	else Gui.Parent = CoreGui end
end

-- [ 3. INTRO ] --
function Library:Welcome(TitleText, SubText)
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "8888_Intro" then v:Destroy() end end
	local Screen = Instance.new("ScreenGui"); Screen.Name = "8888_Intro"; Screen.IgnoreGuiInset = true; Screen.DisplayOrder = 10000; ProtectGui(Screen)
	local Blur = Instance.new("BlurEffect", Lighting); Blur.Size = 0
	local BackFrame = Instance.new("Frame", Screen); BackFrame.Size = UDim2.new(1,0,1,0); BackFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); BackFrame.BackgroundTransparency = 1; BackFrame.ZIndex = 1
	local MainLabel = Instance.new("TextLabel", Screen); MainLabel.Size = UDim2.new(1,0,0,150); MainLabel.Position = UDim2.new(0,0,0.4,0); MainLabel.BackgroundTransparency = 1; MainLabel.Text = string.upper(TitleText or "LIBRARY"); MainLabel.TextColor3 = Library.Theme.Accent; MainLabel.Font = Enum.Font.GothamBlack; MainLabel.TextSize = 0; MainLabel.TextTransparency = 1; MainLabel.ZIndex = 2
	local SubLabel = Instance.new("TextLabel", Screen); SubLabel.Size = UDim2.new(1,0,0,50); SubLabel.Position = UDim2.new(0,0,0.55,0); SubLabel.BackgroundTransparency = 1; SubLabel.Text = string.upper(SubText or "INITIALIZING..."); SubLabel.TextColor3 = Library.Theme.Text; SubLabel.Font = Enum.Font.GothamBold; SubLabel.TextSize = 20; SubLabel.TextTransparency = 1; SubLabel.ZIndex = 2
	Tween(Blur, {Size = 24}, 1); Tween(BackFrame, {BackgroundTransparency = 0.1}, 0.5); task.wait(0.5); TweenService:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 90, TextTransparency = 0}):Play(); task.wait(0.3)
	SubLabel.Position = UDim2.new(0,0,0.60,0); TweenService:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0.55,0), TextTransparency = 0}):Play()
	task.wait(2.5); Tween(MainLabel, {TextSize = 0, TextTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In); Tween(SubLabel, {TextTransparency = 1}, 0.5); task.wait(0.2); Tween(BackFrame, {BackgroundTransparency = 1}, 0.5); Tween(Blur, {Size = 0}, 0.8); task.wait(0.8); Screen:Destroy(); Blur:Destroy()
end

-- [ 4. FENETRE PRINCIPALE ] --
function Library:CreateWindow(Config)
	local WindowName = Config.Title or "WindUI"
	local Size = Config.Size or UDim2.new(0, 650, 0, 400)
	-- Config Controls : Par défaut activés
	local ShowControls = true 
	if Config.Controls ~= nil then ShowControls = Config.Controls end
	
	if Config.TextSize then for k,v in pairs(Config.TextSize) do Library.TextSize[k] = v end end
	if Config.ElementSize then for k,v in pairs(Config.ElementSize) do Library.Sizes[k] = v end end
	
	for _, ui in pairs(CoreGui:GetChildren()) do if ui.Name == "WindUI_" .. WindowName then ui:Destroy() end end
	local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "WindUI_" .. WindowName; ScreenGui.IgnoreGuiInset = true; ProtectGui(ScreenGui)

	local Main = Instance.new("Frame", ScreenGui); Main.Name = "Main"; Main.Size = UDim2.new(0,0,0,0); Main.Position = UDim2.new(0.5,0,0.5,0); Main.AnchorPoint = Vector2.new(0.5,0.5); Main.BackgroundColor3 = Library.Theme.Main; Main.ClipsDescendants = true; Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
	Tween(Main, {Size = Size}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	local Sidebar = Instance.new("Frame", Main); Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 180, 1, 0); Sidebar.BackgroundColor3 = Library.Theme.Sidebar; Sidebar.BorderSizePixel = 0; Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
	local SidebarFix = Instance.new("Frame", Sidebar); SidebarFix.BorderSizePixel=0; SidebarFix.BackgroundColor3=Library.Theme.Sidebar; SidebarFix.Size=UDim2.new(0,10,1,0); SidebarFix.Position=UDim2.new(1,-10,0,0); SidebarFix.ZIndex=0

	local Title = Instance.new("TextLabel", Sidebar); Title.Size = UDim2.new(1, -20, 0, 50); Title.Position = UDim2.new(0, 20, 0, 10); Title.BackgroundTransparency = 1; Title.Text = "<b>" .. string.upper(WindowName) .. "</b>"; Title.RichText = true; Title.TextColor3 = Library.Theme.Text; Title.Font = Enum.Font.GothamMedium; Title.TextSize = Library.TextSize.Title; Title.TextXAlignment = Enum.TextXAlignment.Left
	
	-- [ WINDOW CONTROLS (X et -) ] --
	if ShowControls then
		local Controls = Instance.new("Frame", Main)
		Controls.Name = "WindowControls"
		Controls.Size = UDim2.new(0, 70, 0, 30)
		Controls.Position = UDim2.new(1, -75, 0, 10) -- Top Right
		Controls.BackgroundTransparency = 1
		
		-- Bouton Close (X)
		local CloseBtn = Instance.new("TextButton", Controls)
		CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.BackgroundColor3 = Library.Theme.Main; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Library.Theme.Control; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 14; CloseBtn.AutoButtonColor = false
		Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
		CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Library.Theme.CloseHover}) end)
		CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Library.Theme.Main}) end)
		CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

		-- Bouton Min (-)
		local MinBtn = Instance.new("TextButton", Controls)
		MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -65, 0, 0); MinBtn.BackgroundColor3 = Library.Theme.Main; MinBtn.Text = "-"; MinBtn.TextColor3 = Library.Theme.Control; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 18; MinBtn.AutoButtonColor = false
		Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
		MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = Library.Theme.ControlHover}) end)
		MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = Library.Theme.Main}) end)
		MinBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
	end
	
	local TabContainer = Instance.new("ScrollingFrame", Sidebar); TabContainer.Size = UDim2.new(1,0,1,-70); TabContainer.Position = UDim2.new(0,0,0,70); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0; local TabList = Instance.new("UIListLayout", TabContainer); TabList.Padding = UDim.new(0, 5)
	local Content = Instance.new("Frame", Main); Content.Name = "Content"; Content.Size = UDim2.new(1, -180, 1, 0); Content.Position = UDim2.new(0, 180, 0, 0); Content.BackgroundTransparency = 1; local ContentPad = Instance.new("UIPadding", Content); ContentPad.PaddingTop = UDim.new(0,20); ContentPad.PaddingLeft = UDim.new(0,20); ContentPad.PaddingRight = UDim.new(0,20); ContentPad.PaddingBottom = UDim.new(0,20)

	MakeDraggable(Sidebar, Main)
	UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightControl then Main.Visible = not Main.Visible end end)

	local WindowFuncs = {}
	local FirstTab = true

	function WindowFuncs:AddTab(Name)
		local TabBtn = Instance.new("TextButton", TabContainer); TabBtn.Size = UDim2.new(1,0,0, Library.Sizes.Tab); TabBtn.BackgroundTransparency = 1; TabBtn.Text = ""
		local Indicator = Instance.new("Frame", TabBtn); Indicator.Size = UDim2.new(0,4,0.6,0); Indicator.Position = UDim2.new(0,0,0.2,0); Indicator.BackgroundColor3 = Library.Theme.Accent; Indicator.Transparency = 1; Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)
		local TabLabel = Instance.new("TextLabel", TabBtn); TabLabel.Size = UDim2.new(1,-30,1,0); TabLabel.Position = UDim2.new(0,25,0,0); TabLabel.BackgroundTransparency = 1; TabLabel.Text = Name; TabLabel.TextColor3 = Library.Theme.TextDark; TabLabel.Font = Enum.Font.GothamMedium; TabLabel.TextSize = Library.TextSize.Tab; TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		local Page = Instance.new("ScrollingFrame", Content); Page.Name = Name; Page.Size = UDim2.new(1,0,1,0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = Library.Theme.Accent; Page.Visible = false; local PageList = Instance.new("UIListLayout", Page); PageList.Padding = UDim.new(0, 10)
		PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y+20) end)

		TabBtn.MouseButton1Click:Connect(function()
			for _, btn in pairs(TabContainer:GetChildren()) do if btn:IsA("TextButton") then Tween(btn.TextLabel, {TextColor3 = Library.Theme.TextDark}); Tween(btn.Frame, {Transparency = 1}) end end
			for _, p in pairs(Content:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			Page.Visible = true; Page.Position = UDim2.new(0, 0, 0, 20); TweenService:Create(Page, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play(); Tween(TabLabel, {TextColor3 = Library.Theme.Text}); Tween(Indicator, {Transparency = 0})
		end)
		if FirstTab then Page.Visible = true; TabLabel.TextColor3 = Library.Theme.Text; Indicator.Transparency = 0; FirstTab = false end

		local TabFuncs = {}
		function TabFuncs:AddSection(Title)
			local Section = Instance.new("Frame", Page); Section.BackgroundColor3 = Library.Theme.Section; Section.Size = UDim2.new(1,0,0,30); Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 9)
			local SecTitle = Instance.new("TextLabel", Section); SecTitle.Size = UDim2.new(1,-20,0,30); SecTitle.Position = UDim2.new(0,10,0,0); SecTitle.BackgroundTransparency = 1; SecTitle.Text = Title; SecTitle.TextColor3 = Library.Theme.TextDark; SecTitle.Font = Enum.Font.GothamBold; SecTitle.TextSize = Library.TextSize.Section; SecTitle.TextXAlignment = Enum.TextXAlignment.Left
			local Container = Instance.new("Frame", Section); Container.Size = UDim2.new(1,-20,0,0); Container.Position = UDim2.new(0,10,0,30); Container.BackgroundTransparency = 1
			local List = Instance.new("UIListLayout", Container); List.Padding = UDim.new(0, Library.Sizes.SectionGap)
			List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Container.Size = UDim2.new(1,-20,0,List.AbsoluteContentSize.Y); Section.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y+40) end)

			local SecFuncs = {}
			function SecFuncs:AddButton(Text, Callback)
				local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1,0,0, Library.Sizes.Element); Btn.BackgroundColor3 = Library.Theme.Main; Btn.Text = Text; Btn.TextColor3 = Library.Theme.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = Library.TextSize.Element; Btn.AutoButtonColor = false; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
				AddClickEffect(Btn); Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.Hover}) end); Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.Main}) end); Btn.MouseButton1Click:Connect(function() CreateRipple(Btn); pcall(Callback) end)
			end
			function SecFuncs:AddToggle(Text, Default, Callback)
				local Tgl = Instance.new("TextButton", Container); Tgl.Size = UDim2.new(1,0,0, Library.Sizes.Element); Tgl.BackgroundTransparency = 1; Tgl.Text = ""; AddClickEffect(Tgl)
				local Lab = Instance.new("TextLabel", Tgl); Lab.Size = UDim2.new(1,-50,1,0); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = Library.TextSize.Element; Lab.TextXAlignment = Enum.TextXAlignment.Left
				local Outer = Instance.new("Frame", Tgl); Outer.Size = UDim2.new(0,40,0,20); Outer.AnchorPoint = Vector2.new(1,0.5); Outer.Position = UDim2.new(1,0,0.5,0); Outer.BackgroundColor3 = Default and Library.Theme.Accent or Library.Theme.Outline; Instance.new("UICorner", Outer).CornerRadius = UDim.new(1, 0)
				local Circle = Instance.new("Frame", Outer); Circle.Size = UDim2.new(0,16,0,16); Circle.Position = Default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); Circle.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
				local State = Default; Tgl.MouseButton1Click:Connect(function() State = not State; Tween(Outer, {BackgroundColor3 = State and Library.Theme.Accent or Library.Theme.Outline}); Tween(Circle, {Position = State and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}); pcall(Callback, State) end)
			end
			function SecFuncs:AddSlider(Text, Min, Max, Default, Callback)
				local SldFrame = Instance.new("Frame", Container); SldFrame.Size = UDim2.new(1,0,0, Library.Sizes.Slider); SldFrame.BackgroundTransparency = 1
				local Lab = Instance.new("TextLabel", SldFrame); Lab.Size = UDim2.new(1,0,0,20); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = Library.TextSize.Element; Lab.TextXAlignment = Enum.TextXAlignment.Left
				local Val = Instance.new("TextLabel", SldFrame); Val.Size = UDim2.new(1,0,0,20); Val.BackgroundTransparency = 1; Val.Text = tostring(Default); Val.TextColor3 = Library.Theme.TextDark; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12; Val.TextXAlignment = Enum.TextXAlignment.Right
				local Bar = Instance.new("Frame", SldFrame); Bar.Size = UDim2.new(1,0,0,6); Bar.Position = UDim2.new(0,0,0,28); Bar.BackgroundColor3 = Library.Theme.Outline; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Default-Min)/(Max-Min),0,1,0); Fill.BackgroundColor3 = Library.Theme.Accent; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				local Dragging = false; local function Update(Input) local P = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local V = math.floor(Min + ((Max - Min) * P)); Tween(Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05); Val.Text = tostring(V); pcall(Callback, V) end
				Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end); UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end); UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
			end
			function SecFuncs:AddDropdown(Text, Items, Default, Callback)
				local Drop = Instance.new("Frame", Container); Drop.Size = UDim2.new(1,0,0, Library.Sizes.Element); Drop.BackgroundTransparency = 1; Drop.ClipsDescendants = true
				local Btn = Instance.new("TextButton", Drop); Btn.Size = UDim2.new(1,0,0, Library.Sizes.Element); Btn.BackgroundColor3 = Library.Theme.Main; Btn.Text = ""; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4); AddClickEffect(Btn)
				local Lab = Instance.new("TextLabel", Btn); Lab.Size = UDim2.new(1,-30,1,0); Lab.Position = UDim2.new(0,10,0,0); Lab.BackgroundTransparency = 1; Lab.Text = Text .. ": " .. (Default or "..."); Lab.TextColor3 = Library.Theme.Text; Lab.Font = Enum.Font.GothamMedium; Lab.TextSize = Library.TextSize.Element; Lab.TextXAlignment = Enum.TextXAlignment.Left
				local Arrow = Instance.new("ImageLabel", Btn); Arrow.Size = UDim2.new(0,20,0,20); Arrow.Position = UDim2.new(1,-25,0.5,-10); Arrow.BackgroundTransparency = 1; Arrow.Image = "rbxassetid://6031091004"; Arrow.ImageColor3 = Library.Theme.TextDark
				local List = Instance.new("ScrollingFrame", Drop); List.Size = UDim2.new(1,0,0,0); List.Position = UDim2.new(0,0,0,35); List.BackgroundColor3 = Library.Theme.Main; List.BorderSizePixel = 0; List.ScrollBarThickness = 2; local ListL = Instance.new("UIListLayout", List); ListL.Padding = UDim.new(0, 2)
				local Open = false; Btn.MouseButton1Click:Connect(function() Open = not Open; Tween(Drop, {Size = UDim2.new(1,0,0, Open and (math.min(#Items, 5)*27+40) or Library.Sizes.Element)}); Tween(Arrow, {Rotation = Open and 180 or 0}); Tween(List, {Size = UDim2.new(1,0,0, Open and (math.min(#Items, 5)*27) or 0)}) end)
				for _, item in pairs(Items) do local IB = Instance.new("TextButton", List); IB.Size = UDim2.new(1,0,0,25); IB.BackgroundColor3 = Library.Theme.Main; IB.Text = "  " .. item; IB.TextColor3 = Library.Theme.TextDark; IB.Font = Enum.Font.Gotham; IB.TextSize = Library.TextSize.Element; IB.TextXAlignment = Enum.TextXAlignment.Left; IB.MouseButton1Click:Connect(function() Open = false; Lab.Text = Text..": "..item; Tween(Drop, {Size = UDim2.new(1,0,0, Library.Sizes.Element)}); Tween(Arrow, {Rotation = 0}); pcall(Callback, item) end) end; List.CanvasSize = UDim2.new(0,0,0,#Items*27)
			end
			function SecFuncs:AddConsole(Height)
				local BoxHeight = Height or 100
				local BoxFrame = Instance.new("ScrollingFrame", Container); BoxFrame.Size = UDim2.new(1, 0, 0, BoxHeight); BoxFrame.BackgroundTransparency = 0.5; BoxFrame.BackgroundColor3 = Library.Theme.Main; BoxFrame.ScrollBarThickness = 2; BoxFrame.ScrollBarImageColor3 = Library.Theme.Accent; BoxFrame.BorderSizePixel = 0
				Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 4)
				local BoxList = Instance.new("UIListLayout", BoxFrame); BoxList.Padding = UDim.new(0, 2)
				BoxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() BoxFrame.CanvasSize = UDim2.new(0, 0, 0, BoxList.AbsoluteContentSize.Y + 10); BoxFrame.CanvasPosition = Vector2.new(0, BoxList.AbsoluteContentSize.Y) end)
				local ConsoleFuncs = {}
				function ConsoleFuncs:Log(Text)
					local Label = Instance.new("TextLabel", BoxFrame); Label.Size = UDim2.new(1, -10, 0, 20); Label.BackgroundTransparency = 1; Label.Text = "  > " .. Text; Label.TextColor3 = Library.Theme.Text; Label.Font = Enum.Font.Code; Label.TextSize = 12; Label.TextXAlignment = Enum.TextXAlignment.Left
				end
				return ConsoleFuncs
			end
			return SecFuncs
		end
		return TabFuncs
	end

	function WindowFuncs:AddProfile()
		local Player = Players.LocalPlayer
		TabContainer.Size = UDim2.new(1, 0, 1, -80)
		local ProfileFrame = Instance.new("Frame", Sidebar); ProfileFrame.Name = "UserProfile"; ProfileFrame.Size = UDim2.new(1, -20, 0, 50); ProfileFrame.Position = UDim2.new(0, 10, 1, -60); ProfileFrame.BackgroundColor3 = Library.Theme.Main; ProfileFrame.BorderSizePixel = 0; ProfileFrame.ZIndex = 20
		Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)
		local Avatar = Instance.new("ImageLabel", ProfileFrame); Avatar.Size = UDim2.new(0, 36, 0, 36); Avatar.Position = UDim2.new(0, 8, 0.5, 0); Avatar.AnchorPoint = Vector2.new(0, 0.5); Avatar.BackgroundTransparency = 1; Avatar.Image = "rbxassetid://0"; Avatar.ZIndex = 30
		Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
		task.spawn(function() local s,c = pcall(function() return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) if s then Avatar.Image = c else Avatar.Image = "rbxassetid://16645563" end end)
		local DispName = Instance.new("TextLabel", ProfileFrame); DispName.Size = UDim2.new(1, -60, 0, 18); DispName.Position = UDim2.new(0, 52, 0, 8); DispName.BackgroundTransparency = 1; DispName.Text = Player.DisplayName or "Player"; DispName.TextColor3 = Library.Theme.Text; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 13; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.ZIndex = 30
		local UserName = Instance.new("TextLabel", ProfileFrame); UserName.Size = UDim2.new(1, -60, 0, 15); UserName.Position = UDim2.new(0, 52, 0, 26); UserName.BackgroundTransparency = 1; UserName.Text = "@" .. (Player.Name or "Guest"); UserName.TextColor3 = Library.Theme.TextDark; UserName.Font = Enum.Font.Gotham; UserName.TextSize = 11; UserName.TextXAlignment = Enum.TextXAlignment.Left; UserName.ZIndex = 30
	end

	return WindowFuncs
end
return Library
