-- [[ 8.8.8.8 NEVER-WIN UI LIBRARY ]] --
-- [[ VERSION: V11.5 FIXED | AUTHOR: GHOST66266 ]] --

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Library = {}

-- [ CONFIGURATION DU THÈME ] --
local Theme = {
	Main        = Color3.fromRGB(20, 20, 20),
	Sidebar     = Color3.fromRGB(15, 15, 15),
	Section     = Color3.fromRGB(25, 25, 25),
	Accent      = Color3.fromRGB(170, 0, 255),
	Text        = Color3.fromRGB(255, 255, 255),
	TextDark    = Color3.fromRGB(150, 150, 150),
	Outline     = Color3.fromRGB(45, 45, 45),
	ToggleOff   = Color3.fromRGB(35, 35, 35),
	Hover       = Color3.fromRGB(35, 35, 40)
}

-- [ FONCTIONS UTILITAIRES ] --
local function CreateRipple(obj)
	if not obj then return end
	obj.ClipsDescendants = true
	
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "RippleEffect"
		Ripple.Parent = obj
		Ripple.BackgroundTransparency = 1
		Ripple.Image = "rbxassetid://266543268"
		Ripple.ImageColor3 = Theme.Accent
		Ripple.ImageTransparency = 0.6
		Ripple.ZIndex = 15
		
		local RelativeX = Mouse.X - obj.AbsolutePosition.X
		local RelativeY = Mouse.Y - obj.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, RelativeX, 0, RelativeY)
		Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		Ripple.Size = UDim2.new(0, 0, 0, 0)
		
		local Tween = TS:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5, 0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5),
			ImageTransparency = 1
		})
		
		Tween:Play()
		Tween.Completed:Wait()
		Ripple:Destroy()
	end)
end

local function TweenObj(obj, properties, time)
	TS:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

-- [ SYSTÈME DE BIENVENUE CINÉMATIQUE (CORRIGÉ) ] --
function Library:Welcome(TitleText, SubText)
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name == "8888_Intro" then v:Destroy() end
	end

	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.Name = "8888_Intro"
	Screen.IgnoreGuiInset = true
	Screen.DisplayOrder = 10000

	local Blur = Instance.new("BlurEffect", Lighting)
	Blur.Size = 0
	
	local BackFrame = Instance.new("Frame", Screen)
	BackFrame.Size = UDim2.new(1, 0, 1, 0)
	BackFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	BackFrame.BackgroundTransparency = 1
	BackFrame.ZIndex = 1

	local MainLabel = Instance.new("TextLabel", Screen)
	MainLabel.Size = UDim2.new(1, 0, 0, 150)
	MainLabel.Position = UDim2.new(0, 0, 0.4, 0)
	MainLabel.BackgroundTransparency = 1
	MainLabel.Text = string.upper(TitleText or "LIBRARY")
	MainLabel.TextColor3 = Theme.Accent
	MainLabel.Font = Enum.Font.GothamBlack
	MainLabel.TextSize = 0
	MainLabel.TextTransparency = 1
	MainLabel.ZIndex = 2
	
	local SubLabel = Instance.new("TextLabel", Screen)
	SubLabel.Size = UDim2.new(1, 0, 0, 50)
	SubLabel.Position = UDim2.new(0, 0, 0.55, 0)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Text = string.upper(SubText or "INITIALIZING...")
	SubLabel.TextColor3 = Theme.Text
	SubLabel.Font = Enum.Font.GothamBold
	SubLabel.TextSize = 20
	SubLabel.TextTransparency = 1
	-- J'ai retiré la ligne TextSpacing qui faisait crash
	SubLabel.ZIndex = 2

	task.spawn(function()
		TS:Create(Blur, TweenInfo.new(1), {Size = 24}):Play()
		TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
		task.wait(0.5)

		TS:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			TextSize = 90, 
			TextTransparency = 0
		}):Play()
		
		task.wait(0.3)
		
		SubLabel.Position = UDim2.new(0, 0, 0.60, 0)
		TS:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0.55, 0),
			TextTransparency = 0
		}):Play()

		task.wait(2.5)

		TS:Create(MainLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {TextSize = 0, TextTransparency = 1}):Play()
		TS:Create(SubLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		task.wait(0.2)
		TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		TS:Create(Blur, TweenInfo.new(0.8), {Size = 0}):Play()
		
		task.wait(0.8)
		Screen:Destroy()
		Blur:Destroy()
	end)
end

