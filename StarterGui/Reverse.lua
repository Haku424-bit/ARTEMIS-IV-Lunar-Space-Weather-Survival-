local soundService = game:GetService("SoundService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local growingComputer = replicatedStorage:WaitForChild("GrowingComputer")

local button = script.Parent
local plants = require(replicatedStorage.Plants)

local clickSound = soundService["Click sound"]

button.MouseButton1Click:Connect(function()
	local clickSoundCopy = clickSound:Clone()
	clickSoundCopy.Parent = button
	
	clickSoundCopy:Play()
	growingComputer:FireServer("Reverse")
	clickSoundCopy.Ended:Wait()
	clickSoundCopy:Destroy()
	
end)

local function ChangePlant(currentPlant, SeedCounter)
	local frame = script.Parent.Parent.PlantInfo
	frame.ImageLabel.Image = "rbxassetid://" .. plants.plantsInformations[currentPlant][4]
	frame.PlantName.Text = currentPlant
	frame.ScientificName.Text = plants.plantsInformations[currentPlant][1]
	frame.Data1.Text = plants.plantsInformations[currentPlant][2]
	frame.Data2.Text = plants.plantsInformations[currentPlant][3]
	frame.SeedCount.Text = SeedCounter
end

growingComputer.OnClientEvent:Connect(function(newPlant, SeedCounter)
	ChangePlant(newPlant, SeedCounter)
end)
