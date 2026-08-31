-- =================================================================
-- KING LEGACY - V18 (FIX LỖI SPAM HAKI TỰ BẬT/TẮT + FULL AUTO)
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
local Camera = Workspace.CurrentCamera

local LastStuckCheck = 0
local VisitedServers = {}
local IsTeleporting = false

-- ================= HỆ THỐNG LƯU CÀI ĐẶT =================
local SettingsFile = "KingLegacy_AutoChest_Settings.json"
local Settings = { 
    AutoHop = false, AutoChest = false, HopDelay = 15, AutoPlay = true, AutoBuso = true,
    AutoSeaEvent = false, TargetSeaKing = true, TargetHydra = true, TargetGhostShip = true,
    MainWeaponType = "Sword",
    SubMelee = true, SubSword = false, SubFruit = true, SubGun = false
}

local function SaveSettings()
    pcall(function()
        if writefile then writefile(SettingsFile, HttpService:JSONEncode(Settings)) end
    end)
end

local function LoadSettings()
    pcall(function()
        if isfile and isfile(SettingsFile) then
            local data = readfile(SettingsFile)
            local decoded = HttpService:JSONDecode(data)
            if decoded then
                for k, v in pairs(decoded) do Settings[k] = v end
            end
        end
    end)
end

LoadSettings()
getgenv().KL_AutoHopRunning = Settings.AutoHop
getgenv().KL_AutoChestRunning = Settings.AutoChest
getgenv().KL_HopDelay = Settings.HopDelay
getgenv().KL_AutoPlayRunning = Settings.AutoPlay
getgenv().KL_AutoBusoRunning = Settings.AutoBuso
getgenv().KL_AutoSeaEvent = Settings.AutoSeaEvent

-- ================= GIAO DIỆN CHÍNH =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MobileMasterGui_V18"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 11
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 480)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
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
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "KING LEGACY V18 - FIX TRIỆT ĐỂ SPAM HAKI"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 10
Title.ZIndex = 9
Title.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -35)
ScrollFrame.Position = UDim2.new(0, 5, 0, 32)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 680)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ZIndex = 9
ScrollFrame.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Hoạt động ổn định."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 9
StatusLabel.Parent = ScrollFrame

local function CreateButton(posY, sizeY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, sizeY)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.ZIndex = 9
    btn.Parent = ScrollFrame
    return btn
end

local AutoSeaBtn = CreateButton(30, 30, "")
local SeaKingBtn = CreateButton(65, 25, "")
local HydraBtn = CreateButton(95, 25, "")
local GhostShipBtn = CreateButton(125, 25, "")

local MainWeaponBtn = CreateButton(160, 30, "")
local SubMeleeBtn = CreateButton(195, 25, "")
local SubSwordBtn = CreateButton(225, 25, "")
local SubFruitBtn = CreateButton(255, 25, "")
local SubGunBtn = CreateButton(285, 25, "")

local AutoChestBtn = CreateButton(320, 30, "")
local AutoHopBtn = CreateButton(355, 30, "")
local AutoBusoBtn = CreateButton(390, 30, "")
local AutoPlayBtn = CreateButton(425, 30, "")

