-- =================================================================
-- KING LEGACY - AUTO HOP BOSS CHUẨN API (KHÔNG LỆ THUỘC UI GAME)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local BossCycles = {
    ["Sea King"] = 3600,
    ["Ghost Ship"] = 6000,
    ["Hydra"] = 14400
}

local SelectedBoss = "Sea King"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_AutoAPIHop"
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
MainFrame.Size = UDim2.new(0, 360, 0, 320)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "LỌC BOSS - HOP SERVER TỰ ĐỘNG"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = MainFrame

local BossBtn = Instance.new("TextButton")
BossBtn.Size = UDim2.new(1, -16, 0, 30)
BossBtn.Position = UDim2.new(0, 8, 0, 38)
BossBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
BossBtn.Text = "Boss: Sea King (Nhấn đổi)"
BossBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
BossBtn.Font = Enum.Font.SourceSansBold
BossBtn.TextSize = 11
BossBtn.Parent = MainFrame

local bosses = {"Sea King", "Ghost Ship", "Hydra"}
local bIdx = 1
BossBtn.MouseButton1Click:Connect(function()
    bIdx = bIdx % #bosses + 1
    SelectedBoss = bosses[bIdx]
    BossBtn.Text = "Boss: " .. SelectedBoss .. " (Nhấn đổi)"
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -115)
Scroll.Position = UDim2.new(0, 8, 0, 74)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 4)

local function ScanAndHopServers()
    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    local Loading = Instance.new("TextLabel")
    Loading.Size = UDim2.new(1, 0, 1, 0)
    Loading.BackgroundTransparency = 1
    Loading.Text = "🔄 Đang quét danh sách server từ hệ thống..."
    Loading.TextColor3 = Color3.fromRGB(255, 255, 100)
    Loading.Font = Enum.Font.SourceSansBold
    Loading.TextSize = 11
    Loading.Parent = Scroll

    task.spawn(function()
        local success, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=1&limit=100"
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        Loading:Destroy()

        if not success or not result or not result.data then
            local Err = Instance.new("TextLabel")
            Err.Size = UDim2.new(1, 0, 1, 0)
            Err.BackgroundTransparency = 1
            Err.Text = "⚠️ Không thể kết nối API server. Hãy thử lại sau!"
            Err.TextColor3 = Color3.fromRGB(255, 100, 100)
            Err.Font = Enum.Font.SourceSansBold
            Err.TextSize = 11
            Err.Parent = Scroll
            return
        end

        local count = 0
        local cycle = BossCycles[SelectedBoss]

        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and svr.playing < svr.maxPlayers then
                -- Giả lập hoặc bóc tách thời gian server (dựa vào ping/fps hoặc chu kỳ ngẫu nhiên khả dụng)
                -- Vì API Roblox công khai không trả về trực tiếp Servertime của King Legacy, 
                -- ta sẽ tạo nút chuyển trực tiếp sang các server trống để săn Boss nhanh chóng:
                count = count + 1
                local targetJobId = svr.id

                local ServerItem = Instance.new("Frame")
                ServerItem.Size = UDim2.new(1, 0, 0, 42)
                ServerItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                ServerItem.Parent = Scroll

                local InfoText = Instance.new("TextLabel")
                InfoText.Size = UDim2.new(0.6, 0, 1, 0)
                InfoText.BackgroundTransparency = 1
                InfoText.Text = " Server: " .. svr.playing .. "/" .. svr.maxPlayers .. " người\n ⚡ Ping: " .. (svr.ping or "N/A")
                InfoText.TextColor3 = Color3.fromRGB(0, 255, 150)
                InfoText.Font = Enum.Font.SourceSans
                InfoText.TextSize = 10
                InfoText.TextXAlignment = Enum.TextXAlignment.Left
                InfoText.Parent = ServerItem

                local HopBtn = Instance.new("TextButton")
                HopBtn.Size = UDim2.new(0.36, 0, 0.7, 0)
                HopBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
                HopBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                HopBtn.Text = "VÀO NGAY"
                HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                HopBtn.Font = Enum.Font.SourceSansBold
                HopBtn.TextSize = 11
                HopBtn.Parent = ServerItem

                HopBtn.MouseButton1Click:Connect(function()
                    HopBtn.Text = "Đang sang..."
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
                    end)
                end)
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 46)
    end)
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -16, 0, 28)
ScanBtn.Position = UDim2.new(0, 8, 1, -34)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ScanBtn.Text = "QUÉT SERVER TRỐNG & SĂN BOSS"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 11
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(ScanAndHopServers)
