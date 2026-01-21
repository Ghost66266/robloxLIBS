local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(12, 12, 14),
	Sidebar = Color3.fromRGB(18, 18, 22),
	Section = Color3.fromRGB(22, 22, 26),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(160, 160, 160)
}

local function CreateRipple(obj)
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Circle = Instance.new("ImageLabel", obj)
		Circle.BackgroundTransparency = 1
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Theme.Accent
		Circle.ImageTransparency = 0.3
		Circle.ZIndex = 20
		Circle.Position = UDim2.new(0, Mouse.X - obj.AbsolutePosition.X, 0, Mouse.Y - obj.AbsolutePosition.Y)
		Circle.AnchorPoint = Vector2.new(0.5, 0.5)
		Circle.Size = UDim2.new(0, 0, 0, 0)
		TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5), ImageTransparency = 1}):Play()
		Debris:AddItem(Circle, 0.6)
	end)
end

function Library:CreateWelcomeScreen(customText)
	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.IgnoreGuiInset = true
	local Label = Instance.new("TextLabel", Screen)
	Label.Size = UDim2.new(1, 0, 0, 200); Label.Position = UDim2.new(0, 0, 0.5, -100); Label.BackgroundTransparency = 1
	Label.Text = customText or "8.8.8.8 <font color='#AA00FF'>VIRTUAL</font> ENGINE"; Label.RichText = true
	Label.TextColor3 = Color3.new(1, 1, 1); Label.Font = Enum.Font.GothamBold; Label.TextSize = 1; Label.TextTransparency = 1
	TS:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 80, TextTransparency = 0}):Play()
	task.delay(3, function() TS:Create(Label, TweenInfo.new(1), {TextTransparency = 1}):Play(); Debris:AddItem(Screen, 1.1) end)
end

function Library:CreateWindow(title)
	if CoreGui:FindFirstChild("8888_Ultimate") then CoreGui["8888_Ultimate"]:Destroy() end
	local UI = Instance.new("ScreenGui", CoreGui); UI.Name = "8888_Ultimate"
	
	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"; Main.Size = UDim2.new(0, 600, 0, 400); Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	Main.BackgroundColor3 = Theme.Main; Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	Instance.new("UIStroke", Main).Color = Theme.Accent

	-- BARRE DE GAUCHE (SIDEBAR)
	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 150, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

	local SidebarList = Instance.new("ScrollingFrame", Sidebar)
	SidebarList.Size = UDim2.new(1, 0, 1, -60); SidebarList.Position = UDim2.new(0, 0, 0, 50)
	SidebarList.BackgroundTransparency = 1; SidebarList.ScrollBarThickness = 0
	local SLayout = Instance.new("UIListLayout", SidebarList); SLayout.Padding = UDim.new(0, 5); SLayout.HorizontalAlignment = "Center"

	local Title = Instance.new("TextLabel", Sidebar)
	Title.Size = UDim2.new(1, 0, 0, 50); Title.Text = "8.8.8.8 UI"; Title.TextColor3 = Theme.Accent
	Title.Font = "GothamBold"; Title.TextSize = 18; Title.BackgroundTransparency = 1

	-- CONTENEUR DE PAGES (DROITE)
	local PageContainer = Instance.new("Frame", Main)
	PageContainer.Name = "Pages"; PageContainer.Size = UDim2.new(1, -160, 1, -20); PageContainer.Position = UDim2.new(0, 155, 0, 10)
	PageContainer.BackgroundTransparency = 1

	local WindowActions = {}
	local firstPage = true

	function WindowActions:AddPage(name)
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Name = name .. "_Page"; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1
		Page.Visible = false; Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

		local TabBtn = Instance.new("TextButton", SidebarList)
		TabBtn.Size = UDim2.new(0.9, 0, 0, 35); TabBtn.BackgroundColor3 = Theme.Main
		TabBtn.Text = name; TabBtn.TextColor3 = Theme.TextDark; TabBtn.Font = "GothamMedium"; TabBtn.TextSize = 14
		Instance.new("UICorner", TabBtn)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			for _, b in pairs(SidebarList:GetChildren()) do if b:IsA("TextButton") then TS:Create(b, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark}):Play() end end
			Page.Visible = true
			TS:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent}):Play()
			CreateRipple(TabBtn)
		end)

		if firstPage then Page.Visible = true; TabBtn.TextColor3 = Theme.Accent; firstPage = false end

		local PageActions = {}

		function PageActions:AddSection(sTitle)
			local Sec = Instance.new("Frame", Page)
			Sec.Size = UDim2.new(0.95, 0, 0, 35); Sec.BackgroundColor3 = Theme.Section; Sec.AutomaticSize = "Y"
			Instance.new("UICorner", Sec)
			local L = Instance.new("UIListLayout", Sec); L.Padding = UDim.new(0, 8); L.HorizontalAlignment = "Center"
			Instance.new("UIPadding", Sec).PaddingTop = UDim.new(0, 30); Instance.new("UIPadding", Sec).PaddingBottom = UDim.new(0, 10)

			local SLab = Instance.new("TextLabel", Sec)
			SLab.Size = UDim2.new(1, -20, 0, 25); SLab.Position = UDim2.new(0, 10, 0, 0); SLab.Text = sTitle
			SLab.TextColor3 = Theme.Accent; SLab.Font = "GothamBold"; SLab.TextSize = 13; SLab.BackgroundTransparency = 1; SLab.TextXAlignment = "Left"

			local SecActions = {}
			function SecActions:AddButton(t, c)
				local B = Instance.new("TextButton", Sec); B.Size = UDim2.new(0.92, 0, 0, 35); B.BackgroundColor3 = Theme.Main
				B.Text = "  " .. t; B.TextColor3 = Theme.Text; B.Font = "GothamMedium"; B.TextSize = 13; B.TextXAlignment = "Left"
				B.AutoButtonColor = false; B.ClipsDescendants = true; Instance.new("UICorner", B)
				B.MouseButton1Click:Connect(function() CreateRipple(B) c() end)
			end
			
			function SecActions:AddSlider(t, min, max, def, c)
				local S = Instance.new("Frame", Sec); S.Size = UDim2.new(0.92, 0, 0, 45); S.BackgroundTransparency = 1
				local L = Instance.new("TextLabel", S); L.Size = UDim2.new(1, 0, 0, 20); L.Text = "  "..t.." : "..def; L.TextColor3 = Theme.Text
				L.BackgroundTransparency = 1; L.TextXAlignment = "Left"; L.Font = "GothamMedium"; L.TextSize = 12
				local B = Instance.new("Frame", S); B.Size = UDim2.new(1, -10, 0, 5); B.Position = UDim2.new(0, 5, 0, 25); B.BackgroundColor3 = Theme.Outline
				local F = Instance.new("Frame", B); F.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); F.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", F)
				local function U()
					local p = math.clamp((UIS:GetMouseLocation().X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
					F.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max-min)*p)
					L.Text = "  "..t.." : "..v; c(v)
				end
				local act = false
				B.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = true U() end end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = false end end)
				UIS.InputChanged:Connect(function(i) if act and i.UserInputType == Enum.UserInputType.MouseMovement then U() end end)
			end
			return SecActions
		end
		return PageActions
	end
	return WindowActions
end
return Library
