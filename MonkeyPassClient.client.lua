-- StarterPlayer > StarterPlayerScripts > MonkeyPassClient (LocalScript)
-- Versao para teste no SEU proprio jogo pelo Roblox Studio.
-- Nao e um script para executor/injecao em jogo publicado.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MonkeyPassToggle")

local CONFIG = {
    AIM_RANGE = 250,
    MONKEY_TAG = "Monkey",
    MONKEY_FOLDER_NAME = "Monkeys",
    AIM_PART_NAMES = { "Head", "HumanoidRootPart" },
}

local function getMonkeys()
    local tagged = CollectionService:GetTagged(CONFIG.MONKEY_TAG)
    if #tagged > 0 then return tagged end
    local folder = workspace:FindFirstChild(CONFIG.MONKEY_FOLDER_NAME)
    return folder and folder:GetChildren() or {}
end

local function getAimPart(monkey)
    for _, name in ipairs(CONFIG.AIM_PART_NAMES) do
        local part = monkey:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return monkey.PrimaryPart
end

local function getBestTarget()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local bestPart, bestDistance = nil, CONFIG.AIM_RANGE
    for _, monkey in ipairs(getMonkeys()) do
        if monkey:IsA("Model") and monkey ~= character then
            local humanoid = monkey:FindFirstChildOfClass("Humanoid")
            local part = getAimPart(monkey)
            if part and (not humanoid or humanoid.Health > 0) then
                local distance = (part.Position - root.Position).Magnitude
                if distance < bestDistance then
                    bestPart, bestDistance = part, distance
                end
            end
        end
    end
    return bestPart
end

-- Outros LocalScripts do SEU jogo podem consultar esta BindableFunction.
local aimFn = ReplicatedStorage:FindFirstChild("MonkeyAimTarget")
if not aimFn then
    aimFn = Instance.new("BindableFunction")
    aimFn.Name = "MonkeyAimTarget"
    aimFn.Parent = ReplicatedStorage
end
aimFn.OnInvoke = function()
    if player:GetAttribute("AutoAim") ~= true then return nil end
    local part = getBestTarget()
    return part and part.Position or nil
end

local renderName = "MonkeyPassAim_" .. player.UserId
RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
    if player:GetAttribute("AutoAim") ~= true then return end
    local camera = workspace.CurrentCamera
    local part = getBestTarget()
    if camera and part then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, part.Position)
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MonkeyPassPanel"
gui.ResetOnSpawn = false
gui.Enabled = true -- sem gamepass
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 150)
frame.Position = UDim2.new(1, -236, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = "Monkey Test"
header.TextColor3 = Color3.fromRGB(245, 247, 250)
header.Font = Enum.Font.GothamBold
header.TextSize = 14
header.Parent = frame

local function makeToggle(y, feature, label)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 32)
    button.Position = UDim2.fromOffset(10, y)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local function refresh()
        local enabled = player:GetAttribute(feature) == true
        button.Text = label .. ": " .. (enabled and "ON" or "OFF")
        button.BackgroundColor3 = enabled
            and Color3.fromRGB(45, 135, 80)
            or Color3.fromRGB(55, 61, 72)
    end

    button.Activated:Connect(function()
        remote:FireServer(feature, player:GetAttribute(feature) ~= true)
    end)
    player:GetAttributeChangedSignal(feature):Connect(refresh)
    refresh()
end

makeToggle(36, "DoubleDamage", "Dano 2x*")
makeToggle(72, "AutoAim", "Mira automatica")
makeToggle(108, "AutoEscape", "Fuga automatica")

player:GetAttributeChangedSignal("HasMonkeyPass"):Connect(function()
    gui.Enabled = true
end)
