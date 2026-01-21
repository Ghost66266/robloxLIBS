-- [[ 8.8.8.8 NEVER-WIN UI LIBRARY ]] --
-- [[ VERSION: V15 FLUIDITY | AUTHOR: GHOST66266 ]] --

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Library = {}

-- [ THEME CONFIG ] --
local Theme = {
	Main        = Color3.fromRGB(20, 20, 20),
	Sidebar     = Color3.fromRGB(15, 15, 15),
	Section     = Color3.fromRGB(25, 25, 25),
	Accent      = Color3.fromRGB(170, 0, 255),
	Text        = Color3.fromRGB(255, 255, 255),
	TextDark    = Color3.fromRGB(150, 150, 150),
	Outline     = Color3.fromRGB(45, 45, 45),
	ToggleOff   = Color3.fromRGB(35, 35, 35),
	Hover       = Color3.fromRGB(35, 35, 40),
	Dropdown    = Color3.fromRGB(30, 30, 30)
}

-- [ UTILITAIRES D'ANIMATION ] --

-- Tween rapide générique
local function TweenObj(obj, properties, time, style)
	local Info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(obj, Info, properties):Play()
end

-- Effet Onde de Choc
local function CreateRipple(obj)
	if not obj then return end
	obj.ClipsDescendants = true
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "Ripple"
		Ripple.Parent = obj
		Ripple.BackgroundTransparency = 1
		Ripple.Image = "rbxassetid://266543268"
		Ripple.ImageColor3 = Theme.Accent
		Ripple.ImageTransparency = 0.6
		Ripple.ZIndex = 15
		local Rx, Ry = Mouse.X - obj.AbsolutePosition.X, Mouse.Y - obj.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, Rx, 0, Ry)
		Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		Ripple.Size = UDim2.new(0, 0, 0, 0)
		
		local T = TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5, 0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5),
			ImageTransparency = 1
		})
		T:Play(); T.Completed:Wait(); Ripple:Destroy()
	end)
end

-- Effet de "Press" (Le bouton rétrécit un peu au clic)
local function AddClickEffect(Btn)
	Btn.MouseButton1Down:Connect(function()
		TweenObj(Btn, {Size = UDim2.new(1, -2, 0, Btn.Size.Y.Offset - 2)}, 0.1) -- Rapetisse
	end)
	Btn.MouseButton1Up:Connect(function()
		TweenObj(Btn, {Size = UDim2.new(1, 0, 0, Btn.Size.Y.Offset)}, 0.1) -- Reprend sa taille
	end)
	Btn.MouseLeave:Connect(function()
		TweenObj(Btn, {Size = UDim2.new(1, 0, 0, Btn.Size.Y.Offset)}, 0.1) -- Sécurité si on sort
	end)
end

-- [ INTRO CINEMATIQUE ] --
function Library:Welcome(TitleText, SubText)
	for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "8888_Intro" then v:Destroy() end end
	local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "8888_Intro"; Screen.IgnoreGuiInset = true; Screen.DisplayOrder = 10000
	local Blur = Instance.new("BlurEffect", Lighting); Blur.Size = 0
	local BackFrame = Instance.new("Frame", Screen); BackFrame.Size = UDim2.new(1,0,1,0); BackFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); BackFrame.BackgroundTransparency = 1; BackFrame.ZIndex = 1
	local MainLabel = Instance.new("TextLabel", Screen); MainLabel.Size = UDim2.new(1,0,0,150); MainLabel.Position = UDim2.new(0,0,0.4,0); MainLabel.BackgroundTransparency = 1; MainLabel.Text = string.upper(TitleText or "LIBRARY"); MainLabel.TextColor3 = Theme.Accent; MainLabel.Font = Enum.Font.GothamBlack; MainLabel.TextSize = 0; MainLabel.TextTransparency = 1; MainLabel.ZIndex = 2
	local SubLabel = Instance.new("TextLabel", Screen); SubLabel.Size = UDim2.new(1,0,0,50); SubLabel.Position = UDim2.new(0,0,0.55,0); SubLabel.BackgroundTransparency = 1; SubLabel.Text = string.upper(SubText or "INITIALIZING..."); SubLabel.TextColor3 = Theme.Text; SubLabel.Font = Enum.Font.GothamBold; SubLabel.TextSize = 20; SubLabel.TextTransparency = 1; SubLabel.ZIndex = 2

	task.spawn(function()
		TweenObj(Blur, {Size = 24}, 1); TweenObj(BackFrame, {BackgroundTransparency = 0.1}, 0.5); task.wait(0.5)
		local T1 = TweenService:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 90, TextTransparency = 0}); T1:Play(); task.wait(0.3)
		SubLabel.Position = UDim2.new(0,0,0.60,0); local T2 = TweenService:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0.55,0), TextTransparency = 0}); T2:Play(); task.wait(2.5)
		TweenObj(MainLabel, {TextSize = 0, TextTransparency = 1}, 0.5); TweenObj(SubLabel, {TextTransparency = 1}, 0.5); task.wait(0.2)
		TweenObj(BackFrame, {BackgroundTransparency = 1}, 0.5); TweenObj(Blur, {Size = 0}, 0.8); task.wait(0.8); Screen:Destroy(); Blur:Destroy()
	end)