local function UpdateUI()
    AutoSeaBtn.BackgroundColor3 = Settings.AutoSeaEvent and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoSeaBtn.Text = Settings.AutoSeaEvent and "AUTO SEA EVENT: BẬT" or "AUTO SEA EVENT: TẮT"

    SeaKingBtn.BackgroundColor3 = Settings.TargetSeaKing and Color3.fromRGB(0, 140, 200) or Color3.fromRGB(70, 70, 80)
    SeaKingBtn.Text = Settings.TargetSeaKing and "[✓] SĂN SEA KING / SEA BEAST" or "[ ] SĂN SEA KING / SEA BEAST"

    HydraBtn.BackgroundColor3 = Settings.TargetHydra and Color3.fromRGB(0, 140, 200) or Color3.fromRGB(70, 70, 80)
    HydraBtn.Text = Settings.TargetHydra and "[✓] SĂN HYDRA" or "[ ] SĂN HYDRA"

    GhostShipBtn.BackgroundColor3 = Settings.TargetGhostShip and Color3.fromRGB(0, 140, 200) or Color3.fromRGB(70, 70, 80)
    GhostShipBtn.Text = Settings.TargetGhostShip and "[✓] SĂN GHOST SHIP" or "[ ] SĂN GHOST SHIP"

    MainWeaponBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 200)
    MainWeaponBtn.Text = "VŨ KHÍ CHÍNH (ĐÁNH M1): " .. string.upper(Settings.MainWeaponType)

    SubMeleeBtn.BackgroundColor3 = Settings.SubMelee and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(70, 70, 80)
    SubMeleeBtn.Text = Settings.SubMelee and "[✓] PHỤ: MELEE (CẬN CHIẾN)" or "[ ] PHỤ: MELEE (CẬN CHIẾN)"

    SubSwordBtn.BackgroundColor3 = Settings.SubSword and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(70, 70, 80)
    SubSwordBtn.Text = Settings.SubSword and "[✓] PHỤ: SWORD (KIẾM)" or "[ ] PHỤ: SWORD (KIẾM)"

    SubFruitBtn.BackgroundColor3 = Settings.SubFruit and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(70, 70, 80)
    SubFruitBtn.Text = Settings.SubFruit and "[✓] PHỤ: FRUIT (TRÁI ÁC QUỶ)" or "[ ] PHỤ: FRUIT (TRÁI ÁC QUỶ)"

    SubGunBtn.BackgroundColor3 = Settings.SubGun and Color3.fromRGB(0, 160, 120) or Color3.fromRGB(70, 70, 80)
    SubGunBtn.Text = Settings.SubGun and "[✓] PHỤ: GUN (SÚNG)" or "[ ] PHỤ: GUN (SÚNG)"

    AutoChestBtn.BackgroundColor3 = getgenv().KL_AutoChestRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoChestBtn.Text = getgenv().KL_AutoChestRunning and "AUTO NHẶT RƯƠNG: BẬT" or "AUTO NHẶT RƯƠNG: TẮT"

    AutoHopBtn.BackgroundColor3 = getgenv().KL_AutoHopRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoHopBtn.Text = getgenv().KL_AutoHopRunning and "AUTO HOP SERVER: BẬT" or "AUTO HOP SERVER: TẮT"

    AutoBusoBtn.BackgroundColor3 = getgenv().KL_AutoBusoRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoBusoBtn.Text = getgenv().KL_AutoBusoRunning and "AUTO HAKI BUSO (PHÍM T): BẬT" or "AUTO HAKI BUSO (PHÍM T): TẮT"

    AutoPlayBtn.BackgroundColor3 = getgenv().KL_AutoPlayRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoPlayBtn.Text = getgenv().KL_AutoPlayRunning and "AUTO NHẤN PLAY: BẬT" or "AUTO NHẤN PLAY: TẮT"
end

AutoSeaBtn.MouseButton1Click:Connect(function() Settings.AutoSeaEvent = not Settings.AutoSeaEvent SaveSettings() UpdateUI() end)
SeaKingBtn.MouseButton1Click:Connect(function() Settings.TargetSeaKing = not Settings.TargetSeaKing SaveSettings() UpdateUI() end)
HydraBtn.MouseButton1Click:Connect(function() Settings.TargetHydra = not Settings.TargetHydra SaveSettings() UpdateUI() end)
GhostShipBtn.MouseButton1Click:Connect(function() Settings.TargetGhostShip = not Settings.TargetGhostShip SaveSettings() UpdateUI() end)

MainWeaponBtn.MouseButton1Click:Connect(function()
    if Settings.MainWeaponType == "Sword" then Settings.MainWeaponType = "Melee"
    elseif Settings.MainWeaponType == "Melee" then Settings.MainWeaponType = "Fruit"
    else Settings.MainWeaponType = "Sword" end
    SaveSettings() UpdateUI()
end)

SubMeleeBtn.MouseButton1Click:Connect(function() Settings.SubMelee = not Settings.SubMelee SaveSettings() UpdateUI() end)
SubSwordBtn.MouseButton1Click:Connect(function() Settings.SubSword = not Settings.SubSword SaveSettings() UpdateUI() end)
SubFruitBtn.MouseButton1Click:Connect(function() Settings.SubFruit = not Settings.SubFruit SaveSettings() UpdateUI() end)
SubGunBtn.MouseButton1Click:Connect(function() Settings.SubGun = not Settings.SubGun SaveSettings() UpdateUI() end)

