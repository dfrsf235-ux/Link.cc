task.wait(2.6)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function toVector2(pos)
    if typeof(pos) == "Vector2" then
        return pos
    elseif typeof(pos) == "Vector3" then
        return Vector2.new(pos.X, pos.Y)
    else
        return Vector2.new(0,0)
    end
end

local function safeGetMouseLocation()
    local ok, res = pcall(function() return UserInputService:GetMouseLocation() end)
    if ok and typeof(res) == "Vector2" then
        return res
    end
    return Vector2.new(0,0)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeleeAutoAttack"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 99999
ScreenGui.Parent = CoreGui

local function enforceTopMost()
    local desired = 99999
    while true do
        if not ScreenGui or ScreenGui.Parent ~= CoreGui then
            pcall(function() ScreenGui.Parent = CoreGui end)
        end
        if ScreenGui.DisplayOrder ~= desired then
            pcall(function() ScreenGui.DisplayOrder = desired end)
        end
        if ScreenGui.ZIndexBehavior ~= Enum.ZIndexBehavior.Global then
            pcall(function() ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global end)
        end
        if ScreenGui.Enabled == false then
            pcall(function() ScreenGui.Enabled = true end)
        end
        task.wait(0.4)
    end
end
task.spawn(enforceTopMost)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,320,0,360)
MainFrame.Position = UDim2.new(0.02,0,0.12,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255,245,250)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
local mainUICorner = Instance.new("UICorner", MainFrame)
mainUICorner.CornerRadius = UDim.new(0,12)

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,48)
TitleBar.BackgroundColor3 = Color3.fromRGB(255,240,245)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local titleUICorner = Instance.new("UICorner", TitleBar)
titleUICorner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0,150,1,0)
Title.BackgroundTransparency = 1
Title.Text = "Link.cc"
Title.TextColor3 = Color3.fromRGB(120,28,110)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TitleBar
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0,12,0,0)
Title.AnchorPoint = Vector2.new(0,0)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSLabel"
FPSLabel.Size = UDim2.new(0,220,1,0)
FPSLabel.Position = UDim2.new(0.5,0,0,0)
FPSLabel.AnchorPoint = Vector2.new(0.5,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: -- | Ping: -- ms"
FPSLabel.TextColor3 = Color3.fromRGB(120,28,110)
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextSize = 14
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Parent = TitleBar
FPSLabel.ZIndex = Title.ZIndex + 2

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Name = "CollapseBtn"
CollapseBtn.Size = UDim2.new(0,32,0,32)
CollapseBtn.Position = UDim2.new(1,-40,0,8)
CollapseBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
CollapseBtn.BorderSizePixel = 0
CollapseBtn.Text = "—"
CollapseBtn.TextColor3 = Color3.fromRGB(120,28,110)
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 20
CollapseBtn.Parent = TitleBar
local collapseUICorner = Instance.new("UICorner", CollapseBtn)
collapseUICorner.CornerRadius = UDim.new(0,8)

local ContentScroller = Instance.new("ScrollingFrame")
ContentScroller.Name = "ContentScroller"
ContentScroller.Size = UDim2.new(1,-20,1,-76)
ContentScroller.Position = UDim2.new(0,10,0,56)
ContentScroller.BackgroundTransparency = 1
ContentScroller.Parent = MainFrame
ContentScroller.ScrollBarThickness = 8

if ContentScroller:IsA("ScrollingFrame") then
    pcall(function() ContentScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
    pcall(function() ContentScroller.ScrollBarImageColor3 = Color3.fromRGB(255,100,170) end)
    pcall(function() ContentScroller.HorizontalScrollBarEnabled = false end)
    pcall(function() ContentScroller.ClipsDescendants = true end)
end

local uiPadding = Instance.new("UIPadding", ContentScroller)
uiPadding.PaddingLeft = UDim.new(0,6)
uiPadding.PaddingRight = UDim.new(0,6)
uiPadding.PaddingTop = UDim.new(0,6)
uiPadding.PaddingBottom = UDim.new(0,6)

local uiList = Instance.new("UIListLayout", ContentScroller)
uiList.Padding = UDim.new(0,8)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local absY = uiList.AbsoluteContentSize.Y
    if ContentScroller:IsA("ScrollingFrame") then
        ContentScroller.CanvasSize = UDim2.new(0,0,0,absY + 12)
    end
end)

local function createInfoLabel(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,-12,0,22)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentScroller
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160,80,200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return label, frame
end

local InfoLabel, _ = createInfoLabel("状态：未启用")
local WeaponCheckLabel, _ = createInfoLabel("手持武器检测：无目标武器")
local WhitelistLabel, _ = createInfoLabel("白名单：无")

local function createSwitch(labelText, initial)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-12,0,54)
    container.BackgroundTransparency = 1
    container.Parent = ContentScroller

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-100,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(90,30,90)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,48,0,28)
    sw.Position = UDim2.new(1,-64,0,13)
    sw.BackgroundColor3 = Color3.fromRGB(240,240,240)
    sw.Parent = container
    local swCorner = Instance.new("UICorner", sw)
    swCorner.CornerRadius = UDim.new(0,14)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0,26,0,26)
    knob.Position = UDim2.new(0,2,0,1)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = sw
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0,14)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1,0,1,0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = container

    local state = initial or false
    local function updateVisual(immediate)
        local tweenTime = immediate and 0 or 0.16
        if state then
            TweenService:Create(sw, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255,100,170)}):Play()
            TweenService:Create(knob, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1,-28,0,1)}):Play()
        else
            TweenService:Create(sw, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(240,240,240)}):Play()
            TweenService:Create(knob, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,2,0,1)}):Play()
        end
    end
    updateVisual(true)

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        updateVisual(false)
    end)

    return {
        Container = container,
        Get = function() return state end,
        Set = function(v) state = v updateVisual(false) end,
        Label = label,
    }
end

