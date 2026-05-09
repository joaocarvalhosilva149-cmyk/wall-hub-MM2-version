--[[ Murder Mystery 2 - Complete GUI v1.0
Funcionalidades:
- Wallhack (Assassino/Sheriff/Faca)
- Radar de jogadores
- Auto Farm Coins (Magnetic com área ajustável)
- Mostrar área de coleta
- Anti-AFK
- Pulo extra e velocidade
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Variáveis principais
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- Configurações
local settings = {
    wallhack = true,
    showAssassin = true,
    showSheriff = true,
    showKnife = true,
    showGun = true,
    autoFarmCoins = true,
    magnetRange = 50,
    showMagnetArea = true,
    coinValue = 1,
    antiAFK = true,
    extraJump = true,
    speedBoost = false,
    speedValue = 20
}

local coinsCollected = 0
local friends = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MM2HackGUI"
gui.Parent = player:WaitForChild("PlayerGui")

-- Botão flutuante
local floatingBtn = Instance.new("ImageButton")
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
floatingBtn.Position = UDim2.new(0, 20, 0, 100)
floatingBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
floatingBtn.Image = "rbxassetid://3926305904"
floatingBtn.ImageColor3 = Color3.fromRGB(255, 50, 100)
floatingBtn.Visible = false
floatingBtn.Parent = gui

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(1, 0)
floatingCorner.Parent = floatingBtn

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 550)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 2
border.BorderColor3 = Color3.fromRGB(255, 50, 100)
border.Parent = mainFrame

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔪 MM2 Esmeralda HUB v1.0"
title.TextColor3 = Color3.fromRGB(255, 50, 100)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 100)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

-- ScrollFrame para botões
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 330, 0, 420)
scrollFrame.Position = UDim2.new(0.5, -165, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
scrollFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 8)
uiList.Parent = scrollFrame

