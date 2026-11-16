-- ServerScriptService/MissionController (Script)
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DonkiService = require(ServerScriptService:WaitForChild("DonkiService"))

-- References to the 4 monitors inside Base > LunarBase > Main Module > Telas
local pastaTelas = workspace:WaitForChild("Base")
	:WaitForChild("LunarBase")
	:WaitForChild("Main Module")
	:WaitForChild("Telas")

-- Automatically configures PC terminal layout (preserves Studio Frame orientation, split screen on Main Monitor)
local function configurarMonitor(nomeMonitor, ehPrincipal)
	local peca = pastaTelas:FindFirstChild(nomeMonitor, true)
	assert(peca, "ERROR: Could not find part '" .. nomeMonitor .. "' inside Telas folder!")

	local surfaceGui = peca:WaitForChild("SurfaceGui")
	-- Preserva o Frame original que você já alinhou/rotacionou no Roblox Studio!
	local frame = surfaceGui:WaitForChild("Frame")

	-- Remove apenas os itens antigos de dentro do Frame (UIListLayout, Cabecalho, Conteudo)
	for _, filho in ipairs(frame:GetChildren()) do
		if filho:IsA("GuiObject") or filho:IsA("UILayout") then
			filho:Destroy()
		end
	end

	-- Borda estilo terminal
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 130, 180)
	stroke.Thickness = 3
	stroke.Parent = frame

	-- Barra superior (Header) usando Scale para se adaptar ao tamanho exato do seu Frame
	local barraTopo = Instance.new("Frame")
	barraTopo.Name = "BarraTopo"
	barraTopo.Size = UDim2.new(1, 0, 0.14, 0)
	barraTopo.BackgroundColor3 = Color3.fromRGB(18, 36, 66)
	barraTopo.BorderSizePixel = 0
	barraTopo.Parent = frame

	local cabecalho = Instance.new("TextLabel")
	cabecalho.Name = "Cabecalho"
	cabecalho.Size = UDim2.new(0.94, 0, 0.85, 0)
	cabecalho.Position = UDim2.new(0.03, 0, 0.075, 0)
	cabecalho.BackgroundTransparency = 1
	cabecalho.Font = Enum.Font.Code
	cabecalho.TextScaled = true
	cabecalho.TextColor3 = Color3.fromRGB(110, 235, 255)
	cabecalho.TextXAlignment = Enum.TextXAlignment.Left
	cabecalho.Parent = barraTopo

	if not ehPrincipal then
		-- Layout de 1 coluna para Monitores 1, 3 e 4
		local conteudo = Instance.new("TextLabel")
		conteudo.Name = "Conteudo"
		conteudo.Size = UDim2.new(0.92, 0, 0.78, 0)
		conteudo.Position = UDim2.new(0.04, 0, 0.18, 0)
		conteudo.BackgroundTransparency = 1
		conteudo.Font = Enum.Font.Code
		conteudo.TextSize = 18
		conteudo.TextWrapped = true
		conteudo.TextColor3 = Color3.fromRGB(220, 245, 235)
		conteudo.TextXAlignment = Enum.TextXAlignment.Left
		conteudo.TextYAlignment = Enum.TextYAlignment.Top
		conteudo.LineHeight = 1.2
		conteudo.Parent = frame

		return {
			peca = peca,
			fundo = frame,
			cabecalho = cabecalho,
			conteudo = conteudo
		}
	else
		-- Monitor Principal Dividido: Alerta (Esquerda 51%) | Checklist (Direita 42%)
		local colEsquerda = Instance.new("Frame")
		colEsquerda.Name = "PainelAlerta"
		colEsquerda.Size = UDim2.new(0.51, 0, 0.78, 0)
		colEsquerda.Position = UDim2.new(0.02, 0, 0.18, 0)
		colEsquerda.BackgroundColor3 = Color3.fromRGB(8, 16, 30)
		colEsquerda.BackgroundTransparency = 0.35
		colEsquerda.BorderSizePixel = 0
		colEsquerda.Parent = frame

		local conteudoAlerta = Instance.new("TextLabel")
		conteudoAlerta.Name = "Conteudo"
		conteudoAlerta.Size = UDim2.new(0.92, 0, 0.90, 0)
		conteudoAlerta.Position = UDim2.new(0.04, 0, 0.05, 0)
		conteudoAlerta.BackgroundTransparency = 1
		conteudoAlerta.Font = Enum.Font.Code
		conteudoAlerta.TextSize = 20
		conteudoAlerta.TextWrapped = true
		conteudoAlerta.TextColor3 = Color3.fromRGB(235, 250, 240)
		conteudoAlerta.TextXAlignment = Enum.TextXAlignment.Left
		conteudoAlerta.TextYAlignment = Enum.TextYAlignment.Top
		conteudoAlerta.LineHeight = 1.25
		conteudoAlerta.Parent = colEsquerda

		local divisor = Instance.new("Frame")
		divisor.Name = "Divisor"
		divisor.Size = UDim2.new(0.005, 0, 0.78, 0)
		divisor.Position = UDim2.new(0.545, 0, 0.18, 0)
		divisor.BackgroundColor3 = Color3.fromRGB(45, 130, 180)
		divisor.BorderSizePixel = 0
		divisor.Parent = frame

		local colDireita = Instance.new("Frame")
		colDireita.Name = "PainelChecklist"
		colDireita.Size = UDim2.new(0.42, 0, 0.78, 0)
		colDireita.Position = UDim2.new(0.56, 0, 0.18, 0)
		colDireita.BackgroundColor3 = Color3.fromRGB(8, 16, 30)
		colDireita.BackgroundTransparency = 0.35
		colDireita.BorderSizePixel = 0
		colDireita.Parent = frame

		local tituloChecklist = Instance.new("TextLabel")
		tituloChecklist.Name = "TituloChecklist"
		tituloChecklist.Size = UDim2.new(0.92, 0, 0.15, 0)
		tituloChecklist.Position = UDim2.new(0.04, 0, 0.04, 0)
		tituloChecklist.BackgroundTransparency = 1
		tituloChecklist.Font = Enum.Font.Code
		tituloChecklist.TextScaled = true
		tituloChecklist.TextColor3 = Color3.fromRGB(255, 210, 90)
		tituloChecklist.TextXAlignment = Enum.TextXAlignment.Left
		tituloChecklist.Text = "SHIFT CHECKLIST [0%]"
		tituloChecklist.Parent = colDireita

		local listaChecklist = Instance.new("TextLabel")
		listaChecklist.Name = "ListaChecklist"
		listaChecklist.Size = UDim2.new(0.92, 0, 0.75, 0)
		listaChecklist.Position = UDim2.new(0.04, 0, 0.22, 0)
		listaChecklist.BackgroundTransparency = 1
		listaChecklist.Font = Enum.Font.Code
		listaChecklist.TextSize = 16
		listaChecklist.TextWrapped = true
		listaChecklist.TextColor3 = Color3.fromRGB(200, 235, 220)
		listaChecklist.TextXAlignment = Enum.TextXAlignment.Left
		listaChecklist.TextYAlignment = Enum.TextYAlignment.Top
		listaChecklist.LineHeight = 1.25
		listaChecklist.Parent = colDireita

		return {
			peca = peca,
			fundo = frame,
			cabecalho = cabecalho,
			conteudo = conteudoAlerta,
			tituloChecklist = tituloChecklist,
			listaChecklist = listaChecklist
		}
	end
