-- =================================================================
-- KING LEGACY - V21 FINAL MASTER (FIX HAKI + TARGET BOSS + SMART HOP)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local VisitedServers = {}
local MasterRoutineActive = false

-- ================= HỆ THỐNG CÀI ĐẶT & SKILL =================
local SettingsFile = "KL_Settings_V21.json"
local Settings = { 
    MasterAuto = false,
    MainWeaponType = "Sword",
    Skills = {
        Melee = {Z = true, X = true, C = true, V = true, E = false},
        Sword = {Z = true, X = true, C = false, V = false, E = false},
        Fruit = {Z = true, X = true, C = true, V = true, E = true},
        Gun   = {Z = true, X = true, C = false, V = false, E = false}
    }
}

local function SaveSettings()
    pcall(function() if writefile then writefile(SettingsFile, HttpService:JSONEncode(Settings)) end end)
end

local function LoadSettings()
    pcall(function()
        if isfile and isfile(SettingsFile) then
            local data = readfile(SettingsFile)
            local decoded = HttpService:JSONDecode(data)
            if decoded then for k, v in pairs(decoded) do Settings[k] = v end end
        end
    end)
end
LoadSettings()

-- ================= GIAO DIỆN UI V21 =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MasterGui_V21"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 11
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 500)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 9
MainFrame.Parent = ScreenGui

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local bPos = ToggleBtn.AbsolutePosition
        local bSize = ToggleBtn.AbsoluteSize
        if pos.X >= bPos.X and pos.X <= bPos.X + bSize.X and pos.Y >= bPos.Y and pos.Y <= bPos.Y + bSize.Y then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "KING LEGACY V21 - FIX HAKI & SMART EVENT"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.ZIndex = 9
Title.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -35)
ScrollFrame.Position = UDim2.new(0, 5, 0, 32)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 750)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ZIndex = 9
ScrollFrame.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Tạm dừng"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 9
StatusLabel.Parent = ScrollFrame

local MasterBtn = Instance.new("TextButton")
MasterBtn.Size = UDim2.new(1, -10, 0, 40)
MasterBtn.Position = UDim2.new(0, 5, 0, 30)
MasterBtn.Font = Enum.Font.SourceSansBold
MasterBtn.TextSize = 12
MasterBtn.ZIndex = 9
MasterBtn.Parent = ScrollFrame

local MainWeaponBtn = Instance.new("TextButton")
MainWeaponBtn.Size = UDim2.new(1, -10, 0, 30)
MainWeaponBtn.Position = UDim2.new(0, 5, 0, 75)
MainWeaponBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
MainWeaponBtn.Font = Enum.Font.SourceSansBold
MainWeaponBtn.TextSize = 11
MainWeaponBtn.ZIndex = 9
MainWeaponBtn.Parent = ScrollFrame

local SkillFrame = Instance.new("Frame")
SkillFrame.Size = UDim2.new(1, -10, 0, 180)
SkillFrame.Position = UDim2.new(0, 5, 0, 110)
SkillFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
SkillFrame.ZIndex = 9
SkillFrame.Parent = ScrollFrame

local SkillTitle = Instance.new("TextLabel")
SkillTitle.Size = UDim2.new(1, 0, 0, 25)
SkillTitle.Text = "CẤU HÌNH SPAM SKILL VŨ KHÍ"
SkillTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
SkillTitle.Font = Enum.Font.SourceSansBold
SkillTitle.TextSize = 11
SkillTitle.ZIndex = 9
SkillTitle.Parent = SkillFrame

