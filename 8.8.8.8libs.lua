local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

local Theme = {
	Main = Color3.fromRGB(10, 10, 12),
	Section = Color3.fromRGB(16, 16, 20),
	Accent = Color3.fromRGB(170, 0, 255),
	Outline = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255)
}

-- [[ FONCTION ONDE DE CHOC NÉON ]] --
local function Ripple(obj)
	spawn(function()
		local Mouse = game.Players.LocalPlayer:GetMouse()
		local RippleCircle = Instance.new("ImageLabel") -- On utilise une image pour l'effet "Glow"

		RippleCircle.Name = "Ripple"
		RippleCircle.Parent = obj
		RippleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		RippleCircle.BackgroundTransparency = 1
		RippleCircle.ZIndex = 10
		RippleCircle.Image = "rbxassetid://266543268" -- Texture de cercle dégradé
		RippleCircle.ImageColor3 = Theme.Accent
		RippleCircle.ImageTransparency = 0.6
		
		-- Calcul de la position locale
		local RelativeX = Mouse.X - obj.AbsolutePosition.X
		local RelativeY = Mouse.Y - obj.AbsolutePosition.Y
		RippleCircle.Position = UDim2.new(0, RelativeX, 0, RelativeY)
		RippleCircle.AnchorPoint = Vector2.new(0.5, 0.5)

		-- Animation de "Choc"
		local ExpandInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local Expand = TS:Create(RippleCircle, ExpandInfo, {
			Size = UDim2.new(0, obj.AbsoluteSize.X * 2.5, 0, obj.AbsoluteSize.X * 2.5),
			ImageTransparency = 1
		})
		
		Expand:Play()
		Expand.Completed:Wait()
		RippleCircle:Destroy()
	end)
end

function Library:CreateWindow(title)
	local UI = Instance.new("ScreenGui", CoreGui)
	UI.Name = "8888_Neon_Lib"

	local Main = Instance.new("Frame", UI)
	Main.Size = UDim2.new(0, 500, 0, 350)
	Main.Position = UDim2.new(0.5, -250, 0.5, -175)
	Main.BackgroundColor3 = Theme.Main
	Main.ClipsDescendants = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", Main).Color = Theme.Outline

    -- Drag System
    local d, ds, sp
    Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = Main.Position end end)
    UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

	local Scroll = Instance.new("ScrollingFrame", Main)
	Scroll.Size = UDim2.new(1, -20, 1, -20)
	Scroll.Position = UDim2.new(0, 10, 0, 10)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local Layout = Instance.new("UIListLayout", Scroll)
	Layout.Padding = UDim.new(0, 10)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local Actions = {}

	function Actions:AddSection(sTitle)
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

		local SecActions = {}

		function SecActions:AddButton(text, callback)
			local Btn = Instance.new("TextButton", Container)
			Btn.Size = UDim2.new(0.9, 0, 0, 35)
			Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			Btn.Text = text
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.AutoButtonColor = false
			Btn.ClipsDescendants = true -- Requis pour que l'onde ne sorte pas du bouton
			Instance.new("UICorner", Btn)
			
			Btn.MouseButton1Click:Connect(function()
				Ripple(Btn) -- Lancement de l'effet
				callback()
			end)
		end
		
		return SecActions
	end
	return Actions
end

return Library
