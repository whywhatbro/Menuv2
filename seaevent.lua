-- KING LEGACY: FULL AUTO SYSTEM (SEA EVENTS + NEAREST MOBS + CHESTS)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CONFIG_FILE = "KL_Full_Config.json"

local Config = {
    Enabled = true,
    AutoAttack = true,
    FarmNearest = true, -- TỰ ĐỘNG ĐÁNH QUÁI GẦN NẾU KHÔNG CÓ BOSS
    AutoChest = true,
    AttackDistance = 9,
    MaxMobDistance = 1000, -- Khoảng cách tối đa quét quái gần (Meters)
    MainWeapon = "Melee", -- Melee / Sword / Blox Fruit
    SubWeapons = { ["Melee"] = false, ["Sword"] = true, ["Blox Fruit"] = true },
    UseSkills = { Z = true, X = true, C = true, V = true, E = true },
    HopCountdown = 3,
    MaxWaitTime = 180,
    MaxPlayerLimit = 10,
    HopDelayAfterKill = 10,
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

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_Full_System_GUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = UDim2.new(0.5, -160, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "KING LEGACY - FULL FARM & EVENT"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 50)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "⚡ Khởi tạo hệ thống..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 0, 400)
Scroll.Position = UDim2.new(0, 10, 0, 90)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
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

-- CONTROLS
CreateButton("AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT"), Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40), function(btn)
    Config.Enabled = not Config.Enabled
    btn.Text = "AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    isHopping = false
end)

CreateButton("AUTO ATTACK BOSS: " .. (Config.AutoAttack and "BẬT" or "TẮT"), Config.AutoAttack and Color3.fromRGB(200, 120, 0) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.AutoAttack = not Config.AutoAttack
    btn.Text = "AUTO ATTACK BOSS: " .. (Config.AutoAttack and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.AutoAttack and Color3.fromRGB(200, 120, 0) or Color3.fromRGB(60, 60, 70)
end)

CreateButton("FARM QUÁI GẦN (TEST): " .. (Config.FarmNearest and "BẬT" or "TẮT"), Config.FarmNearest and Color3.fromRGB(0, 180, 180) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.FarmNearest = not Config.FarmNearest
    btn.Text = "FARM QUÁI GẦN (TEST): " .. (Config.FarmNearest and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.FarmNearest and Color3.fromRGB(0, 180, 180) or Color3.fromRGB(60, 60, 70)
end)

CreateButton("AUTO NHẶT RƯƠNG: " .. (Config.AutoChest and "BẬT" or "TẮT"), Config.AutoChest and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.AutoChest = not Config.AutoChest
    btn.Text = "AUTO NHẶT RƯƠNG: " .. (Config.AutoChest and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.AutoChest and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70)
end)

-- LOGIC CẦM VŨ KHÍ
local function EquipWeaponByType(weaponType)
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return false end

    local allTools = {}
    for _, item in pairs(backpack:GetChildren()) do if item:IsA("Tool") then table.insert(allTools, item) end end
    for _, item in pairs(char:GetChildren()) do if item:IsA("Tool") then table.insert(allTools, item) end end

    for _, tool in pairs(allTools) do
        local name = tool.Name:lower()
        local isMatch = false

        if weaponType == "Melee" and (name:find("style") or name:find("combat") or name:find("leg") or name:find("fist") or name:find("claw") or name:find("karate")) then isMatch = true
        elseif weaponType == "Sword" and not name:find("fruit") and not name:find("style") and not name:find("combat") then isMatch = true
        elseif weaponType == "Blox Fruit" and (name:find("fruit") or tool:FindFirstChild("Fruit")) then isMatch = true end

        if isMatch then
            if tool.Parent ~= char then char.Humanoid:EquipTool(tool) task.wait(0.05) end
            return true
        end
    end
    return false
end

-- LOGIC QUÉT BOSS EVENT
local function FindTargetBoss()
    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find(eventName:lower()) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if not hum or (hum and hum.Health > 0) then return obj, eventName end
                end
            end
        end
    end
    return nil, nil
end

-- LOGIC QUÉT QUÁI GẦN
local function FindNearestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local closestMob = nil
    local minDistance = Config.MaxMobDistance

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj ~= char then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            
            -- Không quét Player khác
            local isPlayer = Players:GetPlayerFromCharacter(obj)
            if hum and hum.Health > 0 and part and not isPlayer then
                local dist = (part.Position - myPos).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestMob = obj
                end
            end
        end
    end
    return closestMob
end

-- TẤN CÔNG MỤC TIÊU (BOSS HOẶC QUÁI GẦN)
local function AttackTarget(targetObj, targetName, isBoss)
    isAttacking = true
    StatusLabel.Text = string.format("⚔️ ĐANG ĐÁNH %s: %s", isBoss and "BOSS" or "QUÁI", targetName)
    StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)

    task.spawn(function()
        while targetObj and targetObj.Parent and isAttacking and (Config.AutoAttack or Config.FarmNearest) do
            local hum = targetObj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then break end

            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPart = targetObj:FindFirstChild("HumanoidRootPart") or targetObj.PrimaryPart or targetObj:FindFirstChildWhichIsA("BasePart")
                
                if targetPart then
                    -- Bay lơ lửng trên đầu quái
                    char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, Config.AttackDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)

                    -- Xả skill phụ
                    for _, wpType in ipairs({"Melee", "Sword", "Blox Fruit"}) do
                        if wpType ~= Config.MainWeapon and Config.SubWeapons[wpType] then
                            if EquipWeaponByType(wpType) then
                                for skillKey, enabled in pairs(Config.UseSkills) do
                                    if enabled then
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skillKey], false, game)
                                        task.wait(0.02)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skillKey], false, game)
                                    end
                                end
                            end
                        end
                    end

                    -- Đổi về vũ khí chính đánh M1
                    EquipWeaponByType(Config.MainWeapon)
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    VirtualUser:ClickButton1(Vector2.new(0,0))
                end
            end
            task.wait(0.08)
        end
        isAttacking = false
    end)
end

-- VÒNG LẶP CHÍNH CONTROL
task.spawn(function()
    while true do
        if not isAttacking then
            -- 1. Ưu tiên tìm Sea Event Boss
            local bossObj, bossName = FindTargetBoss()
            if bossObj and Config.AutoAttack then
                AttackTarget(bossObj, bossName, true)
            
            -- 2. Nếu không có Boss -> Tự động đánh quái gần nhất để Test
            elseif Config.FarmNearest then
                local mobObj = FindNearestMob()
                if mobObj then
                    AttackTarget(mobObj, mobObj.Name, false)
                else
                    StatusLabel.Text = "🔍 Không thấy quái xung quanh..."
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                end
            else
                StatusLabel.Text = "⚡ Đang chờ Event hoặc bật Farm Quái Gần"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
        end
        task.wait(1)
    end
end)
