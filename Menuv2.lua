-- Roblox Mobile Hub - Web Image Edition (No Roblox AssetId Required)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

---------------------------------------------------------
-- 🎨 CẤU HÌNH HÌNH NỀN TỪ WEB (SỬA TẠI ĐÂY)
---------------------------------------------------------
local UIConfig = {
    -- 1. NỀN MENU CHÍNH
    Main_UseImage = true,
    -- Dán trực tiếp Link Ảnh trên Web vào đây (JPG, PNG, WEBP):
    Main_ImageUrl = "https://i.imgur.com/8Q8o5wL.png", 
    Main_ImageTransparency = 0.2, -- Độ mờ của ảnh (0 là rõ nét hoàn toàn, 0.5 là mờ nhẹ)

    -- 2. NỀN NÚT BẬT/TẮT HUB (TOGGLE BUTTON)
    Toggle_UseImage = true,
    -- Có thể dán Link Ảnh khác hoặc dùng chung link với Menu:
    Toggle_ImageUrl = "https://i.imgur.com/8Q8o5wL.png", 
    Toggle_ImageTransparency = 0.1,

    -- 3. CẤU HÌNH MÀU GRADIENT (Dùng khi Main_UseImage = false)
    Gradient_Color1 = Color3.fromRGB(15, 25, 45),
    Gradient_Color2 = Color3.fromRGB(40, 10, 60),
}

---------------------------------------------------------
-- 🌐 HAM TẢI VÀ LƯU ẢNH TỪ WEB SANG ROBLOX ASSET
---------------------------------------------------------
local function GetWebAsset(url, fileName)
    if not url or url == "" then return "" end
    
    -- Kiểm tra executor có hỗ trợ tạo custom asset không
    local getAsset = getcustomasset or getgenv().getcustomasset or getCustomAsset
    if not getAsset or not writefile or not isfile then
        return url -- Nếu không hỗ trợ thì trả về mặc định
    end

    local success, result = pcall(function()
        local filePath = "MobileHub_Assets/" .. fileName
        if not isfolder("MobileHub_Assets") then
            makefolder("MobileHub_Assets")
        end

        -- Nếu chưa tải ảnh thì tải về lưu vào máy
        if not isfile(filePath) then
            local req = (syn and syn.request) or (http and http.request) or http_request or request or fluxus and fluxus.request
            if req then
                local res = req({Url = url, Method = "GET"})
                if res and res.Body then
                    writefile(filePath, res.Body)
                end
            else
                writefile(filePath, game:HttpGet(url))
            end
        end

        return getAsset(filePath)
    end)

    if success and result then
        return result
    end
    return ""
end

-- Tải sẵn Asset ID từ Link Web
local MainImageAsset = UIConfig.Main_UseImage and GetWebAsset(UIConfig.Main_ImageUrl, "main_bg.png") or ""
local ToggleImageAsset = UIConfig.Toggle_UseImage and GetWebAsset(UIConfig.Toggle_ImageUrl, "toggle_bg.png") or ""

-- Cấu hình chức năng hệ thống
local Settings = {
    AimbotMode = "None",
    FOVRadius = 120,
    AimWallCheck = true,
    AimTargetName = "",
    
    WalkSpeedActive = false, WalkSpeedVal = 16,
    JumpPowerActive = false, JumpPowerVal = 50,
    InfJumpActive = false, GravityActive = false, GravityVal = 196.2,
    
    FullBrightActive = false, UnlockCamActive = false, CamNoclipActive = false, XRayActive = false, RemoveFogActive = false,
    ESP_Name = false, ESP_Highlight = false, ESP_Full = false,
    
    TargetPlayerName = "",
    AC_LoopInfinite = true, AC_LoopCount = 5, AC_CircleSize = 40, AC_Delay = 0.1, AC_Running = false,
    WP_Mode = "Fly", WP_FlySpeed = 50, WP_Running = false
}

local OriginalLighting = {
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, GlobalShadows = Lighting.GlobalShadows
}

local ServerStartTime = os.time()

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- Vòng tròn FOV Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 200)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

---------------------------------------------------------
-- TẠO VÀ XỬ LÝ KHUNG GIAO DIỆN CHÍNH
---------------------------------------------------------
local function GetSafeParent()
    local success, parent = pcall(function()
        if gethui then return gethui()
        elseif game:GetService("CoreGui") then return game:GetService("CoreGui") end
    end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local TargetParent = GetSafeParent()
if TargetParent:FindFirstChild("UltimateMobileHub") then
    TargetParent.UltimateMobileHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMobileHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetParent

---------------------------------------------------------
-- 🔘 NÚT BẬT/TẮT MENU NỔI
---------------------------------------------------------
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ToggleMenuBtn.Text = "HUB"
ToggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Font = Enum.Font.FredokaOne
ToggleMenuBtn.Active = true
ToggleMenuBtn.Draggable = true
ToggleMenuBtn.ClipsDescendants = true

local ToggleCorner = Instance.new("UICorner", ToggleMenuBtn) ToggleCorner.CornerRadius = UDim.new(0, 30)
local ToggleStroke = Instance.new("UIStroke", ToggleMenuBtn) ToggleStroke.Color = Color3.fromRGB(0, 255, 200) ToggleStroke.Thickness = 2

-- Xử lý Nền Web cho Nút HUB
if UIConfig.Toggle_UseImage and ToggleImageAsset ~= "" then
    local ToggleBgImage = Instance.new("ImageLabel", ToggleMenuBtn)
    ToggleBgImage.Size = UDim2.new(1, 0, 1, 0)
    ToggleBgImage.Image = ToggleImageAsset
    ToggleBgImage.ImageTransparency = UIConfig.Toggle_ImageTransparency
    ToggleBgImage.BackgroundTransparency = 1
    ToggleBgImage.ScaleType = Enum.ScaleType.Crop
    ToggleBgImage.ZIndex = 0
    ToggleMenuBtn.TextZIndex = 1
else
    local ToggleGradient = Instance.new("UIGradient", ToggleMenuBtn)
    ToggleGradient.Color = ColorSequence.new(UIConfig.Gradient_Color1, UIConfig.Gradient_Color2)
    ToggleGradient.Rotation = 45
end

---------------------------------------------------------
-- 📦 KHUNG MENU CHÍNH
---------------------------------------------------------
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 330)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame) MainCorner.CornerRadius = UDim.new(0, 10)
local MainFrameStroke = Instance.new("UIStroke", MainFrame) MainFrameStroke.Color = Color3.fromRGB(0, 170, 255) MainFrameStroke.Thickness = 2