end

local mon1 = configurarMonitor("Monitor 1", false) -- Left (Base Systems)
local mon2 = configurarMonitor("Monitor 2", true)  -- Center Main (Split: Solar Alert + Checklist)
local mon3 = configurarMonitor("Monitor 3", false) -- Bottom Right (NASA Scientific Bulletin)
local mon4 = configurarMonitor("Monitor 4", false) -- Top Right (Lunar Environmental Telemetry)

local somAlerta = mon2.peca:WaitForChild("SomAlerta")

-- 1. FLR Objective (Comms Antenna on roof)
local pecaAntena = workspace:WaitForChild("Base"):WaitForChild("AntenaComunicacao"):WaitForChild("Base")
local promptAntena = pecaAntena:WaitForChild("ProximityPrompt")
local effectPart = pecaAntena:WaitForChild("EffectPart")
local somAntena = pecaAntena:FindFirstChildOfClass("Sound")

-- 2. SEP Objective (Radiation Storm Shelter)
local abrigo = workspace:FindFirstChild("AbrigoRadiacao", true)

-- 3. CME Objective (Direct on Monitor 1)
local promptCME = mon1.peca:WaitForChild("ProximityPrompt")

-- Shift Checklist State (3 daily routine tasks - resets automatically at the start of each new day)
local tarefasTurno = {
	checarPainelPrincipal = false,
	checarEstufa = false,
	checarEnergia = false
}

