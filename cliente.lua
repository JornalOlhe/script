local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local NOME = "monkey"                    -- trecho do nome dos monstros (minúsculo)
local POS_SEGURA = Vector3.new(0, 500, 0)
local mira, ultimaPos = false, nil
local alvos = {}

local plat = Instance.new("Part")
plat.Size = Vector3.new(60, 2, 60)
plat.Anchored = true
plat.Position = POS_SEGURA
plat.Parent = workspace

-- ESP + lista de alvos
task.spawn(function()
	while true do
		local lista = {}
		for _, h in ipairs(workspace:GetDescendants()) do
			if h:IsA("Humanoid") and h.Health > 0 and h.Parent:IsA("Model")
				and not Players:GetPlayerFromCharacter(h.Parent)
				and h.Parent.Name:lower():find(NOME) then
				local m = h.Parent
				if not m:FindFirstChild("TesteESP") then
					local hl = Instance.new("Highlight")
					hl.Name = "TesteESP"
					hl.FillColor = Color3.fromRGB(255, 0, 0)
					hl.FillTransparency = 0.5
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = m
				end
				local r = m:FindFirstChild("HumanoidRootPart")
				if r then table.insert(lista, r) end
			end
		end
		alvos = lista
		task.wait(0.5)
	end
end)

-- fuga ao levar dano
local function ligarFuga(char)
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	local vida = hum.Health
	hum.HealthChanged:Connect(function(h)
		if h < vida then
			ultimaPos = hrp.CFrame
			hrp.CFrame = CFrame.new(POS_SEGURA + Vector3.new(0, 4, 0))
		end
		vida = h
	end)
end
if player.Character then ligarFuga(player.Character) end
player.CharacterAdded:Connect(ligarFuga)

UIS.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.G then mira = not mira end
	if i.KeyCode == Enum.KeyCode.T and ultimaPos then
		local c = player.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = ultimaPos end
	end
end)

-- mira (câmera não se mexe)
RunService.Heartbeat:Connect(function()
	local c = player.Character
	local hrp = c and c:FindFirstChild("HumanoidRootPart")
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end
	hum.AutoRotate = not mira
	if mira then
		local alvo, menor = nil, math.huge
		for _, r in ipairs(alvos) do
			if r.Parent then
				local d = (r.Position - hrp.Position).Magnitude
				if d < menor then alvo, menor = r, d end
			end
		end
		if alvo then
			local p = alvo.Position
			hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(p.X, hrp.Position.Y, p.Z))
		end
	end
end)
