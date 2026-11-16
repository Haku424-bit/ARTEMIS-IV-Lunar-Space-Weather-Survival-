--Energy Script

local workspace = game:GetService("Workspace")
local lunarBase = workspace:WaitForChild("Base"):WaitForChild("LunarBase")
local Energy = workspace.Base.LunarBase["Main Module"]:WaitForChild("ControlPanelEnergy"):WaitForChild("Energy")

local growingRoom = lunarBase.GrowingRoom
local mainModule = lunarBase["Main Module"]
local restingModule = lunarBase["RestingModule"]
local safeRoom = lunarBase.saferoom

local places = {
	growingRoom, mainModule, restingModule, safeRoom
}
local function EnergyExpenditure(places)
	local number = 0
	for i= 1, #places do
		number = number + places[i]:GetAttribute("EnergyConsumption")
	end
	return number
end

local solarPanels = {
	workspace:WaitForChild("SolarPanel1"),
	workspace:WaitForChild("SolarPanel2"),
	workspace:WaitForChild("SolarPanel3")
}

local function updateEnergy()
	while true do
		local sumProduction = solarPanels[1]:GetAttribute("Production") + solarPanels[2]:GetAttribute("Production") + solarPanels[3]:GetAttribute("Production") - EnergyExpenditure(places)
		local newEnergy  = Energy:GetAttribute("Energy") + sumProduction
		Energy:SetAttribute("Energy", newEnergy)
		task.wait(5)
	end
end

updateEnergy()
