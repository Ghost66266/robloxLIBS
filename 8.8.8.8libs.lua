local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(18, 18, 22),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(160, 160, 165)
}

-- [[ EFFET ONDE ]] --
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
	TS:Create(Circle, TweenInfo.new(0.5), {Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5), ImageTransparency = 1}):Play()
	Debris:AddItem(Circle, 0.6)
end

-- [[ ACCUEIL SANS FOND ]] --
function Library:CreateWelcomeScreen()
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome"
	WelcomeGui.IgnoreGuiInset = true

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 0, 200)
	TextLabel.Position = UDim2.new(0, 0, 0.5, -100)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME <font color='#AA00FF'>8.8.8.8</font> UI"
	TextLabel.RichText = true
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 0
	TextLabel.TextTransparency = 1

	TS:Create(TextLabel, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 80, TextTransparency = 0}):Play()

	task.delay(6, function()
		if TextLabel then
			TS:Create(TextLabel, TweenInfo.new(1), {TextTransparency = 1, TextSize = 100}):Play()
			Debris:AddItem(WelcomeGui, 1.1)
		end
	end)
end

-- [[ FENÊTRE ]] --
function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Main"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 520, 0, 380)
	Main.Position = UDim2.new(0.5, -260, 0.5, -190)
	Main.BackgroundColor3 = Theme.Main
	Instance.new("UICorner", Main)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 45)
	Header.BackgroundColor3 = Theme.Section
	Instance.new("UICorner", Header)

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.Text = title or "8.8.8.8 UI"
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = "Left"

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -65)
	Scroll.Position = UDim2.new(0, 10, 0, 55)
	Scroll.BackgroundTransparency = 1
	Scroll.AutomaticCanvasSize = "Y"
	Scroll.ScrollBarThickness = 0
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 12)
	Layout.HorizontalAlignment = "Center"

	local WindowActions = {}

	function WindowActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 30)
		Section.AutomaticSize = "Y"
		Section.BackgroundColor3 = Theme.Section
		Instance.new("UICorner", Section)

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		local CLayout = Instance.new("UIListLayout", Container)
		CLayout.Padding = UDim.new(0, 6)
		CLayout.HorizontalAlignment = "Center"
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 12)

		local SectionActions = {}

		function SectionActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 35)
			Btn.BackgroundColor3 = Theme.Main
			Btn.Text = "  " .. text
			Btn.TextColor3 = Theme.TextDark
			Btn.Font = "GothamMedium"
			Btn.TextSize = 13
			Btn.TextXAlignment = "Left"
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn)
			Btn.MouseButton1Click:Connect(function() CreateRipple(Btn) callback() end)
		end
		
		return SectionActions
	end
	return WindowActions
end

return Library
