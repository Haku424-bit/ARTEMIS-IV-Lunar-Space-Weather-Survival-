-- StarterGui/HudStatus/PainelStatus/LocalScript

local painel = script.Parent
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local COR_CRITICA = Color3.fromRGB(235, 45, 45)
local COR_FUNDO_BARRA = Color3.fromRGB(14, 22, 38)

local status = {
	Fome = 100,
	Oxigenio = 100,
	Blindagem = 100
}

local elementos = {
	Fome = {
		fundo = painel:WaitForChild("FundoFome"),
		barra = painel.FundoFome:WaitForChild("Barra"),
		texto = painel.FundoFome:WaitForChild("TextLabel"),
		nome = "HUNGRY",
		corNormal = Color3.fromRGB(255, 145, 0)
	},

	Oxigenio = {
		fundo = painel:WaitForChild("FundoOxigenio"),
		barra = painel.FundoOxigenio:WaitForChild("Barra"),
		texto = painel.FundoOxigenio:WaitForChild("TextLabel"),
		nome = "OXYGEN",
		corNormal = Color3.fromRGB(0, 195, 255)
	},

	Blindagem = {
		fundo = painel:WaitForChild("FundoBlindagem"),
		barra = painel.FundoBlindagem:WaitForChild("Barra"),
		texto = painel.FundoBlindagem:WaitForChild("TextLabel"),
		nome = "RADIATION",
		corNormal = Color3.fromRGB(40, 215, 100)
	}
}

-- Configuração visual das barras

for _, ui in pairs(elementos) do

	ui.fundo.BackgroundColor3 = COR_FUNDO_BARRA
	ui.fundo.BackgroundTransparency = 0.15
	ui.fundo.ClipsDescendants = true

	local layoutInterno = ui.fundo:FindFirstChildOfClass("UIListLayout")

	if layoutInterno then
		layoutInterno:Destroy()
	end

	local cornerFundo = ui.fundo:FindFirstChildOfClass("UICorner")
	local raio = cornerFundo and cornerFundo.CornerRadius or UDim.new(0, 8)

	if not cornerFundo then
		cornerFundo = Instance.new("UICorner")
		cornerFundo.CornerRadius = raio
		cornerFundo.Parent = ui.fundo
	end

	local cornerBarra = ui.barra:FindFirstChildOfClass("UICorner")

	if not cornerBarra then
		cornerBarra = Instance.new("UICorner")
		cornerBarra.Parent = ui.barra
	end

	cornerBarra.CornerRadius = raio

	if ui.texto.Parent == ui.barra then
		ui.texto.Parent = ui.fundo
	end

	ui.texto.Size = UDim2.new(1, 0, 1, 0)
	ui.texto.Position = UDim2.new(0, 0, 0, 0)
	ui.texto.BackgroundTransparency = 1
	ui.texto.Font = Enum.Font.Code
	ui.texto.TextColor3 = Color3.fromRGB(240, 248, 255)
	ui.texto.TextStrokeTransparency = 0.4
	ui.texto.ZIndex = 3

	ui.barra.AnchorPoint = Vector2.new(0, 0)
	ui.barra.Position = UDim2.new(0, 0, 0, 0)
	ui.barra.BackgroundTransparency = 0
	ui.barra.ZIndex = 2
end

local tweenInfo = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

-- Atualiza a interface usando somente os dados do servidor

local function atualizarHUD()

	local eventoAtual = workspace:GetAttribute("EventoAtivo")
	local emInterferencia = eventoAtual == "FLR"

	for chave, ui in pairs(elementos) do

		local valor = player:GetAttribute(chave)

		if typeof(valor) == "number" then
			status[chave] = math.clamp(valor, 0, 100)
		end

		local valorAtual = status[chave]

		local tamanhoAlvo = UDim2.new(valorAtual / 100, 0, 1, 0)

		TweenService:Create(
			ui.barra,
			tweenInfo,
			{Size = tamanhoAlvo}
		):Play()

		if emInterferencia then

			ui.texto.Text = string.format(
				"%s: [SINAL PERDIDO]",
				ui.nome
			)

			ui.barra.BackgroundColor3 = Color3.fromRGB(110, 120, 135)

		else

			ui.texto.Text = string.format(
				"%s: %d%%",
				ui.nome,
				math.floor(valorAtual)
			)

			ui.barra.BackgroundColor3 =
				(valorAtual <= 25)
				and COR_CRITICA
				or ui.corNormal

		end
	end
end

-- Recebe atualizações dos Attributes do servidor

for atributo in pairs(elementos) do

	player:GetAttributeChangedSignal(atributo):Connect(function()
		atualizarHUD()
	end)

end

-- Também atualiza quando o evento global mudar

workspace:GetAttributeChangedSignal("EventoAtivo"):Connect(function()
	atualizarHUD()
end)

-- Primeira atualização

atualizarHUD()
