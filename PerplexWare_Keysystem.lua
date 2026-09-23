local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local VALID_KEY = "PerplexFree"
local DISCORD_LINK = "https://discord.gg/4qsE29qaPJ"
local WEAO_LINK = "https://weao.gg"
local POLICY_FILE = "Accept.lua"
local KEY_FILE = "PerplexWare_Key.lua"
local BLOCKED_EXECUTORS = {"xeno", "solara", "sirhurt", "real"}

local C_ACCENT  = Color3.fromRGB(167, 200, 245)
local C_WHITE   = Color3.fromRGB(245, 248, 255)
local C_BLACK   = Color3.fromRGB(6, 8, 12)
local C_DARK    = Color3.fromRGB(10, 14, 20)
local C_MID     = Color3.fromRGB(18, 24, 34)
local C_DIM     = Color3.fromRGB(80, 110, 150)

local keyValidated = false
local keyValidEvent = Instance.new("BindableEvent")

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

pcall(function() setclipboard(DISCORD_LINK) end)

local closing = false
local Scale = nil

local FadeTargets = {}
local function track(obj, prop)
    table.insert(FadeTargets, {obj = obj, prop = prop})
end

local function getExecutorName()
    local ok, name = pcall(function()
        if identifyexecutor then
            local n = identifyexecutor()
            return n
        end
        return nil
    end)
    if ok and name and tostring(name) ~= "" then
        return tostring(name)
    end
    return "Ass ah exexutor. Stop using this shit"
end

local function isBlockedExecutor(name)
    if not name then return false end
    local lower = string.lower(name)
    for _, blocked in ipairs(BLOCKED_EXECUTORS) do
        if string.find(lower, blocked, 1, true) then
            return true
        end
    end
    return false
end

local function hasAcceptedPolicy()
    local accepted = false
    pcall(function()
        if isfile and isfile(POLICY_FILE) then
            local content = readfile(POLICY_FILE)
            if content and trim(content) ~= "" then
                accepted = true
            end
        end
    end)
    return accepted
end

local function acceptPolicy()
    pcall(function()
        if writefile then
            writefile(POLICY_FILE, "accepted")
        end
    end)
end

local function saveKey(key)
    pcall(function()
        if writefile then
            writefile(KEY_FILE, key)
        end
    end)
end

local function loadSavedKey()
    local saved = nil
    pcall(function()
        if isfile and isfile(KEY_FILE) then
            local content = readfile(KEY_FILE)
            if content and trim(content) ~= "" then
                saved = trim(content)
            end
        end
    end)
    return saved
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PerplexWareCreation"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function setGuiParent(gui)
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok then return end
    end
    local ok2 = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if ok2 then return end
    gui.Parent = PlayerGui
end
setGuiParent(ScreenGui)

local Backdrop = Instance.new("Frame")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.new(1, 0, 1, 0)
Backdrop.Position = UDim2.new(0, 0, 0, 0)
Backdrop.BackgroundColor3 = C_BLACK
Backdrop.BackgroundTransparency = 0
Backdrop.BorderSizePixel = 0
Backdrop.ZIndex = 1
Backdrop.Parent = ScreenGui
track(Backdrop, "BackgroundTransparency")

local BackdropGradient = Instance.new("UIGradient")
BackdropGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 8, 16)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(6, 10, 18)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(8, 14, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 6, 12)),
})
BackdropGradient.Rotation = 110
BackdropGradient.Parent = Backdrop

task.spawn(function()
    while Backdrop.Parent and not closing do
        TweenService:Create(BackdropGradient, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 160}):Play()
        task.wait(5)
        if closing then break end
        TweenService:Create(BackdropGradient, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 110}):Play()
        task.wait(5)
    end
end)

local StormCloudLayer = Instance.new("Frame")
StormCloudLayer.Name = "StormCloudLayer"
StormCloudLayer.Size = UDim2.new(1, 0, 0.65, 0)
StormCloudLayer.Position = UDim2.new(0, 0, -0.1, 0)
StormCloudLayer.BackgroundTransparency = 1
StormCloudLayer.ZIndex = 1
StormCloudLayer.Parent = Backdrop

local function spawnStormCloud()
    local cloud = Instance.new("Frame")
    local w = math.random(40, 80) / 100
    local h = math.random(12, 28) / 100
    cloud.Size = UDim2.new(w, 0, h, 0)
    cloud.Position = UDim2.new(math.random(-20, 80) / 100, 0, math.random(0, 70) / 100, 0)
    local g = math.random(10, 28)
    cloud.BackgroundColor3 = Color3.fromRGB(g, g + 4, g + 10)
    cloud.BackgroundTransparency = math.random(55, 78) / 100
    cloud.BorderSizePixel = 0
    cloud.ZIndex = 1
    cloud.Parent = StormCloudLayer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = cloud

    local grad = Instance.new("UIGradient")
    grad.Rotation = math.random(0, 30)
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.25, 0),
        NumberSequenceKeypoint.new(0.75, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = cloud

    local drift = math.random(2, 6) / 100
    local dur = math.random(18, 38)
    TweenService:Create(cloud, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
        Position = UDim2.new(cloud.Position.X.Scale + drift, 0, cloud.Position.Y.Scale, 0),
    }):Play()
    task.delay(dur, function()
        if cloud then cloud:Destroy() end
    end)
end

task.spawn(function()
    for i = 1, 8 do
        spawnStormCloud()
        task.wait(0.3)
    end
    while StormCloudLayer.Parent and not closing do
        spawnStormCloud()
        task.wait(math.random(20, 50) / 10)
    end
end)

local LightningLayer = Instance.new("Frame")
LightningLayer.Name = "LightningLayer"
LightningLayer.Size = UDim2.new(1, 0, 1, 0)
LightningLayer.BackgroundTransparency = 1
LightningLayer.ZIndex = 2
LightningLayer.Parent = Backdrop

