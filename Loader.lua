--[[ MM2 AUTO FARM COINS - Versão Simplificada e Funcional --]]

local Players = game:GetService("Services")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações
local ativo = true
local magnetRange = 50
local coinValue = 1
local mostrarArea = true
local coinsCollected = 0

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- Função para detectar moedas (completa)
local function isCoin(obj)
    if not obj or not obj.Name then return false end
    
    local nome = string.lower(obj.Name)
    
    -- Lista completa de nomes de moedas
    local coinNames = {
        "coin", "coins", "gold", "money", "moeda", "moedas", "doubloon",
        "token", "gem", "crystal", "reward", "pickup", "collectible",
        "coinpart", "coinmesh", "goldcoin", "goldbar", "diamond",
        "emerald", "ruby", "sapphire", "coinpickup", "moneybag",
        "bronze", "silver", "chestcoin", "bagcoin", "pouch"
    }
    
    for _, coinName in ipairs(coinNames) do
        if nome:find(coinName) then
            return true
        end
    end
    
    -- Verificar por cor (moedas geralmente são amarelas/douradas)
    if obj:IsA("BasePart") and obj.Size.X < 3 and obj.Size.Y < 3 and obj.Size.Z < 3 then
        local cor = obj.BrickColor
        if cor == BrickColor.new("Bright yellow") or 
           cor == BrickColor.new("Gold") or
           cor == BrickColor.new("New Yeller") or
           cor == BrickColor.new("Really yellow") then
            return true
        end
    end
    
    return false
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmCoins"
gui.Parent = player:WaitForChild("PlayerGui")

-- Botão flutuante (quando minimizado)
local floatingBtn = Instance.new("ImageButton")
floatingBtn.Size = UDim2.new(0, 50, 0, 50)
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
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 2
border.BorderColor3 = Color3.fromRGB(255, 215, 0)
border.Parent = mainFrame

-- Barra de título (para arrastar e minimizar)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💰 AUTO FARM COINS v1.0"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = titleBar

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

-- Botão Ativar/Desativar
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 260, 0, 45)
toggleBtn.Position = UDim2.new(0.5, -130, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
toggleBtn.Text = "🟢 FARM ATIVADO"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Slider de alcance
local rangeSlider = Instance.new("Frame")
rangeSlider.Size = UDim2.new(0, 260, 0, 55)
rangeSlider.Position = UDim2.new(0.5, -130, 0, 110)
rangeSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
rangeSlider.BackgroundTransparency = 0.5
rangeSlider.Parent = mainFrame

local rangeCorner = Instance.new("UICorner")
rangeCorner.CornerRadius = UDim.new(0, 6)
rangeCorner.Parent = rangeSlider

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(1, -10, 0, 20)
rangeLabel.Position = UDim2.new(0, 5, 0, 5)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "📡 Alcance do Ímã"
rangeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
rangeLabel.TextSize = 11
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = rangeSlider

local rangeValue = Instance.new("TextLabel")
rangeValue.Size = UDim2.new(0, 45, 0, 20)
rangeValue.Position = UDim2.new(1, -50, 0, 5)
rangeValue.BackgroundTransparency = 1
rangeValue.Text = tostring(magnetRange) .. "m"
rangeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeValue.TextSize = 11
rangeValue.Font = Enum.Font.GothamBold
rangeValue.Parent = rangeSlider

local rangeBg = Instance.new("Frame")
rangeBg.Size = UDim2.new(0, 200, 0, 5)
rangeBg.Position = UDim2.new(0.5, -100, 0, 35)
rangeBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
rangeBg.BorderSizePixel = 0
rangeBg.Parent = rangeSlider

local rangeBgCorner = Instance.new("UICorner")
rangeBgCorner.CornerRadius = UDim.new(1, 0)
rangeBgCorner.Parent = rangeBg

local p = (magnetRange - 10) / 90
local rangeFill = Instance.new("Frame")
rangeFill.Size = UDim2.new(p, 0, 1, 0)
rangeFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
rangeFill.BorderSizePixel = 0
rangeFill.Parent = rangeBg

local rangeBtn = Instance.new("TextButton")
rangeBtn.Size = UDim2.new(0, 12, 0, 12)
rangeBtn.Position = UDim2.new(p, -6, 0.5, -6)
rangeBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
rangeBtn.Text = ""
rangeBtn.BorderSizePixel = 0
rangeBtn.Parent = rangeBg

-- Slider de valor da moeda
local valueSlider = Instance.new("Frame")
valueSlider.Size = UDim2.new(0, 260, 0, 55)
valueSlider.Position = UDim2.new(0.5, -130, 0, 175)
valueSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
valueSlider.BackgroundTransparency = 0.5
valueSlider.Parent = mainFrame

local valueCorner = Instance.new("UICorner")
valueCorner.CornerRadius = UDim.new(0, 6)
valueCorner.Parent = valueSlider

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1, -10, 0, 20)
valueLabel.Position = UDim2.new(0, 5, 0, 5)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "🪙 Valor por Moeda"
valueLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
valueLabel.TextSize = 11
valueLabel.Font = Enum.Font.GothamBold
valueLabel.TextXAlignment = Enum.TextXAlignment.Left
valueLabel.Parent = valueSlider

