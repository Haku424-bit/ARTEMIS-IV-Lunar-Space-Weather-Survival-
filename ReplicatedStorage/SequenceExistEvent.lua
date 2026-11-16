-- StarterPlayer/StarterPlayerScripts/ControleCutsceneSaida (LocalScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local eventoSaida = ReplicatedStorage:WaitForChild("SequenciaSaidaEvent")

-- Acessa o módulo oficial de controles do Roblox
local PlayerScripts = player:WaitForChild("PlayerScripts")
local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
local controls = PlayerModule:GetControls()

eventoSaida.OnClientEvent:Connect(function(emCutscene)
	if emCutscene then
		controls:Disable() -- Trava WASD/Pulo durante a caminhada automática
	else
		controls:Enable()  -- Devolve o controle ao jogador já do lado de fora!
	end
end)
