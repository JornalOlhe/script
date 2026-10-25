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
