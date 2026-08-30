-- KING LEGACY: MAIN WEAPON M1 + SUB WEAPON SKILLS SPAMMER
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CONFIG_FILE = "KL_SeaEvent_Config.json"

local EVENT_INTERVALS = {
    ["Sea King"]       = 3600,
    ["Ghost Ship"]     = 6000,
    ["Hydra"]          = 14400,
    ["Kraken"]         = 7200,  
    ["Drakenfyr"]      = 7200,  
    ["Abyssal Tyrant"] = 7200,  
    ["Crab"]           = 7200   
}

local Config = {
    Enabled = true,
    AutoAttack = true,
    AutoChest = true,
    AttackDistance = 9,
    MainWeapon = "Melee", -- Vũ khí chính (Đánh M1): Melee / Sword / Blox Fruit
    SubWeapons = {
        ["Melee"] = false,
        ["Sword"] = true,
        ["Blox Fruit"] = true
    },
    UseSkills = { Z = true, X = true, C = true, V = true, E = true },
    HopCountdown = 3,
    MaxWaitTime = 180,
    MaxPlayerLimit = 10,
    HopDelayAfterKill = 15,
    SelectedEvents = {
        ["Sea King"]       = true,
        ["Ghost Ship"]     = true,
        ["Hydra"]          = true,
        ["Kraken"]         = false,
        ["Drakenfyr"]      = false,
        ["Abyssal Tyrant"] = false,
        ["Crab"]           = false
    }
}

local isHopping = false
local isAttacking = false
local visitedServers = {}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- LOAD/SAVE CONFIG
local function SaveConfig()
    if writefile then pcall(writefile, CONFIG_FILE, HttpService:JSONEncode(Config)) end
end

local function LoadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if success and type(result) == "table" then
            for k, v in pairs(result) do Config[k] = v end
        end
    end
end
LoadConfig()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_DualWeapon_Scanner"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleMenuBtn.Position = UDim2.new(0, 10, 0.4, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ToggleMenuBtn.Text = "MENU [ON]"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.TextSize = 13
ToggleMenuBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 520)
MainFrame.Position = UDim2.new(0.5, -165, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleMenuBtn.Text = MainFrame.Visible and "MENU [ON]" or "MENU [OFF]"
    ToggleMenuBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80)
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "KL - DUAL WEAPON SYSTEM"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 50)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "⚡ Đang khởi động..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 0, 420)
Scroll.Position = UDim2.new(0, 10, 0, 90)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)

local function CreateButton(text, bg, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = bg
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- CONTROLS MAIN TOGGLES
CreateButton("AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT"), Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40), function(btn)
    Config.Enabled = not Config.Enabled
    btn.Text = "AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    isHopping = false
    SaveConfig()
end)

CreateButton("AUTO ATTACK BOSS: " .. (Config.AutoAttack and "BẬT" or "TẮT"), Config.AutoAttack and Color3.fromRGB(200, 120, 0) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.AutoAttack = not Config.AutoAttack
    btn.Text = "AUTO ATTACK BOSS: " .. (Config.AutoAttack and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.AutoAttack and Color3.fromRGB(200, 120, 0) or Color3.fromRGB(60, 60, 70)
    SaveConfig()
end)

CreateButton("AUTO NHẶT RƯƠNG: " .. (Config.AutoChest and "BẬT" or "TẮT"), Config.AutoChest and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.AutoChest = not Config.AutoChest
    btn.Text = "AUTO NHẶT RƯƠNG: " .. (Config.AutoChest and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.AutoChest and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70)
    SaveConfig()
end)

-- TEXTBOX TẦM ĐÁNH
local DistFrame = Instance.new("Frame")
DistFrame.Size = UDim2.new(1, -8, 0, 30)
DistFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
DistFrame.Parent = Scroll

local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0.6, 0, 1, 0)
DistLabel.Text = "Tầm Đánh (Meters):"
DistLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DistLabel.Font = Enum.Font.SourceSansBold
DistLabel.TextSize = 12
DistLabel.BackgroundTransparency = 1
DistLabel.Parent = DistFrame

