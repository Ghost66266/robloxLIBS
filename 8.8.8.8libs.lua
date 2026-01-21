local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(8, 8, 10),
	Section = Color3.fromRGB(15, 15, 20),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(40, 40, 50),
	Text = Color3.fromRGB(255, 255, 255)
}

-- [[ EFFET RIPPLE NÉON ]] --
local function CreateRipple(parent, pos)
	local Ripple = Instance.new("Frame", parent)
	Ripple.Size = UDim2.new(0, 0, 0, 0)
	Ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
	Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	Ripple.BackgroundColor3 = Theme.Accent
	Ripple.BackgroundTransparency = 0.5
	Ripple.BorderSizePixel = 0
	Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1,0)
	
	-- Animation d'expansion et de fondu
	TS:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, parent.AbsoluteSize.X * 2.5, 0, parent.AbsoluteSize.X * 2.5),
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.6, function() Ripple:Destroy() end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Godly_Lib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Color = Theme.Outline
	MainStroke.Thickness = 1.5

	-- Drag
	local dragging, dragStart, startPos
	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; dragStart = input.Position; startPos = Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -60)
	Scroll.Position = UDim2.new(0, 10, 0, 50)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.ScrollBarThickness = 0
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 12)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Actions = {}

	function Actions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.95, 0, 0, 30)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Section.BorderSizePixel = 0
		Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
		Instance.new("UIStroke", Section).Color = Theme.Outline

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 6)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 10)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 35)
			Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			Btn.Text = text
			Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 13
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false -- DÉSACTIVE L'EFFET BLANC ROBLOX
			Instance.new("UICorner", Btn)
			local bStroke = Instance.new("UIStroke", Btn)
			bStroke.Color = Theme.Outline
			bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- [[ EFFETS DE FOU ]] --
			Btn.MouseEnter:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Theme.Accent}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Accent, Thickness = 2}):Play()
				TS:Create(Btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0.95, 0, 0, 38)}):Play()
			end)

			Btn.MouseLeave:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 30), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Outline, Thickness = 1}):Play()
				TS:Create(Btn, TweenInfo.new(0.3), {Size = UDim2.new(0.92, 0, 0, 35)}):Play()
			end)

			Btn.MouseButton1Click:Connect(function()
				local m = UIS:GetMouseLocation()
				local relPos = Vector2.new(m.X - Btn.AbsolutePosition.X, (m.Y - 36) - Btn.AbsolutePosition.Y)
				CreateRipple(Btn, relPos)
				
				-- Petit effet de "pression"
				Btn.Size = UDim2.new(0.9, 0, 0, 32)
				task.wait(0.1)
				Btn:TweenSize(UDim2.new(0.95, 0, 0, 38), "Out", "Back", 0.2, true)
				callback()
			end)
		end

		return SectionActions
	end
	return Actions
end

return Library
