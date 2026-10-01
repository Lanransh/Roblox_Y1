local NativeBackpack = {}

function NativeBackpack.Start(player, network)
    local bound = {}
    local backpackConnection
    local characterConnection

    local function bindTool(tool)
        if not tool:IsA("Tool") or bound[tool] then
            return
        end
        bound[tool] = true
        tool.Activated:Connect(function()
            if tool:GetAttribute("FrameworkGridIndex") ~= nil then
                network:SendMsgToServer("C2S_ActivateTool", tool)
            end
        end)
        tool.Destroying:Connect(function()
            bound[tool] = nil
        end)
    end

    local function bindContainer(container)
        for _, child in ipairs(container:GetChildren()) do
            bindTool(child)
        end
        return container.ChildAdded:Connect(bindTool)
    end

    local function bindBackpack(backpack)
        if backpackConnection then
            backpackConnection:Disconnect()
        end
        backpackConnection = bindContainer(backpack)
    end

    local function bindCharacter(character)
        if characterConnection then
            characterConnection:Disconnect()
        end
        characterConnection = bindContainer(character)
    end

    player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            bindBackpack(child)
        end
    end)
    player.CharacterAdded:Connect(bindCharacter)
    if player.Character then
        bindCharacter(player.Character)
    end
    bindBackpack(player:WaitForChild("Backpack"))
end

return NativeBackpack