local function createSlider(labelText, minVal, maxVal, initial)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-12,0,70)
    container.BackgroundTransparency = 1
    container.Parent = ContentScroller

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-100,0,18)
    label.Position = UDim2.new(0,12,0,2)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(90,30,90)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0,90,0,18)
    valueLabel.Position = UDim2.new(1,-88,0,2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(initial)
    valueLabel.TextColor3 = Color3.fromRGB(90,30,90)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-140,0,12)
    track.Position = UDim2.new(0,12,0,32)
    track.BackgroundColor3 = Color3.fromRGB(250,240,248)
    track.Parent = container
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(0,8)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.Position = UDim2.new(0,0,0,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,100,170)
    fill.Parent = track
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0,8)

    local knob = Instance.new("ImageButton")
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(0,-9,0,-3)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Parent = track
    knob.Image = ""
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0,9)

    local dragging = false
    local value = initial or minVal

    local function setVisualFromValue()
        local ratio = 0
        if maxVal > minVal then
            ratio = (value - minVal) / (maxVal - minVal)
            ratio = math.clamp(ratio,0,1)
        end
        fill.Size = UDim2.new(ratio,0,1,0)
        local trackX = track.AbsoluteSize.X
        if trackX <= 0 then return end
        local knobX = math.clamp(ratio * trackX - knob.AbsoluteSize.X/2, -knob.AbsoluteSize.X/2, trackX - knob.AbsoluteSize.X/2)
        knob.Position = UDim2.new(0, knobX, 0, knob.Position.Y.Offset)
        valueLabel.Text = string.format("%.2f", value)
    end

    local function setValueFromAbsoluteX(x)
        local ok, trackPos = pcall(function() return track.AbsolutePosition.X end)
        local ok2, trackSize = pcall(function() return track.AbsoluteSize.X end)
        if not ok or not ok2 or trackSize <= 0 then return end
        local relative = (x - trackPos) / trackSize
        relative = math.clamp(relative, 0, 1)
        value = minVal + relative * (maxVal - minVal)
        value = math.floor(value * 100 + 0.5) / 100
        setVisualFromValue()
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            pcall(function() ContentScroller.ScrollingEnabled = false end)
        end
    end)
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            pcall(function() ContentScroller.ScrollingEnabled = true end)
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pcall(function() ContentScroller.ScrollingEnabled = false end)
            local pos = safeGetMouseLocation()
            setValueFromAbsoluteX(pos.X)
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            pcall(function() ContentScroller.ScrollingEnabled = true end)
        end
    end)

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = safeGetMouseLocation()
            pcall(function() setValueFromAbsoluteX(pos.X) end)
        end
    end)

    task.delay(0.06, function()
        setVisualFromValue()
    end)

    return {
        Container = container,
        Get = function() return value end,
        Set = function(v) value = math.clamp(v, minVal, maxVal) value = math.floor(value * 100 + 0.5) / 100 setVisualFromValue() end,
        Label = label,
        ValueLabel = valueLabel,
    }
end

local whitelist = {}
local whitelistButtons = {}

local function isWhitelisted(plr)
    if not plr then return false end
    return whitelist[plr.UserId] == true
end

local function createWhitelistSection()
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,-12,0,110)
    container.BackgroundTransparency = 1
    container.Parent = ContentScroller

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,18)
    title.Position = UDim2.new(0,6,0,0)
    title.BackgroundTransparency = 1
    title.Text = "白名单"
    title.TextColor3 = Color3.fromRGB(80,30,120)
    title.Font = Enum.Font.Gotham
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1,0,1,-22)
    listFrame.Position = UDim2.new(0,0,0,22)
    listFrame.BackgroundTransparency = 1
    listFrame.Parent = container

    local listScroller = Instance.new("ScrollingFrame")
    listScroller.Size = UDim2.new(1,0,1,0)
    listScroller.BackgroundTransparency = 1
    listScroller.ScrollBarThickness = 6
    listScroller.Parent = listFrame
    listScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroller.ClipsDescendants = true

    local listLayout = Instance.new("UIListLayout", listScroller)
    listLayout.Padding = UDim.new(0,6)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makePlayerButton(plr)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-12,0,26)
        btn.BackgroundColor3 = Color3.fromRGB(245,240,247)
        btn.BorderSizePixel = 0
        btn.Text = plr.Name .. " (" .. tostring(plr.UserId) .. ")"
        btn.TextColor3 = Color3.fromRGB(80,30,120)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = listScroller
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0,8)

        local function updateVisual()
            if isWhitelisted(plr) then
                btn.BackgroundColor3 = Color3.fromRGB(255,220,235)
                btn.TextColor3 = Color3.fromRGB(160,40,140)
            else
                btn.BackgroundColor3 = Color3.fromRGB(245,240,247)
                btn.TextColor3 = Color3.fromRGB(80,30,120)
            end
        end

        btn.MouseButton1Click:Connect(function()
            local uid = plr.UserId
            if whitelist[uid] then
                whitelist[uid] = nil
            else
                whitelist[uid] = true
            end
            updateVisual()
            local names = {}
            for id,_ in pairs(whitelist) do
                local p = Players:GetPlayerByUserId(id)
                if p then table.insert(names, p.Name) end
            end
            if #names == 0 then
                WhitelistLabel.Text = "白名单：无"
            else
                WhitelistLabel.Text = "白名单：" .. table.concat(names, "，")
            end
        end)

        whitelistButtons[plr.UserId] = btn
        updateVisual()
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            makePlayerButton(plr)
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        task.delay(0.05, function()
            makePlayerButton(plr)
        end)
    end)
    Players.PlayerRemoving:Connect(function(plr)
        local btn = whitelistButtons[plr.UserId]
        if btn then
            pcall(function() btn:Destroy() end)
            whitelistButtons[plr.UserId] = nil
        end
        whitelist[plr.UserId] = nil
        local names = {}
        for id,_ in pairs(whitelist) do
            local p = Players:GetPlayerByUserId(id)
            if p then table.insert(names, p.Name) end
        end
        if #names == 0 then
            WhitelistLabel.Text = "白名单：无"
        else
            WhitelistLabel.Text = "白名单：" .. table.concat(names, "，")
        end
    end)
