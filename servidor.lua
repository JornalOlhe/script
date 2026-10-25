if not game:GetService("RunService"):IsStudio() then return end

local MULT = 2
local NOME = "monkey"

local function ligar(hum)
	if hum:GetAttribute("DanoX") or not hum.Parent.Name:lower():find(NOME) then return end
	hum:SetAttribute("DanoX", true)
	local ultima, esperado = hum.Health, nil
	hum.HealthChanged:Connect(function(h)
		if esperado and math.abs(h - esperado) < 0.01 then
			ultima, esperado = h, nil
			return
		end
		if h < ultima then
			local novo = math.max(0, h - (ultima - h) * (MULT - 1))
			esperado = novo
			hum.Health = novo
			ultima = novo
		else
			ultima = h
		end
	end)
end

for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("Humanoid") then ligar(d) end
end
workspace.DescendantAdded:Connect(function(d)
	if d:IsA("Humanoid") then task.defer(ligar, d) end
end)