AutoChestBtn.MouseButton1Click:Connect(function() getgenv().KL_AutoChestRunning = not getgenv().KL_AutoChestRunning Settings.AutoChest = getgenv().KL_AutoChestRunning SaveSettings() UpdateUI() end)
AutoHopBtn.MouseButton1Click:Connect(function() getgenv().KL_AutoHopRunning = not getgenv().KL_AutoHopRunning Settings.AutoHop = getgenv().KL_AutoHopRunning SaveSettings() UpdateUI() end)
AutoBusoBtn.MouseButton1Click:Connect(function() getgenv().KL_AutoBusoRunning = not getgenv().KL_AutoBusoRunning Settings.AutoBuso = getgenv().KL_AutoBusoRunning SaveSettings() UpdateUI() end)
AutoPlayBtn.MouseButton1Click:Connect(function() getgenv().KL_AutoPlayRunning = not getgenv().KL_AutoPlayRunning Settings.AutoPlay = getgenv().KL_AutoPlayRunning SaveSettings() UpdateUI() end)

UpdateUI()

-- ================= 1. HÀM TỰ DỌN DẸP MENU & NHẤN PLAY & FIX CAMERA =================
local function AutoFixCameraAndPlay()
    if not getgenv().KL_AutoPlayRunning then return end
    
    pcall(function()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.AbsolutePosition.X > 0 then
                local name = string.lower(gui.Name)
                local text = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and string.lower(gui.Text) or ""
                
                if name == "play" or string.find(text, "play") then
                    if VirtualInputManager then
                        local absPos = gui.AbsolutePosition
                        local absSize = gui.AbsoluteSize
                        local cx = absPos.X + (absSize.X / 2)
                        local cy = absPos.Y + (absSize.Y / 2) + 36
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                    end
                end
            end
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hrp and humanoid then
            local camDist = (Camera.CFrame.Position - hrp.Position).Magnitude
            if camDist > 30 then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = humanoid
                Camera.CFrame = hrp.CFrame * CFrame.new(0, 3, 10)
                
                if tick() - LastStuckCheck > 3 then
                    LastStuckCheck = tick()
                    humanoid.Health = 0
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        AutoFixCameraAndPlay()
    end
end)

-- ================= 2. FIX CHUẨN AUTO HAKI BUSO (CHỈ BẬT 1 LẦN KHI RESPAWN) =================
local function TriggerBusoOnce()
    if getgenv().KL_AutoBusoRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end
        end)
    end
end

-- Bật ngay 1 lần lúc vừa load script
task.spawn(function()
    task.wait(1.5)
    TriggerBusoOnce()
end)

-- Chỉ bật đúng 1 lần duy nhất mỗi khi nhân vật chết/reset/vừa spawn ra
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(1.2) -- Chờ nhân vật nạp animation hoàn tất
    TriggerBusoOnce()
end)

-- ================= 3. QUÉT RƯƠNG NGHIÊM NGẶT (LỌC GACHA/FRUIT/NPC) =================
local function GetValidChests(hrpPosition)
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (string.find(name, "chest") or string.find(name, "reward")) then
            local isIgnored = false
            if string.find(name, "gacha") or string.find(name, "fruit") or string.find(name, "barrel") or string.find(name, "crate") or string.find(name, "box") or string.find(name, "random") then
                isIgnored = true
            end
            if not isIgnored then
                local current = obj.Parent
                while current and current ~= Workspace do
                    local cName = string.lower(current.Name)
                    if string.find(cName, "quest") or string.find(cName, "daily") or string.find(cName, "delivery") or string.find(cName, "bandit") or string.find(cName, "pirate") or string.find(cName, "marine") or string.find(cName, "gacha") or string.find(cName, "fruit") or string.find(cName, "spawn") or string.find(cName, "barrel") or string.find(cName, "shop") or string.find(cName, "dealer") then
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

-- ================= 4. HỆ THỐNG COMBAT & XẢ SKILL VŨ KHÍ =================
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