local function atualizarChecklistUI()
	local total = 3
	local concluidas = 0
	for _, ok in pairs(tarefasTurno) do
		if ok then concluidas += 1 end
	end
	local pct = math.floor((concluidas / total) * 100)

	mon2.tituloChecklist.Text = string.format("SHIFT CHECKLIST [%d%%]", pct)
	mon2.listaChecklist.Text = table.concat({
		(tarefasTurno.checarPainelPrincipal and "[✓]" or "[ ]") .. " Check main telemetry PC",
		(tarefasTurno.checarEstufa and "[✓]" or "[ ]") .. " Inspect GrowingRoom (5s)",
		(tarefasTurno.checarEnergia and "[✓]" or "[ ]") .. " Check Solar Panels status",
		"",
		workspace:GetAttribute("TurnoEncerrado")
			and "► 18:00 UTC: Go to Dormitory!"
			or "► Active shift (06:00 - 18:00 UTC)"
	}, "\n")
end

workspace:GetAttributeChangedSignal("DiaAtual"):Connect(function()
	tarefasTurno.checarPainelPrincipal = false
	tarefasTurno.checarEstufa = false
	tarefasTurno.checarEnergia = false
	atualizarChecklistUI()
end)

workspace:GetAttributeChangedSignal("TurnoEncerrado"):Connect(atualizarChecklistUI)

-- References for automatic proximity/interaction detection
local mainModule = workspace:WaitForChild("Base"):WaitForChild("LunarBase"):WaitForChild("Main Module")
local computerModel = mainModule:FindFirstChild("Computer", true)
local controlPanelEnergy = mainModule:FindFirstChild("ControlPanelEnergy", true)
local growingRoom = workspace:WaitForChild("Base"):WaitForChild("LunarBase"):FindFirstChild("GrowingRoom", true)

-- Detects clicks/interactions on ControlPanelEnergy buttons or ProximityPrompts
if controlPanelEnergy then
	for _, desc in ipairs(controlPanelEnergy:GetDescendants()) do
		if desc:IsA("ClickDetector") then
			desc.MouseClick:Connect(function()
				if not tarefasTurno.checarEnergia then
					tarefasTurno.checarEnergia = true
					atualizarChecklistUI()
				end
			end)
		elseif desc:IsA("ProximityPrompt") then
			desc.Triggered:Connect(function()
				if not tarefasTurno.checarEnergia then
					tarefasTurno.checarEnergia = true
					atualizarChecklistUI()
				end
			end)
		end
	end
end

-- Helper to get the center position of any Model or BasePart
local function obterPosicaoCentro(obj)
	if not obj then return nil end
	if obj:IsA("Model") then
		return obj:GetPivot().Position
	elseif obj:IsA("BasePart") then
		return obj.Position
	end
	return nil
end

