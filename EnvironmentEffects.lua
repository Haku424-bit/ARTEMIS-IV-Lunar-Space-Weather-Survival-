-- ServerScriptService/EfeitosAmbiente (Script)
local Lighting = game:GetService("Lighting")
local COR_AMBIENTE_NORMAL = Lighting.OutdoorAmbient

-- Busca a peça das partículas e o som de radiação
local zonaSEP = workspace:FindFirstChild("ZonaParticulasSEP", true)
local particulasSEP = zonaSEP and zonaSEP:FindFirstChildOfClass("ParticleEmitter")
local somSEP = zonaSEP and zonaSEP:FindFirstChildOfClass("Sound")

if particulasSEP then
	particulasSEP.Enabled = false
end

workspace:GetAttributeChangedSignal("EventoAtivo"):Connect(function()
	local evento = workspace:GetAttribute("EventoAtivo")

	-- Liga ou desliga as partículas e o som do SEP juntos
	if evento == "SEP" then
		if particulasSEP then particulasSEP.Enabled = true end
		if somSEP then somSEP:Play() end

		-- Radiação de prótons: ambiente avermelhado de alerta
		Lighting.OutdoorAmbient = Color3.fromRGB(160, 30, 30)

	else
		-- Garante que o som e as partículas do SEP parem quando mudar de evento
		if particulasSEP then particulasSEP.Enabled = false end
		if somSEP then somSEP:Stop() end

		if evento == "GST" then
			-- Tempestade geomagnética: queda de energia
			Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 25)

		elseif evento == "FLR" then
			-- Clarão solar: pisca a iluminação
			task.spawn(function()
				while workspace:GetAttribute("EventoAtivo") == "FLR" do
					Lighting.OutdoorAmbient = Color3.fromRGB(255, 220, 150)
					task.wait(0.15)
					Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 60)
					task.wait(0.2)
				end
			end)

		else
			Lighting.OutdoorAmbient = COR_AMBIENTE_NORMAL
		end
	end
end)