end

createWhitelistSection()

local AlwaysHeadSwitch = createSwitch("始终攻击头部", false)
local AutoSwitch = createSwitch("杀戮光环", false)
local SilentSwitch = createSwitch("静默转向", false)
local TeamCheckSwitch = createSwitch("队伍检查", false)
local UseNativeSpeedSwitch = createSwitch("使用武器原生攻击速度", false)

local RangeSlider = createSlider("攻击距离", 0, 14, 14)
local SilentRangeSlider = createSlider("静默转向触发范围", 0, 20, 10)
local MultiTargetSlider = createSlider("同时攻击目标数", 1, 3, 1)
local CooldownSlider = createSlider("攻击冷却", 0.5, 5, 0.5)
local SilentCooldownSlider = createSlider("静默转向冷却", 0, 5, 0)

local SendDelaySlider = createSlider("命中发送延迟", 0, 1, 0)

local LatencyCompSwitch = createSwitch("延迟补偿 (根据Ping调整)", false)
local LatencyFactorSlider = createSlider("延迟补偿系数", 0.1, 3, 1.0)

local autoAttack = false
local silentAim = false
local teamCheck = false
local alwaysHead = false
local useNativeSpeed = false
local attackRange = 14
local attackCoolDown = 0.5
local maxTargets = 1
local silentRange = 10
local silentCooldown = 0

local hitFlushInterval = 0

local latencyCompEnabled = false
local latencyFactor = 1.0

local weaponList = {"Metal Shard","Stunstick","Riot Control","Door & Glass Shard","Glass Fragment", "Fireaxe"}
local character, rootPart
local lastAttackTime = 0
local lastSilentTime = 0

local lockedTargets = nil
local attackLockExpire = 0

local aimTarget = nil

local weaponHooks = {}
local weaponInfo = {}
local currentHookedTool = nil

local ToolSoundEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ToolSound")
local ServiceFolder = ReplicatedStorage:WaitForChild("Service")
local NamespaceModule = require(ServiceFolder:WaitForChild("Namespaces"))
local MeleeSendHit = NamespaceModule.MeleeReplication.packets.sendHit.send

local meleeWeaponConfig = {
    ["Glass Fragment"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Equip",
        Sound2 = "Swing"
    },
    ["Glass Shard"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Plan",
        Sound2 = "Commit"
    },
    ["ShadowInfernoBlock20"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Plan",
        Sound2 = "Commit"
    },
    ["Door & Glass Shard"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Plan",
        Sound2 = "Commit"
    },
    ["Metal Shard"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Plan",
        Sound2 = "Commit"
    },
    ["Fireaxe"] = {
        SwingCooldownAttribute = "SwingCooldown",
        Sound1 = "Equip",
        Sound2 = "Swing"
    }
}

local function GetMeleeWeaponCooldown(tool)
    if not tool then return 0.5 end
    local cfg = meleeWeaponConfig[tool.Name]
    if cfg then
        local raw = nil
        pcall(function() raw = tool:GetAttribute(cfg.SwingCooldownAttribute) end)
        if raw then
            local val = tonumber(raw)
            if val and val > 0 then
                return val
            end
        end
        local primary = tool:FindFirstChild("Primary")
        if primary then
            local fallback = nil
            pcall(function() fallback = primary:GetAttribute(cfg.SwingCooldownAttribute) end)
            if fallback then
                local fval = tonumber(fallback)
                if fval and fval > 0 then
                    return fval
                end
            end
        end
    end
    local tryVals = {}
    pcall(function()
        local a = tool:GetAttribute("SwingCooldown")
        if a then table.insert(tryVals, tonumber(a)) end
    end)
    if weaponInfo[tool] and weaponInfo[tool].swing then
        table.insert(tryVals, tonumber(weaponInfo[tool].swing))
    end
    for _, v in ipairs(tryVals) do
        if v and type(v) == "number" and v > 0 then
            return v
        end
    end
    return 0.5
end

local function FireMeleeWeaponSound(tool)
    if not tool then return end
    local cfg = meleeWeaponConfig[tool.Name]
    if not cfg then return end
    pcall(function() ToolSoundEvent:FireServer(tool, cfg.Sound1) end)
    task.wait(0.025)
    pcall(function() ToolSoundEvent:FireServer(tool, cfg.Sound2) end)
end

local function refreshChar(char)
    character = char
    rootPart = character and character:WaitForChild("HumanoidRootPart")