-- Função para criar botões
local function criarBotao(texto, cor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 310, 0, 40)
    btn.BackgroundColor3 = cor
    btn.Text = texto
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Função para criar slider
local function criarSlider(texto, min, max, valorInicial, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 310, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scrollFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = Color3.fromRGB(0, 255, 200)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valorLabel = Instance.new("TextLabel")
    valorLabel.Size = UDim2.new(0, 40, 0, 20)
    valorLabel.Position = UDim2.new(1, -45, 0, 5)
    valorLabel.BackgroundTransparency = 1
    valorLabel.Text = tostring(valorInicial)
    valorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valorLabel.TextSize = 11
    valorLabel.Font = Enum.Font.GothamBold
    valorLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, 280, 0, 5)
    sliderBg.Position = UDim2.new(0.5, -140, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((valorInicial - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 12, 0, 12)
    sliderBtn.Position = UDim2.new((valorInicial - min) / (max - min), -6, 0.5, -6)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    sliderBtn.Text = ""
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Parent = sliderBg
    
    local dragging = false
    
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local p = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            local valor = min + (p * (max - min))
            valor = math.floor(valor)
            valorLabel.Text = tostring(valor)
            sliderFill.Size = UDim2.new(p, 0, 1, 0)
            sliderBtn.Position = UDim2.new(p, -6, 0.5, -6)
            callback(valor)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Criar botões toggle
local btnWallhack = criarBotao("👁️ Wallhack: ATIVADO", Color3.fromRGB(0, 100, 80), function()
    settings.wallhack = not settings.wallhack
    btnWallhack.Text = settings.wallhack and "👁️ Wallhack: ATIVADO" or "👁️ Wallhack: DESATIVADO"
    btnWallhack.BackgroundColor3 = settings.wallhack and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
end)

local btnAutoFarm = criarBotao("💰 Auto Farm Coins: ATIVADO", Color3.fromRGB(0, 100, 80), function()
    settings.autoFarmCoins = not settings.autoFarmCoins
    btnAutoFarm.Text = settings.autoFarmCoins and "💰 Auto Farm Coins: ATIVADO" or "💰 Auto Farm Coins: DESATIVADO"
    btnAutoFarm.BackgroundColor3 = settings.autoFarmCoins and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
end)

local btnMostrarArea = criarBotao("🔲 Mostrar Área Magnética: ATIVADO", Color3.fromRGB(0, 100, 80), function()
    settings.showMagnetArea = not settings.showMagnetArea
    btnMostrarArea.Text = settings.showMagnetArea and "🔲 Mostrar Área Magnética: ATIVADO" or "🔲 Mostrar Área Magnética: DESATIVADO"
    btnMostrarArea.BackgroundColor3 = settings.showMagnetArea and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
end)

local btnAntiAFK = criarBotao("💤 Anti-AFK: ATIVADO", Color3.fromRGB(0, 100, 80), function()
    settings.antiAFK = not settings.antiAFK
    btnAntiAFK.Text = settings.antiAFK and "💤 Anti-AFK: ATIVADO" or "💤 Anti-AFK: DESATIVADO"
    btnAntiAFK.BackgroundColor3 = settings.antiAFK and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
end)

local btnExtraJump = criarBotao("🦘 Pulo Extra: ATIVADO", Color3.fromRGB(0, 100, 80), function()
    settings.extraJump = not settings.extraJump
    btnExtraJump.Text = settings.extraJump and "🦘 Pulo Extra: ATIVADO" or "🦘 Pulo Extra: DESATIVADO"
    btnExtraJump.BackgroundColor3 = settings.extraJump and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
    if settings.extraJump then
        hum.UseJumpPower = true
        hum.JumpPower = 80
    else
        hum.JumpPower = 50
    end
end)

local btnSpeed = criarBotao("⚡ Velocidade Boost: DESATIVADO", Color3.fromRGB(80, 40, 40), function()
    settings.speedBoost = not settings.speedBoost
    btnSpeed.Text = settings.speedBoost and "⚡ Velocidade Boost: ATIVADO" or "⚡ Velocidade Boost: DESATIVADO"
    btnSpeed.BackgroundColor3 = settings.speedBoost and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(80, 40, 40)
    if settings.speedBoost then
        hum.WalkSpeed = settings.speedValue
    else
        hum.WalkSpeed = 16
    end
end)

-- Sliders
criarSlider("📡 Alcance do Ímã (1-100)", 1, 100, settings.magnetRange, function(valor)
    settings.magnetRange = valor
end)

criarSlider("🪙 Valor da Moeda (1-1000)", 1, 1000, settings.coinValue, function(valor)
    settings.coinValue = valor
end)

criarSlider("⚡ Velocidade (16-100)", 16, 100, settings.speedValue, function(valor)
    settings.speedValue = valor
    if settings.speedBoost then
        hum.WalkSpeed = settings.speedValue
    end
end)

-- Contador de moedas
local counterFrame = Instance.new("Frame")
counterFrame.Size = UDim2.new(0, 310, 0, 30)
counterFrame.Position = UDim2.new(0.5, -155, 0, 480)
counterFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
counterFrame.BackgroundTransparency = 0.3
counterFrame.Parent = mainFrame

local counterCorner = Instance.new("UICorner")
counterCorner.CornerRadius = UDim.new(0, 6)
counterCorner.Parent = counterFrame

local counterText = Instance.new("TextLabel")
counterText.Size = UDim2.new(1, -10, 1, -10)
counterText.Position = UDim2.new(0, 5, 0, 5)
counterText.BackgroundTransparency = 1
counterText.Text = "💰 Moedas coletadas: 0"
counterText.TextColor3 = Color3.fromRGB(255, 215, 0)
counterText.TextSize = 12
counterText.Font = Enum.Font.GothamBold
counterText.Parent = counterFrame

-- Sistema Magnético de Moedas
local function magnetizarMoedas()
    if not settings.autoFarmCoins then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local pos = rootPart.Position
    
    -- Mostrar área (círculo no chão)
    if settings.showMagnetArea then
        local areaCircle = Instance.new("Part")
        areaCircle.Shape = Enum.PartType.Cylinder
        areaCircle.Size = Vector3.new(settings.magnetRange * 2, 0.2, settings.magnetRange * 2)
        areaCircle.Position = pos - Vector3.new(0, 3, 0)
        areaCircle.Anchored = true
        areaCircle.CanCollide = false
        areaCircle.Transparency = 0.8
        areaCircle.Color = Color3.fromRGB(0, 255, 200)
        areaCircle.Material = Enum.Material.Neon
        areaCircle.Parent = workspace
        
        task.delay(0.1, function()
            areaCircle:Destroy()
        end)
    end
    
    -- Procurar moedas
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money")) then
            local distancia = (pos - obj.Position).Magnitude
            
            if distancia <= settings.magnetRange then
                -- Teleportar moeda para o jogador
                local bf = Instance.new("BodyPosition")
                bf.MaxForce = Vector3.new(4000, 4000, 4000)
                bf.P = 3000
                bf.D = 100
                bf.Position = pos
                bf.Parent = obj
                
                -- Criar efeito visual
                local trail = Instance.new("Trail")
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
                trail.Lifetime = 0.3
                trail.Parent = obj
                
                -- Coletar quando chegar perto
                task.spawn(function()
                    while obj and obj.Parent and (obj.Position - pos).Magnitude > 3 do
                        task.wait()
                        if not obj or not obj.Parent then break end
                    end
                    
                    if obj and obj.Parent then
                        -- Simular coleta
                        coinsCollected = coinsCollected + settings.coinValue
                        counterText.Text = "💰 Moedas coletadas: " .. coinsCollected
                        obj:Destroy()
                    end
                end)
            end
        end
    end
end

-- Wallhack
local function aplicarWallhack()
    if not settings.wallhack then return end
    
    for _, outros in ipairs(Players:GetPlayers()) do
        if outros ~= player then
            local outrosChar = outros.Character
            if outrosChar then
                for _, part in ipairs(outrosChar:GetDescendants()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("OriginalTransparency") then
                        -- Guardar transparência original
                        local origTrans = part.Transparency
                        part:SetAttribute("OriginalTransparency", origTrans)
                        
                        -- Destacar inimigos
                        if settings.showAssassin and (outrosChar:FindFirstChild("Murderer") or outros.Character:FindFirstChild("Knife")) then
                            part.Transparency = 0.3
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                            highlight.Parent = part
                        elseif settings.showSheriff and outrosChar:FindFirstChild("Gun") then
                            part.Transparency = 0.3
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(0, 0, 255)
                            highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                            highlight.Parent = part
                        end
                    end
                end
            end
        end
    end
    
    -- Destacar faca
    if settings.showKnife then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("knife") or obj.Name:lower():find("couteau") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.Parent = obj
            end
        end
    end
    
    -- Destacar arma do sheriff
    if settings.showGun then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("gun") or obj.Name:lower():find("revolver") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 0, 255)
                highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                highlight.Parent = obj
            end
        end
    end
end

-- Anti-AFK
local function iniciarAntiAFK()
    if not settings.antiAFK then return end
    
    local mousePos = mouse.X
    task.spawn(function()
        while settings.antiAFK do
            task.wait(240) -- 4 minutos
            if settings.antiAFK then
                -- Simular movimento do mouse
                local newPos = mouse.X + 1
                mouse.Move(newPos, mouse.Y)
                task.wait(0.1)
                mouse.Move(mousePos, mouse.Y)
                
                -- Pequeno movimento
                hum:MoveTo(char:GetPivot().Position + Vector3.new(1, 0, 0))
                task.wait(0.2)
                hum:MoveTo(char:GetPivot().Position)
            end
        end
    end)
end

-- Notificação
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 280, 0, 45)
notifFrame.Position = UDim2.new(1, -300, 0, 60)
notifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
notifFrame.BackgroundTransparency = 0.1
notifFrame.Visible = false
notifFrame.Parent = gui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notifFrame

local notifText = Instance.new("TextLabel")
notifText.Size = UDim2.new(1, -10, 1, -10)
notifText.Position = UDim2.new(0, 5, 0, 5)
notifText.BackgroundTransparency = 1
notifText.Text = ""
notifText.TextColor3 = Color3.fromRGB(255, 50, 100)
notifText.TextSize = 11
notifText.Font = Enum.Font.Gotham
notifText.Parent = notifFrame

local function mostrarNotificacao(msg)
    notifText.Text = msg
    notifFrame.Visible = true
    task.wait(2.5)
    notifFrame.Visible = false
end

-- Minimizar/Restaurar
local minimizado = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    mainFrame.Visible = not minimizado
    floatingBtn.Visible = minimizado
    
    if minimizado then
        mostrarNotificacao("📌 MM2 HUB Minimizado")
    else
        mostrarNotificacao("📂 MM2 HUB Restaurado")
    end
end)

