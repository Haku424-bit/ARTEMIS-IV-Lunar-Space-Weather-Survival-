-- ServerScriptService/DonkiService (ModuleScript)
local HttpService = game:GetService("HttpService")

local DonkiService = {}

local BASE_URL = "https://ccmc.gsfc.nasa.gov/DONKI-API/get"
local INICIO_PADRAO = "2024-05-08"
local FIM_PADRAO = "2024-05-15"

-- Cache em memória para não repetir chamadas HTTP desnecessárias
local cacheEventos = nil
local jaCarregou = false

-- Função auxiliar para extrair o dia de maio (8 a 15) de uma string ISO "2024-05-08T05:09Z"
local function extrairDiaMaio(timestampStr)
	if type(timestampStr) == "string" and #timestampStr >= 10 then
		return tonumber(string.sub(timestampStr, 9, 10)) or 8
	end
	return 8
end

-- DADOS DE FALLBACK (Eventos reais em ordem cronológica da supertempestade de Maio/2024)
local FALLBACK_EVENTOS = {
	{
		tipo = "FLR",
		id = "2024-05-08T05:09:00-FLR-001",
		dataHoraUTC = "2024-05-08T05:09Z",
		diaMaio = 8,
		titulo = "Clarão Solar Extremo (X1.0)",
		severidade = 3,
		dadoPrincipal = "Classe X1.0",
		tempoAviso = 20,
		descricao = "Explosão de raios-X da região AR3664 atingindo a órbita. Risco imediato de blecaute nas comunicações de rádio."
	},
	{
		tipo = "CME",
		id = "2024-05-08T12:24:00-CME-001",
		dataHoraUTC = "2024-05-08T12:24Z",
		diaMaio = 8,
		titulo = "Ejeção de Massa Coronal (CME)",
		severidade = 2,
		dadoPrincipal = "Velocidade: 828 km/s",
		tempoAviso = 30,
		descricao = "Primeira nuvem de plasma solar da sequência viajando em direção à Terra/Lua. Ative o Modo de Segurança."
	},
	{
		tipo = "CME",
		id = "2024-05-10T18:24:00-CME-001",
		dataHoraUTC = "2024-05-10T18:24Z",
		diaMaio = 10,
		titulo = "CME Ultra-Rápida em Rota de Colisão",
		severidade = 3,
		dadoPrincipal = "Velocidade: ~1.800 km/s",
		tempoAviso = 35,
		descricao = "Nuvem massiva de plasma solar viajando em altíssima velocidade. Prepare os escudos magnéticos e painéis."
	},
	{
		tipo = "SEP",
		id = "2024-05-13T09:50:00-SEP-001",
		dataHoraUTC = "2024-05-13T09:50Z",
		diaMaio = 13,
		titulo = "Tempestade de Partículas Energéticas (SEP)",
		severidade = 3,
		dadoPrincipal = "Prótons de Alta Energia",
		tempoAviso = 25,
		descricao = "Fluxo intenso de prótons acelerados. Ameaça biológica direta aos astronautas fora de áreas blindadas."
	},
	{
		tipo = "FLR",
		id = "2024-05-14T16:46:00-FLR-001",
		dataHoraUTC = "2024-05-14T16:46Z",
		diaMaio = 14,
		titulo = "Clarão Solar Extremo (X8.7)",
		severidade = 3,
		dadoPrincipal = "Classe X8.7",
		tempoAviso = 15,
		descricao = "Maior explosão solar do ciclo! Recalibre os sistemas de comunicação imediatamente."
	}
}

-- Função interna para requisição HTTP segura
local function buscarEndpoint(tipo, inicio, fim)
	local url = string.format("%s/%s?startDate=%s&endDate=%s", BASE_URL, tipo, inicio, fim)

	local ok, resposta = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if not ok then
		warn("[DonkiService] Falha HTTP em " .. tipo .. ": " .. tostring(resposta))
		return nil
	end

	local okJson, dados = pcall(function()
		return HttpService:JSONDecode(resposta)
	end)
	if not okJson or type(dados) ~= "table" then
		warn("[DonkiService] JSON inválido em " .. tipo)
		return nil
	end

	return dados
end

-- Normaliza Clarões Solares (filtra apenas M e X)
local function processarFLR(listaBruta, destino)
	if not listaBruta then return end
	for _, item in ipairs(listaBruta) do
		local classe = item.classType or ""
		local letra = string.sub(classe, 1, 1)
		if letra == "M" or letra == "X" then
			local ehExtrema = (letra == "X")
			local timestamp = item.beginTime or item.peakTime or string.sub(item.flrID or "2024-05-08T00:00Z", 1, 16)
			table.insert(destino, {
				tipo = "FLR",
				id = item.flrID or "FLR-DESCONHECIDO",
				dataHoraUTC = timestamp,
				diaMaio = extrairDiaMaio(timestamp),
				titulo = ehExtrema and ("Clarão Solar Extremo (" .. classe .. ")") or ("Clarão Solar Moderado (" .. classe .. ")"),
				severidade = ehExtrema and 3 or 2,
				dadoPrincipal = "Classe " .. classe,
				tempoAviso = ehExtrema and 15 or 20,
				descricao = "Radiação eletromagnética viajando na velocidade da luz. Recalibre os sistemas de comunicação imediatamente."
			})
		end
	end
end

-- Normaliza Partículas Energéticas Solares (SEP)
local function processarSEP(listaBruta, destino)
	if not listaBruta then return end
	for _, item in ipairs(listaBruta) do
		local timestamp = item.eventTime or string.sub(item.sepID or "2024-05-08T00:00Z", 1, 16)
		table.insert(destino, {
			tipo = "SEP",
			id = item.sepID or "SEP-DESCONHECIDO",
			dataHoraUTC = timestamp,
			diaMaio = extrairDiaMaio(timestamp),
			titulo = "Alerta de Radiação de Prótons (SEP)",
			severidade = 3,
			dadoPrincipal = "Evento " .. timestamp,
			tempoAviso = 25,
			descricao = "Partículas energéticas solares detectadas. Ative a blindagem antirradiação ou recolha a tripulação para o abrigo."
		})
	end