local function CastSkills()
    local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.E}
    for _, key in ipairs(keys) do
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.08)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
        task.wait(0.1)
    end
end

local function AttackM1()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ================= 5. AUTO SEA EVENT & DUAL COMBAT LOOP =================
local function GetSeaEventTarget()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local name = string.lower(obj.Name)
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then
                if Settings.TargetSeaKing and (name:find("sea king") or name:find("seabeast") or name:find("sea beast")) then return obj end
                if Settings.TargetHydra and name:find("hydra") then return obj end
                if Settings.TargetGhostShip and (name:find("ghost ship") or name:find("ghostship")) then return obj end
            end
        end
    end
    return nil
end

local function HopServerNow()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and result and result.data then
        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and not VisitedServers[svr.id] and svr.playing >= 8 and svr.playing <= 11 then
                VisitedServers[svr.id] = true
                StatusLabel.Text = "Trạng thái: Hoàn thành! Đang Hop Server..."
                TeleportService:TeleportToPlaceInstance(game.PlaceId, svr.id, LocalPlayer)
                return
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoSeaEvent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = GetSeaEventTarget()
            if target and target:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                local tHrp = target.HumanoidRootPart
                
                StatusLabel.Text = "Trạng thái: Đang đánh " .. target.Name
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                
                hrp.CFrame = tHrp.CFrame * CFrame.new(0, 35, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                hrp.Velocity = Vector3.new(0,0,0)

                local subCategories = {}
                if Settings.SubMelee then table.insert(subCategories, "Melee") end
                if Settings.SubSword then table.insert(subCategories, "Sword") end
                if Settings.SubFruit then table.insert(subCategories, "Fruit") end
                if Settings.SubGun then table.insert(subCategories, "Gun") end

                for _, cat in ipairs(subCategories) do
                    if EquipToolCategory(cat) then
                        task.wait(0.1)
                        CastSkills()
                    end
                end

                if EquipToolCategory(Settings.MainWeaponType) then
                    task.wait(0.1)
                    CastSkills()
                    for i = 1, 4 do AttackM1() task.wait(0.1) end
                end
            else
                local chestList = GetValidChests(LocalPlayer.Character.HumanoidRootPart.Position)
                if #chestList > 0 then
                    StatusLabel.Text = "Trạng thái: Gom rương chuẩn sau Event..."
                    for _, chestPart in ipairs(chestList) do
                        if chestPart and chestPart.Parent then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = chestPart.CFrame + Vector3.new(0, 2.5, 0)
                            pcall(function()
                                local prompt = chestPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) or chestPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                            end)
                            task.wait(0.3)
                        end
                    end
                elseif getgenv().KL_AutoHopRunning then
                    HopServerNow()
                end
            end
        end
    end
end)

-- ================= 6. AUTO NHẶT RƯƠNG BÌNH THƯỜNG (ORBIT) =================
task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().KL_AutoChestRunning and not Settings.AutoSeaEvent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local chestList = GetValidChests(hrp.Position)
            for _, chestPart in ipairs(chestList) do
                if not getgenv().KL_AutoChestRunning then break end
                local timeout = tick() + 4
                while chestPart and chestPart.Parent and tick() < timeout and getgenv().KL_AutoChestRunning do
                    StatusLabel.Text = "Trạng thái: Nhặt rương chuẩn..."
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    hrp.CFrame = CFrame.new(chestPart.Position + Vector3.new(0, 2.5, 0))
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    pcall(function()
                        local prompt = chestPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) or chestPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then fireproximityprompt(prompt) end
                        if firetouchinterest then
                            firetouchinterest(hrp, chestPart, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, chestPart, 1)
                        end
                    end)
                    RunService.Heartbeat:Wait()
                end
            end
        end
    end
end)

-- ================= 7. AUTO HOP SERVER THƯỜNG =================
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().KL_AutoHopRunning and not Settings.AutoSeaEvent then
            local elapsed = 0
            while elapsed < getgenv().KL_HopDelay and getgenv().KL_AutoHopRunning do
                task.wait(1)
                elapsed = elapsed + 1
            end
            if getgenv().KL_AutoHopRunning and not IsTeleporting then
                HopServerNow()
            end
        end
    end
end)