local DistBox = Instance.new("TextBox")
DistBox.Size = UDim2.new(0.35, 0, 0.8, 0)
DistBox.Position = UDim2.new(0.62, 0, 0.1, 0)
DistBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
DistBox.Text = tostring(Config.AttackDistance)
DistBox.TextColor3 = Color3.fromRGB(0, 255, 150)
DistBox.Font = Enum.Font.SourceSansBold
DistBox.TextSize = 12
DistBox.Parent = DistFrame

DistBox.FocusLost:Connect(function()
    local val = tonumber(DistBox.Text)
    if val then Config.AttackDistance = val SaveConfig() else DistBox.Text = tostring(Config.AttackDistance) end
end)

-- CHỌN VŨ KHÍ CHÍNH (ĐÁNH M1)
local MainHeader = Instance.new("TextLabel")
MainHeader.Size = UDim2.new(1, -8, 0, 20)
MainHeader.Text = "--- VŨ KHÍ CHÍNH (ĐÁNH M1) ---"
MainHeader.TextColor3 = Color3.fromRGB(0, 255, 150)
MainHeader.Font = Enum.Font.SourceSansBold
MainHeader.TextSize = 12
MainHeader.BackgroundTransparency = 1
MainHeader.Parent = Scroll

CreateButton("VŨ KHÍ CHÍNH: " .. Config.MainWeapon, Color3.fromRGB(0, 150, 150), function(btn)
    if Config.MainWeapon == "Melee" then Config.MainWeapon = "Sword"
    elseif Config.MainWeapon == "Sword" then Config.MainWeapon = "Blox Fruit"
    else Config.MainWeapon = "Melee" end
    btn.Text = "VŨ KHÍ CHÍNH: " .. Config.MainWeapon
    SaveConfig()
end)

-- CHỌN VŨ KHÍ PHỤ (SPAM SKILL)
local SubHeader = Instance.new("TextLabel")
SubHeader.Size = UDim2.new(1, -8, 0, 20)
SubHeader.Text = "--- VŨ KHÍ PHỤ (SPAM SKILL) ---"
SubHeader.TextColor3 = Color3.fromRGB(0, 255, 150)
SubHeader.Font = Enum.Font.SourceSansBold
SubHeader.TextSize = 12
SubHeader.BackgroundTransparency = 1
SubHeader.Parent = Scroll

for _, wpType in ipairs({"Melee", "Sword", "Blox Fruit"}) do
    CreateButton("Spam Skill " .. wpType .. ": " .. (Config.SubWeapons[wpType] and "BẬT" or "TẮT"), Config.SubWeapons[wpType] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60), function(btn)
        Config.SubWeapons[wpType] = not Config.SubWeapons[wpType]
        btn.Text = "Spam Skill " .. wpType .. ": " .. (Config.SubWeapons[wpType] and "BẬT" or "TẮT")
        btn.BackgroundColor3 = Config.SubWeapons[wpType] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60)
        SaveConfig()
    end)
end

-- BẬT/TẮT PHÍM SKILL
local SkillHeader = Instance.new("TextLabel")
SkillHeader.Size = UDim2.new(1, -8, 0, 20)
SkillHeader.Text = "--- CHỌN SKILL SỬ DỤNG ---"
SkillHeader.TextColor3 = Color3.fromRGB(0, 255, 150)
SkillHeader.Font = Enum.Font.SourceSansBold
SkillHeader.TextSize = 12
SkillHeader.BackgroundTransparency = 1
SkillHeader.Parent = Scroll

