-- =================================================================
-- KING LEGACY - V16 PRO (FIX LỖI KHÔNG MỞ ĐƯỢC MENU TRÊN MOBILE)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local ServerJoinTick = tick()

-- ================= HỆ THỐNG LƯU CÀI ĐẶT =================
local SettingsFile = "KingLegacy_AutoChest_Settings.json"
local Settings = { 
    AutoHop = false, 
    AutoChest = false, 
    HopDelay = 15,
    DotX = 0.5, 
    DotY = 0.5,
    IsLocked = false,
    AutoPlay = true
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
                Settings.AutoHop = decoded.AutoHop ~= nil and decoded.AutoHop or false
                Settings.AutoChest = decoded.AutoChest ~= nil and decoded.AutoChest or false
                Settings.HopDelay = decoded.HopDelay or 15
                Settings.DotX = decoded.DotX or 0.5
                Settings.DotY = decoded.DotY or 0.5
                Settings.IsLocked = decoded.IsLocked ~= nil and decoded.IsLocked or false
                Settings.AutoPlay = decoded.AutoPlay ~= nil and decoded.AutoPlay or true
            end
        end
    end)
end

LoadSettings()
getgenv().KL_AutoHopRunning = Settings.AutoHop
getgenv().KL_AutoChestRunning = Settings.AutoChest
getgenv().KL_HopDelay = Settings.HopDelay
getgenv().KL_AutoPlayRunning = Settings.AutoPlay

local VisitedServers = {}
local IsTeleporting = false

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if getgenv().KL_AutoHopRunning then
        IsTeleporting = false
        task.wait(2)
    end
end)

-- ================= GIAO DIỆN CHÍNH =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MobileMasterGui_V16"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- HÌNH TRÒN KÉO THẢ ĐẾN NÚT PLAY
local PlayDot = Instance.new("TextButton")
PlayDot.Size = UDim2.new(0, 40, 0, 40)
PlayDot.Position = UDim2.new(Settings.DotX, -20, Settings.DotY, -20)
PlayDot.BackgroundColor3 = Settings.IsLocked and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
PlayDot.Text = "PLAY"
PlayDot.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayDot.Font = Enum.Font.SourceSansBold
PlayDot.TextSize = 10
PlayDot.ZIndex = 5
PlayDot.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = PlayDot

-- Logic kéo thả
local dragging = false
local dragStart, startPos

PlayDot.InputBegan:Connect(function(input)
    if not Settings.IsLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = PlayDot.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and not Settings.IsLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        PlayDot.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

PlayDot.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            local absPos = PlayDot.AbsolutePosition
            local absSize = PlayDot.AbsoluteSize
            local centerX = absPos.X + (absSize.X / 2)
            local centerY = absPos.Y + (absSize.Y / 2)
            Settings.DotX = centerX / Workspace.CurrentCamera.ViewportSize.X
            Settings.DotY = centerY / Workspace.CurrentCamera.ViewportSize.Y
            SaveSettings()
        end
    end
end)

-- NÚT BẬT/TẮT MENU (ÉP ZIndex CAO NHẤT ĐỂ KHÔNG BỊ CHẶN)
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
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.ZIndex = 9
MainFrame.Parent = ScreenGui

