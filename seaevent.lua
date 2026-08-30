-- =================================================================
-- KING LEGACY - AUTO REFRESH & BROWSER SCANNER HUB
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BossSeconds = {
    ["Sea King"] = 3600,       -- 1 giờ
    ["Ghost Ship"] = 6000,     -- 1 giờ 40 phút
    ["Hydra"] = 14400          -- 4 giờ
}

local SelectedBoss = "Sea King"

-- Giao diện Hub
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_AutoRefreshBrowser"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 460)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "AUTO REFRESH & BOSS SCANNER"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 12
Title.Parent = MainFrame

-- Nút đổi Boss
local BossBtn = Instance.new("TextButton")
BossBtn.Size = UDim2.new(1, -20, 0, 35)
BossBtn.Position = UDim2.new(0, 10, 0, 45)
BossBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
BossBtn.Text = "Đang chọn Boss: Sea King (Nhấn để đổi)"
BossBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
BossBtn.Font = Enum.Font.SourceSansBold
BossBtn.TextSize = 13
BossBtn.Parent = MainFrame

local bosses = {"Sea King", "Ghost Ship", "Hydra"}
local bIdx = 1
BossBtn.MouseButton1Click:Connect(function()
    bIdx = bIdx % #bosses + 1
    SelectedBoss = bosses[bIdx]
    BossBtn.Text = "Đang chọn Boss: " .. SelectedBoss .. " (Nhấn để đổi)"
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -135)
Scroll.Position = UDim2.new(0, 10, 0, 85)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)

-- Hàm tìm nút Refresh của game và tự động bấm
local function AutoRefreshGameBrowser(browserUI)
    for _, btn in pairs(browserUI:GetDescendants()) do
        if btn:IsA("TextButton") and btn.Text == "Refresh" then
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                conn:Fire()
            end
            break
        end
    end
end

-- Hàm quét chính
local function ScanInGameBrowser()
    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    local browserUI = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text == "Server Browser" then
            browserUI = gui.Parent
            break
        end
    end

    if not browserUI then
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

    -- Tự động bấm nút Refresh của game trước khi đọc dữ liệu
    AutoRefreshGameBrowser(browserUI)
    task.wait(1) -- Chờ game load dữ liệu về giao diện

    local count = 0
    local cycle = BossSeconds[SelectedBoss]

    for _, item in pairs(browserUI:GetDescendants()) do
        if item:IsA("TextLabel") and (item.Text:find(":") or item.Text:find("Servertime")) then
            local timeText = item.Text
            local parts = {}
            for p in string.gmatch(timeText, "%d+") do
                table.insert(parts, tonumber(p))
            end

            if #parts >= 3 then
                local totalSeconds = 0
                if #parts == 4 then
                    totalSeconds = (parts[1] * 86400) + (parts[2] * 3600) + (parts[3] * 60) + parts[4]
                elseif #parts == 3 then
                    totalSeconds = (parts[1] * 3600) + (parts[2] * 60) + parts[3]
                end

                local remainder = totalSeconds % cycle
                local timeLeft = cycle - remainder

                -- Lọc cửa sổ 5 phút cuối hoặc đang ra trong 2 phút đầu
                if timeLeft <= 120 or timeLeft <= 300 then
                    count = count + 1
                    
                    local statusStr = (timeLeft <= 120) and ("🔥 " .. SelectedBoss .. " Đang có!") or ("⏳ " .. SelectedBoss .. " sắp ra (~" .. math.ceil(timeLeft/60) .. "p)")
                    local badgeColor = (timeLeft <= 120) and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 120, 0)

                    local ServerItem = Instance.new("Frame")
                    ServerItem.Size = UDim2.new(1, 0, 0, 48)
                    ServerItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                    ServerItem.Parent = Scroll

                    local InfoText = Instance.new("TextLabel")
                    InfoText.Size = UDim2.new(0.62, 0, 1, 0)
                    InfoText.BackgroundTransparency = 1
                    InfoText.Text = " Time: " .. timeText .. "\n " .. statusStr
                    InfoText.TextColor3 = Color3.fromRGB(230, 230, 230)
                    InfoText.Font = Enum.Font.SourceSans
                    InfoText.TextSize = 11
                    InfoText.TextXAlignment = Enum.TextXAlignment.Left
                    InfoText.Parent = ServerItem

                    local JoinBtn = Instance.new("TextButton")
                    JoinBtn.Size = UDim2.new(0.33, 0, 0.7, 0)
                    JoinBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
                    JoinBtn.BackgroundColor3 = badgeColor
                    JoinBtn.Text = "THAM GIA"
                    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    JoinBtn.Font = Enum.Font.SourceSansBold
                    JoinBtn.TextSize = 12
                    JoinBtn.Parent = ServerItem

                    -- Tìm nút Join gốc của game trên dòng tương ứng để bấm
                    local originalJoinBtn = nil
                    local parentFrame = item.Parent
                    if parentFrame then
                        for _, child in pairs(parentFrame:GetChildren()) do
                            if child:IsA("TextButton") and child.Text == "Join" then
                                originalJoinBtn = child
                                break
                            end
                        end
                    end

                    JoinBtn.MouseButton1Click:Connect(function()
                        JoinBtn.Text = "Đang vào..."
                        if originalJoinBtn then
                            for _, connection in pairs(getconnections(originalJoinBtn.MouseButton1Click)) do
                                connection:Fire()
                            end
                        end
                    end)
                end
            end
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 53)
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -20, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -40)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ScanBtn.Text = "TỰ ĐỘNG REFRESH & QUÉT SERVER"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 12
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(ScanInGameBrowser)
