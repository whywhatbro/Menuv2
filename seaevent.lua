-- =================================================================
-- KING LEGACY - AUTO TOGGLE BROWSER JOIN FIX (ĐÃ SỬA LỖI JOIN)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local BossCycles = {
    ["Sea King"] = 3600,
    ["Ghost Ship"] = 6000,
    ["Hydra"] = 14400
}

local SelectedBoss = "Sea King"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_AutoToggleJoin"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or PlayerGui

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
Title.Text = "LỌC BOSS - THAM GIA TRỰC TIẾP"
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

local function ScanAndFix()
    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    local browserUI = nil
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and (gui.Text == "Server Browser" or gui.Text:find("Servertime")) then
            browserUI = gui.Parent.Parent
            break
        end
    end

    if not browserUI then
        local Err = Instance.new("TextLabel")
        Err.Size = UDim2.new(1, 0, 1, 0)
        Err.BackgroundTransparency = 1
        Err.Text = "⚠️ HÃY MỞ BẢNG 'Servers' TRONG GAME 1 LẦN ĐẦU ĐỂ TẢI DỮ LIỆU!"
        Err.TextColor3 = Color3.fromRGB(255, 100, 100)
        Err.Font = Enum.Font.SourceSansBold
        Err.TextSize = 11
        Err.TextWrapped = true
        Err.Parent = Scroll
        return
    end

    local count = 0
    local cycle = BossCycles[SelectedBoss]

    for _, item in pairs(browserUI:GetDescendants()) do
        if item:IsA("TextLabel") and item.Text:find("Servertime:") then
            local timeText = item.Text
            local parts = {}
            for p in string.gmatch(timeText, "%d+") do
                table.insert(parts, tonumber(p))
            end

            if #parts >= 3 then
                local totalSec = 0
                if #parts == 4 then
                    totalSec = (parts[1] * 86400) + (parts[2] * 3600) + (parts[3] * 60) + parts[4]
                elseif #parts == 3 then
                    totalSec = (parts[1] * 3600) + (parts[2] * 60) + parts[3]
                end

                local remainder = totalSec % cycle
                local timeLeft = cycle - remainder

                if timeLeft > 0 and timeLeft <= 300 then
                    count = count + 1
                    local parentFrame = item.Parent
                    
                    local ServerItem = Instance.new("Frame")
                    ServerItem.Size = UDim2.new(1, 0, 0, 42)
                    ServerItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                    ServerItem.Parent = Scroll

                    local InfoText = Instance.new("TextLabel")
                    InfoText.Size = UDim2.new(0.6, 0, 1, 0)
                    InfoText.BackgroundTransparency = 1
                    InfoText.Text = " " .. timeText .. "\n ⏳ Sắp ra (~" .. math.ceil(timeLeft/60) .. "p nữa)"
                    InfoText.TextColor3 = Color3.fromRGB(0, 255, 150)
                    InfoText.Font = Enum.Font.SourceSans
                    InfoText.TextSize = 10
                    InfoText.TextXAlignment = Enum.TextXAlignment.Left
                    InfoText.Parent = ServerItem

                    local JoinBtn = Instance.new("TextButton")
                    JoinBtn.Size = UDim2.new(0.36, 0, 0.7, 0)
                    JoinBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
                    JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                    JoinBtn.Text = "THAM GIA"
                    JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    JoinBtn.Font = Enum.Font.SourceSansBold
                    JoinBtn.TextSize = 11
                    JoinBtn.Parent = ServerItem

                    JoinBtn.MouseButton1Click:Connect(function()
                        JoinBtn.Text = "Đang vào..."
                        if parentFrame then
                            for _, child in pairs(parentFrame:GetChildren()) do
                                if child:IsA("TextButton") and (child.Text == "Join" or child.Text:lower() == "join") then
                                    -- Thử kích hoạt bằng firesignal hoặc getconnections nếu hỗ trợ
                                    local success = pcall(function()
                                        if firesignal then
                                            firesignal(child.MouseButton1Click)
                                        else
                                            for _, conn in pairs(getconnections(child.MouseButton1Click)) do
                                                conn:Fire()
                                            end
                                        end
                                    end)
                                    
                                    -- Nếu executor không hỗ trợ, dùng VirtualInputManager để click trực tiếp vào tọa độ nút Join
                                    if not success then
                                        task.spawn(function()
                                            local absPos = child.AbsolutePosition
                                            local absSize = child.AbsoluteSize
                                            VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, true, game, 1)
                                            task.wait(0.05)
                                            VirtualInputManager:SendMouseButtonEvent(absPos.X + absSize.X/2, absPos.Y + absSize.Y/2, 0, false, game, 1)
                                        end)
                                    end
                                    break
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, count * 46)
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -16, 0, 28)
ScanBtn.Position = UDim2.new(0, 8, 1, -34)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ScanBtn.Text = "QUÉT CHUẨN XÁC SERVER BOSS"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 11
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(ScanAndFix)
