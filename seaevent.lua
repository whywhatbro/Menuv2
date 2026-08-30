-- KING LEGACY: DELAYED HOPPER WITH SAVE CONFIG & AUTO EXECUTE (STRICT <= 180S)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local CONFIG_FILE = "KL_SeaEvent_Config.json"

-- CHU KỲ XUẤT HIỆN TÍNH THEO GIÂY TỪ LÚC SERVER MỚI TẠO (0s)
local EVENT_INTERVALS = {
    ["Sea King"]       = 3600,  -- Mốc 1 tiếng, 2 tiếng, 3 tiếng...
    ["Ghost Ship"]     = 6000,  -- Mốc 1t40p (100p), 3t20p...
    ["Hydra"]          = 14400, -- Mốc 4 tiếng, 8 tiếng...
    ["Kraken"]         = 7200,  -- Mốc 2 tiếng...
    ["Drakenfyr"]      = 7200,  
    ["Abyssal Tyrant"] = 7200,  
    ["Crab"]           = 7200   
}

local Config = {
    Enabled = true,
    AutoReExec = true,
    HopCountdown = 5, -- Thời gian đếm ngược trước khi Hop (5 giây để kịp bấm tắt)
    SelectedEvents = {
        ["Sea King"]       = true,
        ["Ghost Ship"]     = true,
        ["Hydra"]          = true,
        ["Kraken"]         = false,
        ["Drakenfyr"]      = false,
        ["Abyssal Tyrant"] = false,
        ["Crab"]           = false
    },
    MaxWaitTime = 180, -- CHỈ Ở LẠI NẾU CÒN <= 180s (3 PHÚT)
    HopDelayAfterKill = 15
}

local isHopping = false -- Trạng thái đang đếm ngược Hop

-- 1. TẢI VÀ LƯU CẤU HÌNH (SAVE / LOAD CONFIG)
local function SaveConfig()
    if writefile then
        local data = HttpService:JSONEncode({
            Enabled = Config.Enabled,
            AutoReExec = Config.AutoReExec,
            HopCountdown = Config.HopCountdown,
            SelectedEvents = Config.SelectedEvents
        })
        pcall(writefile, CONFIG_FILE, data)
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(result) == "table" then
            if result.Enabled ~= nil then Config.Enabled = result.Enabled end
            if result.AutoReExec ~= nil then Config.AutoReExec = result.AutoReExec end
            if result.HopCountdown then Config.HopCountdown = result.HopCountdown end
            if result.SelectedEvents then
                for k, v in pairs(result.SelectedEvents) do
                    Config.SelectedEvents[k] = v
                end
            end
        end
    end
end

LoadConfig()

-- 2. TẠO GIAO DIỆN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DelayedUptimeScannerGUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 430)
MainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "KL - SEA EVENT HOPPER (DELAY SAFE)"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "⚡ Đang kiểm tra Uptime Server..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

local MainToggleBtn = Instance.new("TextButton")
MainToggleBtn.Size = UDim2.new(1, -20, 0, 30)
MainToggleBtn.Position = UDim2.new(0, 10, 0, 100)
MainToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
MainToggleBtn.Text = "AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT")
MainToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggleBtn.Font = Enum.Font.SourceSansBold
MainToggleBtn.TextSize = 13
MainToggleBtn.Parent = MainFrame

MainToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    MainToggleBtn.Text = "AUTO HOP: " .. (Config.Enabled and "BẬT" or "TẮT")
    MainToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
    isHopping = false -- Hủy trạng thái Hop nếu đang đếm ngược
    SaveConfig()
end)

local AutoReExecBtn = Instance.new("TextButton")
AutoReExecBtn.Size = UDim2.new(1, -20, 0, 30)
AutoReExecBtn.Position = UDim2.new(0, 10, 0, 135)
AutoReExecBtn.BackgroundColor3 = Config.AutoReExec and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70)
AutoReExecBtn.Text = "TỰ BẬT LẠI KHI HOP: " .. (Config.AutoReExec and "BẬT" or "TẮT")
AutoReExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoReExecBtn.Font = Enum.Font.SourceSansBold
AutoReExecBtn.TextSize = 13
AutoReExecBtn.Parent = MainFrame

AutoReExecBtn.MouseButton1Click:Connect(function()
    Config.AutoReExec = not Config.AutoReExec
    AutoReExecBtn.Text = "TỰ BẬT LẠI KHI HOP: " .. (Config.AutoReExec and "BẬT" or "TẮT")
    AutoReExecBtn.BackgroundColor3 = Config.AutoReExec and Color3.fromRGB(140, 60, 200) or Color3.fromRGB(60, 60, 70)
    SaveConfig()
end)

