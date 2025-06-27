-- Universal Roblox Script with Kavo UI (Ultimate Edition V5)
-- Features: Original ESP, Silent Aim, Trigger Bot, Wallbang, Bunny Hop, FOV Changer, Instant Respawn, Fake Lag, Speed Hack, Noclip, Infinite Jump, Teleport, Auto-Detect, God Mode, Kill Aura, X-Ray, Fullbright, Player Chams, Auto Respawn, Anti-AFK, Gravity Hack, No Fall Damage, Item ESP, Click TP, Super Jump, Auto Clicker, Player Tracker, No Clip Speed Boost, Wallwalk, Feature Search, F3X, Nameless Admin, No Spread, Rapid Fire, Invisible Tools, Fake Character, Bullet Tracers, Auto Reload, Hitbox Expander, Break In Script, Break In 2 Script, Aimbot
-- Added: Break In Script, Break In 2 Script, Aimbot buttons in Scripts tab
-- Note: Use at your own risk. Anticheat bypass is not guaranteed.

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("BlueBack", "DarkTheme")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Enhanced Anticheat Bypass
local function antiCheatBypass()
    pcall(function()
        if getgenv().ACBYPASS then return end
        getgenv().ACBYPASS = true
        
        local function spoofProperties()
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = math.clamp(humanoid.WalkSpeed, 16, 100)
                humanoid.JumpPower = math.clamp(humanoid.JumpPower, 50, 100)
                humanoid.HipHeight = math.clamp(humanoid.HipHeight, 0, 10)
                humanoid.Health = math.clamp(humanoid.Health, 0, 100)
            end
        end
        
        local mt = getrawmetatable(game)
        local oldIndex, oldNamecall, oldNewIndex = mt.__index, mt.__namecall, mt.__newindex
        setreadonly(mt, false)
        
        mt.__index = function(t, k)
            if k == "Kick" or k == "Ban" or k == "Destroy" then
                return function() end
            end
            return oldIndex(t, k)
        end
        
        mt.__namecall = function(t, k, ...)
            if k == "Kick" or k == "Ban" or k == "RemoteEvent" or k == "RemoteFunction" then
                return
            end
            local args = {...}
            if k == "FireServer" and args[1] == "Check" then
                return
            end
            return oldNamecall(t, k, ...)
        end
        
        mt.__newindex = function(t, k, v)
            if k == "WalkSpeed" or k == "JumpPower" or k == "CFrame" then
                return
            end
            oldNewIndex(t, k, v)
        end
        
        setreadonly(mt, true)
        
        spawn(function()
            while getgenv().ACBYPASS do
                spoofProperties()
                pcall(function()
                    for _, conn in pairs(getconnections(game:GetService("ReplicatedStorage"):FindFirstChildOfClass("RemoteEvent").OnClientEvent)) do
                        conn:Disable()
                    end
                end)
                wait(math.random(0.3, 0.7))
            end
        end)
        
        spawn(function()
            while getgenv().ACBYPASS do
                pcall(function()
                    LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                end)
                wait(1)
            end
        end)
    end)
end
antiCheatBypass()

-- Original ESP (Smaller Health/Distance Text)
local espEnabled = false
local espTable = {}
local espTeamCheck = false
local function createESP(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Head") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_" .. player.Name
    billboard.Adornee = player.Character.Head
    billboard.Size = UDim2.new(0, 150, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = espTeamCheck and (player.Team == LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)) or Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.3, 0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "Health: 100"
    healthLabel.TextColor3 = Color3.new(0, 1, 0)
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextSize = 12
    healthLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.2, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: 0"
    distanceLabel.TextColor3 = Color3.new(1, 1, 0)
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = espTeamCheck and (player.Team == LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)) or Color3.new(1, 0, 0)
    highlight.Parent = player.Character

    espTable[player] = {billboard = billboard, healthLabel = healthLabel, distanceLabel = distanceLabel, highlight = highlight}
end

local function updateESP()
    while espEnabled do
        for player, data in pairs(espTable) do
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                local hum = player.Character.Humanoid
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                data.healthLabel.Text = "Health: " .. math.floor(hum.Health)
                data.healthLabel.TextColor3 = Color3.fromHSV(hum.Health/300, 1, 1)
                data.distanceLabel.Text = "Distance: " .. math.floor(distance)
                data.highlight.FillColor = Color3.fromHSV(hum.Health/300, 1, 1)
                if espTeamCheck then
                    data.nameLabel.TextColor3 = player.Team == LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    data.highlight.OutlineColor = player.Team == LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end
            else
                data.billboard:Destroy()
                data.highlight:Destroy()
                espTable[player] = nil
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if not espTable[player] then
                createESP(player)
            end
        end
        wait(0.1)
    end
