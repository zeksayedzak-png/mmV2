-- // MINATO MM2 V2 | SMART ROLE DETECTION //
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MINATO MM2 V2",
   LoadingTitle = "MINATO MODZ",
   LoadingSubtitle = "Smart Role Detection",
   ConfigurationSaving = { Enabled = false }
})

-- [ VARIABLES ]
local player = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera

getgenv().Config = { 
    Farm = false, 
    ESP = false, 
    AutoGun = false, 
    AntiKick = true,
    ShowNames = true,
    AutoUpdate = true
}

-- [ ROLE SYSTEM - الذكي ]
local Roles = {
    Murderer = nil,    -- اللاعب اللي عنده سكين
    Sheriff = nil,     -- اللاعب اللي عنده مسدس
    Innocents = {}     -- الباقي
}

-- [ ESP COLORS ]
local ESP_COLORS = {
    Murderer = Color3.fromRGB(255, 0, 0),    -- أحمر
    Sheriff = Color3.fromRGB(0, 100, 255),    -- أزرق
    Innocent = Color3.fromRGB(0, 255, 0)     -- أخضر
}

-- [ TABS ]
local TabMain = Window:CreateTab("Principal", 4483362458)
local TabCombat = Window:CreateTab("Combate", 4483362458)
local TabESP = Window:CreateTab("ESP", 4483362458)

TabMain:CreateToggle({
   Name = "Auto Farm Inteligente",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.Farm = v end,
})

TabMain:CreateToggle({
   Name = "Auto Grab Gun",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.AutoGun = v end,
})

TabESP:CreateToggle({
   Name = "ESP Maestro (Smart Roles)",
   CurrentValue = false,
   Callback = function(v) getgenv().Config.ESP = v end,
})

TabESP:CreateToggle({
   Name = "Show Names Above Head",
   CurrentValue = true,
   Callback = function(v) getgenv().Config.ShowNames = v end,
})