end
if LocalPlayer.Character then
    task.spawn(refreshChar, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(refreshChar)

local function unhookWeapon(tool)
    if not tool then return end
    local conns = weaponHooks[tool]
    if conns then
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
    end
    weaponHooks[tool] = nil
    weaponInfo[tool] = nil
    if currentHookedTool == tool then currentHookedTool = nil end
end

local function hookWeapon(tool)
    if not tool or not tool:IsA("Tool") then return end
    if weaponHooks[tool] then return end
    local conns = {}
    weaponInfo[tool] = weaponInfo[tool] or {}
    weaponInfo[tool].name = tool.Name
    pcall(function()
        local swing = tool:GetAttribute("SwingCooldown")
        local pull = tool:GetAttribute("PulloutTime")
        local anim = tool:GetAttribute("AnimationAttack")
        weaponInfo[tool].swing = tonumber(swing) or weaponInfo[tool].swing
        weaponInfo[tool].pull = tonumber(pull) or weaponInfo[tool].pull
        weaponInfo[tool].anim = tostring(anim) ~= "nil" and tostring(anim) or weaponInfo[tool].anim
    end)
    table.insert(conns, tool.Equipped:Connect(function()
        weaponInfo[tool].equipped = true
        WeaponCheckLabel.Text = "手持武器检测："..tostring(tool.Name)
    end))
    table.insert(conns, tool.Unequipped:Connect(function()
        weaponInfo[tool].equipped = false
        WeaponCheckLabel.Text = "手持武器检测：无目标武器"
    end))
    table.insert(conns, tool.Activated:Connect(function()
        weaponInfo[tool].lastManual = os.clock()
    end))
    if tool.GetAttribute and tool.AttributeChanged then
        table.insert(conns, tool.AttributeChanged:Connect(function(attr)
            pcall(function()
                if attr == "SwingCooldown" then
                    local v = tonumber(tool:GetAttribute("SwingCooldown"))
                    weaponInfo[tool].swing = v
                elseif attr == "PulloutTime" then
                    local v = tonumber(tool:GetAttribute("PulloutTime"))
                    weaponInfo[tool].pull = v
                elseif attr == "AnimationAttack" then
                    weaponInfo[tool].anim = tostring(tool:GetAttribute("AnimationAttack"))
                end
            end)
        end))
    end
    table.insert(conns, tool.AncestryChanged:Connect(function(child, parent)
        if not tool:IsDescendantOf(game) then
            unhookWeapon(tool)
        end
    end))
    weaponHooks[tool] = conns
    currentHookedTool = tool
end

spawn(function()
    local prevTool = nil
    while true do
        local held = nil
        if LocalPlayer.Character then
            held = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not held then
                for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
                    if obj and obj:IsA("Tool") then
                        held = obj
                        break
                    end
                end
            end
        end
        if held ~= prevTool then
            if prevTool then
                pcall(unhookWeapon, prevTool)
            end
            if held then
                pcall(hookWeapon, held)
            end
            prevTool = held
        end
        task.wait(0.12)
    end
end)

local function hookAllTools()
    if LocalPlayer.Character then
        for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
            if obj and obj:IsA("Tool") then
                pcall(function()
                    if isMeleeTool(obj) then hookWeapon(obj) end
                end)
            end
        end
    end
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if obj and obj:IsA("Tool") then
                pcall(function()
                    if isMeleeTool(obj) then hookWeapon(obj) end
                end)
            end
        end
        LocalPlayer.Backpack.ChildAdded:Connect(function(child)
            task.delay(0.05, function()
                if child and child:IsA("Tool") then
                    pcall(function() if isMeleeTool(child) then hookWeapon(child) end end)
                end
            end)
        end)
    end
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            task.delay(0.05, function()
                if child and child:IsA("Tool") then
                    pcall(function() if isMeleeTool(child) then hookWeapon(child) end end)
                end
            end)
        end)
    end
end

task.spawn(function()
    task.wait(0.05)
    pcall(hookAllTools)
end)

spawn(function()
    local prev = AutoSwitch.Get()
    while true do
        local cur = AutoSwitch.Get()
        if cur ~= prev then
            prev = cur
            autoAttack = cur
            InfoLabel.Text = autoAttack and "状态：运行中" or "状态：未启用"
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = SilentSwitch.Get()
    while true do
        local cur = SilentSwitch.Get()
        if cur ~= prev then
            prev = cur
            silentAim = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = TeamCheckSwitch.Get()
    while true do
        local cur = TeamCheckSwitch.Get()
        if cur ~= prev then
            prev = cur
            teamCheck = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = AlwaysHeadSwitch.Get()
    while true do
        local cur = AlwaysHeadSwitch.Get()
        if cur ~= prev then
            prev = cur
            alwaysHead = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = UseNativeSpeedSwitch.Get()
    while true do
        local cur = UseNativeSpeedSwitch.Get()
        if cur ~= prev then
            prev = cur
            useNativeSpeed = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = LatencyCompSwitch.Get()
    while true do
        local cur = LatencyCompSwitch.Get()
        if cur ~= prev then
            prev = cur
            latencyCompEnabled = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    local prev = LatencyFactorSlider.Get()
    while true do
        local cur = LatencyFactorSlider.Get()
        if cur ~= prev then
            prev = cur
            latencyFactor = cur
        end
        task.wait(0.12)
    end
end)

spawn(function()
    while true do
        local r = RangeSlider.Get() or 14
        if r > 14 then r = 14 end
        attackRange = math.floor(r * 100 + 0.5) / 100
        RangeSlider.ValueLabel.Text = string.format("%.2f 米", attackRange)

        local cd = CooldownSlider.Get() or 0.5
        if cd < 0.5 then cd = 0.5 end
        attackCoolDown = math.floor(cd * 100 + 0.5) / 100
        CooldownSlider.ValueLabel.Text = string.format("%.2f s", attackCoolDown)

        local mt = MultiTargetSlider.Get() or 1
        mt = math.clamp(math.floor(mt+0.5), 1, 3)
        maxTargets = mt
        MultiTargetSlider.ValueLabel.Text = tostring(maxTargets)

        local sr = SilentRangeSlider.Get() or 10
        silentRange = math.floor(sr * 100 + 0.5) / 100
        SilentRangeSlider.ValueLabel.Text = string.format("%.2f 米", silentRange)

        local sc = SilentCooldownSlider.Get() or 0
        silentCooldown = math.floor(sc * 100 + 0.5) / 100
        SilentCooldownSlider.ValueLabel.Text = string.format("%.2f s", silentCooldown)

        local sendDelay = SendDelaySlider.Get() or 0
        sendDelay = math.clamp(sendDelay, 0, 1)
        local baseSendDelay = math.floor(sendDelay * 100 + 0.5) / 100

        local pingSec = 0
        local ok, res = pcall(function()
            if LocalPlayer and LocalPlayer.GetNetworkPing then
                return LocalPlayer:GetNetworkPing()
            end
            return nil
        end)
        if ok and type(res) == "number" then
            pingSec = res
        end

        if latencyCompEnabled and pingSec and pingSec > 0 then
            hitFlushInterval = math.max(baseSendDelay, pingSec * latencyFactor)
        else
            hitFlushInterval = baseSendDelay
        end
        SendDelaySlider.ValueLabel.Text = string.format("%.2f s", hitFlushInterval)

        task.wait(0.12)
    end
end)