-- Background loop tracking player presence at Main PC, GrowingRoom (5s), and ControlPanelEnergy
task.spawn(function()
	local tempoNaEstufa = 0
	local posPC = obterPosicaoCentro(computerModel) or mon2.peca.Position
	local posEstufa = obterPosicaoCentro(growingRoom)
	local posEnergia = obterPosicaoCentro(controlPanelEnergy)

	while true do
		task.wait(1)
		local alguemNaEstufa = false

		for _, player in ipairs(Players:GetPlayers()) do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local posJogador = root.Position

				-- 1. Check Main Telemetry PC (within 10 studs of Monitor 2 / Computer)
				if not tarefasTurno.checarPainelPrincipal and (posJogador - posPC).Magnitude <= 10 then
					tarefasTurno.checarPainelPrincipal = true
					atualizarChecklistUI()
				end

				-- 2. Check GrowingRoom (within 22 studs of GrowingRoom center)
				if not tarefasTurno.checarEstufa and posEstufa and (posJogador - posEstufa).Magnitude <= 22 then
					alguemNaEstufa = true
				end

				-- 3. Fallback proximity for ControlPanelEnergy (within 8 studs if no ClickDetector fired)
				if not tarefasTurno.checarEnergia and posEnergia and (posJogador - posEnergia).Magnitude <= 8 then
					tarefasTurno.checarEnergia = true
					atualizarChecklistUI()
				end
			end
		end

		if alguemNaEstufa and not tarefasTurno.checarEstufa then
			tempoNaEstufa += 1
			if tempoNaEstufa >= 5 then
				tarefasTurno.checarEstufa = true
				tempoNaEstufa = 0
				atualizarChecklistUI()
			end
		else
			tempoNaEstufa = 0
		end
	end
end)

atualizarChecklistUI()

local function alternarFaiscas(estado)
	for _, filho in ipairs(effectPart:GetDescendants()) do
		if filho:IsA("ParticleEmitter") or filho:IsA("Light") or filho:IsA("Sparkles") then
			filho.Enabled = estado
		end
	end
end

local function resetarTodosObjetivos()
	promptAntena.Enabled = false
	alternarFaiscas(false)
	if somAntena then somAntena:Stop() end

	promptCME.Enabled = false
	workspace:SetAttribute("SobrecargaCME", false)
	workspace:SetAttribute("ImpactoCME", false)
end

local COR_NORMAL = Color3.fromRGB(12, 22, 42)
local COR_ALERTA_RADIACAO = Color3.fromRGB(185, 85, 0)
local COR_ALERTA_EXTREMO = Color3.fromRGB(160, 20, 20)
local COR_SUCESSO = Color3.fromRGB(20, 125, 55)

local function pintarTodosMonitores(cor)
	mon1.fundo.BackgroundColor3 = cor
	mon2.fundo.BackgroundColor3 = cor
	mon3.fundo.BackgroundColor3 = cor
	mon4.fundo.BackgroundColor3 = cor
end

-- Base internal lighting flicker during Solar Flares (FLR)
local baseLunar = workspace:WaitForChild("Base"):WaitForChild("LunarBase")
local luzesBase = {}
local pecasNeon = {}

for _, obj in ipairs(baseLunar:GetDescendants()) do
	if obj:IsA("Light") and obj.Enabled == true then
		-- Ignora luzes gigantes que simulam o Sol/iluminação externa (Range >= 60 ou nome Sun/Sol)
		local nomeLower = string.lower(obj.Name)
		local parentLower = obj.Parent and string.lower(obj.Parent.Name) or ""
		
		
		local ehSol = string.find(nomeLower, "sun") or string.find(nomeLower, "sol")
			or string.find(parentLower, "sun") or string.find(parentLower, "sol")
			or (obj:IsA("PointLight") and obj.Range >= 60)

		if not ehSol then
			luzesBase[obj] = {
				brilho = obj.Brightness,
				ativo = obj.Enabled
			}
			-- Se a peça pai da luz for Neon, guarda para escurecer junto na piscada
			if obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Material == Enum.Material.Neon then
				pecasNeon[obj.Parent] = obj.Parent.Color
			end
		end
	end
