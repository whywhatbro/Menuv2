-- =================================================================
-- KING LEGACY - TEST PHẦN 1 & PHẦN 2 KẾT HỢP
-- =================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

getgenv().KL_TestConfig = {
    TweenSpeed = 280,
    SafeDistance = 35,
    AutoBuso = true,
    AutoKen = true,
    AutoEquipMain = true,
    MainWeapon = "Melee", -- "Melee", "Sword", hoặc "Blox Fruit"
    Skills = {Z = true, X = true, C = true, V = true, E = true}
}

-- // 1. HỆ THỐNG NOCLIP & TWEEN (PHẦN 1)
local NoclipConn
local function SetNoclip(state)
    if state then
        if not NoclipConn then
            NoclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if NoclipConn then NoclipConn:Disconnect() NoclipConn = nil end
    end
end

local currentTween = nil
local function SafeTween(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    if dist < 5 then return end

    SetNoclip(true)
    local duration = dist / getgenv().KL_TestConfig.TweenSpeed
    
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    currentTween:Play()

    currentTween.Completed:Connect(function()
        SetNoclip(false)
    end)
end

-- // 2. TẠO GIAO DIỆN MENU GUI (PHẦN 1)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KL_Test_GUI"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer.PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
ToggleBtn.Text = "MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
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
Title.Text = "TEST P1 & P2: HAKI & COMBO"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -45)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.Padding = UDim.new(0, 5)

local function CreateToggle(text, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(50, 50, 60)
    btn.Text = text .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Scroll

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(50, 50, 60)
        callback(state)
    end)
end

CreateToggle("Auto Buso Haki", getgenv().KL_TestConfig.AutoBuso, function(s) getgenv().KL_TestConfig.AutoBuso = s end)
CreateToggle("Auto Ken Haki", getgenv().KL_TestConfig.AutoKen, function(s) getgenv().KL_TestConfig.AutoKen = s end)
CreateToggle("Auto Equip Weapon", getgenv().KL_TestConfig.AutoEquipMain, function(s) getgenv().KL_TestConfig.AutoEquipMain = s end)

for _, key in ipairs({"Z", "X", "C", "V", "E"}) do
    CreateToggle("Skill [" .. key .. "]", getgenv().KL_TestConfig.Skills[key], function(s)
        getgenv().KL_TestConfig.Skills[key] = s
    end)
end

-- // 3. HỆ THỐNG HAKI & VŨ KHÍ (PHẦN 2)
task.spawn(function()
    while task.wait(1.5) do
        local char = LocalPlayer.Character
        if char then
            if getgenv().KL_TestConfig.AutoBuso and not char:FindFirstChild("HasBuso") then
                pcall(function() ReplicatedStorage.Remotes.Functions.Buso:InvokeServer() end)
            end
            if getgenv().KL_TestConfig.AutoKen and not char:FindFirstChild("HasKen") then
                pcall(function() ReplicatedStorage.Remotes.Functions.Ken:InvokeServer() end)
            end
        end
    end
end)

local function EquipMainWeapon()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end

    local allTools = {}
    for _, item in pairs(backpack:GetChildren()) do if item:IsA("Tool") then table.insert(allTools, item) end end
    for _, item in pairs(char:GetChildren()) do if item:IsA("Tool") then table.insert(allTools, item) end end

    for _, tool in pairs(allTools) do
        local name = tool.Name:lower()
        local isMatch = false
        local weaponType = getgenv().KL_TestConfig.MainWeapon

        if weaponType == "Melee" and (name:find("style") or name:find("combat") or name:find("leg") or name:find("fist") or name:find("claw") or name:find("karate")) then isMatch = true
        elseif weaponType == "Sword" and not name:find("fruit") and not name:find("style") and not name:find("combat") then isMatch = true
        elseif weaponType == "Blox Fruit" and (name:find("fruit") or tool:FindFirstChild("Fruit")) then isMatch = true end

        if isMatch then
            if tool.Parent ~= char then char.Humanoid:EquipTool(tool) end
            return tool
        end
    end
    return nil
end

-- Test chạy thử tính năng Combat định kỳ khi bật toggle
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().KL_TestConfig.AutoEquipMain then
            EquipMainWeapon()
        end
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
                for skillKey, enabled in pairs(getgenv().KL_TestConfig.Skills) do
                    if enabled then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[skillKey], false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[skillKey], false, game)
                    end
                end
            end
        end
    end
end)

print("[System] Test Phần 1 và Phần 2 đã tải thành công!")