-- Xử lý Nền Web cho Menu Chính
if UIConfig.Main_UseImage and MainImageAsset ~= "" then
    local MainBgImage = Instance.new("ImageLabel", MainFrame)
    MainBgImage.Name = "BackgroundImage"
    MainBgImage.Size = UDim2.new(1, 0, 1, 0)
    MainBgImage.Image = MainImageAsset
    MainBgImage.ImageTransparency = UIConfig.Main_ImageTransparency
    MainBgImage.BackgroundTransparency = 1
    MainBgImage.ScaleType = Enum.ScaleType.Crop
    MainBgImage.ZIndex = 0
else
    local MainGradient = Instance.new("UIGradient", MainFrame)
    MainGradient.Color = ColorSequence.new(UIConfig.Gradient_Color1, UIConfig.Gradient_Color2)
    MainGradient.Rotation = 45
end

-- Hiệu ứng Đóng/Mở Menu
local menuOpen = true
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 330), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
    else
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function()
            MainFrame.Visible = false
        end)
    end
end)

-- Header Bar
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
Header.BackgroundTransparency = 0.2
Header.ZIndex = 2

local HeaderCorner = Instance.new("UICorner", Header) HeaderCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "⚡ MOBILE ADVANCED HUB (WEB IMAGE ADAPTED)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    MainFrame:TweenSize(UDim2.new(0, 520, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.3, true, function()
        MainFrame.Visible = false
    end)
end)

-- Navigation Bar
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.Size = UDim2.new(1, -10, 0, 32)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 2

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 5, 0, 76)
ContentFrame.Size = UDim2.new(1, -10, 1, -82)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2

local Pages = {}

local function createTab(name, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1/7, -4, 1, 0)
    btn.Text = name
    btn.TextColor3 = (order == 1) and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(150, 160, 175)
    btn.BackgroundColor3 = (order == 1) and Color3.fromRGB(25, 32, 45) or Color3.fromRGB(20, 24, 32)
    btn.BackgroundTransparency = 0.2
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 9

    local btnCorner = Instance.new("UICorner", btn) btnCorner.CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (order == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentFrame:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then 
                b.TextColor3 = Color3.fromRGB(150, 160, 175) 
                b.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
            end
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 200)
        btn.BackgroundColor3 = Color3.fromRGB(25, 32, 45)
    end)
    return page
end

local ServerPage   = createTab("SERVER", 1)
local CombatPage   = createTab("COMBAT", 2)
local MovePage     = createTab("MOVE", 3)
local VisualPage   = createTab("ESP", 4)
local WorldPage    = createTab("WORLD", 5)
local ChatPage     = createTab("CHAT", 6)
local MiscPage     = createTab("TỔNG HỢP", 7)

---------------------------------------------------------
-- UI HELPER FUNCTIONS & CONFIRMATION MODAL
---------------------------------------------------------
local ConfirmModal = Instance.new("Frame", ScreenGui)
ConfirmModal.Size = UDim2.new(0, 320, 0, 160)
ConfirmModal.Position = UDim2.new(0.5, -160, 0.5, -80)
ConfirmModal.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ConfirmModal.Visible = false
ConfirmModal.ZIndex = 100

local CMCorner = Instance.new("UICorner", ConfirmModal) CMCorner.CornerRadius = UDim.new(0, 8)
local CMStroke = Instance.new("UIStroke", ConfirmModal) CMStroke.Color = Color3.fromRGB(0, 170, 255) CMStroke.Thickness = 2

local CMTitle = Instance.new("TextLabel", ConfirmModal)
CMTitle.Size = UDim2.new(1, 0, 0, 30)
CMTitle.Text = "XÁC NHẬN HÀNH ĐỘNG"
CMTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
CMTitle.Font = Enum.Font.GothamBold
CMTitle.TextSize = 12
CMTitle.ZIndex = 101

local CMBody = Instance.new("TextLabel", ConfirmModal)
CMBody.Size = UDim2.new(0.9, 0, 0, 60)
CMBody.Position = UDim2.new(0.05, 0, 0.25, 0)
CMBody.Text = "Bạn có chắc chắn thực hiện?"
CMBody.TextColor3 = Color3.fromRGB(255, 255, 255)
CMBody.TextWrapped = true
CMBody.Font = Enum.Font.Gotham
CMBody.TextSize = 11
CMBody.ZIndex = 101

local CMCancelBtn = Instance.new("TextButton", ConfirmModal)
CMCancelBtn.Size = UDim2.new(0.4, 0, 0, 32)
CMCancelBtn.Position = UDim2.new(0.08, 0, 0.7, 0)
CMCancelBtn.Text = "Hủy Bỏ"
CMCancelBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
CMCancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CMCancelBtn.Font = Enum.Font.GothamBold
CMCancelBtn.TextSize = 11
CMCancelBtn.ZIndex = 101
local CMCBCorner = Instance.new("UICorner", CMCancelBtn) CMCBCorner.CornerRadius = UDim.new(0, 6)

local CMConfirmBtn = Instance.new("TextButton", ConfirmModal)
CMConfirmBtn.Size = UDim2.new(0.4, 0, 0, 32)
CMConfirmBtn.Position = UDim2.new(0.52, 0, 0.7, 0)
CMConfirmBtn.Text = "Xác Nhận"
CMConfirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
CMConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CMConfirmBtn.Font = Enum.Font.GothamBold
CMConfirmBtn.TextSize = 11
CMConfirmBtn.ZIndex = 101
local CMCFCorner = Instance.new("UICorner", CMConfirmBtn) CMCFCorner.CornerRadius = UDim.new(0, 6)

local currentConfirmCallback = nil
local function ShowConfirmDialog(message, onConfirm)
    CMBody.Text = message
    currentConfirmCallback = onConfirm
    ConfirmModal.Visible = true
end

CMCancelBtn.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = false
    currentConfirmCallback = nil
end)

CMConfirmBtn.MouseButton1Click:Connect(function()
    ConfirmModal.Visible = false
    if currentConfirmCallback then
        currentConfirmCallback()
        currentConfirmCallback = nil
    end
end)

local function addToggleWithInput(page, name, defaultVal, onToggle, onValChange)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(0.99, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
    frame.BackgroundTransparency = 0.3

    local corner = Instance.new("UICorner", frame) corner.CornerRadius = UDim.new(0, 6)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.55, -5, 1, -8)
    btn.Position = UDim2.new(0, 4, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local btnCorner = Instance.new("UICorner", btn) btnCorner.CornerRadius = UDim.new(0, 4)

    local txt = Instance.new("TextBox", frame)
    txt.Position = UDim2.new(0.55, 4, 0, 4)
    txt.Size = UDim2.new(0.45, -8, 1, -8)
    txt.Text = tostring(defaultVal)
    txt.PlaceholderText = "Giá trị"
    txt.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
    txt.TextColor3 = Color3.fromRGB(0, 255, 200)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 11

    local txtCorner = Instance.new("UICorner", txt) txtCorner.CornerRadius = UDim.new(0, 4)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
        btn.Text = name .. (active and ": ON" or ": OFF")
        onToggle(active)
    end)

    txt.FocusLost:Connect(function()
        local val = tonumber(txt.Text)
        if val then onValChange(val) end
    end)