end

local piscandoLuzes = false
local function iniciarOscilacaoLuzes()
	if piscandoLuzes then return end
	piscandoLuzes = true
	task.spawn(function()
		while piscandoLuzes do
			-- 45% de chance de apagar totalmente por uma fração de segundo (efeito curto-circuito)
			local apagaoRapido = (math.random(1, 100) <= 45)
			local fator = apagaoRapido and 0 or (math.random(10, 45) / 100)

			for luz, dados in pairs(luzesBase) do
				if luz and luz.Parent then
					luz.Enabled = not apagaoRapido
					luz.Brightness = dados.brilho * fator
				end
			end

			for peca, corOriginal in pairs(pecasNeon) do
				if peca and peca.Parent then
					peca.Color = apagaoRapido and Color3.fromRGB(25, 30, 40) or corOriginal:Lerp(Color3.new(0, 0, 0), 0.6)
				end
			end

			task.wait(apagaoRapido and (math.random(6, 14) / 100) or (math.random(10, 25) / 100))

			-- Volta brevemente antes da próxima oscilação
			for luz, dados in pairs(luzesBase) do
				if luz and luz.Parent then
					luz.Enabled = dados.ativo
					luz.Brightness = dados.brilho
				end
			end
			for peca, corOriginal in pairs(pecasNeon) do
				if peca and peca.Parent then
					peca.Color = corOriginal
				end
			end

			task.wait(math.random(15, 45) / 100)
		end

		-- Garante 100% restaurado ao finalizar o evento
		for luz, dados in pairs(luzesBase) do
			if luz and luz.Parent then
				luz.Enabled = dados.ativo
				luz.Brightness = dados.brilho
			end
		end
		for peca, corOriginal in pairs(pecasNeon) do
			if peca and peca.Parent then
				peca.Color = corOriginal
			end
		end
	end)
end

local function pararOscilacaoLuzes()
	piscandoLuzes = false
end

-- Parallel loop for MONITOR 4 (Coordinates, Lunar Temperature & Environmental Telemetry)
task.spawn(function()
	local tempBase = -128.4
	while true do
		local eventoAtual = workspace:GetAttribute("EventoAtivo")
		local variacao = math.random(-8, 8) / 10
		local tempAtual = tempBase + variacao

		mon4.cabecalho.Text = "LUNAR TELEMETRY [ARTEMIS-IV]"

		if eventoAtual == "FLR" then
			mon4.conteudo.Text = "COORD: 89.54° S, 0.00° E\nSECTOR: Shackleton Crater\nEXT TEMP: [SENSOR ERROR]\nGPS SIGNAL: SOLAR INTERFERENCE"
		elseif eventoAtual == "SEP" then
			mon4.conteudo.Text = string.format(
				"COORD: 89.54° S, 0.00° E\nEXT TEMP: %.1f °C\nCABIN PRESS: 101.3 kPa\nPROTON FLUX: ⚠ CRITICAL",
				tempAtual + 12.5
			)
		elseif eventoAtual == "CME" then
			mon4.conteudo.Text = string.format(
				"COORD: 89.54° S, 0.00° E\nEXT TEMP: %.1f °C\nMAG FIELD: ⚠ UNSTABLE\nPOWER GRID: HIGH VOLTAGE",
				tempAtual + 8.0
			)
		else
			mon4.conteudo.Text = string.format(
				"COORD: 89.54° S, 0.00° E\nSECTOR: Shackleton Crater\nEXT TEMP: %.1f °C\nCABIN PRESS: 101.3 kPa",
				tempAtual
			)
		end

		task.wait(1.5)
	end
end)

resetarTodosObjetivos()
DonkiService:CarregarEventos()

