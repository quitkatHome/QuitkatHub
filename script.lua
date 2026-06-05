-- QuitkatHub - Script otimizado com ESP persistente
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local rodandoColeta = false
local mostrandoJogadores = false
local highlights = {}

-- Função para encontrar o ovo mais próximo
local function getOvoMaisProximo(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end

    local eggsFolder = workspace.Ignore.Easter2026.Eggs
    local maisProximo, menorDist = nil, math.huge

    for _, egg in ipairs(eggsFolder:GetChildren()) do
        if egg:IsA("BasePart") then
            local dist = (egg.Position - humanoidRootPart.Position).Magnitude
            if dist < menorDist then
                menorDist = dist
                maisProximo = egg
            end
        end
    end
    return maisProximo
end

-- Função de voo e coleta rápida
local function voarAteOvos(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local EasterRemoteEvent = workspace.Ignore.Easter2026:WaitForChild("EasterRemoteEvent")

    task.spawn(function()
        while rodandoColeta and humanoidRootPart.Parent do
            local egg = getOvoMaisProximo(character)
            if egg then
                local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                local goal = { CFrame = egg.CFrame + Vector3.new(0, 3, 0) }
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
                tween:Play()
                tween.Completed:Wait()

                if rodandoColeta then
                    EasterRemoteEvent:FireServer("EggTouched", egg)
                    print("Coletado: " .. egg.Name)
                end
                task.wait(0.2)
            else
                task.wait(0.5)
            end
        end
    end)
end

-- Funções de highlight (ESP Players)
local function addHighlight(plr)
    if plr.Character then
        if highlights[plr] then highlights[plr]:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Parent = plr.Character
        highlights[plr] = highlight
    end
end

local function removeHighlight(plr)
    if highlights[plr] then
        highlights[plr]:Destroy()
        highlights[plr] = nil
    end
end

local function toggleHighlights(on)
    mostrandoJogadores = on
    if mostrandoJogadores then
        for _, plr in ipairs(Players:GetPlayers()) do
            addHighlight(plr)
            plr.CharacterAdded:Connect(function()
                if mostrandoJogadores then
                    addHighlight(plr)
                end
            end)
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            removeHighlight(plr)
        end
    end
end

-- HUD fixa
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuitkatHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 30)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "QuitkatHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.2, 0, 1, 0)
toggleButton.Position = UDim2.new(0.6, 0, 0, 0)
toggleButton.Text = "+"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.2, 0, 1, 0)
closeButton.Position = UDim2.new(0.8, 0, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Parent = frame

local panel = Instance.new("Frame")
panel.Size = UDim2.new(1, 0, 0, 120)
panel.Position = UDim2.new(0, 0, 1, 0)
panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
panel.BorderSizePixel = 2
panel.Visible = false
panel.Parent = frame

local startStopButton = Instance.new("TextButton")
startStopButton.Size = UDim2.new(1, -10, 0, 30)
startStopButton.Position = UDim2.new(0, 5, 0, 5)
startStopButton.Text = "Autofarm"
startStopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startStopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
startStopButton.Font = Enum.Font.SourceSansBold
startStopButton.TextSize = 16
startStopButton.Parent = panel

local showPlayersButton = Instance.new("TextButton")
showPlayersButton.Size = UDim2.new(1, -10, 0, 30)
showPlayersButton.Position = UDim2.new(0, 5, 0, 40)
showPlayersButton.Text = "Esp Players: OFF"
showPlayersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
showPlayersButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
showPlayersButton.Font = Enum.Font.SourceSansBold
showPlayersButton.TextSize = 16
showPlayersButton.Parent = panel

-- Alterna painel
toggleButton.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
    toggleButton.Text = panel.Visible and "-" or "+"
end)

-- Alterna coleta (Autofarm)
startStopButton.MouseButton1Click:Connect(function()
    rodandoColeta = not rodandoColeta
    startStopButton.Text = rodandoColeta and "Parar Autofarm" or "Autofarm"
    if rodandoColeta and player.Character then
        voarAteOvos(player.Character)
    end
end)

-- Alterna ESP Players
showPlayersButton.MouseButton1Click:Connect(function()
    mostrandoJogadores = not mostrandoJogadores
    showPlayersButton.Text = mostrandoJogadores and "Esp Players: ON" or "Esp Players: OFF"
    toggleHighlights(mostrandoJogadores)
end)

-- Botão de fechar HUD
closeButton.MouseButton1Click:Connect(function()
    rodandoColeta = false
    mostrandoJogadores = false
    screenGui:Destroy()
end)

-- Continua coleta se respawnar
player.CharacterAdded:Connect(function(character)
    if rodandoColeta then
        voarAteOvos(character)
    end
    if mostrandoJogadores then
        addHighlight(player)
    end
end)

-- Mantém ESP ativo em novos jogadores
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        if mostrandoJogadores then
            addHighlight(plr)
        end
    end)
end)