end

-- Normaliza Ejeções de Massa Coronal (pega velocidade da análise mais relevante)
local function processarCME(listaBruta, destino)
	if not listaBruta then return end
	for _, item in ipairs(listaBruta) do
		local velocidade = 0
		if type(item.cmeAnalyses) == "table" then
			for _, analise in ipairs(item.cmeAnalyses) do
				if analise.speed and analise.speed > velocidade then
					velocidade = analise.speed
				end
			end
		end

		-- Filtra apenas CMEs rápidas (> 700 km/s) que representam perigo real
		if velocidade >= 700 then
			local sev = velocidade >= 1200 and 3 or 2
			local timestamp = item.startTime or string.sub(item.activityID or "2024-05-08T00:00Z", 1, 16)
			table.insert(destino, {
				tipo = "CME",
				id = item.activityID or "CME-DESCONHECIDO",
				dataHoraUTC = timestamp,
				diaMaio = extrairDiaMaio(timestamp),
				titulo = sev == 3 and "CME Ultra-Rápida em Rota de Colisão" or "Ejeção de Massa Coronal Detectada",
				severidade = sev,
				dadoPrincipal = string.format("Velocidade: %d km/s", math.floor(velocidade)),
				tempoAviso = 35,
				descricao = "Nuvem de plasma solar magnetizado se aproximando. Ajuste a orientação dos painéis solares e escudos."
			})
		end
	end
end

-- Normaliza Tempestades Geomagnéticas (lê o maior índice Kp registrado)
local function processarGST(listaBruta, destino)
	if not listaBruta then return end
	for _, item in ipairs(listaBruta) do
		local maiorKp = 0
		if type(item.allKpIndex) == "table" then
			for _, registroKp in ipairs(item.allKpIndex) do
				if registroKp.kpIndex and registroKp.kpIndex > maiorKp then
					maiorKp = registroKp.kpIndex
				end
			end
		end

		if maiorKp >= 5 then
			local sev = maiorKp >= 8 and 3 or 2
			local timestamp = item.startTime or string.sub(item.gstID or "2024-05-10T00:00Z", 1, 16)
			table.insert(destino, {
				tipo = "GST",
				id = item.gstID or "GST-DESCONHECIDO",
				dataHoraUTC = timestamp,
				diaMaio = extrairDiaMaio(timestamp),
				titulo = string.format("Tempestade Geomagnética (Kp %d)", maiorKp),
				severidade = sev,
				dadoPrincipal = "Índice Kp: " .. tostring(maiorKp),
				tempoAviso = 30,
				descricao = "Perturbação severa no campo magnético. Risco de sobrecarga elétrica e perda de telemetria orbital."
			})
		end
	end
end

-- Função principal chamada pelo servidor do jogo
function DonkiService:CarregarEventos(inicio, fim)
	if jaCarregou and cacheEventos then
		return cacheEventos
	end

	inicio = inicio or INICIO_PADRAO
	fim = fim or FIM_PADRAO

	local eventosOrganizados = {}

	-- Busca os 4 fenômenos escolhidos
	local flrDados = buscarEndpoint("FLR", inicio, fim)
	local sepDados = buscarEndpoint("SEP", inicio, fim)
	local cmeDados = buscarEndpoint("CME", inicio, fim)
	local gstDados = buscarEndpoint("GST", inicio, fim)

	processarFLR(flrDados, eventosOrganizados)
	processarSEP(sepDados, eventosOrganizados)
	processarCME(cmeDados, eventosOrganizados)
	processarGST(gstDados, eventosOrganizados)

	-- Se a API falhar ou vier vazia, usa o fallback garantido
	if #eventosOrganizados == 0 then
		warn("[DonkiService] Usando eventos de FALLBACK da tempestade de Maio/2024.")
		cacheEventos = FALLBACK_EVENTOS
	else
		-- Ordena todos os eventos em ordem cronológica exata (08/05 -> 15/05/2024)
		table.sort(eventosOrganizados, function(a, b)
			return (a.dataHoraUTC or "") < (b.dataHoraUTC or "")
		end)
		print(string.format("[DonkiService] Sucesso! %d eventos reais ordenados cronologicamente.", #eventosOrganizados))
		cacheEventos = eventosOrganizados
	end

	jaCarregou = true
	return cacheEventos
end

-- Retorna todos os eventos jogáveis (FLR, SEP, CME) em ordem cronológica (08/05 a 15/05/2024)
function DonkiService:ObterCronologico()
	local lista = self:CarregarEventos()
	local cronologicos = {}
	for _, ev in ipairs(lista) do
		if ev.tipo == "FLR" or ev.tipo == "SEP" or ev.tipo == "CME" then
			table.insert(cronologicos, ev)
		end
	end
	return cronologicos
end

-- Sorteia um evento pronto para virar missão no jogo
function DonkiService:SortearEvento()
	local lista = self:CarregarEventos()
	local indice = math.random(1, #lista)
	return lista[indice]
end

-- Filtra eventos por um tipo específico ("FLR", "SEP", "CME" ou "GST")
function DonkiService:ObterPorTipo(tipoDesejado)
	local lista = self:CarregarEventos()
	local filtrados = {}
	for _, ev in ipairs(lista) do
		if ev.tipo == tipoDesejado then
			table.insert(filtrados, ev)
		end
	end
	return #filtrados > 0 and filtrados or lista
end

return DonkiService
