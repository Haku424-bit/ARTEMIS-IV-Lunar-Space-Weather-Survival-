local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local plants = require(replicatedStorage.Plants)

local growingComputer = replicatedStorage:WaitForChild("GrowingComputer")
local plants = require(replicatedStorage.Plants)
local computer = workspace.Base.LunarBase.GrowingRoom.Samsung


growingComputer.OnServerEvent:Connect(function(player, type)
	if type == "Select" then
		local currentPlant = computer:GetAttribute("CurrentPlant") .. "Seed"
		local character = player.character
		local backpack = player.Backpack
		local id = plants.plantsInformations[computer:GetAttribute("CurrentPlant")][4]
		
		if character:FindFirstChild(currentPlant) or backpack:FindFirstChild(currentPlant) then
			print("Jogador já possui a semente")
		else
		
			local seedTool = serverStorage.Tools.PlantSeed
			local humanoid = character:FindFirstChild("Humanoid")
		
			local DuplicatedSeed = seedTool:Clone()
			DuplicatedSeed.TextureId = "http://www.roblox.com/asset/?id="..id
			DuplicatedSeed.Name = currentPlant
			DuplicatedSeed.Parent = backpack
		end
	else
	
		local CurrentPlant = computer:GetAttribute("CurrentPlant")
		local position = table.find(plants.plantsOrder, CurrentPlant)
		local newPlant = ""
		if type == "Reverse" then
			if position == 1 then
				newPlant = plants.plantsOrder[#plants.plantsOrder]
			else
				newPlant = plants.plantsOrder[position - 1]
			end
		elseif type == "Forward" then
			if position == #plants.plantsOrder then
				newPlant = plants.plantsOrder[1]
			else
				newPlant = plants.plantsOrder[position + 1]
			end
		end
		computer:SetAttribute("CurrentPlant", newPlant)
		local seedCount = computer:GetAttribute(newPlant.."Seed")
		growingComputer:FireAllClients(newPlant, seedCount)
	end

end)
