-- [[ 8.8.8.8 NEVER-WIN UI LIBRARY ]] --
-- [[ VERSION: V11 FINAL EXTENDED | AUTHOR: GHOST66266 ]] --

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Library = {}

-- [ CONFIGURATION DU THÈME ] --
local Theme = {
	Main        = Color3.fromRGB(20, 20, 20),       -- Fond Principal
	Sidebar     = Color3.fromRGB(15, 15, 15),       -- Barre Latérale
	Section     = Color3.fromRGB(25, 25, 25),       -- Fond des Sections
	Accent      = Color3.fromRGB(170, 0, 255),      -- VIOLET FLUO
	Text        = Color3.fromRGB(255, 255, 255),    -- Texte Blanc
	TextDark    = Color3.fromRGB(150, 150, 150),    -- Texte Gris
	Outline     = Color3.fromRGB(45, 45, 45),       -- Contours
	ToggleOff   = Color3.fromRGB(35, 35, 35),       -- Toggle éteint
	Hover       = Color3.fromRGB(35, 35, 40)        -- Survol souris
}

-- [ FONCTIONS UTILITAIRES ] --

-- Fonction pour créer l'onde de choc (Ripple Effect)
local function CreateRipple(obj)
	-- Sécurité : On force le clipping pour ne pas dépasser
	if not obj then return end
	obj.ClipsDescendants = true
	
	task.spawn(function()
		local Mouse = Players.LocalPlayer:GetMouse()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "RippleEffect"
		Ripple.Parent = obj
		Ripple.BackgroundTransparency = 1
		Ripple.Image = "rbxassetid://266543268"
		Ripple.ImageColor3 = Theme.Accent
		Ripple.ImageTransparency = 0.6
		Ripple.ZIndex = 15
		
		-- Calcul de la position relative à l'objet
		local RelativeX = Mouse.X - obj.AbsolutePosition.X
		local RelativeY = Mouse.Y - obj.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, RelativeX, 0, RelativeY)
		Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		Ripple.Size = UDim2.new(0, 0, 0, 0)
		
		-- Animation d'agrandissement
		local Tween = TS:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5, 0, math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 3.5),
			ImageTransparency = 1
		})
		
		Tween:Play()
		Tween.Completed:Wait()
		Ripple:Destroy()
	end)
end

-- Fonction pour animer les objets UI (Hover, Click)
local function TweenObj(obj, properties, time)
	TS:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

