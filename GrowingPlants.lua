local workspace = game:GetService("Workspace")
local aquaponia = workspace:WaitForChild("Base"):WaitForChild("LunarBase"):WaitForChild("GrowingRoom"):WaitForChild("Aquaponias"):WaitForChild("Aquaponia")
local serverStorage = game:GetService("ServerStorage")

local LettuceButton = serverStorage.Plants:WaitForChild("LettuceProximity")
local PotatoButton = serverStorage.Plants:WaitForChild("PotatoProximity")

local plants = {}

local scales = {
	0.250, 0.500, 1
}

local function GrowPlant()
	for _, object in aquaponia:GetDescendants() do
		if object.Name == "PlantLocal" then
			local plant = object:GetAttribute("Plant")
			if plant ~= nil then
				
				local number = math.random(1, 10)

				if number <= 3 then
					if object:GetAttribute("Stage") < 3 then
						
						object:SetAttribute("Stage", object:GetAttribute("Stage") + 1)
						local result, err = pcall(function()
							object[plant]:ScaleTo(scales[object:GetAttribute("Stage") + 1])
						end)
					elseif object:GetAttribute("Stage") == 3 then
						if object[plant]:FindFirstChildWhichIsA("ProximityPrompt") ~= nil then
							
						else
							if plant == "Lettuce" then
								local clone = LettuceButton:Clone()
								clone.Parent = object.Lettuce.Handle

							elseif plant == "Potato" then
								print("ProximityNaBaatata")
								local clone = PotatoButton:Clone()
								clone.Parent = object.Potato.Handle
							end
						end
						
					end

				end
			end
		end

	end

end



while true do
	task.wait(10)
	GrowPlant()
end