local valueAmount = Instance.new("TextLabel")
valueAmount.Size = UDim2.new(0, 45, 0, 20)
valueAmount.Position = UDim2.new(1, -50, 0, 5)
valueAmount.BackgroundTransparency = 1
valueAmount.Text = tostring(coinValue) .. "x"
valueAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
valueAmount.TextSize = 11
valueAmount.Font = Enum.Font.GothamBold
valueAmount.Parent = valueSlider

local valueBg = Instance.new("Frame")
valueBg.Size = UDim2.new(0, 200, 0, 5)
valueBg.Position = UDim2.new(0.5, -100, 0, 35)
valueBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
valueBg.BorderSizePixel = 0
valueBg.Parent = valueSlider

local valueBgCorner = Instance.new("UICorner")
valueBgCorner.CornerRadius = UDim.new(1, 0)
valueBgCorner.Parent = valueBg

local p2 = (coinValue - 1) / 999
local valueFill = Instance.new("Frame")
valueFill.Size = UDim2.new(p2, 0, 1, 0)
valueFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
valueFill.BorderSizePixel = 0
valueFill.Parent = valueBg

local valueBtn = Instance.new("TextButton")
valueBtn.Size = UDim2.new(0, 12, 0, 12)
valueBtn.Position = UDim2.new(p2, -6, 0.5, -6)
valueBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
valueBtn.Text = ""
valueBtn.BorderSizePixel = 0
valueBtn.Parent = valueBg

-- Botão Mostrar Área
local areaBtn = Instance.new("TextButton")
areaBtn.Size = UDim2.new(0, 260, 0, 38)
areaBtn.Position = UDim2.new(0.5, -130, 0, 240)
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
local counterFrame = Instance.new("Frame")
counterFrame.Size = UDim2.new(0, 260, 0, 45)
counterFrame.Position = UDim2.new(0.5, -130, 0, 290)
counterFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
counterFrame.BackgroundTransparency = 0.5
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

-- Slider drag functions
local rangeDrag = false
rangeBtn.MouseButton1Down:Connect(function() rangeDrag = true end)

local valueDrag = false
valueBtn.MouseButton1Down:Connect(function() valueDrag = true end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if rangeDrag then
            local pos = input.Position.X - rangeBg.AbsolutePosition.X
            local p = math.clamp(pos / rangeBg.AbsoluteSize.X, 0, 1)
            local valor = math.floor(10 + (p * 90))
            magnetRange = valor
            rangeValue.Text = tostring(valor) .. "m"
            rangeFill.Size = UDim2.new(p, 0, 1, 0)
            rangeBtn.Position = UDim2.new(p, -6, 0.5, -6)
        elseif valueDrag then
            local pos = input.Position.X - valueBg.AbsolutePosition.X
            local p = math.clamp(pos / valueBg.AbsoluteSize.X, 0, 1)
            local valor = math.floor(1 + (p * 999))
            coinValue = valor
            valueAmount.Text = tostring(valor) .. "x"
            valueFill.Size = UDim2.new(p, 0, 1, 0)
            valueBtn.Position = UDim2.new(p, -6, 0.5, -6)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        rangeDrag = false
        valueDrag = false
    end
end)

-- Botão toggle do farm
toggleBtn.MouseButton1Click:Connect(function()
    ativo = not ativo
    if ativo then
        toggleBtn.Text = "🟢 FARM ATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
        notify("✅ Auto Farm ATIVADO!")
    else
        toggleBtn.Text = "🔴 FARM DESATIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        notify("❌ Auto Farm DESATIVADO!")
    end
end)

