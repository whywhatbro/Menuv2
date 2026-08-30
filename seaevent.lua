-- KING LEGACY: UPTIME-BASED SEA EVENT FINDER & AUTO HOPPER
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- CHU KỲ SPAWN TÍNH BẰNG GIÂY
local EVENT_INTERVALS = {
    ["Sea King"]       = 3600,  -- 1 tiếng (60 phút)
    ["Ghost Ship"]     = 6000,  -- 1 tiếng 40 phút (100 phút)
    ["Hydra"]          = 14400, -- 4 tiếng (240 phút)
    ["Kraken"]         = 7200,  -- 2 tiếng (Sea 3)
    ["Drakenfyr"]      = 7200,  -- 2 tiếng (Sea 3)
    ["Abyssal Tyrant"] = 7200,  -- 2 tiếng (Sea 3)
    ["Crab"]           = 7200   -- 2 tiếng (Sea 3)
}

local Config = {
    Enabled = false,
    SelectedEvents = {
        ["Sea King"] = true,
        ["Ghost Ship"] = true,
        ["Hydra"] = true,
        ["Kraken"] = true,
        ["Drakenfyr"] = true,
        ["Abyssal Tyrant"] = true,
        ["Crab"] = true
    },
    TargetWindow = 120, -- Khoảng thời gian sắp spawn mong muốn (mặc định 1m59s ~ 120s)
    HopDelayAfterKill = 60
}

-- 1. TẠO GUI GIAO DIỆN
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UptimeSeaEventGUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 90, 0, 35)
ToggleMenuBtn.Position = UDim2.new(0, 10, 0.4, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleMenuBtn.Text = "[UI] Sea Event"
ToggleMenuBtn.Font = Enum.Font.SourceSansBold
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 440)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "KL - SEA EVENT UPTIME HOPPER"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.Parent = MainFrame

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -120)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 380)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)

local MainToggleBtn = Instance.new("TextButton")
MainToggleBtn.Size = UDim2.new(0, 290, 0, 35)
MainToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
MainToggleBtn.Text = "Trạng Thái Auto Hop: TẮT"
MainToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MainToggleBtn.Font = Enum.Font.SourceSansBold
MainToggleBtn.TextSize = 15
MainToggleBtn.Parent = Scroll

MainToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    MainToggleBtn.Text = Config.Enabled and "Trạng Thái Auto Hop: BẬT" or "Trạng Thái Auto Hop: TẮT"
    MainToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

for eventName, _ in pairs(Config.SelectedEvents) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 290, 0, 28)
    btn.BackgroundColor3 = Config.SelectedEvents[eventName] and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(50, 50, 60)
    btn.Text = eventName .. " [" .. (Config.SelectedEvents[eventName] and "BẬT" or "TẮT") .. "]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = Scroll

    btn.MouseButton1Click:Connect(function()
        Config.SelectedEvents[eventName] = not Config.SelectedEvents[eventName]
        btn.BackgroundColor3 = Config.SelectedEvents[eventName] and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(50, 50, 60)
        btn.Text = eventName .. " [" .. (Config.SelectedEvents[eventName] and "BẬT" or "TẮT") .. "]"
    end)
end

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 65)
StatusLabel.Position = UDim2.new(0, 10, 1, -70)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.Text = "Đang chờ kích hoạt..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- 2. TÍNH TOÁN UPTIME VÀ KIỂM TRA EVENT
local function CheckUptimeAndEvent()
    local serverUptime = workspace.DistributedGameTime -- Thời gian server đã chạy (tính bằng giây)
    
    -- Kiểm tra xem hiện tại Boss đã xuất hiện sẵn trong Workspace chưa
    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:lower():find(eventName:lower()) then
                    return true, eventName, 0 -- Boss đang có mặt (0s còn lại)
                end
            end
        end
    end

    -- Nếu chưa có Boss, tính toán thời gian sắp spawn dựa vào chu kỳ
    local minTimeToNextSpawn = 999999
    local targetEventName = nil

    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected and EVENT_INTERVALS[eventName] then
            local interval = EVENT_INTERVALS[eventName]
            local timeSinceLastSpawn = serverUptime % interval
            local timeToNextSpawn = interval - timeSinceLastSpawn

            if timeToNextSpawn < minTimeToNextSpawn then
                minTimeToNextSpawn = timeToNextSpawn
                targetEventName = eventName
            end
        end
    end

    return false, targetEventName, math.floor(minTimeToNextSpawn)
end

-- 3. CHUYỂN SERVER
local function HopServer()
    StatusLabel.Text = "Đang quét Server public..."
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    local body = nil

    if req then
        local res = req({Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId), Method = "GET"})
        body = res.Body
    else
        body = game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100", PlaceId))
    end

    if body then
        local data = HttpService:JSONDecode(body)
        if data and data.data then
            local servers = {}
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
            if #servers > 0 then
                StatusLabel.Text = "Đang chuyển sang Server mới..."
                TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                return
            end
        end
    end

    StatusLabel.Text = "Hop Server ngẫu nhiên..."
    TeleportService:Teleport(PlaceId, LocalPlayer)
end

-- 4. VÒNG LẶP CHÍNH
task.spawn(function()
    while true do
        task.wait(3)
        if Config.Enabled then
            local isSpawned, eventName, timeRemaining = CheckUptimeAndEvent()

            if isSpawned then
                StatusLabel.Text = "🎉 PHÁT HIỆN: " .. eventName .. " đang xuất hiện! Giữ Server..."
                repeat 
                    task.wait(5)
                    isSpawned, _, _ = CheckUptimeAndEvent()
                until not isSpawned or not Config.Enabled

                if Config.Enabled then
                    StatusLabel.Text = "Đánh xong/Event kết thúc! Chờ " .. Config.HopDelayAfterKill .. "s để chuyển Server..."
                    task.wait(Config.HopDelayAfterKill)
                    HopServer()
                end
            elseif timeRemaining <= Config.TargetWindow then
                StatusLabel.Text = "⏳ Server Uptime phù hợp! " .. tostring(eventName) .. " sẽ spawn trong " .. timeRemaining .. "s nữa. Giữ Server..."
                task.wait(timeRemaining + 5) -- Đợi cho tới khi đến thời gian spawn
            else
                StatusLabel.Text = "❌ Server này phải chờ thêm " .. timeRemaining .. "s nữa mới có Event (" .. tostring(eventName) .. "). Đang Hop..."
                task.wait(1.5)
                HopServer()
            end
        else
            StatusLabel.Text = "Auto Hop đang TẮT."
        end
    end
end)
