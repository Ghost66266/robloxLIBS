local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

-- THEME "FLUENT DARK VIOLET"
local Theme = {
	Main = Color3.fromRGB(15, 15, 15),
	Sidebar = Color3.fromRGB(20, 20, 20),
	Section = Color3.fromRGB(25, 25, 25),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 45),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(160, 160, 160)
}

-- [[ EFFET ONDE VIOLETTE ]] --
local function CreateRipple(obj)
	obj.ClipsDescendants = true 
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Circle = Instance.new("ImageLabel", obj)
		Circle.BackgroundTransparency = 1
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Theme.Accent
		Circle.ImageTransparency = 0.4
		Circle.ZIndex = 10
		Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
		Circle.AnchorPoint = Vector2.new(0.5, 0.5)
		Circle.Size = UDim2.new(0, 0, 0, 0)
		TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5), ImageTransparency = 1}):Play()
		Debris:AddItem(Circle, 0.6)
	end)
end

-- [[ MESSAGE DE BIENVENUE TITANESQUE ]] --
function Library:CreateWelcomeScreen(customText)
	if CoreGui:FindFirstChild("8888_Welcome") then CoreGui["8888_Welcome"]:Destroy() end
	
	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.Name = "8888_Welcome"
	Screen.DisplayOrder = 10000 -- Toujours tout devant
	Screen.IgnoreGuiInset = true
	
	-- Fond flouté sombre
	local Blur = Instance.new("Frame", Screen)
	Blur.Size = UDim2.new(1, 0, 1, 0)
	Blur.BackgroundColor3 = Color3.new(0,0,0)
	Blur.BackgroundTransparency = 1
	
	local Label = Instance.new("TextLabel", Screen)
	Label.Size = UDim2.new(1, 0, 0, 300)
	Label.Position = UDim2.new(0, 0, 0.5, -150)
	Label.BackgroundTransparency = 1
	Label.Text = customText or "8.8.8.8"
	Label.RichText = true
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.Font = Enum.Font.GothamBlack -- Police très épaisse
	Label.TextSize = 0 -- Départ petit
	Label.TextTransparency = 1
	
	-- Contour du texte pour lisibilité maximale
	local Stroke = Instance.new("UIStroke", Label)
	Stroke.Color = Theme.Accent
	Stroke.Thickness = 3
	Stroke.Transparency = 1

	-- Animation Séquentielle
	-- 1. Fond s'assombrit
	TS:Create(Blur, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
	
	-- 2. Texte EXPLOSE à l'écran (Taille 160 !)
	TS:Create(Label, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = 160, TextTransparency = 0}):Play()
	TS:Create(Stroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
	
	task.delay(3, function()
		-- Disparition propre
		TS:Create(Label, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextSize = 250, TextTransparency = 1}):Play()
		TS:Create(Blur, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		TS:Create(Stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
		Debris:AddItem(Screen, 1)
	end)
end

function Library:CreateWindow(title)
	if CoreGui:FindFirstChild("8888_UI") then CoreGui["8888_UI"]:Destroy() end
	local UI = Instance.new("ScreenGui", CoreGui); UI.Name = "8888_UI"
	
	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"
	Main.Size = UDim2.new(0, 680, 0, 480)
	Main.Position = UDim2.new(0.5, -340, 0.5, 50) -- Un peu plus bas pour l'anim
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.GroupTransparency = 1
	Main.ClipsDescendants = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	
	-- Bordure fine "Fluent"
	local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Theme.Outline; Stroke.Thickness = 1
	
	-- Animation d'entrée du Menu (Fade + Slide Up)
	TS:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -340, 0.5, -240),
		GroupTransparency = 0
	}):Play()

	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
	
	-- Titre Menu
	local AppTitle = Instance.new("TextLabel", Sidebar)
	AppTitle.Size = UDim2.new(1, -20, 0, 50); AppTitle.Position = UDim2.new(0, 20, 0, 10)
	AppTitle.Text = title; AppTitle.TextColor3 = Theme.Text; AppTitle.Font = "GothamBold"; AppTitle.TextSize = 18; AppTitle.TextXAlignment = "Left"; AppTitle.BackgroundTransparency = 1

	local TabContainer = Instance.new("ScrollingFrame", Sidebar)
	TabContainer.Size = UDim2.new(1, -10, 1, -70); TabContainer.Position = UDim2.new(0, 5, 0, 60); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0
	Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

	local PageContainer = Instance.new("Frame", Main)
	PageContainer.Name = "Content"
	PageContainer.Size = UDim2.new(1, -210, 1, -20); PageContainer.Position = UDim2.new(0, 210, 0, 10); PageContainer.BackgroundTransparency = 1

	local WindowActions = {}
	local first = true

	function WindowActions:AddPage(name)
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

		local TabBtn = Instance.new("TextButton", TabContainer)
		TabBtn.Size = UDim2.new(1, 0, 0, 36); TabBtn.BackgroundTransparency = 1
		TabBtn.Text = "       " .. name; TabBtn.TextColor3 = Theme.TextDark; TabBtn.Font = "GothamMedium"; TabBtn.TextSize = 14; TabBtn.TextXAlignment = "Left"; TabBtn.ClipsDescendants = true
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
		
		local ActiveBar = Instance.new("Frame", TabBtn)
		ActiveBar.Size = UDim2.new(0, 4, 0, 16); ActiveBar.Position = UDim2.new(0, 0, 0.5, -8); ActiveBar.BackgroundColor3 = Theme.Accent; ActiveBar.Transparency = 1; Instance.new("UICorner", ActiveBar)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			for _, b in pairs(TabContainer:GetChildren()) do 
				if b:IsA("TextButton") then 
					TS:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}):Play()
					TS:Create(b.Frame, TweenInfo.new(0.2), {Transparency = 1, Size = UDim2.new(0, 4, 0, 0)}):Play()
				end 
			end
			Page.Visible = true
			TS:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.92, TextColor3 = Theme.Text}):Play()
			TS:Create(ActiveBar, TweenInfo.new(0.2), {Transparency = 0, Size = UDim2.new(0, 4, 0, 16)}):Play()
			CreateRipple(TabBtn)
		end)

		if first then 
			Page.Visible = true; TabBtn.BackgroundTransparency = 0.92; TabBtn.TextColor3 = Theme.Text; ActiveBar.Transparency = 0; first = false 
		end

		local PageActions = {}
		function PageActions:AddSection(sTitle)
			local Sec = Instance.new("Frame", Page)
			Sec.Size = UDim2.new(1, -5, 0, 35); Sec.BackgroundColor3 = Theme.Section; Sec.AutomaticSize = "Y"
			Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", Sec).Color = Theme.Outline
			local L = Instance.new("UIListLayout", Sec); L.Padding = UDim.new(0, 6); L.HorizontalAlignment = "Center"
			Instance.new("UIPadding", Sec).PaddingTop = UDim.new(0, 12); Instance.new("UIPadding", Sec).PaddingBottom = UDim.new(0, 12)
			
			local Title = Instance.new("TextLabel", Sec)
			Title.Size = UDim2.new(1, -20, 0, 20); Title.Text = sTitle; Title.TextColor3 = Theme.TextDark; Title.Font = "GothamBold"; Title.TextSize = 12; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"
			
			local SecActions = {}
			function SecActions:AddButton(t, c)
				local B = Instance.new("TextButton", Sec); B.Size = UDim2.new(1, -20, 0, 32); B.BackgroundColor3 = Theme.Main; B.Text = "  " .. t; B.TextColor3 = Theme.Text; B.Font = "Gotham"; B.TextSize = 13; B.TextXAlignment = "Left"; B.AutoButtonColor = false; B.ClipsDescendants = true
				Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4); Instance.new("UIStroke", B).Color = Theme.Outline
				B.MouseButton1Click:Connect(function() CreateRipple(B); c() end)
			end
			
			function SecActions:AddSlider(t, min, max, def, c)
				local S = Instance.new("Frame", Sec); S.Size = UDim2.new(1, -20, 0, 50); S.BackgroundTransparency = 1
				local L = Instance.new("TextLabel", S); L.Size = UDim2.new(1, 0, 0, 20); L.Text = t; L.TextColor3 = Theme.Text; L.BackgroundTransparency = 1; L.TextXAlignment = "Left"; L.Font = "Gotham"; L.TextSize = 13
				local V = Instance.new("TextLabel", S); V.Size = UDim2.new(1, 0, 0, 20); V.Text = tostring(def); V.TextColor3 = Theme.TextDark; V.BackgroundTransparency = 1; V.TextXAlignment = "Right"; V.Font = "Gotham"; V.TextSize = 13
				
				local B = Instance.new("Frame", S); B.Size = UDim2.new(1, 0, 0, 4); B.Position = UDim2.new(0, 0, 0, 30); B.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", B)
				local F = Instance.new("Frame", B); F.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); F.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", F)
				
				local function U()
					local p = math.clamp((UIS:GetMouseLocation().X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
					TS:Create(F, TweenInfo.new(0.05), {Size = UDim2.new(p, 0, 1, 0)}):Play()
					local val = math.floor(min + (max-min)*p); V.Text = tostring(val); c(val)
				end
				local act = false
				B.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = true U() end end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = false end end)
				UIS.InputChanged:Connect(function(i) if act and i.UserInputType == Enum.UserInputType.MouseMovement then U() end end)
			end

			function SecActions:AddToggle(t, def, c)
				local T = Instance.new("TextButton", Sec); T.Size = UDim2.new(1, -20, 0, 32); T.BackgroundColor3 = Theme.Main; T.Text = "  " .. t; T.TextColor3 = Theme.Text; T.Font = "Gotham"; T.TextSize = 13; T.TextXAlignment = "Left"; T.AutoButtonColor = false; T.ClipsDescendants = true
				Instance.new("UICorner", T).CornerRadius = UDim.new(0, 4)
				local Ind = Instance.new("Frame", T); Ind.Size = UDim2.new(0, 32, 0, 18); Ind.Position = UDim2.new(1, -40, 0.5, -9); Ind.BackgroundColor3 = def and Theme.Accent or Color3.fromRGB(50, 50, 50); Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)
				local D = Instance.new("Frame", Ind); D.Size = UDim2.new(0, 14, 0, 14); D.Position = def and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); D.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", D).CornerRadius = UDim.new(1, 0)
				local state = def
				T.MouseButton1Click:Connect(function()
					state = not state
					TS:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 50)}):Play()
					TS:Create(D, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
					CreateRipple(T); c(state)
				end)
			end
			return SecActions
		end
		return PageActions
	end
	return WindowActions
end
return Library