-- Botão mostrar área
areaBtn.MouseButton1Click:Connect(function()
    mostrarArea = not mostrarArea
    areaBtn.Text = mostrarArea and "🔲 Mostrar Área: ATIVADO" or "🔲 Mostrar Área: DESATIVADO"
    areaBtn.BackgroundColor3 = mostrarArea and Color3.fromRGB(0, 100, 80) or Color3.fromRGB(60, 40, 40)
    notify(mostrarArea and "🔲 Área visível!" or "🔲 Área oculta!")
end)

-- Sistema de coleta de moedas
task.spawn(function()
    while true do
        if ativo and char and char:FindFirstChild("HumanoidRootPart") then
            local rootPart = char.HumanoidRootPart
            local pos = rootPart.Position
            
            -- Mostrar área
            if mostrarArea then
                local area = Instance.new("Part")
                area.Shape = Enum.PartType.Cylinder
                area.Size = Vector3.new(magnetRange * 2, 0.2, magnetRange * 2)
                area.Position = pos - Vector3.new(0, 3, 0)
                area.Anchored = true
                area.CanCollide = false
                area.Transparency = 0.7
                area.Color = Color3.fromRGB(255, 215, 0)
                area.Material = Enum.Material.Neon
                area.Parent = workspace
                task.delay(0.2, function() area:Destroy() end)
            end
            
            -- Procurar moedas
            for _, obj in ipairs(workspace:GetDescendants()) do
                if isCoin(obj) and obj:IsA("BasePart") and obj.Parent ~= char then
                    local dist = (pos - obj.Position).Magnitude
                    
                    if dist <= magnetRange then
                        -- Puxar moeda
                        local bodyVel = obj:FindFirstChild("MagnetVel")
                        if not bodyVel then
                            bodyVel = Instance.new("BodyVelocity")
                            bodyVel.Name = "MagnetVel"
                            bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                            bodyVel.Velocity = (pos - obj.Position).Unit * 70
                            bodyVel.Parent = obj
                            
                            -- Efeito de luz
                            local light = Instance.new("PointLight")
                            light.Color = Color3.fromRGB(255, 215, 0)
                            light.Range = 5
                            light.Brightness = 2
                            light.Parent = obj
                            
                            task.spawn(function()
                                task.wait(0.8)
                                if obj and obj.Parent and (pos - obj.Position).Magnitude <= 5 then
                                    coinsCollected = coinsCollected + coinValue
                                    counterText.Text = "💰 Moedas coletadas: " .. coinsCollected
                                    obj:Destroy()
                                    if math.random(1, 5) == 1 then
                                        notify("💰 +" .. coinValue .. " moedas!")
                                    end
                                end
                            end)
                            
                            task.delay(1, function()
                                if bodyVel then bodyVel:Destroy() end
                                if light then light:Destroy() end
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- Notificações
local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 250, 0, 40)
notifFrame.Position = UDim2.new(1, -270, 0, 60)
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
notifText.TextColor3 = Color3.fromRGB(255, 215, 0)
notifText.TextSize = 11
notifText.Font = Enum.Font.Gotham
notifText.Parent = notifFrame

function notify(msg)
    notifText.Text = msg
    notifFrame.Visible = true
    task.wait(2)
    notifFrame.Visible = false
end

-- Minimizar/Restaurar
local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Visible = not minimized
    floatingBtn.Visible = minimized
    
    if minimized then
        notify("📌 Minimizado")
    else
        notify("📂 Restaurado")
    end
end)

floatingBtn.MouseButton1Click:Connect(function()
    minimized = false
    mainFrame.Visible = true
    floatingBtn.Visible = false
    notify("📂 Interface restaurada")
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
        mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
        floatingBtn.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then floatDragging = false end
end)

-- Animação da borda
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            local t = 0.5 + math.sin(i * math.pi) * 0.5
            local cor = Color3.fromRGB(255, 215 * (1 - t), 0)
            border.BorderColor3 = cor
            if floatingBtn.Visible then
                floatingBtn.ImageColor3 = cor
            end
            task.wait(0.05)
        end
    end
end)

-- Inicialização
notify("💰 Auto Farm Coins carregado!")
notify("🎯 Coleta TODAS as moedas automaticamente!")
notify("💡 Use o botão − para minimizar")

print("✅ Auto Farm Coins v1.0 - Simplificado e Funcional!")
