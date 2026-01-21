local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Sidebar = Color3.fromRGB(15, 15, 18),
	Section = Color3.fromRGB(20, 20, 25),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(40, 40, 45),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(140, 140, 140)
}

-- [[ EFFET ONDE VIOLETTE ]] --
local function CreateRipple(obj)
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Circle = Instance.new("ImageLabel", obj)
		Circle.BackgroundTransparency = 1
		Circle.Image = "rbxassetid://266543268"
		Circle.ImageColor3 = Theme.Accent
		Circle.ImageTransparency = 0.2
		Circle.ZIndex = 25
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
	TS:Create(Label, TweenInfo.new(1.2, Enum.EasingStyle.Back), {TextSize = 85, TextTransparency = 0}):Play()
	task.delay(3, function() TS:Create(Label, TweenInfo.new(1), {TextTransparency = 1, TextSize = 100}):Play(); Debris:AddItem(Screen, 1.1) end)
end

function Library:CreateWindow(title)
	if CoreGui:FindFirstChild("8888_Ultimate") then CoreGui["8888_Ultimate"]:Destroy() end
	local UI = Instance.new("ScreenGui", CoreGui); UI.Name = "8888_Ultimate"
	
	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"; Main.Size = UDim2.new(0, 620, 0, 420); Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Theme.Main; Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
	
	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = Theme.Accent; Stroke.Thickness = 1.5; Stroke.Transparency = 0.3

	-- SIDEBAR AVEC EFFET FLOU (TRANSLUCIDE)
	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Name = "Sidebar"; Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BackgroundTransparency = 0.2 -- Effet translucide
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 15)

	local SidebarList = Instance.new("ScrollingFrame", Sidebar)
	SidebarList.Size = UDim2.new(1, 0, 1, -80); SidebarList.Position = UDim2.new(0, 0, 0, 70)
	SidebarList.BackgroundTransparency = 1; SidebarList.ScrollBarThickness = 0
	local SLayout = Instance.new("UIListLayout", SidebarList); SLayout.Padding = UDim.new(0, 8); SLayout.HorizontalAlignment = "Center"

	local Title = Instance.new("TextLabel", Sidebar)
	Title.Size = UDim2.new(1, 0, 0, 60); Title.Text = "8.8.8.8"; Title.TextColor3 = Theme.Accent
	Title.Font = "GothamBold"; Title.TextSize = 22; Title.BackgroundTransparency = 1

	-- CONTENEUR DE PAGES
	local PageContainer = Instance.new("Frame", Main)
	PageContainer.Name = "Pages"; PageContainer.Size = UDim2.new(1, -180, 1, -30); PageContainer.Position = UDim2.new(0, 170, 0, 15)
	PageContainer.BackgroundTransparency = 1

	local WindowActions = {}
	local firstPage = true

	function WindowActions:AddPage(name)
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Name = name .. "_Page"; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1
		Page.Visible = false; Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 15)

		local TabBtn = Instance.new("TextButton", SidebarList)
		TabBtn.Size = UDim2.new(0.85, 0, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,35); TabBtn.BackgroundTransparency = 1
		TabBtn.Text = name; TabBtn.TextColor3 = Theme.TextDark; TabBtn.Font = "GothamMedium"; TabBtn.TextSize = 14
		Instance.new("UICorner", TabBtn)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			for _, b in pairs(SidebarList:GetChildren()) do 
				if b:IsA("TextButton") then 
					TS:Create(b, TweenInfo.new(0.3), {TextColor3 = Theme.TextDark, BackgroundTransparency = 1}):Play() 
				end 
			end
			Page.Visible = true
			TS:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Theme.Accent, BackgroundTransparency = 0.8}):Play()
			CreateRipple(TabBtn)
		end)

		if firstPage then 
			Page.Visible = true; 
			TabBtn.TextColor3 = Theme.Accent; 
			TabBtn.BackgroundTransparency = 0.8;
			firstPage = false 
		end

		local PageActions = {}

		function PageActions:AddSection(sTitle)
			local Sec = Instance.new("Frame", Page)
			Sec.Size = UDim2.new(0.98, 0, 0, 40); Sec.BackgroundColor3 = Theme.Section; Sec.AutomaticSize = "Y"
			Instance.new("UICorner", Sec); Instance.new("UIStroke", Sec).Color = Theme.Outline
			local L = Instance.new("UIListLayout", Sec); L.Padding = UDim.new(0, 10); L.HorizontalAlignment = "Center"
			Instance.new("UIPadding", Sec).PaddingTop = UDim.new(0, 35); Instance.new("UIPadding", Sec).PaddingBottom = UDim.new(0, 15)

			local SLab = Instance.new("TextLabel", Sec)
			SLab.Size = UDim2.new(1, -20, 0, 30); SLab.Position = UDim2.new(0, 15, 0, 0); SLab.Text = sTitle:upper()
			SLab.TextColor3 = Theme.Accent; SLab.Font = "GothamBold"; SLab.TextSize = 12; SLab.BackgroundTransparency = 1; SLab.TextXAlignment = "Left"

			local SecActions = {}
			function SecActions:AddButton(t, c)
				local B = Instance.new("TextButton", Sec); B.Size = UDim2.new(0.92, 0, 0, 38); B.BackgroundColor3 = Theme.Main
				B.Text = "  " .. t; B.TextColor3 = Theme.Text; B.Font = "GothamMedium"; B.TextSize = 13; B.TextXAlignment = "Left"
				B.AutoButtonColor = false; B.ClipsDescendants = true; Instance.new("UICorner", B)
				local BS = Instance.new("UIStroke", B); BS.Color = Theme.Outline
				B.MouseEnter:Connect(function() TS:Create(BS, TweenInfo.new(0.3), {Color = Theme.Accent}):Play() end)
				B.MouseLeave:Connect(function() TS:Create(BS, TweenInfo.new(0.3), {Color = Theme.Outline}):Play() end)
				B.MouseButton1Click:Connect(function() CreateRipple(B) c() end)
			end
			
			function SecActions:AddSlider(t, min, max, def, c)
				local S = Instance.new("Frame", Sec); S.Size = UDim2.new(0.92, 0, 0, 50); S.BackgroundTransparency = 1
				local L = Instance.new("TextLabel", S); L.Size = UDim2.new(1, 0, 0, 20); L.Text = "  "..t.." : "..def; L.TextColor3 = Theme.TextDark
				L.BackgroundTransparency = 1; L.TextXAlignment = "Left"; L.Font = "GothamMedium"; L.TextSize = 13
				local B = Instance.new("Frame", S); B.Size = UDim2.new(1, -10, 0, 6); B.Position = UDim2.new(0, 5, 0, 32); B.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", B)
				local F = Instance.new("Frame", B); F.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); F.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", F)
				local function U()
					local p = math.clamp((UIS:GetMouseLocation().X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
					TS:Create(F, TweenInfo.new(0.1), {Size = UDim2.new(p, 0, 1, 0)}):Play()
					local v = math.floor(min + (max-min)*p); L.Text = "  "..t.." : "..v; c(v)
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