local function flashLightning(xHint)
    if closing then return end

    local xPos = xHint or (math.random(5, 95) / 100)
    local boltW = math.random(1, 5)
    local bolt = Instance.new("Frame")
    bolt.Size = UDim2.new(0, boltW, 1, 0)
    bolt.Position = UDim2.new(xPos, 0, 0, 0)
    bolt.BackgroundColor3 = C_WHITE
    bolt.BackgroundTransparency = 0
    bolt.BorderSizePixel = 0
    bolt.ZIndex = 4
    bolt.Parent = LightningLayer

    local grad = Instance.new("UIGradient")
    grad.Rotation = 0
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.25, 0.2),
        NumberSequenceKeypoint.new(0.6, 0.55),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = bolt

    if boltW >= 3 then
        local fork = Instance.new("Frame")
        fork.Size = UDim2.new(0, math.random(1, 2), 0.45, 0)
        fork.Position = UDim2.new(xPos + math.random(1, 3) / 100, 0, math.random(15, 45) / 100, 0)
        fork.BackgroundColor3 = C_WHITE
        fork.BackgroundTransparency = 0.3
        fork.Rotation = math.random(10, 25)
        fork.BorderSizePixel = 0
        fork.ZIndex = 4
        fork.Parent = LightningLayer

        local forkGrad = Instance.new("UIGradient")
        forkGrad.Rotation = 0
        forkGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        })
        forkGrad.Parent = fork

        TweenService:Create(fork, TweenInfo.new(0.07), {BackgroundTransparency = 1}):Play()
        task.delay(0.09, function() if fork then fork:Destroy() end end)
    end

    local ambientFlash = Instance.new("Frame")
    ambientFlash.Size = UDim2.new(1, 0, 1, 0)
    ambientFlash.BackgroundColor3 = C_ACCENT
    ambientFlash.BackgroundTransparency = 0.75
    ambientFlash.BorderSizePixel = 0
    ambientFlash.ZIndex = 2
    ambientFlash.Parent = Backdrop

    TweenService:Create(bolt, TweenInfo.new(0.06), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ambientFlash, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()

    task.delay(0.08, function() if bolt then bolt:Destroy() end end)
    task.delay(0.22, function() if ambientFlash then ambientFlash:Destroy() end end)
end

task.spawn(function()
    while LightningLayer.Parent and not closing do
        task.wait(math.random(18, 55) / 10)
        if closing then break end
        local x = math.random(5, 95) / 100
        flashLightning(x)
        local strikes = math.random(1, 3)
        for i = 1, strikes do
            task.wait(math.random(6, 18) / 100)
            if closing then break end
            flashLightning(x + math.random(-5, 5) / 100)
        end
    end
end)

local GridContainer = Instance.new("Frame")
GridContainer.Name = "GridContainer"
GridContainer.Size = UDim2.new(1, 0, 1, 0)
GridContainer.BackgroundTransparency = 1
GridContainer.ZIndex = 2
GridContainer.Parent = Backdrop

local function buildGrid()
    local NUM_V, NUM_H = 18, 10
    for i = 1, NUM_V do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(i / (NUM_V + 1), 0, 0, 0)
        line.BackgroundColor3 = C_ACCENT
        line.BackgroundTransparency = 0.96
        line.BorderSizePixel = 0
        line.ZIndex = 2
        line.Parent = GridContainer
    end
    for i = 1, NUM_H do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i / (NUM_H + 1), 0)
        line.BackgroundColor3 = C_ACCENT
        line.BackgroundTransparency = 0.96
        line.BorderSizePixel = 0
        line.ZIndex = 2
        line.Parent = GridContainer
    end
end
buildGrid()

local ParticleLayer = Instance.new("Frame")
ParticleLayer.Name = "ParticleLayer"
ParticleLayer.Size = UDim2.new(1, 0, 1, 0)
ParticleLayer.BackgroundTransparency = 1
ParticleLayer.ClipsDescendants = true
ParticleLayer.ZIndex = 3
ParticleLayer.Parent = Backdrop

local function spawnRainDrop(layer, lengthMin, lengthMax, speedMin, speedMax, alphaMin, alphaMax, angleMin, angleMax)
    local p = Instance.new("Frame")
    local h = math.random(lengthMin, lengthMax)
    p.Size = UDim2.new(0, 1, 0, h)
    p.Position = UDim2.new(math.random(0, 1100) / 1000 - 0.05, 0, -0.06, 0)
    p.BackgroundColor3 = C_ACCENT
    p.BackgroundTransparency = math.random(alphaMin, alphaMax) / 100
    p.BorderSizePixel = 0
    p.ZIndex = 3
    p.Parent = layer

    local duration = math.random(speedMin, speedMax) / 100
    local angle = math.random(angleMin, angleMax) / 100
    TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Position = UDim2.new(p.Position.X.Scale + angle, 0, 1.08, 0),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(duration + 0.05, function()
        if p then p:Destroy() end
    end)
end

task.spawn(function()
    while ParticleLayer.Parent and not closing do
        spawnRainDrop(ParticleLayer, 10, 22, 40, 75, 38, 65, 4, 9)
        task.wait(math.random(5, 12) / 1000)
    end
end)

task.spawn(function()
    while ParticleLayer.Parent and not closing do
        spawnRainDrop(ParticleLayer, 6, 14, 55, 90, 55, 80, 3, 7)
        task.wait(math.random(8, 18) / 1000)
    end
end)

task.spawn(function()
    while ParticleLayer.Parent and not closing do
        spawnRainDrop(ParticleLayer, 18, 34, 30, 55, 22, 48, 5, 10)
        task.wait(math.random(14, 28) / 1000)
    end
end)

local function spawnRainSplash()
    local splash = Instance.new("Frame")
    local sz = math.random(3, 7)
    splash.Size = UDim2.new(0, sz, 0, 2)
    splash.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(60, 100) / 100, 0)
    splash.BackgroundColor3 = C_ACCENT
    splash.BackgroundTransparency = math.random(55, 80) / 100
    splash.BorderSizePixel = 0
    splash.ZIndex = 3
    splash.Parent = ParticleLayer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = splash

    local duration = math.random(2, 5) / 10
    TweenService:Create(splash, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, sz * 3, 0, 1),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(duration, function()
        if splash then splash:Destroy() end
    end)
end

task.spawn(function()
    while ParticleLayer.Parent and not closing do
        spawnRainSplash()
        task.wait(math.random(5, 14) / 100)
    end
end)