end

local function addSimpleToggle(page, name, onToggle, defaultState)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.99, 0, 0, 32)
    local active = defaultState or false
    btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
    btn.BackgroundTransparency = 0.2
    btn.Text = name .. (active and ": ON" or ": OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
        btn.Text = name .. (active and ": ON" or ": OFF")
        onToggle(active)
    end)
    return btn
end

local function addActionButton(page, name, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.99, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    btn.BackgroundTransparency = 0.2
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11

    local corner = Instance.new("UICorner", btn) corner.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn) stroke.Color = Color3.fromRGB(0, 170, 255) stroke.Thickness = 1

    btn.MouseButton1Click:Connect(callback)
    return btn
end

---------------------------------------------------------
-- 1. TAB SERVER
---------------------------------------------------------
local ServerAgeLabel = Instance.new("TextLabel", ServerPage)
ServerAgeLabel.Size = UDim2.new(0.99, 0, 0, 25)
ServerAgeLabel.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
ServerAgeLabel.BackgroundTransparency = 0.3
ServerAgeLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
ServerAgeLabel.Font = Enum.Font.Gotham
ServerAgeLabel.TextSize = 11

local ServerAgeCorner = Instance.new("UICorner", ServerAgeLabel) ServerAgeCorner.CornerRadius = UDim.new(0, 6)

task.spawn(function()
    while task.wait(1) do
        local diff = os.time() - ServerStartTime
        local d = math.floor(diff / 86400)
        local h = math.floor((diff % 86400) / 3600)
        local m = math.floor((diff % 3600) / 60)
        local s = diff % 60
        ServerAgeLabel.Text = string.format(" Tuổi Server: %d ngày, %d giờ, %d phút, %d giây", d, h, m, s)
    end
end)

local ServerHopFrame = Instance.new("Frame", ServerPage)
ServerHopFrame.Size = UDim2.new(0.99, 0, 0, 40)
ServerHopFrame.BackgroundTransparency = 1

local SHLayout = Instance.new("UIListLayout", ServerHopFrame)
SHLayout.FillDirection = Enum.FillDirection.Horizontal
SHLayout.Padding = UDim.new(0.02, 0)

local RejoinBtn = Instance.new("TextButton", ServerHopFrame)
RejoinBtn.Size = UDim2.new(0.32, 0, 1, 0)
RejoinBtn.Text = "Vào Lại Server"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
RejoinBtn.BackgroundTransparency = 0.2
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 9
local RJC = Instance.new("UICorner", RejoinBtn) RJC.CornerRadius = UDim.new(0, 6)
local RJS = Instance.new("UIStroke", RejoinBtn) RJS.Color = Color3.fromRGB(0, 170, 255)

