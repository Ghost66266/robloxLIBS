--// WindUI Exploit Library
--// Drawing API | Lua Pur

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

--================================================--
-- THEME
--================================================--
Library.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(90, 130, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Muted = Color3.fromRGB(140, 140, 140),
    Outline = Color3.fromRGB(35, 35, 35)
}

--================================================--
-- UTILS
--================================================--
local function Tween(obj, prop, goal, speed)
    task.spawn(function()
        local start = obj[prop]
        local t = 0
        while t < 1 do
            t += RunService.RenderStepped:Wait() * speed
            obj[prop] = start:Lerp(goal, math.clamp(t, 0, 1))
        end
    end)
end

local function MouseIn(pos, size)
    local m = UserInputService:GetMouseLocation()
    return m.X > pos.X and m.X < pos.X + size.X and m.Y > pos.Y and m.Y < pos.Y + size.Y
end

--================================================--
-- DRAW OBJECT
--================================================--
local function Rect(pos, size, color)
    local r = Drawing.new("Square")
    r.Position = pos
    r.Size = size
    r.Color = color
    r.Filled = true
    r.Thickness = 1
    return r
end

local function Text(txt, pos, size)
    local t = Drawing.new("Text")
    t.Text = txt
    t.Position = pos
    t.Size = size
    t.Color = Library.Theme.Text
    t.Font = 2
    t.Center = false
    t.Outline = false
    return t
end

--================================================--
-- WINDOW
--================================================--
function Library:CreateWindow(cfg)
    local Window = {}
    Window.Title = cfg.Title or "WindUI"
    Window.Size = cfg.Size or Vector2.new(520, 360)
    Window.Position = cfg.Position or Vector2.new(200, 200)
    Window.Tabs = {}

    -- Main
    Window.Frame = Rect(Window.Position, Window.Size, self.Theme.Background)
    Window.Top = Rect(Window.Position, Vector2.new(Window.Size.X, 40), self.Theme.Outline)
    Window.TitleText = Text(Window.Title, Window.Position + Vector2.new(12, 10), 16)

    -- Drag
    local dragging, dragOffset
    UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and MouseIn(Window.Position, Vector2.new(Window.Size.X, 40)) then
            dragging = true
            dragOffset = Window.Position - UserInputService:GetMouseLocation()
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            Window.Position = UserInputService:GetMouseLocation() + dragOffset
            Window.Frame.Position = Window.Position
            Window.Top.Position = Window.Position
            Window.TitleText.Position = Window.Position + Vector2.new(12, 10)
        end
    end)

    --================================================--
    -- TAB
    --================================================--
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.Offset = 60

        local label = Text(name, Window.Position + Vector2.new(12 + (#Window.Tabs * 80), 48), 14)

        function Tab:AddButton(text, callback)
            local btn = {}
            btn.Frame = Rect(
                Window.Position + Vector2.new(20, Tab.Offset),
                Vector2.new(Window.Size.X - 40, 32),
                Library.Theme.Outline
            )
            btn.Text = Text(text, btn.Frame.Position + Vector2.new(10, 8), 14)

            UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and MouseIn(btn.Frame.Position, btn.Frame.Size) then
                    Tween(btn.Frame, "Color", Library.Theme.Accent, 6)
                    task.delay(0.15, function()
                        Tween(btn.Frame, "Color", Library.Theme.Outline, 6)
                    end)
                    pcall(callback)
                end
            end)

            Tab.Offset += 40
        end

        function Tab:AddToggle(text, default, callback)
            local state = default
            local toggle = Rect(
                Window.Position + Vector2.new(20, Tab.Offset),
                Vector2.new(24, 24),
                state and Library.Theme.Accent or Library.Theme.Outline
            )
            local label = Text(text, toggle.Position + Vector2.new(34, 4), 14)

            UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and MouseIn(toggle.Position, toggle.Size) then
                    state = not state
                    Tween(toggle, "Color", state and Library.Theme.Accent or Library.Theme.Outline, 6)
                    pcall(callback, state)
                end
            end)

            Tab.Offset += 36
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return Library
