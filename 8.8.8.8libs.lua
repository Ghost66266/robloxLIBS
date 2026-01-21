local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(8, 8, 11),
	Section = Color3.fromRGB(13, 13, 17),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(35, 35, 45),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(140, 140, 145)
}

-- [[ UTILITAIRES D'ANIMATION ]] --
local function Ripple(obj)
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local Circle = Instance.new("ImageLabel")
	Circle.Name = "Ripple"
	Circle.Parent = obj
	Circle.BackgroundColor3 = Color3.new(1, 1, 1)
	Circle.BackgroundTransparency = 1
	Circle.ZIndex = 10
	Circle.Image = "rbxassetid://266543268"
	Circle.ImageColor3 = Theme.Accent
	Circle.ImageTransparency = 0.4
	
	local RelX = Mouse.X - obj.AbsolutePosition.X
	local RelY = Mouse.Y - obj.AbsolutePosition.Y
	Circle.Position = UDim2.new(0, RelX, 0, RelY)
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)

	TS:Create(Circle, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, obj.AbsoluteSize.X * 2, 0, obj.AbsoluteSize.X * 2),
		ImageTransparency = 1
	}):Play()
	task.delay(0.6, function() Circle:Destroy() end)
end

-- [[ CRÉATION DE LA FENÊTRE ]] --
function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Final_Edition"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 560, 0, 400)
	Main.Position = UDim2.new(0.5, -280, 0.5, -200)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
	
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Color = Theme.Outline
	MainStroke.Thickness = 2

	-- Effet de Respiration Néon sur la bordure
	task.spawn(function()
		while task.wait() do
			TS:Create(MainStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Theme.Accent}):Play()
			task.wait(1.5)
			TS:Create(MainStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Theme.Outline}):Play()
			task.wait(1.5)
		end
	end)

	-- [[ EFFET 3D TILT (Unique) ]] --
	RunService.RenderStepped:Connect(function()
		local Mouse = UIS:GetMouseLocation()
		local Center = Vector2.new(Main.AbsolutePosition.X + (Main.AbsoluteSize.X/2), Main.AbsolutePosition.Y + (Main.AbsoluteSize.Y/2))
		local Distance = (Mouse - Center)
		
		TS:Create(Main, TweenInfo.new(0.2), {
			Rotation = math.clamp(Distance.X / 100, -2, 2)
		}):Play()
	end)

	-- Header Holographique
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = Theme.Section
	Header.BorderSizePixel = 0
	
	local Scanline = Instance.new("Frame", Header)
	Scanline.Size = UDim2.new(1, 0, 0, 2)
	Scanline.BackgroundColor3 = Theme.Accent
	Scanline.BackgroundTransparency = 0.7
	TS:Create(Scanline, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(0,0,1,0)}):Play()

	local Title = Instance.new("TextLabel", Header)
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Text = "  " .. (title or "8.8.8.8 UI")
	Title.RichText = true
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.BackgroundTransparency = 1

	-- Scrolling Area
	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -70)
	Scroll.Position = UDim2.new(0, 10, 0, 60)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.ScrollBarThickness = 0
	
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 15)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Drag
	local dragging, dragStart, startPos
	Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = Main.Position end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end end)

	local WinActions = {}

	function WinActions:AddSection(sTitle)
		local Section = Instance.new("Frame", Scroll)
		Section.Size = UDim2.new(0.96, 0, 0, 0)
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.BackgroundColor3 = Theme.Section
		Section.BorderSizePixel = 0
		Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
		local sStroke = Instance.new("UIStroke", Section)
		sStroke.Color = Theme.Outline

		local st = Instance.new("TextLabel", Section)
		st.Size = UDim2.new(1, 0, 0, 28)
		st.Position = UDim2.new(0, 12, 0, -12)
		st.Text = sTitle:upper()
		st.TextColor3 = Theme.Accent
		st.Font = Enum.Font.GothamBold
		st.TextSize = 11
		st.BackgroundTransparency = 1
		st.TextXAlignment = Enum.TextXAlignment.Left

		local Container = Instance.new("Frame", Section)
		Container.Size = UDim2.new(1, 0, 1, 0)
		Container.BackgroundTransparency = 1
		Instance.new("UIListLayout", Container).Padding = UDim.new(0, 8)
		Instance.new("UIPadding", Container).PaddingTop = UDim.new(0, 18)
		Instance.new("UIPadding", Container).PaddingBottom = UDim.new(0, 10)

		local SecActions = {}

		function SecActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.92, 0, 0, 38)
			Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			Btn.Text = text
			Btn.TextColor3 = Theme.TextDark
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 14
			Btn.ClipsDescendants = true
			Btn.AutoButtonColor = false
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			local bStroke = Instance.new("UIStroke", Btn)
			bStroke.Color = Theme.Outline

			-- Effet Magnétique & Glow
			Btn.MouseEnter:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 40), TextColor3 = Theme.Accent}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Accent, Thickness = 2}):Play()
				Btn:TweenSize(UDim2.new(0.96, 0, 0, 42), "Out", "Back", 0.3, true)
			end)
			Btn.MouseLeave:Connect(function()
				TS:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), TextColor3 = Theme.TextDark}):Play()
				TS:Create(bStroke, TweenInfo.new(0.3), {Color = Theme.Outline, Thickness = 1}):Play()
				Btn:TweenSize(UDim2.new(0.92, 0, 0, 38), "Out", "Quart", 0.3, true)
			end)

			Btn.MouseButton1Click:Connect(function()
				Ripple(Btn)
				callback()
			end)
		end
		return SecActions
	end
	return WinActions
end

return Library