local function CreateSkillToggle(category, key, posX, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    btn.ZIndex = 9
    btn.Parent = SkillFrame

    local function updateBtnUI()
        local active = Settings.Skills[category][key]
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(150, 40, 40)
        btn.Text = category .. " [" .. key .. "]: " .. (active and "ON" or "OFF")
    end

    btn.MouseButton1Click:Connect(function()
        Settings.Skills[category][key] = not Settings.Skills[category][key]
        SaveSettings()
        updateBtnUI()
    end)
    updateBtnUI()
end

local cats = {"Melee", "Sword", "Fruit", "Gun"}
local keys = {"Z", "X", "C", "V", "E"}
for cIdx, cat in ipairs(cats) do
    for kIdx, key in ipairs(keys) do
        CreateSkillToggle(cat, key, 10 + (kIdx - 1) * 68, 30 + (cIdx - 1) * 35)
    end
end

local function UpdateUI()
    MasterBtn.BackgroundColor3 = Settings.MasterAuto and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(180, 40, 40)
    MasterBtn.Text = Settings.MasterAuto and "[BẬT] ALL IN ONE MASTER AUTO" or "[TẮT] ALL IN ONE MASTER AUTO"
    MainWeaponBtn.Text = "VŨ KHÍ CHÍNH ĐÁNH M1: " .. string.upper(Settings.MainWeaponType)
end

MasterBtn.MouseButton1Click:Connect(function()
    Settings.MasterAuto = not Settings.MasterAuto
    SaveSettings()
    UpdateUI()
end)

MainWeaponBtn.MouseButton1Click:Connect(function()
    if Settings.MainWeaponType == "Sword" then Settings.MainWeaponType = "Melee"
    elseif Settings.MainWeaponType == "Melee" then Settings.MainWeaponType = "Fruit"
    elseif Settings.MainWeaponType == "Fruit" then Settings.MainWeaponType = "Gun"
    else Settings.MainWeaponType = "Sword" end
    SaveSettings()
    UpdateUI()
end)

UpdateUI()

-- ================= 1. HỆ THỐNG NHẤN PLAY VÀ BẬT HAKI TAY (FIXED) =================
local function AutoPressPlay()
    pcall(function()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.AbsolutePosition.X > 0 then
                local name = string.lower(gui.Name)
                local text = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and string.lower(gui.Text) or ""
                if name == "play" or string.find(text, "play") then
                    if VirtualInputManager then
                        local absPos, absSize = gui.AbsolutePosition, gui.AbsoluteSize
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + (absSize.X / 2), absPos.Y + (absSize.Y / 2) + 36, 0, true, game, 0)
                        task.wait(0.05)
                        VirtualInputManager:SendMouseButtonEvent(absPos.X + (absSize.X / 2), absPos.Y + (absSize.Y / 2) + 36, 0, false, game, 0)
                    end
                end
            end
        end
    end)
end

local function TriggerBusoOnce()
    if Settings.MasterAuto and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end
        end)
    end
end

-- Bật Haki ngay khi nhân vật load vào hoặc hồi sinh
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 8)
    task.wait(1.2) -- Chờ game load hoàn tất nhân vật rồi mới bật Haki
    TriggerBusoOnce()
end)

-- ================= 2. QUÉT RƯƠNG MAP CHUẨN XÁC (LỌC SẠCH MINION/TIER) =================
local function GetValidMapChests(hrpPosition)
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (string.find(name, "chest") or string.find(name, "reward")) then
            local isIgnored = false
            if string.find(name, "tier") or string.find(name, "drop") or string.find(name, "beam") or string.find(name, "light") or string.find(name, "minion") or string.find(name, "spark") or string.find(name, "gacha") or string.find(name, "fruit") or string.find(name, "barrel") or string.find(name, "crate") or string.find(name, "box") then
                isIgnored = true
            end
            if not isIgnored then
                local current = obj.Parent
                while current and current ~= Workspace do
                    local cName = string.lower(current.Name)
                    if string.find(cName, "quest") or string.find(cName, "bandit") or string.find(cName, "pirate") or string.find(cName, "marine") or string.find(cName, "spawn") or string.find(cName, "minion") or string.find(cName, "tier") then
                        isIgnored = true
                        break
                    end
                    if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
                        isIgnored = true
                        break
                    end
                    current = current.Parent
                end
            end
            if not isIgnored then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then table.insert(chests, part) end
            end
        end
    end
    if hrpPosition then
        table.sort(chests, function(a, b)
            return (a.Position - hrpPosition).Magnitude < (b.Position - hrpPosition).Magnitude
        end)
    end
    return chests
