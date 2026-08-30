-- =================================================================
-- KING LEGACY - IN-GAME SERVER BROWSER SCANNER (AUTO SERVERTIME)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cấu hình thời gian chu kỳ Boss (Tính bằng giây hoặc phân tích trực tiếp từ Servertime)
-- Sea King: 1 giờ (3600s), Ghost Ship: 1h40 (6000s), Hydra: 4 giờ (14400s)
local BossSeconds = {
    ["Sea King"] = 3600,
    ["Ghost Ship"] = 6000,
    ["Hydra"] = 14400
}

local SelectedBoss = "Sea King"

-- Giao diện Hub quét từ UI có sẵn của game
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_InGameBrowserScanner"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 400)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
Title.Text = "QUÉT SERVER BROWSER - 5 PHÚT SPAWN BOSS"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = MainFrame

-- Nút chọn Boss
local BossBtn = Instance.new("TextButton")
BossBtn.Size = UDim2.new(1, -20, 0, 30)
BossBtn.Position = UDim2.new(0, 10, 0, 45)
BossBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
BossBtn.Text = "Mục tiêu: Sea King (Nhấn đổi)"
BossBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
BossBtn.Font = Enum.Font.SourceSansBold
BossBtn.TextSize = 12
BossBtn.Parent = MainFrame

local bosses = {"Sea King", "Ghost Ship", "Hydra"}
local bIdx = 1
BossBtn.MouseButton1Click:Connect(function()
    bIdx = bIdx % #bosses + 1
    SelectedBoss = bosses[bIdx]
    BossBtn.Text = "Mục tiêu: " + SelectedBoss + " (Nhấn đổi)"
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -125)
Scroll.Position = UDim2.new(0, 10, 0, 85)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)

-- Hàm tìm kiếm và bóc tách dữ liệu từ bảng Server Browser có sẵn trong game
local function ScanInGameBrowser()
    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    -- Tìm đến Frame chứa Server Browser của game trên màn hình
    local browserUI = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text == "Server Browser" then
            browserUI = gui.Parent
            break
        end
    end

    if not browserUI then
        -- Thông báo nếu chưa mở bảng Server Browser trong game
        local Err = Instance.new("TextLabel")
        Err.Size = UDim2.new(1, 0, 1, 0)
        Err.BackgroundTransparency = 1
        Err.Text = "⚠️ HÃY MỞ BẢNG 'Servers' (Server Browser) TRONG GAME TRƯỚC!"
        Err.TextColor3 = Color3.fromRGB(255, 100, 100)
        Err.Font = Enum.Font.SourceSansBold
        Err.TextSize = 12
        Err.TextWrapped = true
        Err.Parent = Scroll
        return
    end

    -- Quét qua các dòng server đang hiển thị sẵn trong giao diện game
    local count = 0
    local cycle = BossSeconds[SelectedBoss]

    for _, item in pairs(browserUI:GetDescendants()) do
        if item:IsA("TextLabel") and (item.Text:find(":") or item.Text:find("Servertime")) then
            local timeText = item.Text
            -- Đọc chuỗi thời gian Servertime (Ví dụ: 01:06:11:48 hoặc dạng giờ:phút:giây)
            -- Logic bóc tách giây tổng thể từ chuỗi servertime của game
            local parts = {}
            for p in string.gmatch(timeText, "%d+") do
                table.insert(parts, tonumber(p))
            end

            if #parts >= 3 then
                -- Quy đổi ra tổng số giây server đã hoạt động
                local totalSeconds = 0
                if #parts == 4 then -- Ngày:Giờ:Phút:Giây
                    totalSeconds = (parts[1] * 86400) + (parts[2] * 3600) + (parts[3] * 60) + parts[4]
                elseif #parts == 3 then -- Giờ:Phút:Giây
                    totalSeconds = (parts[1] * 3600) + (parts[2] * 60) + parts[3]
                end

                local remainder = totalSeconds % cycle
                local timeLeft = cycle - remainder

                -- Lọc đúng cửa sổ 5 phút cuối (300 giây) trước khi spawn hoặc mới xuất hiện (trong 120 giây đầu)
                if timeLeft <= 120 or timeLeft <= 300 then
                    count = count + 1
                    local f = Instance.new("Frame")
                    f.Size = UDim2.new(1, 0, 0, 40)
                    f.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
                    f.Parent = Scroll

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(0.7, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = " Thời gian: " .. timeText .. "\n Trạng thái: Sắp/Đang có Boss!"
                    lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
                    lbl.Font = Enum.Font.SourceSans
                    lbl.TextSize = 11
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                    lbl.Parent = f
                end
            end
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 45)
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -35)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
ScanBtn.Text = "QUÉT DỮ LIỆU TỪ BẢNG GAME"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 12
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(ScanInGameBrowser)
