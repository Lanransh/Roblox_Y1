-- Installed in StarterPlayer.StarterPlayerScripts.GroundGuideArrows.
-- 三个世界的箭头随各自装饰分组移动，动画起点使用模型局部坐标。
local RunService = game:GetService("RunService")
local decorations = workspace:WaitForChild("Decorations")
local guides = {
	decorations:WaitForChild("World1Decorations"):WaitForChild("GroundGuideArrows"),
	decorations:WaitForChild("World2Decorations"):WaitForChild("World2GroundGuideArrows"),
	decorations:WaitForChild("World3Decorations"):WaitForChild("World3GroundGuideArrows"),
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
		local start = arrow.guide:GetAttribute("StartOffset")
		local length = arrow.guide:GetAttribute("TravelLength")
		local speed = arrow.guide:GetAttribute("Speed")
		local distance = (arrow.phase + elapsed * speed) % length
		arrow.model:PivotTo(arrow.guide:GetPivot() * start * CFrame.new(0, 0, distance))
		local opacity = math.clamp(math.min(distance, length - distance) / 3, 0, 1)
		for partIndex, part in ipairs(arrow.parts) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 1 - opacity
			end
		end
	end
end)
