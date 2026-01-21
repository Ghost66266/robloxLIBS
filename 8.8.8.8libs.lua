local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(35, 35, 40),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(150, 150, 155)
}

-- [[ EFFET RIPPLE (L'ONDE VIOLETTE) ]] --
local function CreateRipple(parent, pos)
	local Ripple = Instance.new("Frame", parent)
	Ripple.Size = UDim2.new(0, 0, 0, 0)
	Ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
	Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	Ripple.BackgroundColor3 = Theme.Accent
	Ripple.BackgroundTransparency = 0.6
	Ripple.BorderSizePixel = 0
	Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1,0)
	TS:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 250, 0, 250), 
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.6, function() Ripple:Destroy() end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Premium_Final"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 380)
	Main.Position = UDim2.new(0.5, -250, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	-- [[ SYSTÈME DE DRAG ]] --
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

	-- [[ HEADER AVEC SCANLINE ]] --
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 45)
	Header.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
	Header.BorderSizePixel = 0
	
	local TitleLabel = Instance.new("TextLabel", Header)
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.Text = title or "8.8.8.8 <font color='#AA00FF'>UI</font>"
	TitleLabel.RichText = true
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 18
	TitleLabel.BackgroundTransparency = 1

	local Scanline = Instance.new("Frame", Header)
	Scanline.Size = UDim2.new(1, 0, 0, 1)
	Scanline.BackgroundColor3 = Theme.Accent
	Scanline.BackgroundTransparency = 0.5
	TS:Create(Scanline, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

	-- [[ SCROLLING AREA ]] --
	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -65)
	Scroll.Position = UDim2.new(0, 10, 0, 55)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.ScrollBarThickness = 2
	Scroll.ScrollBarImageColor3 = Theme.Accent
	Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 15)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.95, 0, 0, 0)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Section.BorderSizePixel = 0
		Instance.new("UICorner", Section)
		Instance.new("UIStroke", Section).Color = Theme.Outline

		local st = Instance.new("TextLabel", Section)
		st.Size = UDim2.new(1, 0, 0, 25)
		st.Position = UDim2.new(0, 12, 0, -10)
		st.Text = sTitle:upper()
		st.TextColor3 = Theme.Accent
		st.Font = Enum.Font.GothamBold
		st.TextSize = 11
		st.BackgroundTransparency = 1
		st.TextXAlignment = Enum.TextXAlignment.Left

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 15)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.9, 0, 0, 32)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 13
			Btn.TextXAlignment = Enum.TextXAlignment.Left
			Btn.ClipsDescendants = true -- IMPORTANT POUR LE RIPPLE
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn)
			local s = Instance.new("UIStroke", Btn)
			s.Color = Theme.Outline

			-- Effet Hover
			Btn.MouseEnter:Connect(function()
				TS:Create(s, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
			end)
			Btn.MouseLeave:Connect(function()
				TS:Create(s, TweenInfo.new(0.2), {Color = Theme.Outline}):Play()
			end)

			Btn.MouseButton1Click:Connect(function()
				local mouse = UIS:GetMouseLocation()
				local relativePos = Vector2.new(mouse.X - Btn.AbsolutePosition.X, mouse.Y - Btn.AbsolutePosition.Y - 36)
				CreateRipple(Btn, relativePos)
				callback()
			end)
		end

		return SectionActions
	end
	return WindowActions
end

return Library