local function spawnWindStreak()
    local streak = Instance.new("Frame")
    local w = math.random(40, 120)
    streak.Size = UDim2.new(0, w, 0, 1)
    streak.Position = UDim2.new(-0.1, 0, math.random(0, 1000) / 1000, 0)
    streak.BackgroundColor3 = C_WHITE
    streak.BackgroundTransparency = math.random(82, 94) / 100
    streak.BorderSizePixel = 0
    streak.ZIndex = 3
    streak.Parent = ParticleLayer

    local grad = Instance.new("UIGradient")
    grad.Rotation = 0
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = streak

    local duration = math.random(6, 14) / 10
    TweenService:Create(streak, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
        Position = UDim2.new(1.1, 0, streak.Position.Y.Scale + math.random(1, 4) / 100, 0),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(duration, function()
        if streak then streak:Destroy() end
    end)
end

task.spawn(function()
    while ParticleLayer.Parent and not closing do
        spawnWindStreak()
        task.wait(math.random(4, 12) / 10)
    end
end)

local MountainLayer = Instance.new("Frame")
MountainLayer.Name = "MountainLayer"
MountainLayer.Size = UDim2.new(1, 0, 0.42, 0)
MountainLayer.AnchorPoint = Vector2.new(0.5, 1)
MountainLayer.Position = UDim2.new(0.5, 0, 1, 50)
MountainLayer.BackgroundTransparency = 1
MountainLayer.ZIndex = 2
MountainLayer.Parent = Backdrop

local BackPeak = Instance.new("TextLabel")
BackPeak.Name = "BackPeak"
BackPeak.Size = UDim2.new(0.85, 0, 1, 0)
BackPeak.AnchorPoint = Vector2.new(0.5, 1)
BackPeak.Position = UDim2.new(0.4, 0, 1, 0)
BackPeak.BackgroundTransparency = 1
BackPeak.Text = "▲"
BackPeak.Font = Enum.Font.GothamBlack
BackPeak.TextScaled = true
BackPeak.TextColor3 = Color3.fromRGB(16, 22, 32)
BackPeak.TextTransparency = 0.45
BackPeak.ZIndex = 2
BackPeak.Parent = MountainLayer
track(BackPeak, "TextTransparency")

local FrontPeak = Instance.new("TextLabel")
FrontPeak.Name = "FrontPeak"
FrontPeak.Size = UDim2.new(1.05, 0, 1.15, 0)
FrontPeak.AnchorPoint = Vector2.new(0.5, 1)
FrontPeak.Position = UDim2.new(0.6, 0, 1, 0)
FrontPeak.BackgroundTransparency = 1
FrontPeak.Text = "▲"
FrontPeak.Font = Enum.Font.GothamBlack
FrontPeak.TextScaled = true
FrontPeak.TextColor3 = Color3.fromRGB(22, 32, 48)
FrontPeak.TextTransparency = 0.35
FrontPeak.ZIndex = 3
FrontPeak.Parent = MountainLayer
track(FrontPeak, "TextTransparency")

local WT_ANGLE   = -28
local WT_GAP_X   = 210
local WT_GAP_Y   = 64
local WT_COLS    = 9
local WT_ROWS    = 13
local WT_STAGGER = WT_GAP_X / 2
local WT_SPEED_X = -30
local WT_SPEED_Y = -18

local WordTileLayer = Instance.new("Frame")
WordTileLayer.Name               = "WordTileLayer"
WordTileLayer.Size               = UDim2.new(1, 0, 1, 0)
WordTileLayer.Position           = UDim2.new(0, 0, 0, 0)
WordTileLayer.BackgroundTransparency = 1
WordTileLayer.ClipsDescendants   = false
WordTileLayer.ZIndex             = 2
WordTileLayer.Parent             = Backdrop

local WT_WRAP_W = WT_COLS * WT_GAP_X
local WT_WRAP_H = WT_ROWS * WT_GAP_Y

local wTiles = {}

for row = 0, WT_ROWS - 1 do
    local stagger = (row % 2 == 0) and 0 or WT_STAGGER
    for col = 0, WT_COLS - 1 do
        local t = Instance.new("TextLabel")
        t.Size               = UDim2.new(0, 180, 0, 30)
        t.BackgroundTransparency = 1
        t.Text               = "Perplexware"
        t.Font               = Enum.Font.GothamBlack
        t.TextSize           = 17
        t.TextColor3         = C_ACCENT
        t.TextTransparency   = math.random(88, 95) / 100
        t.BorderSizePixel    = 0
        t.ZIndex             = 2
        t.Rotation           = WT_ANGLE
        t.Parent             = WordTileLayer

        local px = col * WT_GAP_X + stagger
        local py = row * WT_GAP_Y
        t.Position = UDim2.new(0, px, 0, py)
        table.insert(wTiles, {label = t, x = px, y = py})
    end
end

task.spawn(function()
    local lastT = tick()
    while WordTileLayer.Parent and not closing do
        local now = tick()
        local dt  = math.min(now - lastT, 0.05)
        lastT = now

        local dx = WT_SPEED_X * dt
        local dy = WT_SPEED_Y * dt

        for _, tile in ipairs(wTiles) do
            tile.x = tile.x + dx
            tile.y = tile.y + dy

            if tile.x < -220 then
                tile.x = tile.x + WT_WRAP_W
            elseif tile.x > WT_WRAP_W then
                tile.x = tile.x - WT_WRAP_W
            end

            if tile.y < -60 then
                tile.y = tile.y + WT_WRAP_H
            elseif tile.y > WT_WRAP_H then
                tile.y = tile.y - WT_WRAP_H
            end

            tile.label.Position = UDim2.new(0, tile.x, 0, tile.y)
        end

        task.wait()
    end
end)

local BrandMark = Instance.new("Frame")
BrandMark.Name = "BrandMark"
BrandMark.Position = UDim2.new(0, 28, 0, 26)
BrandMark.Size = UDim2.new(0, 26, 0, 26)
BrandMark.BackgroundColor3 = C_DARK
BrandMark.BorderSizePixel = 0
BrandMark.ZIndex = 4
BrandMark.Parent = Backdrop
track(BrandMark, "BackgroundTransparency")

local BrandCorner = Instance.new("UICorner")
BrandCorner.CornerRadius = UDim.new(0, 8)
BrandCorner.Parent = BrandMark

local BrandStroke = Instance.new("UIStroke")
BrandStroke.Color = C_ACCENT
BrandStroke.Thickness = 1
BrandStroke.Transparency = 0.5
BrandStroke.Parent = BrandMark
track(BrandStroke, "Transparency")

local BrandIcon = Instance.new("TextLabel")
BrandIcon.Size = UDim2.new(1, 0, 1, 0)
BrandIcon.BackgroundTransparency = 1
BrandIcon.Text = "P"
BrandIcon.TextColor3 = C_ACCENT
BrandIcon.TextScaled = true
BrandIcon.Font = Enum.Font.GothamBlack
BrandIcon.ZIndex = 5
BrandIcon.Parent = BrandMark
track(BrandIcon, "TextTransparency")

local BrandText = Instance.new("TextLabel")
BrandText.Position = UDim2.new(0, 62, 0, 26)
BrandText.Size = UDim2.new(0, 200, 0, 26)
BrandText.BackgroundTransparency = 1
BrandText.Text = "• PerplexWare"
BrandText.TextColor3 = C_ACCENT
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.TextSize = 13
BrandText.Font = Enum.Font.GothamBold
BrandText.ZIndex = 4
BrandText.Parent = Backdrop
track(BrandText, "TextTransparency")

local DetectedExecutor = getExecutorName()

local ExecutorTag = Instance.new("TextLabel")
ExecutorTag.AnchorPoint = Vector2.new(1, 1)
ExecutorTag.Position = UDim2.new(1, -28, 1, -24)
ExecutorTag.Size = UDim2.new(0, 260, 0, 18)
ExecutorTag.BackgroundTransparency = 1
ExecutorTag.Text = "EXECUTOR  •  " .. string.upper(DetectedExecutor)
ExecutorTag.TextColor3 = C_DIM
ExecutorTag.TextXAlignment = Enum.TextXAlignment.Right
ExecutorTag.TextSize = 11
ExecutorTag.Font = Enum.Font.Code
ExecutorTag.ZIndex = 4
ExecutorTag.Parent = Backdrop
track(ExecutorTag, "TextTransparency")

local CreditTag = Instance.new("TextLabel")
CreditTag.AnchorPoint = Vector2.new(0, 1)
CreditTag.Position = UDim2.new(0, 28, 1, -24)
CreditTag.Size = UDim2.new(0, 380, 0, 18)
CreditTag.BackgroundTransparency = 1
CreditTag.Text = "Made with Patient - https://perplexware.vercel.app/"
CreditTag.TextColor3 = C_DIM
CreditTag.TextXAlignment = Enum.TextXAlignment.Left
CreditTag.TextSize = 11
CreditTag.Font = Enum.Font.Code
CreditTag.ZIndex = 4
CreditTag.Parent = Backdrop
track(CreditTag, "TextTransparency")

local CloseBtn = Instance.new("TextButton")
CloseBtn.AnchorPoint = Vector2.new(1, 0)
CloseBtn.Position = UDim2.new(1, -28, 0, 26)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.BackgroundColor3 = C_DARK
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C_ACCENT
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ClipsDescendants = true
CloseBtn.ZIndex = 9
CloseBtn.Parent = Backdrop
track(CloseBtn, "BackgroundTransparency")
track(CloseBtn, "TextTransparency")

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = C_ACCENT
CloseStroke.Thickness = 1
CloseStroke.Transparency = 0.5
CloseStroke.Parent = CloseBtn
track(CloseStroke, "Transparency")

local function showToast(message)
    local toast = Instance.new("Frame")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, -60)
    toast.Size = UDim2.new(0, 320, 0, 42)
    toast.BackgroundColor3 = C_DARK
    toast.BorderSizePixel = 0
    toast.ZIndex = 30
    toast.Parent = Backdrop

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Color = C_ACCENT
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = toast

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = C_WHITE
    text.TextSize = 13
    text.Font = Enum.Font.GothamMedium
    text.TextWrapped = true
    text.ZIndex = 31
    text.Parent = toast

    TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 24),
    }):Play()
    task.delay(3.2, function()
        if toast.Parent and not closing then
            TweenService:Create(toast, TweenInfo.new(0.35), {Position = UDim2.new(0.5, 0, 0, -60)}):Play()
            task.delay(0.4, function()
                if toast then toast:Destroy() end
            end)
        end
    end)