-- Sử dụng .Activated để ăn cảm ứng cực tốt trên Mobile
ToggleBtn.Activated:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "AUTO EVENT KL V16 (FIX MOBILE TOUCH)"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 10
Title.ZIndex = 9
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 25)
StatusLabel.Position = UDim2.new(0, 8, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Sẵn sàng."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.ZIndex = 9
StatusLabel.Parent = MainFrame

-- NÚT KHÓA / MỞ KHÓA VỊ TRÍ
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(1, -16, 0, 32)
LockBtn.Position = UDim2.new(0, 8, 0, 65)
LockBtn.BackgroundColor3 = Settings.IsLocked and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
LockBtn.Text = Settings.IsLocked and "🔒 KHÓA ĐIỂM NHẤN: ĐANG KHÓA" or "🔓 KHÓA ĐIỂM NHẤN: ĐANG MỞ (CÓ THỂ KÉO)"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.SourceSansBold
LockBtn.TextSize = 10
LockBtn.ZIndex = 9
LockBtn.Parent = MainFrame

LockBtn.Activated:Connect(function()
    Settings.IsLocked = not Settings.IsLocked
    SaveSettings()
    LockBtn.BackgroundColor3 = Settings.IsLocked and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    LockBtn.Text = Settings.IsLocked and "🔒 KHÓA ĐIỂM NHẤN: ĐANG KHÓA" or "🔓 KHÓA ĐIỂM NHẤN: ĐANG MỞ (CÓ THỂ KÉO)"
    PlayDot.BackgroundColor3 = Settings.IsLocked and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    StatusLabel.Text = Settings.IsLocked and "Trạng thái: Đã khóa vị trí hình tròn!" or "Trạng thái: Đã mở khóa hình tròn."
end)

-- NÚT BẬT / TẮT TỰ ĐỘNG PLAY
local AutoPlayBtn = Instance.new("TextButton")
AutoPlayBtn.Size = UDim2.new(1, -16, 0, 32)
AutoPlayBtn.Position = UDim2.new(0, 8, 0, 102)
AutoPlayBtn.Font = Enum.Font.SourceSansBold
AutoPlayBtn.TextSize = 10
AutoPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPlayBtn.ZIndex = 9
AutoPlayBtn.Parent = MainFrame

local function UpdateAutoPlayButton()
    AutoPlayBtn.BackgroundColor3 = getgenv().KL_AutoPlayRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoPlayBtn.Text = getgenv().KL_AutoPlayRunning and "TỰ ĐỘNG PLAY (TÂM HÌNH TRÒN): BẬT" or "TỰ ĐỘNG PLAY (TÂM HÌNH TRÒN): TẮT"
end
UpdateAutoPlayButton()

AutoPlayBtn.Activated:Connect(function()
    getgenv().KL_AutoPlayRunning = not getgenv().KL_AutoPlayRunning
    Settings.AutoPlay = getgenv().KL_AutoPlayRunning
    SaveSettings()
    UpdateAutoPlayButton()
end)

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0.35, 0, 0, 25)
TimeTextBox.Position = UDim2.new(0.62, 0, 0, 142)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
TimeTextBox.Text = tostring(getgenv().KL_HopDelay)
TimeTextBox.TextColor3 = Color3.fromRGB(0, 255, 180)
TimeTextBox.Font = Enum.Font.SourceSansBold
TimeTextBox.TextSize = 12
TimeTextBox.ZIndex = 9
TimeTextBox.Parent = MainFrame

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0.6, 0, 0, 25)
TimeLabel.Position = UDim2.new(0, 8, 0, 142)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = " Thời gian ở SV (giây):"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextSize = 11
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.ZIndex = 9
TimeLabel.Parent = MainFrame

TimeTextBox.FocusLost:Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val and val >= 3 then
        getgenv().KL_HopDelay = val
        Settings.HopDelay = val
        SaveSettings()
    end
    TimeTextBox.Text = tostring(getgenv().KL_HopDelay)
end)

local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -16, 0, 32)
AutoHopBtn.Position = UDim2.new(0, 8, 0, 175)
AutoHopBtn.ZIndex = 9
AutoHopBtn.Parent = MainFrame
AutoHopBtn.Font = Enum.Font.SourceSansBold
AutoHopBtn.TextSize = 11

local AutoChestBtn = Instance.new("TextButton")
AutoChestBtn.Size = UDim2.new(1, -16, 0, 32)
AutoChestBtn.Position = UDim2.new(0, 8, 0, 215)
AutoChestBtn.ZIndex = 9
AutoChestBtn.Parent = MainFrame
AutoChestBtn.Font = Enum.Font.SourceSansBold
AutoChestBtn.TextSize = 11

local function UpdateButtons()
    AutoHopBtn.BackgroundColor3 = getgenv().KL_AutoHopRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoHopBtn.Text = getgenv().KL_AutoHopRunning and "AUTO HOP SERVER: BẬT" or "AUTO HOP SERVER: TẮT"
    
    AutoChestBtn.BackgroundColor3 = getgenv().KL_AutoChestRunning and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    AutoChestBtn.Text = getgenv().KL_AutoChestRunning and "AUTO NHẶT RƯƠNG (ORBIT): BẬT" or "AUTO NHẶT RƯƠNG (ORBIT): TẮT"
end
UpdateButtons()

