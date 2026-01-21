-- [[ 8.8.8.8 UI LIBRARY - ARCHITECT EDITION ]] --
-- [[ VERSION: V18 | STRUCTURE: TOPBAR + SIDEBAR + DYNAMIC PAGES ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Library = {}

-- [ CONFIGURATION DU THÈME ] --
local Theme = {
	Main        = Color3.fromRGB(25, 25, 30),       -- Fond Principal
	Sidebar     = Color3.fromRGB(20, 20, 25),       -- Barre Latérale
	Topbar      = Color3.fromRGB(18, 18, 22),       -- Barre du Haut
	Section     = Color3.fromRGB(32, 32, 38),       -- Fond des Sections
	Accent      = Color3.fromRGB(170, 0, 255),      -- VIOLET FLUO (Signature)
	Text        = Color3.fromRGB(255, 255, 255),
	TextDark    = Color3.fromRGB(160, 160, 170),
	Outline     = Color3.fromRGB(50, 50, 60),
	Hover       = Color3.fromRGB(40, 40, 45)
}

-- [ UTILITAIRES ] --
local function Tween(obj, props, time, style, dir)
	local T = TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	T:Play()
	return T
end

local function CreateRipple(Btn)
	if not Btn then return end
	Btn.ClipsDescendants = true
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "Ripple"; Ripple.Parent = Btn; Ripple.BackgroundTransparency = 1
		Ripple.Image = "rbxassetid://266543268"; Ripple.ImageColor3 = Theme.Accent; Ripple.ImageTransparency = 0.6; Ripple.ZIndex = 15
		local Rx, Ry = Mouse.X - Btn.AbsolutePosition.X, Mouse.Y - Btn.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, Rx, 0, Ry); Ripple.AnchorPoint = Vector2.new(0.5, 0.5); Ripple.Size = UDim2.new(0,0,0,0)
		local T = TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y)*3, 0, math.max(Btn.AbsoluteSize.X, Btn.AbsoluteSize.Y)*3), ImageTransparency = 1})
		T:Play(); T.Completed:Wait(); Ripple:Destroy()
	end)
end

-- Effet de clic qui ne casse pas la taille
local function AddClickEffect(Btn)
	local Scale = Instance.new("UIScale", Btn)
	Btn.AnchorPoint = Vector2.new(0.5, 0.5)
	-- Note: L'utilisateur de la lib n'a pas à gérer ça, c'est auto
	
	Btn.MouseButton1Down:Connect(function() Tween(Scale, {Scale = 0.96}, 0.05) end)
	Btn.MouseButton1Up:Connect(function() Tween(Scale, {Scale = 1}, 0.05) end)
	Btn.MouseLeave:Connect(function() Tween(Scale, {Scale = 1}, 0.05) end)
end

-- Système de Drag (Déplacement)
local function MakeDraggable(DragPoint, Main)
	local Dragging, DragInput, DragStart, StartPos
	DragPoint.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; DragStart = input.Position; StartPos = Main.Position end end)
	DragPoint.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
	UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then local Delta = input.Position - DragStart; Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

-- [ 1. WELCOME SCREEN (INTOUCHABLE) ] --
function Library:Welcome(TitleText, SubText)
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "8888_Intro" then v:Destroy() end end
	local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "8888_Intro"; Screen.IgnoreGuiInset = true; Screen.DisplayOrder = 10000
	local Blur = Instance.new("BlurEffect", Lighting); Blur.Size = 0
	local BackFrame = Instance.new("Frame", Screen); BackFrame.Size = UDim2.new(1,0,1,0); BackFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); BackFrame.BackgroundTransparency = 1; BackFrame.ZIndex = 1
	local MainLabel = Instance.new("TextLabel", Screen); MainLabel.Size = UDim2.new(1,0,0,150); MainLabel.Position = UDim2.new(0,0,0.4,0); MainLabel.BackgroundTransparency = 1; MainLabel.Text = string.upper(TitleText or "LIBRARY"); MainLabel.TextColor3 = Theme.Accent; MainLabel.Font = Enum.Font.GothamBlack; MainLabel.TextSize = 0; MainLabel.TextTransparency = 1; MainLabel.ZIndex = 2
	local SubLabel = Instance.new("TextLabel", Screen); SubLabel.Size = UDim2.new(1,0,0,50); SubLabel.Position = UDim2.new(0,0,0.55,0); SubLabel.BackgroundTransparency = 1; SubLabel.Text = string.upper(SubText or "INITIALIZING..."); SubLabel.TextColor3 = Theme.Text; SubLabel.Font = Enum.Font.GothamBold; SubLabel.TextSize = 20; SubLabel.TextTransparency = 1; SubLabel.ZIndex = 2

	task.spawn(function()
		Tween(Blur, {Size = 24}, 1); Tween(BackFrame, {BackgroundTransparency = 0.1}, 0.5); task.wait(0.5)
		local T1 = TweenService:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 90, TextTransparency = 0}); T1:Play(); task.wait(0.3)
		SubLabel.Position = UDim2.new(0,0,0.60,0); local T2 = TweenService:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0.55,0), TextTransparency = 0}); T2:Play(); task.wait(2.5)
		Tween(MainLabel, {TextSize = 0, TextTransparency = 1}, 0.5); Tween(SubLabel, {TextTransparency = 1}, 0.5); task.wait(0.2)
		Tween(BackFrame, {BackgroundTransparency = 1}, 0.5); Tween(Blur, {Size = 0}, 0.8); task.wait(0.8); Screen:Destroy(); Blur:Destroy()
	end)
