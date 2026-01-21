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
	Text = Color3.fromRGB(255, 255, 255)
}

-- [[ ÉCRAN DE BIENVENUE RÉPARÉ ]] --
function Library:CreateWelcomeScreen()
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome_Fix"
	WelcomeGui.DisplayOrder = 999 -- Force l'affichage au premier plan

	local BackFrame = Instance.new("Frame", WelcomeGui)
	BackFrame.Size = UDim2.new(1, 0, 1, 0)
	BackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BackFrame.BackgroundTransparency = 1
	BackFrame.BorderSizePixel = 0
	BackFrame.ZIndex = 1

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 0, 100)
	TextLabel.Position = UDim2.new(0, 0, 0.5, -50)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME 8.8.8.8 UI" -- Simple texte sans balises pour tester
	TextLabel.TextColor3 = Theme.Accent
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 40
	TextLabel.TextTransparency = 1
	TextLabel.ZIndex = 2 -- Toujours au-dessus du fond noir

	-- Animation
	TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
	TS:Create(TextLabel, TweenInfo.new(0.8, Enum.EasingStyle.Back), {TextTransparency = 0}):Play()

	task.delay(3, function()
		TS:Create(TextLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		Debris:AddItem(WelcomeGui, 0.6)
	end)
end

-- [[ FENÊTRE PRINCIPALE ]] --
function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_MainUI"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 350)
	Main.Position = UDim2.new(0.5, -250, 0.5, -175)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Instance.new("UICorner", Main)
	Instance.new("UIStroke", Main).Color = Theme.Outline

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -20)
	Scroll.Position = UDim2.new(0, 10, 0, 10)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.ScrollBarThickness = 0
	Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)

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
			Btn.AutoButtonColor = false
			Btn.ClipsDescendants = true
			Instance.new("UICorner", Btn)
			Btn.MouseButton1Click:Connect(function()
				callback()
			end)
		end
		return SectionActions
	end
	return WindowActions
end

return Library
