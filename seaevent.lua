-- =================================================================
-- KING LEGACY: FULL AUTO FARM (CHỌN SKILL + VŨ KHÍ + ANTI-JITTER)
-- =================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- CẤU HÌNH MẶC ĐỊNH
local Config = {
    FarmNearest = true,
    AttackDistance = 7, -- Khoảng cách đứng trên đầu quái (7m)
    MaxMobDistance = 1000,
    MainWeapon = "Melee", -- "Melee", "Sword", hoặc "Blox Fruit"
    UseSkills = {
        Z = true,
        X = true,
        C = true,
        V = false,
        E = false
    }
}

local isAttacking = false

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- =================================================================
-- 1. TẠO GIAO DIỆN GUI CỐ ĐỊNH & NÚT CẤU HÌNH
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_FullSkill_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- NÚT BẬT / TẮT MENU CỐ ĐỊNH Ở GÓC TRÁI MÀN HÌNH
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 100, 0, 32)
ToggleMenuBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
ToggleMenuBtn.BorderSizePixel = 0
ToggleMenuBtn.Text = "⚙️ MENU: ẨN/HIỆN"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.TextSize = 12
ToggleMenuBtn.Active = true
ToggleMenuBtn.Parent = ScreenGui

-- KHUNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 360)
MainFrame.Position = UDim2.new(0, 125, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "KING LEGACY: AUTO FARM + SKILL"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 12
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 35)
StatusLabel.Position = UDim2.new(0, 8, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Text = "⚡ Tùy chỉnh Skill & Vũ khí!"
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- SCROLL CHỨA CÁC NÚT BẤM CẤU HÌNH
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 0, 270)
Scroll.Position = UDim2.new(0, 8, 0, 75)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 320)
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
    btn.TextSize = 11
    btn.Parent = Scroll
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- 1. NÚT AUTO FARM
CreateButton("AUTO FARM: " .. (Config.FarmNearest and "BẬT" or "TẮT"), Config.FarmNearest and Color3.fromRGB(0, 180, 180) or Color3.fromRGB(60, 60, 70), function(btn)
    Config.FarmNearest = not Config.FarmNearest
    btn.Text = "AUTO FARM: " .. (Config.FarmNearest and "BẬT" or "TẮT")
    btn.BackgroundColor3 = Config.FarmNearest and Color3.fromRGB(0, 180, 180) or Color3.fromRGB(60, 60, 70)
end)

-- 2. NÚT CHỌN VŨ KHÍ CHÍNH
CreateButton("VŨ KHÍ CHÍNH: " .. Config.MainWeapon, Color3.fromRGB(0, 130, 200), function(btn)
    if Config.MainWeapon == "Melee" then Config.MainWeapon = "Sword"
    elseif Config.MainWeapon == "Sword" then Config.MainWeapon = "Blox Fruit"
    else Config.MainWeapon = "Melee" end
    btn.Text = "VŨ KHÍ CHÍNH: " .. Config.MainWeapon
end)

-- 3. NÚT CHỈNH KHOẢNG CÁCH ĐÁNH
CreateButton("KHOẢNG CÁCH: " .. Config.AttackDistance .. "M", Color3.fromRGB(120, 80, 200), function(btn)
    if Config.AttackDistance == 7 then Config.AttackDistance = 5
    elseif Config.AttackDistance == 5 then Config.AttackDistance = 9
    else Config.AttackDistance = 7 end
    btn.Text = "KHOẢNG CÁCH: " .. Config.AttackDistance .. "M"
end)

-- 4. BẬT/TẮT CÁC SKILL TẤN CÔNG (Z, X, C, V, E)
local skillKeys = {"Z", "X", "C", "V", "E"}
for _, key in ipairs(skillKeys) do
    local isEnabled = Config.UseSkills[key]
    CreateButton("DÙNG SKILL [" .. key .. "]: " .. (isEnabled and "BẬT" or "TẮT"), isEnabled and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(80, 80, 90), function(btn)
        Config.UseSkills[key] = not Config.UseSkills[key]
        local current = Config.UseSkills[key]
        btn.Text = "DÙNG SKILL [" .. key .. "]: " .. (current and "BẬT" or "TẮT")
        btn.BackgroundColor3 = current and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(80, 80, 90)
    end)