-- KHU VỰC CHỌN BOSS
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 0, 210)
Scroll.Position = UDim2.new(0, 10, 0, 172)
Scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 240)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 4)

for eventName, isEnabled in pairs(Config.SelectedEvents) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 28)
    btn.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60)
    btn.Text = eventName .. " [" .. (isEnabled and "BẬT" or "TẮT") .. "]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = Scroll

    btn.MouseButton1Click:Connect(function()
        Config.SelectedEvents[eventName] = not Config.SelectedEvents[eventName]
        btn.BackgroundColor3 = Config.SelectedEvents[eventName] and Color3.fromRGB(0, 130, 200) or Color3.fromRGB(50, 50, 60)
        btn.Text = eventName .. " [" .. (Config.SelectedEvents[eventName] and "BẬT" or "TẮT") .. "]"
        SaveConfig()
    end)
end

-- 3. HÀM THỰC HIỆN HOP SERVER
local visitedServers = {}

local function PerformHop()
    if Config.AutoReExec and queue_on_teleport then
        queue_on_teleport([[
            repeat task.wait() until game:IsLoaded()
            loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()
        ]])
    end

    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
    local cursor = ""
    local targetServer = nil

    for page = 1, 5 do
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s", PlaceId, (cursor ~= "" and "&cursor=" .. cursor or ""))
        local success, response = pcall(function()
            if httpRequest then
                return httpRequest({Url = url, Method = "GET"}).Body
            else
                return game:HttpGet(url)
            end
        end)

        if success and response then
            local decodeOk, data = pcall(function() return HttpService:JSONDecode(response) end)
            if decodeOk and data and data.data then
                local valid = {}
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers and not visitedServers[s.id] then
                        table.insert(valid, s.id)
                    end
                end

                if #valid > 0 then
                    targetServer = valid[math.random(1, #valid)]
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

-- 4. BỘ ĐẾM NGƯỢC THỜI GIAN CHỜ TRƯỚC KHI HOP (DELAY COUNTDOWN)
local function StartHopCountdown()
    isHopping = true
    for i = Config.HopCountdown, 1, -1 do
        if not Config.Enabled or not isHopping then
            StatusLabel.Text = "🛑 ĐÃ HỦY QUÁ TRÌNH HOP SERVER!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
            isHopping = false
            return false
        end
        StatusLabel.Text = string.format("❌ Server không phù hợp!\n⏳ Sẽ Hop Server trong: %d giây... (Tắt Hop để Hủy)", i)
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1)
    end

    if Config.Enabled and isHopping then
        StatusLabel.Text = "⚡ Đang tiến hành Hop Server..."
        PerformHop()
    end
end

-- 5. TÍNH MỐC UPTIME
local function ScanSelectedMilestones()
    local uptime = workspace.DistributedGameTime

    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:lower():find(eventName:lower()) then
                    return true, eventName, 0, uptime
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

    return false, targetEventName, math.floor(minTimeToMilestone), math.floor(uptime)
end

-- 6. VÒNG LẶP KIỂM TRA
local function RunCheck()
    if not Config.Enabled or isHopping then return end

    local isSpawned, eventName, timeRemaining, currentUptime = ScanSelectedMilestones()
    local uptimeMin = math.floor(currentUptime / 60)
    local uptimeSec = currentUptime % 60

    if not eventName and not isSpawned then
        StatusLabel.Text = "⚠️ Chưa BẬT Boss nào trong menu!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        return
    end

    if isSpawned then
        StatusLabel.Text = string.format("🎉 PHÁT HIỆN: %s ĐANG XUẤT HIỆN!\n(Uptime: %d phút %ds)\nĐang giữ Server...", eventName, uptimeMin, uptimeSec)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        repeat 
            task.wait(3)
            isSpawned, _, _, _ = ScanSelectedMilestones()
        until not isSpawned or not Config.Enabled

        if Config.Enabled then
            task.wait(Config.HopDelayAfterKill)
            StartHopCountdown()
        end

    elseif timeRemaining <= Config.MaxWaitTime then
        StatusLabel.Text = string.format("🎯 ĐÃ TÌM THẤY SERVER!\nUptime: %d phút %ds\n%s sẽ Spawn sau: %d giây", uptimeMin, uptimeSec, tostring(eventName), timeRemaining)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        task.wait(timeRemaining + 3)

    else
        -- Bắt đầu đếm ngược 5s trước khi nhảy sang Server khác
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

TeleportService.TeleportInitFailed:Connect(function(player)
    if player == LocalPlayer and Config.Enabled then
        PerformHop()
    end
end)
