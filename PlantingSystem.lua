local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local workspace = game:GetService("Workspace")
local computer = workspace.Base.LunarBase.GrowingRoom.Samsung

local planting = replicatedStorage:WaitForChild("Planting")

planting.OnServerEvent:Connect(function(player, targetPart, toolName)
	local seeds = computer:GetAttribute(toolName)
	computer:SetAttribute(toolName, seeds - 1)
	if seeds - 1 == 0 then
		planting:FireAllClients(toolName)
	end
	
	local currentPlant = targetPart:GetAttribute("Plant")
	local plant = toolName:sub(1, -5)
	
	if targetPart:GetAttribute("Plant") ~= nil then 
		print("Já existe uma planta aqui")
	else
		
		targetPart:SetAttribute("Plant", plant)
		targetPart:SetAttribute("Stage", 0)
	
		local clonePlant = serverStorage.Plants:FindFirstChild(plant):Clone()
		clonePlant.Parent = targetPart
		local numberCorrection = 0
	
		if plant == "Lettuce" then
			numberCorrection = 0.25
		elseif plant == "Potato" then
			numberCorrection = -0.25
		end
	
		if clonePlant:IsA("Model") or clonePlant:IsA("Tool") then
			clonePlant:MoveTo(targetPart.Position + Vector3.new(0, numberCorrection, 0))
		elseif clonePlant:IsA("BasePart") then 
			clonePlant.Position = targetPart.Position + Vector3.new(0, numberCorrection, 0)
		end
	end
end)