-- ================= HÀM KÍCH HOẠT NÚT PLAY =================
local function ExecutePlayClickAtDot()
    if not getgenv().KL_AutoPlayRunning then return end
    pcall(function()
        if VirtualInputManager and VirtualInputManager.SendTouchEvent then
            local absPos = PlayDot.AbsolutePosition
            local absSize = PlayDot.AbsoluteSize
            local centerX = absPos.X + (absSize.X / 2)
            local centerY = absPos.Y + (absSize.Y / 2)
            
            for i = 1, 2 do
                VirtualInputManager:SendTouchEvent(0, 0, 0, centerX, centerY, game)
                task.wait(0.03)
                VirtualInputManager:SendTouchEvent(0, 1, 0, centerX, centerY, game)
                task.wait(0.05)
            end
        end
    end)
end

-- ================= VÒNG LẶP KIỂM TRA =================
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if tick() - ServerJoinTick < 12 then
                ExecutePlayClickAtDot()
            else
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if char and humanoid and hrp and humanoid.Health > 0 then
                    if Camera.CameraSubject ~= humanoid or Camera.CameraType ~= Enum.CameraType.Custom then
                        Camera.CameraType = Enum.CameraType.Custom
                        Camera.CameraSubject = humanoid
                    end
                else
                    ExecutePlayClickAtDot()
                end
            end
        end)
    end
end)

-- ================= 2. AUTO NHẶT RƯƠNG (ORBIT) =================
local function GetValidChests(hrpPosition)
    local chests = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (string.find(name, "chest") or string.find(name, "reward")) then
            local isIgnored = false
            if string.find(name, "gacha") or string.find(name, "fruit") or string.find(name, "barrel") or string.find(name, "crate") or string.find(name, "box") then
                isIgnored = true
            end
            if not isIgnored then
                local current = obj.Parent
                while current and current ~= Workspace do
                    local cName = string.lower(current.Name)
                    if string.find(cName, "quest") or string.find(cName, "daily") or string.find(cName, "delivery") or string.find(cName, "bandit") or string.find(cName, "pirate") or string.find(cName, "marine") or string.find(cName, "gacha") or string.find(cName, "fruit") or string.find(cName, "spawn") or string.find(cName, "barrel") then
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
    table.sort(chests, function(a, b)
        return (a.Position - hrpPosition).Magnitude < (b.Position - hrpPosition).Magnitude
    end)
    return chests
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().KL_AutoChestRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local chestList = GetValidChests(hrp.Position)
            for _, chestPart in ipairs(chestList) do
                if not getgenv().KL_AutoChestRunning then break end
                local timeout = tick() + 5 
                while chestPart and chestPart.Parent and tick() < timeout and getgenv().KL_AutoChestRunning do
                    StatusLabel.Text = "Trạng thái: Đang nhặt rương (Orbit)..."
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

-- ================= 3. AUTO HOP SERVER =================
local function HopServer()
    if IsTeleporting then return end
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and not VisitedServers[svr.id] and svr.playing >= 8 and svr.playing <= 11 then
                VisitedServers[svr.id] = true
                IsTeleporting = true
                StatusLabel.Text = "Trạng thái: Đang kết nối server mới..."
                ServerJoinTick = tick()
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, svr.id, LocalPlayer)
                end)
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().KL_AutoHopRunning then
            local elapsed = 0
            while elapsed < getgenv().KL_HopDelay and getgenv().KL_AutoHopRunning do
                task.wait(1)
                elapsed = elapsed + 1
            end
            if getgenv().KL_AutoHopRunning and not IsTeleporting then
                HopServer()
            end
        end
    end
end)

AutoHopBtn.Activated:Connect(function()
    getgenv().KL_AutoHopRunning = not getgenv().KL_AutoHopRunning
    Settings.AutoHop = getgenv().KL_AutoHopRunning
    SaveSettings()
    UpdateButtons()
end)

AutoChestBtn.Activated:Connect(function()
    getgenv().KL_AutoChestRunning = not getgenv().KL_AutoChestRunning
    Settings.AutoChest = getgenv().KL_AutoChestRunning
    SaveSettings()
    UpdateButtons()
    if not getgenv().KL_AutoChestRunning then
        StatusLabel.Text = "Trạng thái: Đã tắt."
    end
end)