end

showToast("Discord link copied to clipboard")

local function addInteractionFX(guiObject)
    local scale = Instance.new("UIScale")
    scale.Parent = guiObject

    local function wink()
        TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.92}):Play()
        task.wait(0.08)
        TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end

    local function ripple()
        local r = Instance.new("Frame")
        r.AnchorPoint = Vector2.new(0.5, 0.5)
        r.Position = UDim2.new(0.5, 0, 0.5, 0)
        r.Size = UDim2.new(0, 6, 0, 6)
        r.BackgroundColor3 = C_ACCENT
        r.BackgroundTransparency = 0.2
        r.BorderSizePixel = 0
        r.ZIndex = guiObject.ZIndex + 3
        r.Parent = guiObject

        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(1, 0)
        rc.Parent = r

        local targetSize = math.max(guiObject.AbsoluteSize.X, guiObject.AbsoluteSize.Y) * 1.7
        TweenService:Create(r, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, targetSize, 0, targetSize),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.5, function() if r then r:Destroy() end end)
    end

    return wink, ripple
end

local closeWink, closeRipple = addInteractionFX(CloseBtn)

local function addShine(button, radius)
    local shine = Instance.new("Frame")
    shine.Size = UDim2.new(1, 0, 1, 0)
    shine.BackgroundColor3 = C_WHITE
    shine.BorderSizePixel = 0
    shine.ZIndex = button.ZIndex + 1
    shine.Parent = button

    local shineCorner = Instance.new("UICorner")
    shineCorner.CornerRadius = UDim.new(0, radius)
    shineCorner.Parent = shine

    local grad = Instance.new("UIGradient")
    grad.Rotation = 20
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.45, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(0.55, 1),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Offset = Vector2.new(-1, 0)
    grad.Parent = shine

    task.spawn(function()
        while shine.Parent and not closing do
            grad.Offset = Vector2.new(-1, 0)
            TweenService:Create(grad, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Offset = Vector2.new(1.5, 0),
            }):Play()
            task.wait(math.random(30, 55) / 10)
        end
    end)
end

local function createCard(width)
    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.53, 0)
    card.Size = UDim2.new(0, width, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C_DARK
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = 5
    card.Parent = Backdrop

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = card

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
    })
    gradient.Rotation = 115
    gradient.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.4
    stroke.Transparency = 0.35
    stroke.Parent = card

    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_ACCENT),
        ColorSequenceKeypoint.new(0.5, C_DIM),
        ColorSequenceKeypoint.new(1, C_WHITE),
    })
    strokeGrad.Parent = stroke

    task.spawn(function()
        while card.Parent and not closing do
            strokeGrad.Rotation = (strokeGrad.Rotation + 1) % 360
            task.wait(0.04)
        end
    end)

    local scale = Instance.new("UIScale")
    scale.Scale = 0.9
    scale.Parent = card
    TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.ZIndex = 6
    content.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 28)
    padding.PaddingBottom = UDim.new(0, 28)
    padding.PaddingLeft = UDim.new(0, 26)
    padding.PaddingRight = UDim.new(0, 26)
    padding.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 14)
    layout.Parent = content

    return card, content, scale, stroke
end