-- [ FENÊTRE PRINCIPALE ] --
function Library:CreateWindow(Config)
	local OldUI = CoreGui:FindFirstChild(Config.Name or "Library")
	if OldUI then OldUI:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = Config.Name or "Library"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 100
	
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 750, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	
	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Theme.Outline
	MainStroke.Thickness = 1
	
	local Sidebar = Instance.new("Frame", MainFrame)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	
	local AppTitle = Instance.new("TextLabel", Sidebar)
	AppTitle.Name = "Title"
	AppTitle.Size = UDim2.new(1, -20, 0, 60)
	AppTitle.Position = UDim2.new(0, 20, 0, 10)
	AppTitle.BackgroundTransparency = 1
	AppTitle.Text = string.upper(Config.Name or "UI")
	AppTitle.Font = Enum.Font.GothamBlack
	AppTitle.TextSize = 24
	AppTitle.TextColor3 = Theme.Text
	AppTitle.TextXAlignment = Enum.TextXAlignment.Left
	
	local TabContainer = Instance.new("ScrollingFrame", Sidebar)
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 1, -80)
	TabContainer.Position = UDim2.new(0, 0, 0, 80)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	
	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 5)
	
	local PageContainer = Instance.new("Frame", MainFrame)
	PageContainer.Name = "PageContainer"
	PageContainer.Size = UDim2.new(1, -210, 1, -20)
	PageContainer.Position = UDim2.new(0, 210, 0, 10)
	PageContainer.BackgroundTransparency = 1

	local dragging, dragInput, dragStart, startPos
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		end
	end)
	Sidebar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	UIS.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Enum.KeyCode.Insert then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	local WindowActions = {}
	local FirstTab = true

	function WindowActions:AddTab(TabName)
		local TabButton = Instance.new("TextButton", TabContainer)
		TabButton.Name = TabName
		TabButton.Size = UDim2.new(1, 0, 0, 45)
		TabButton.BackgroundTransparency = 1
		TabButton.Text = ""
		TabButton.AutoButtonColor = false
		
		local ActiveLine = Instance.new("Frame", TabButton)
		ActiveLine.Size = UDim2.new(0, 4, 0.6, 0)
		ActiveLine.Position = UDim2.new(0, 0, 0.2, 0)
		ActiveLine.BackgroundColor3 = Theme.Accent
		ActiveLine.Transparency = 1
		ActiveLine.BorderSizePixel = 0
		
		local TabLabel = Instance.new("TextLabel", TabButton)
		TabLabel.Size = UDim2.new(1, -30, 1, 0)
		TabLabel.Position = UDim2.new(0, 30, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text = TabName
		TabLabel.Font = Enum.Font.GothamBold
		TabLabel.TextSize = 14
		TabLabel.TextColor3 = Theme.TextDark
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Name = TabName .. "_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 0
		Page.Visible = false
		
		local PageGrid = Instance.new("UIGridLayout", Page)
		PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
		PageGrid.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
		PageGrid.CellSize = UDim2.new(0.48, 0, 0, 0)
		
		TabButton.MouseButton1Click:Connect(function()
			for _, btn in pairs(TabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					TweenObj(btn.TextLabel, {TextColor3 = Theme.TextDark})
					TweenObj(btn.Frame, {Transparency = 1})
				end
			end
			for _, pg in pairs(PageContainer:GetChildren()) do pg.Visible = false end
			
			Page.Visible = true
			TweenObj(TabLabel, {TextColor3 = Theme.Text})
			TweenObj(ActiveLine, {Transparency = 0})
		end)
		
		if FirstTab then
			Page.Visible = true; TabLabel.TextColor3 = Theme.Text; ActiveLine.Transparency = 0; FirstTab = false
		end

		local TabActions = {}

		function TabActions:AddSection(SectionName)
			local Section = Instance.new("Frame", Page)
			Section.Name = SectionName
			Section.BackgroundColor3 = Theme.Section
			Section.Size = UDim2.new(0.48, 0, 0, 100)
			Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
			
			local Header = Instance.new("TextLabel", Section)
			Header.Size = UDim2.new(1, -20, 0, 40)
			Header.Position = UDim2.new(0, 15, 0, 0)
			Header.BackgroundTransparency = 1
			Header.Text = SectionName
			Header.Font = Enum.Font.GothamBold
			Header.TextSize = 13
			Header.TextColor3 = Theme.Text
			Header.TextXAlignment = Enum.TextXAlignment.Left
			
			local Div = Instance.new("Frame", Section)
			Div.Size = UDim2.new(1, 0, 0, 1)
			Div.Position = UDim2.new(0, 0, 0, 40)
			Div.BackgroundColor3 = Theme.Outline
			Div.BorderSizePixel = 0
			
			local ItemContainer = Instance.new("Frame", Section)
			ItemContainer.Name = "Items"
			ItemContainer.Size = UDim2.new(1, -20, 1, -50)
			ItemContainer.Position = UDim2.new(0, 10, 0, 50)
			ItemContainer.BackgroundTransparency = 1
			
			local ItemList = Instance.new("UIListLayout", ItemContainer)
			ItemList.SortOrder = Enum.SortOrder.LayoutOrder
			ItemList.Padding = UDim.new(0, 6)
			
			ItemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				local ContentHeight = ItemList.AbsoluteContentSize.Y
				Section.Size = UDim2.new(0.48, 0, 0, ContentHeight + 60)
				
				local MaxH = 0
				for _, child in pairs(Page:GetChildren()) do
					if child:IsA("Frame") then
						local Y = child.AbsolutePosition.Y + child.AbsoluteSize.Y - Page.AbsolutePosition.Y
						if Y > MaxH then MaxH = Y end
					end
				end
				Page.CanvasSize = UDim2.new(0, 0, 0, MaxH + 20)
			end)

			local SectionActions = {}

			function SectionActions:AddButton(Text, Callback)
				local Button = Instance.new("TextButton", ItemContainer)
				Button.Size = UDim2.new(1, 0, 0, 32)
				Button.BackgroundColor3 = Theme.Main
				Button.Text = Text
				Button.TextColor3 = Theme.Text
				Button.Font = Enum.Font.GothamBold
				Button.TextSize = 12
				Button.AutoButtonColor = false
				Button.ClipsDescendants = true
				Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
				Instance.new("UIStroke", Button).Color = Theme.Outline
				
				Button.MouseEnter:Connect(function() TweenObj(Button, {BackgroundColor3 = Theme.Hover}) end)
				Button.MouseLeave:Connect(function() TweenObj(Button, {BackgroundColor3 = Theme.Main}) end)
				Button.MouseButton1Click:Connect(function() CreateRipple(Button); pcall(Callback) end)
			end

			function SectionActions:AddToggle(Text, Default, Callback)
				local ToggleBtn = Instance.new("TextButton", ItemContainer)
				ToggleBtn.Size = UDim2.new(1, 0, 0, 30)
				ToggleBtn.BackgroundTransparency = 1
				ToggleBtn.Text = ""
				ToggleBtn.AutoButtonColor = false
				
				local Label = Instance.new("TextLabel", ToggleBtn)
				Label.Size = UDim2.new(1, -45, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = Text
				Label.TextColor3 = Theme.TextDark
				Label.Font = Enum.Font.GothamMedium
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				
				local SwitchBg = Instance.new("Frame", ToggleBtn)
				SwitchBg.Size = UDim2.new(0, 36, 0, 18)
				SwitchBg.Position = UDim2.new(1, -36, 0.5, -9)
				SwitchBg.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff
				Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
				
				local SwitchCircle = Instance.new("Frame", SwitchBg)
				SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
				SwitchCircle.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
				SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)
				
				local Toggled = Default
				ToggleBtn.MouseButton1Click:Connect(function()
					Toggled = not Toggled
					if Toggled then
						TweenObj(SwitchBg, {BackgroundColor3 = Theme.Accent})
						TweenObj(SwitchCircle, {Position = UDim2.new(1, -16, 0.5, -7)})
						TweenObj(Label, {TextColor3 = Theme.Text})
					else
						TweenObj(SwitchBg, {BackgroundColor3 = Theme.ToggleOff})
						TweenObj(SwitchCircle, {Position = UDim2.new(0, 2, 0.5, -7)})
						TweenObj(Label, {TextColor3 = Theme.TextDark})
					end
					pcall(Callback, Toggled)
				end)
			end

			function SectionActions:AddSlider(Text, Min, Max, Default, Callback)
				local SliderFrame = Instance.new("Frame", ItemContainer)
				SliderFrame.Size = UDim2.new(1, 0, 0, 45)
				SliderFrame.BackgroundTransparency = 1
				
				local Label = Instance.new("TextLabel", SliderFrame)
				Label.Size = UDim2.new(1, 0, 0, 20)
				Label.BackgroundTransparency = 1
				Label.Text = Text
				Label.TextColor3 = Theme.TextDark
				Label.Font = Enum.Font.GothamMedium
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				
				local ValueLabel = Instance.new("TextLabel", SliderFrame)
				ValueLabel.Size = UDim2.new(1, 0, 0, 20)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Text = tostring(Default)
				ValueLabel.TextColor3 = Theme.Text
				ValueLabel.Font = Enum.Font.GothamBold
				ValueLabel.TextSize = 13
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				
				local Bar = Instance.new("Frame", SliderFrame)
				Bar.Size = UDim2.new(1, 0, 0, 4)
				Bar.Position = UDim2.new(0, 0, 0, 30)
				Bar.BackgroundColor3 = Theme.Outline
				Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				
				local Fill = Instance.new("Frame", Bar)
				Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				
				local IsSliding = false
				local function UpdateSlider(Input)
					local SizeScale = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local Value = math.floor(Min + ((Max - Min) * SizeScale))
					TweenObj(Fill, {Size = UDim2.new(SizeScale, 0, 1, 0)}, 0.05)
					ValueLabel.Text = tostring(Value)
					pcall(Callback, Value)
				end
				
				Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = true; UpdateSlider(input) end end)
				UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then IsSliding = false end end)
				UIS.InputChanged:Connect(function(input) if IsSliding and input.UserInputType == Enum.UserInputType.MouseMovement then UpdateSlider(input) end end)
			end
			return SectionActions
		end
		return TabActions
	end
	return WindowActions
end
return Library
