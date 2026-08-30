-- =================================================================
-- KING LEGACY - AUTO PLAY & AUTO EVENT CHEST (CẬP NHẬT CHUẨN KING LEGACY)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

getgenv().KL_AutoHopRunning = getgenv().KL_AutoHopRunning or false
getgenv().KL_AutoChestRunning = getgenv().KL_AutoChestRunning or false
getgenv().KL_HopDelay = getgenv().KL_HopDelay or 15

local VisitedServers = {}
local CollectedChests = {}

pcall(function()
    if queue_on_teleport then
        queue_on_teleport([[
            getgenv().KL_AutoHopRunning = ]] .. tostring(getgenv().KL_AutoHopRunning) .. [[
            getgenv().KL_AutoChestRunning = ]] .. tostring(getgenv().KL_AutoChestRunning) .. [[
            getgenv().KL_HopDelay = ]] .. tostring(getgenv().KL_HopDelay) .. [[
        ]])
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_MobileMasterGui"
ScreenGui.Parent = CoreGui

-- 1. AUTO PLAY CHUYÊN BẬT DÀNH RIÊNG CHO KING LEGACY
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            -- Khi nhân vật chưa vào trận
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetDescendants()) do
                        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                            local text = gui:IsA("TextButton") and gui.Text:lower() or ""
                            local name = gui.Name:lower()
                            
                            -- Quét các từ khóa màn hình chờ của King Legacy (Play, Start, Enter...)
                            if text:find("play") or text:find("start") or text:find("enter") or name:find("play") or name:find("start") or name:find("enter") then
                                
                                -- Kích hoạt trực tiếp Event của nút
                                if getconnections then
                                    for _, conn in pairs(getconnections(gui.MouseButton1Click)) do pcall(function() conn:Fire() end) end
                                    for _, conn in pairs(getconnections(gui.TouchTap)) do pcall(function() conn:Fire() end) end
                                    for _, conn in pairs(getconnections(gui.Activated)) do pcall(function() conn:Fire() end) end
                                end
                                
                                pcall(function() gui:Activate() end)
                                
                                -- Giả lập chạm màn hình tọa độ nút (dành cho Mobile Executor)
                                if gui.AbsolutePosition.X > 0 and gui.AbsolutePosition.Y > 0 then
                                    local cx = gui.AbsolutePosition.X + (gui.AbsoluteSize.X / 2)
                                    local cy = gui.AbsolutePosition.Y + (gui.AbsoluteSize.Y / 2)
                                    pcall(function()
                                        if VirtualInputManager and VirtualInputManager.SendTouchEvent then
                                            VirtualInputManager:SendTouchEvent(0, 0, 0, cx, cy, game)
                                            task.wait(0.05)
                                            VirtualInputManager:SendTouchEvent(0, 1, 0, cx, cy, game)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- GIAO DIỆN MENU
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
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
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
Title.Text = "AUTO RƯƠNG EVENT & AUTO PLAY (KING LEGACY)"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 10
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 25)
StatusLabel.Position = UDim2.new(0, 8, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Đang hoạt động..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

local TimeBoxContainer = Instance.new("Frame")
TimeBoxContainer.Size = UDim2.new(1, -16, 0, 30)
TimeBoxContainer.Position = UDim2.new(0, 8, 0, 68)
TimeBoxContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TimeBoxContainer.Parent = MainFrame

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0.6, 0, 1, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = " Thời gian ở mỗi SV (giây):"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextSize = 11
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = TimeBoxContainer

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0.35, 0, 0.8, 0)
TimeTextBox.Position = UDim2.new(0.62, 0, 0.1, 0)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
TimeTextBox.Text = tostring(getgenv().KL_HopDelay)
TimeTextBox.TextColor3 = Color3.fromRGB(0, 255, 180)
TimeTextBox.Font = Enum.Font.SourceSansBold
TimeTextBox.TextSize = 12
TimeTextBox.Parent = TimeBoxContainer

TimeTextBox.FocusLost:Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val and val >= 3 then
        getgenv().KL_HopDelay = val
    end
    TimeTextBox.Text = tostring(getgenv().KL_HopDelay)
end)

local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -16, 0, 32)
AutoHopBtn.Position = UDim2.new(0, 8, 0, 104)
AutoHopBtn.Parent = MainFrame
AutoHopBtn.Font = Enum.Font.SourceSansBold
AutoHopBtn.TextSize = 11

local AutoChestBtn = Instance.new("TextButton")
AutoChestBtn.Size = UDim2.new(1, -16, 0, 32)
AutoChestBtn.Position = UDim2.new(0, 8, 0, 141)
AutoChestBtn.Parent = MainFrame
AutoChestBtn.Font = Enum.Font.SourceSansBold
AutoChestBtn.TextSize = 11

if getgenv().KL_AutoHopRunning then
    AutoHopBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: BẬT"
else
    AutoHopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: TẮT"
end

if getgenv().KL_AutoChestRunning then
    AutoChestBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    AutoChestBtn.Text = "AUTO NHẶT RƯƠNG EVENT: BẬT"