end

-- [ FENETRE PRINCIPALE ] --
function Library:CreateWindow(Config)
	local UI_Name = Config.Name or "Library"
	if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end
	local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = UI_Name; ScreenGui.DisplayOrder = 100; ScreenGui.ResetOnSpawn = false
	
	local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(0, 750, 0, 500); MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250); MainFrame.BackgroundColor3 = Theme.Main; MainFrame.ClipsDescendants = true
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8); local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Theme.Outline; MainStroke.Thickness = 1
	
	local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 200, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0
	local TitleLabel = Instance.new("TextLabel", Sidebar); TitleLabel.Size = UDim2.new(1, -25, 0, 65); TitleLabel.Position = UDim2.new(0, 25, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = string.upper(UI_Name); TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.TextSize = 22; TitleLabel.TextColor3 = Theme.Text; TitleLabel.TextXAlignment = "Left"
	local TabContainer = Instance.new("ScrollingFrame", Sidebar); TabContainer.Size = UDim2.new(1, 0, 1, -80); TabContainer.Position = UDim2.new(0, 0, 0, 80); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0
	Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 4)
	
	local PageContainer = Instance.new("Frame", MainFrame); PageContainer.Name = "Pages"; PageContainer.Size = UDim2.new(1, -215, 1, -20); PageContainer.Position = UDim2.new(0, 210, 0, 10); PageContainer.BackgroundTransparency = 1

	-- Drag Logic
	local dragging, dragInput, dragStart, startPos
	Sidebar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=MainFrame.Position end end)
	Sidebar.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput=i end end)
	InputService.InputChanged:Connect(function(i) if i==dragInput and dragging then local d=i.Position-dragStart; MainFrame.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
	InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
	InputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.Insert then MainFrame.Visible=not MainFrame.Visible end end)

	local WinActions = {}
	local FirstTab = true

	function WinActions:AddTab(TabName)
		local TabButton = Instance.new("TextButton", TabContainer)
		TabButton.Size = UDim2.new(1, 0, 0, 40); TabButton.BackgroundTransparency = 1; TabButton.Text = ""; TabButton.AutoButtonColor = false
		local ActiveBar = Instance.new("Frame", TabButton); ActiveBar.Size = UDim2.new(0, 4, 0.6, 0); ActiveBar.Position = UDim2.new(0, 0, 0.2, 0); ActiveBar.BackgroundColor3 = Theme.Accent; ActiveBar.Transparency = 1; ActiveBar.BorderSizePixel = 0
		local Label = Instance.new("TextLabel", TabButton); Label.Size = UDim2.new(1, -30, 1, 0); Label.Position = UDim2.new(0, 30, 0, 0); Label.BackgroundTransparency = 1; Label.Text = TabName; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Theme.TextDark; Label.TextXAlignment = "Left"
		
		local Page = Instance.new("ScrollingFrame", PageContainer); Page.Name = TabName.."_Page"; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 0; Page.Visible = false
		local Grid = Instance.new("UIGridLayout", Page); Grid.SortOrder = "LayoutOrder"; Grid.CellPadding = UDim2.new(0, 15, 0, 15); Grid.CellSize = UDim2.new(0.48, 0, 0, 0)
		
		TabButton.MouseButton1Click:Connect(function()
			-- Désactiver les autres onglets
			for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then TweenObj(b.TextLabel, {TextColor3 = Theme.TextDark}); TweenObj(b.Frame, {Transparency = 1}) end end
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			
			-- Activer celui-ci avec TRANSITION
			Page.Visible = true
			-- Effet Slide Up : On part de plus bas (offset Y 15) et on remonte à 0
			Page.Position = UDim2.new(0, 0, 0, 15) 
			TweenObj(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)
			
			TweenObj(Label, {TextColor3 = Theme.Text}); TweenObj(ActiveBar, {Transparency = 0})
		end)
		
		if FirstTab then Page.Visible = true; Label.TextColor3 = Theme.Text; ActiveBar.Transparency = 0; FirstTab = false end
		
		local TabActs = {}
		function TabActs:AddSection(SecName)
			local Section = Instance.new("Frame", Page); Section.BackgroundColor3 = Theme.Section; Section.Size = UDim2.new(0.48, 0, 0, 100); Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)
			local Title = Instance.new("TextLabel", Section); Title.Size = UDim2.new(1, -20, 0, 35); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1; Title.Text = SecName; Title.Font = "GothamBold"; Title.TextSize = 12; Title.TextColor3 = Theme.Text; Title.TextXAlignment = "Left"
			local Div = Instance.new("Frame", Section); Div.Size = UDim2.new(1, 0, 0, 1); Div.Position = UDim2.new(0, 0, 0, 35); Div.BackgroundColor3 = Theme.Outline; Div.BorderSizePixel = 0
			local Container = Instance.new("Frame", Section); Container.Size = UDim2.new(1, -20, 1, -45); Container.Position = UDim2.new(0, 10, 0, 45); Container.BackgroundTransparency = 1
			local List = Instance.new("UIListLayout", Container); List.SortOrder = "LayoutOrder"; List.Padding = UDim.new(0, 6)
			
			List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Section.Size = UDim2.new(0.48, 0, 0, List.AbsoluteContentSize.Y + 55); local MaxH = 0; for _, c in pairs(Page:GetChildren()) do if c:IsA("Frame") then local Y = c.AbsolutePosition.Y + c.AbsoluteSize.Y - Page.AbsolutePosition.Y; if Y > MaxH then MaxH = Y end end end; Page.CanvasSize = UDim2.new(0, 0, 0, MaxH + 20) end)

			local SecActs = {}

			-- BUTTON
			function SecActs:AddButton(Text, Callback)
				local Btn = Instance.new("TextButton", Container); Btn.Size = UDim2.new(1, 0, 0, 28); Btn.BackgroundColor3 = Theme.Main; Btn.Text = Text; Btn.TextColor3 = Theme.Text; Btn.Font = "GothamBold"; Btn.TextSize = 11; Btn.AutoButtonColor = false; Btn.ClipsDescendants = true
				Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", Btn).Color = Theme.Outline
				
				AddClickEffect(Btn) -- Animation de Press
				
				Btn.MouseEnter:Connect(function() TweenObj(Btn, {BackgroundColor3 = Theme.Hover}) end)
				Btn.MouseLeave:Connect(function() TweenObj(Btn, {BackgroundColor3 = Theme.Main}) end)
				Btn.MouseButton1Click:Connect(function() CreateRipple(Btn); pcall(Callback) end)
			end
			
			-- LABEL
			function SecActs:AddLabel(Text)
				local Lab = Instance.new("TextLabel", Container); Lab.Size = UDim2.new(1, 0, 0, 20); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Theme.TextDark; Lab.Font = "Gotham"; Lab.TextSize = 11; Lab.TextXAlignment = "Left"
			end

			-- TOGGLE
			function SecActs:AddToggle(Text, Default, Callback)
				local Tgl = Instance.new("TextButton", Container); Tgl.Size = UDim2.new(1, 0, 0, 26); Tgl.BackgroundTransparency = 1; Tgl.Text = ""; Tgl.AutoButtonColor = false
				local Lab = Instance.new("TextLabel", Tgl); Lab.Size = UDim2.new(1, -40, 1, 0); Lab.BackgroundTransparency = 1; Lab.Text = Text; Lab.TextColor3 = Theme.TextDark; Lab.Font = "GothamMedium"; Lab.TextSize = 12; Lab.TextXAlignment = "Left"
				local Bg = Instance.new("Frame", Tgl); Bg.Size = UDim2.new(0, 32, 0, 16); Bg.Position = UDim2.new(1, -32, 0.5, -8); Bg.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff; Instance.new("UICorner", Bg).CornerRadius = UDim.new(1, 0)
				local Dot = Instance.new("Frame", Bg); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = Default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); Dot.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
				
				AddClickEffect(Tgl) -- Animation de Press

				local State = Default
				Tgl.MouseButton1Click:Connect(function() State = not State; TweenObj(Bg, {BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff}); TweenObj(Dot, {Position = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}); TweenObj(Lab, {TextColor3 = State and Theme.Text or Theme.TextDark}); pcall(Callback, State) end)
			end

			-- SLIDER
			function SecActs:AddSlider(Text, Min, Max, Default, Callback)
				local Sld = Instance.new("Frame", Container); Sld.Size = UDim2.new(1, 0, 0, 40); Sld.BackgroundTransparency = 1
				local Title = Instance.new("TextLabel", Sld); Title.Size = UDim2.new(1, 0, 0, 20); Title.BackgroundTransparency = 1; Title.Text = Text; Title.TextColor3 = Theme.TextDark; Title.Font = "GothamMedium"; Title.TextSize = 12; Title.TextXAlignment = "Left"
				local Val = Instance.new("TextLabel", Sld); Val.Size = UDim2.new(1, 0, 0, 20); Val.BackgroundTransparency = 1; Val.Text = tostring(Default); Val.TextColor3 = Theme.Text; Val.Font = "GothamBold"; Val.TextSize = 12; Val.TextXAlignment = "Right"
				local Bar = Instance.new("Frame", Sld); Bar.Size = UDim2.new(1, 0, 0, 4); Bar.Position = UDim2.new(0, 0, 0, 26); Bar.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				
				local Active = false; local function Update(Input) local Size = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1); local Value = math.floor(Min + ((Max - Min) * Size)); TweenObj(Fill, {Size = UDim2.new(Size, 0, 1, 0)}, 0.05); Val.Text = tostring(Value); pcall(Callback, Value) end
				Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Active = true; Update(i) end end)
				InputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Active = false end end)
				InputService.InputChanged:Connect(function(i) if Active and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
			end
			
			-- DROPDOWN
			function SecActs:AddDropdown(Text, Items, Default, Callback)
				local Dropdown = Instance.new("Frame", Container); Dropdown.Size = UDim2.new(1, 0, 0, 30); Dropdown.BackgroundTransparency = 1; Dropdown.ClipsDescendants = true
				local Button = Instance.new("TextButton", Dropdown); Button.Size = UDim2.new(1, 0, 0, 30); Button.BackgroundColor3 = Theme.Main; Button.Text = ""; Button.AutoButtonColor = false; Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", Button).Color = Theme.Outline
				
				AddClickEffect(Button) -- Animation de Press

				local Label = Instance.new("TextLabel", Button); Label.Size = UDim2.new(1, -30, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0); Label.BackgroundTransparency = 1; Label.Text = Text .. ": " .. (Default or "None"); Label.TextColor3 = Theme.TextDark; Label.Font = Enum.Font.GothamMedium; Label.TextSize = 12; Label.TextXAlignment = "Left"
				local Icon = Instance.new("ImageLabel", Button); Icon.Size = UDim2.new(0, 20, 0, 20); Icon.Position = UDim2.new(1, -25, 0.5, -10); Icon.BackgroundTransparency = 1; Icon.Image = "rbxassetid://6031091004"; Icon.ImageColor3 = Theme.TextDark
				local ListFrame = Instance.new("ScrollingFrame", Dropdown); ListFrame.Size = UDim2.new(1, 0, 0, 100); ListFrame.Position = UDim2.new(0, 0, 0, 32); ListFrame.BackgroundColor3 = Theme.Dropdown; ListFrame.BorderSizePixel = 0; ListFrame.ScrollBarThickness = 2; Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 4); local ListLayout = Instance.new("UIListLayout", ListFrame); ListLayout.SortOrder = "LayoutOrder"; ListLayout.Padding = UDim.new(0, 2)
				
				local Open = false; local ItemHeight = 25
				local function Update()
					for _, c in pairs(ListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
					for _, Itm in pairs(Items) do
						local ItmBtn = Instance.new("TextButton", ListFrame); ItmBtn.Size = UDim2.new(1, -4, 0, ItemHeight); ItmBtn.BackgroundColor3 = Theme.Dropdown; ItmBtn.Text = "  " .. Itm; ItmBtn.TextColor3 = Theme.TextDark; ItmBtn.Font = "Gotham"; ItmBtn.TextSize = 12; ItmBtn.TextXAlignment = "Left"; ItmBtn.AutoButtonColor = false; Instance.new("UICorner", ItmBtn).CornerRadius = UDim.new(0, 3)
						ItmBtn.MouseEnter:Connect(function() ItmBtn.BackgroundColor3 = Theme.Hover; ItmBtn.TextColor3 = Theme.Text end); ItmBtn.MouseLeave:Connect(function() ItmBtn.BackgroundColor3 = Theme.Dropdown; ItmBtn.TextColor3 = Theme.TextDark end)
						ItmBtn.MouseButton1Click:Connect(function() Open = false; Label.Text = Text .. ": " .. Itm; TweenObj(Dropdown, {Size = UDim2.new(1, 0, 0, 30)}); TweenObj(Icon, {Rotation = 0}); pcall(Callback, Itm) end)
					end
					ListFrame.CanvasSize = UDim2.new(0, 0, 0, #Items * (ItemHeight + 2))
				end
				Button.MouseButton1Click:Connect(function() Open = not Open; Update(); if Open then TweenObj(Dropdown, {Size = UDim2.new(1, 0, 0, math.min(#Items * 27, 100) + 35)}); TweenObj(Icon, {Rotation = 180}) else TweenObj(Dropdown, {Size = UDim2.new(1, 0, 0, 30)}); TweenObj(Icon, {Rotation = 0}) end end)
			end
			return SecActs
		end
		return TabActs
	end
	return WinActions
end
return Library