local function dismissCard(card, scale, onDone)
    TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.9}):Play()
    TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    for _, d in ipairs(card:GetDescendants()) do
        pcall(function()
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                TweenService:Create(d, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            elseif d:IsA("Frame") then
                TweenService:Create(d, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            elseif d:IsA("UIStroke") then
                TweenService:Create(d, TweenInfo.new(0.25), {Transparency = 1}):Play()
            end
        end)
    end
    task.delay(0.28, function()
        card:Destroy()
        if onDone then onDone() end
    end)
end

local function fadeEverything(duration)
    GridContainer.Visible = false
    ParticleLayer.Visible = false
    StormCloudLayer.Visible = false
    LightningLayer.Visible = false
    WordTileLayer.Visible = false
    for _, item in ipairs(FadeTargets) do
        pcall(function()
            TweenService:Create(item.obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                [item.prop] = 1,
            }):Play()
        end)
    end
end

local function closeGate(callback)
    closing = true
    if Scale then
        TweenService:Create(Scale, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.92}):Play()
    end
    fadeEverything(0.32)
    task.delay(0.34, function()
        ScreenGui:Destroy()
        if callback then callback() end
    end)
end

CloseBtn.MouseEnter:Connect(function()
    if closing then return end
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 30, 44)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    if closing then return end
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = C_DARK}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    if closing then return end
    task.spawn(closeWink)
    closeRipple()
    task.delay(0.1, function()
        closeGate(nil)
    end)
end)

local function buildIconBadge(content, glyph, bgColor, glyphColor, order)
    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 44, 0, 44)
    icon.BackgroundColor3 = bgColor
    icon.BorderSizePixel = 0
    icon.LayoutOrder = order
    icon.ZIndex = 6
    icon.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 13)
    corner.Parent = icon

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = glyph
    label.TextColor3 = glyphColor
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.ZIndex = 7
    label.Parent = icon

    return icon
end

local function buildTitle(content, text, order)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = C_WHITE
    title.TextSize = 22
    title.Font = Enum.Font.GothamBlack
    title.LayoutOrder = order
    title.ZIndex = 6
    title.Parent = content
    return title
end

local function buildSubtitle(content, text, order)
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 18)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = text
    subtitle.TextColor3 = C_ACCENT
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.LayoutOrder = order
    subtitle.ZIndex = 6
    subtitle.Parent = content
    return subtitle
end

local function buildDivider(content, order)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
    divider.BorderSizePixel = 0
    divider.LayoutOrder = order
    divider.ZIndex = 6
    divider.Parent = content
    return divider
end

local function buildBody(content, text, height, order)
    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, 0, 0, height)
    body.BackgroundTransparency = 1
    body.Text = text
    body.TextColor3 = Color3.fromRGB(170, 190, 215)
    body.TextSize = 12.5
    body.TextWrapped = true
    body.Font = Enum.Font.Gotham
    body.LayoutOrder = order
    body.ZIndex = 6
    body.Parent = content
    return body
end

