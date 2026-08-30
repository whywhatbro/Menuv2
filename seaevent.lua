-- =================================================================
-- KING LEGACY - V13 PRO (FIX TỰ ĐỘNG NHẤN TỌA ĐỘ KHI ĐỔI SERVER)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

-- Biến đánh dấu thời điểm vừa vào server (dùng để ép bấm nút Play trong 15s đầu)
local ServerJoinTick = tick()

-- ================= HỆ THỐNG LƯU CÀI ĐẶT =================
local SettingsFile = "KingLegacy_AutoChest_Settings_V13.json"
local Settings = { 
    AutoHop = false, 
    AutoChest = false, 
    HopDelay = 15,
    PlayX = 0,
    PlayY = 0
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
                Settings.AutoHop = decoded.AutoHop or false
                Settings.AutoChest = decoded.AutoChest or false
                Settings.HopDelay = decoded.HopDelay or 15
                Settings.PlayX = decoded.PlayX or 0
                Settings.PlayY = decoded.PlayY or 0
            end
        end
    end)
end

LoadSettings()
getgenv().KL_AutoHopRunning = Settings.AutoHop
getgenv().KL_AutoChestRunning = Settings.AutoChest
getgenv().KL_HopDelay = Settings.HopDelay

local VisitedServers = {}
local IsTeleporting = false
local isSettingCoord = false

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
    if getgenv().KL_AutoHopRunning then
        IsTeleporting = false
        task.wait(2)
    end
end)

-- ================= HÀM KÍCH HOẠT NÚT PLAY THEO TỌA ĐỘ =================
local function ExecutePlayClick()
    local success = false
    if Settings.PlayX > 0 and Settings.PlayY > 0 then
        pcall(function()
            if VirtualInputManager and VirtualInputManager.SendTouchEvent then
                for i = 1, 3 do
                    VirtualInputManager:SendTouchEvent(0, 0, 0, Settings.PlayX, Settings.PlayY, game)
                    task.wait(0.03)
                    VirtualInputManager:SendTouchEvent(0, 1, 0, Settings.PlayX, Settings.PlayY, game)
                    task.wait(0.05)
                end
                success = true
            end
        end)
    else
        -- Fallback quét giao diện nếu chưa đặt tọa độ
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.AbsolutePosition.X > 0 then
                    local matched = false
                    local name = string.lower(gui.Name)
                    if string.find(name, "play") or string.find(name, "start") or string.find(name, "pirate") or string.find(name, "marine") then
                        matched = true
                    else
                        for _, child in pairs(gui:GetDescendants()) do
                            if child:IsA("TextLabel") or child:IsA("TextBox") then
                                local cText = string.lower(child.Text)
                                if string.find(cText, "play") or string.find(cText, "start") or string.find(cText, "pirate") or string.find(cText, "marine") then
                                    matched = true
                                    break
                                end
                            end
                        end
                    end
                    if matched then
                        success = true
                        pcall(function() gui:Activate() end)
                    end
                end
            end
        end
    end
    return success
end

-- ================= VÒNG LẶP KIỂM TRA & ÉP BẤM PLAY KHI VÀO SERVER =================
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- Nếu vừa vào server chưa đến 15 giây, ép bấm liên tục tọa độ Play
            if tick() - ServerJoinTick < 15 then
                ExecutePlayClick()
            else
                -- Sau 15 giây kiểm tra trạng thái nhân vật bình thường
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if char and humanoid and hrp and humanoid.Health > 0 then
                    if Camera.CameraSubject ~= humanoid or Camera.CameraType ~= Enum.CameraType.Custom then
                        Camera.CameraType = Enum.CameraType.Custom
                        Camera.CameraSubject = humanoid
                    end
                else
                    ExecutePlayClick()
                end
            end
        end)
    end
end)

