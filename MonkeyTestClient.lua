-- MonkeyTest Studio UI — interface de diagnóstico
-- Uso: Roblox Studio, em um LocalScript dentro de StarterPlayer > StarterPlayerScripts.
-- Esta versão testa apenas a interface. Não implementa exploit, aimbot, ESP de terceiros,
-- voo, teleporte, nem multiplicação de dano.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "MonkeyTestStudioUI"
local old = playerGui:FindFirstChild(GUI_NAME)
if old then old:Destroy() end

local state = {
    ESP = false,
    Fly = false,
    EscapeProximity = false,
    EscapeDamage = false,
    Damage2x = false,
}

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(340, 360)
window.Position = UDim2.new(0, 24, 0, 60)
window.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
window.BorderSizePixel = 0
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 78, 95)
stroke.Thickness = 1
stroke.Parent = window

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -90, 0, 42)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "MonkeyTest • Studio UI"
title.TextColor3 = Color3.fromRGB(245, 247, 250)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = window

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 28)
close.Position = UDim2.new(1, -40, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(170, 55, 60)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = window
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(30, 28)
minimize.Position = UDim2.new(1, -76, 0, 7)
minimize.BackgroundColor3 = Color3.fromRGB(60, 66, 78)
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 13
minimize.Parent = window
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -20, 0, 34)
tabs.Position = UDim2.fromOffset(10, 48)
tabs.BackgroundTransparency = 1
tabs.Parent = window

local pagesRoot = Instance.new("Frame")
pagesRoot.Size = UDim2.new(1, -20, 1, -94)
pagesRoot.Position = UDim2.fromOffset(10, 88)
pagesRoot.BackgroundTransparency = 1
pagesRoot.Parent = window

local pages = {}
local tabButtons = {}
local activePage = "Combat"

local function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
