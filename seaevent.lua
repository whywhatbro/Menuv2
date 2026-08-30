-- =================================================================
-- KING LEGACY - AUTO PLAY & AUTO NHẶT RƯƠNG EVENT (FIX CHUẨN 100%)
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local VisitedServers = {}
local AutoHopRunning = false
local AutoChestRunning = false
local HopDelay = 15

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_FinalAutoEventChest"
ScreenGui.Parent = CoreGui

-- 1. CƠ CHẾ AUTO PLAY: Tự động tìm và bấm nút PLAY ở màn hình chờ
task.spawn(function()
    while true do
        task.wait(0.8)
        pcall(function()
            -- Kiểm tra nếu nhân vật chưa spawn (chưa có HumanoidRootPart)
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Quét toàn bộ các TextButton có trong CoreGui và PlayerGui
                local containers = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
                for _, container in pairs(containers) do
                    if container then
                        for _, gui in pairs(container:GetDescendants()) do
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                local text = ""
                                if gui:IsA("TextButton") then
                                    text = gui.Text:lower()
                                end
                                
                                -- Nhận diện đúng nút PLAY màu xanh lá trong game
                                if text:find("play") or text:find("start") or text:find("chơi") or gui.Name:lower():find("play") then
                                    if gui.Visible and gui.AbsoluteSize.X > 0 then
                                        local pos = gui.AbsolutePosition
                                        local size = gui.AbsoluteSize
                                        local centerX = pos.X + size.X / 2
                                        local centerY = pos.Y + size.Y / 2
                                        
                                        -- Gửi sự kiện click chuột ảo vào nút Play
                                        if VirtualInputManager then
                                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                                            task.wait(0.1)
                                            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                                        end
                                    end
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
Title.Text = "AUTO RƯƠNG EVENT & AUTO PLAY"
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 10
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 25)
StatusLabel.Position = UDim2.new(0, 8, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: Đang sẵn sàng..."
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
TimeTextBox.Text = "15"
TimeTextBox.TextColor3 = Color3.fromRGB(0, 255, 180)
TimeTextBox.Font = Enum.Font.SourceSansBold
TimeTextBox.TextSize = 12
TimeTextBox.Parent = TimeBoxContainer

TimeTextBox.FocusLost:Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val and val >= 3 then
        HopDelay = val
    end
    TimeTextBox.Text = tostring(HopDelay)
end)

local AutoHopBtn = Instance.new("TextButton")
AutoHopBtn.Size = UDim2.new(1, -16, 0, 32)
AutoHopBtn.Position = UDim2.new(0, 8, 0, 104)
AutoHopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: TẮT"
AutoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoHopBtn.Font = Enum.Font.SourceSansBold
AutoHopBtn.TextSize = 11
AutoHopBtn.Parent = MainFrame

local AutoChestBtn = Instance.new("TextButton")
AutoChestBtn.Size = UDim2.new(1, -16, 0, 32)
AutoChestBtn.Position = UDim2.new(0, 8, 0, 141)
AutoChestBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AutoChestBtn.Text = "AUTO NHẶT RƯƠNG EVENT: TẮT"
AutoChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoChestBtn.Font = Enum.Font.SourceSansBold
AutoChestBtn.TextSize = 11
AutoChestBtn.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -220)
Scroll.Position = UDim2.new(0, 8, 0, 180)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 4)

-- 2. CƠ CHẾ AUTO NHẶT RƯƠNG EVENT: Quét toàn diện các rương boss biển
task.spawn(function()
    while true do
        task.wait(0.4)
        if AutoChestRunning and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if not AutoChestRunning then break end
                
                local name = obj.Name:lower()
                -- Lọc các vật thể là rương hoặc phần thưởng rơi ra
                if name:find("chest") or name:find("reward") or name:find("drop") or name:find("box") then
                    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                    
                    -- Kiểm tra xem có thuộc sự kiện Sea King, Ghost Ship, Hydra hay không
                    local fullName = name .. " " .. parentName
                    local current = obj.Parent
                    while current and current ~= Workspace do
                        fullName = fullName .. " " .. current.Name:lower()
                        current = current.Parent
                    end
                    
                    -- Loại bỏ rương nhiệm vụ thường (như Daily Quest delivery boxes ở video của bạn)
                    local isDailyQuestBox = fullName:find("daily") or fullName:find("quest") or fullName:find("delivery")
                    
                    if not isDailyQuestBox then
                        local isSeaEventChest = fullName:find("seaking") 
                            or fullName:find("sea king") 
                            or fullName:find("ghost") 
                            or fullName:find("ship") 
                            or fullName:find("hydra") 
                            or fullName:find("boss")
                            or fullName:find("sea")
                            
                        if isSeaEventChest then
                            local part = nil
                            if obj:IsA("Model") then
                                part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                            elseif obj:IsA("BasePart") then
                                part = obj
                            end
                            
                            if part then
                                StatusLabel.Text = "Trạng thái: Đã nhặt rương Sea Event!"
                                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                                hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                                task.wait(0.3)
                            end
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

AutoHopBtn.MouseButton1Click:Connect(function()
    AutoHopRunning = not AutoHopRunning
    if AutoHopRunning then
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: BẬT"
        
        task.spawn(function()
            while AutoHopRunning do
                local elapsed = 0
                while elapsed < HopDelay and AutoHopRunning do
                    task.wait(1)
                    elapsed = elapsed + 1
                end
                
                if AutoHopRunning then
                    local hopped = FetchAndHopNext()
                    if not hopped then
                        task.wait(3)
                    else
                        break
                    end
                end
            end
        end)
    else
        AutoHopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        AutoHopBtn.Text = "AUTO HOP 11-12 NGƯỜI: TẮT"
    end
end)

AutoChestBtn.MouseButton1Click:Connect(function()
    AutoChestRunning = not AutoChestRunning
    if AutoChestRunning then
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