-- ================= GIAO DIỆN MENU (ẨN BAN ĐẦU) =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MobileMasterGui_V13"
ScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 11
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 470)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "AUTO EVENT KL V13 (FIX HOP AUTO CLICK)"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 10
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 25)
StatusLabel.Position = UDim2.new(0, 8, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Sẵn sàng."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

local SetCoordBtn = Instance.new("TextButton")
SetCoordBtn.Size = UDim2.new(1, -16, 0, 35)
SetCoordBtn.Position = UDim2.new(0, 8, 0, 68)
SetCoordBtn.BackgroundColor3 = Color3.fromRGB(220, 100, 0)
SetCoordBtn.Text = "📍 ĐẶT VỊ TRÍ NÚT PLAY (BẤM VÀO ĐÂY RỒI CHẠM NÚT PLAY)"
SetCoordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetCoordBtn.Font = Enum.Font.SourceSansBold
SetCoordBtn.TextSize = 10
SetCoordBtn.Parent = MainFrame

local CoordInfoLabel = Instance.new("TextLabel")
CoordInfoLabel.Size = UDim2.new(1, -16, 0, 20)
CoordInfoLabel.Position = UDim2.new(0, 8, 0, 105)
CoordInfoLabel.BackgroundTransparency = 1
CoordInfoLabel.Text = (Settings.PlayX > 0 and "Đã lưu tọa độ: X="..math.floor(Settings.PlayX).." Y="..math.floor(Settings.PlayY)) or "Tọa độ nút Play: Chưa thiết lập"
CoordInfoLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
CoordInfoLabel.Font = Enum.Font.SourceSans
CoordInfoLabel.TextSize = 10
CoordInfoLabel.Parent = MainFrame

SetCoordBtn.MouseButton1Click:Connect(function()
    isSettingCoord = true
    StatusLabel.Text = "Trạng thái: HÃY CHẠM VÀO NÚT PLAY TRÊN MÀN HÌNH NGAY!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
end)

UserInputService.InputBegan:Connect(function(input)
    if isSettingCoord and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        Settings.PlayX = input.Position.X
        Settings.PlayY = input.Position.Y
        isSettingCoord = false
        SaveSettings()
        StatusLabel.Text = "Trạng thái: Đã lưu vị trí nút Play thành công!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        CoordInfoLabel.Text = "Đã lưu tọa độ: X="..math.floor(Settings.PlayX).." Y="..math.floor(Settings.PlayY)
    end
end)

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0.35, 0, 0, 25)
TimeTextBox.Position = UDim2.new(0.62, 0, 0, 135)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
TimeTextBox.Text = tostring(getgenv().KL_HopDelay)
TimeTextBox.TextColor3 = Color3.fromRGB(0, 255, 180)
TimeTextBox.Font = Enum.Font.SourceSansBold
TimeTextBox.TextSize = 12
TimeTextBox.Parent = MainFrame

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0.6, 0, 0, 25)
TimeLabel.Position = UDim2.new(0, 8, 0, 135)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = " Thời gian ở SV (giây):"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextSize = 11
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
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
AutoHopBtn.Position = UDim2.new(0, 8, 0, 170)
AutoHopBtn.Parent = MainFrame
AutoHopBtn.Font = Enum.Font.SourceSansBold
AutoHopBtn.TextSize = 11

local AutoChestBtn = Instance.new("TextButton")
AutoChestBtn.Size = UDim2.new(1, -16, 0, 32)
AutoChestBtn.Position = UDim2.new(0, 8, 0, 210)
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

-- ================= 3. AUTO HOP SERVER (8-11 NGƯỜI) =================
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

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().KL_AutoHopRunning = not getgenv().KL_AutoHopRunning
    Settings.AutoHop = getgenv().KL_AutoHopRunning
    SaveSettings()
    UpdateButtons()
end)

AutoChestBtn.MouseButton1Click:Connect(function()
    getgenv().KL_AutoChestRunning = not getgenv().KL_AutoChestRunning
    Settings.AutoChest = getgenv().KL_AutoChestRunning
    SaveSettings()
    UpdateButtons()
    if not getgenv().KL_AutoChestRunning then
        StatusLabel.Text = "Trạng thái: Đã tắt."
    end
end)