local function isMeleeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Handle") or tool:FindFirstChild("Grip") or tool:FindFirstChild("Primary") or tool:FindFirstChild("Controller") then
        return true
    end
    local attrs = {"MeleeIcon","SwingCooldown","AnimationAttack","AnimationEquip","PulloutTime","RegisterOnce","CustomHitbox"}
    for _, a in ipairs(attrs) do
        if tool:GetAttribute(a) ~= nil then
            return true
        end
    end
    for _, name in ipairs(weaponList) do
        local tname = tostring(tool.Name or "")
        if string.lower(tname) == string.lower(name) or string.find(string.lower(tname), string.lower(name), 1, true) then
            return true
        end
    end
    return false
end

local function getHeldWeapon()
    if not LocalPlayer.Character then return nil end
    local char = LocalPlayer.Character
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and isMeleeTool(tool) then
        return tool
    end
    for _, obj in ipairs(char:GetChildren()) do
        if obj and obj:IsA("Tool") and isMeleeTool(obj) then
            return obj
        end
    end
    return nil
end

local function hasLineOfSight(attackerRoot, targetPart)
    if not attackerRoot or not targetPart then return false end
    local dir = targetPart.Position - attackerRoot.Position
    if dir.Magnitude <= 0 then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    if character then
        params.FilterDescendantsInstances = {character}
    else
        params.FilterDescendantsInstances = {}
    end
    local ray = workspace:Raycast(attackerRoot.Position, dir, params)
    if not ray then
        return true
    end
    local hitInst = ray.Instance
    if hitInst and hitInst:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function findTargetLimb(char, preferHead)
    if preferHead then
        local head = char:FindFirstChild("Head") or char:FindFirstChild("head")
        if head then
            return head
        end
    end
    local limb = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand") or char:FindFirstChild("RightLowerArm") or char:FindFirstChild("RightUpperArm")
    if not limb then
        limb = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    end
    if not limb then
        limb = char:FindFirstChild("Head") or char:FindFirstChild("head")
    end
    return limb
end

