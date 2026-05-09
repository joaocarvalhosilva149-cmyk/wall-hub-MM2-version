--[[ 
███╗   ███╗███╗   ███╗██████╗     █████╗ ██╗   ██╗████████╗ ██████╗     ███████╗ █████╗ ██████╗ ███╗   ███╗
████╗ ████║████╗ ████║██╔══██╗   ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔════╝██╔══██╗██╔══██╗████╗ ████║
██╔████╔██║██╔████╔██║██████╔╝   ███████║██║   ██║   ██║   ██║   ██║    █████╗  ███████║██████╔╝██╔████╔██║
██║╚██╔╝██║██║╚██╔╝██║██╔══██╗   ██╔══██║██║   ██║   ██║   ██║   ██║    ██╔══╝  ██╔══██║██╔══██╗██║╚██╔╝██║
██║ ╚═╝ ██║██║ ╚═╝ ██║██████╔╝   ██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║
╚═╝     ╚═╝╚═╝     ╚═╝╚═════╝    ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ===== CONFIGURAÇÕES =====
local ativo = true
local alcance = 50
local valorMoeda = 1
local mostrarArea = true
local moedasColetadas = 0

-- ===== VARIÁVEIS =====
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local gui = nil
local mainFrame = nil
local floatingBtn = nil

-- ===== FUNÇÃO PARA DETECTAR MOEDAS =====
local function isCoin(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    
    local nome = string.lower(obj.Name or "")
    
    -- Lista de nomes de moedas
    local nomesMoeda = {
        "coin", "coins", "gold", "money", "moeda", "moedas", "doubloon",
        "token", "gem", "crystal", "reward", "pickup", "collect",
        "coinpart", "coinmesh", "goldcoin", "goldbar", "diamond",
        "emerald", "ruby", "sapphire", "bronze", "silver", "chest"
    }
    
    for _, nomePadrao in ipairs(nomesMoeda) do
        if nome:find(nomePadrao) then
            return true
        end
    end
    
    -- Verifica por cor dourada/amarela
    if obj:IsA("BasePart") and obj.Size.Magnitude < 5 then
        local cor = obj.BrickColor
        if cor == BrickColor.new("Bright yellow") or 
           cor == BrickColor.new("Gold") or
           cor == BrickColor.new("New Yeller") then
            return true
        end
    end
    
    return false
end

-- ===== SISTEMA DE COLETA =====
local function coletarMoedas()
    if not ativo then return end
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = char.HumanoidRootPart
    local posicao = rootPart.Position
    
    -- Mostrar área
    if mostrarArea then
        local circle = Instance.new("Part")
        circle.Shape = Enum.PartType.Cylinder
        circle.Size = Vector3.new(alcance * 2, 0.2, alcance * 2)
        circle.Position = posicao - Vector3.new(0, 3, 0)
        circle.Anchored = true
        circle.CanCollide = false
        circle.Transparency = 0.6
        circle.Color = Color3.fromRGB(255, 215, 0)
        circle.Material = Enum.Material.Neon
        circle.Parent = workspace
        game:GetService("Debris"):AddItem(circle, 0.3)
    end
    
    -- Procurar moedas
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isCoin(obj) and obj:IsA("BasePart") and obj.Parent ~= char then
            local distancia = (posicao - obj.Position).Magnitude
            
            if distancia <= alcance then
                -- Criar BodyVelocity para puxar a moeda
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(10000, 10000, 10000)
                bv.Velocity = (posicao - obj.Position).Unit * 60
                bv.Parent = obj
                
                -- Efeito visual
                local trail = Instance.new("Trail")
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
                trail.Lifetime = 0.3
                trail.Parent = obj
                
                -- Coletar após 0.5 segundos
                task.spawn(function()
                    task.wait(0.5)
                    if obj and obj.Parent then
                        moedasColetadas = moedasColetadas + valorMoeda
                        obj:Destroy()
                        
                        -- Atualizar contador na GUI se existir
                        if gui and gui:FindFirstChild("Counter") then
                            gui.Counter.Text = "💰 Moedas: " .. moedasColetadas
                        end
                    end
                end)
                
                -- Limpar após 1 segundo
                task.delay(1, function()
                    if bv then bv:Destroy() end
                    if trail then trail:Destroy() end
                end)
            end
        end
    end
end

-- ===== CRIAR GUI =====
local function criarGUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "CoinFarmer"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Botão flutuante
    floatingBtn = Instance.new("ImageButton")
    floatingBtn.Size = UDim2.new(0, 45, 0, 45)
    floatingBtn.Position = UDim2.new(0, 10, 0, 100)
    floatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    floatingBtn.Image = "rbxassetid://3926305904"
    floatingBtn.ImageColor3 = Color3.fromRGB(255, 215, 0)
    floatingBtn.Visible = false
    floatingBtn.Parent = gui
    
    local floatingCorner = Instance.new("UICorner")
    floatingCorner.CornerRadius = UDim.new(1, 0)
    floatingCorner.Parent = floatingBtn
    
    -- Frame principal
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    -- Borda animada
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 2
    border.BorderColor3 = Color3.fromRGB(255, 215, 0)
    border.Parent = mainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "💰 AUTO FARM COINS"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 13
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Parent = titleBar
    
    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 3)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = titleBar
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    -- Botão ligar/desligar
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 240, 0, 45)
    toggleBtn.Position = UDim2.new(0.5, -120, 0, 50)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
    toggleBtn.Text = "🟢 FARM ATIVADO"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    -- Informação de alcance
    local rangeFrame = Instance.new("Frame")
    rangeFrame.Size = UDim2.new(0, 240, 0, 50)
    rangeFrame.Position = UDim2.new(0.5, -120, 0, 110)
    rangeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    rangeFrame.BackgroundTransparency = 0.5
    rangeFrame.Parent = mainFrame
    
    local rangeCorner = Instance.new("UICorner")
    rangeCorner.CornerRadius = UDim.new(0, 6)
    rangeCorner.Parent = rangeFrame
    
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(1, -10, 0, 20)
    rangeLabel.Position = UDim2.new(0, 5, 0, 5)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Text = "📡 Alcance: " .. alcance .. "m"
    rangeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    rangeLabel.TextSize = 11
    rangeLabel.Font = Enum.Font.GothamBold
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rangeLabel.Parent = rangeFrame
    
    -- Botões + e - para alcance
    local rangeDown = Instance.new("TextButton")
    rangeDown.Size = UDim2.new(0, 30, 0, 25)
    rangeDown.Position = UDim2.new(0, 5, 0, 20)
    rangeDown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    rangeDown.Text = "-"
    rangeDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeDown.TextSize = 16
    rangeDown.Font = Enum.Font.GothamBold
    rangeDown.Parent = rangeFrame
    
    local rangeDownCorner = Instance.new("UICorner")
    rangeDownCorner.CornerRadius = UDim.new(0, 4)
    rangeDownCorner.Parent = rangeDown
    
    local rangeValue = Instance.new("TextLabel")
    rangeValue.Size = UDim2.new(0, 50, 0, 25)
    rangeValue.Position = UDim2.new(0.5, -25, 0, 20)
    rangeValue.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    rangeValue.Text = tostring(alcance)
    rangeValue.TextColor3 = Color3.fromRGB(255, 215, 0)
    rangeValue.TextSize = 13
    rangeValue.Font = Enum.Font.GothamBold
    rangeValue.Parent = rangeFrame
    
    local rangeValueCorner = Instance.new("UICorner")
    rangeValueCorner.CornerRadius = UDim.new(0, 4)
    rangeValueCorner.Parent = rangeValue
    
    local rangeUp = Instance.new("TextButton")
    rangeUp.Size = UDim2.new(0, 30, 0, 25)
    rangeUp.Position = UDim2.new(1, -35, 0, 20)
    rangeUp.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    rangeUp.Text = "+"
    rangeUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeUp.TextSize = 16
    rangeUp.Font = Enum.Font.GothamBold
    rangeUp.Parent = rangeFrame
    
    local rangeUpCorner = Instance.new("UICorner")
    rangeUpCorner.CornerRadius = UDim.new(0, 4)
    rangeUpCorner.Parent = rangeUp
    
    -- Informação de valor da moeda
    local valueFrame = Instance.new("Frame")
    valueFrame.Size = UDim2.new(0, 240, 0, 50)
    valueFrame.Position = UDim2.new(0.5, -120, 0, 170)
    valueFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    valueFrame.BackgroundTransparency = 0.5
    valueFrame.Parent = mainFrame
    
    local valueCorner = Instance.new("UICorner")
    valueCorner.CornerRadius = UDim.new(0, 6)
    valueCorner.Parent = valueFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -10, 0, 20)
    valueLabel.Position = UDim2.new(0, 5, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "🪙 Valor por moeda: " .. valorMoeda .. "x"
    valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = valueFrame
    
    -- Botões + e - para valor
    local valueDown = Instance.new("TextButton")
    valueDown.Size = UDim2.new(0, 30, 0, 25)
    valueDown.Position = UDim2.new(0, 5, 0, 20)
    valueDown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    valueDown.Text = "-"
    valueDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueDown.TextSize = 16
    valueDown.Font = Enum.Font.GothamBold
    valueDown.Parent = valueFrame
    
    local valueDownCorner = Instance.new("UICorner")
    valueDownCorner.CornerRadius = UDim.new(0, 4)
    valueDownCorner.Parent = valueDown
    
    local valueAmount = Instance.new("TextLabel")
    valueAmount.Size = UDim2.new(0, 50, 0, 25)
    valueAmount.Position = UDim2.new(0.5, -25, 0, 20)
    valueAmount.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    valueAmount.Text = tostring(valorMoeda)
    valueAmount.TextColor3 = Color3.fromRGB(255, 215, 0)
    valueAmount.TextSize = 13
    valueAmount.Font = Enum.Font.GothamBold
    valueAmount.Parent = valueFrame
    
    local valueAmountCorner = Instance.new("UICorner")
    valueAmountCorner.CornerRadius = UDim.new(0, 4)
    valueAmountCorner.Parent = valueAmount
    
    local valueUp = Instance.new("TextButton")
    valueUp.Size = UDim2.new(0, 30, 0, 25)
    valueUp.Position = UDim2.new(1, -35, 0, 20)
    valueUp.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    valueUp.Text = "+"
    valueUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueUp.TextSize = 16
    valueUp.Font = Enum.Font.GothamBold
    valueUp.Parent = valueFrame
    
    local valueUpCorner = Instance.new("UICorner")
    valueUpCorner.CornerRadius = UDim.new(0, 4)
    valueUpCorner.Parent = valueUp
    
    -- Botão mostrar área
    local areaBtn = Instance.new("TextButton")
    areaBtn.Size = UDim2.new(0, 240, 0, 38)
    areaBtn.Position = UDim2.new(0.5, -120, 0, 230)
    areaBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
    areaBtn.Text = "🔲 Mostrar Área: ATIVADO"
    areaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    areaBtn.TextSize = 12
    areaBtn.Font = Enum.Font.GothamSemibold
    areaBtn.Parent = mainFrame
    
    local areaCorner = Instance.new("UICorner")
    areaCorner.CornerRadius = UDim.new(0, 6)
    areaCorner.Parent = areaBtn
    
    -- Contador
    local counter = Instance.new("TextLabel")
    counter.Name = "Counter"
    counter.Size = UDim2.new(0, 240, 0, 35)
    counter.Position = UDim2.new(0.5, -120, 0, 280)
    counter.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    counter.BackgroundTransparency = 0.5
    counter.Text = "💰 Moedas: 0"
    counter.TextColor3 = Color3.fromRGB(255, 215, 0)
    counter.TextSize = 12
    counter.Font = Enum.Font.GothamBold
    counter.Parent = mainFrame
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 6)
    counterCorner.Parent = counter
    
    -- ===== FUNÇÕES DOS BOTÕES =====
    toggleBtn.MouseButton1Click:Connect(function()
        ativo = not ativo
        if ativo then
            toggleBtn.Text = "🟢 FARM ATIVADO"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
        else
            toggleBtn.Text = "🔴 FARM DESATIVADO"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        end
    end)
    
    rangeDown.MouseButton1Click:Connect(function()
        alcance = math.max(10, alcance - 5)
        rangeLabel.Text = "📡 Alcance: " .. alcance .. "m"
        rangeValue.Text = tostring(alcance)
    end)
    
    rangeUp.MouseButton1Click:Connect(function()
        alcance = math.min(100, alcance + 5)
        rangeLabel.Text = "📡 Alcance: " .. alcance .. "m"
        rangeValue.Text = tostring(alcance)
    end)
    
    valueDown.MouseButton1Click:Connect(function()
        valorMoeda = math.max(1, valorMoeda - 1)
        valueLabel.Text = "🪙 Valor por moeda: " .. valorMoeda .. "x"
        valueAmount.Text = tostring(valorMoeda)
    end)
    
    valueUp.MouseButton1Click:Connect(function()
        valorMoeda = math.min(1000, valorMoeda + 1)
        valueLabel.Text = "🪙 Valor por moeda: " .. valorMoeda .. "x"
        valueAmount.Text = tostring(valorMoeda)
    end)
    
    areaBtn.MouseButton1Click:Connect(function()
        mostrarArea = not mostrarArea
        areaBtn.Text = mostrarArea and "🔲 Mostrar Área: ATIVADO" or "🔲 Mostrar Área: DESATIVADO"
        areaBtn.BackgroundColor3 = mostrarArea and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(60, 40, 40)
    end)
    
    -- Minimizar
    local minimizado = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimizado = not minimizado
        mainFrame.Visible = not minimizado
        floatingBtn.Visible = minimizado
    end)
    
    floatingBtn.MouseButton1Click:Connect(function()
        minimizado = false
        mainFrame.Visible = true
        floatingBtn.Visible = false
    end)
    
    -- Arrastar UI
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
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
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Arrastar botão flutuante
    local floatDragging = false
    floatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = true
            dragStart = input.Position
            frameStart = floatingBtn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            floatingBtn.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            floatDragging = false
        end
    end)
    
    -- Animação da borda
    task.spawn(function()
        while true do
            for i = 0, 1, 0.05 do
                local t = 0.5 + math.sin(i * math.pi) * 0.5
                border.BorderColor3 = Color3.fromRGB(255, 215 * (1 - t), 0)
                if floatingBtn.Visible then
                    floatingBtn.ImageColor3 = border.BorderColor3
                end
                task.wait(0.05)
            end
        end
    end)
end

-- ===== LOOP PRINCIPAL =====
local function iniciarLoop()
    task.spawn(function()
        while true do
            coletarMoedas()
            task.wait(0.3)
        end
    end)
end

-- ===== INICIALIZAR =====
pcall(function()
    criarGUI()
    iniciarLoop()
    print("✅ AUTO FARM COINS - Script carregado com sucesso!")
    print("💰 Coletando moedas automaticamente!")
end)

-- Reconectar quando o personagem renascer
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    task.wait(1)
    print("✅ Personagem recarregado - Continuando farm!")
end)