local function buildPrimaryButton(content, text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = C_ACCENT
    btn.Text = text
    btn.TextColor3 = C_BLACK
    btn.TextSize = 13.5
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.LayoutOrder = order
    btn.ZIndex = 6
    btn.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    addShine(btn, 10)
    local wink, ripple = addInteractionFX(btn)
    return btn, wink, ripple
end

local function buildSecondaryButton(content, text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = C_MID
    btn.Text = text
    btn.TextColor3 = C_ACCENT
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.LayoutOrder = order
    btn.ZIndex = 6
    btn.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = C_DIM
    stroke.Thickness = 1
    stroke.Parent = btn

    local wink, ripple = addInteractionFX(btn)
    return btn, wink, ripple
end

local function showExecutorNotice(execName, onDone)
    pcall(function() setclipboard(WEAO_LINK) end)
    showToast("weao.gg copied to clipboard")

    local card, content, scale = createCard(380)

    buildIconBadge(content, "@", Color3.fromRGB(20, 26, 36), C_ACCENT, 1)
    buildTitle(content, "Executor Notice", 2)
    buildSubtitle(content, "Detected: " .. execName, 3)
    buildDivider(content, 4)
    buildBody(content, "This content may not fully support your executor, as it is considered a low-end option. For a smoother experience, we recommend trying a different executor.", 70, 5)

    local linkBtn, linkWink, linkRipple = buildPrimaryButton(content, "  Click Here — Try weao.gg", 6)
    linkBtn.MouseButton1Click:Connect(function()
        task.spawn(linkWink)
        linkRipple()
        pcall(function() setclipboard(WEAO_LINK) end)
        linkBtn.Text = " Copied!"
        task.delay(1.5, function()
            if linkBtn.Parent then
                linkBtn.Text = "  Click Here — Try weao.gg"
            end
        end)
    end)

    local continueBtn, contWink, contRipple = buildSecondaryButton(content, "Continue Anyway", 7)
    continueBtn.MouseButton1Click:Connect(function()
        task.spawn(contWink)
        contRipple()
        dismissCard(card, scale, onDone)
    end)
end

local function showPolicyUI(onDone)
    local card, content, scale = createCard(400)

    buildIconBadge(content, "#", Color3.fromRGB(14, 20, 30), C_WHITE, 1)
    buildTitle(content, "Usage Policy", 2)
    buildSubtitle(content, "Please read before continuing", 3)
    buildDivider(content, 4)
    buildBody(content, "By using PerplexWare products, you accept full responsibility for your own actions. Whatever you do with this script, how you use it, and when you use it, is entirely on you. We provide no guarantees and assume zero liability for damages, account actions, bans, or any other consequences.", 90, 5)
    buildBody(content, "Authorizing with a valid key confirms that you have read, understood, and agreed to these terms.", 36, 6)

    local acceptBtn, acceptWink, acceptRipple = buildPrimaryButton(content, "✓  I Accept — Continue", 7)
    acceptBtn.MouseButton1Click:Connect(function()
        task.spawn(acceptWink)
        acceptRipple()
        acceptPolicy()
        dismissCard(card, scale, onDone)
    end)

    local declineBtn, declineWink, declineRipple = buildSecondaryButton(content, "Decline & Exit", 8)
    declineBtn.MouseButton1Click:Connect(function()
        task.spawn(declineWink)
        declineRipple()
        dismissCard(card, scale, function()
            ScreenGui:Destroy()
        end)
    end)
end

local function showKeyGate()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.53, 0)
    MainFrame.Size = UDim2.new(0, 390, 0, 0)
    MainFrame.AutomaticSize = Enum.AutomaticSize.Y
    MainFrame.BackgroundColor3 = C_DARK
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 5
    MainFrame.Parent = Backdrop
    track(MainFrame, "BackgroundTransparency")

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame

    local CardGradient = Instance.new("UIGradient")
    CardGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 18)),
    })
    CardGradient.Rotation = 115
    CardGradient.Parent = MainFrame

    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Thickness = 1.4
    BorderStroke.Transparency = 0.35
    BorderStroke.Parent = MainFrame
    track(BorderStroke, "Transparency")

    local BorderGradient = Instance.new("UIGradient")
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_ACCENT),
        ColorSequenceKeypoint.new(0.5, C_DIM),
        ColorSequenceKeypoint.new(1, C_WHITE),
    })
    BorderGradient.Parent = BorderStroke

    task.spawn(function()
        while MainFrame.Parent and not closing do
            BorderGradient.Rotation = (BorderGradient.Rotation + 1) % 360
            task.wait(0.04)
        end
    end)

    Scale = Instance.new("UIScale")
    Scale.Scale = 0.9
    Scale.Parent = MainFrame
    TweenService:Create(Scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.AutomaticSize = Enum.AutomaticSize.Y
    Content.BackgroundTransparency = 1
    Content.ZIndex = 6
    Content.Parent = MainFrame

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 28)
    Padding.PaddingBottom = UDim.new(0, 28)
    Padding.PaddingLeft = UDim.new(0, 26)
    Padding.PaddingRight = UDim.new(0, 26)
    Padding.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Vertical
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 14)
    Layout.Parent = Content

    local EyebrowPill = Instance.new("Frame")
    EyebrowPill.Size = UDim2.new(0, 190, 0, 24)
    EyebrowPill.BackgroundColor3 = C_MID
    EyebrowPill.BorderSizePixel = 0
    EyebrowPill.LayoutOrder = 1
    EyebrowPill.ZIndex = 6
    EyebrowPill.Parent = Content
    track(EyebrowPill, "BackgroundTransparency")

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(1, 0)
    PillCorner.Parent = EyebrowPill

    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = C_ACCENT
    PillStroke.Thickness = 1
    PillStroke.Transparency = 0.4
    PillStroke.Parent = EyebrowPill
    track(PillStroke, "Transparency")

    local LiveDot = Instance.new("Frame")
    LiveDot.AnchorPoint = Vector2.new(0, 0.5)
    LiveDot.Position = UDim2.new(0, 14, 0.5, 0)
    LiveDot.Size = UDim2.new(0, 6, 0, 6)
    LiveDot.BackgroundColor3 = C_ACCENT
    LiveDot.BorderSizePixel = 0
    LiveDot.ZIndex = 7
    LiveDot.Parent = EyebrowPill
    track(LiveDot, "BackgroundTransparency")

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = LiveDot

    task.spawn(function()
        while LiveDot.Parent and not closing do
            TweenService:Create(LiveDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.7}):Play()
            task.wait(0.9)
            if closing then break end
            TweenService:Create(LiveDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
            task.wait(0.9)
        end
    end)

    local PillText = Instance.new("TextLabel")
    PillText.Position = UDim2.new(0, 26, 0, 0)
    PillText.Size = UDim2.new(1, -34, 1, 0)
    PillText.BackgroundTransparency = 1
    PillText.Text = "GAIN ACCESS"
    PillText.TextColor3 = C_ACCENT
    PillText.TextSize = 11
    PillText.TextXAlignment = Enum.TextXAlignment.Left
    PillText.Font = Enum.Font.Code
    PillText.ZIndex = 7
    PillText.Parent = EyebrowPill
    track(PillText, "TextTransparency")

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 28)
    Title.BackgroundTransparency = 1
    Title.Text = "Enter Access Key"
    Title.TextColor3 = C_WHITE
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBlack
    Title.LayoutOrder = 2
    Title.ZIndex = 6
    Title.Parent = Content
    track(Title, "TextTransparency")

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, 0, 0, 18)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Verify your key to unlock PerplexWare"
    Subtitle.TextColor3 = C_ACCENT
    Subtitle.TextSize = 13
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.LayoutOrder = 3
    Subtitle.ZIndex = 6
    Subtitle.Parent = Content
    track(Subtitle, "TextTransparency")

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = 4
    Divider.ZIndex = 6
    Divider.Parent = Content
    track(Divider, "BackgroundTransparency")

    local DiscordCTA = Instance.new("TextButton")
    DiscordCTA.Size = UDim2.new(1, 0, 0, 46)
    DiscordCTA.BackgroundColor3 = C_WHITE
    DiscordCTA.Text = "Click Here — To Obtain Discord Link"
    DiscordCTA.TextColor3 = C_BLACK
    DiscordCTA.TextSize = 13.5
    DiscordCTA.Font = Enum.Font.GothamBold
    DiscordCTA.AutoButtonColor = false
    DiscordCTA.BorderSizePixel = 0
    DiscordCTA.ClipsDescendants = true
    DiscordCTA.LayoutOrder = 5
    DiscordCTA.ZIndex = 6
    DiscordCTA.Parent = Content
    track(DiscordCTA, "BackgroundTransparency")
    track(DiscordCTA, "TextTransparency")

    local CTACorner = Instance.new("UICorner")
    CTACorner.CornerRadius = UDim.new(0, 10)
    CTACorner.Parent = DiscordCTA

    local CTAGradient = Instance.new("UIGradient")
    CTAGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C_WHITE),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 228, 245)),
    })
    CTAGradient.Rotation = 90
    CTAGradient.Parent = DiscordCTA

    local CTAStroke = Instance.new("UIStroke")
    CTAStroke.Color = C_ACCENT
    CTAStroke.Thickness = 1
    CTAStroke.Transparency = 0.7
    CTAStroke.Parent = DiscordCTA
    track(CTAStroke, "Transparency")

    task.spawn(function()
        while DiscordCTA.Parent and not closing do
            TweenService:Create(CTAStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.9}):Play()
            task.wait(1)
            if closing then break end
            TweenService:Create(CTAStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0.4}):Play()
            task.wait(1)
        end
    end)

    addShine(DiscordCTA, 10)
    local ctaWink, ctaRipple = addInteractionFX(DiscordCTA)

    local HelperNote = Instance.new("TextLabel")
    HelperNote.Size = UDim2.new(1, 0, 0, 16)
    HelperNote.BackgroundTransparency = 1
    HelperNote.Text = "Then paste your key below"
    HelperNote.TextColor3 = C_DIM
    HelperNote.TextSize = 11.5
    HelperNote.Font = Enum.Font.Gotham
    HelperNote.LayoutOrder = 6
    HelperNote.ZIndex = 6
    HelperNote.Parent = Content
    track(HelperNote, "TextTransparency")

    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(1, 0, 0, 44)
    InputContainer.BackgroundColor3 = C_BLACK
    InputContainer.BorderSizePixel = 0
    InputContainer.ClipsDescendants = true
    InputContainer.LayoutOrder = 7
    InputContainer.ZIndex = 6
    InputContainer.Parent = Content
    track(InputContainer, "BackgroundTransparency")

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputContainer

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(30, 46, 66)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputContainer
    track(InputStroke, "Transparency")

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -28, 1, 0)
    KeyInput.Position = UDim2.new(0, 16, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.PlaceholderText = "Enter your key..."
    KeyInput.PlaceholderColor3 = C_DIM
    KeyInput.Text = ""
    KeyInput.TextColor3 = C_WHITE
    KeyInput.TextSize = 14
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.Font = Enum.Font.GothamMedium
    KeyInput.ClearTextOnFocus = false
    KeyInput.ZIndex = 7
    KeyInput.Parent = InputContainer
    track(KeyInput, "TextTransparency")

    local inputWink, inputRipple = addInteractionFX(InputContainer)

    local SavedBadge = Instance.new("Frame")
    SavedBadge.Size = UDim2.new(1, 0, 0, 26)
    SavedBadge.BackgroundColor3 = Color3.fromRGB(14, 28, 22)
    SavedBadge.BorderSizePixel = 0
    SavedBadge.LayoutOrder = 75
    SavedBadge.ZIndex = 6
    SavedBadge.Visible = false
    SavedBadge.Parent = Content
    track(SavedBadge, "BackgroundTransparency")

    local SavedBadgeCorner = Instance.new("UICorner")
    SavedBadgeCorner.CornerRadius = UDim.new(0, 7)
    SavedBadgeCorner.Parent = SavedBadge

    local SavedBadgeStroke = Instance.new("UIStroke")
    SavedBadgeStroke.Color = Color3.fromRGB(80, 200, 130)
    SavedBadgeStroke.Thickness = 1
    SavedBadgeStroke.Transparency = 0.4
    SavedBadgeStroke.Parent = SavedBadge
    track(SavedBadgeStroke, "Transparency")

    local SavedBadgeLabel = Instance.new("TextLabel")
    SavedBadgeLabel.Size = UDim2.new(1, -12, 1, 0)
    SavedBadgeLabel.Position = UDim2.new(0, 10, 0, 0)
    SavedBadgeLabel.BackgroundTransparency = 1
    SavedBadgeLabel.Text = "✓  Saved key loaded — auto-verifying..."
    SavedBadgeLabel.TextColor3 = Color3.fromRGB(120, 210, 160)
    SavedBadgeLabel.TextSize = 11.5
    SavedBadgeLabel.TextXAlignment = Enum.TextXAlignment.Left
    SavedBadgeLabel.Font = Enum.Font.GothamMedium
    SavedBadgeLabel.ZIndex = 7
    SavedBadgeLabel.Parent = SavedBadge
    track(SavedBadgeLabel, "TextTransparency")

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 16)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = C_ACCENT
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.LayoutOrder = 8
    StatusLabel.ZIndex = 6
    StatusLabel.Parent = Content
    track(StatusLabel, "TextTransparency")

    local savedKey = loadSavedKey()
    if savedKey then
        KeyInput.Text = savedKey
        SavedBadge.Visible = true
    end

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(1, 0, 0, 48)
    SubmitBtn.BackgroundColor3 = C_ACCENT
    SubmitBtn.Text = "UNLOCK ACCESS"
    SubmitBtn.TextColor3 = C_BLACK
    SubmitBtn.TextSize = 15
    SubmitBtn.Font = Enum.Font.GothamBlack
    SubmitBtn.AutoButtonColor = false
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.ClipsDescendants = true
    SubmitBtn.LayoutOrder = 9
    SubmitBtn.ZIndex = 6
    SubmitBtn.Parent = Content
    track(SubmitBtn, "BackgroundTransparency")
    track(SubmitBtn, "TextTransparency")

    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 10)
    SubmitCorner.Parent = SubmitBtn

    local SubmitGradient = Instance.new("UIGradient")
    SubmitGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 230, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 185, 235)),
    })
    SubmitGradient.Rotation = 120
    SubmitGradient.Parent = SubmitBtn

    local SubmitStroke = Instance.new("UIStroke")
    SubmitStroke.Color = C_WHITE
    SubmitStroke.Thickness = 1.5
    SubmitStroke.Transparency = 0.5
    SubmitStroke.Parent = SubmitBtn
    track(SubmitStroke, "Transparency")

    local submitGlow = Instance.new("Frame")
    submitGlow.Size = UDim2.new(1, 16, 1, 16)
    submitGlow.Position = UDim2.new(0, -8, 0, -8)
    submitGlow.BackgroundColor3 = C_ACCENT
    submitGlow.BackgroundTransparency = 0.72
    submitGlow.BorderSizePixel = 0
    submitGlow.ZIndex = SubmitBtn.ZIndex - 1
    submitGlow.Parent = SubmitBtn

    local submitGlowCorner = Instance.new("UICorner")
    submitGlowCorner.CornerRadius = UDim.new(0, 14)
    submitGlowCorner.Parent = submitGlow

    task.spawn(function()
        while submitGlow.Parent and not closing do
            TweenService:Create(submitGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.84}):Play()
            task.wait(1.2)
            if closing then break end
            TweenService:Create(submitGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.62}):Play()
            task.wait(1.2)
        end
    end)

    addShine(SubmitBtn, 10)
    local submitWink, submitRipple = addInteractionFX(SubmitBtn)

    SubmitBtn.MouseEnter:Connect(function()
        if closing then return end
        TweenService:Create(SubmitBtn, TweenInfo.new(0.15), {BackgroundColor3 = C_WHITE}):Play()
    end)
    SubmitBtn.MouseLeave:Connect(function()
        if closing then return end
        TweenService:Create(SubmitBtn, TweenInfo.new(0.15), {BackgroundColor3 = C_ACCENT}):Play()
    end)

    DiscordCTA.MouseEnter:Connect(function()
        if closing then return end
        TweenService:Create(DiscordCTA, TweenInfo.new(0.15), {BackgroundColor3 = C_ACCENT}):Play()
    end)
    DiscordCTA.MouseLeave:Connect(function()
        if closing then return end
        TweenService:Create(DiscordCTA, TweenInfo.new(0.15), {BackgroundColor3 = C_WHITE}):Play()
    end)

    KeyInput.Focused:Connect(function()
        if closing then return end
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = C_ACCENT}):Play()
        task.spawn(inputWink)
        inputRipple()
    end)

    local function playSuccessAndLoad()
        TweenService:Create(Scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 1.22}):Play()

        task.delay(0.18, function()
            local splash = Instance.new("Frame")
            splash.AnchorPoint = Vector2.new(0.5, 0.5)
            splash.Position = UDim2.new(0.5, 0, 0.5, 0)
            splash.Size = UDim2.new(0, 10, 0, 10)
            splash.BackgroundColor3 = C_ACCENT
            splash.BackgroundTransparency = 0.05
            splash.BorderSizePixel = 0
            splash.ZIndex = 50
            splash.Parent = Backdrop

            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(1, 0)
            sc.Parent = splash

            TweenService:Create(splash, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(3, 0, 3, 0),
                BackgroundTransparency = 0.5,
            }):Play()

            task.delay(0.25, function()
                local ring = Instance.new("Frame")
                ring.AnchorPoint = Vector2.new(0.5, 0.5)
                ring.Position = UDim2.new(0.5, 0, 0.5, 0)
                ring.Size = UDim2.new(0, 30, 0, 30)
                ring.BackgroundTransparency = 1
                ring.ZIndex = 51
                ring.Parent = Backdrop

                local ringCorner = Instance.new("UICorner")
                ringCorner.CornerRadius = UDim.new(1, 0)
                ringCorner.Parent = ring

                local ringStroke = Instance.new("UIStroke")
                ringStroke.Color = C_WHITE
                ringStroke.Thickness = 3
                ringStroke.Transparency = 0
                ringStroke.Parent = ring

                TweenService:Create(ring, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(4, 0, 4, 0),
                }):Play()
                TweenService:Create(ringStroke, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Transparency = 1,
                }):Play()
                task.delay(0.6, function()
                    if ring then ring:Destroy() end
                end)
            end)

            task.delay(0.45, function()
                closing = true

                local countLabel = Instance.new("TextLabel")
                countLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                countLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                countLabel.Size = UDim2.new(0, 300, 0, 60)
                countLabel.BackgroundTransparency = 1
                countLabel.Text = "Loading in 3..."
                countLabel.TextColor3 = C_ACCENT
                countLabel.TextSize = 22
                countLabel.Font = Enum.Font.GothamBlack
                countLabel.ZIndex = 60
                countLabel.Parent = Backdrop

                TweenService:Create(countLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextTransparency = 0,
                }):Play()

                fadeEverything(0.6)
                TweenService:Create(splash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

                task.wait(1)
                countLabel.Text = "Loading in 2..."
                task.wait(1)
                countLabel.Text = "Loading in 1..."
                task.wait(1)

                TweenService:Create(countLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                task.delay(0.32, function()
                    ScreenGui:Destroy()
                    keyValidated = true
                    keyValidEvent:Fire()
                end)
            end)
        end)
    end

    local verifying = false
    local attemptSubmit

    local function setVerifying(state)
        verifying = state
        KeyInput.TextEditable = not state
        SubmitBtn.Text = state and "VERIFYING..." or "UNLOCK ACCESS"
    end

    local function shakeInput()
        local origPos = InputContainer.Position
        for i = 1, 5 do
            TweenService:Create(InputContainer, TweenInfo.new(0.04), {
                Position = origPos + UDim2.new(0, (i % 2 == 0 and 7 or -7), 0, 0),
            }):Play()
            task.wait(0.04)
        end
        TweenService:Create(InputContainer, TweenInfo.new(0.06, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = origPos}):Play()
    end

    local function flashInvalidBorder()
        for i = 1, 3 do
            TweenService:Create(InputStroke, TweenInfo.new(0.08), {Color = Color3.fromRGB(220, 80, 90)}):Play()
            task.wait(0.12)
            TweenService:Create(InputStroke, TweenInfo.new(0.08), {Color = Color3.fromRGB(100, 30, 40)}):Play()
            task.wait(0.12)
        end
        task.delay(0.8, function()
            if not verifying and not closing then
                TweenService:Create(InputStroke, TweenInfo.new(0.25), {Color = Color3.fromRGB(30, 46, 66)}):Play()
            end
        end)
    end

    attemptSubmit = function()
        if verifying or closing then return end

        local entered = trim(KeyInput.Text)
        if entered == "" then
            StatusLabel.Text = "Please enter a key first."
            StatusLabel.TextColor3 = Color3.fromRGB(220, 120, 130)
            return
        end

        setVerifying(true)
        StatusLabel.Text = "Checking key..."
        StatusLabel.TextColor3 = C_ACCENT

        task.wait(0.4)
        if closing then return end

        if entered == VALID_KEY then
            saveKey(entered)
            StatusLabel.Text = "Access granted. Loading..."
            StatusLabel.TextColor3 = Color3.fromRGB(140, 220, 170)
            SubmitBtn.Text = "✓  SUCCESS"
            SubmitBtn.TextColor3 = C_BLACK
            TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 220, 190)}):Play()
            playSuccessAndLoad()
        else
            setVerifying(false)
            if SavedBadge.Visible then
                SavedBadgeLabel.Text = "⚠  Saved key is outdated — enter a new one"
                SavedBadgeLabel.TextColor3 = Color3.fromRGB(230, 160, 80)
                SavedBadgeStroke.Color = Color3.fromRGB(200, 130, 50)
                SavedBadge.BackgroundColor3 = Color3.fromRGB(28, 20, 10)
            end
            StatusLabel.Text = "Invalid key. Check Discord for the latest one."
            StatusLabel.TextColor3 = Color3.fromRGB(220, 100, 110)
            shakeInput()
            task.spawn(flashInvalidBorder)
        end
    end

    KeyInput.FocusLost:Connect(function(enterPressed)
        if closing then return end
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(30, 46, 66)}):Play()
        if enterPressed then
            attemptSubmit()
        end
    end)

    if savedKey then
        task.delay(0.7, function()
            if not closing then
                attemptSubmit()
            end
        end)
    end

    SubmitBtn.MouseButton1Click:Connect(function()
        if closing then return end
        task.spawn(submitWink)
        submitRipple()
        attemptSubmit()
    end)

    DiscordCTA.MouseButton1Click:Connect(function()
        if closing then return end
        task.spawn(ctaWink)
        ctaRipple()
        pcall(function() setclipboard(DISCORD_LINK) end)
        DiscordCTA.Text = "Copied! Open Discord now"
        task.delay(2, function()
            if DiscordCTA.Parent and not closing then
                DiscordCTA.Text = "Click Here — To Obtain Discord Link"
            end
        end)
    end)
end

local function startGate()
    local function checkPolicyThenGate()
        if hasAcceptedPolicy() then
            showKeyGate()
        else
            showPolicyUI(showKeyGate)
        end
    end

    if isBlockedExecutor(DetectedExecutor) then
        showExecutorNotice(DetectedExecutor, checkPolicyThenGate)
    else
        checkPolicyThenGate()
    end
end

startGate()

keyValidEvent.Event:Wait()
keyValidEvent:Destroy()

-- Paste your script below here