local function collectTargets(maxCount, maxRange)
    if not rootPart then return {} end
    local results = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if isWhitelisted(plr) then
            else
                local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local tarHum = plr.Character:FindFirstChild("Humanoid")
                if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
                    if teamCheck then
                        if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
                        else
                            local dis = (rootPart.Position - tarRoot.Position).Magnitude
                            if dis <= maxRange then
                                local limb = findTargetLimb(plr.Character, true)
                                if limb and hasLineOfSight(rootPart, limb) then
                                    local score = dis
                                    local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head")
                                    if head and hasLineOfSight(rootPart, head) then
                                        score = score - 3.0
                                    end
                                    if tarHum.Health and tarHum.MaxHealth and tarHum.Health < (tarHum.MaxHealth * 0.5) then
                                        score = score - 2.0
                                    end
                                    local toTarget = (tarRoot.Position - rootPart.Position)
                                    if toTarget.Magnitude > 0 then
                                        local dir = toTarget.Unit
                                        local forward = rootPart.CFrame.LookVector
                                        local dot = forward:Dot(dir)
                                        if dot and dot > 0.5 then
                                            score = score - 1.5
                                        end
                                    end
                                    if aimTarget and aimTarget == plr then
                                        score = score - 4.0
                                    end
                                    table.insert(results, {plr=plr, dist=dis, score=score})
                                end
                            end
                        end
                    else
                        local dis = (rootPart.Position - tarRoot.Position).Magnitude
                        if dis <= maxRange then
                            local limb = findTargetLimb(plr.Character, true)
                            if limb and hasLineOfSight(rootPart, limb) then
                                local score = dis
                                local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head")
                                if head and hasLineOfSight(rootPart, head) then
                                    score = score - 3.0
                                end
                                local tarHum = plr.Character:FindFirstChild("Humanoid")
                                if tarHum and tarHum.Health and tarHum.MaxHealth and tarHum.Health < (tarHum.MaxHealth * 0.5) then
                                    score = score - 2.0
                                end
                                local toTarget = (tarRoot.Position - rootPart.Position)
                                if toTarget.Magnitude > 0 then
                                    local dir = toTarget.Unit
                                    local forward = rootPart.CFrame.LookVector
                                    local dot = forward:Dot(dir)
                                    if dot and dot > 0.5 then
                                        score = score - 1.5
                                    end
                                end
                                if aimTarget and aimTarget == plr then
                                    score = score - 4.0
                                end
                                table.insert(results, {plr=plr, dist=dis, score=score})
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(results, function(a,b)
        if a.score == b.score then
            return a.dist < b.dist
        end
        return a.score < b.score
    end)
    local out = {}
    for i=1, math.min(#results, maxCount) do
        table.insert(out, results[i].plr)
    end
    return out
end

local function predictTargetPosition(tarRoot, tarLimb, predictionFactor)
    if not tarRoot or not tarLimb then return tarLimb and tarLimb.Position or (tarRoot and tarRoot.Position) end
    predictionFactor = predictionFactor or 0.9
    local vel = Vector3.new(0,0,0)
    pcall(function()
        if tarRoot.AssemblyLinearVelocity then
            vel = tarRoot.AssemblyLinearVelocity
        elseif tarRoot.Velocity then
            vel = tarRoot.Velocity
        end
    end)
    local dist = (tarRoot.Position - rootPart.Position).Magnitude
    local lead = math.clamp(dist / 20, 0, 1.6) * predictionFactor
    return tarLimb.Position + vel * lead
end

local function lookAtYawOnly(originPart, targetPos)
    if not originPart or not targetPos then return end
    pcall(function()
        local origin = originPart.Position
        local flatTarget = Vector3.new(targetPos.X, origin.Y, targetPos.Z)
        originPart.CFrame = CFrame.new(origin, flatTarget)
    end)
end

local hitQueue = {}

local function enqueueHit(payload)
    if not payload or not payload.tarHum then return end
    payload.snapshotHealth = payload.tarHum.Health
    table.insert(hitQueue, payload)
end

task.spawn(function()
    while true do
        if hitFlushInterval and hitFlushInterval > 0 then
            task.wait(hitFlushInterval)
        else
            task.wait()
        end
        if #hitQueue > 0 then
            local toSend = hitQueue
            hitQueue = {}
            for _, entry in ipairs(toSend) do
                if entry and entry.tarHum and entry.tarLimb and entry.tool then
                    pcall(function()
                        MeleeSendHit({entry.tarHum, entry.tarLimb, entry.tool})
                    end)
                    if entry.needCommit then
                        task.wait(0.03)
                        pcall(function()
                            ToolSoundEvent:FireServer(entry.tool, "Commit")
                        end)
                    end
                    task.wait(0.02)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if #hitQueue > 0 then
            for i = #hitQueue, 1, -1 do
                local entry = hitQueue[i]
                if entry and entry.tarHum and entry.snapshotHealth then
                    local ok, cur = pcall(function() return entry.tarHum.Health end)
                    if ok and type(cur) == "number" and cur < entry.snapshotHealth then
                        pcall(function()
                            MeleeSendHit({entry.tarHum, entry.tarLimb, entry.tool})
                        end)
                        if entry.needCommit then
                            task.wait(0.02)
                            pcall(function() ToolSoundEvent:FireServer(entry.tool, "Commit") end)
                        end
                        table.remove(hitQueue, i)
                    end
                end
            end
        end
    end
end)

local lastObservedHealth = {}

local function reassignHitsFromPlayer(userId)
    if not userId then return end
    local indices = {}
    for i,entry in ipairs(hitQueue) do
        if entry and entry.tarPlayer and entry.tarPlayer.UserId == userId then
            table.insert(indices, i)
        end
    end
    if #indices == 0 then return end
    local candidates = collectTargets(#indices, attackRange)
    local idx = 1
    for _, i in ipairs(indices) do
        local entry = hitQueue[i]
        if entry then
            if candidates[idx] then
                local repl = candidates[idx]
                if repl and repl.Character then
                    local tarHum = repl.Character:FindFirstChild("Humanoid")
                    local limb = findTargetLimb(repl.Character, alwaysHead)
                    if tarHum and limb then
                        entry.tarHum = tarHum
                        entry.tarLimb = limb
                        entry.tarPlayer = repl
                        entry.snapshotHealth = tarHum.Health
                        idx = idx + 1
                    end
                end
            else
            end
        end
    end
end

local function findNearestExcluding(excludeTbl, maxRange)
    local list = collectTargets(20, maxRange)
    for _, plr in ipairs(list) do
        if plr and plr.UserId and not excludeTbl[plr.UserId] then
            return plr
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not rootPart then return end
    local now = os.clock()
    if silentAim and now - lastSilentTime >= silentCooldown then
        local candidates = collectTargets(1, silentRange)
        local targetPlr = candidates[1]
        if targetPlr and targetPlr.Character then
            local tarLimb = findTargetLimb(targetPlr.Character, alwaysHead)
            if tarLimb then
                pcall(function()
                    lookAtYawOnly(rootPart, tarLimb.Position)
                end)
                lastSilentTime = now
            end
        end
    end
    if autoAttack and silentAim then
        local candidates = collectTargets(1, attackRange)
        local preTarget = candidates[1]
        if preTarget and preTarget.Character then
            local tarLimb = findTargetLimb(preTarget.Character, alwaysHead)
            if tarLimb then
                local tarRoot = preTarget.Character:FindFirstChild("HumanoidRootPart")
                local predPos = predictTargetPosition(tarRoot, tarLimb, 0.9)
                pcall(function()
                    lookAtYawOnly(rootPart, predPos)
                end)
                aimTarget = preTarget
            end
        else
            aimTarget = nil
        end
    else
        aimTarget = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not autoAttack or not rootPart then return end
    local now = os.clock()
    local heldTool = getHeldWeapon()
    if heldTool then
        pcall(function() WeaponCheckLabel.Text = "手持武器检测："..heldTool.Name end)
    else
        pcall(function() WeaponCheckLabel.Text = "手持武器检测：无目标武器" end)
        return
    end
    local currentCooldown = attackCoolDown
    if useNativeSpeed and heldTool then
        local ok, val = pcall(function() return GetMeleeWeaponCooldown(heldTool) end)
        if ok and type(val) == "number" and val > 0 then
            currentCooldown = val
        end
    end
    if latencyCompEnabled then
        local ok, res = pcall(function()
            if LocalPlayer and LocalPlayer.GetNetworkPing then
                return LocalPlayer:GetNetworkPing()
            end
            return nil
        end)
        if ok and type(res) == "number" and res > 0 then
            currentCooldown = currentCooldown + (res * latencyFactor)
        end
    end
    currentCooldown = math.clamp(currentCooldown, 0.05, 10)
    if now - lastAttackTime < currentCooldown then return end

    local targetsToAttack = {}
    local leftPlayers = {}
    if lockedTargets and now < attackLockExpire then
        for _, plr in ipairs(lockedTargets) do
            if plr and plr.Character then
                local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local tarHum = plr.Character:FindFirstChild("Humanoid")
                if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
                    if (rootPart.Position - tarRoot.Position).Magnitude <= attackRange then
                        local limb = findTargetLimb(plr.Character, alwaysHead)
                        if limb and hasLineOfSight(rootPart, limb) then
                            table.insert(targetsToAttack, plr)
                        end
                    else
                        table.insert(leftPlayers, plr)
                    end
                else
                    table.insert(leftPlayers, plr)
                end
            end
            if #targetsToAttack >= maxTargets then break end
        end
        if #targetsToAttack == 0 then
            lockedTargets = nil
            attackLockExpire = 0
        else
            for _, left in ipairs(leftPlayers) do
                if left and left.UserId then
                    reassignHitsFromPlayer(left.UserId)
                end
            end
        end
    end

    if (not lockedTargets) or (#targetsToAttack == 0) then
        local newTargets = collectTargets(maxTargets, attackRange)
        if #newTargets == 0 then
            return
        end
        lockedTargets = newTargets
        attackLockExpire = now + currentCooldown
        for _, plr in ipairs(lockedTargets) do
            if plr and plr.Character then
                local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local tarHum = plr.Character:FindFirstChild("Humanoid")
                if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
                    if (rootPart.Position - tarRoot.Position).Magnitude <= attackRange then
                        local limb = findTargetLimb(plr.Character, alwaysHead)
                        if limb and hasLineOfSight(rootPart, limb) then
                            table.insert(targetsToAttack, plr)
                            lastObservedHealth[plr.UserId] = tarHum.Health
                        end
                    end
                end
            end
            if #targetsToAttack >= maxTargets then break end
        end
        if #targetsToAttack == 0 then
            lockedTargets = nil
            attackLockExpire = 0
            return
        end
    end

    lastAttackTime = now

    local alreadyAttacked = {}
    for idx = 1, maxTargets do
        local targetPlr = nil
        for _, plr in ipairs(targetsToAttack) do
            if plr and plr.UserId and not alreadyAttacked[plr.UserId] then
                targetPlr = plr
                break
            end
        end
        if not targetPlr then
            targetPlr = findNearestExcluding(alreadyAttacked, attackRange)
        end
        if not targetPlr then break end

        if not targetPlr or not targetPlr.Character then
        else
            local tarChar = targetPlr.Character
            local tarHum = tarChar:FindFirstChild("Humanoid")
            local tarLimb = findTargetLimb(tarChar, alwaysHead)
            if not tarHum or not tarLimb then
            else
                local info = weaponInfo[heldTool] or {}
                local tarRoot = tarChar:FindFirstChild("HumanoidRootPart")
                local aimPos = predictTargetPosition(tarRoot, tarLimb, 1.0)
                local firedSoundByConfig = false
                if useNativeSpeed and heldTool and meleeWeaponConfig[heldTool.Name] then
                    pcall(function() FireMeleeWeaponSound(heldTool) end)
                    firedSoundByConfig = true
                end
                local needCommit = false
                if not firedSoundByConfig then
                    if heldTool.Name == "Glass Fragment" then
                        pcall(function() ToolSoundEvent:FireServer(heldTool, "Swing") end)
                        needCommit = false
                    else
                        pcall(function() ToolSoundEvent:FireServer(heldTool, "Plan") end)
                        needCommit = true
                    end
                end
                local uid = targetPlr.UserId
                local prevHealth = lastObservedHealth[uid] or tarHum.Health
                if tarHum.Health < prevHealth then
                    pcall(function()
                        MeleeSendHit({tarHum, tarLimb, heldTool})
                    end)
                    if needCommit then
                        task.wait(0.03)
                        pcall(function() ToolSoundEvent:FireServer(heldTool, "Commit") end)
                    end
                else
                    enqueueHit({
                        tarHum = tarHum,
                        tarLimb = tarLimb,
                        tool = heldTool,
                        needCommit = needCommit,
                        tarPlayer = targetPlr
                    })
                end
                lastObservedHealth[uid] = tarHum.Health
                alreadyAttacked[uid] = true
            end
        end
        if idx < maxTargets then
            task.wait(0.02)
        end
    end
end)

local collapsed = false
local expandedSize = UDim2.new(0,320,0,360)
local collapsedSize = UDim2.new(0,320,0,48)
MainFrame.Size = expandedSize
CollapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(MainFrame, tweenInfo, {Size = collapsedSize}):Play()
        ContentScroller.Visible = false
        CollapseBtn.Text = "+"
    else
        ContentScroller.Visible = true
        local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(MainFrame, tweenInfo, {Size = expandedSize}):Play()
        CollapseBtn.Text = "—"
    end
end)

if RangeSlider and RangeSlider.Set then RangeSlider.Set(14) end
if CooldownSlider and CooldownSlider.Set then CooldownSlider.Set(0.5) end
if MultiTargetSlider and MultiTargetSlider.Set then MultiTargetSlider.Set(1) end
if SilentRangeSlider and SilentRangeSlider.Set then SilentRangeSlider.Set(10) end
if SilentCooldownSlider and SilentCooldownSlider.Set then SilentCooldownSlider.Set(0) end
if AlwaysHeadSwitch and AlwaysHeadSwitch.Set then AlwaysHeadSwitch.Set(false) end
if UseNativeSpeedSwitch and UseNativeSpeedSwitch.Set then UseNativeSpeedSwitch.Set(false) end
if SendDelaySlider and SendDelaySlider.Set then SendDelaySlider.Set(0) end
if LatencyCompSwitch and LatencyCompSwitch.Set then LatencyCompSwitch.Set(false) end
if LatencyFactorSlider and LatencyFactorSlider.Set then LatencyFactorSlider.Set(1.0) end

do
    local origGet = MultiTargetSlider.Get
    local origSet = MultiTargetSlider.Set
    MultiTargetSlider.Get = function()
        local v = origGet()
        v = math.clamp(math.floor(v + 0.5), 1, 3)
        return v
    end
    MultiTargetSlider.Set = function(v)
        v = math.clamp(math.floor(v + 0.5), 1, 3)
        origSet(v)
        pcall(function() MultiTargetSlider.ValueLabel.Text = tostring(v) end)
    end
    pcall(function() MultiTargetSlider.ValueLabel.Text = tostring(math.clamp(math.floor(origGet() + 0.5),1,3)) end)
end

autoAttack = AutoSwitch and AutoSwitch.Get and AutoSwitch.Get() or autoAttack
silentAim = SilentSwitch and SilentSwitch.Get and SilentSwitch.Get() or silentAim
teamCheck = TeamCheckSwitch and TeamCheckSwitch.Get and TeamCheckSwitch.Get() or teamCheck
alwaysHead = AlwaysHeadSwitch and AlwaysHeadSwitch.Get and AlwaysHeadSwitch.Get() or alwaysHead
useNativeSpeed = UseNativeSpeedSwitch and UseNativeSpeedSwitch.Get and UseNativeSpeedSwitch.Get() or useNativeSpeed
attackRange = RangeSlider and RangeSlider.Get and (math.floor((RangeSlider.Get() or attackRange) * 100 + 0.5) / 100) or attackRange
attackCoolDown = CooldownSlider and CooldownSlider.Get and (math.floor((CooldownSlider.Get() or attackCoolDown) * 100 + 0.5) / 100) or attackCoolDown
maxTargets = MultiTargetSlider and MultiTargetSlider.Get and math.clamp(math.floor((MultiTargetSlider.Get() or maxTargets)+0.5),1,3) or maxTargets
silentRange = SilentRangeSlider and SilentRangeSlider.Get and (math.floor((SilentRangeSlider.Get() or silentRange) * 100 + 0.5) / 100) or silentRange
silentCooldown = SilentCooldownSlider and SilentCooldownSlider.Get and (math.floor((SilentCooldownSlider.Get() or silentCooldown) * 100 + 0.5) / 100) or silentCooldown
hitFlushInterval = SendDelaySlider and SendDelaySlider.Get and (math.floor((SendDelaySlider.Get() or hitFlushInterval) * 100 + 0.5) / 100) or hitFlushInterval

MainFrame.Active = true
local draggingWindow = false
local dragStart = Vector2.new(0,0)
local startPos = Vector2.new(0,0)
local targetPos = MainFrame.AbsolutePosition

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = toVector2(input.Position)
        local ap = MainFrame.AbsolutePosition
        if typeof(ap) == "Vector2" then
            startPos = ap
        else
            startPos = Vector2.new(ap.X or 0, ap.Y or 0)
        end
        targetPos = startPos
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingWindow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local curPos = toVector2(input.Position)
        local delta = curPos - dragStart
        local desired = startPos + delta
        targetPos = desired
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        draggingWindow = false
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local cur = MainFrame.AbsolutePosition
    if not cur then return end
    local curPos = Vector2.new(cur.X, cur.Y)
    local lerpFactor = math.clamp(1 - math.exp(-12 * dt), 0, 1)
    local newPos = curPos:Lerp(targetPos, lerpFactor)
    MainFrame.Position = UDim2.new(0, math.floor(newPos.X + 0.5), 0, math.floor(newPos.Y + 0.5))
end)