end

-- =================================================================
-- 2. TRANG BỊ VŨ KHÍ & BỘ LỌC QUÁI / NPC
-- =================================================================
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

local function IsEnemyMob(obj)
    if not obj:IsA("Model") then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 or hum.MaxHealth <= 0 then return false end
    
    if Players:GetPlayerFromCharacter(obj) then return false end

    if obj:FindFirstChildWhichIsA("ProximityPrompt", true) then return false end
    if obj:FindFirstChild("Dialog") or obj:FindFirstChild("Quest") or obj:FindFirstChild("NPC") then return false end
    if obj:FindFirstChild("Talk") or obj:FindFirstChild("Shop") then return false end

    local name = obj.Name:lower()
    if name:find("quest") or name:find("dealer") or name:find("seller") or name:find("spawn") or name:find("spin") then 
        return false 
    end

    return true
end

local function FindNearestMob()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position

    local closestMob = nil
    local minDistance = Config.MaxMobDistance
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

-- =================================================================
-- 3. HÀM TẤN CÔNG (THỰC THI SKILL ĐÃ CHỌN + M1 VŨ KHÍ CHÍNH)
-- =================================================================
local function AttackTarget(targetObj)
    isAttacking = true
    StatusLabel.Text = "⚔️ ĐANG TẤN CÔNG: " .. targetObj.Name
    StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        isAttacking = false
        return 
    end

    local hrp = char.HumanoidRootPart

    -- TRIỆT TIÊU TRỌNG LỰC (KHÓA CỨNG LƠ LỬNG)
    local bv = hrp:FindFirstChild("KL_FreezeVel") or Instance.new("BodyVelocity")
    bv.Name = "KL_FreezeVel"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    task.spawn(function()
        while targetObj and targetObj.Parent and isAttacking do
            local hum = targetObj:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then break end

            if char and char:FindFirstChild("HumanoidRootPart") then
                local targetPart = targetObj:FindFirstChild("HumanoidRootPart") or targetObj.PrimaryPart or targetObj:FindFirstChildWhichIsA("BasePart")
                
                if targetPart then
                    -- Tắt va chạm
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end

                    -- Vị trí đứng trên đầu quái
                    local mobPosition = targetPart.Position
                    local standPosition = mobPosition + Vector3.new(0, Config.AttackDistance, 0)

                    -- CỐ ĐỊNH TƯ THẾ: ĐỨNG THẲNG & CÚI MẶT NHÌN XUỐNG QUÁI
                    hrp.CFrame = CFrame.lookAt(standPosition, mobPosition)

                    -- 1. Trang bị Vũ khí chính đã chọn
                    EquipWeaponByType(Config.MainWeapon)

                    -- 2. Xả các Skill được BẬT (Z, X, C, V, E)
                    for key, enabled in pairs(Config.UseSkills) do
                        if enabled then
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        end
                    end

                    -- 3. Chém đòn M1
                    VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end
            end
            task.wait(0.05)
        end

        -- Hủy khóa lơ lửng khi hạ xong quái
        if bv then bv:Destroy() end
        isAttacking = false
    end)
end

-- =================================================================
-- 4. VÒNG LẶP CHÍNH
-- =================================================================
task.spawn(function()
    while true do
        if not isAttacking and Config.FarmNearest then
            local mobObj = FindNearestMob()
            if mobObj then
                AttackTarget(mobObj)
            else
                StatusLabel.Text = "🔍 Đang tìm quái gần nhất..."
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            end
        end
        task.wait(0.8)
    end
end)