end

-- [ 2. FENÊTRE PRINCIPALE ] --
function Library:CreateWindow(Config)
	local UI_Name = Config.Name or "UI"
	if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = UI_Name
	ScreenGui.DisplayOrder = 100
	ScreenGui.ResetOnSpawn = false

	-- MAIN FRAME
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 750, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.ClipsDescendants = true
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", MainFrame).Color = Theme.Outline

	-- TOPBAR (Contient le Titre et le Crédit)
	local TopBar = Instance.new("Frame", MainFrame)
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundColor3 = Theme.Topbar
	TopBar.BorderSizePixel = 0
	
	local TopBarTitle = Instance.new("TextLabel", TopBar)
	TopBarTitle.Size = UDim2.new(0, 200, 1, 0)
	TopBarTitle.Position = UDim2.new(0, 15, 0, 0)
	TopBarTitle.BackgroundTransparency = 1
	TopBarTitle.Text = string.upper(Config.Name)
	TopBarTitle.TextColor3 = Theme.Text
	TopBarTitle.Font = Enum.Font.GothamBlack
	TopBarTitle.TextSize = 16
	TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left

	local CreditLabel = Instance.new("TextLabel", TopBar)
	CreditLabel.Size = UDim2.new(0, 100, 1, 0)
	CreditLabel.AnchorPoint = Vector2.new(1, 0)
	CreditLabel.Position = UDim2.new(1, -15, 0, 0)
	CreditLabel.BackgroundTransparency = 1
	CreditLabel.Text = "BY <font color='#AA00FF'>8.8.8.8</font>"
	CreditLabel.RichText = true
	CreditLabel.TextColor3 = Theme.TextDark
	CreditLabel.Font = Enum.Font.GothamBold
	CreditLabel.TextSize = 12
	CreditLabel.TextXAlignment = Enum.TextXAlignment.Right

	-- Separateur sous la TopBar
	local Sep = Instance.new("Frame", TopBar)
	Sep.Size = UDim2.new(1, 0, 0, 1)
	Sep.Position = UDim2.new(0, 0, 1, 0)
	Sep.BackgroundColor3 = Theme.Outline
	Sep.BorderSizePixel = 0

	-- SIDEBAR (Menu de gauche)
	local Sidebar = Instance.new("Frame", MainFrame)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 180, 1, -41)
	Sidebar.Position = UDim2.new(0, 0, 0, 41)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0

	local TabContainer = Instance.new("ScrollingFrame", Sidebar)
	TabContainer.Size = UDim2.new(1, 0, 1, -20)
	TabContainer.Position = UDim2.new(0, 0, 0, 10)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	
	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 5)

	-- CONTENEUR DE PAGES (Droite)
	local PageContainer = Instance.new("Frame", MainFrame)
	PageContainer.Name = "Pages"
	PageContainer.Size = UDim2.new(1, -180, 1, -41)
	PageContainer.Position = UDim2.new(0, 180, 0, 41)
	PageContainer.BackgroundTransparency = 1
	
	-- Padding global des pages pour ne pas coller aux bords
	local PagePad = Instance.new("UIPadding", PageContainer)
	PagePad.PaddingTop = UDim.new(0, 15)
	PagePad.PaddingLeft = UDim.new(0, 15)
	PagePad.PaddingRight = UDim.new(0, 15)
	PagePad.PaddingBottom = UDim.new(0, 15)

	MakeDraggable(TopBar, MainFrame)
	
	-- Touche Insert
	UserInputService.InputBegan:Connect(function(i, g)
		if not g and i.KeyCode == Enum.KeyCode.Insert then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	local WindowActions = {}
	local FirstTab = true

	-- [ AJOUTER UN ONGLET ] --
	function WindowActions:AddTab(Name, IconId)
		local TabBtn = Instance.new("TextButton", TabContainer)
		TabBtn.Size = UDim2.new(1, 0, 0, 40)
		TabBtn.BackgroundTransparency = 1
		TabButton = TabBtn -- reference
		TabBtn.Text = ""
		
		-- Ligne active
		local ActiveLine = Instance.new("Frame", TabBtn)
		ActiveLine.Size = UDim2.new(0, 3, 0.7, 0)
		ActiveLine.Position = UDim2.new(0, 0, 0.15, 0)
		ActiveLine.BackgroundColor3 = Theme.Accent
		ActiveLine.Transparency = 1
		
		-- Texte
		local TabLabel = Instance.new("TextLabel", TabBtn)
		TabLabel.Size = UDim2.new(1, -35, 1, 0)
		TabLabel.Position = UDim2.new(0, 35, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text = Name
		TabLabel.TextColor3 = Theme.TextDark
		TabLabel.Font = Enum.Font.GothamMedium
		TabLabel.TextSize = 13
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Icône (optionnelle)
		if IconId then
			local Icon = Instance.new("ImageLabel", TabBtn)
			Icon.Size = UDim2.new(0, 20, 0, 20)
			Icon.Position = UDim2.new(0, 10, 0.5, -10)
			Icon.BackgroundTransparency = 1
			Icon.Image = "rbxassetid://"..tostring(IconId)
			Icon.ImageColor3 = Theme.TextDark
			TabLabel.Position = UDim2.new(0, 40, 0, 0)
		end

		-- La Page
		local Page = Instance.new("Frame", PageContainer)
		Page.Name = Name.."_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		
		-- 2 Colonnes pour les sections
		local Grid = Instance.new("UIGridLayout", Page)
		Grid.SortOrder = Enum.SortOrder.LayoutOrder
		Grid.CellPadding = UDim2.new(0, 15, 0, 15)
		Grid.CellSize = UDim2.new(0.485, 0, 0, 0) -- Sera override par le script si Scrolling

		TabBtn.MouseButton1Click:Connect(function()
			for _, b in pairs(TabContainer:GetChildren()) do
				if b:IsA("TextButton") then
					Tween(b.TextLabel, {TextColor3 = Theme.TextDark})
					Tween(b.Frame, {Transparency = 1})
					if b:FindFirstChild("ImageLabel") then Tween(b.ImageLabel, {ImageColor3 = Theme.TextDark}) end
				end
			end
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			
			Page.Visible = true
			Tween(TabLabel, {TextColor3 = Theme.Text})
			Tween(ActiveLine, {Transparency = 0})
			if TabBtn:FindFirstChild("ImageLabel") then Tween(TabBtn.ImageLabel, {ImageColor3 = Theme.Text}) end
		end)
		
		if FirstTab then
			Page.Visible = true; TabLabel.TextColor3 = Theme.Text; ActiveLine.Transparency = 0
			if TabBtn:FindFirstChild("ImageLabel") then TabBtn.ImageLabel.ImageColor3 = Theme.Text end
			FirstTab = false
		end

		local TabActions = {}

		-- [ AJOUTER UNE SECTION (Frame ou ScrollingFrame) ] --
		function TabActions:AddSection(SecName, Type)
			local Section = Instance.new("Frame", Page)
			Section.Name = SecName
			Section.BackgroundColor3 = Theme.Section
			Section.Size = UDim2.new(0.485, 0, 0, 100)
			Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)
			
			local Title = Instance.new("TextLabel", Section)
			Title.Size = UDim2.new(1, -20, 0, 35)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = SecName
			Title.Font = Enum.Font.GothamBold
			Title.TextSize = 13
			Title.TextColor3 = Theme.Text
			Title.TextXAlignment = Enum.TextXAlignment.Left
			
			local Line = Instance.new("Frame", Section)
			Line.Size = UDim2.new(1, 0, 0, 1)
			Line.Position = UDim2.new(0, 0, 0, 35)
			Line.BackgroundColor3 = Theme.Outline
			Line.BorderSizePixel = 0
			
			-- Choix du type de conteneur
			local Container
			if Type == "Scroll" then
				Container = Instance.new("ScrollingFrame", Section)
				Container.ScrollBarThickness = 2
				Container.ScrollBarImageColor3 = Theme.Accent
			else
				Container = Instance.new("Frame", Section)
			end
			
			Container.Name = "Container"
			Container.Size = UDim2.new(1, 0, 1, -40)
			Container.Position = UDim2.new(0, 0, 0, 40)
			Container.BackgroundTransparency = 1
			
			-- Padding interne à la section
			local Pad = Instance.new("UIPadding", Container)
			Pad.PaddingTop = UDim.new(0, 5)
			Pad.PaddingLeft = UDim.new(0, 10)
			Pad.PaddingRight = UDim.new(0, 10)
			Pad.PaddingBottom = UDim.new(0, 5)
			
			local List = Instance.new("UIListLayout", Container)
			List.SortOrder = Enum.SortOrder.LayoutOrder
			List.Padding = UDim.new(0, 6)
			
			-- Auto-Resize Logic
			List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if Type == "Scroll" then
					Container.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
					-- Pour une section Scroll, on peut fixer une hauteur max
					Section.Size = UDim2.new(0.485, 0, 0, 250) 
				else
					-- Frame classique qui s'agrandit
					Section.Size = UDim2.new(0.485, 0, 0, List.AbsoluteContentSize.Y + 50)
				end
			end)

			local SecActions = {}

			function SecActions:AddButton(Text, Callback)
				local Btn = Instance.new("TextButton", Container)
				Btn.Size = UDim2.new(1, 0, 0, 30)
				Btn.BackgroundColor3 = Theme.Main
				Btn.Text = Text
				Btn.TextColor3 = Theme.Text
				Btn.Font = Enum.Font.GothamBold
				Btn.TextSize = 12
				Btn.AutoButtonColor = false
				
				Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
				Instance.new("UIStroke", Btn).Color = Theme.Outline
				
				-- On compense le AnchorPoint du AddClickEffect
				Btn.Position = UDim2.new(0.5, 0, 0, 0)
				
				AddClickEffect(Btn)
				
				Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Hover}) end)
				Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Main}) end)
				Btn.MouseButton1Click:Connect(function() CreateRipple(Btn); pcall(Callback) end)
			end

			function SecActions:AddToggle(Text, Default, Callback)
				local Tgl = Instance.new("TextButton", Container)
				Tgl.Size = UDim2.new(1, 0, 0, 28)
				Tgl.BackgroundTransparency = 1
				Tgl.Text = ""
				Tgl.AutoButtonColor = false
				
				-- On compense le AnchorPoint
				Tgl.Position = UDim2.new(0.5, 0, 0, 0)
				AddClickEffect(Tgl)

				local Lab = Instance.new("TextLabel", Tgl)
				Lab.Size = UDim2.new(1, -45, 1, 0)
				Lab.BackgroundTransparency = 1
				Lab.Text = Text
				Lab.TextColor3 = Theme.TextDark
				Lab.Font = Enum.Font.GothamMedium
				Lab.TextSize = 12
				Lab.TextXAlignment = Enum.TextXAlignment.Left
				
				local Bg = Instance.new("Frame", Tgl)
				Bg.Size = UDim2.new(0, 34, 0, 18)
				Bg.Position = UDim2.new(1, -34, 0.5, -9)
				Bg.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff
				Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
				
				local Dot = Instance.new("Frame", Bg)
				Dot.Size = UDim2.new(0, 14, 0, 14)
				Dot.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
				Dot.BackgroundColor3 = Color3.new(1,1,1)
				Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
				
				local State = Default
				Tgl.MouseButton1Click:Connect(function()
					State = not State
					Tween(Bg, {BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff})
					Tween(Dot, {Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
					Tween(Lab, {TextColor3 = State and Theme.Text or Theme.TextDark})
					pcall(Callback, State)
				end)
			end

			function SecActions:AddSlider(Text, Min, Max, Default, Callback)
				local Sld = Instance.new("Frame", Container)
				Sld.Size = UDim2.new(1, 0, 0, 45)
				Sld.BackgroundTransparency = 1
				
				local Title = Instance.new("TextLabel", Sld)
				Title.Size = UDim2.new(1, 0, 0, 20)
				Title.BackgroundTransparency = 1; Title.Text = Text; Title.TextColor3 = Theme.TextDark; Title.Font = "GothamMedium"; Title.TextSize = 12; Title.TextXAlignment = "Left"
				local Val = Instance.new("TextLabel", Sld)
				Val.Size = UDim2.new(1, 0, 0, 20); Val.BackgroundTransparency = 1; Val.Text = tostring(Default); Val.TextColor3 = Theme.Text; Val.Font = "GothamBold"; Val.TextSize = 12; Val.TextXAlignment = "Right"
				
				local Bar = Instance.new("Frame", Sld)
				Bar.Size = UDim2.new(1, 0, 0, 4); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				local Fill = Instance.new("Frame", Bar)
				Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				
				local Active=false
				local function Update(Input)
					local Size = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local Value = math.floor(Min + ((Max - Min) * Size))
					Tween(Fill, {Size = UDim2.new(Size, 0, 1, 0)}, 0.05)
					Val.Text = tostring(Value); pcall(Callback, Value)
				end
				Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Active=true; Update(i) end end)
				UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Active=false end end)
				UserInputService.InputChanged:Connect(function(i) if Active and i.UserInputType==Enum.UserInputType.MouseMovement then Update(i) end end)
			end
			
			return SecActs
		end
		return TabActions
	end
	return WindowActions
end

return Library
