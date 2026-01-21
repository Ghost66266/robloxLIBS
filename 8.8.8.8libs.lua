local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(35, 35, 40),
	Text = Color3.fromRGB(255, 255, 255)
}

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Final_Lib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 350)
	Main.Position = UDim2.new(0.5, -250, 0.5, -175)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	-- Drag System
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

	-- Scroll Area (Où tout va s'afficher)
	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -20)
	Scroll.Position = UDim2.new(0, 10, 0, 10)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Theme.Accent

	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 10)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Name = sTitle .. "_Section"
		Section.Size = UDim2.new(0.95, 0, 0, 50) -- Taille de base
		Section.AutomaticSize = Enum.AutomaticSize.Y -- S'agrandit avec les boutons
		Section.BackgroundColor3 = Theme.Section
		Section.BorderSizePixel = 0
		Instance.new("UICorner", Section)
		Instance.new("UIStroke", Section).Color = Theme.Outline

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		
		local ContainerLayout = Instance.new("UIListLayout", Container)
		ContainerLayout.Padding = UDim.new(0, 5)
		ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        
        -- Padding interne pour pas que les boutons touchent les bords
        local p = Instance.new("UIPadding", Container)
        p.PaddingTop = UDim.new(0, 10)
        p.PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.9, 0, 0, 35) -- Bouton bien visible
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = text
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 14
			Instance.new("UICorner", Btn)
            Instance.new("UIStroke", Btn).Color = Theme.Outline

			Btn.MouseButton1Click:Connect(function()
				callback()
			end)
		end

		return SectionActions
	end

	return WindowActions
end

return Library
