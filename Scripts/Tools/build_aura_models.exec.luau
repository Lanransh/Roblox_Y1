-- Run in Studio Edit via MCP execute_luau (one-shot aura asset build).
local folder = game.ReplicatedStorage.Assets.Effects.Aura
local template = folder:FindFirstChild("01_Common")
assert(template, "Missing 01_Common template")

local function fromHex(hex: string): Color3
	hex = hex:gsub("#", "")
	return Color3.fromRGB(
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16)
	)
end

local function solidSequence(hex: string): ColorSequence
	return ColorSequence.new(fromHex(hex))
end

local function gradientSequence(hexes: { string }): ColorSequence
	local keypoints = {}
	local count = #hexes
	for index, hex in hexes do
		local t = if count == 1 then 0 else (index - 1) / (count - 1)
		keypoints[index] = ColorSequenceKeypoint.new(t, fromHex(hex))
	end
	return ColorSequence.new(keypoints)
end

local function applyColors(model: Model, solid: string?, gradient: { string }?)
	for _, desc in model:GetDescendants() do
		if desc:IsA("ParticleEmitter") then
			if gradient then
				desc.Color = gradientSequence(gradient)
			elseif solid then
				desc.Color = solidSequence(solid)
			end
		end
	end
end

local renames = {
	{ "05_Legendary", "13_Legendary" },
	{ "04_Epic", "10_Epic" },
	{ "03_Rare", "04_Rare" },
}
for _, pair in renames do
	local srcName, dstName = pair[1], pair[2]
	local src = folder:FindFirstChild(srcName)
	if src and not folder:FindFirstChild(dstName) then
		src.Name = dstName
	end
end

local tiers = {
	{ "03_Toxic", "#40FF20", nil },
	{ "05_Bronze", "#C87830", nil },
	{ "06_Abyss", "#204060", nil },
	{ "07_Void", "#8040A0", nil },
	{ "08_Crimson", nil, { "#FFC8C8", "#FF2848", "#500018" } },
	{ "09_Silver", "#C0CCD8", nil },
	{ "11_Ocean", "#00C8A8", nil },
	{ "12_Lunar", "#A0B0D8", nil },
	{ "14_Emerald", "#18C868", nil },
	{ "15_Sapphire", "#1860D0", nil },
	{ "16_Ruby", "#E81858", nil },
	{ "17_Sakura", nil, { "#FFF5FA", "#FF90C8", "#B01070" } },
	{ "18_Sunset", nil, { "#FFE8A0", "#FF6088", "#6020A0" } },
	{ "19_Frost", nil, { "#FFFFFF", "#B0F0FF", "#2878E8" } },
	{ "20_Inferno", nil, { "#FFF8C0", "#FF6800", "#7A1500" } },
	{ "21_Storm", nil, { "#FFFFFF", "#FFE840", "#5878F0" } },
	{ "22_Solar", nil, { "#FFFFE8", "#FFD020", "#FF9010" } },
	{ "23_Neon", nil, { "#FF50FF", "#00F0FF", "#FF2088" } },
	{ "24_Prismatic", nil, { "#FFFFFF", "#FF70D0", "#60D0FF", "#FFF060" } },
	{ "25_Astral", nil, { "#FFFFFF", "#E8D0FF", "#50B8FF", "#F0F8FF" } },
}

local created = 0
for index, tier in tiers do
	local modelName, solid, gradient = tier[1], tier[2], tier[3]
	local model = folder:FindFirstChild(modelName)
	if not model then
		model = template:Clone()
		model.Name = modelName
		model.Parent = folder
		created += 1
	end
	applyColors(model, solid, gradient)
	if index % 5 == 0 then
		task.wait()
	end
end

local names = {}
for _, child in folder:GetChildren() do
	if child:IsA("Model") then
		table.insert(names, child.Name)
	end
end
table.sort(names)
return { created = created, models = names, count = #names }
