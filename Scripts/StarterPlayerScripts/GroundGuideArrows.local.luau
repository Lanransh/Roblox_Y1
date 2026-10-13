-- Installed in StarterPlayer.StarterPlayerScripts.GroundGuideArrows.
-- 世界 1 保留原路径，世界 2、3 的预览模型放在 Decorations。
local RunService = game:GetService("RunService")
local decorations = workspace:WaitForChild("Decorations")
local guides = {
	workspace:WaitForChild("GroundGuideArrows"),
	decorations:WaitForChild("World2GroundGuideArrows"),
	decorations:WaitForChild("World3GroundGuideArrows"),
}
local arrows = {}

for guideIndex, guide in ipairs(guides) do
	for arrowIndex, arrow in ipairs(guide:GetChildren()) do
		if arrow:IsA("Model") then
			table.insert(arrows, {
				guide = guide,
				model = arrow,
				phase = arrow:GetAttribute("Phase"),
				parts = arrow:GetChildren(),
			})
		end
	end
end

local elapsed = 0
-- 三个世界复用相同的循环移动和淡入淡出效果。
--- @param dt number 平台渲染回调提供的帧间隔（秒）。
RunService.RenderStepped:Connect(function(dt)
	elapsed += dt
	for arrowIndex, arrow in ipairs(arrows) do
		local start = arrow.guide:GetAttribute("Start")
		local length = arrow.guide:GetAttribute("TravelLength")
		local speed = arrow.guide:GetAttribute("Speed")
		local distance = (arrow.phase + elapsed * speed) % length
		arrow.model:PivotTo(CFrame.new(start + Vector3.new(0, 0, distance)))
		local opacity = math.clamp(math.min(distance, length - distance) / 3, 0, 1)
		for partIndex, part in ipairs(arrow.parts) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1 - opacity
			end
		end
	end
end)
