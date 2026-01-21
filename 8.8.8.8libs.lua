local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(15, 15, 15),
	Sidebar = Color3.fromRGB(20, 20, 20),
	Section = Color3.fromRGB(25, 25, 25),
	Accent = Color3.fromRGB(170, 0, 255), -- Ton Violet
	Outline = Color3.fromRGB(40, 40, 40),
	Text = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(150, 150, 150)
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
		TS:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, obj.AbsoluteSize.X * 2, 0, obj.AbsoluteSize.X * 2), ImageTransparency = 1}):Play()
		Debris:AddItem(Circle, 0.6)
	end)
end

function Library:CreateWelcomeScreen(customText)
	local Screen = Instance.new("ScreenGui", CoreGui)
	local Label = Instance.new("TextLabel", Screen)
	Label.Size = UDim2.new(1, 0, 1, 0); Label.BackgroundTransparency = 1
	Label.Text = customText; Label.RichText = true; Label.TextColor3 = Color3.new(1,1,1)
	Label.Font = "GothamBold"; Label.TextSize = 0; Label.TextTransparency = 1
	TS:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 60, TextTransparency = 0}):Play()
	task.delay(2.5, function() TS:Create(Label, TweenInfo.new(1), {TextTransparency = 1}):Play(); Debris:AddItem(Screen, 1.1) end)
end

