-- Installed in StarterPlayer.StarterPlayerScripts.GroundGuideArrows.
-- The editable preview models live in Workspace.GroundGuideArrows.
local RunService = game:GetService("RunService")
local guide = workspace:WaitForChild("GroundGuideArrows")
local arrows = {}

for _, arrow in ipairs(guide:GetChildren()) do
	if arrow:IsA("Model") then
		table.insert(arrows, {
			model = arrow,
			phase = arrow:GetAttribute("Phase"),
			parts = arrow:GetChildren(),
		})
	end
end

local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
	elapsed += dt
	local start = guide:GetAttribute("Start")
	local length = guide:GetAttribute("TravelLength")
	local speed = guide:GetAttribute("Speed")
	for _, arrow in ipairs(arrows) do
		local distance = (arrow.phase + elapsed * speed) % length
		arrow.model:PivotTo(CFrame.new(start + Vector3.new(0, 0, distance)))
		local opacity = math.clamp(math.min(distance, length - distance) / 3, 0, 1)
		for _, part in ipairs(arrow.parts) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1 - opacity
			end
		end
	end
end)