-- [ SYSTÈME DE BIENVENUE CINÉMATIQUE ] --
function Library:Welcome(TitleText, SubText)
	-- Nettoyage des anciens GUI s'ils existent
	for _, v in pairs(CoreGui:GetChildren()) do
		if v.Name == "8888_Intro" then v:Destroy() end
	end

	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.Name = "8888_Intro"
	Screen.IgnoreGuiInset = true
	Screen.DisplayOrder = 10000

	-- Effet de flou global
	local Blur = Instance.new("BlurEffect", Lighting)
	Blur.Size = 0
	
	-- Fond sombre
	local BackFrame = Instance.new("Frame", Screen)
	BackFrame.Size = UDim2.new(1, 0, 1, 0)
	BackFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	BackFrame.BackgroundTransparency = 1
	BackFrame.ZIndex = 1

	-- Texte Principal (Titre)
	local MainLabel = Instance.new("TextLabel", Screen)
	MainLabel.Size = UDim2.new(1, 0, 0, 150)
	MainLabel.Position = UDim2.new(0, 0, 0.4, 0)
	MainLabel.BackgroundTransparency = 1
	MainLabel.Text = string.upper(TitleText or "LIBRARY")
	MainLabel.TextColor3 = Theme.Accent
	MainLabel.Font = Enum.Font.GothamBlack -- Police très grasse
	MainLabel.TextSize = 0 -- Commence à 0 pour l'effet pop
	MainLabel.TextTransparency = 1
	MainLabel.ZIndex = 2
	
	-- Sous-titre
	local SubLabel = Instance.new("TextLabel", Screen)
	SubLabel.Size = UDim2.new(1, 0, 0, 50)
	SubLabel.Position = UDim2.new(0, 0, 0.55, 0)
	SubLabel.BackgroundTransparency = 1
	SubLabel.Text = string.upper(SubText or "INITIALIZING...")
	SubLabel.TextColor3 = Theme.Text
	SubLabel.Font = Enum.Font.GothamBold
	SubLabel.TextSize = 20
	SubLabel.TextTransparency = 1
	SubLabel.TextSpacing = 5
	SubLabel.ZIndex = 2

	-- Séquence d'Animation
	task.spawn(function()
		-- 1. Apparition du flou et du fond
		TS:Create(Blur, TweenInfo.new(1), {Size = 24}):Play()
		TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
		task.wait(0.5)

		-- 2. Explosion du Titre
		TS:Create(MainLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			TextSize = 90, 
			TextTransparency = 0
		}):Play()
		
		task.wait(0.3)
		
		-- 3. Glissement du sous-titre
		SubLabel.Position = UDim2.new(0, 0, 0.60, 0) -- Part d'un peu plus bas
		TS:Create(SubLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0.55, 0),
			TextTransparency = 0
		}):Play()

		task.wait(2.5) -- Temps de lecture

		-- 4. Disparition Cinématique
		TS:Create(MainLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {TextSize = 0, TextTransparency = 1}):Play()
		TS:Create(SubLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		task.wait(0.2)
		TS:Create(BackFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		TS:Create(Blur, TweenInfo.new(0.8), {Size = 0}):Play()
		
		task.wait(0.8)
		Screen:Destroy()
		Blur:Destroy()
	end)
end

-- [ FENÊTRE PRINCIPALE (UI MAJEURE) ] --
function Library:CreateWindow(Config)
	-- Sécurité : Nettoie l'ancienne UI
	local OldUI = CoreGui:FindFirstChild(Config.Name or "Library")
	if OldUI then OldUI:Destroy() end

	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = Config.Name or "Library"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 100
	
	-- Cadre Principal (Main)
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 750, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true -- Important pour les coins arrondis
	
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
	
	-- Contour (Outline)
	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Theme.Outline
	MainStroke.Thickness = 1
	
	-- [ BARRE LATÉRALE (SIDEBAR) ] --
	local Sidebar = Instance.new("Frame", MainFrame)
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	
	-- Titre de l'UI
	local AppTitle = Instance.new("TextLabel", Sidebar)
	AppTitle.Name = "Title"
	AppTitle.Size = UDim2.new(1, -20, 0, 60)
	AppTitle.Position = UDim2.new(0, 20, 0, 10)
	AppTitle.BackgroundTransparency = 1
	AppTitle.Text = string.upper(Config.Name or "UI")
	AppTitle.Font = Enum.Font.GothamBlack
	AppTitle.TextSize = 24
	AppTitle.TextColor3 = Theme.Text
	AppTitle.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Conteneur des Onglets
	local TabContainer = Instance.new("ScrollingFrame", Sidebar)
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 1, -80)
	TabContainer.Position = UDim2.new(0, 0, 0, 80)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	
	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 5)
	
	-- [ ZONE DES PAGES (CONTENU) ] --
	local PageContainer = Instance.new("Frame", MainFrame)
	PageContainer.Name = "PageContainer"
	PageContainer.Size = UDim2.new(1, -210, 1, -20)
	PageContainer.Position = UDim2.new(0, 210, 0, 10)
	PageContainer.BackgroundTransparency = 1

	-- [ SYSTÈME DE DRAG (DÉPLACEMENT) ] --
	local dragging, dragInput, dragStart, startPos
	
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	
	Sidebar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			-- Utilisation de Tween pour un déplacement fluide (optionnel)
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Touche Insert pour cacher/afficher
	UIS.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Enum.KeyCode.Insert then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	-- [ LOGIQUE DES ONGLETS ] --
	local WindowActions = {}
	local FirstTab = true

	function WindowActions:AddTab(TabName)
		-- Création du Bouton d'Onglet
		local TabButton = Instance.new("TextButton", TabContainer)
		TabButton.Name = TabName
		TabButton.Size = UDim2.new(1, 0, 0, 45)
		TabButton.BackgroundTransparency = 1
		TabButton.Text = ""
		TabButton.AutoButtonColor = false
		
		-- Indicateur Actif (Barre Violette)
		local ActiveLine = Instance.new("Frame", TabButton)
		ActiveLine.Size = UDim2.new(0, 4, 0.6, 0)
		ActiveLine.Position = UDim2.new(0, 0, 0.2, 0)
		ActiveLine.BackgroundColor3 = Theme.Accent
		ActiveLine.Transparency = 1 -- Caché par défaut
		ActiveLine.BorderSizePixel = 0
		
		-- Texte de l'onglet
		local TabLabel = Instance.new("TextLabel", TabButton)
		TabLabel.Size = UDim2.new(1, -30, 1, 0)
		TabLabel.Position = UDim2.new(0, 30, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text = TabName
		TabLabel.Font = Enum.Font.GothamBold
		TabLabel.TextSize = 14
		TabLabel.TextColor3 = Theme.TextDark
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Création de la Page associée
		local Page = Instance.new("ScrollingFrame", PageContainer)
		Page.Name = TabName .. "_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 0
		Page.Visible = false
		
		-- Layout en Grille (2 Colonnes comme NeverWin)
		local PageGrid = Instance.new("UIGridLayout", Page)
		PageGrid.SortOrder = Enum.SortOrder.LayoutOrder
		PageGrid.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
		PageGrid.CellSize = UDim2.new(0.48, 0, 0, 0) -- Hauteur sera auto gérée par script
		
		-- Logique de sélection d'onglet
		TabButton.MouseButton1Click:Connect(function()
			-- Désactiver tous les autres onglets
			for _, btn in pairs(TabContainer:GetChildren()) do
				if btn:IsA("TextButton") then
					TweenObj(btn.TextLabel, {TextColor3 = Theme.TextDark})
					TweenObj(btn.Frame, {Transparency = 1})
				end
			end
			for _, pg in pairs(PageContainer:GetChildren()) do
				pg.Visible = false
			end
			
			-- Activer celui-ci
			Page.Visible = true
			TweenObj(TabLabel, {TextColor3 = Theme.Text})
			TweenObj(ActiveLine, {Transparency = 0})
			
			-- Son au clic (Optionnel)
			-- local Sound = Instance.new("Sound", workspace); Sound.SoundId = "rbxassetid://6895079853"; Sound:Play(); Debris:AddItem(Sound, 1)
		end)
		
		-- Sélectionner le premier onglet par défaut
		if FirstTab then
			Page.Visible = true
			TabLabel.TextColor3 = Theme.Text
			ActiveLine.Transparency = 0
			FirstTab = false
		end

		-- [ LOGIQUE DES SECTIONS ] --
		local TabActions = {}

		function TabActions:AddSection(SectionName)
			local Section = Instance.new("Frame", Page)
			Section.Name = SectionName
			Section.BackgroundColor3 = Theme.Section
			-- La hauteur initiale est 0, elle grandira avec le contenu
			Section.Size = UDim2.new(0.48, 0, 0, 100) 
			
			Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 8)
			
			-- En-tête de la section
			local Header = Instance.new("TextLabel", Section)
			Header.Size = UDim2.new(1, -20, 0, 40)
			Header.Position = UDim2.new(0, 15, 0, 0)
			Header.BackgroundTransparency = 1
			Header.Text = SectionName
			Header.Font = Enum.Font.GothamBold
			Header.TextSize = 13
			Header.TextColor3 = Theme.Text
			Header.TextXAlignment = Enum.TextXAlignment.Left
			
			-- Ligne de séparation
			local Div = Instance.new("Frame", Section)
			Div.Size = UDim2.new(1, 0, 0, 1)
			Div.Position = UDim2.new(0, 0, 0, 40)
			Div.BackgroundColor3 = Theme.Outline
			Div.BorderSizePixel = 0
			
			-- Conteneur d'éléments
			local ItemContainer = Instance.new("Frame", Section)
			ItemContainer.Name = "Items"
			ItemContainer.Size = UDim2.new(1, -20, 1, -50)
			ItemContainer.Position = UDim2.new(0, 10, 0, 50)
			ItemContainer.BackgroundTransparency = 1
			
			local ItemList = Instance.new("UIListLayout", ItemContainer)
			ItemList.SortOrder = Enum.SortOrder.LayoutOrder
			ItemList.Padding = UDim.new(0, 6)
			
			-- AUTORESIZE SYSTEM (Très important pour éviter que les sections s'écrasent)
			ItemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				local ContentHeight = ItemList.AbsoluteContentSize.Y
				Section.Size = UDim2.new(0.48, 0, 0, ContentHeight + 60)
				
				-- Calcul de la hauteur de la page pour le scroll
				local MaxH = 0
				for _, child in pairs(Page:GetChildren()) do
					if child:IsA("Frame") then
						local Y = child.AbsolutePosition.Y + child.AbsoluteSize.Y - Page.AbsolutePosition.Y
						if Y > MaxH then MaxH = Y end
					end
				end
				Page.CanvasSize = UDim2.new(0, 0, 0, MaxH + 20)
			end)

			local SectionActions = {}

			-- [ ÉLÉMENT : BOUTON ] --
			function SectionActions:AddButton(Text, Callback)
				local Button = Instance.new("TextButton", ItemContainer)
				Button.Name = "Button"
				Button.Size = UDim2.new(1, 0, 0, 32)
				Button.BackgroundColor3 = Theme.Main
				Button.Text = Text
				Button.TextColor3 = Theme.Text
				Button.Font = Enum.Font.GothamBold
				Button.TextSize = 12
				Button.AutoButtonColor = false
				Button.ClipsDescendants = true
				
				Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
				local Stroke = Instance.new("UIStroke", Button)
				Stroke.Color = Theme.Outline
				Stroke.Thickness = 1
				
				-- Events
				Button.MouseEnter:Connect(function()
					TweenObj(Button, {BackgroundColor3 = Theme.Hover})
				end)
				Button.MouseLeave:Connect(function()
					TweenObj(Button, {BackgroundColor3 = Theme.Main})
				end)
				Button.MouseButton1Click:Connect(function()
					CreateRipple(Button)
					pcall(Callback)
				end)
			end

			-- [ ÉLÉMENT : TOGGLE ] --
			function SectionActions:AddToggle(Text, Default, Callback)
				local ToggleBtn = Instance.new("TextButton", ItemContainer)
				ToggleBtn.Name = "Toggle"
				ToggleBtn.Size = UDim2.new(1, 0, 0, 30)
				ToggleBtn.BackgroundTransparency = 1
				ToggleBtn.Text = ""
				ToggleBtn.AutoButtonColor = false
				
				local Label = Instance.new("TextLabel", ToggleBtn)
				Label.Size = UDim2.new(1, -45, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = Text
				Label.TextColor3 = Theme.TextDark
				Label.Font = Enum.Font.GothamMedium
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				
				-- Le Switch
				local SwitchBg = Instance.new("Frame", ToggleBtn)
				SwitchBg.Size = UDim2.new(0, 36, 0, 18)
				SwitchBg.Position = UDim2.new(1, -36, 0.5, -9)
				SwitchBg.BackgroundColor3 = Default and Theme.Accent or Theme.ToggleOff
				Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
				
				local SwitchCircle = Instance.new("Frame", SwitchBg)
				SwitchCircle.Size = UDim2.new(0, 14, 0, 14)
				SwitchCircle.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
				SwitchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Instance.new("UICorner", SwitchCircle).CornerRadius = UDim.new(1, 0)
				
				local Toggled = Default
				
				ToggleBtn.MouseButton1Click:Connect(function()
					Toggled = not Toggled
					
					-- Animations
					if Toggled then
						TweenObj(SwitchBg, {BackgroundColor3 = Theme.Accent})
						TweenObj(SwitchCircle, {Position = UDim2.new(1, -16, 0.5, -7)})
						TweenObj(Label, {TextColor3 = Theme.Text})
					else
						TweenObj(SwitchBg, {BackgroundColor3 = Theme.ToggleOff})
						TweenObj(SwitchCircle, {Position = UDim2.new(0, 2, 0.5, -7)})
						TweenObj(Label, {TextColor3 = Theme.TextDark})
					end
					
					pcall(Callback, Toggled)
				end)
			end

			-- [ ÉLÉMENT : SLIDER ] --
			function SectionActions:AddSlider(Text, Min, Max, Default, Callback)
				local SliderFrame = Instance.new("Frame", ItemContainer)
				SliderFrame.Name = "Slider"
				SliderFrame.Size = UDim2.new(1, 0, 0, 45)
				SliderFrame.BackgroundTransparency = 1
				
				-- Titre Slider
				local Label = Instance.new("TextLabel", SliderFrame)
				Label.Size = UDim2.new(1, 0, 0, 20)
				Label.BackgroundTransparency = 1
				Label.Text = Text
				Label.TextColor3 = Theme.TextDark
				Label.Font = Enum.Font.GothamMedium
				Label.TextSize = 13
				Label.TextXAlignment = Enum.TextXAlignment.Left
				
				-- Valeur affichée
				local ValueLabel = Instance.new("TextLabel", SliderFrame)
				ValueLabel.Size = UDim2.new(1, 0, 0, 20)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Text = tostring(Default)
				ValueLabel.TextColor3 = Theme.Text
				ValueLabel.Font = Enum.Font.GothamBold
				ValueLabel.TextSize = 13
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				
				-- Barre de fond
				local Bar = Instance.new("Frame", SliderFrame)
				Bar.Size = UDim2.new(1, 0, 0, 4)
				Bar.Position = UDim2.new(0, 0, 0, 30)
				Bar.BackgroundColor3 = Theme.Outline
				Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
				
				-- Barre de remplissage
				local Fill = Instance.new("Frame", Bar)
				Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
				
				local IsSliding = false
				
				local function UpdateSlider(Input)
					local SizeScale = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local Value = math.floor(Min + ((Max - Min) * SizeScale))
					
					TweenObj(Fill, {Size = UDim2.new(SizeScale, 0, 1, 0)}, 0.05)
					ValueLabel.Text = tostring(Value)
					pcall(Callback, Value)
				end
				
				Bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						IsSliding = true
						UpdateSlider(input)
					end
				end)
				
				UIS.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						IsSliding = false
					end
				end)
				
				UIS.InputChanged:Connect(function(input)
					if IsSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
						UpdateSlider(input)
					end
				end)
			end

			return SectionActions
		end
		return TabActions
	end
	return WindowActions
end

return Library