function Library:CreateWindow(title)
	if CoreGui:FindFirstChild("8888_Fluent") then CoreGui["8888_Fluent"]:Destroy() end
	local UI = Instance.new("ScreenGui", CoreGui); UI.Name = "8888_Fluent"
	
	local Main = Instance.new("Frame", UI)
	Main.Name = "MainFrame"; Main.Size = UDim2.new(0, 650, 0, 450); Main.Position = UDim2.new(0.5, -325, 0.5, -225)
	Main.BackgroundColor3 = Theme.Main; Main.BorderSizePixel = 0
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Theme.Outline; Stroke.Thickness = 1

	-- SIDEBAR (STYLE FLUENT)
	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Size = UDim2.new(0, 180, 1, 0); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
	
	local SidebarTitle = Instance.new("TextLabel", Sidebar)
	SidebarTitle.Size = UDim2.new(1, 0, 0, 50); SidebarTitle.Position = UDim2.new(0, 15, 0, 5)
	SidebarTitle.Text = title; SidebarTitle.TextColor3 = Theme.Text; SidebarTitle.Font = "GothamBold"; SidebarTitle.TextSize = 16; SidebarTitle.TextXAlignment = "Left"; SidebarTitle.BackgroundTransparency = 1

	local TabContainer = Instance.new("ScrollingFrame", Sidebar)
	TabContainer.Size = UDim2.new(1, -10, 1, -60); TabContainer.Position = UDim2.new(0, 5, 0, 55); TabContainer.BackgroundTransparency = 1; TabContainer.ScrollBarThickness = 0
	Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 4)

	local PageContainer = Instance.new("Frame", Main)
	PageContainer.Size = UDim2.new(1, -195, 1, -20); PageContainer.Position = UDim2.new(0, 190, 0, 10); PageContainer.BackgroundTransparency = 1

	local WindowActions = {}
	local first = true

	function WindowActions:AddPage(name)
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

		local TabBtn = Instance.new("TextButton", TabContainer)
		TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.BackgroundColor3 = Theme.Accent; TabBtn.BackgroundTransparency = 1
		TabBtn.Text = "      " .. name; TabBtn.TextColor3 = Theme.TextDark; TabBtn.Font = "GothamMedium"; TabBtn.TextSize = 13; TabBtn.TextXAlignment = "Left"
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
		
		local SelectionBar = Instance.new("Frame", TabBtn)
		SelectionBar.Size = UDim2.new(0, 3, 0, 18); SelectionBar.Position = UDim2.new(0, 8, 0.5, -9); SelectionBar.BackgroundColor3 = Theme.Accent; SelectionBar.Transparency = 1; Instance.new("UICorner", SelectionBar)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
			for _, b in pairs(TabContainer:GetChildren()) do 
				if b:IsA("TextButton") then 
					TS:Create(b, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}):Play()
					TS:Create(b.Frame, TweenInfo.new(0.2), {Transparency = 1}):Play()
				end 
			end
			Page.Visible = true
			TS:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9, TextColor3 = Theme.Text}):Play()
			TS:Create(SelectionBar, TweenInfo.new(0.2), {Transparency = 0}):Play()
			CreateRipple(TabBtn)
		end)

		if first then Page.Visible = true; TabBtn.BackgroundTransparency = 0.9; TabBtn.TextColor3 = Theme.Text; SelectionBar.Transparency = 0; first = false end

		local PageActions = {}
		function PageActions:AddSection(sTitle)
			local Sec = Instance.new("Frame", Page)
			Sec.Size = UDim2.new(1, -10, 0, 35); Sec.BackgroundColor3 = Theme.Section; Sec.AutomaticSize = "Y"
			Instance.new("UICorner", Sec).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Sec).Color = Theme.Outline
			local L = Instance.new("UIListLayout", Sec); L.Padding = UDim.new(0, 5); L.HorizontalAlignment = "Center"
			Instance.new("UIPadding", Sec).PaddingTop = UDim.new(0, 10); Instance.new("UIPadding", Sec).PaddingBottom = UDim.new(0, 10)

			local SecActions = {}
			function SecActions:AddButton(t, c)
				local B = Instance.new("TextButton", Sec); B.Size = UDim2.new(0.95, 0, 0, 32); B.BackgroundColor3 = Theme.Main
				B.Text = "  " .. t; B.TextColor3 = Theme.Text; B.Font = "Gotham"; B.TextSize = 13; B.TextXAlignment = "Left"; B.AutoButtonColor = false; B.ClipsDescendants = true
				Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
				local S = Instance.new("UIStroke", B); S.Color = Theme.Outline
				B.MouseButton1Click:Connect(function() CreateRipple(B); c() end)
			end

			function SecActions:AddSlider(t, min, max, def, c)
				local S = Instance.new("Frame", Sec); S.Size = UDim2.new(0.95, 0, 0, 45); S.BackgroundTransparency = 1
				local L = Instance.new("TextLabel", S); L.Size = UDim2.new(1, 0, 0, 20); L.Text = "  "..t.." : "..def; L.TextColor3 = Theme.Text; L.BackgroundTransparency = 1; L.TextXAlignment = "Left"; L.Font = "Gotham"; L.TextSize = 12
				local B = Instance.new("Frame", S); B.Size = UDim2.new(1, -10, 0, 4); B.Position = UDim2.new(0, 5, 0, 30); B.BackgroundColor3 = Theme.Outline; Instance.new("UICorner", B)
				local F = Instance.new("Frame", B); F.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); F.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", F)
				local function U()
					local p = math.clamp((UIS:GetMouseLocation().X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
					F.Size = UDim2.new(p, 0, 1, 0); local v = math.floor(min + (max-min)*p); L.Text = "  "..t.." : "..v; c(v)
				end
				local act = false
				B.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = true U() end end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then act = false end end)
				UIS.InputChanged:Connect(function(i) if act and i.UserInputType == Enum.UserInputType.MouseMovement then U() end end)
			end

			function SecActions:AddToggle(t, def, c)
				local T = Instance.new("TextButton", Sec); T.Size = UDim2.new(0.95, 0, 0, 32); T.BackgroundColor3 = Theme.Main; T.Text = "  " .. t; T.TextColor3 = Theme.Text; T.Font = "Gotham"; T.TextSize = 13; T.TextXAlignment = "Left"; T.AutoButtonColor = false; T.ClipsDescendants = true
				Instance.new("UICorner", T).CornerRadius = UDim.new(0, 4)
				local Ind = Instance.new("Frame", T); Ind.Size = UDim2.new(0, 30, 0, 16); Ind.Position = UDim2.new(1, -40, 0.5, -8); Ind.BackgroundColor3 = def and Theme.Accent or Color3.fromRGB(60, 60, 60); Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)
				local D = Instance.new("Frame", Ind); D.Size = UDim2.new(0, 12, 0, 12); D.Position = def and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6); D.BackgroundColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", D).CornerRadius = UDim.new(1, 0)
				local state = def
				T.MouseButton1Click:Connect(function()
					state = not state
					TS:Create(Ind, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 60)}):Play()
					TS:Create(D, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
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