-- Load exact historical timeline from May 08 to May 15, 2024
local eventosHistoricos = DonkiService:ObterCronologico()
local indiceHistorico = 1

local function obterProximoEventoDoDia(diaCalendario)
	while indiceHistorico <= #eventosHistoricos do
		local ev = eventosHistoricos[indiceHistorico]
		local diaEvento = ev.diaMaio or 8

		if diaEvento < diaCalendario then
			indiceHistorico += 1
		elseif diaEvento == diaCalendario then
			indiceHistorico += 1
			return ev
		else
			return nil
		end
	end
	return nil
end

while true do
	-- PHASE 1: Nominal Monitoring
	workspace:SetAttribute("EventoAtivo", "NENHUM")
	workspace:SetAttribute("Severidade", 0)
	pararOscilacaoLuzes()
	resetarTodosObjetivos()

	if abrigo then
		abrigo.Color = Color3.fromRGB(0, 170, 255)
	end

	local diaMissao = workspace:GetAttribute("DiaAtual") or 1
	local diaCalendario = 7 + diaMissao -- Day 1 = 2024-05-08 ... Day 8 = 2024-05-15
	local turnoEncerrado = workspace:GetAttribute("TurnoEncerrado")

	if turnoEncerrado then
		pintarTodosMonitores(COR_NORMAL)
		mon1.cabecalho.Text = "END OF SHIFT [18:00 UTC]"
		mon1.conteudo.Text = "Systems in standby mode.\nHead to the DORMITORY to advance to the next day."
		mon2.cabecalho.Text = string.format("DATE: 2024-05-%02d", diaCalendario)
		mon2.conteudo.Text = "Awaiting crew rest cycle..."
		mon3.cabecalho.Text = "NASA DONKI BULLETIN"
		mon3.conteudo.Text = "Shift ended. Next telemetry report at 06:00 UTC."
		task.wait(2)
		continue
	end

	pintarTodosMonitores(COR_NORMAL)
	mon1.cabecalho.Text = "BASE SYSTEMS"
	mon1.conteudo.Text = "Safety Mode: STANDBY\n(Available only during CME alerts)"
	mon2.cabecalho.Text = string.format("NASA DONKI [2024-05-%02d]", diaCalendario)
	mon2.conteudo.Text = "Historical Solar Monitoring Active"
	mon3.cabecalho.Text = "NASA DONKI BULLETIN"
	mon3.conteudo.Text = "Synchronized with NASA DONKI archive..."

	for _ = 1, 30 do
		if workspace:GetAttribute("TurnoEncerrado") then
			break
		end
		task.wait(1)
	end

	if workspace:GetAttribute("TurnoEncerrado") then
		continue
	end

	-- PHASE 2: Trigger next chronological historical event for the current date
	local evento = obterProximoEventoDoDia(diaCalendario)

	if not evento then
		if diaCalendario > 15 then
			mon2.conteudo.Text = "Historical sequence (May 08–15, 2024) complete!\nScientific mission accomplished."
		else
			mon2.conteudo.Text = string.format("No further NASA events on 2024-05-%02d.\nAwait end of shift (18:00 UTC).", diaCalendario)
		end
		task.wait(4)
		continue
	end

	workspace:SetAttribute("EventoAtivo", evento.tipo)
	workspace:SetAttribute("Severidade", evento.severidade)

	somAlerta:Play()

	local registroNASA = evento.dataHoraUTC or string.format("2024-05-%02d", diaCalendario)

	if evento.tipo == "FLR" then
		iniciarOscilacaoLuzes()

		if evento.severidade <= 2 then
			-- MODERATE (M-Class): Environmental lighting flicker & screen interference only
			mon1.cabecalho.Text = "⚡ POWER FLUCTUATION"
			mon1.conteudo.Text = "Minor grid interference detected.\nMain comms antenna nominal."
			mon2.cabecalho.Text = "⚡ MODERATE SOLAR FLARE"
			mon3.cabecalho.Text = "NASA ID: " .. (evento.id or registroNASA)
			mon3.conteudo.Text = string.format("[%s]\nElectromagnetic X-ray surge detected. Minor radio interference.", registroNASA)

			local duracaoLeve = 14
			for segundos = duracaoLeve, 0, -1 do
				local corRuido = (segundos % 2 == 0) and Color3.fromRGB(45, 55, 85) or Color3.fromRGB(25, 35, 60)
				pintarTodosMonitores(corRuido)
				mon2.conteudo.Text = string.format("M-Class Solar Flare\nUTC: %s\nSTABILIZING IN: %ds", registroNASA, segundos)
				task.wait(1)
			end

			pararOscilacaoLuzes()
			workspace:SetAttribute("EventoAtivo", "NENHUM")
			pintarTodosMonitores(COR_NORMAL)
			mon1.cabecalho.Text = "GRID STABILIZED"
			mon1.conteudo.Text = "Electrical systems nominal."
			mon2.cabecalho.Text = "✓ INTERFERENCE CLEARED"
			mon2.conteudo.Text = "Telemetry stabilized."
		else
			-- EXTREME (X-Class): Lighting flicker + Antenna damaged!
			promptAntena.Enabled = true
			alternarFaiscas(true)
			if somAntena then somAntena:Play() end

			local antenaConsertada = false
			local astronautaHeroi = nil

			local conexao = promptAntena.Triggered:Connect(function(player)
				antenaConsertada = true
				astronautaHeroi = player
			end)

			pintarTodosMonitores(COR_ALERTA_EXTREMO)
			mon1.cabecalho.Text = "⚠ URGENT OBJECTIVE [FLR]"
			mon1.conteudo.Text = "Climb to the roof and recalibrate the COMMS ANTENNA!"
			mon2.cabecalho.Text = "⚠ EXTREME SOLAR FLARE"
			mon3.cabecalho.Text = "NASA ID: " .. (evento.id or registroNASA)
			mon3.conteudo.Text = string.format("[%s]\nIntense X-class radiation burst. Immediate risk of total radio blackout.", registroNASA)

			local duracaoFLR = math.max(25, evento.tempoAviso)
			for segundos = duracaoFLR, 0, -1 do
				if antenaConsertada then break end
				mon2.conteudo.Text = string.format("X-Class Solar Flare\nUTC: %s\nRADIO BLACKOUT IN: %ds", registroNASA, segundos)
				task.wait(1)
			end

			conexao:Disconnect()
			pararOscilacaoLuzes()
			resetarTodosObjetivos()
			workspace:SetAttribute("EventoAtivo", "NENHUM")

			if antenaConsertada then
				pintarTodosMonitores(COR_SUCESSO)
				mon1.cabecalho.Text = "ANTENNA RECALIBRATED"
				mon1.conteudo.Text = "Radio communications restored!"
				mon2.cabecalho.Text = "✓ OBJECTIVE COMPLETE"
				mon2.conteudo.Text = "Repaired by " .. (astronautaHeroi and astronautaHeroi.Name or "Astronaut")
			else
				pintarTodosMonitores(COR_ALERTA_EXTREMO)
				mon1.cabecalho.Text = "COMMS FAILURE"
				mon1.conteudo.Text = "The antenna suffered thermal overload."
				mon2.cabecalho.Text = "✖ RADIO BLACKOUT"
				mon2.conteudo.Text = "Time expired!"
			end
		end

	elseif evento.tipo == "SEP" then
		if abrigo then
			abrigo.Color = Color3.fromRGB(0, 255, 140)
		end
		pintarTodosMonitores(COR_ALERTA_RADIACAO)

		mon1.cabecalho.Text = "☢ RADIATION ALERT [SEP]"
		mon1.conteudo.Text = "ENTER THE RADIATION STORM SHELTER IMMEDIATELY!"
		mon2.cabecalho.Text = "☢ SOLAR ENERGETIC PARTICLES"
		mon3.cabecalho.Text = "NASA ID: " .. (evento.id or registroNASA)
		mon3.conteudo.Text = string.format("[%s]\nHigh-energy proton flux detected. Direct biological hazard outside shielded zones.", registroNASA)

		local duracaoSEP = math.max(25, evento.tempoAviso)
		for segundos = duracaoSEP, 0, -1 do
			mon2.conteudo.Text = string.format("Proton Radiation Storm\nUTC: %s\nSTORM DURATION: %ds", registroNASA, segundos)
			task.wait(1)
		end

		workspace:SetAttribute("EventoAtivo", "NENHUM")
		pintarTodosMonitores(COR_SUCESSO)
		mon1.cabecalho.Text = "PROTON FLUX NORMALIZED"
		mon1.conteudo.Text = "Safe to exit the storm shelter."
		mon2.cabecalho.Text = "✓ STORM DISSIPATED"
		mon2.conteudo.Text = "Radiation levels nominal."

	elseif evento.tipo == "CME" then
		local modoSegurancaAtivo = false
		local astronautaHeroi = nil

		promptCME.Enabled = true
		local conexaoCME = promptCME.Triggered:Connect(function(player)
			modoSegurancaAtivo = true
			astronautaHeroi = player
			promptCME.Enabled = false
		end)

		pintarTodosMonitores(COR_ALERTA_RADIACAO)
		mon1.cabecalho.Text = "☄ CME ALERT"
		mon1.conteudo.Text = "[HOLD E ON MONITOR 1]\nEngage SAFETY MODE before plasma impact!"
		mon2.cabecalho.Text = "☄ CORONAL MASS EJECTION"
		mon3.cabecalho.Text = "NASA ID: " .. (evento.id or registroNASA)
		mon3.conteudo.Text = string.format("[%s]\nMassive magnetized plasma cloud inbound. Retract solar arrays and engage shielding.", registroNASA)

		local duracaoCME = math.max(20, evento.tempoAviso)
		for segundos = duracaoCME, 0, -1 do
			if modoSegurancaAtivo then
				mon1.fundo.BackgroundColor3 = COR_SUCESSO
				mon1.cabecalho.Text = "✓ SAFETY MODE ENGAGED"
				mon1.conteudo.Text = "Arrays retracted! Standing by for plasma cloud passage..."
			end
			mon2.conteudo.Text = string.format("Plasma Wave Inbound\nUTC: %s\nIMPACT IN: %ds", registroNASA, segundos)
			task.wait(1)
		end

		conexaoCME:Disconnect()
		promptCME.Enabled = false

		workspace:SetAttribute("ImpactoCME", true)

		if modoSegurancaAtivo then
			pintarTodosMonitores(COR_SUCESSO)
			mon1.cabecalho.Text = "IMPACT ABSORBED"
			mon1.conteudo.Text = "Protected by " .. (astronautaHeroi and astronautaHeroi.Name or "Astronaut")
			mon2.cabecalho.Text = "✓ BASE INTACT"
			mon2.conteudo.Text = "Plasma wave dissipated with zero damage."
		else
			pintarTodosMonitores(COR_ALERTA_EXTREMO)
			mon1.cabecalho.Text = "✖ MAGNETIC OVERLOAD!"
			mon1.conteudo.Text = "Life support failing! Oxygen levels dropping!"
			mon2.cabecalho.Text = "✖ DIRECT CME IMPACT"
			mon2.conteudo.Text = "Rebooting generators in 10s..."
			workspace:SetAttribute("SobrecargaCME", true)
			task.wait(10)
			workspace:SetAttribute("SobrecargaCME", false)
		end

		workspace:SetAttribute("ImpactoCME", false)
		workspace:SetAttribute("EventoAtivo", "NENHUM")
	end

	task.wait(5)
end
