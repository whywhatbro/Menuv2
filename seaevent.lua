-- KING LEGACY: FIXED NPC TARGETING ISSUE
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local CONFIG_FILE = "KL_FixNPC_Config.json"

local Config = {
    Enabled = true,
    AutoAttack = true,
    FarmNearest = true,
    AutoChest = true,
    AttackDistance = 9,
    MaxMobDistance = 1000,
    MainWeapon = "Melee",
    SubWeapons = { ["Melee"] = false, ["Sword"] = true, ["Blox Fruit"] = true },
    UseSkills = { Z = true, X = true, C = true, V = true, E = true },
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

local isAttacking = false

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- GUI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_FixNPC_Gui"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 45)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Text = "⚡ Đã cập nhật lọc NPC an toàn..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- HÀM TRANG BỊ VŨ KHÍ
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

-- BỘ LỌC KIỂM TRA XEM MỤC TIÊU CÓ PHẢI LÀ NPC CHAT/BÁN ĐỒ KHÔNG
local function IsEnemyMob(obj)
    if not obj:IsA("Model") then return false end
    
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    -- Bỏ qua Người chơi
    if Players:GetPlayerFromCharacter(obj) then return false end

    -- Bỏ qua NPC có hội thoại / nhiệm vụ / bán đồ
    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return false end
    if obj:FindFirstChild("Dialog") or obj:FindFirstChild("Quest") or obj:FindFirstChild("NPC") then return false end
    if obj:FindFirstChild("Talk") or obj:FindFirstChild("Shop") then return false end
    
    -- Tên các NPC quen thuộc cần bỏ qua
    local name = obj.Name:lower()
    if name:find("quest") or name:find("dealer") or name:find("seller") or name:find("spawn") or name:find("spin") then
        return false
    end

    -- Đảm bảo có thanh máu thực sự (MaxHealth > 0)
    if hum.MaxHealth <= 0 then return false end

    return true
end

-- TÌM QUÁI GẦN NHẤT CHUẨN XÁC
local function FindNearestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local closestMob = nil
    local minDistance = Config.MaxMobDistance

    -- Ưu tiên tìm trong thư mục Quái của King Legacy
    local searchFolder = Workspace:FindFirstChild("Monster") or Workspace:FindFirstChild("Enemies") or Workspace

    for _, obj in pairs(searchFolder:GetDescendants()) do
        if IsEnemyMob(obj) then
            local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if part then
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

-- TẤN CÔNG MỤC TIÊU
local function AttackTarget(targetObj)
    isAttacking = true
    StatusLabel.Text = "⚔️ ĐANG TẤN CÔNG QUÁI: " .. targetObj.Name
    StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)

    task.spawn(function()
        while targetObj and targetObj.Parent and isAttacking do
            local hum = targetObj:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then break end

            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPart = targetObj:FindFirstChild("HumanoidRootPart") or targetObj.PrimaryPart or targetObj:FindFirstChildWhichIsA("BasePart")
                
                if targetPart then
                    -- Bay lơ lửng trên đầu quái
                    char.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, Config.AttackDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)

                    -- 1. Đổi sang vũ khí phụ xả Skill
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

                    -- 2. Đổi về Vũ khí chính đánh M1
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

-- VÒNG LẶP CHÍNH
task.spawn(function()
    while true do
        if not isAttacking and Config.FarmNearest then
            local mobObj = FindNearestMob()
            if mobObj then
                AttackTarget(mobObj)
            else
                StatusLabel.Text = "🔍 Đang quét quái thực sự (Đã lọc NPC)..."
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
        end
        task.wait(1)
    end
end)
