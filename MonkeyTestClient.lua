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
    page.Visible = false
    page.Parent = pagesRoot
    pages[name] = page
    return page
end

local function showPage(name)
    activePage = name
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for tabName, button in pairs(tabButtons) do
        button.BackgroundColor3 = tabName == name
            and Color3.fromRGB(58, 112, 190)
            or Color3.fromRGB(48, 54, 65)
    end
end

local tabNames = {"Combat", "Visuals", "Movement"}
for i, name in ipairs(tabNames) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1/3, -4, 1, 0)
    button.Position = UDim2.new((i-1)/3, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(48, 54, 65)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(245, 247, 250)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = tabs
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    tabButtons[name] = button
    button.Activated:Connect(function() showPage(name) end)
    makePage(name)
end

local function makeStatus(parent, y, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 36)
    label.Position = UDim2.fromOffset(4, y)
    label.BackgroundColor3 = Color3.fromRGB(35, 40, 49)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(225, 229, 237)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.Parent = parent
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 6)
    return label
end

local function makeToggle(parent, y, key, label)
    local button = Instance.new("TextButton")
    button.Name = key .. "Toggle"
    button.Size = UDim2.new(1, -8, 0, 34)
    button.Position = UDim2.fromOffset(4, y)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local function refresh()
        button.Text = label .. ": " .. (state[key] and "ON" or "OFF")
        button.BackgroundColor3 = state[key]
            and Color3.fromRGB(45, 135, 80)
            or Color3.fromRGB(55, 61, 72)
    end

    button.Activated:Connect(function()
        state[key] = not state[key]
        refresh()
        print("[MonkeyTest Studio UI] " .. key .. " = " .. tostring(state[key])
            .. " (interface de demonstração; recurso não conectado)")
    end)
    refresh()
    return button
end

makeStatus(pages.Combat, 8, "Dano 2×: indisponível nesta demonstração. Exige integração no servidor do seu próprio jogo.")
makeToggle(pages.Combat, 54, "Damage2x", "Dano 2× (somente UI)")

makeStatus(pages.Visuals, 8, "ESP: demonstração de interface. Nenhum NPC é rastreado ou destacado.")
makeToggle(pages.Visuals, 54, "ESP", "ESP (somente UI)")

makeStatus(pages.Movement, 8, "Movimento: os botões abaixo apenas testam o estado visual. Não alteram o personagem.")
makeToggle(pages.Movement, 54, "Fly", "Voo (somente UI)")
makeToggle(pages.Movement, 98, "EscapeProximity", "Fuga por proximidade (somente UI)")
makeToggle(pages.Movement, 142, "EscapeDamage", "Fuga ao receber dano (somente UI)")

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 22)
footer.Position = UDim2.new(0, 10, 1, -26)
footer.BackgroundTransparency = 1
footer.Text = "Painel de diagnóstico • Studio"
footer.TextColor3 = Color3.fromRGB(150, 160, 178)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.Parent = window

local minimized = false
local expandedSize = window.Size
minimize.Activated:Connect(function()
    minimized = not minimized
    tabs.Visible = not minimized
    pagesRoot.Visible = not minimized
    footer.Visible = not minimized
    window.Size = minimized and UDim2.fromOffset(340, 42) or expandedSize
    minimize.Text = minimized and "+" or "—"
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Arrastar pela barra de título com mouse ou toque.
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart
local startPosition
local dragConnections = {}

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = window.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if conn then conn:Disconnect() end
            end
        end)
        table.insert(dragConnections, conn)
    end
end)

table.insert(dragConnections, UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))

gui.Destroying:Connect(function()
    for _, connection in ipairs(dragConnections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    table.clear(dragConnections)
end)

showPage(activePage)
print("[MonkeyTest Studio UI] Painel carregado. Esta versão só testa a interface.")