-- [ SMART ROLE DETECTION FUNCTION ]
local function DetectRoles()
    local newMurderer = nil
    local newSheriff = nil
    local newInnocents = {}
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hasKnife = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) ~= nil
            local hasGun = (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) ~= nil
            
            if hasKnife then
                newMurderer = p
            elseif hasGun then
                newSheriff = p
            else
                table.insert(newInnocents, p)
            end
        end
    end
    
    -- Check if roles changed
    if newMurderer ~= Roles.Murderer or newSheriff ~= Roles.Sheriff then
        Roles.Murderer = newMurderer
        Roles.Sheriff = newSheriff
        Roles.Innocents = newInnocents
        
        -- Update ESP immediately when roles change
        if getgenv().Config.ESP then
            UpdateESP()
        end
        
        -- Notification
        if newMurderer then
            Rayfield:Notify({
                Title = "🔴 MURDERER DETECTED",
                Content = newMurderer.Name .. " is the Murderer!",
                Duration = 3,
                Image = 4483362458
            })
        end
        if newSheriff then
            Rayfield:Notify({
                Title = "🔵 SHERIFF DETECTED", 
                Content = newSheriff.Name .. " is the Sheriff!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
end

-- [ ESP SYSTEM - مع الأسماء والألوان ]
function UpdateESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            -- Highlight
            local hl = p.Character:FindFirstChild("MM2_Highlight")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "MM2_Highlight"
                hl.Parent = p.Character
                hl.OutlineTransparency = 0.3
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  -- X-RAY من خلف الجدران!
            end
            
            -- Determine role and color
            local role = "Innocent"
            if p == Roles.Murderer then role = "Murderer"
            elseif p == Roles.Sheriff then role = "Sheriff" end
            
            hl.FillColor = ESP_COLORS[role]
            hl.OutlineColor = ESP_COLORS[role]
            hl.Enabled = getgenv().Config.ESP
            
            -- Name Tag Above Head
            local nameTag = p.Character:FindFirstChild("MM2_NameTag")
            if not nameTag then
                nameTag = Instance.new("BillboardGui")
                nameTag.Name = "MM2_NameTag"
                nameTag.AlwaysOnTop = true
                nameTag.Size = UDim2.new(0, 200, 0, 50)
                nameTag.StudsOffset = Vector3.new(0, 3, 0) -- فوق الرأس
                nameTag.Parent = p.Character:WaitForChild("Head")
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "RoleText"
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextStrokeTransparency = 0
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 14
                textLabel.Parent = nameTag
            end
            
            local textLabel = nameTag:FindFirstChild("RoleText")
            if textLabel then
                textLabel.Text = p.Name .. " [" .. role .. "]"
                textLabel.TextColor3 = ESP_COLORS[role]
                textLabel.Visible = getgenv().Config.ESP and getgenv().Config.ShowNames
            end
        end
    end
end

-- [ SMART AIMBOT - يضرب في الرأس ]
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Auto Aimbot when shooting gun
    if method == "FireServer" and self.Name == "ShootGun" then
        if Roles.Murderer and Roles.Murderer.Character and Roles.Murderer.Character:FindFirstChild("Head") then
            -- Aim at Murderer's HEAD
            args[2] = Roles.Murderer.Character.Head.Position
            return old(self, unpack(args))
        end
    end

    -- Knife throw aimbot (if you're murderer)
    if method == "FireServer" and self.Name == "Throw" then
        local target = nil
        local closestDist = 2000
        
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                -- Target Sheriff first, then Innocents
                local isTarget = (v == Roles.Sheriff) or (v ~= Roles.Murderer)
                if isTarget then
                    local dist = (player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = v
                    end
                end
            end
        end
        
        if target then
            args[2] = target.Character.Head.Position
            return old(self, unpack(args))
        end
    end

    if getgenv().Config.AntiKick and (method == "Kick" or method == "kick") then 
        return nil 
    end
    
    return old(self, ...)
end)
setreadonly(mt, true)

-- [ GUI BUTTONS - SHOOT & KNIFE ]
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "MinatoV2Extras"
sg.ResetOnSpawn = false

local function createBtn(name, color, pos)
    local b = Instance.new("TextButton", sg)
    b.Size = UDim2.new(0, 85, 0, 85)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.Visible = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    return b
end

local shootBtn = createBtn("SHOOT\nKILL", Color3.fromRGB(0, 80, 255), UDim2.new(0.75, -135, 0.9, -165))
local knifeBtn = createBtn("KNIFE\nKILL", Color3.fromRGB(255, 0, 50), UDim2.new(0.75, -45, 0.9, -165))

-- [ SMART SHOOT BUTTON ]
shootBtn.MouseButton1Click:Connect(function()
    local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
    if not gun then return end
    
    -- Equip
    if not player.Character:FindFirstChild("Gun") then
        player.Character.Humanoid:EquipTool(gun)
    end
    
    -- Smart Target: Murderer first
    local target = Roles.Murderer
    
    if target and target.Character and target.Character:FindFirstChild("Head") then
        -- Aim at head
        local headPos = target.Character.Head.Position
        cam.CFrame = CFrame.new(cam.CFrame.Position, headPos)
        
        task.wait(0.05)
        
        -- Fire at head
        local shootEvent = gun:FindFirstChild("ShootGun") or gun:FindFirstChild("Shoot")
        if shootEvent and shootEvent:IsA("RemoteEvent") then
            shootEvent:FireServer(headPos)
        else
            gun:Activate()
        end
        
        Rayfield:Notify({
            Title = "🎯 HEADSHOT",
            Content = "Shot " .. target.Name .. " in the head!",
            Duration = 2
        })
    else
        Rayfield:Notify({
            Title = "⚠️ NO TARGET",
            Content = "Murderer not found!",
            Duration = 2
        })
    end
end)

-- [ KNIFE BUTTON ]
knifeBtn.MouseButton1Click:Connect(function()
    local knife = player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
    if knife then
        if not player.Character:FindFirstChild("Knife") then
            player.Character.Humanoid:EquipTool(knife)
        end
        knife:Activate()
    end
end)

-- [ AUTO UPDATE LOOP - كل 3 ثواني ]
spawn(function()
    while task.wait(3) do
        if getgenv().Config.AutoUpdate then
            DetectRoles()
            if getgenv().Config.ESP then
                UpdateESP()
            end
        end
        
        -- Update buttons visibility
        local hasGun = player.Backpack:FindFirstChild("Gun") or (player.Character and player.Character:FindFirstChild("Gun"))
        local hasKnife = player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife"))
        
        shootBtn.Visible = hasGun ~= nil
        knifeBtn.Visible = hasKnife ~= nil
    end
end)

-- [ AUTO FARM - محسّن ]
spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.Farm then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local nearestCoin = nil
            local nearestDist = 350
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "CoinVisual" or v.Name == "MainCoin" then
                    if v:IsA("BasePart") then
                        local dist = (hrp.Position - v.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestCoin = v
                        end
                    end
                end
            end
            
            if nearestCoin then
                local tween = ts:Create(hrp, TweenInfo.new(nearestDist/20, Enum.EasingStyle.Linear), {CFrame = nearestCoin.CFrame})
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.2)
            end
        end
    end
end)

-- [ AUTO GRAB GUN ]
spawn(function()
    while task.wait(1) do
        if getgenv().Config.AutoGun then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "GunDrop" and v:FindFirstChild("TouchInterest") then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = v.CFrame
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- [ INITIAL DETECTION ]
DetectRoles()
UpdateESP()

Rayfield:Notify({
    Title = "✅ MINATO V2 LOADED",
    Content = "Smart Role Detection Active!",
    Duration = 5
})
