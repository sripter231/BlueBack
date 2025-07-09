local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("BlueBack", "DarkTheme")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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
            local method = tostring(k):lower()
            if method:find("kick") or method:find("ban") or method:find("report") then
                return
            end
            return oldNamecall(t, k, ...)
        end
        
        mt.__newindex = function(t, k, v)
            if k == "WalkSpeed" or k == "JumpPower" or k == "Health" then
                return
            end
            oldNewIndex(t, k, v)
        end
        
        setreadonly(mt, true)
        
        coroutine.wrap(function()
            while getgenv().ACBYPASS do
                spoofProperties()
                wait(0.3)
            end
        end)()
    end)
end
antiCheatBypass()

-- Minimap Feature
local minimapEnabled = false
local minimapGui = nil
local minimapSize = 200
local minimapZoom = 50

local function createMinimap()
    minimapGui = Instance.new("ScreenGui")
    minimapGui.Name = "MinimapGui"
    minimapGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, minimapSize, 0, minimapSize)
    frame.Position = UDim2.new(0.85, 0, 0.05, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 2
    frame.Parent = minimapGui
    
    local function updateMinimap()
        while minimapEnabled do
            for _, v in pairs(frame:GetChildren()) do
                if v:IsA("Frame") then v:Destroy() end
            end
            
            local center = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not center then wait(0.1) continue end
            center = center.Position
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = player.Character.HumanoidRootPart.Position
                    local relPos = (pos - center) / minimapZoom
                    if relPos.Magnitude < 0.5 then
                        local dot = Instance.new("Frame")
                        dot.Size = UDim2.new(0, 5, 0, 5)
                        dot.Position = UDim2.new(0.5 + relPos.X, 0, 0.5 + relPos.Z, 0)
                        dot.BackgroundColor3 = Color3.new(1, 0, 0)
                        dot.Parent = frame
                    end
                end
            end
            
            local playerDot = Instance.new("Frame")
            playerDot.Size = UDim2.new(0, 8, 0, 8)
            playerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
            playerDot.BackgroundColor3 = Color3.new(0, 1, 0)
            playerDot.Parent = frame
            
            wait(0.1)
        end
    end
    
    coroutine.wrap(updateMinimap)()
end

local function toggleMinimap(state)
    minimapEnabled = state
    if state then
        createMinimap()
    else
        if minimapGui then minimapGui:Destroy() end
        minimapGui = nil
    end
end

-- Fixed and Optimized ESP
local espEnabled = false
local espTable = {}
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
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
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
    highlight.OutlineColor = Color3.new(1, 0, 0)
    highlight.Parent = player.Character

    espTable[player] = {billboard = billboard, healthLabel = healthLabel, distanceLabel = distanceLabel, highlight = highlight}
end

local function updateESP()
    coroutine.wrap(function()
        while espEnabled do
            for player, data in pairs(espTable) do
                if player.Character and player.Character:FindFirstChild("Humanoid") and 
                   player.Character:FindFirstChild("HumanoidRootPart") and 
                   player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    local hum = player.Character.Humanoid
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local distance = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        data.healthLabel.Text = "Health: " .. math.floor(hum.Health)
                        data.healthLabel.TextColor3 = Color3.fromHSV(hum.Health/100, 1, 1)
                        data.distanceLabel.Text = "Distance: " .. math.floor(distance)
                        data.highlight.FillColor = Color3.fromHSV(hum.Health/100, 1, 1)
                    end
                else
                    data.billboard:Destroy()
                    data.highlight:Destroy()
                    espTable[player] = nil
                end
            end
            for _, player in pairs(Players:GetPlayers()) do
                if not espTable[player] and player.Character and 
                   player.Character:FindFirstChild("Humanoid") and 
                   player.Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    createESP(player)
                end
            end
            wait(0.1)
        end
    end)()
end

local function toggleESP(state)
    espEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end
        Players.PlayerAdded:Connect(createESP)
        updateESP()
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
        local cam = Workspace.CurrentCamera
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

-- Improved Trigger Bot
local triggerBotEnabled = false
local triggerBotFOV = 100
local function triggerBot()
    coroutine.wrap(function()
        while triggerBotEnabled do
            local mouse = UserInputService:GetMouseLocation()
            local ray = Workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if result and result.Instance then
                local hitPart = result.Instance
                local hitPlayer = Players:GetPlayerFromCharacter(hitPart.Parent)
                if hitPlayer and hitPlayer ~= LocalPlayer and hitPart.Parent:FindFirstChildOfClass("Humanoid") then
                    local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(hitPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                        if distance < triggerBotFOV then
                            mouse1click()
                        end
                    end
                end
            end
            wait(0.05)
        end
    end)()
end

local function toggleTriggerBot(state)
    triggerBotEnabled = state
    if state then
        triggerBot()
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
                local distance = (player.Character.Head.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
        return closestPlayer
    end

    local oldFireServer
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            oldFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
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
    end
end

local function toggleSilentAim(state)
    silentAimEnabled = state
    if state then
        silentAim()
    end
end

-- Wallbang
local wallbangEnabled = false
local function wallbang()
    local oldFireServer
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            oldFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
                if wallbangEnabled then
                    local args = {...}
                    if args[1] == "Shoot" then
                        local ray = Ray.new(Workspace.CurrentCamera.CFrame.Position, args[2] - Workspace.CurrentCamera.CFrame.Position)
                        local hit, pos = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
                        if hit and hit.Parent:FindFirstChildOfClass("Humanoid") then
                            args[2] = hit.Position
                        end
                    end
                    return oldFireServer(self, unpack(args))
                end
                return oldFireServer(self, ...)
            end
        end
    end
end

local function toggleWallbang(state)
    wallbangEnabled = state
    if state then
        wallbang()
    end
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
        coroutine.wrap(bunnyHop)()
    end
end

-- FOV Changer
local function setFOV(value)
    Workspace.CurrentCamera.FieldOfView = value
end

-- Third Person
local thirdPersonEnabled = false
local function toggleThirdPerson(state)
    thirdPersonEnabled = state
    if state then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
        RunService.RenderStepped:Connect(function()
            if thirdPersonEnabled then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local root = character.HumanoidRootPart
                    Workspace.CurrentCamera.CFrame = CFrame.new(root.Position - root.CFrame.LookVector * 5 + Vector3.new(0, 2, 0), root.Position)
                end
            end
        end)
    else
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

-- No Recoil
local noRecoilEnabled = false
local function noRecoil()
    local oldMouseDelta = UserInputService.GetMouseDelta
    UserInputService.GetMouseDelta = function(...)
        if noRecoilEnabled then
            return Vector2.new(0, 0)
        end
        return oldMouseDelta(...)
    end
end

local function toggleNoRecoil(state)
    noRecoilEnabled = state
    if state then
        noRecoil()
    end
end

-- Instant Respawn
local instantRespawnEnabled = false
local function instantRespawn()
    LocalPlayer.CharacterAdded:Connect(function()
        if instantRespawnEnabled then
            wait(0.1)
            local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("Part")
            if spawn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end

local function toggleInstantRespawn(state)
    instantRespawnEnabled = state
    if state then
        instantRespawn()
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
    coroutine.wrap(function()
        while autoDetectEnabled do
            if Workspace:FindFirstChild("SpawnLocation") then
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
    end)()
end

-- God Mode
local godModeEnabled = false
local function godMode()
    coroutine.wrap(function()
        while godModeEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.Health = 100
            end
            wait(0.1)
        end
    end)()
end

-- Kill Aura
local killAuraEnabled = false
local function killAura()
    coroutine.wrap(function()
        while killAuraEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 10 then
                        player.Character.Humanoid:TakeDamage(100)
                    end
                end
            end
            wait(0.1)
        end
    end)()
end

-- X-Ray
local xrayEnabled = false
local function xray()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            part.Transparency = xrayEnabled and 0.7 or part:GetAttribute("OriginalTransparency") or 0
            if not part:GetAttribute("OriginalTransparency") then
                part:SetAttribute("OriginalTransparency", part.Transparency)
            end
        end
    end
end

-- Fullbright
local fullbrightEnabled = false
local function fullbright()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
    else
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
    end
end

-- Player Chams
local chamsEnabled = false
local function playerChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = chamsEnabled and Enum.Material.Neon or (part:GetAttribute("OriginalMaterial") or Enum.Material.Plastic)
                    part.Color = chamsEnabled and Color3.new(1, 0, 0) or (part:GetAttribute("OriginalColor") or Color3.new(1, 1, 1))
                    if not chamsEnabled then
                        part:SetAttribute("OriginalMaterial", part.Material)
                        part:SetAttribute("OriginalColor", part.Color)
                    end
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
            local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildOfClass("Part")
            if spawn then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end)
end

-- Anti-AFK
local antiAfkEnabled = false
local function antiAfk()
    coroutine.wrap(function()
        while antiAfkEnabled do
            game:GetService("VirtualUser"):CaptureController()
            wait(60)
        end
    end)()
end

-- Gravity Hack
local gravityHackEnabled = false
local gravityValue = 50
local function gravityHack()
    Workspace.Gravity = gravityHackEnabled and gravityValue or 196.2
end

-- No Fall Damage
local noFallDamageEnabled = false
local function noFallDamage()
    coroutine.wrap(function()
        while noFallDamageEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.FallDamageEnabled = false
            end
            wait(0.1)
        end
    end)()
end

-- Item ESP
local itemEspEnabled = false
local itemEspTable = {}
local function createItemESP(item)
    if not (item:IsA("BasePart") or item:IsA("Tool")) then return end
    
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
    coroutine.wrap(function()
        while itemEspEnabled do
            for item, data in pairs(itemEspTable) do
                if not item.Parent then
                    data.billboard:Destroy()
                    itemEspTable[item] = nil
                end
            end
            for _, item in pairs(Workspace:GetDescendants()) do
                if (item:IsA("BasePart") or item:IsA("Tool")) and not itemEspTable[item] then
                    createItemESP(item)
                end
            end
            wait(0.5)
        end
    end)()
end

local function toggleItemESP(state)
    itemEspEnabled = state
    if state then
        for _, item in pairs(Workspace:GetDescendants()) do
            if item:IsA("BasePart") or item:IsA("Tool") then
                createItemESP(item)
            end
        end
        Workspace.DescendantAdded:Connect(createItemESP)
        updateItemESP()
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
            local ray = Workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
            local hit = Workspace:FindPartOnRay(ray)
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
    coroutine.wrap(function()
        while autoClickerEnabled do
            mouse1click()
            wait(0.05)
        end
    end)()
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
        coroutine.wrap(function()
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
        end)()
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

-- Aimbot (External Script Integration)
local aimbotEnabled = false
local function loadAimbot()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()()
    end)
end

local function toggleAimbot(state)
    aimbotEnabled = state
    if state then
        loadAimbot()
    end
end

-- Auto Farm
local autoFarmEnabled = false
local function autoFarm()
    coroutine.wrap(function()
        while autoFarmEnabled do
            for _, item in pairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") or item.Name:lower():find("coin") or item.Name:lower():find("gem") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(item.Position)
                        wait(0.1)
                        local clickDetector = item:FindFirstChildOfClass("ClickDetector")
                        if clickDetector then
                            fireclickdetector(clickDetector)
                        end
                    end
                end
            end
            wait(1)
        end
    end)()
end

local function toggleAutoFarm(state)
    autoFarmEnabled = state
    if state then
        autoFarm()
    end
end

-- Player Teleport List
local function createTeleportDropdown()
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    return players
end

-- ESP Tracers
local tracersEnabled = false
local tracersTable = {}
local function createTracer(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = Color3.new(1, 0, 0)
    line.Thickness = 2
    line.Transparency = 1
    
    tracersTable[player] = {line = line}
end

local function updateTracers()
    coroutine.wrap(function()
        while tracersEnabled do
            for player, data in pairs(tracersTable) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        data.line.From = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                        data.line.To = Vector2.new(screenPos.X, screenPos.Y)
                        data.line.Visible = true
                    else
                        data.line.Visible = false
                    end
                else
                    data.line:Remove()
                    tracersTable[player] = nil
                end
            end
            for _, player in pairs(Players:GetPlayers()) do
                if not tracersTable[player] then
                    createTracer(player)
                end
            end
            wait(0.03)
        end
    end)()
end

local function toggleTracers(state)
    tracersEnabled = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            createTracer(player)
        end
        Players.PlayerAdded:Connect(createTracer)
        updateTracers()
    else
        for _, data in pairs(tracersTable) do
            data.line:Remove()
        end
        tracersTable = {}
    end
end

-- Hitbox Expander
local hitboxExpanderEnabled = false
local hitboxSize = 10
local function hitboxExpander()
    coroutine.wrap(function()
        while hitboxExpanderEnabled do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    root.Size = hitboxExpanderEnabled and Vector3.new(hitboxSize, hitboxSize, hitboxSize) or Vector3.new(2, 2, 1)
                    root.Transparency = hitboxExpanderEnabled and 0.7 or 0
                end
            end
            wait(0.1)
        end
    end)()
end

local function toggleHitboxExpander(state)
    hitboxExpanderEnabled = state
    if state then
        hitboxExpander()
    end
end

-- Speed Boost
local speedBoostEnabled = false
local speedBoostMultiplier = 2
local function speedBoost()
    if speedBoostEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue * speedBoostMultiplier
    end
end

local function toggleSpeedBoost(state)
    speedBoostEnabled = state
    speedBoost()
end

-- Invisible Mode
local invisibleEnabled = false
local function invisible()
    if invisibleEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        LocalPlayer.Character.HumanoidRootPart.Transparency = 1
    else
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = part:GetAttribute("OriginalTransparency") or 0
            end
        end
        LocalPlayer.Character.HumanoidRootPart.Transparency = 0
    end
end

local function toggleInvisible(state)
    invisibleEnabled = state
    invisible()
end

-- Auto Reload
local autoReloadEnabled = false
local function autoReload()
    coroutine.wrap(function()
        while autoReloadEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool:FindFirstChild("Ammo") and tool.Ammo.Value <= 0 then
                    local reloadRemote = tool:FindFirstChild("Reload")
                    if reloadRemote then
                        reloadRemote:FireServer()
                    end
                end
            end
            wait(0.5)
        end
    end)()
end

local function toggleAutoReload(state)
    autoReloadEnabled = state
    if state then
        autoReload()
    end
end

-- F3X Integration
local function loadF3X()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GroggyDev/F3X-Building-Tools/master/source.lua"))()
    end)
end

-- Feature List
local featureList = {
    {name = "Fly", toggle = function(state) flying = state; if state then startFly() else stopFly() end end},
    {name = "ESP", toggle = toggleESP},
    {name = "Silent Aim", toggle = toggleSilentAim},
    {name = "Trigger Bot", toggle = toggleTriggerBot},
    {name = "Wallbang", toggle = toggleWallbang},
    {name = "Bunny Hop", toggle = toggleBunnyHop},
    {name = "Kill Aura", toggle = function(state) killAuraEnabled = state; if state then killAura() end end},
    {name = "Third Person", toggle = toggleThirdPerson},
    {name = "No Recoil", toggle = toggleNoRecoil},
    {name = "Instant Respawn", toggle = toggleInstantRespawn},
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
    {name = "Minimap", toggle = toggleMinimap},
    {name = "Aimbot", toggle = toggleAimbot},
    {name = "Auto Farm", toggle = toggleAutoFarm},
    {name = "ESP Tracers", toggle = toggleTracers},
    {name = "Hitbox Expander", toggle = toggleHitboxExpander},
    {name = "Speed Boost", toggle = toggleSpeedBoost},
    {name = "Invisible Mode", toggle = toggleInvisible},
    {name = "Auto Reload", toggle = toggleAutoReload}
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

local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Movement Features")

MovementSection:NewToggle("Fly", "Toggle flying", function(state)
    flying = state
    if state then
        startFly()
    else
        stopFly()
    end
end)

MovementSection:NewSlider("Fly Speed", "Adjust fly speed", 100, 10, function(value)
    flySpeed = value
end)

MovementSection:NewToggle("Speed Hack", "Toggle speed hack", function(state)
    speedHackEnabled = state
    speedHack()
end)

MovementSection:NewSlider("Speed Value", "Adjust speed", 100, 16, function(value)
    speedValue = value
    speedHack()
end)

MovementSection:NewToggle("Speed Boost", "Toggle temporary speed boost", function(state)
    toggleSpeedBoost(state)
end)

MovementSection:NewSlider("Speed Boost Multiplier", "Adjust boost multiplier", 5, 1, function(value)
    speedBoostMultiplier = value
    speedBoost()
end)

MovementSection:NewToggle("Noclip", "Toggle noclip", function(state)
    noclipEnabled = state
    if state then
        noclip()
    end
end)

MovementSection:NewToggle("No Clip Speed Boost", "Toggle no clip speed boost", function(state)
    noClipSpeedBoostEnabled = state
    noClipSpeedBoost()
end)

MovementSection:NewSlider("No Clip Speed Value", "Adjust no clip speed", 200, 50, function(value)
    noClipSpeedValue = value
    noClipSpeedBoost()
end)

MovementSection:NewToggle("Infinite Jump", "Toggle infinite jump", function(state)
    infJumpEnabled = state
    if state then
        infiniteJump()
    end
end)

MovementSection:NewToggle("Super Jump", "Toggle super jump", function(state)
    superJumpEnabled = state
    superJump()
end)

MovementSection:NewSlider("Super Jump Value", "Adjust jump power", 200, 50, function(value)
    superJumpValue = value
    superJump()
end)

MovementSection:NewToggle("Bunny Hop", "Toggle bunny hop", function(state)
    toggleBunnyHop(state)
end)

MovementSection:NewToggle("Gravity Hack", "Toggle gravity hack", function(state)
    gravityHackEnabled = state
    gravityHack()
end)

MovementSection:NewSlider("Gravity Value", "Adjust gravity", 100, 0, function(value)
    gravityValue = value
    gravityHack()
end)

MovementSection:NewToggle("Click TP", "Toggle click teleport", function(state)
    clickTpEnabled = state
    if state then
        clickTp()
    end
end)

MovementSection:NewTextBox("Teleport to Player", "Enter player name", function(text)
    teleportToPlayer(text)
end)

MovementSection:NewDropdown("Teleport to Player", "Select player to teleport", createTeleportDropdown(), function(playerName)
    teleportToPlayer(playerName)
end)

local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Combat Features")

CombatSection:NewToggle("Silent Aim", "Toggle silent aim", function(state)
    toggleSilentAim(state)
end)

CombatSection:NewToggle("Aimbot", "Toggle aimbot", function(state)
    toggleAimbot(state)
end)

CombatSection:NewToggle("Trigger Bot", "Toggle trigger bot", function(state)
    toggleTriggerBot(state)
end)

CombatSection:NewSlider("Trigger Bot FOV", "Adjust trigger bot FOV", 200, 10, function(value)
    triggerBotFOV = value
end)

CombatSection:NewToggle("Wallbang", "Toggle wallbang", function(state)
    toggleWallbang(state)
end)

CombatSection:NewToggle("No Recoil", "Toggle no recoil", function(state)
    toggleNoRecoil(state)
end)

CombatSection:NewToggle("Kill Aura", "Toggle kill aura", function(state)
    killAuraEnabled = state
    if state then
        killAura()
    end
end)

CombatSection:NewToggle("Hitbox Expander", "Toggle hitbox expander", function(state)
    toggleHitboxExpander(state)
end)

CombatSection:NewSlider("Hitbox Size", "Adjust hitbox size", 20, 5, function(value)
    hitboxSize = value
    hitboxExpander()
end)

CombatSection:NewToggle("Auto Reload", "Toggle auto reload", function(state)
    toggleAutoReload(state)
end)

local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("Visual Features")

VisualsSection:NewToggle("ESP", "Toggle ESP", function(state)
    toggleESP(state)
end)

VisualsSection:NewToggle("ESP Tracers", "Toggle ESP tracers", function(state)
    toggleTracers(state)
end)

VisualsSection:NewToggle("Player Chams", "Toggle player chams", function(state)
    chamsEnabled = state
    playerChams()
end)

VisualsSection:NewToggle("Item ESP", "Toggle item ESP", function(state)
    toggleItemESP(state)
end)

VisualsSection:NewToggle("Minimap", "Toggle minimap", function(state)
    toggleMinimap(state)
end)

VisualsSection:NewSlider("Minimap Size", "Adjust minimap size", 300, 100, function(value)
    minimapSize = value
    if minimapEnabled then
        toggleMinimap(false)
        toggleMinimap(true)
    end
end)

VisualsSection:NewSlider("Minimap Zoom", "Adjust minimap zoom", 100, 10, function(value)
    minimapZoom = value
end)

VisualsSection:NewToggle("X-Ray", "Toggle X-Ray vision", function(state)
    xrayEnabled = state
    xray()
end)

VisualsSection:NewToggle("Fullbright", "Toggle fullbright", function(state)
    fullbrightEnabled = state
    fullbright()
end)

VisualsSection:NewToggle("Third Person", "Toggle third person view", function(state)
    toggleThirdPerson(state)
end)

VisualsSection:NewSlider("FOV", "Adjust field of view", 120, 70, function(value)
    setFOV(value)
end)

local UtilityTab = Window:NewTab("Utility")
local UtilitySection = UtilityTab:NewSection("Utility Features")

UtilitySection:NewToggle("God Mode", "Toggle god mode", function(state)
    godModeEnabled = state
    if state then
        godMode()
    end
end)

UtilitySection:NewToggle("Invisible Mode", "Toggle invisible mode", function(state)
    toggleInvisible(state)
end)

UtilitySection:NewToggle("Auto Farm", "Toggle auto farm", function(state)
    toggleAutoFarm(state)
end)

UtilitySection:NewToggle("Auto Clicker", "Toggle auto clicker", function(state)
    autoClickerEnabled = state
    if state then
        autoClicker()
    end
end)

UtilitySection:NewToggle("Auto Respawn", "Toggle auto respawn", function(state)
    autoRespawnEnabled = state
    if state then
        autoRespawn()
    end
end)

UtilitySection:NewToggle("Instant Respawn", "Toggle instant respawn", function(state)
    toggleInstantRespawn(state)
end)

UtilitySection:NewToggle("No Fall Damage", "Toggle no fall damage", function(state)
    noFallDamageEnabled = state
    if state then
        noFallDamage()
    end
end)

UtilitySection:NewToggle("Anti-AFK", "Toggle anti-AFK", function(state)
    antiAfkEnabled = state
    if state then
        antiAfk()
    end
end)

UtilitySection:NewToggle("Auto-Detect Features", "Toggle auto-detection", function(state)
    autoDetectEnabled = state
    if state then
        autoDetectFeatures()
    end
end)

UtilitySection:NewTextBox("Player Tracker", "Enter player name to track", function(text)
    trackerEnabled = true
    trackPlayer(text)
end)

UtilitySection:NewButton("Infinite Yield", "Load Infinite Yield admin script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

UtilitySection:NewButton("Load F3X", "Load F3X Building Tools", function()
    loadF3X()
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
    toggleThirdPerson(false)
    toggleInstantRespawn(false)
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
    toggleMinimap(false)
    toggleAimbot(false)
    toggleAutoFarm(false)
    toggleTracers(false)
    toggleHitboxExpander(false)
    toggleSpeedBoost(false)
    toggleInvisible(false)
    toggleAutoReload(false)
end)
