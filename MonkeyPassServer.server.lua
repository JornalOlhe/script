-- ServerScriptService > MonkeyPassServer (Script)
-- Versao para testar no SEU proprio jogo no Roblox Studio.
-- Sem gamepass: os recursos sao liberados para testes.
-- O sistema de combate do jogo deve consultar DamageMultiplier para aplicar dano 2x.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local CONFIG = {
    MONKEY_TAG = "Monkey",
    MONKEY_FOLDER_NAME = "Monkeys",
    SAFE_FOLDER_NAME = "SafeSpots",
    ESCAPE_COOLDOWN = 3,
    MIN_DAMAGE_TO_ESCAPE = 1,
}

local FEATURES = {
    AutoAim = true,
    DoubleDamage = true,
    AutoEscape = true,
}

local remote = ReplicatedStorage:FindFirstChild("MonkeyPassToggle")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "MonkeyPassToggle"
    remote.Parent = ReplicatedStorage
end

local lastEscape = {}

local function getMonkeys()
    local tagged = CollectionService:GetTagged(CONFIG.MONKEY_TAG)
    if #tagged > 0 then
        return tagged
    end
    local folder = workspace:FindFirstChild(CONFIG.MONKEY_FOLDER_NAME)
    return folder and folder:GetChildren() or {}
end

local function nearestMonkeyDistance(position, monkeys)
    local best = math.huge
    for _, monkey in ipairs(monkeys) do
        if monkey:IsA("Model") then
            local hum = monkey:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health > 0 then
                local ok, pivot = pcall(function() return monkey:GetPivot() end)
                if ok then
                    local distance = (pivot.Position - position).Magnitude
                    if distance < best then best = distance end
                end
            end
        end
    end
    return best
end

local function pickSafeSpot()
    local folder = workspace:FindFirstChild(CONFIG.SAFE_FOLDER_NAME)
    if not folder then return nil end

    local monkeys = getMonkeys()
    local bestPart, bestScore = nil, -1
    for _, spot in ipairs(folder:GetChildren()) do
        if spot:IsA("BasePart") then
            local score = nearestMonkeyDistance(spot.Position, monkeys)
            if score > bestScore then
                bestPart, bestScore = spot, score
            end
        end
    end
    return bestPart
end

local function hookCharacter(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    local lastHealth = humanoid.Health
    humanoid.HealthChanged:Connect(function(health)
        local lost = lastHealth - health
        lastHealth = health
        if lost < CONFIG.MIN_DAMAGE_TO_ESCAPE or health <= 0 then return end
        if player:GetAttribute("AutoEscape") ~= true then return end

        local now = os.clock()
        if lastEscape[player] and now - lastEscape[player] < CONFIG.ESCAPE_COOLDOWN then
            return
        end

        local spot = pickSafeSpot()
        if not spot or not character.Parent then return end

        lastEscape[player] = now
        character:PivotTo(spot.CFrame + Vector3.new(0, 4, 0))
    end)
end

local function setupPlayer(player)
    player:SetAttribute("HasMonkeyPass", true) -- compatibility with the client UI
    player:SetAttribute("AutoAim", false)
    player:SetAttribute("DoubleDamage", false)
    player:SetAttribute("AutoEscape", false)
    player:SetAttribute("DamageMultiplier", 1)

    player.CharacterAdded:Connect(function(character)
        hookCharacter(player, character)
    end)
    if player.Character then
        task.spawn(hookCharacter, player, player.Character)
    end
end

remote.OnServerEvent:Connect(function(player, feature, enabled)
    if type(feature) ~= "string" or not FEATURES[feature] then return end
    if type(enabled) ~= "boolean" then return end

    player:SetAttribute(feature, enabled)
    if feature == "DoubleDamage" then
        player:SetAttribute("DamageMultiplier", enabled and 2 or 1)
    end
end)

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
    lastEscape[player] = nil
end)
