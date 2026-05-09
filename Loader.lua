--[[ Murder Mystery 2 - Script Corrigido e Funcional v3.0 --]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Configurações
local settings = {
    wallhack = false,
    autoFarm = false,
    showArea = false,
    antiAFK = false,
    extraJump = false,
    speedBoost = false,
    magnetRange = 30,
    coinValue = 1,
    speedValue = 20
}

local coinsCollected = 0
local antiAFKRunning = false
local wallhackObjects = {}

-- Função para atualizar personagem
local function getChar()
    char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    return char, hum
end

getChar()
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    getChar()
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MM2Hub"
gui.Parent = player:WaitForChild("PlayerGui")

-- Botão flutuante
local floatingBtn = Instance.new("ImageButton")
floatingBtn.Size = UDim2.new(0, 45, 0, 45)
floatingBtn.Position = UDim2.new(0, 10, 0, 100)
floatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
floatingBtn.Image = "rbxassetid://3926305904"
floatingBtn.ImageColor3 = Color3.fromRGB(255, 50, 100)
floatingBtn.Visible = false
floatingBtn.Parent = gui

local floatingCorner = Instance.new("UICorner")
floatingCorner.CornerRadius = UDim.new(1, 0)
floatingCorner.Parent = floatingBtn

-- Frame principal (tamanho correto)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 480)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -240)
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
border.BorderColor3 = Color3.fromRGB(255, 50, 100)
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
title.Text = "🔪 MM2 HUB v3.0"
title.TextColor3 = Color3.fromRGB(255, 50, 100)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 3)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 50, 100)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 260, 0, 390)
scrollFrame.Position = UDim2.new(0.5, -130, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 8)
uiList.Parent = scrollFrame

-- Função para criar botões toggle
local function createToggle(text, settingName, colorOn, defaultColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 38)
    btn.Position = UDim2.new(0.5, -120, 0, 0)
    btn.BackgroundColor3 = settings[settingName] and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(60, 40, 40)
    btn.Text = text .. ": " .. (settings[settingName] and "✅ ATIVADO" or "❌ DESATIVADO")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        btn.Text = text .. ": " .. (settings[settingName] and "✅ ATIVADO" or "❌ DESATIVADO")
        btn.BackgroundColor3 = settings[settingName] and Color3.fromRGB(0, 120, 80) or Color3.fromRGB(60, 40, 40)
        
        -- Ações específicas
        if settingName == "extraJump" and hum then
            hum.JumpPower = settings[settingName] and 80 or 50
        elseif settingName == "speedBoost" and hum then
            hum.WalkSpeed = settings[settingName] and settings.speedValue or 16
        elseif settingName == "autoFarm" then
            notify(settings[settingName] and "💰 Auto Farm ATIVADO" or "💰 Auto Farm DESATIVADO")
        elseif settingName == "antiAFK" then
            if settings[settingName] then
                startAntiAFK()
            end
            notify(settings[settingName] and "💤 Anti-AFK ATIVADO" or "💤 Anti-AFK DESATIVADO")
        end
    end)
    
    return btn
end

