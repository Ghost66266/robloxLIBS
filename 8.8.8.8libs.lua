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

function Library:CreateWelcomeScreen()
	local Debris = game:GetService("Debris")
	
	local WelcomeGui = Instance.new("ScreenGui", CoreGui)
	WelcomeGui.Name = "8888_Welcome_Ultra"
	WelcomeGui.DisplayOrder = 999999 -- Priorité absolue
	WelcomeGui.IgnoreGuiInset = true 

	-- FOND NOIR TOTAL (On déborde de l'écran pour être sûr)
	local BackFrame = Instance.new("Frame", WelcomeGui)
	BackFrame.Size = UDim2.new(2, 0, 2, 0) -- 2x la taille de l'écran
	BackFrame.Position = UDim2.new(-0.5, 0, -0.5, 0) -- Centré pour tout couvrir
	BackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BackFrame.BackgroundTransparency = 1
	BackFrame.BorderSizePixel = 0
	BackFrame.ZIndex = 1

	local TextLabel = Instance.new("TextLabel", WelcomeGui)
	TextLabel.Size = UDim2.new(1, 0, 0, 300)
	TextLabel.Position = UDim2.new(0, 0, 0.5, -150)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = "WELCOME <font color='#AA00FF'>8.8.8.8</font> UI"
	TextLabel.RichText = true
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.Font = Enum.Font.GothamBold
	TextLabel.TextSize = 85 -- TEXTE GÉANT
	TextLabel.TextTransparency = 1
	TextLabel.ZIndex = 2

	-- ANIMATION D'ENTRÉE
	TS:Create(BackFrame, TweenInfo.new(1), {BackgroundTransparency = 0.3}):Play()
	local ShowText = TS:Create(TextLabel, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextSize = 90
	})
	ShowText:Play()

	-- ON FORCE L'ATTENTE (On ne sort pas d'ici avant 7 secondes réelles)
	local StartTime = tick()
	task.spawn(function()
		while (tick() - StartTime) < 7 do
			TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Theme.Accent}):Play()
			task.wait(1)
			TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.new(1,1,1)}):Play()
			task.wait(1)
		end
		
		-- ANIMATION DE SORTIE
		TS:Create(TextLabel, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextSize = 120
		}):Play()
		TS:Create(BackFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
		
		task.wait(1.1)
		WelcomeGui:Destroy()
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
