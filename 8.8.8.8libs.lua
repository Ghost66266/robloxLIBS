local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255)
}

-- Fonction Ripple Ultra-Stable
local function CreateRipple(obj)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Circle = Instance.new("ImageLabel")
	Circle.Parent = obj
	Circle.BackgroundColor3 = Color3.new(1, 1, 1)
	Circle.BackgroundTransparency = 1
	Circle.Image = "rbxassetid://266543268"
	Circle.ImageColor3 = Theme.Accent
	Circle.ImageTransparency = 0.5
	Circle.ZIndex = 10
	
	local RelX = Mouse.X - obj.AbsolutePosition.X
	local RelY = Mouse.Y - obj.AbsolutePosition.Y
	Circle.Position = UDim2.new(0, RelX, 0, RelY)
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)
	Circle.Size = UDim2.new(0, 0, 0, 0)

	TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, obj.AbsoluteSize.X * 2, 0, obj.AbsoluteSize.X * 2),
		ImageTransparency = 1
	}):Play()
	game:GetService("Debris"):AddItem(Circle, 0.6)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui")
	UI.Name = "8888_Final_Lib"
	UI.Parent = CoreGui

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 350)
	Main.Position = UDim2.new(0.5, -250, 0.5, -175)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -20)
	Scroll.Position = UDim2.new(0, 10, 0, 10)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.ScrollBarThickness = 0
	
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 10)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.95, 0, 0, 40)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 10)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.9, 0, 0, 35)
			Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			Btn.Text = text
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn)
			
			Btn.MouseButton1Click:Connect(function()
				CreateRipple(Btn)
				callback()
			end)
		end
		return SectionActions
	end
	return WindowActions
end

return Library -- TRÈS IMPORTANT
