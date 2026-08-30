-- KING LEGACY: EXACT UPTIME MILESTONE HOPPER (<= 3 MINS TO SPAWN)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- CHU KỲ XUẤT HIỆN TÍNH THEO GIÂY TỪ LÚC SERVER MỚI MỞ
local EVENT_INTERVALS = {
    ["Sea King"]       = 3600,  -- Mỗi 60 phút (1 tiếng, 2 tiếng, 3 tiếng...)
    ["Ghost Ship"]     = 6000,  -- Mỗi 100 phút (1t40p, 3t20p, 5t00p...)
    ["Hydra"]          = 14400, -- Mỗi 240 phút (4 tiếng, 8 tiếng...)
    ["Kraken"]         = 7200,  -- Mỗi 120 phút (2 tiếng, 4 tiếng...)
    ["Drakenfyr"]      = 7200,  
    ["Abyssal Tyrant"] = 7200,  
    ["Crab"]           = 7200   
}

local Config = {
    Enabled = true,
    SelectedEvents = {
        ["Sea King"] = true,
        ["Ghost Ship"] = true,
        ["Hydra"] = true,
        ["Kraken"] = true,
        ["Drakenfyr"] = true,
        ["Abyssal Tyrant"] = true,
        ["Crab"] = true
    },
    MaxWaitTime = 180, -- CHỈ Ở LẠI NẾU CÒN <= 180s (3 PHÚT) LÀ TỚI MỐC SPAWN
    HopDelayAfterKill = 15
}

-- 1. GUI THÔNG BÁO
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MilestoneSeaEventGUI"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 160)
MainFrame.Position = UDim2.new(0.5, -170, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "KL - MILESTONE UPTIME SCANNER (<= 3M)"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 70)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "⚡ Đang tính toán Uptime Server..."
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 110)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
ToggleBtn.Text = "Auto Hop: BẬT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "Auto Hop: BẬT" or "Auto Hop: TẮT"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(180, 40, 40)
end)

-- 2. HÀM HOP SERVER NGẪU NHIÊN SIÊU TỐC
local visitedServers = {}

local function FastHop()
    StatusLabel.Text = "🔍 Đang đổi Server khác để kiểm tra Uptime..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
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
        task.wait(0.1)
    end

    if targetServer then
        visitedServers[targetServer] = true
        TeleportService:TeleportToPlaceInstance(PlaceId, targetServer, LocalPlayer)
    else
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
end

-- 3. TÍNH TOÁN KHOẢNG CÁCH TỚI MỐC SPAWN GẦN NHẤT
local function CalculateTimeToNextMilestone()
    local serverUptime = workspace.DistributedGameTime -- Thời gian thực Server đã mở (tính bằng giây)

    -- Kiểm tra nếu Boss đã lỡ xuất hiện sẵn trên Map
    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:lower():find(eventName:lower()) then
                    return true, eventName, 0
                end
            end
        end
    end

    local minTimeToMilestone = 999999
    local targetEventName = nil

    for eventName, isSelected in pairs(Config.SelectedEvents) do
        if isSelected and EVENT_INTERVALS[eventName] then
            local interval = EVENT_INTERVALS[eventName]
            
            -- Tính mốc tiếp theo kể từ khi Server tạo (0s -> Interval -> 2*Interval...)
            local timeToNextMilestone = interval - (serverUptime % interval)

            if timeToNextMilestone < minTimeToMilestone then
                minTimeToMilestone = timeToNextMilestone
                targetEventName = eventName
            end
        end
    end

    return false, targetEventName, math.floor(minTimeToMilestone), math.floor(serverUptime)
end

-- 4. VÒNG LẶP KIỂM TRA CHẶT CHẼ
task.spawn(function()
    task.wait(1) -- Chờ 1 giây để đọc đúng Uptime từ Workspace

    while true do
        if Config.Enabled then
            local isSpawned, eventName, timeRemaining, currentUptime = CalculateTimeToNextMilestone()

            local uptimeMin = math.floor(currentUptime / 60)
            local uptimeSec = currentUptime % 60

            if isSpawned then
                StatusLabel.Text = string.format("🎉 %s ĐANG XUẤT HIỆN!\n(Server Uptime: %d phút %ds)\nĐang giữ Server...", eventName, uptimeMin, uptimeSec)
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                
                repeat 
                    task.wait(3)
                    isSpawned, _, _, _ = CalculateTimeToNextMilestone()
                until not isSpawned or not Config.Enabled

                if Config.Enabled then
                    StatusLabel.Text = "⚔️ Boss đã hết! Đợi " .. Config.HopDelayAfterKill .. "s để Hop..."
                    task.wait(Config.HopDelayAfterKill)
                    FastHop()
                end

            elseif timeRemaining <= Config.MaxWaitTime then
                -- THỎA MÃN ĐIỀU KIỆN: Server này mở được X phút và chỉ còn <= 180s là tới mốc Spawn!
                StatusLabel.Text = string.format("🎯 ĐÃ TÌM THẤY SERVER CHUẨN!\nUptime hiện tại: %d phút %ds\n%s sẽ Spawn sau: %d giây", uptimeMin, uptimeSec, tostring(eventName), timeRemaining)
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                
                -- Giữ Server chờ đúng mốc xuất hiện
                task.wait(timeRemaining + 3)

            else
                -- BỎ QUA NẾU > 3 PHÚT: Chuyển ngay lập tức
                StatusLabel.Text = string.format("❌ Server Uptime: %d phút\nMốc %s gần nhất còn %ds (> 3 phút)\n⚡ Đang Hop ngay...", uptimeMin, tostring(eventName), timeRemaining)
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                task.wait(0.5)
                FastHop()
                break
            end
        else
            StatusLabel.Text = "Auto Hop đang TẮT."
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        task.wait(2)
    end
end)

TeleportService.TeleportInitFailed:Connect(function(player)
    if player == LocalPlayer and Config.Enabled then
        FastHop()
    end
end)