else
    AutoChestBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    AutoChestBtn.Text = "AUTO NHẶT RƯƠNG EVENT: TẮT"
end

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -220)
Scroll.Position = UDim2.new(0, 8, 0, 180)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 4)

-- 2. AUTO NHẶT RƯƠNG EVENT (Bộ lọc chuẩn King Legacy)
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().KL_AutoChestRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not getgenv().KL_AutoChestRunning then break end
                
                local name = obj.Name:lower()
                
                if (name:find("chest") or name:find("reward")) and not CollectedChests[obj] then
                    local isIgnored = false
                    
                    if name:find("gacha") or name:find("fruit") or name:find("barrel") or name:find("crate") or name:find("box") then
                        isIgnored = true
                    end
                    
                    if not isIgnored then
                        local current = obj.Parent
                        while current and current ~= Workspace do
                            local cName = current.Name:lower()
                            
                            if cName:find("quest") or cName:find("daily") or cName:find("delivery") or cName:find("bandit") or cName:find("pirate") or cName:find("marine") or cName:find("gacha") or cName:find("fruit") or cName:find("spawn") or cName:find("barrel") then
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
                        local part = nil
                        if obj:IsA("Model") then
                            part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        elseif obj:IsA("BasePart") then
                            part = obj
                        end
                        
                        if part then
                            CollectedChests[obj] = true
                            StatusLabel.Text = "Trạng thái: Đang lấy rương sự kiện..."
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                            
                            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
                            
                            pcall(function()
                                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then fireproximityprompt(prompt) end
                                if firetouchinterest then
                                    firetouchinterest(hrp, part, 0)
                                    task.wait(0.02)
                                    firetouchinterest(hrp, part, 1)
                                end
                            end)
                            
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end
end)

local function FetchAndHopNext()
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&limit=100"
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and result and result.data then
        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and not VisitedServers[svr.id] and svr.playing >= 11 and svr.playing <= 12 then
                VisitedServers[svr.id] = true
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
            
            if getgenv().KL_AutoHopRunning then
                local hopped = FetchAndHopNext()
                if not hopped then
                    task.wait(3)
                else
                    break
                end
            end
        end
    end
end)

AutoHopBtn.MouseButton1Click:Connect(function()
    getgenv().KL_AutoHopRunning = not getgenv().KL_AutoHopRunning
    if getgenv().KL_AutoHopRunning then
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: BẬT"
    else
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: TẮT"
    end
end)

AutoChestBtn.MouseButton1Click:Connect(function()
    getgenv().KL_AutoChestRunning = not getgenv().KL_AutoChestRunning
    if getgenv().KL_AutoChestRunning then
        AutoChestBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        AutoChestBtn.Text = "AUTO NHẶT RƯƠNG EVENT: BẬT"
        StatusLabel.Text = "Trạng thái: Đang quét rương event..."
    else
        AutoChestBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        AutoChestBtn.Text = "AUTO NHẶT RƯƠNG EVENT: TẮT"
        StatusLabel.Text = "Trạng thái: Đã tắt."
    end
end)

local function ScanAndDisplay()
    for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

    local Loading = Instance.new("TextLabel")
    Loading.Size = UDim2.new(1, 0, 1, 0)
    Loading.BackgroundTransparency = 1
    Loading.Text = "🔍 Đang tìm server 11-12 người..."
    Loading.TextColor3 = Color3.fromRGB(255, 255, 100)
    Loading.Font = Enum.Font.SourceSansBold
    Loading.TextSize = 11
    Loading.Parent = Scroll

    task.spawn(function()
        local success, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=2&limit=100"
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        Loading:Destroy()

        if not success or not result or not result.data then
            local Err = Instance.new("TextLabel")
            Err.Size = UDim2.new(1, 0, 1, 0)
            Err.BackgroundTransparency = 1
            Err.Text = "⚠️ Lỗi tải dữ liệu server!"
            Err.TextColor3 = Color3.fromRGB(255, 100, 100)
            Err.Font = Enum.Font.SourceSansBold
            Err.TextSize = 11
            Err.Parent = Scroll
            return
        end

        local count = 0

        for _, svr in pairs(result.data) do
            if svr.id ~= game.JobId and not VisitedServers[svr.id] and svr.playing >= 11 and svr.playing <= 12 then
                count = count + 1
                local targetJobId = svr.id

                local ServerItem = Instance.new("Frame")
                ServerItem.Size = UDim2.new(1, 0, 0, 42)
                ServerItem.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                ServerItem.Parent = Scroll

                local InfoText = Instance.new("TextLabel")
                InfoText.Size = UDim2.new(0.6, 0, 1, 0)
                InfoText.BackgroundTransparency = 1
                InfoText.Text = " Người chơi: " .. svr.playing .. "/" .. svr.maxPlayers .. "\n 🎁 Server tiềm năng"
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
                    HopBtn.Text = "Đang vào..."
                    VisitedServers[targetJobId] = true
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
ScanBtn.Text = "QUÉT LẠI DANH SÁCH"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 11
ScanBtn.Parent = MainFrame

ScanBtn.MouseButton1Click:Connect(ScanAndDisplay)