end

-- ================= 3. HỆ THỐNG VŨ KHÍ & SPAM SKILL =================
local function EquipToolCategory(category)
    local char = LocalPlayer.Character
    if not char then return nil end
    local backpack = LocalPlayer.Backpack

    local function MatchesCategory(tool)
        local name = string.lower(tool.Name)
        local toolTip = string.lower(tool.ToolTip or "")
        if category == "Melee" and (toolTip:find("melee") or name:find("style") or name:find("black leg") or name:find("fist") or name:find("cyborg")) then return true end
        if category == "Sword" and (toolTip:find("sword") or name:find("blade") or name:find("katana") or name:find("saber") or name:find("sword")) then return true end
        if category == "Fruit" and (toolTip:find("fruit") or name:find("fruit") or name:find("power")) then return true end
        if category == "Gun" and (toolTip:find("gun") or name:find("musket") or name:find("rifle") or name:find("blaster")) then return true end
        return false
    end

    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") and MatchesCategory(tool) then return tool end
    end
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and MatchesCategory(tool) then
            char.Humanoid:EquipTool(tool)
            return tool
        end
    end
    return nil
end

local function CastSelectedSkills(category)
    local cfg = Settings.Skills[category]
    if not cfg then return end
    local keyMap = {Z = Enum.KeyCode.Z, X = Enum.KeyCode.X, C = Enum.KeyCode.C, V = Enum.KeyCode.V, E = Enum.KeyCode.E}
    
    for kName, keyCode in pairs(keyMap) do
        if cfg[kName] then
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            task.wait(0.05)
        end
    end
end

local function AttackM1()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.04)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ================= 4. NHẬN DIỆN SEA EVENT CHUẨN XÁC (LOẠI BỎ MINION) =================
local function GetPrioritySeaEventTarget()
    local hydraTarget = nil
    local seaKingTarget = nil
    local ghostShipTarget = nil

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local name = string.lower(obj.Name)
            local hum = obj:FindFirstChildOfClass("Humanoid")
            
            -- Loại bỏ hoàn toàn quái nhỏ, bandit, marine, minion
            local isMinion = name:find("bandit") or name:find("pirate") or name:find("marine") or name:find("minion") or name:find("brute") or name:find("soldier")
            
            if hum.Health > 0 and not isMinion then
                if name:find("hydra") or name:find("serpent") then
                    hydraTarget = obj
                elseif name:find("sea king") or name:find("seabeast") or name:find("sea beast") or name:find("beast") or name:find("king sea") then
                    seaKingTarget = obj
                elseif name:find("ghost ship") or name:find("ghostship") or (name:find("ship") and not name:find("player")) then
                    ghostShipTarget = obj
                end
            end
        end
    end

    -- Sắp xếp ưu tiên: Hydra (1) -> Sea King (2) -> Tàu Ma (3)
    if hydraTarget then return hydraTarget end
    if seaKingTarget then return seaKingTarget end
    if ghostShipTarget then return ghostShipTarget end
    return nil
end

local function HopServerNow()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and result and result.data then
        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and not VisitedServers[svr.id] and svr.playing >= 8 and svr.playing <= 11 then
                VisitedServers[svr.id] = true
                StatusLabel.Text = "Trạng thái: Đang đổi Server..."
                TeleportService:TeleportToPlaceInstance(game.PlaceId, svr.id, LocalPlayer)
                return
            end
        end
    end
end

