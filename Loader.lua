--[[ 
   SIMPLE COIN FARMER MM2 - VERSÃO FUNCIONAL
   Círculo magnético que coleta todas as moedas automaticamente
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== CONFIGURAÇÕES =====
local alcance = 45
local coletando = true
local moedasColetadas = 0

-- ===== AGUARDAR PERSONAGEM =====
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- ===== CRIAR GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinFarmer"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💰 FARM DE MOEDAS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Botão ligar/desligar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -50, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
toggleBtn.Text = "🔴 ATIVADO"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Contador
local counterText = Instance.new("TextLabel")
counterText.Size = UDim2.new(1, 0, 0, 25)
counterText.Position = UDim2.new(0, 0, 0, 75)
counterText.BackgroundTransparency = 1
counterText.Text = "💰 Moedas: 0"
counterText.TextColor3 = Color3.fromRGB(255, 215, 0)
counterText.TextSize = 11
counterText.Font = Enum.Font.GothamBold
counterText.Parent = mainFrame

-- ===== FUNÇÃO PARA DETECTAR MOEDAS =====
local function isCoin(objeto)
    if not objeto or not objeto.Parent then return false end
    if not objeto:IsA("BasePart") then return false end
    
    local nome = string.lower(objeto.Name or "")
    
    -- Lista de nomes de moedas
    local padroes = {
        "coin", "gold", "money", "moeda", "gem", "token", 
        "crystal", "reward", "pickup", "chest", "doubloon",
        "bronze", "silver", "diamond", "emerald", "ruby"
    }
    
    for _, padrao in ipairs(padroes) do
        if string.find(nome, padrao) then
            return true
        end
    end
    
    -- Verificar por cor amarela/dourada
    if objeto:IsA("BasePart") and objeto.Size.Magnitude < 5 then
        local cor = objeto.BrickColor
        if cor == BrickColor.new("Bright yellow") or 
           cor == BrickColor.new("Gold") or
           cor == BrickColor.new("New Yeller") then
            return true
        end
    end
    
    return false
end

-- ===== CRIAR CÍRCULO =====
local circlePart = nil

local function criarCirculo()
    if circlePart then
        circlePart:Destroy()
    end
    
    circlePart = Instance.new("Part")
    circlePart.Name = "MagnetCircle"
    circlePart.Shape = Enum.PartType.Cylinder
    circlePart.Size = Vector3.new(alcance * 2, 0.2, alcance * 2)
    circlePart.Position = rootPart.Position - Vector3.new(0, 3, 0)
    circlePart.Anchored = true
    circlePart.CanCollide = false
    circlePart.Transparency = 0.4
    circlePart.Color = Color3.fromRGB(255, 200, 0)
    circlePart.Material = Enum.Material.Neon
    circlePart.Parent = workspace
end

-- ===== SISTEMA DE COLETA =====
local function coletarMoedas()
    if not coletando then return end
    if not rootPart or not rootPart.Parent then return end
    
    local posicao = rootPart.Position
    
    -- Atualizar posição do círculo
    if circlePart and circlePart.Parent then
        circlePart.Position = posicao - Vector3.new(0, 3, 0)
    end
    
    -- Procurar moedas
    for _, objeto in ipairs(workspace:GetDescendants()) do
        if isCoin(objeto) and objeto:IsA("BasePart") then
            -- Evitar coletar partes do próprio personagem
            if objeto.Parent == char then continue end
            
            local distancia = (posicao - objeto.Position).Magnitude
            
            if distancia <= alcance then
                -- Criar força para puxar a moeda
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                bodyVelocity.Velocity = (posicao - objeto.Position).Unit * 70
                bodyVelocity.Parent = objeto
                
                -- Efeito visual (rastro)
                local trail = Instance.new("Trail")
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
                trail.Lifetime = 0.2
                trail.Parent = objeto
                
                -- Coletar após 0.4 segundos
                task.spawn(function()
                    task.wait(0.4)
                    if objeto and objeto.Parent then
                        moedasColetadas = moedasColetadas + 1
                        counterText.Text = "💰 Moedas: " .. moedasColetadas
                        objeto:Destroy()
                    end
                end)
                
                -- Limpar os efeitos
                task.delay(0.6, function()
                    if bodyVelocity then bodyVelocity:Destroy() end
                    if trail then trail:Destroy() end
                end)
            end
        end
    end
end

-- ===== BOTÃO LIGAR/DESLIGAR =====
toggleBtn.MouseButton1Click:Connect(function()
    coletando = not coletando
    if coletando then
        toggleBtn.Text = "🟢 ATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        if circlePart then
            circlePart.Transparency = 0.4
        end
    else
        toggleBtn.Text = "🔴 DESATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if circlePart then
            circlePart.Transparency = 1
        end
    end
end)

-- ===== ARRASTAR INTERFACE =====
local dragging = false
local dragStart, frameStart

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, 
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, 
            frameStart.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===== LOOP PRINCIPAL =====
task.spawn(function()
    while true do
        coletarMoedas()
        task.wait(0.2)
    end
end)

-- ===== MANTER CÍRCULO =====
task.spawn(function()
    while true do
        if rootPart and rootPart.Parent then
            if not circlePart or not circlePart.Parent then
                criarCirculo()
            end
        end
        task.wait(1)
    end
end)

-- ===== RECONECTAR QUANDO MORRER =====
player.CharacterAdded:Connect(function(novoChar)
    task.wait(0.5)
    char = novoChar
    hum = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    criarCirculo()
    print("✅ Personagem recarregado - Continuando farm!")
end)

-- ===== INICIAR =====
criarCirculo()

-- Mensagem de confirmação
print("========================================")
print("💰 SIMPLE COIN FARMER - CARREGADO!")
print("========================================")
print("✅ Círculo dourado ao redor do personagem")
print("✅ Coletando todas as moedas automaticamente")
print("✅ Use o botão na tela para ligar/desligar")
print("========================================")