do
    MainFrame.Visible = false

    local overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "MeleeStartupOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    overlayGui.DisplayOrder = 2147483647
    overlayGui.IgnoreGuiInset = true
    overlayGui.Parent = CoreGui
    overlayGui.Enabled = true

    local overlay = Instance.new("Frame")
    overlay.Name = "BlackOverlay"
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.Position = UDim2.new(0,0,0,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = overlayGui.DisplayOrder or 2147483647
    overlay.Parent = overlayGui

    local centerText = Instance.new("TextLabel")
    centerText.Name = "StartupText"
    centerText.Size = UDim2.new(0.7,0,0.18,0)
    centerText.Position = UDim2.new(0.5,0,0.5,0)
    centerText.AnchorPoint = Vector2.new(0.5,0.5)
    centerText.BackgroundTransparency = 1
    centerText.Text = "Link.cc"
    centerText.TextColor3 = Color3.fromRGB(255,240,250)
    centerText.TextStrokeTransparency = 0.6
    centerText.Font = Enum.Font.GothamBold
    centerText.TextSize = 72
    centerText.TextTransparency = 1
    centerText.ZIndex = (overlay.ZIndex or 2147483647) + 1
    centerText.Parent = overlay

    local ok, err = pcall(function()
        local tIn = TweenService:Create(overlay, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
        tIn:Play()
        tIn.Completed:Wait()

        local tTextIn = TweenService:Create(centerText, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0})
        local startPos = centerText.Position
        local newY = startPos.Y.Offset - 20
        local destPos = UDim2.new(startPos.X.Scale, startPos.X.Offset, startPos.Y.Scale, newY)
        local tFloat = TweenService:Create(centerText, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = destPos})

        tTextIn:Play()
        tFloat:Play()
        tTextIn.Completed:Wait()

        task.wait(10)

        local tTextOut = TweenService:Create(centerText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1, TextStrokeTransparency = 1})
        tTextOut:Play()
        tTextOut.Completed:Wait()

        local tOut = TweenService:Create(overlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        tOut:Play()
        tOut.Completed:Wait()
    end)

    pcall(function() overlayGui:Destroy() end)
    MainFrame.Visible = true
end

ScreenGui.ResetOnSpawn = false

local frameCount = 0
local accTime = 0
local lastFPS = 0
RunService.RenderStepped:Connect(function(dt)
    if dt and type(dt) == "number" then
        frameCount = frameCount + 1
        accTime = accTime + dt
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local fps = 0
        if accTime > 0 then
            fps = math.floor(frameCount / math.max(accTime, 1e-6) + 0.5)
        end
        frameCount = 0
        accTime = 0
        lastFPS = fps
        local pingMs = nil
        local ok, res = pcall(function()
            if LocalPlayer and LocalPlayer.GetNetworkPing then
                return LocalPlayer:GetNetworkPing()
            end
            return nil
        end)
        if ok and type(res) == "number" then
            pingMs = math.floor(res * 1000 + 0.5)
        end
        if pingMs then
            FPSLabel.Text = string.format("FPS: %d | Ping: %d ms", lastFPS, pingMs)
        else
            FPSLabel.Text = string.format("FPS: %d | Ping: -- ms", lastFPS)
        end
    end
end)