end

local function toggleESP(state)
    espEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end
        Players.PlayerAdded:Connect(createESP)
        spawn(updateESP)
    else
        for _, data in pairs(espTable) do
            data.billboard:Destroy()
            data.highlight:Destroy()
        end
        espTable = {}
    end
end

-- Fly Feature
local flying = false
local flySpeed = 50
local function startFly()
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9e4
    bodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart

    RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = Camera
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        bodyVelocity.Velocity = moveDir * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        for _, v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
end

-- Silent Aim
local silentAimEnabled = false
local function silentAim()
    local function getClosestPlayer()
        local closestPlayer = nil
        local closestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local distance = (player.Character.Head.Position - Camera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
        return closestPlayer
    end

    local oldFireServer = game:GetService("ReplicatedStorage").RemoteEvent.FireServer
    game:GetService("ReplicatedStorage").RemoteEvent.FireServer = function(self, ...)
        if silentAimEnabled then
            local args = {...}
            local closestPlayer = getClosestPlayer()
            if closestPlayer and args[1] == "Shoot" then
                args[2] = closestPlayer.Character.Head.Position
            end
            return oldFireServer(self, unpack(args))
        end
        return oldFireServer(self, ...)
    end
end

local function toggleSilentAim(state)
    silentAimEnabled = state
    if state then
        silentAim()
    end
end

-- Trigger Bot
local triggerBotEnabled = false
local function triggerBot()
    RunService.RenderStepped:Connect(function()
        if not triggerBotEnabled then return end
        local mouse = UserInputService:GetMouseLocation()
        local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
        local hit = workspace:FindPartOnRay(ray)
        if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent ~= LocalPlayer.Character then
            mouse1click()
        end
    end)
end

local function toggleTriggerBot(state)
    triggerBotEnabled = state
    if state then
        spawn(triggerBot)
    end
end

-- Wallbang
local wallbangEnabled = false
local function wallbang()
    -- Game-specific
end

-- Bunny Hop
local bunnyHopEnabled = false
local function bunnyHop()
    RunService.Stepped:Connect(function()
        if bunnyHopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Running then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function toggleBunnyHop(state)
    bunnyHopEnabled = state
    if state then
        spawn(bunnyHop)
    end
end

-- FOV Changer
local function setFOV(value)
    Camera.FieldOfView = value
end

-- Instant Respawn
local instantRespawnEnabled = false
local function instantRespawn()
    LocalPlayer.CharacterAdded:Connect(function()
        if instantRespawnEnabled then
            wait(0.1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame
        end
    end)
end

local function toggleInstantRespawn(state)
    instantRespawnEnabled = state
    if state then
        instantRespawn()
    end
end

-- Fake Lag
local fakeLagEnabled = false
local function fakeLag()
    spawn(function()
        while fakeLagEnabled do
            wait(0.1)
        end
    end)
end

local function toggleFakeLag(state)
    fakeLagEnabled = state
    if state then
        fakeLag()
    end
end

-- Speed Hack
local speedHackEnabled = false
local speedValue = 50
local function speedHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedHackEnabled and speedValue or 16
    end
end

-- Noclip
local noclipEnabled = false
local function noclip()
    RunService.Stepped:Connect(function()
        if noclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Infinite Jump
local infJumpEnabled = false
local function infiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled and LocalPlayer.Character then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Teleport to Player
local function teleportToPlayer(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(playerName:lower()) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            break
        end
    end
end

-- Auto-Detect Features
local autoDetectEnabled = false
local function autoDetectFeatures()
    spawn(function()
        while autoDetectEnabled do
            if workspace:FindFirstChild("SpawnLocation") then
                instantRespawnEnabled = true
            end
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    silentAimEnabled = true
                    triggerBotEnabled = true
                    break
                end
            end
            wait(5)
        end
    end)
end

-- God Mode
local godModeEnabled = false
local function godMode()
    spawn(function()
        while godModeEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 100
            end
            wait(0.1)
        end
    end)
end

-- Kill Aura
local killAuraEnabled = false
local function killAura()
    spawn(function()
        while killAuraEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 10 then
                        player.Character.Humanoid.Health = 0
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- X-Ray
local xrayEnabled = false
local function xray()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            part.Transparency = xrayEnabled and 0.7 or 0
        end
    end
end

-- Fullbright
local fullbrightEnabled = false
local function fullbright()
    if fullbrightEnabled then
        game.Lighting.Brightness = 2
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.Brightness = 1
        game.Lighting.FogEnd = 1000
    end
end

-- Player Chams
local chamsEnabled = false
local function playerChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = chamsEnabled and Enum.Material.Neon or Enum.Material.Plastic
                    part.Color = chamsEnabled and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
                end
            end
        end
    end
end

-- Auto Respawn
local autoRespawnEnabled = false
local function autoRespawn()
    LocalPlayer.CharacterAdded:Connect(function()
        if autoRespawnEnabled then
            wait(0.1)
            LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.SpawnLocation.CFrame
        end
    end)
end

-- Anti-AFK
local antiAfkEnabled = false
local function antiAfk()
    spawn(function()
        while antiAfkEnabled do
            game:GetService("VirtualUser"):CaptureController()
            wait(60)
        end
    end)
end

-- Gravity Hack
local gravityHackEnabled = false
local gravityValue = 50
local function gravityHack()
    workspace.Gravity = gravityHackEnabled and gravityValue or 196.2
end

-- No Fall Damage
local noFallDamageEnabled = false
local function noFallDamage()
    spawn(function()
        while noFallDamageEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            wait(0.1)
        end
    end)
end

-- ESP for Items
local itemEspEnabled = false
local itemEspTable = {}
local function createItemESP(item)
    if not item:IsA("BasePart") and not item:IsA("Tool") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ItemESP_" .. item.Name
    billboard.Adornee = item
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.Name
    nameLabel.TextColor3 = Color3.new(0, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    itemEspTable[item] = {billboard = billboard}
end

local function updateItemESP()
    while itemEspEnabled do
        for item, data in pairs(itemEspTable) do
            if not item.Parent then
                data.billboard:Destroy()
                itemEspTable[item] = nil
            end
        end
        for _, item in pairs(workspace:GetDescendants()) do
            if (item:IsA("BasePart") or item:IsA("Tool")) and not itemEspTable[item] then
                createItemESP(item)
            end
        end
        wait(0.5)
    end
end

local function toggleItemESP(state)
    itemEspEnabled = state
    if state then
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("Tool") then
                createItemESP(item)
            end
        end
        workspace.DescendantAdded:Connect(createItemESP)
        spawn(updateItemESP)
    else
        for _, data in pairs(itemEspTable) do
            data.billboard:Destroy()
        end
        itemEspTable = {}
    end
end

-- Click TP
local clickTpEnabled = false
local function clickTp()
    UserInputService.InputBegan:Connect(function(input)
        if clickTpEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
            local hit = workspace:FindPartOnRay(ray)
            if hit and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
end

-- Super Jump
local superJumpEnabled = false
local superJumpValue = 100
local function superJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = superJumpEnabled and superJumpValue or 50
    end
end

-- Auto Clicker
local autoClickerEnabled = false
local function autoClicker()
    spawn(function()
        while autoClickerEnabled do
            mouse1click()
            wait(0.05)
        end
    end)
end

-- Player Tracker
local trackerEnabled = false
local trackedPlayer = nil
local function trackPlayer(playerName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(playerName:lower()) then
            trackedPlayer = player
            break
        end
    end
    if trackedPlayer and trackerEnabled then
        spawn(function()
            while trackerEnabled and trackedPlayer and trackedPlayer.Character and trackedPlayer.Character:FindFirstChild("HumanoidRootPart") do
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "Tracker_" .. trackedPlayer.Name
                billboard.Adornee = trackedPlayer.Character.Head
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = game.CoreGui

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "Tracked: " .. trackedPlayer.Name
                label.TextColor3 = Color3.new(1, 0, 0)
                label.TextScaled = true
                label.Parent = billboard

                wait(1)
                billboard:Destroy()
            end
        end)
    end
end

-- No Clip Speed Boost
local noClipSpeedBoostEnabled = false
local noClipSpeedValue = 100
local function noClipSpeedBoost()
    if noclipEnabled and noClipSpeedBoostEnabled then
        flySpeed = noClipSpeedValue
    else
        flySpeed = 50
    end
end

-- Wallwalk
local wallwalkEnabled = false
local function wallwalk()
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart

    RunService.Stepped:Connect(function()
        if not wallwalkEnabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            bodyVelocity:Destroy()
            return
        end
        local root = LocalPlayer.Character.HumanoidRootPart
        local ray = Ray.new(root.Position, -root.CFrame.UpVector * 5)
        local hit, pos, normal = workspace:FindPartOnRay(ray, LocalPlayer.Character)
        if hit then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(root.Position, root.Position + normal) * CFrame.Angles(math.rad(-90), 0, 0)
        else
            bodyVelocity.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * 16
        end
    end)
end

local function toggleWallwalk(state)
    wallwalkEnabled = state
    if state then
        wallwalk()
    else
        if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            for _, v in pairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
end

-- No Spread
local noSpreadEnabled = false
local function noSpread()
    -- Game-specific
end

-- Rapid Fire
local rapidFireEnabled = false
local function rapidFire()
    spawn(function()
        while rapidFireEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                tool:Activate()
            end
            wait(0.01)
        end
    end)
end

-- Invisible Tools
local invisibleToolsEnabled = false
local function invisibleTools()
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in pairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = invisibleToolsEnabled and 1 or 0
                end
            end
        end
    end
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, part in pairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = invisibleToolsEnabled and 1 or 0
                    end
                end
            end
        end
    end
end

-- Fake Character
local fakeCharacterEnabled = false
local function fakeCharacter()
    if fakeCharacterEnabled and LocalPlayer.Character then
        local clone = LocalPlayer.Character:Clone()
        clone.Parent = workspace
        clone.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        clone.Humanoid.WalkSpeed = 0
        spawn(function()
            while fakeCharacterEnabled and clone.Parent do
                clone.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                wait(0.1)
            end
            clone:Destroy()
        end)
    end
end

-- Bullet Tracers
local bulletTracersEnabled = false
local bulletTracersTable = {}
local function createBulletTracer(bullet)
    if not bullet:IsA("BasePart") then return end
    local tracer = Instance.new("LineHandleAdornment")
    tracer.Adornee = bullet
    tracer.Color3 = Color3.new(1, 0, 0)
    tracer.Thickness = 2
    tracer.Transparency = 0.3
    tracer.Length = 100
    tracer.Parent = bullet
    bulletTracersTable[bullet] = tracer
end

local function updateBulletTracers()
    while bulletTracersEnabled do
        for bullet, tracer in pairs(bulletTracersTable) do
            if not bullet.Parent then
                tracer:Destroy()
                bulletTracersTable[bullet] = nil
            end
        end
        for _, bullet in pairs(workspace:GetDescendants()) do
            if bullet.Name == "Bullet" and not bulletTracersTable[bullet] then
                createBulletTracer(bullet)
            end
        end
        wait(0.1)
    end
end

local function toggleBulletTracers(state)
    bulletTracersEnabled = state
    if state then
        spawn(updateBulletTracers)
    else
        for _, tracer in pairs(bulletTracersTable) do
            tracer:Destroy()
        end
        bulletTracersTable = {}
    end
end

-- Auto Reload
local autoReloadEnabled = false
local function autoReload()
    spawn(function()
        while autoReloadEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool:FindFirstChild("Ammo") and tool.Ammo.Value == 0 then
                    tool:FindFirstChildOfClass("RemoteEvent"):FireServer("Reload")
                end
            end
            wait(0.5)
        end
    end)
end

-- Custom Hitbox Expander
local hitboxExpanderEnabled = false
local hitboxSize = 10
local function hitboxExpander()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            head.Size = hitboxExpanderEnabled and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or Vector3.new(2, 1, 1)
            head.Transparency = hitboxExpanderEnabled and 0.7 or 0
        end
    end
end

-- F3X Integration
local function loadF3X()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BadScripter/Scripts/master/F3X.lua", true))()
    end)
end

-- Nameless Admin
local function loadNamelessAdmin()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/Nameless/master/Main"))()
    end)
end

-- Break In Script
local function loadBreakInScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nikita365/Break-In-Story-/main/Break%20In%20Story%20Hub"))()
    end)
end

-- Break In 2 Script
local function loadBreakIn2Script()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RScriptz/RobloxScripts/main/BreakIn2.lua"))()
    end)
end

-- Aimbot Script
local function loadAimbotScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
    end)
end

-- Feature Search
local featureList = {
    {name = "Fly", toggle = function(state) flying = state; if state then startFly() else stopFly() end end},
    {name = "ESP", toggle = toggleESP},
    {name = "Team Check ESP", toggle = function(state) espTeamCheck = state; toggleESP(false); toggleESP(true) end},
    {name = "Silent Aim", toggle = toggleSilentAim},
    {name = "Trigger Bot", toggle = toggleTriggerBot},
    {name = "Wallbang", toggle = function(state) wallbangEnabled = state; if state then wallbang() end end},
    {name = "Bunny Hop", toggle = toggleBunnyHop},
    {name = "Kill Aura", toggle = function(state) killAuraEnabled = state; if state then killAura() end end},
    {name = "Instant Respawn", toggle = toggleInstantRespawn},
    {name = "Fake Lag", toggle = toggleFakeLag},
    {name = "Speed Hack", toggle = function(state) speedHackEnabled = state; speedHack() end},
    {name = "Noclip", toggle = function(state) noclipEnabled = state; if state then noclip() end end},
    {name = "Infinite Jump", toggle = function(state) infJumpEnabled = state; if state then infiniteJump() end end},
    {name = "Auto-Detect Features", toggle = function(state) autoDetectEnabled = state; if state then autoDetectFeatures() end end},
    {name = "God Mode", toggle = function(state) godModeEnabled = state; if state then godMode() end end},
    {name = "X-Ray", toggle = function(state) xrayEnabled = state; xray() end},
    {name = "Fullbright", toggle = function(state) fullbrightEnabled = state; fullbright() end},
    {name = "Player Chams", toggle = function(state) chamsEnabled = state; playerChams() end},
    {name = "Auto Respawn", toggle = function(state) autoRespawnEnabled = state; if state then autoRespawn() end end},
    {name = "Anti-AFK", toggle = function(state) antiAfkEnabled = state; if state then antiAfk() end end},
    {name = "Gravity Hack", toggle = function(state) gravityHackEnabled = state; gravityHack() end},
    {name = "No Fall Damage", toggle = function(state) noFallDamageEnabled = state; if state then noFallDamage() end end},
    {name = "Item ESP", toggle = toggleItemESP},
    {name = "Click TP", toggle = function(state) clickTpEnabled = state; if state then clickTp() end end},
    {name = "Super Jump", toggle = function(state) superJumpEnabled = state; superJump() end},
    {name = "Auto Clicker", toggle = function(state) autoClickerEnabled = state; if state then autoClicker() end end},
    {name = "No Clip Speed Boost", toggle = function(state) noClipSpeedBoostEnabled = state; noClipSpeedBoost() end},
    {name = "Wallwalk", toggle = toggleWallwalk},
    {name = "No Spread", toggle = function(state) noSpreadEnabled = state; if state then noSpread() end end},
    {name = "Rapid Fire", toggle = function(state) rapidFireEnabled = state; if state then rapidFire() end end},
    {name = "Invisible Tools", toggle = function(state) invisibleToolsEnabled = state; invisibleTools() end},
    {name = "Fake Character", toggle = function(state) fakeCharacterEnabled = state; if state then fakeCharacter() end end},
    {name = "Bullet Tracers", toggle = toggleBulletTracers},
    {name = "Auto Reload", toggle = function(state) autoReloadEnabled = state; if state then autoReload() end end},
    {name = "Hitbox Expander", toggle = function(state) hitboxExpanderEnabled = state; hitboxExpander() end}
}

-- UI Setup
local SearchTab = Window:NewTab("Search")
local SearchSection = SearchTab:NewSection("Feature Search")
SearchSection:NewTextBox("Search Features", "Type to filter features", function(text)
    SearchSection:ClearAllChildren()
    for _, feature in pairs(featureList) do
        if feature.name:lower():find(text:lower()) then
            SearchSection:NewToggle(feature.name, "Toggle " .. feature.name, function(state)
                feature.toggle(state)
            end)
        end
    end
end)

local ScriptsTab = Window:NewTab("Scripts")
local ScriptsSection = ScriptsTab:NewSection("External Scripts")
ScriptsSection:NewButton("Break In Script", "Load Break In Story Hub", function()
    loadBreakInScript()
end)
ScriptsSection:NewButton("Break In 2 Script", "Load Break In 2 Script", function()
    loadBreakIn2Script()
end)
ScriptsSection:NewButton("Aimbot", "Load Aimbot V3 Script", function()
    loadAimbotScript()
end)

local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Core Features")

MainSection:NewToggle("Fly", "Toggle flying", function(state)
    flying = state
    if state then
        startFly()
    else
        stopFly()
    end
end)

MainSection:NewSlider("Fly Speed", "Adjust fly speed", 100, 10, function(value)
    flySpeed = value
end)

MainSection:NewToggle("ESP", "Toggle original ESP", function(state)
    toggleESP(state)
end)

MainSection:NewToggle("Team Check ESP", "Toggle team-based ESP colors", function(state)
    espTeamCheck = state
    toggleESP(false)
    toggleESP(true)
end)

MainSection:NewButton("Nameless Admin", "Load Nameless Admin script", function()
    loadNamelessAdmin()
end)

MainSection:NewButton("Load F3X", "Load F3X Building Tools", function()
    loadF3X()
end)

-- Combat Tab
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Combat Features")

CombatSection:NewToggle("Silent Aim", "Toggle silent aim", function(state)
    toggleSilentAim(state)
end)

CombatSection:NewToggle("Trigger Bot", "Toggle trigger bot", function(state)
    toggleTriggerBot(state)
end)

CombatSection:NewToggle("Wallbang", "Toggle wallbang (game specific)", function(state)
    wallbangEnabled = state
    if state then
        wallbang()
    end
end)

CombatSection:NewToggle("Bunny Hop", "Toggle bunny hop", function(state)
    toggleBunnyHop(state)
end)

CombatSection:NewToggle("Kill Aura", "Toggle kill aura", function(state)
    killAuraEnabled = state
    if state then
        killAura()
    end
end)

CombatSection:NewToggle("No Spread", "Toggle no spread (game specific)", function(state)
    noSpreadEnabled = state
    if state then
        noSpread()
    end
end)

CombatSection:NewToggle("Rapid Fire", "Toggle rapid fire", function(state)
    rapidFireEnabled = state
    if state then
        rapidFire()
    end
end)

CombatSection:NewToggle("Auto Reload", "Toggle auto reload", function(state)
    autoReloadEnabled = state
    if state then
        autoReload()
    end
end)

CombatSection:NewToggle("Hitbox Expander", "Toggle hitbox expander", function(state)
    hitboxExpanderEnabled = state
    hitboxExpander()
end)

CombatSection:NewSlider("Hitbox Size", "Adjust hitbox size", 20, 5, function(value)
    hitboxSize = value
    hitboxExpander()
end)

-- Visuals Tab
local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("Visual Features")

VisualsSection:NewSlider("FOV", "Adjust field of view", 120, 70, function(value)
    setFOV(value)
end)

VisualsSection:NewToggle("X-Ray", "Toggle X-Ray vision", function(state)
    xrayEnabled = state
    xray()
end)

VisualsSection:NewToggle("Fullbright", "Toggle fullbright", function(state)
    fullbrightEnabled = state
    fullbright()
end)

VisualsSection:NewToggle("Player Chams", "Toggle player chams", function(state)
    chamsEnabled = state
    playerChams()
end)

VisualsSection:NewToggle("Item ESP", "Toggle item ESP", function(state)
    toggleItemESP(state)
end)

VisualsSection:NewToggle("Bullet Tracers", "Toggle bullet tracers", function(state)
    toggleBulletTracers(state)
end)

-- Misc Tab
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Miscellaneous Features")

MiscSection:NewToggle("Instant Respawn", "Toggle instant respawn", function(state)
    toggleInstantRespawn(state)
end)

MiscSection:NewToggle("Fake Lag", "Toggle fake lag", function(state)
    toggleFakeLag(state)
end)

MiscSection:NewToggle("Speed Hack", "Toggle speed hack", function(state)
    speedHackEnabled = state
    speedHack()
end)

MiscSection:NewSlider("Speed Value", "Adjust speed", 100, 16, function(value)
    speedValue = value
    speedHack()
end)

MiscSection:NewToggle("Noclip", "Toggle noclip", function(state)
    noclipEnabled = state
    if state then
        noclip()
    end
end)

MiscSection:NewToggle("Infinite Jump", "Toggle infinite jump", function(state)
    infJumpEnabled = state
    if state then
        infiniteJump()
    end
end)

MiscSection:NewTextBox("Teleport to Player", "Enter player name", function(text)
    teleportToPlayer(text)
end)

MiscSection:NewToggle("Auto-Detect Features", "Toggle auto-detection", function(state)
    autoDetectEnabled = state
    if state then
        autoDetectFeatures()
    end
end)

MiscSection:NewToggle("God Mode", "Toggle god mode", function(state)
    godModeEnabled = state
    if state then
        godMode()
    end
end)

MiscSection:NewToggle("Auto Respawn", "Toggle auto respawn", function(state)
    autoRespawnEnabled = state
    if state then
        autoRespawn()
    end
end)

MiscSection:NewToggle("Anti-AFK", "Toggle anti-AFK", function(state)
    antiAfkEnabled = state
    if state then
        antiAfk()
    end
end)

MiscSection:NewToggle("Gravity Hack", "Toggle gravity hack", function(state)
    gravityHackEnabled = state
    gravityHack()
end)

MiscSection:NewSlider("Gravity Value", "Adjust gravity", 100, 0, function(value)
    gravityValue = value
    gravityHack()
end)

MiscSection:NewToggle("No Fall Damage", "Toggle no fall damage", function(state)
    noFallDamageEnabled = state
    if state then
        noFallDamage()
    end
end)

MiscSection:NewToggle("Click TP", "Toggle click teleport", function(state)
    clickTpEnabled = state
    if state then
        clickTp()
    end
end)

MiscSection:NewToggle("Super Jump", "Toggle super jump", function(state)
    superJumpEnabled = state
    superJump()
end)

MiscSection:NewSlider("Super Jump Value", "Adjust jump power", 200, 50, function(value)
    superJumpValue = value
    superJump()
end)

MiscSection:NewToggle("Auto Clicker", "Toggle auto clicker", function(state)
    autoClickerEnabled = state
    if state then
        autoClicker()
    end
end)

MiscSection:NewTextBox("Player Tracker", "Enter player name to track", function(text)
    trackerEnabled = true
    trackPlayer(text)
end)

MiscSection:NewToggle("No Clip Speed Boost", "Toggle no clip speed boost", function(state)
    noClipSpeedBoostEnabled = state
    noClipSpeedBoost()
end)

MiscSection:NewSlider("No Clip Speed Value", "Adjust no clip speed", 200, 50, function(value)
    noClipSpeedValue = value
    noClipSpeedBoost()
end)

MiscSection:NewToggle("Wallwalk", "Toggle wallwalk", function(state)
    toggleWallwalk(state)
end)

MiscSection:NewToggle("Invisible Tools", "Toggle invisible tools", function(state)
    invisibleToolsEnabled = state
    invisibleTools()
end)

MiscSection:NewToggle("Fake Character", "Toggle fake character", function(state)
    fakeCharacterEnabled = state
    if state then
        fakeCharacter()
    end
end)

-- Credits Tab
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("Credits")
CreditsSection:NewLabel("Script By NightLou")
CreditsSection:NewLabel("UI Library: Kavo by xHeptc")
CreditsSection:NewLabel("Use responsibly!")

-- Cleanup on script end
game:BindToClose(function()
    toggleESP(false)
    stopFly()
    toggleSilentAim(false)
    toggleTriggerBot(false)
    toggleBunnyHop(false)
    toggleInstantRespawn(false)
    toggleFakeLag(false)
    speedHackEnabled = false
    speedHack()
    noclipEnabled = false
    infJumpEnabled = false
    autoDetectEnabled = false
    godModeEnabled = false
    killAuraEnabled = false
    xrayEnabled = false
    xray()
    fullbrightEnabled = false
    fullbright()
    chamsEnabled = false
    playerChams()
    autoRespawnEnabled = false
    antiAfkEnabled = false
    gravityHackEnabled = false
    gravityHack()
    noFallDamageEnabled = false
    toggleItemESP(false)
    clickTpEnabled = false
    superJumpEnabled = false
    superJump()
    autoClickerEnabled = false
    trackerEnabled = false
    noClipSpeedBoostEnabled = false
    noClipSpeedBoost()
    wallwalkEnabled = false
    toggleWallwalk(false)
    noSpreadEnabled = false
    rapidFireEnabled = false
    invisibleToolsEnabled = false
    invisibleTools()
    fakeCharacterEnabled = false
    toggleBulletTracers(false)
    autoReloadEnabled = false
    hitboxExpanderEnabled = false
    hitboxExpander()
end)

-- Initialize camera to default state
Camera.CameraType = Enum.CameraType.Custom
UserInputService.MouseBehavior = Enum.MouseBehavior.Default