for _, key in ipairs({"Z", "X", "C", "V", "E"}) do
    CreateButton("Skill [" .. key .. "]: " .. (Config.UseSkills[key] and "BẬT" or "TẮT"), Config.UseSkills[key] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60), function(btn)
        Config.UseSkills[key] = not Config.UseSkills[key]
        btn.Text = "Skill [" .. key .. "]: " .. (Config.UseSkills[key] and "BẬT" or "TẮT")
        btn.BackgroundColor3 = Config.UseSkills[key] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60)
        SaveConfig()
    end)
end

-- BOSS EVENTS
local EventHeader = Instance.new("TextLabel")
EventHeader.Size = UDim2.new(1, -8, 0, 20)
EventHeader.Text = "--- CHỌN SEA EVENT HOP ---"
EventHeader.TextColor3 = Color3.fromRGB(0, 255, 150)
EventHeader.Font = Enum.Font.SourceSansBold
EventHeader.TextSize = 12
EventHeader.BackgroundTransparency = 1
EventHeader.Parent = Scroll

for eventName, isEnabled in pairs(Config.SelectedEvents) do
    CreateButton(eventName .. " [" .. (isEnabled and "BẬT" or "TẮT") .. "]", isEnabled and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60), function(btn)
        Config.SelectedEvents[eventName] = not Config.SelectedEvents[eventName]
        btn.BackgroundColor3 = Config.SelectedEvents[eventName] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60)
        btn.Text = eventName .. " [" .. (Config.SelectedEvents[eventName] and "BẬT" or "TẮT") .. "]"
        SaveConfig()
    end)
end

-- LOGIC CẦM VŨ KHÍ THEO LOẠI
local function EquipSpecificWeapon(weaponType)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return false end

    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local isMatch = false
            if weaponType == "Melee" and (item.ToolTip:find("Melee") or item.Name:find("Combat") or item.Name:find("Dark Step")) then isMatch = true
            elseif weaponType == "Sword" and item:FindFirstChild("Sword") then isMatch = true
            elseif weaponType == "Blox Fruit" and item:FindFirstChild("Fruit") then isMatch = true end

            if isMatch then
                char.Humanoid:EquipTool(item)
                return true
            end
        end
    end
    return false
end

-- AUTO NHẶT RƯƠNG
local function AutoCollectChests()
    if not Config.AutoChest then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("chest") and obj:IsA("BasePart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = obj.CFrame
                task.wait(0.2)
            end
        end
    end
end

-- SMART HOPPER
local function SmartHop()
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
    local cursor = ""
    local targetServer = nil

    for page = 1, 6 do
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s", PlaceId, (cursor ~= "" and "&cursor=" .. cursor or ""))
        local success, response = pcall(function()
            if httpRequest then return httpRequest({Url = url, Method = "GET"}).Body else return game:HttpGet(url) end
        end)

        if success and response then
            local decodeOk, data = pcall(function() return HttpService:JSONDecode(response) end)
            if decodeOk and data and data.data then
                local candidates = {}
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and not visitedServers[s.id] and s.playing <= Config.MaxPlayerLimit and s.playing > 1 then
                        table.insert(candidates, s.id)
                    end
                end

                if #candidates > 0 then
                    targetServer = candidates[math.random(1, #candidates)]
                    break
                end
                cursor = data.nextPageCursor or ""
                if cursor == "" then break end
            end
        end
        task.wait(0.05)
    end

    if targetServer then
        visitedServers[targetServer] = true
        TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, LocalPlayer)
    else
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end

-- HÀM SPAM CHIÊU CHO 1 VŨ KHÍ
local function CastSkillsForWeapon(wpType)
    if not Config.SubWeapons[wpType] then return end
    if EquipSpecificWeapon(wpType) then
        task.wait(0.05)
        for skillKey, enabled in pairs(Config.UseSkills) do
            if enabled then
                local keyEnum = Enum.KeyCode[skillKey]
                VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
            end
        end
    end
end

-- HÀM AUTO ATTACK NÂNG CẤP DUAL WEAPONS
local function AutoAttackTarget(bossModel)
    isAttacking = true
    StatusLabel.Text = "⚔️ ĐANG ĐÁNH M1 & SPAM SKILL: " .. bossModel.Name
    StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)

    task.spawn(function()
        while bossModel and bossModel.Parent and isAttacking and Config.AutoAttack do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPart = bossModel:FindFirstChild("HumanoidRootPart") or bossModel:FindFirstChildWithClass("Part") or bossModel.PrimaryPart
                
                if targetPart then
                    -- Teleport cố định vị trí theo tầm đánh đã nhập
                    char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, Config.AttackDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- 1. Chuyển sang Vũ Khí Phụ để Xả Skill
                    for _, wpType in ipairs({"Melee", "Sword", "Blox Fruit"}) do
                        if wpType ~= Config.MainWeapon then
                            CastSkillsForWeapon(wpType)
                        end
                    end

                    -- 2. Đổi về Vũ Khí Chính để đánh M1 liên tục
                    EquipSpecificWeapon(Config.MainWeapon)
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)

                    -- 3. Xả luôn Skill của Vũ Khí Chính (nếu được bật)
                    if Config.SubWeapons[Config.MainWeapon] then
                        for skillKey, enabled in pairs(Config.UseSkills) do
                            if enabled then
                                local keyEnum = Enum.KeyCode[skillKey]
                                VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
                                task.wait(0.02)
                                VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
                            end
                        end
                    end
                end
            end
            task.wait(0.05)
        end
        isAttacking = false
    end)
