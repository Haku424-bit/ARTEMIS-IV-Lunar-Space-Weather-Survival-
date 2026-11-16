local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local replicatedStorage = game:GetService("ReplicatedStorage")

local planting = replicatedStorage:WaitForChild("Planting")

tool.Activated:Connect(function()
	local targetPart = mouse.Target

	if targetPart then
		if targetPart.Name == "PlantLocal" then
			planting:FireServer(targetPart, tool.Name)
		end
	end
end)

planting.OnClientEvent:Connect(function(toolName)
	local backpack = player.Backpack
	local character = player.Character

	local tool = backpack:FindFirstChild(toolName)

	if not tool and character then
		tool = character:FindFirstChild(toolName)
	end

	if tool then
		tool:Destroy()
	end
end)
