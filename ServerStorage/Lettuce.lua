local button = script.Parent
local samsung = game.Workspace.Base.LunarBase.GrowingRoom.Samsung

button.Triggered:Connect(function(player)
	button.Parent.Parent:SetAttribute("Plant", nil)
	button.Parent.Parent:SetAttribute("Stage", nil)
	
	local number = player:GetAttribute("Fome")
	player:SetAttribute("Fome", number + 8)
	
	local lettuceSeed = samsung:GetAttribute("LettuceSeed")
	samsung:SetAttribute("LettuceSeed", lettuceSeed + 2)
	
	print("O player clicou"..player.Name)
	button.Parent:Destroy()
end)