RejoinBtn.MouseButton1Click:Connect(function()
    ShowConfirmDialog("Bạn có muốn tải lại (Rejoin) Server hiện tại không?", function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

local ServerHopBtn = Instance.new("TextButton", ServerHopFrame)
ServerHopBtn.Size = UDim2.new(0.32, 0, 1, 0)
ServerHopBtn.Text = "Vào Server Khác"
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
ServerHopBtn.BackgroundTransparency = 0.2
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.Font = Enum.Font.GothamBold
ServerHopBtn.TextSize = 9
local SHC = Instance.new("UICorner", ServerHopBtn) SHC.CornerRadius = UDim.new(0, 6)
local SHS = Instance.new("UIStroke", ServerHopBtn) SHS.Color = Color3.fromRGB(0, 170, 255)

local function SafeHttpRequest(url, method, headers, body)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    if requestFunc then
        return requestFunc({
            Url = url, Method = method or "GET", Headers = headers or {}, Body = body or nil
        })
    else
        local res = game:HttpGet(url)
        return {Body = res, StatusCode = 200}
    end
end

local function FetchServerListMulti()
    local endpoints = {
        "https://games.roproxy.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100",
        "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    }

    for _, url in ipairs(endpoints) do
        local success, res = pcall(function() return SafeHttpRequest(url) end)
        if success and res and res.Body then
            local jsonSuccess, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if jsonSuccess and data and data.data and #data.data > 0 then return data.data end
        end
    end
    return nil
end

local function HopRandomServer()
    task.spawn(function()
        local servers = FetchServerListMulti()
        if servers then
            local validServers = {}
            for _, s in ipairs(servers) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then table.insert(validServers, s.id) end
            end
            if #validServers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)], LocalPlayer)
                return
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

ServerHopBtn.MouseButton1Click:Connect(function()
    ShowConfirmDialog("Bạn có chắc muốn nhảy sang Server ngẫu nhiên khác?", function() HopRandomServer() end)
end)

local SmallServerBtn = Instance.new("TextButton", ServerHopFrame)
SmallServerBtn.Size = UDim2.new(0.32, 0, 1, 0)
SmallServerBtn.Text = "Vào Server Ít Người"
SmallServerBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
SmallServerBtn.BackgroundTransparency = 0.2
SmallServerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SmallServerBtn.Font = Enum.Font.GothamBold
SmallServerBtn.TextSize = 9
local SSC = Instance.new("UICorner", SmallServerBtn) SSC.CornerRadius = UDim.new(0, 6)
local SSS = Instance.new("UIStroke", SmallServerBtn) SSS.Color = Color3.fromRGB(0, 170, 255)

local function HopSmallestServer()
    task.spawn(function()
        local servers = FetchServerListMulti()
        if servers then
            local bestServer = nil
            local minPlayers = math.huge
            for _, s in ipairs(servers) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing < minPlayers then
                    minPlayers = s.playing
                    bestServer = s.id
                end
            end
            if bestServer then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer, LocalPlayer)
                return
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

SmallServerBtn.MouseButton1Click:Connect(function()
    ShowConfirmDialog("Chuyển sang Server có ít người nhất?", function() HopSmallestServer() end)
end)

------------------ KHUNG TÌM KIẾM NGƯỜI CHƠI ------------------
local TargetUserContainer = Instance.new("Frame", ServerPage)
TargetUserContainer.Size = UDim2.new(0.99, 0, 0, 360)
TargetUserContainer.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
TargetUserContainer.BackgroundTransparency = 0.3

local TUCorner = Instance.new("UICorner", TargetUserContainer) TUCorner.CornerRadius = UDim.new(0, 6)

local TUHeader = Instance.new("TextLabel", TargetUserContainer)
TUHeader.Size = UDim2.new(1, -10, 0, 20)
TUHeader.Position = UDim2.new(0, 5, 0, 2)
TUHeader.Text = "👤 TÌM KIẾM NGƯỜI CHƠI (VIẾT TẮT / TÊN THẬT / TÊN HIỂN THỊ)"
TUHeader.TextColor3 = Color3.fromRGB(0, 255, 200)
TUHeader.TextXAlignment = Enum.TextXAlignment.Left
TUHeader.Font = Enum.Font.GothamBold
TUHeader.TextSize = 9
TUHeader.BackgroundTransparency = 1

local UserInputFrame = Instance.new("Frame", TargetUserContainer)
UserInputFrame.Size = UDim2.new(0.96, 0, 0, 26)
UserInputFrame.Position = UDim2.new(0.02, 0, 0.06, 0)
UserInputFrame.BackgroundTransparency = 1

local TargetUserBox = Instance.new("TextBox", UserInputFrame)
TargetUserBox.Size = UDim2.new(0.75, 0, 1, 0)
TargetUserBox.PlaceholderText = "Nhập từ khóa hoặc chữ cái đầu..."
TargetUserBox.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
TargetUserBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetUserBox.Font = Enum.Font.Gotham
TargetUserBox.TextSize = 10
local TUBCorner = Instance.new("UICorner", TargetUserBox) TUBCorner.CornerRadius = UDim.new(0, 4)

local SearchUserBtn = Instance.new("TextButton", UserInputFrame)
SearchUserBtn.Position = UDim2.new(0.77, 0, 0, 0)
SearchUserBtn.Size = UDim2.new(0.23, 0, 1, 0)
SearchUserBtn.Text = "Tìm kiếm"
SearchUserBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SearchUserBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchUserBtn.Font = Enum.Font.GothamBold
SearchUserBtn.TextSize = 10
local SUBStyle = Instance.new("UICorner", SearchUserBtn) SUBStyle.CornerRadius = UDim.new(0, 4)

local UserStatusLabel = Instance.new("TextLabel", TargetUserContainer)
UserStatusLabel.Position = UDim2.new(0.02, 0, 0.14, 0)
UserStatusLabel.Size = UDim2.new(0.96, 0, 0, 14)
UserStatusLabel.Text = "Nhập từ khóa để tìm chính xác người chơi..."
UserStatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
UserStatusLabel.Font = Enum.Font.Gotham
UserStatusLabel.TextSize = 9
UserStatusLabel.BackgroundTransparency = 1

local SearchResultsFrame = Instance.new("ScrollingFrame", TargetUserContainer)
SearchResultsFrame.Position = UDim2.new(0.02, 0, 0.19, 0)
SearchResultsFrame.Size = UDim2.new(0.96, 0, 0, 275)
SearchResultsFrame.BackgroundTransparency = 1
SearchResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
SearchResultsFrame.ScrollBarThickness = 3

local SRLayout = Instance.new("UIListLayout", SearchResultsFrame)
SRLayout.Padding = UDim.new(0, 5)
SRLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SearchResultsFrame.CanvasSize = UDim2.new(0, 0, 0, SRLayout.AbsoluteContentSize.Y + 5)
end)

local function ExecuteUserSearch()
    local query = TargetUserBox.Text:match("^%s*(.-)%s*$")
    if query == "" then
        UserStatusLabel.Text = "⚠️ Vui lòng nhập từ khóa tìm kiếm!"
        return
    end

    for _, child in pairs(SearchResultsFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end

    UserStatusLabel.Text = "⏳ Đang lọc kết quả..."

    task.spawn(function()
        local foundUsers = {}
        local queryLower = query:lower()

        for _, p in pairs(Players:GetPlayers()) do
            local username = p.Name:lower()
            local displayName = p.DisplayName:lower()
            
            local matchFound = false
            if username:sub(1, #queryLower) == queryLower or displayName:sub(1, #queryLower) == queryLower then
                matchFound = true
            elseif username:find(queryLower, 1, true) or displayName:find(queryLower, 1, true) then
                matchFound = true
            end

            if matchFound then
                table.insert(foundUsers, {
                    userId = p.UserId, username = p.Name, displayName = p.DisplayName, isCurrentServer = true
                })
            end
        end

        if #foundUsers == 0 then
            UserStatusLabel.Text = "❌ Không tìm thấy người chơi phù hợp!"
            return
        end

        UserStatusLabel.Text = string.format("✅ Tìm thấy %d kết quả!", #foundUsers)

        for _, uData in ipairs(foundUsers) do
            local itemFrame = Instance.new("Frame", SearchResultsFrame)
            itemFrame.Size = UDim2.new(1, 0, 0, 60)
            itemFrame.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
            itemFrame.BackgroundTransparency = 0.2
            local IFC = Instance.new("UICorner", itemFrame) IFC.CornerRadius = UDim.new(0, 6)

            local searchAvatarImg = Instance.new("ImageLabel", itemFrame)
            searchAvatarImg.Size = UDim2.new(0, 45, 0, 45)
            searchAvatarImg.Position = UDim2.new(0, 6, 0.5, -22)
            searchAvatarImg.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
            local SAFCorner = Instance.new("UICorner", searchAvatarImg) SAFCorner.CornerRadius = UDim.new(1, 0)

            task.spawn(function()
                pcall(function()
                    searchAvatarImg.Image = Players:GetUserThumbnailAsync(uData.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                end)
            end)

            local statusText = "<font color=\"#00FF88\"><b>🟢 Đang ở Server Này</b></font>"

            local uInfoLabel = Instance.new("TextLabel", itemFrame)
            uInfoLabel.Position = UDim2.new(0, 58, 0, 4)
            uInfoLabel.Size = UDim2.new(0.60, 0, 1, -8)
            uInfoLabel.Text = string.format("<b>%s</b> (@%s)\n%s", uData.displayName, uData.username, statusText)
            uInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            uInfoLabel.RichText = true
            uInfoLabel.Font = Enum.Font.Gotham
            uInfoLabel.TextSize = 9
            uInfoLabel.TextXAlignment = Enum.TextXAlignment.Left

            local actionBtn = Instance.new("TextButton", itemFrame)
            actionBtn.Position = UDim2.new(0.72, 0, 0.2, 0)
            actionBtn.Size = UDim2.new(0.26, 0, 0.6, 0)
            actionBtn.Font = Enum.Font.GothamBold
            actionBtn.TextSize = 9
            actionBtn.Text = "Teleport"
            actionBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            local ABC = Instance.new("UICorner", actionBtn) ABC.CornerRadius = UDim.new(0, 4)

            actionBtn.MouseButton1Click:Connect(function()
                local targetP = Players:FindFirstChild(uData.username)
                if targetP and targetP.Character and targetP.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetP.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end)
end

SearchUserBtn.MouseButton1Click:Connect(ExecuteUserSearch)
TargetUserBox.FocusLost:Connect(function(enterPressed) if enterPressed then ExecuteUserSearch() end end)

---------------------------------------------------------
-- 2. TAB COMBAT
---------------------------------------------------------
addSimpleToggle(CombatPage, "Aim Người Gần Nhất", function(val) Settings.AimbotMode = val and "Closest" or "None" end)
addSimpleToggle(CombatPage, "Aim Ít Máu Nhất", function(val) Settings.AimbotMode = val and "LowestHealth" or "None" end)

local AimFOVToggle = addSimpleToggle(CombatPage, "Aim Vòng Tròn (FOV Trung Tâm)", function(val)
    Settings.AimbotMode = val and "FOV" or "None"
    FOVCircle.Visible = val
end)

local FOVInput = Instance.new("TextBox", CombatPage)
FOVInput.Size = UDim2.new(0.99, 0, 0, 32)
FOVInput.Text = tostring(Settings.FOVRadius)
FOVInput.PlaceholderText = "Nhập bán kính FOV"
FOVInput.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
FOVInput.TextColor3 = Color3.fromRGB(0, 255, 200)
FOVInput.Font = Enum.Font.Gotham
FOVInput.TextSize = 11
local FOVCorner = Instance.new("UICorner", FOVInput) FOVCorner.CornerRadius = UDim.new(0, 6)

FOVInput.FocusLost:Connect(function()
    local val = tonumber(FOVInput.Text)
    if val then Settings.FOVRadius = val FOVCircle.Radius = val end
end)

addSimpleToggle(CombatPage, "Aim Xuyên Tường (Wall Check)", function(val) Settings.AimWallCheck = val end, true)
addSimpleToggle(CombatPage, "Aim Theo Tên (Target Name)", function(val) Settings.AimbotMode = val and "TargetName" or "None" end)

local AimTargetInput = Instance.new("TextBox", CombatPage)
AimTargetInput.Size = UDim2.new(0.99, 0, 0, 32)
AimTargetInput.Text = Settings.AimTargetName
AimTargetInput.PlaceholderText = "Nhập Username/Display Name cần Aim..."
AimTargetInput.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
AimTargetInput.TextColor3 = Color3.fromRGB(0, 255, 200)
AimTargetInput.Font = Enum.Font.Gotham
AimTargetInput.TextSize = 11
local AimTargetCorner = Instance.new("UICorner", AimTargetInput) AimTargetCorner.CornerRadius = UDim.new(0, 6)

AimTargetInput.FocusLost:Connect(function() Settings.AimTargetName = AimTargetInput.Text:lower() end)

---------------------------------------------------------
-- 3. TAB MOVEMENT
---------------------------------------------------------
addToggleWithInput(MovePage, "Chạy Nhanh", Settings.WalkSpeedVal, function(state) Settings.WalkSpeedActive = state end, function(val) Settings.WalkSpeedVal = val end)
addToggleWithInput(MovePage, "Nhảy Cao", Settings.JumpPowerVal, function(state) Settings.JumpPowerActive = state end, function(val) Settings.JumpPowerVal = val end)
addToggleWithInput(MovePage, "Trọng Lực (Gravity)", Settings.GravityVal, function(state) Settings.GravityActive = state end, function(val) Settings.GravityVal = val end)
addSimpleToggle(MovePage, "Nhảy Vô Hạn", function(state) Settings.InfJumpActive = state end)

addActionButton(MovePage, "Bật Script Bay (FlyGui V3)", function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)
end)

addActionButton(MovePage, "🔒 Bật Script Shift Lock (Universal)", function()
    pcall(function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shift-Lock-121871"))() end)
end)

---------------------------------------------------------
-- 4. TAB VISUAL
---------------------------------------------------------
addSimpleToggle(VisualPage, "ESP Tên", function(val) Settings.ESP_Name = val end)
addSimpleToggle(VisualPage, "ESP Viền Sáng", function(val) Settings.ESP_Highlight = val end)
addSimpleToggle(VisualPage, "Full ESP (Hiển thị Máu + Tên)", function(val) Settings.ESP_Full = val end)

local function ApplyXRay(active)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
            if active then
                if not obj:FindFirstChild("OriginalTransparency") then
                    local val = Instance.new("NumberValue", obj)
                    val.Name = "OriginalTransparency"
                    val.Value = obj.Transparency
                end
                obj.Transparency = 0.6
            else
                if obj:FindFirstChild("OriginalTransparency") then
                    obj.Transparency = obj.OriginalTransparency.Value
                    obj.OriginalTransparency:Destroy()
                end
            end
        end
    end
end

addSimpleToggle(VisualPage, "X-Ray (Nhìn Xuyên Tường)", function(val) Settings.XRayActive = val ApplyXRay(val) end)
addSimpleToggle(VisualPage, "Full Bright (Màn Hình Sáng Vô Hạn)", function(val)
    Settings.FullBrightActive = val
    if not val then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

addSimpleToggle(VisualPage, "Noclip Camera (Nhìn Qua Tường)", function(val)
    Settings.CamNoclipActive = val
    LocalPlayer.DevCameraOcclusionMode = val and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom
end)

addSimpleToggle(VisualPage, "Mở Khoá Góc Nhìn Camera", function(val)
    Settings.UnlockCamActive = val
    LocalPlayer.CameraMaxZoomDistance = val and 99999 or 128
end)

---------------------------------------------------------
-- 5. TAB WORLD
---------------------------------------------------------
addSimpleToggle(WorldPage, "Xóa Sương Mù (Remove Fog)", function(val)
    Settings.RemoveFogActive = val
    if val then
        Lighting.FogEnd = 9e9
        for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") then v:Destroy() end end
    else
        Lighting.FogEnd = 1000
    end
end)

addActionButton(WorldPage, "Giảm Lag (FPS Boost - Smooth Textures)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
end)

---------------------------------------------------------
-- 6. TAB CHAT
---------------------------------------------------------
local ChatTargetBox = Instance.new("TextBox", ChatPage)
ChatTargetBox.Size = UDim2.new(0.99, 0, 0, 32)
ChatTargetBox.PlaceholderText = "Nhập tên bạn bè cần chat riêng..."
ChatTargetBox.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
ChatTargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatTargetBox.Font = Enum.Font.Gotham
ChatTargetBox.TextSize = 11
local CTC = Instance.new("UICorner", ChatTargetBox) CTC.CornerRadius = UDim.new(0, 6)

local ChatMsgBox = Instance.new("TextBox", ChatPage)
ChatMsgBox.Size = UDim2.new(0.99, 0, 0, 32)
ChatMsgBox.PlaceholderText = "Nhập nội dung tin nhắn..."
ChatMsgBox.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
ChatMsgBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatMsgBox.Font = Enum.Font.Gotham
ChatMsgBox.TextSize = 11
local CMBC = Instance.new("UICorner", ChatMsgBox) CMBC.CornerRadius = UDim.new(0, 6)

addActionButton(ChatPage, "Gửi Tin Nhắn Riêng", function()
    local targetName = ChatTargetBox.Text:lower()
    local msg = ChatMsgBox.Text
    if targetName == "" or msg == "" then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(targetName) or p.DisplayName:lower():find(targetName) then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w " .. p.Name .. " " .. msg, "All")
            end)
            ChatMsgBox.Text = ""
            break
        end
    end
end)

---------------------------------------------------------
-- 7. TAB TỔNG HỢP (AUTO CLICK & WAYPOINT)
---------------------------------------------------------
local AutoClickPoints = {}

local ACBar = Instance.new("Frame", ScreenGui)
ACBar.Size = UDim2.new(0, 50, 0, 180)
ACBar.Position = UDim2.new(0.02, 0, 0.35, 0)
ACBar.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ACBar.Active = true
ACBar.Draggable = true
ACBar.Visible = false

local ACBarCorner = Instance.new("UICorner", ACBar) ACBarCorner.CornerRadius = UDim.new(0, 8)
local ACBarStroke = Instance.new("UIStroke", ACBar) ACBarStroke.Color = Color3.fromRGB(0, 255, 200)

local ACBarLayout = Instance.new("UIListLayout", ACBar)
ACBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ACBarLayout.Padding = UDim.new(0, 5)

local function makeRoundBtn(parent, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 40, 0, 30)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local c = Instance.new("UICorner", btn) c.CornerRadius = UDim.new(0, 6)
    return btn
end

local ACAddBtn = makeRoundBtn(ACBar, "+", Color3.fromRGB(0, 150, 255))
local ACDelBtn = makeRoundBtn(ACBar, "-", Color3.fromRGB(255, 100, 0))
local ACClearBtn = makeRoundBtn(ACBar, "🗑", Color3.fromRGB(200, 50, 50))
local ACRunBtn = makeRoundBtn(ACBar, "▶", Color3.fromRGB(40, 160, 90))
local ACSettingsBtn = makeRoundBtn(ACBar, "⚙", Color3.fromRGB(150, 150, 0))

local ACSettingsFrame = Instance.new("Frame", ScreenGui)
ACSettingsFrame.Size = UDim2.new(0, 200, 0, 170)
ACSettingsFrame.Position = UDim2.new(0.08, 0, 0.35, 0)
ACSettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
ACSettingsFrame.Visible = false
ACSettingsFrame.Active = true
ACSettingsFrame.Draggable = true

local ACSFrameCorner = Instance.new("UICorner", ACSettingsFrame) ACSFrameCorner.CornerRadius = UDim.new(0, 8)

local ACLoopInfBtn = Instance.new("TextButton", ACSettingsFrame)
ACLoopInfBtn.Size = UDim2.new(0.9, 0, 0, 28)
ACLoopInfBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
ACLoopInfBtn.Text = "Lặp Vô Hạn: ON"
ACLoopInfBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
ACLoopInfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ACLoopInfBtn.Font = Enum.Font.GothamBold

local ACLCorner = Instance.new("UICorner", ACLoopInfBtn) ACLCorner.CornerRadius = UDim.new(0, 4)

ACLoopInfBtn.MouseButton1Click:Connect(function()
    Settings.AC_LoopInfinite = not Settings.AC_LoopInfinite
    ACLoopInfBtn.BackgroundColor3 = Settings.AC_LoopInfinite and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(180, 50, 60)
    ACLoopInfBtn.Text = "Lặp Vô Hạn: " .. (Settings.AC_LoopInfinite and "ON" or "OFF")
end)

local function makeBox(parent, yPos, text, placeholder)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.9, 0, 0, 28)
    box.Position = UDim2.new(0.05, 0, yPos, 0)
    box.Text = text
    box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
    box.TextColor3 = Color3.fromRGB(0, 255, 200)
    box.Font = Enum.Font.Gotham
    local c = Instance.new("UICorner", box) c.CornerRadius = UDim.new(0, 4)
    return box
end

local ACDelayBox = makeBox(ACSettingsFrame, 0.28, tostring(Settings.AC_Delay), "Tốc độ nhấn (giây)")
ACDelayBox.FocusLost:Connect(function()
    local val = tonumber(ACDelayBox.Text)
    if val then Settings.AC_Delay = math.max(0.01, val) end
end)

local ACLoopCountBox = makeBox(ACSettingsFrame, 0.51, tostring(Settings.AC_LoopCount), "Số vòng lặp")
ACLoopCountBox.FocusLost:Connect(function()
    local val = tonumber(ACLoopCountBox.Text)
    if val then Settings.AC_LoopCount = val end
end)

local ACSizeBox = makeBox(ACSettingsFrame, 0.74, tostring(Settings.AC_CircleSize), "Kích thước vòng")
ACSizeBox.FocusLost:Connect(function()
    local val = tonumber(ACSizeBox.Text)
    if val then
        Settings.AC_CircleSize = val
        for _, p in pairs(AutoClickPoints) do p.Frame.Size = UDim2.new(0, val, 0, val) end
    end
end)

ACSettingsBtn.MouseButton1Click:Connect(function() ACSettingsFrame.Visible = not ACSettingsFrame.Visible end)

local function createAutoClickPoint()
    local id = #AutoClickPoints + 1
    local pFrame = Instance.new("Frame", ScreenGui)
    pFrame.Size = UDim2.new(0, Settings.AC_CircleSize, 0, Settings.AC_CircleSize)
    pFrame.Position = UDim2.new(0.5, -20 + (id * 10), 0.5, -20)
    pFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    pFrame.BackgroundTransparency = 0.6
    pFrame.Active = true
    pFrame.Draggable = true

    local stroke = Instance.new("UIStroke", pFrame) stroke.Color = Color3.fromRGB(0, 255, 200) stroke.Thickness = 2
    local corner = Instance.new("UICorner", pFrame) corner.CornerRadius = UDim.new(1, 0)

    local centerDot = Instance.new("Frame", pFrame)
    centerDot.Size = UDim2.new(0, 4, 0, 4)
    centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    centerDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    local dotCorner = Instance.new("UICorner", centerDot) dotCorner.CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", pFrame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tostring(id)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold

    table.insert(AutoClickPoints, {Frame = pFrame})
end

ACAddBtn.MouseButton1Click:Connect(createAutoClickPoint)
ACDelBtn.MouseButton1Click:Connect(function()
    if #AutoClickPoints > 0 then
        local last = AutoClickPoints[#AutoClickPoints]
        last.Frame:Destroy()
        table.remove(AutoClickPoints, #AutoClickPoints)
    end
end)
ACClearBtn.MouseButton1Click:Connect(function()
    for _, p in pairs(AutoClickPoints) do p.Frame:Destroy() end
    AutoClickPoints = {}
end)

ACRunBtn.MouseButton1Click:Connect(function()
    Settings.AC_Running = not Settings.AC_Running
    if Settings.AC_Running then
        ACRunBtn.Text = "⏹"
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        task.spawn(function()
            local loops = 0
            while Settings.AC_Running do
                if not Settings.AC_LoopInfinite and loops >= Settings.AC_LoopCount then
                    Settings.AC_Running = false
                    break
                end

                for i, p in ipairs(AutoClickPoints) do
                    if not Settings.AC_Running then break end
                    local absPos = p.Frame.AbsolutePosition
                    local absSize = p.Frame.AbsoluteSize
                    local centerX = absPos.X + (absSize.X / 2)
                    local centerY = absPos.Y + (absSize.Y / 2) + GuiService:GetGuiInset().Y

                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                    task.wait(Settings.AC_Delay)
                end
                loops = loops + 1
                task.wait(0.05)
            end
            Settings.AC_Running = false
            ACRunBtn.Text = "▶"
            ACRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        end)
    else
        ACRunBtn.Text = "▶"
        ACRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
    end
end)

addSimpleToggle(MiscPage, "Bật Thanh Auto Click Nổi", function(state)
    ACBar.Visible = state
    if not state then ACSettingsFrame.Visible = false Settings.AC_Running = false end
end)

------------------ WAYPOINT SYSTEM ------------------
local WaypointList = {}
local WPFolder = workspace:FindFirstChild("MobileHubWaypoints") or Instance.new("Folder", workspace)
WPFolder.Name = "MobileHubWaypoints"

local WPBar = Instance.new("Frame", ScreenGui)
WPBar.Size = UDim2.new(0, 50, 0, 180)
WPBar.Position = UDim2.new(0.92, 0, 0.35, 0)
WPBar.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
WPBar.Active = true
WPBar.Draggable = true
WPBar.Visible = false

local WPBarCorner = Instance.new("UICorner", WPBar) WPBarCorner.CornerRadius = UDim.new(0, 8)
local WPBarStroke = Instance.new("UIStroke", WPBar) WPBarStroke.Color = Color3.fromRGB(0, 255, 200)

local WPBarLayout = Instance.new("UIListLayout", WPBar)
WPBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WPBarLayout.Padding = UDim.new(0, 5)

local WPAddBtn = makeRoundBtn(WPBar, "📍+", Color3.fromRGB(0, 150, 255))
local WPRunBtn = makeRoundBtn(WPBar, "▶", Color3.fromRGB(40, 160, 90))
local WPDelBtn = makeRoundBtn(WPBar, "📍-", Color3.fromRGB(255, 100, 0))
local WPClearBtn = makeRoundBtn(WPBar, "🗑", Color3.fromRGB(200, 50, 50))
local WPSettingsBtn = makeRoundBtn(WPBar, "⚙", Color3.fromRGB(150, 150, 0))

local WPSettingsFrame = Instance.new("Frame", ScreenGui)
WPSettingsFrame.Size = UDim2.new(0, 210, 0, 120)
WPSettingsFrame.Position = UDim2.new(0.78, 0, 0.35, 0)
WPSettingsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
WPSettingsFrame.Visible = false
WPSettingsFrame.Active = true
WPSettingsFrame.Draggable = true

local WPSCorner = Instance.new("UICorner", WPSettingsFrame) WPSCorner.CornerRadius = UDim.new(0, 8)

local WPModeBtn = Instance.new("TextButton", WPSettingsFrame)
WPModeBtn.Size = UDim2.new(0.9, 0, 0, 35)
WPModeBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
WPModeBtn.Text = "Chế độ: Bay Waypoint"
WPModeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
WPModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WPModeBtn.Font = Enum.Font.GothamBold

local WPMCorner = Instance.new("UICorner", WPModeBtn) WPMCorner.CornerRadius = UDim.new(0, 4)

local WPSpeedBox = makeBox(WPSettingsFrame, 0.5, tostring(Settings.WP_FlySpeed), "Tốc độ bay (Studs/s)")
WPSpeedBox.FocusLost:Connect(function()
    local val = tonumber(WPSpeedBox.Text)
    if val then Settings.WP_FlySpeed = math.max(5, val) end
end)

WPModeBtn.MouseButton1Click:Connect(function()
    if Settings.WP_Mode == "Fly" then
        Settings.WP_Mode = "Teleport"
        WPModeBtn.Text = "Chế độ: Dịch Chuyển WP"
        WPSpeedBox.Visible = false
    else
        Settings.WP_Mode = "Fly"
        WPModeBtn.Text = "Chế độ: Bay Waypoint"
        WPSpeedBox.Visible = true
    end
end)

WPSettingsBtn.MouseButton1Click:Connect(function() WPSettingsFrame.Visible = not WPSettingsFrame.Visible end)

local function createWaypointVisual(cframe, index)
    local pole = Instance.new("Part")
    pole.Name = "WP_" .. tostring(index)
    pole.Size = Vector3.new(0.4, 8, 0.4)
    pole.CFrame = cframe
    pole.Anchored = true
    pole.CanCollide = false
    pole.Material = Enum.Material.Neon
    pole.Color = Color3.fromRGB(0, 255, 200)
    pole.Transparency = 0.3
    pole.Parent = WPFolder

    local bb = Instance.new("BillboardGui", pole)
    bb.Size = UDim2.new(0, 80, 0, 30)
    bb.AlwaysOnTop = true
    bb.ExtentsOffset = Vector3.new(0, 4.5, 0)

    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "WP " .. tostring(index)
    txt.TextColor3 = Color3.fromRGB(0, 255, 200)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold

    return pole
end

WPAddBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local cf = char.HumanoidRootPart.CFrame
        local pole = createWaypointVisual(cf, #WaypointList + 1)
        table.insert(WaypointList, {CFrame = cf, Part = pole})
    end
end)

WPDelBtn.MouseButton1Click:Connect(function()
    if #WaypointList > 0 then
        local last = WaypointList[#WaypointList]
        if last.Part then last.Part:Destroy() end
        table.remove(WaypointList, #WaypointList)
    end
end)

WPClearBtn.MouseButton1Click:Connect(function()
    for _, wp in pairs(WaypointList) do if wp.Part then wp.Part:Destroy() end end
    WaypointList = {}
end)

WPRunBtn.MouseButton1Click:Connect(function()
    if #WaypointList == 0 then return end
    Settings.WP_Running = not Settings.WP_Running

    if Settings.WP_Running then
        WPRunBtn.Text = "⏹"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

        task.spawn(function()
            while Settings.WP_Running do
                for i, wp in ipairs(WaypointList) do
                    if not Settings.WP_Running or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then break end
                    local hrp = LocalPlayer.Character.HumanoidRootPart

                    if Settings.WP_Mode == "Teleport" then
                        hrp.CFrame = wp.CFrame
                        task.wait(0.2)
                    elseif Settings.WP_Mode == "Fly" then
                        local distance = (hrp.Position - wp.CFrame.Position).Magnitude
                        local duration = distance / Settings.WP_FlySpeed
                        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = wp.CFrame})
                        
                        tween:Play()
                        local completed = false
                        local conn = tween.Completed:Connect(function() completed = true end)

                        while not completed and Settings.WP_Running do task.wait(0.05) end
                        if conn then conn:Disconnect() end
                        if not Settings.WP_Running then tween:Cancel() break end
                    end
                end
                task.wait(0.1)
            end
            Settings.WP_Running = false
            WPRunBtn.Text = "▶"
            WPRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
        end)
    else
        WPRunBtn.Text = "▶"
        WPRunBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 90)
    end
end)

addSimpleToggle(MiscPage, "Bật Thanh Waypoint Nổi", function(state)
    WPBar.Visible = state
    if not state then WPSettingsFrame.Visible = false Settings.WP_Running = false end
end)

---------------------------------------------------------
-- ESP & GAMEPLAY LOOP
---------------------------------------------------------
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local function getHealthColor(percent)
    if percent >= 0.99 then return Color3.fromRGB(0, 255, 150)
    elseif percent >= 0.75 then return Color3.fromRGB(150, 255, 0)
    elseif percent >= 0.50 then return Color3.fromRGB(255, 255, 0)
    elseif percent >= 0.35 then return Color3.fromRGB(255, 128, 0)
    else return Color3.fromRGB(255, 50, 50) end
end

local function ensureESP(p)
    if p == LocalPlayer or not p.Character then return end
    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hl = char:FindFirstChild("ESP_Highlight")
    if not hl then
        hl = Instance.new("Highlight", char)
        hl.Name = "ESP_Highlight"
        hl.Enabled = false
    end

    local bb = hrp:FindFirstChild("ESP_Billboard")
    if not bb then
        bb = Instance.new("BillboardGui", hrp)
        bb.Name = "ESP_Billboard"
        bb.Size = UDim2.new(0, 150, 0, 40)
        bb.AlwaysOnTop = true
        bb.ExtentsOffset = Vector3.new(0, 3.5, 0)
        bb.Enabled = false

        local txtName = Instance.new("TextLabel", bb)
        txtName.Name = "NameLabel"
        txtName.Size = UDim2.new(1, 0, 0.5, 0)
        txtName.BackgroundTransparency = 1
        txtName.TextScaled = true
        txtName.Font = Enum.Font.GothamBold

        local txtHP = Instance.new("TextLabel", bb)
        txtHP.Name = "HPLabel"
        txtHP.Position = UDim2.new(0, 0, 0.5, 0)
        txtHP.Size = UDim2.new(1, 0, 0.5, 0)
        txtHP.BackgroundTransparency = 1
        txtHP.TextScaled = true
        txtHP.Font = Enum.Font.Gotham
    end
end

local function IsVisible(targetPart)
    if not Settings.AimWallCheck then return true end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
    raycastParams.IgnoreWater = true

    return workspace:Raycast(origin, direction, raycastParams) == nil
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Settings.FullBrightActive then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 14
    end

    if Settings.CamNoclipActive and LocalPlayer.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            ensureESP(p)
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hrp then
                local hl = char:FindFirstChild("ESP_Highlight")
                local bb = hrp:FindFirstChild("ESP_Billboard")

                if hl then hl.Enabled = Settings.ESP_Highlight or Settings.ESP_Full end

                if bb then
                    local txtName = bb:FindFirstChild("NameLabel")
                    local txtHP = bb:FindFirstChild("HPLabel")
                    bb.Enabled = Settings.ESP_Name or Settings.ESP_Full

                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local currentColor = getHealthColor(hpPercent)

                    if txtName and txtHP then
                        txtName.Text = p.DisplayName
                        txtName.TextColor3 = currentColor

                        if Settings.ESP_Full then
                            txtHP.Text = string.format("[HP: %d/%d]", math.floor(hum.Health), math.floor(hum.MaxHealth))
                            txtHP.TextColor3 = currentColor
                            txtHP.Visible = true
                        else
                            txtHP.Visible = false
                        end
                    end

                    if hl then hl.FillColor = currentColor hl.OutlineColor = currentColor end
                end
            end
        end
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if Settings.WalkSpeedActive then hum.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.JumpPowerActive then hum.UseJumpPower = true hum.JumpPower = Settings.JumpPowerVal end
        if Settings.GravityActive then workspace.Gravity = Settings.GravityVal end
    end

    if Settings.AimbotMode ~= "None" then
        local target = nil
        local shortestDist = math.huge
        local lowestHP = math.huge
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local pChar = player.Character
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                local pHrp = pChar.HumanoidRootPart

                if pHum.Health > 0 and IsVisible(pHrp) then
                    local pos, onScreen = Camera:WorldToViewportPoint(pHrp.Position)
                    local distToCenter = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    local distToPlayer = (pHrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

                    if Settings.AimbotMode == "Closest" and distToPlayer < shortestDist then
                        shortestDist = distToPlayer
                        target = pHrp
                    elseif Settings.AimbotMode == "LowestHealth" and pHum.Health < lowestHP then
                        lowestHP = pHum.Health
                        target = pHrp
                    elseif Settings.AimbotMode == "FOV" and onScreen and distToCenter <= Settings.FOVRadius then
                        if distToCenter < shortestDist then
                            shortestDist = distToCenter
                            target = pHrp
                        end
                    elseif Settings.AimbotMode == "TargetName" and Settings.AimTargetName ~= "" then
                        if player.Name:lower():find(Settings.AimTargetName, 1, true) or player.DisplayName:lower():find(Settings.AimTargetName, 1, true) then
                            target = pHrp
                            break
                        end
                    end
                end
            end
        end

        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
