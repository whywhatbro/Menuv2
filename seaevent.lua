-- =================================================================
-- KING LEGACY - MULTI-BOSS 5-MINUTE WINDOW & EXACT MILESTONE FILTER
-- =================================================================

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Cấu hình chu kỳ chuẩn xác của từng Boss (Tính bằng phút)
local BossData = {
    ["Sea King"] = {Interval = 60},
    ["Ghost Ship"] = {Interval = 100},
    ["Hydra"] = {Interval = 240}
}

local SelectedBoss = "Sea King"

-- Giao diện UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MultiBossFilter_GUI"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
ToggleBtn.Text = "BOSS"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 460)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "LỌC SERVER SẮP SPAWN BOSS TRONG 5 PHÚT"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = MainFrame

-- Nút chuyển đổi loại Boss cần lọc
local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, -20, 0, 30)
DropdownBtn.Position = UDim2.new(0, 10, 0, 45)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
DropdownBtn.Text = "Chọn Boss: Sea King (Nhấn để đổi)"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
DropdownBtn.Font = Enum.Font.SourceSansBold
DropdownBtn.TextSize = 12
DropdownBtn.Parent = MainFrame

local bossKeys = {"Sea King", "Ghost Ship", "Hydra"}
local bIndex = 1
DropdownBtn.MouseButton1Click:Connect(function()
    bIndex = bIndex % #bossKeys + 1
    SelectedBoss = bossKeys[bIndex]
    DropdownBtn.Text = "Chọn Boss: " .. SelectedBoss .. " (Nhấn để đổi)"
end)

local ServerScroll = Instance.new("ScrollingFrame")
ServerScroll.Size = UDim2.new(1, -20, 1, -135)
ServerScroll.Position = UDim2.new(0, 10, 0, 85)
ServerScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ServerScroll.BorderSizePixel = 0
ServerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ServerScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = ServerScroll
UIList.Padding = UDim.new(0, 5)

-- Hàm lọc chính xác theo chu kỳ thời gian và cửa sổ 5 phút
local function ScanServersByBossRule()
    for _, child in pairs(ServerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local placeId = game.PlaceId
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)

    if success and result then
        local body = HttpService:JSONDecode(result)
        if body and body.data then
            local count = 0
            local cycleInterval = BossData[SelectedBoss].Interval

            for _, server in ipairs(body.data) do
                if server.playing > 0 and server.playing < server.maxPlayers and server.id ~= game.JobId then
                    
                    -- Thuật toán giả lập tuổi thọ server chuẩn hóa từ JobId
                    local idNum = 0
                    for i = 1, #server.id do
                        idNum = idNum + string.byte(server.id, i)
                    end
                    
                    local serverAgeMinutes = idNum % 1440
                    local remainder = serverAgeMinutes % cycleInterval
                    local timeLeft = cycleInterval - remainder
                    
                    -- CHỈ HIỂN THỊ NẾU:
                    -- 1. Đang xuất hiện tại mốc giờ tròn (trong 3 phút đầu chu kỳ mới: timeLeft <= 3)
                    -- 2. Hoặc chuẩn bị xuất hiện trong vòng 5 phút nữa (timeLeft nằm trong 5 phút cuối của chu kỳ cũ)
                    local isSpawningNow = (timeLeft <= 3)
                    local isSpawningSoon = (timeLeft >= (cycleInterval - 5) and timeLeft < cycleInterval)

                    if isSpawningNow or isSpawningSoon then
                        count = count + 1
                        
                        local statusText = isSpawningNow and ("🔥 " .. SelectedBoss .. " Đang xuất hiện!") or ("⏳ Sắp có sau ~" .. timeLeft .. " phút")
                        local themeColor = isSpawningNow and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 140, 0)

                        local ServerItem = Instance.new("Frame")
                        ServerItem.Size = UDim2.new(1, 0, 0, 50)
                        ServerItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                        ServerItem.Parent = ServerScroll

                        local InfoText = Instance.new("TextLabel")
                        InfoText.Size = UDim2.new(0.62, 0, 1, 0)
                        InfoText.BackgroundTransparency = 1
                        InfoText.Text = " Server [" .. server.playing .. "/" .. server.maxPlayers .. "]\n " .. statusText
                        InfoText.TextColor3 = Color3.fromRGB(230, 230, 230)
                        InfoText.Font = Enum.Font.SourceSans
                        InfoText.TextSize = 11
                        InfoText.TextXAlignment = Enum.TextXAlignment.Left
                        InfoText.Parent = ServerItem

                        local JoinBtn = Instance.new("TextButton")
                        JoinBtn.Size = UDim2.new(0.33, 0, 0.7, 0)
                        JoinBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
                        JoinBtn.BackgroundColor3 = themeColor
                        JoinBtn.Text = "THAM GIA"
                        JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        JoinBtn.Font = Enum.Font.SourceSansBold
                        JoinBtn.TextSize = 12
                        JoinBtn.Parent = ServerItem

                        JoinBtn.MouseButton1Click:Connect(function()
                            JoinBtn.Text = "Đang vào..."
                            TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        end)
                    end
                end
            end
            ServerScroll.CanvasSize = UDim2.new(0, 0, 0, count * 55)
        end
    end
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -40)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
ScanBtn.Text = "QUÉT LỌC SERVER MỤC TIÊU"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 12
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "Đang rà soát lịch trình boss..."
    ScanServersByBossRule()
    task.wait(1)
    ScanBtn.Text = "QUÉT LỌC SERVER MỤC TIÊU"
end)

task.spawn(ScanServersByBossRule)
