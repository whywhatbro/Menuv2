-- =================================================================
-- KING LEGACY - ULTIMATE SEA EVENT & CHEST FARM HUB (CUSTOM REDZ STYLE)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- GOBLAL CONFIGURATION
getgenv().KL_Hub = {
    AutoSeaEvent = false,
    AutoAttack = false,
    AutoSkills = {Z = true, X = true, C = true, V = true, E = true},
    AutoChest = false,
    AutoBuso = true,
    AutoHop = false,
    SafeDistance = 35,
    TweenSpeed = 300,
    HopDelay = 10
}

local VisitedServers = {}
local isAttacking = false

-- 1. CHỐNG VĂNG GAME & NOCLIP (NO-COLLISION)
local NoclipConn
local function SetNoclip(state)
    if state then
        if not NoclipConn then
            NoclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    end
end

-- 2. TWEEN DI CHUYỂN AN TOÀN
local currentTween
local function SafeTween(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    if dist < 5 then return end

    SetNoclip(true)
    local duration = dist / getgenv().KL_Hub.TweenSpeed
    
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()

    currentTween.Completed:Connect(function()
        SetNoclip(false)
    end)
end

-- 3. AUTO BẬT BUSOSHOKU HAKI (KING LEGACY REMOTE)
task.spawn(function()
    while task.wait(1) do
        if getgenv().KL_Hub.AutoBuso and LocalPlayer.Character then
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function()
                    ReplicatedStorage.Remotes.Functions.Buso:InvokeServer()
                end)
            end
        end
    end
end)

-- 4. TÌM SEA EVENT TRONG KING LEGACY
local function GetKingLegacyBoss()
    for _, entity in pairs(Workspace:GetChildren()) do
        if entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0 and entity:FindFirstChild("HumanoidRootPart") then
            local name = string.lower(entity.Name)
            if name:find("sea king") or name:find("ghost ship") or name:find("hydra") or name:find("kraken") or name:find("sea monster") or name:find("drakenfyr") or name:find("beast") then
                return entity
            end
        end
    end
    return nil
end

-- 5. TỰ ĐỘNG ĐÁNH VÀ XẢ SKILL
local function ExecuteAttack()
    local char = LocalPlayer.Character
    if not char then return end

    -- Equip Weapon
    local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
    if tool and tool.Parent == LocalPlayer.Backpack then
        char.Humanoid:EquipTool(tool)
    end

    if tool then
        tool:Activate()
        
        -- Spam Skill đã chọn
        for skillKey, enabled in pairs(getgenv().KL_Hub.AutoSkills) do
            if enabled then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skillKey], false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skillKey], false, game)
            end
        end
    end
end

-- 6. GOM RƯƠNG TRÊN BẢN ĐỒ
local function CollectChests()
    for _, v in pairs(Workspace:GetDescendants()) do
        if getgenv().KL_Hub.AutoChest and (v.Name:find("Chest") or v.Name:find("Rương") or v.Name:find("Treasure")) then
            local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
            if part then
                SafeTween(part.CFrame * CFrame.new(0, 3, 0))
                task.wait(0.3)
                
                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or part:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end

-- 7. SMART HOP SERVER
local function SmartHopServer()
    print("[King Legacy Hub] Đang nhảy Server mới...")
    SetNoclip(false)
    
    local placeId = game.PlaceId
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)

    if success and result then
        local body = HttpService:JSONDecode(result)
        if body and body.data then
            for _, server in ipairs(body.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId and not VisitedServers[server.id] then
                    VisitedServers[server.id] = true
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    task.wait(5)
                    break
                end
            end
        end
    end
end

-- 8. GIAO DIỆN UI HUB ĐẸP MẮT (MOBILE & PC)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_Ultimate_Hub"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
ToggleBtn.Text = "KL"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 20
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "👑 KING LEGACY HUB | SEA EVENT"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -45)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 450)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 6)

local function CreateToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(40, 40, 50)
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(40, 40, 50)
        callback(state)
    end)
end

-- CÁC NÚT ĐIỀU KHIỂN SCRIPT
CreateToggle("Auto Sea Event", getgenv().KL_Hub.AutoSeaEvent, function(s) getgenv().KL_Hub.AutoSeaEvent = s end)
CreateToggle("Auto Attack", getgenv().KL_Hub.AutoAttack, function(s) getgenv().KL_Hub.AutoAttack = s end)
CreateToggle("Auto Collect Chests", getgenv().KL_Hub.AutoChest, function(s) getgenv().KL_Hub.AutoChest = s end)
CreateToggle("Auto Hop Server", getgenv().KL_Hub.AutoHop, function(s) getgenv().KL_Hub.AutoHop = s end)
CreateToggle("Auto Buso Haki", getgenv().KL_Hub.AutoBuso, function(s) getgenv().KL_Hub.AutoBuso = s end)

-- NÚT BẬT/TẮT SKILL TỰ ĐỘNG
for _, skill in ipairs({"Z", "X", "C", "V", "E"}) do
    CreateToggle("Use Skill [" .. skill .. "]", getgenv().KL_Hub.AutoSkills[skill], function(s)
        getgenv().KL_Hub.AutoSkills[skill] = s
    end)
end

-- 9. MAIN AUTOMATION LOOP
task.spawn(function()
    local noBossTimer = 0
    while task.wait(0.2) do
        if getgenv().KL_Hub.AutoSeaEvent then
            local boss = GetKingLegacyBoss()
            
            if boss and boss:FindFirstChild("HumanoidRootPart") and boss.Humanoid.Health > 0 then
                noBossTimer = 0
                
                -- Đứng an toàn trên đầu Sea Event
                local targetCFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().KL_Hub.SafeDistance, 0)
                SafeTween(targetCFrame)

                if getgenv().KL_Hub.AutoAttack then
                    ExecuteAttack()
                end
            else
                -- Tự động gom rương nếu không thấy Boss
                if getgenv().KL_Hub.AutoChest then
                    CollectChests()
                end

                -- Đếm thời gian đỗ bến để Hop Server
                noBossTimer = noBossTimer + 0.2
                if getgenv().KL_Hub.AutoHop and noBossTimer >= getgenv().KL_Hub.HopDelay then
                    SmartHopServer()
                    noBossTimer = 0
                end
            end
        end
    end
end)