-- ================= 5. LUỒNG MASTER THÔNG MINH (ALL IN ONE) =================
task.spawn(function()
    task.wait(2)
    TriggerBusoOnce()
    
    while true do
        task.wait(0.3)
        AutoPressPlay()
        
        if Settings.MasterAuto and not MasterRoutineActive then
            MasterRoutineActive = true
            
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            
            if hrp then
                local seaTarget = GetPrioritySeaEventTarget()
                
                if seaTarget and seaTarget:FindFirstChild("HumanoidRootPart") then
                    -- THỰC THI KHI CÓ SEA EVENT
                    StatusLabel.Text = "Đang đánh Boss: " .. seaTarget.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)

                    local tHrp = seaTarget.HumanoidRootPart
                    
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bodyVelocity.Parent = hrp

                    while seaTarget and seaTarget:FindFirstChildOfClass("Humanoid") and seaTarget:FindFirstChildOfClass("Humanoid").Health > 0 and Settings.MasterAuto do
                        hrp.CFrame = tHrp.CFrame * CFrame.new(0, 32, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        for _, cat in ipairs({"Melee", "Sword", "Fruit", "Gun"}) do
                            if EquipToolCategory(cat) then
                                task.wait(0.04)
                                CastSelectedSkills(cat)
                            end
                        end
                        
                        if EquipToolCategory(Settings.MainWeaponType) then
                            for i = 1, 3 do AttackM1() end
                        end
                        
                        RunService.Heartbeat:Wait()
                    end
                    
                    if bodyVelocity then bodyVelocity:Destroy() end
                    
                    -- Sau khi hạ xong Event -> Gom rương xung quanh
                    StatusLabel.Text = "Đã hạ Event! Đang gom rương..."
                    local chests = GetValidMapChests(hrp.Position)
                    for _, chestPart in ipairs(chests) do
                        if not Settings.MasterAuto then break end
                        local timeout = tick() + 2.5
                        while chestPart and chestPart.Parent and tick() < timeout and Settings.MasterAuto do
                            hrp.CFrame = CFrame.new(chestPart.Position + Vector3.new(0, 2.5, 0))
                            hrp.Velocity = Vector3.new(0, 0, 0)
                            pcall(function()
                                local prompt = chestPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) or chestPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                            end)
                            RunService.Heartbeat:Wait()
                        end
                    end
                    
                    -- Chờ từ 30 giây đến 1 phút (chọn 45 giây) rồi đổi Server
                    StatusLabel.Text = "Hoàn tất Sea Event. Chờ đổi Server..."
                    local waitTimer = 0
                    while waitTimer < 45 and Settings.MasterAuto do
                        task.wait(1)
                        waitTimer = waitTimer + 1
                        StatusLabel.Text = "Đổi Server sau: " .. (45 - waitTimer) .. "s"
                    end
                    
                    if Settings.MasterAuto then
                        HopServerNow()
                    end
                else
                    -- THỰC THI KHI KHÔNG CÓ SEA EVENT (QUÉT RƯƠNG HOẶC ĐỔI SERVER)
                    StatusLabel.Text = "Không có Event. Đang quét rương trong Server..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    
                    local chests = GetValidMapChests(hrp.Position)
                    
                    if #chests > 0 then
                        -- Nếu tìm thấy rương, tiến hành nhặt
                        for _, chestPart in ipairs(chests) do
                            if not Settings.MasterAuto then break end
                            if GetPrioritySeaEventTarget() then break end -- Ngắt nếu xuất hiện Event giữa chừng
                            
                            local timeout = tick() + 3
                            while chestPart and chestPart.Parent and tick() < timeout and Settings.MasterAuto do
                                hrp.CFrame = CFrame.new(chestPart.Position + Vector3.new(0, 2.5, 0))
                                hrp.Velocity = Vector3.new(0, 0, 0)
                                pcall(function()
                                    local prompt = chestPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) or chestPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then fireproximityprompt(prompt) end
                                end)
                                RunService.Heartbeat:Wait()
                            end
                        end
                    else
                        -- Nếu không có Sea Event và không có rương nào trong server -> Đổi Server ngay lập tức
                        StatusLabel.Text = "Server trống (Không Event/Không Rương). Đổi Server..."
                        HopServerNow()
                        task.wait(5)
                    end
                end
            end
            
            MasterRoutineActive = false
        end
    end
end)
