-- ServerScriptService/TurnoSystem (Script)
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fadeEvent = ReplicatedStorage:WaitForChild("DormirFadeEvent")

-- Configurações do Turno
local HORA_INICIO = 6   -- 06:00 UTC
local HORA_FIM = 18     -- 18:00 UTC
local SEGUNDOS_POR_MINUTO_JOGO = 0.35 -- Velocidade do relógio (0.35s reais = 1 min no jogo)

-- Estado inicial no Workspace
workspace:SetAttribute("DiaAtual", 1)
workspace:SetAttribute("HoraTexto", "06:00 UTC")
workspace:SetAttribute("TurnoEncerrado", false)

-- Aguarda RestingModule e o ProximityPrompt carregarem
local lunarBase = workspace:WaitForChild("Base"):WaitForChild("LunarBase")
local dormitory = lunarBase:WaitForChild("RestingModule")

local promptCama = dormitory:FindFirstChildWhichIsA("ProximityPrompt", true)
while not promptCama do
	task.wait(0.2)
	promptCama = dormitory:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local minutoAtual = HORA_INICIO * 60 -- Começa em 360 minutos (06:00)
local processandoSono = false

local function atualizarRelogio()
	local horas = math.floor(minutoAtual / 60)
	local minutos = minutoAtual % 60
	local textoFormatado = string.format("%02d:%02d UTC", horas, minutos)

	workspace:SetAttribute("MinutoDoDia", minutoAtual) -- 👈 Adicione esta linha
	workspace:SetAttribute("HoraTexto", textoFormatado)
	--Lighting.ClockTime = horas + (minutos / 60)
end

-- Loop principal do relógio do turno
task.spawn(function()
	atualizarRelogio()

	while true do
		task.wait(SEGUNDOS_POR_MINUTO_JOGO)

		-- Só avança o tempo se ainda não chegou às 18:00
		if not workspace:GetAttribute("TurnoEncerrado") then
			minutoAtual += 1
			atualizarRelogio()

			-- Chegou às 18:00 -> Congela o tempo e libera o sono
			if minutoAtual >= (HORA_FIM * 60) then
				workspace:SetAttribute("TurnoEncerrado", true)
				promptCama.ActionText = "Dormir (Iniciar Próximo Dia)"
			end
		end
	end
end)

-- Interação com a Cama para passar para o próximo dia
promptCama.Enabled = true
promptCama.ActionText = "Dormir (Disponível às 18:00)"

promptCama.Triggered:Connect(function(player)
	if processandoSono then return end

	-- Se ainda não deu 18:00, avisa o jogador
	if not workspace:GetAttribute("TurnoEncerrado") then
		promptCama.ActionText = "Ainda é cedo (aguarde 18:00 UTC)"
		task.wait(2)
		if not workspace:GetAttribute("TurnoEncerrado") then
			promptCama.ActionText = "Dormir (Disponível às 18:00)"
		end
		return
	end

	processandoSono = true
	promptCama.Enabled = false

	-- Escurece a tela dos jogadores
	fadeEvent:FireAllClients(true)
	task.wait(1.5)

	-- Avança o dia e reinicia o relógio para 06:00
	local proximoDia = (workspace:GetAttribute("DiaAtual") or 1) + 1
	workspace:SetAttribute("DiaAtual", proximoDia)
	minutoAtual = HORA_INICIO * 60
	atualizarRelogio()
	workspace:SetAttribute("TurnoEncerrado", false)

	task.wait(0.8)
	-- Clareia a tela novamente no novo dia e reativa o prompt da cama
	fadeEvent:FireAllClients(false)
	promptCama.ActionText = "Dormir (Disponível às 18:00)"
	promptCama.Enabled = true
	processandoSono = false
end)
