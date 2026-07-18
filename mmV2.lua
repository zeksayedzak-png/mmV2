-- // MINATO MM2 V1 | V16 ROLE DETECTION //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MINATO MM2 V1",
   LoadingTitle = "MINATO MODZ",
   LoadingSubtitle = "by Minato",
   ConfigurationSaving = { Enabled = false }
})

-- [ VARIABLES ]
local player = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
getgenv().Config = { Farm = false, ESP = false, AutoGun = false, AntiKick = true }

-- [ TABS ]
local TabMain = Window:CreateTab("Principal", 4483362458)
local TabCombat = Window:CreateTab("Combate", 4483362458)

TabMain:CreateToggle({
   Name = "Auto Farm Inteligente (Piso)",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.Farm = v end,
})

TabMain:CreateToggle({
   Name = "Auto Grab Gun",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.AutoGun = v end,
})

TabMain:CreateToggle({
   Name = "ESP Maestro",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.ESP = v end,
})

-- [ MOTOR AIMBOT DESCARADO ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and self.Name == "ShootGun" then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) then
                args[2] = v.Character.HumanoidRootPart.Position
                return old(self, unpack(args))
            end
        end
    end

    if method == "FireServer" and self.Name == "Throw" then
        local target = nil local dist = 2000
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local d = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d target = v end
            end
        end
        if target then args[2] = target.Character.HumanoidRootPart.Position return old(self, unpack(args)) end
    end

    if getgenv().Config.AntiKick and (method == "Kick" or method == "kick") then return nil end
    return old(self, ...)
end)
setreadonly(mt, true)

-- [ INTERFAZ EXTRAS (CONTADOR Y AVISOS) ]
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "MinatoV1Extras"
sg.ResetOnSpawn = false

local timerFrame = Instance.new("Frame", sg)
timerFrame.Size = UDim2.new(0, 120, 0, 40)
timerFrame.Position = UDim2.new(0.5, -60, 0.02, 0)
timerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", timerFrame)

local timerLabel = Instance.new("TextLabel", timerFrame)
timerLabel.Size = UDim2.new(1,0,1,0); timerLabel.TextColor3 = Color3.new(1,1,1); 
timerLabel.Font = Enum.Font.Code; timerLabel.Text = "BUSCANDO..."; timerLabel.BackgroundTransparency = 1; timerLabel.TextSize = 14

-- BOTONES
local function createBtn(name, color, pos)
    local b = Instance.new("TextButton", sg)
    b.Size = UDim2.new(0, 85, 0, 85)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.Visible = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    return b
end

local shootBtn = createBtn("SHOOT\nKILL", Color3.fromRGB(0, 80, 255), UDim2.new(0.75, -135, 0.9, -165))
local knifeBtn = createBtn("KNIFE\nKILL", Color3.fromRGB(255, 0, 50), UDim2.new(0.75, -45, 0.9, -165))

-- [ LOOP DE TIEMPO Y DETECCIÓN ]
spawn(function()
    while task.wait(0.5) do
        local mainGui = player.PlayerGui:FindFirstChild("MainGui")
        if mainGui and mainGui:FindFirstChild("Game") and mainGui.Game.Visible then
            timerFrame.Visible = true
            timerLabel.Text = "TIME: " .. mainGui.Game.Timer.Text
        else
            timerFrame.Visible = false
        end
        
        -- Detectar armas para mostrar botones
        local hasGun = player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun"))
        local hasKnife = player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife"))
        
        shootBtn.Visible = hasGun ~= nil
        knifeBtn.Visible = hasKnife ~= nil
    end
end)

-- ACCIONES
shootBtn.MouseButton1Click:Connect(function()
    local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
    if gun then
        if not player.Character:FindFirstChild("Gun") then player.Character.Humanoid:EquipTool(gun) end
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, v.Character.HumanoidRootPart.Position)
                gun:Activate() break
            end
        end
    end
end)

knifeBtn.MouseButton1Click:Connect(function()
    local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
    if knife then
        if not player.Character:FindFirstChild("Knife") then player.Character.Humanoid:EquipTool(knife) end
        knife:Activate()
    end
end)

-- [ AUTO FARM SEGURO SIN VUELO ]
spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.Farm then
            for _, v in pairs(workspace:GetDescendants()) do
                if (v.Name == "CoinVisual" or v.Name == "MainCoin") and getgenv().Config.Farm then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and v:IsA("BasePart") then
                        local distance = (hrp.Position - v.Position).Magnitude
                        if distance < 350 then
                            local tween = ts:Create(hrp, TweenInfo.new(distance/16, Enum.EasingStyle.Linear), {CFrame = v.CFrame})
                            tween:Play()
                            tween.Completed:Wait()
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end
end)

-- [ ESP & GRAB GUN ]
spawn(function()
    while task.wait(1) do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                hl.Enabled = getgenv().Config.ESP
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then hl.FillColor = Color3.new(1, 0, 0)
                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then hl.FillColor = Color3.new(0, 0, 1)
                else hl.FillColor = Color3.new(0, 1, 0) end
            end
        end
        if getgenv().Config.AutoGun then
            for _, v in pairs(workspace:GetDescendants()) do
                if (v.Name == "GunDrop" or (v.Name == "Gun" and v:IsA("Part"))) and v:FindFirstChild("TouchInterest") then
                    player.Character.HumanoidRootPart.CFrame = v.CFrame
                end
            end
        end
    end
end)