floatingBtn.MouseButton1Click:Connect(function()
    minimizado = false
    mainFrame.Visible = true
    floatingBtn.Visible = false
    mostrarNotificacao("📂 Interface restaurada")
end)

-- Arrastar interface
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
        mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Arrastar botão flutuante
local floatDragging = false
local floatDragStart, floatFrameStart

floatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatDragging = true
        floatDragStart = input.Position
        floatFrameStart = floatingBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if floatDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - floatDragStart
        floatingBtn.Position = UDim2.new(floatFrameStart.X.Scale, floatFrameStart.X.Offset + delta.X, floatFrameStart.Y.Scale, floatFrameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then floatDragging = false end
end)

-- Loops principais
task.spawn(function()
    while true do
        aplicarWallhack()
        magnetizarMoedas()
        iniciarAntiAFK()
        task.wait(0.5)
    end
end)

-- Animação da borda
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            local t = 0.5 + math.sin(i * math.pi) * 0.5
            local cor = Color3.fromRGB(255 * (1 - t), 50 * t, 100 * t)
            border.BorderColor3 = cor
            if floatingBtn.Visible then
                floatingBtn.ImageColor3 = cor
            end
            task.wait(0.05)
        end
    end
end)

-- Inicialização
task.spawn(function()
    wait(1)
    mostrarNotificacao("🔪 MM2 Esmeralda HUB carregado!")
    mostrarNotificacao("💰 Sistema de ímã ativo - Alcance: " .. settings.magnetRange .. " unidades")
    mostrarNotificacao("💡 Use '[' e ']' para ajustar o alcance")
    
    -- Atalhos de teclado
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.LeftBracket then -- [
            settings.magnetRange = math.max(1, settings.magnetRange - 5)
            mostrarNotificacao("📡 Alcance: " .. settings.magnetRange)
        elseif input.KeyCode == Enum.KeyCode.RightBracket then -- ]
            settings.magnetRange = math.min(100, settings.magnetRange + 5)
            mostrarNotificacao("📡 Alcance: " .. settings.magnetRange)
        end
    end)
end)

print("✅ MM2 Esmeralda HUB v1.0 carregado!")