-- Função para criar slider
local function createSlider(text, min, max, settingName, unit)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 55)
    frame.Position = UDim2.new(0.5, -120, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = scrollFrame
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 6)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(0, 255, 200)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 45, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(settings[settingName]) .. (unit or "")
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, 200, 0, 5)
    sliderBg.Position = UDim2.new(0.5, -100, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local p = (settings[settingName] - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(p, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 12, 0, 12)
    sliderBtn.Position = UDim2.new(p, -6, 0.5, -6)
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
            local value = math.floor(min + (p * (max - min)))
            settings[settingName] = value
            valueLabel.Text = tostring(value) .. (unit or "")
            sliderFill.Size = UDim2.new(p, 0, 1, 0)
            sliderBtn.Position = UDim2.new(p, -6, 0.5, -6)
            
            if settingName == "speedValue" and settings.speedBoost and hum then
                hum.WalkSpeed = value
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Criar botões
createToggle("👁️ Wallhack", "wallhack")
createToggle("💰 Auto Farm", "autoFarm")
createToggle("🔲 Mostrar Área", "showArea")
createToggle("💤 Anti-AFK", "antiAFK")
createToggle("🦘 Pulo Extra", "extraJump")
createToggle("⚡ Velocidade Boost", "speedBoost")

-- Sliders
createSlider("📡 Alcance Magnético", 10, 100, "magnetRange", "m")
createSlider("🪙 Valor por Moeda", 1, 1000, "coinValue", "x")
createSlider("⚡ Velocidade", 16, 100, "speedValue", "")

-- Contador
local counterFrame = Instance.new("Frame")
counterFrame.Size = UDim2.new(0, 240, 0, 35)
counterFrame.Position = UDim2.new(0.5, -120, 0, 0)
counterFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
counterFrame.BackgroundTransparency = 0.5
counterFrame.Parent = scrollFrame

local counterCorner = Instance.new("UICorner")
counterCorner.CornerRadius = UDim.new(0, 6)
counterCorner.Parent = counterFrame

local counterText = Instance.new("TextLabel")
counterText.Size = UDim2.new(1, -10, 1, -10)
counterText.Position = UDim2.new(0, 5, 0, 5)
counterText.BackgroundTransparency = 1
counterText.Text = "💰 Moedas: 0"
counterText.TextColor3 = Color3.fromRGB(255, 215, 0)
counterText.TextSize = 12
counterText.Font = Enum.Font.GothamBold
counterText.Parent = counterFrame

-- Sistema Anti-AFK
function startAntiAFK()
    if antiAFKRunning then return end
    antiAFKRunning = true
    
    task.spawn(function()
        while settings.antiAFK and hum do
            task.wait(240)
            if settings.antiAFK and hum then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local origPos = root.Position
                    root.CFrame = root.CFrame + Vector3.new(0.5, 0, 0)
                    task.wait(0.1)
                    root.CFrame = root.CFrame - Vector3.new(0.5, 0, 0)
                end
            end
        end
        antiAFKRunning = false
    end)
end

-- Sistema de Ímã para Moedas
task.spawn(function()
    while true do
        if settings.autoFarm and char and char:FindFirstChild("HumanoidRootPart") then
            local rootPart = char.HumanoidRootPart
            local pos = rootPart.Position
            
            -- Mostrar área
            if settings.showArea then
                local area = Instance.new("Part")
                area.Shape = Enum.PartType.Cylinder
                area.Size = Vector3.new(settings.magnetRange * 2, 0.2, settings.magnetRange * 2)
                area.Position = pos - Vector3.new(0, 3, 0)
                area.Anchored = true
                area.CanCollide = false
                area.Transparency = 0.7
                area.Color = Color3.fromRGB(0, 255, 200)
                area.Material = Enum.Material.Neon
                area.Parent = workspace
                task.delay(0.2, function() area:Destroy() end)
            end
            
            -- Procurar moedas
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("gold")) then
                    local dist = (pos - obj.Position).Magnitude
                    if dist <= settings.magnetRange then
                        -- Puxar moeda
                        local bodyVel = Instance.new("BodyVelocity")
                        bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                        bodyVel.Velocity = (pos - obj.Position).Unit * 50
                        bodyVel.Parent = obj
                        
                        task.spawn(function()
                            task.wait(0.5)
                            if obj and obj.Parent then
                                local newDist = (pos - obj.Position).Magnitude
                                if newDist <= 5 then
                                    coinsCollected = coinsCollected + settings.coinValue
                                    counterText.Text = "💰 Moedas: " .. coinsCollected
                                    obj:Destroy()
                                    notify("💰 +" .. settings.coinValue .. " moedas!")
                                end
                            end
                            if bodyVel then bodyVel:Destroy() end
                        end)
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Sistema de Wallhack
task.spawn(function()
    while true do
        if settings.wallhack then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("knife") then
                    local hl = obj:FindFirstChild("WallhackHighlight")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "WallhackHighlight"
                        hl.FillColor = Color3.fromRGB(255, 255, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                        hl.Parent = obj
                    end
                end
            end
            
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    for _, part in ipairs(otherPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local hl = part:FindFirstChild("WallhackHighlight")
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "WallhackHighlight"
                                if otherPlayer.Character:FindFirstChild("Murderer") or otherPlayer.Character:FindFirstChild("Knife") then
                                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                                elseif otherPlayer.Character:FindFirstChild("Gun") then
                                    hl.FillColor = Color3.fromRGB(0, 0, 255)
                                else
                                    hl.FillColor = Color3.fromRGB(255, 255, 255)
                                end
                                hl.OutlineColor = hl.FillColor
                                hl.Parent = part
                            end
                        end
                    end
                end
            end
        else
            -- Limpar highlights
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "WallhackHighlight" then
                    obj:Destroy()
                end
            end
        end
        task.wait(0.5)
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
notifText.TextColor3 = Color3.fromRGB(255, 50, 100)
notifText.TextSize = 11
notifText.Font = Enum.Font.Gotham
notifText.Parent = notifFrame

function notify(msg)
    notifText.Text = msg
    notifFrame.Visible = true
    task.wait(2)
    notifFrame.Visible = false
end

-- Minimizar
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    mainFrame.Visible = not minimized
    floatingBtn.Visible = minimized
    notify(minimized and "📌 Minimizado" or "📂 Restaurado")
end)

floatingBtn.MouseButton1Click:Connect(function()
    minimized = false
    mainFrame.Visible = true
    floatingBtn.Visible = false
    notify("📂 Interface restaurada")
end)

-- Arrastar UI
local dragStart, frameStart, dragging = nil, nil, false
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

-- Animação
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            local t = 0.5 + math.sin(i * math.pi) * 0.5
            local cor = Color3.fromRGB(255 * (1 - t), 50, 100 * t)
            border.BorderColor3 = cor
            if floatingBtn.Visible then
                floatingBtn.ImageColor3 = cor
            end
            task.wait(0.05)
        end
    end
end)

-- Inicialização
notify("🔪 MM2 HUB v3.0 carregado!")
notify("✅ Todos os botões funcionam!")
notify("💰 Ative o Auto Farm para coletar moedas")

print("✅ Script corrigido carregado!")
