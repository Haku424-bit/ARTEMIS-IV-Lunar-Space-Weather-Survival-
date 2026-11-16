local button = script.Parent
local samsung = game.Workspace.Base.LunarBase.GrowingRoom.Samsung
	
button.Triggered:Connect(function(player)
	button.Parent.Parent:SetAttribute("Plant", nil)
	button.Parent.Parent:SetAttribute("Stage", nil)
	
	local number = player:GetAttribute("Fome")
	player:SetAttribute("Fome", number + 8)
	
	local potatoSeed = samsung:GetAttribute("PotatoSeed")
	samsung:SetAttribute("PotatoSeed", potatoSeed + 2)
	
	print("O player clicou"..player.Name)
	button.Parent.Parent:Destroy()
end)
