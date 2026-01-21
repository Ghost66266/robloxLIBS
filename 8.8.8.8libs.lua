local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Sidebar = Color3.fromRGB(13, 13, 16),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(35, 35, 40),
	Text = Color3.fromRGB(255, 255, 255),
	Section = Color3.fromRGB(18, 18, 22)
}

-- Effet d'onde (Ripple)
local function CreateRipple(parent, pos)
	local Ripple = Instance.new("Frame", parent)
	Ripple.Size = UDim2.new(0, 0, 0, 0)
	Ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
	Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	Ripple.BackgroundColor3 = Theme.Accent
	Ripple.BackgroundTransparency = 0.6
	Ripple.BorderSizePixel = 0
	Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1,0)
	TS:Create(Ripple, TweenInfo.new(0.5), {Size = UDim2.new(0, 250, 0, 250), BackgroundTransparency = 1}):Play()
	task.delay(0.6, function() Ripple:Destroy() end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_UI_Lib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 350)
	Main.Position = UDim2.new(0.5, -250, 0.5, -175)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Color = Theme.Outline

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

	-- Header
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundColor3 = Theme.Sidebar
	Header.BorderSizePixel = 0
	Instance.new("UICorner", Header)

	local Scanline = Instance.new("Frame", Header)
	Scanline.Size = UDim2.new(1, 0, 0, 1)
	Scanline.BackgroundColor3 = Theme.Accent
	Scanline.BackgroundTransparency = 0.5
	TS:Create(Scanline, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.Text = title or "8.8.8.8 UI"
	TitleLabel.RichText = true
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.BackgroundTransparency = 1

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -60)
	Scroll.Position = UDim2.new(0, 10, 0, 50)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.ScrollBarThickness = 0
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

	local Actions = {}

	function Actions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(1, 0, 0, 30)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Section.BorderSizePixel = 0
		Instance.new("UICorner", Section)
		Instance.new("UIStroke", Section).Color = Theme.Outline

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		local L = Instance.new("UIListLayout", Container)
		L.Padding = UDim.new(0, 5)
		L.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 10)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.9, 0, 0, 30)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = text
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 13
			Btn.ClipsDescendants = true
			Instance.new("UICorner", Btn)
			
			Btn.MouseButton1Click:Connect(function()
				local m = UIS:GetMouseLocation()
				CreateRipple(Btn, Vector2.new(m.X - Btn.AbsolutePosition.X, m.Y - Btn.AbsolutePosition.Y - 36))
				callback()
			end)
		end
		
		return SectionActions
	end
	return Actions
end

return Library
