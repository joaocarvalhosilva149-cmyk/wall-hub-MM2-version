--[[ SIMPLE COIN FARMER - Círculo magnético --]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Configurações
local alcance = 40  -- Tamanho do círculo
local coletando = true

-- Aguardar personagem
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")

-- Criar GUI simples
local gui = Instance.new("ScreenGui")
gui.Name = "CoinFarmer"
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.05
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "💰 FARM DE MOEDAS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Botão ligar/desligar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
toggleBtn.Text = "⚡ ATIVADO"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Contador
local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(1, 0, 0, 25)
counter.Position = UDim2.new(0, 0, 0, 75)
counter.BackgroundTransparency = 1
counter.Text = "💰 0 moedas"
counter.TextColor3 = Color3.fromRGB(255, 215, 0)
counter.TextSize = 11
counter.Font = Enum.Font.GothamBold
counter.Parent = frame

-- Variáveis
local moedasColetadas = 0
let circlePart = nil

-- Função para criar o círculo
local function criarCirculo()
    if circlePart then circlePart:Destroy() end
    
    circlePart = Instance.new("Part")
    circlePart.Shape = Enum.PartType.Cylinder
    circlePart.Size = Vector3.new(alcance * 2, 0.2, alcance * 2)
    circlePart.Position = rootPart.Position - Vector3.new(0, 3, 0)
    circlePart.Anchored = true
    circlePart.CanCollide = false
    circlePart.Transparency = 0.5
    circlePart.Color = Color3.fromRGB(255, 215, 0)
    circlePart.Material = Enum.Material.Neon
    circlePart.Parent = workspace
end

-- Função para detectar moedas
local function isCoin(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    
    local nome = string.lower(obj.Name or "")
    
    -- Nomes comuns de moedas
    local nomes = {"coin", "gold", "money", "moeda", "gem", "token", "crystal", "reward", "pickup", "chest"}
    
    for _, n in ipairs(nomes) do
        if nome:find(n) then
            return true
        end
    end
    
    -- Verificar cor
    if obj.BrickColor == BrickColor.new("Bright yellow") or 
       obj.BrickColor == BrickColor.new("Gold") then
        return true
    end
    
    return false
end

-- Função para coletar moedas
local function coletarMoedas()
    if not coletando then return end
    if not rootPart or not rootPart.Parent then return end
    
    local posicao = rootPart.Position
    
    -- Atualizar posição do círculo
    if circlePart then
        circlePart.Position = posicao - Vector3.new(0, 3, 0)
    end
    
    -- Procurar moedas
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isCoin(obj) and obj:IsA("BasePart") and obj.Parent ~= char then
            local distancia = (posicao - obj.Position).Magnitude
            
            if distancia <= alcance then
                -- Puxar moeda
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(100000, 100000, 100000)
                bv.Velocity = (posicao - obj.Position).Unit * 80
                bv.Parent = obj
                
                -- Coletar após 0.3 segundos
                task.spawn(function()
                    task.wait(0.3)
                    if obj and obj.Parent then
                        moedasColetadas = moedasColetadas + 1
                        counter.Text = "💰 " .. moedasColetadas .. " moedas"
                        obj:Destroy()
                    end
                end)
                
                -- Limpar BodyVelocity
                task.delay(0.5, function()
                    if bv then bv:Destroy() end
                end)
            end
        end
    end
end

-- Botão toggle
toggleBtn.MouseButton1Click:Connect(function()
    coletando = not coletando
    if coletando then
        toggleBtn.Text = "⚡ ATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
        if circlePart then circlePart.Transparency = 0.5 end
    else
        toggleBtn.Text = "⏸️ DESATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        if circlePart then circlePart.Transparency = 1 end
    end
end)

-- Arrastar UI
local dragging = false
local dragStart, frameStart

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Loop principal
task.spawn(function()
    criarCirculo()
    
    while true do
        coletarMoedas()
        task.wait(0.3)
    end
end)

-- Recriar círculo se necessário
task.spawn(function()
    while true do
        task.wait(0.5)
        if rootPart and rootPart.Parent then
            if not circlePart or not circlePart.Parent then
                criarCirculo()
            end
        end
    end
end)

-- Atualizar quando o personagem renascer
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    criarCirculo()
    print("🔄 Personagem recarregado!")
end)

print("✅ Script carregado - Círculo magnético ativado!")
print("💡 Círculo dourado ao redor do personagem")
print("💰 Todas as moedas dentro do círculo serão puxadas!")