end

-- SCANNER & LOOP
local function ScanSelectedMilestones()
    local uptime = workspace.DistributedGameTime

    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:lower():find(eventName:lower()) then
                    return true, eventName, 0, uptime, obj
                end
            end
        end
    end

    local minTimeToMilestone = 999999
    local targetEventName = nil

    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected and EVENT_INTERVALS[eventName] then
            local interval = EVENT_INTERVALS[eventName]
            local timeToNext = interval - (uptime % interval)

            if timeToNext < minTimeToMilestone then
                minTimeToMilestone = timeToNext
                targetEventName = eventName
            end
        end
    end

    return false, targetEventName, math.floor(minTimeToMilestone), math.floor(uptime), nil
end

local function StartHopCountdown()
    isHopping = true
    for i = Config.HopCountdown, 1, -1 do
        if not Config.Enabled or not isHopping then
            StatusLabel.Text = "🛑 ĐÃ HỦY HOP SERVER!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
            isHopping = false
            return
        end
        StatusLabel.Text = string.format("❌ Không có Boss thích hợp!\n⏳ Hop Server sau: %d giây...", i)
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1)
    end

    if Config.Enabled and isHopping then
        StatusLabel.Text = "⚡ Đang di chuyển Server..."
        SmartHop()
    end
end

local function RunCheck()
    if not Config.Enabled or isHopping then return end

    local isSpawned, eventName, timeRemaining, currentUptime, bossObject = ScanSelectedMilestones()
    local uptimeMin = math.floor(currentUptime / 60)
    local uptimeSec = currentUptime % 60

    if isSpawned and bossObject then
        if Config.AutoAttack and not isAttacking then
            AutoAttackTarget(bossObject)
        end

        repeat task.wait(2) until not bossObject or not bossObject.Parent or not Config.Enabled

        isAttacking = false
        if Config.Enabled then
            StatusLabel.Text = "🎁 Boss gục! Tự động gom rương & chờ Hop..."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
            AutoCollectChests()
            task.wait(Config.HopDelayAfterKill)
            StartHopCountdown()
        end

    elseif timeRemaining <= Config.MaxWaitTime then
        StatusLabel.Text = string.format("🎯 ĐÃ VÀO SERVER PHÙ HỢP!\nUptime: %d m %d s\n%s Spawn sau: %d s", uptimeMin, uptimeSec, tostring(eventName), timeRemaining)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    else
        StartHopCountdown()
    end
end

task.spawn(function()
    task.wait(0.5)
    while true do
        RunCheck()
        task.wait(1)
    end
end)
