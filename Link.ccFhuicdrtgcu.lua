task.wait(2.6)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local IS_PC = false
pcall(function()
	IS_PC = (not UserInputService.TouchEnabled) and UserInputService.KeyboardEnabled
end)
local trackedConnections = {}
local spawnedTasks = {}
pcall(function()
	local function detectLuau()
		local v
		pcall(function() if typeof(shared) == "table" and shared.LuauVersion ~= nil then v = shared.LuauVersion end end)
		if not v then pcall(function() if _G and _G.LuauVersion then v = _G.LuauVersion end end) end
		if not v then pcall(function() if _G and _G.LuaVersion then v = _G.LuaVersion end end) end
		if not v then pcall(function() v = _VERSION end) end
		return v or "unknown"
	end
	local ver = detectLuau()
	print("Luau version:", ver)
end)
local PINK_BG = Color3.fromRGB(255,242,247)
local PINK_ACCENT = Color3.fromRGB(255,105,180)
local PANEL_WIDTH = 600
local PANEL_HEIGHT = 340
local CENTER_Y_OFFSET = -200
local BASE_PANEL_Z = 1000000000
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Link_cc_Extracted_UI"
pcall(function() ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)
pcall(function() ScreenGui.ResetOnSpawn = false end)
ScreenGui.Parent = CoreGui
local FullscreenMask = Instance.new("Frame", ScreenGui)
FullscreenMask.Name = "FullscreenMask"
FullscreenMask.Size = UDim2.new(2, 0, 2, 0)
FullscreenMask.Position = UDim2.new(-0.5, 0, -0.5, 0)
FullscreenMask.BackgroundColor3 = Color3.fromRGB(0,0,0)
FullscreenMask.BackgroundTransparency = 0
FullscreenMask.BorderSizePixel = 0
FullscreenMask.ZIndex = BASE_PANEL_Z + 1000
local SplashText = Instance.new("TextLabel", FullscreenMask)
SplashText.Size = UDim2.new(0, 420, 0, 120)
SplashText.Position = UDim2.new(0.5, 0, 0.5, -20)
SplashText.AnchorPoint = Vector2.new(0.5, 0.5)
SplashText.BackgroundTransparency = 1
SplashText.Font = Enum.Font.GothamBold
SplashText.TextSize = 48
SplashText.TextColor3 = PINK_ACCENT
SplashText.Text = "Link.cc"
SplashText.TextTransparency = 1
SplashText.ZIndex = FullscreenMask.ZIndex + 10
local splashSound = Instance.new("Sound")
splashSound.SoundId = "rbxassetid://77919879643329"
splashSound.Volume = 2.5
splashSound.Looped = false
splashSound.Parent = SoundService
local function getInputPos(input)
	local ok, pos = pcall(function() return input.Position end)
	if ok and pos then return pos end
	local ok2, mpos = pcall(function() return UserInputService:GetMouseLocation() end)
	if ok2 and mpos then return mpos end
	return nil
end
local function trackConnection(conn)
	if conn then
		table.insert(trackedConnections, conn)
	end
	return conn
end
local function makeDraggable(frame)
	if not frame then return end
	frame.Active = true
	local dragging = false
	local dragInput = nil
	local dragStart = Vector2.new(0,0)
	local startPos = UDim2.new(0,0,0,0)
	local inputChangedConn
	local function onInputChanged(input)
		if not dragging or input ~= dragInput then return end
		local pos = getInputPos(input)
		if not pos then return end
		local delta = pos - dragStart
		local sx, ox = startPos.X.Scale, startPos.X.Offset
		local sy, oy = startPos.Y.Scale, startPos.Y.Offset
		frame.Position = UDim2.new(sx, ox + delta.X, sy, oy + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = getInputPos(input)
			if not pos then return end
			dragging = true
			dragInput = input
			dragStart = pos
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragInput = nil
				end
			end)
			if not inputChangedConn then
				inputChangedConn = UserInputService.InputChanged:Connect(onInputChanged)
				trackConnection(inputChangedConn)
			end
		end
	end)
end
local function playSplash()
	SplashText.Position = UDim2.new(0.5, 0, 0.5, -20)
	SplashText.TextTransparency = 1
	local tweenIn = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(SplashText, tweenIn, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, -30)}):Play()
	splashSound:Play()
	local conn
	conn = splashSound.Ended:Connect(function()
		conn:Disconnect()
		local mid = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(SplashText, mid, {TextColor3 = PINK_BG, TextTransparency = 0.5}):Play()
		task.wait(0.5)
		local out = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local t = TweenService:Create(SplashText, out, {TextTransparency = 1})
		t:Play()
		t.Completed:Wait()
		pcall(function() FullscreenMask:Destroy() end)
	end)
end
task.spawn(playSplash)
local CenterPanel = Instance.new("Frame", ScreenGui)
CenterPanel.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
CenterPanel.Position = UDim2.new(0.5, -PANEL_WIDTH/2, 0.5, CENTER_Y_OFFSET)
CenterPanel.BackgroundColor3 = PINK_BG
CenterPanel.BackgroundTransparency = 0.05
CenterPanel.BorderSizePixel = 0
CenterPanel.ZIndex = BASE_PANEL_Z
CenterPanel.Active = true
CenterPanel.ClipsDescendants = false
local CenterCorner = Instance.new("UICorner", CenterPanel)
CenterCorner.CornerRadius = UDim.new(0, 12)
local TitleLabel = Instance.new("TextLabel", CenterPanel)
TitleLabel.Size = UDim2.new(1, -24, 0, 36)
TitleLabel.Position = UDim2.new(0, 12, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextColor3 = PINK_ACCENT
TitleLabel.Text = "Link.cc"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
TitleLabel.ZIndex = CenterPanel.ZIndex + 1
local StatusFrame = Instance.new("Frame", CenterPanel)
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0, 220, 0, 24)
StatusFrame.Position = UDim2.new(0, 160, 0, 6)
StatusFrame.BackgroundTransparency = 1
StatusFrame.BorderSizePixel = 0
StatusFrame.ZIndex = CenterPanel.ZIndex + 2
local PingLabel = Instance.new("TextLabel", StatusFrame)
PingLabel.Size = UDim2.new(0.6, 0, 1, 0)
PingLabel.Position = UDim2.new(0, 0, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.Gotham
PingLabel.TextSize = 12
PingLabel.TextColor3 = Color3.fromRGB(200,200,200)
PingLabel.Text = "Ping: --ms"
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.TextYAlignment = Enum.TextYAlignment.Center
PingLabel.ZIndex = StatusFrame.ZIndex + 1
PingLabel.TextTransparency = 0
local FpsLabel = Instance.new("TextLabel", StatusFrame)
FpsLabel.Size = UDim2.new(0.4, -4, 1, 0)
FpsLabel.Position = UDim2.new(0.6, 4, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Font = Enum.Font.Gotham
FpsLabel.TextSize = 12
FpsLabel.TextColor3 = Color3.fromRGB(200,200,200)
FpsLabel.Text = "FPS: --"
FpsLabel.TextXAlignment = Enum.TextXAlignment.Right
FpsLabel.TextYAlignment = Enum.TextYAlignment.Center
FpsLabel.ZIndex = StatusFrame.ZIndex + 1
FpsLabel.TextTransparency = 0
local function pingColorForValue(p)
	if not p then return Color3.fromRGB(52,211,153) end
	if p <= 99 then
		return Color3.fromRGB(52,211,153)
	elseif p <= 120 then
		return Color3.fromRGB(245,158,11)
	else
		return Color3.fromRGB(239,68,68)
	end
end
local function fpsColorForValue(fps)
	if not fps then return Color3.fromRGB(52,211,153) end
	if fps >= 55 then
		return Color3.fromRGB(52,211,153)
	elseif fps >= 40 then
		return Color3.fromRGB(245,158,11)
	else
		return Color3.fromRGB(239,68,68)
	end
end
do
	local frameCount = 0
	local frameAccumTime = 0.0
	local currentPing = 0
	local serverPingItem = nil
	pcall(function()
		local ok, Stats = pcall(function() return game:GetService("Stats") end)
		if ok and Stats and Stats.Network and Stats.Network.ServerStatsItem then
			serverPingItem = Stats.Network.ServerStatsItem["Data Ping"]
		end
	end)
	RunService.RenderStepped:Connect(function(dt)
		frameCount = frameCount + 1
		frameAccumTime = frameAccumTime + (dt or 0)
	end)
	spawn(function()
		while ScreenGui and ScreenGui.Parent do
			local gotPing = false
			local newPing = 0
			if serverPingItem then
				pcall(function()
					local v = serverPingItem:GetValue()
					if v then
						local num = tonumber(v) or 0
						if num and num > 0 then
							if num > 1000 then
								newPing = math.floor(num)
							elseif num >= 0.01 and num <= 10 then
								newPing = math.floor(num * 1000)
							else
								newPing = math.floor(num)
							end
							gotPing = true
						end
					end
				end)
			end
			if not gotPing then
				pcall(function()
					if LocalPlayer and LocalPlayer.GetNetworkPing then
						local p = LocalPlayer:GetNetworkPing()
						if p and p > 0 then
							if p < 10 then
								newPing = math.floor(p * 1000)
							else
								newPing = math.floor(p)
							end
							gotPing = true
						end
					end
				end)
			end
			if not gotPing then
				newPing = 0
			end
			currentPing = newPing
			local fps = 0
			if frameAccumTime and frameAccumTime > 0 then
				fps = math.floor((frameCount / frameAccumTime) + 0.5)
			else
				fps = 0
			end
			frameCount = 0
			frameAccumTime = 0.0
			pcall(function()
				if StatusFrame and StatusFrame.Parent and StatusFrame.Visible then
					PingLabel.Text = ("Ping: %dms"):format(currentPing or 0)
					PingLabel.TextColor3 = pingColorForValue(currentPing or 0)
					local fpsText = ("FPS: %d"):format(fps or 0)
					FpsLabel.Text = fpsText
					FpsLabel.TextColor3 = fpsColorForValue(fps or 0)
				end
			end)
			for i = 1, 10 do
				task.wait(0.1)
				if not (ScreenGui and ScreenGui.Parent) then break end
			end
		end
	end)
end
local LEFT_PADDING = 8
local TOP_CONTENT_Y = 52
local LEFT_AREA_WIDTH = 180
local LEFT_ITEM_HEIGHT = 40
local LEFT_ITEM_PADDING = 8
local LeftArea = Instance.new("Frame", CenterPanel)
LeftArea.Name = "LeftArea"
LeftArea.Size = UDim2.new(0, LEFT_AREA_WIDTH, 1, -TOP_CONTENT_Y - 12)
LeftArea.Position = UDim2.new(0, LEFT_PADDING, 0, TOP_CONTENT_Y)
LeftArea.BackgroundColor3 = PINK_BG
LeftArea.BackgroundTransparency = 0.02
LeftArea.BorderSizePixel = 0
LeftArea.ZIndex = CenterPanel.ZIndex + 2
Instance.new("UICorner", LeftArea).CornerRadius = UDim.new(0, 10)
local LeftAreaTitle = Instance.new("TextLabel", LeftArea)
LeftAreaTitle.Size = UDim2.new(1, -16, 0, 28)
LeftAreaTitle.Position = UDim2.new(0, 8, 0, 8)
LeftAreaTitle.BackgroundTransparency = 1
LeftAreaTitle.Font = Enum.Font.Gotham
LeftAreaTitle.TextSize = 14
LeftAreaTitle.Text = "功能区"
LeftAreaTitle.TextColor3 = Color3.fromRGB(80,80,80)
LeftAreaTitle.ZIndex = LeftArea.ZIndex + 1
LeftAreaTitle.TextXAlignment = Enum.TextXAlignment.Left
local LeftList = Instance.new("ScrollingFrame", LeftArea)
LeftList.Name = "LeftList"
LeftList.Active = true
LeftList.Size = UDim2.new(1, -16, 1, -48)
LeftList.Position = UDim2.new(0, 8, 0, 36)
LeftList.BackgroundTransparency = 1
LeftList.BorderSizePixel = 0
LeftList.ScrollBarThickness = 6
LeftList.CanvasSize = UDim2.new(0,0,0,0)
LeftList.ZIndex = LeftArea.ZIndex + 1
LeftList.ClipsDescendants = true
local LeftListLayout = Instance.new("UIListLayout", LeftList)
LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftListLayout.Padding = UDim.new(0,LEFT_ITEM_PADDING)
local RightArea = Instance.new("Frame", CenterPanel)
RightArea.Name = "RightArea"
RightArea.Size = UDim2.new(1, -LEFT_AREA_WIDTH - LEFT_PADDING*3, 1, -TOP_CONTENT_Y - 12)
RightArea.Position = UDim2.new(0, LEFT_AREA_WIDTH + LEFT_PADDING*2, 0, TOP_CONTENT_Y)
RightArea.BackgroundTransparency = 1
RightArea.BorderSizePixel = 0
RightArea.ZIndex = CenterPanel.ZIndex + 2
local RightTitle = Instance.new("TextLabel", RightArea)
RightTitle.Size = UDim2.new(1, -12, 0, 28)
RightTitle.Position = UDim2.new(0, 6, 0, 6)
RightTitle.BackgroundTransparency = 1
RightTitle.Font = Enum.Font.GothamBold
RightTitle.TextSize = 15
RightTitle.Text = "内容"
RightTitle.TextColor3 = Color3.fromRGB(200,200,200)
RightTitle.TextXAlignment = Enum.TextXAlignment.Left
RightTitle.ZIndex = RightArea.ZIndex + 1
local RightList = Instance.new("ScrollingFrame", RightArea)
RightList.Name = "RightList"
RightList.Active = true
RightList.Size = UDim2.new(1, -12, 1, -48)
RightList.Position = UDim2.new(0, 6, 0, 36)
RightList.BackgroundTransparency = 1
RightList.BorderSizePixel = 0
RightList.ScrollBarThickness = 6
RightList.ZIndex = RightArea.ZIndex + 1
local RightListLayout = Instance.new("UIListLayout", RightList)
RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightListLayout.Padding = UDim.new(0,8)
local function clearContainer(container)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and child.Name ~= "SelectionIndicator" then
			child:Destroy()
		end
	end
end
local function createToggleControl(parent, item)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, 64)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ZIndex = parent.ZIndex + 1
	local bg = Instance.new("Frame", container)
	bg.Size = UDim2.new(1, 0, 0, 64)
	bg.Position = UDim2.new(0, 0, 0, 0)
	bg.BackgroundColor3 = Color3.fromRGB(250,250,250)
	bg.BackgroundTransparency = 0.02
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
	bg.ZIndex = container.ZIndex
	local label = Instance.new("TextLabel", bg)
	label.Size = UDim2.new(0.7, -12, 0, 22)
	label.Position = UDim2.new(0, 10, 0, 8)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 14
	label.Text = item.title or "Toggle"
	label.TextColor3 = Color3.fromRGB(30,30,30)
	label.ZIndex = bg.ZIndex + 2
	label.TextXAlignment = Enum.TextXAlignment.Left
	local desc = Instance.new("TextLabel", bg)
	desc.Size = UDim2.new(0.7, -12, 0, 14)
	desc.Position = UDim2.new(0, 10, 0, 30)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 12
	desc.Text = item.desc or ""
	desc.TextColor3 = Color3.fromRGB(100,100,100)
	desc.ZIndex = bg.ZIndex + 2
	desc.TextXAlignment = Enum.TextXAlignment.Left
	local sw = Instance.new("TextButton", bg)
	sw.Name = "Switch"
	sw.Size = UDim2.new(0, 52, 0, 30)
	sw.Position = UDim2.new(1, -72, 0.5, -15)
	sw.BackgroundColor3 = Color3.fromRGB(70,70,74)
	sw.BorderSizePixel = 0
	sw.ZIndex = CenterPanel.ZIndex + 60
	sw.AutoButtonColor = true
	sw.Active = true
	sw.Text = ""
	Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 15)
	local knob = Instance.new("Frame", sw)
	knob.Name = "Knob"
	knob.Size = UDim2.new(0,26,0,26)
	knob.Position = UDim2.new(0, 2, 0.5, -13)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 13)
	knob.ZIndex = sw.ZIndex + 1
	if item._state == nil then
		item._state = (item.defaultOn == true) or false
	end
	local state = item._state
	local animing = false
	local function setVisual(on, instant)
		animing = true
		item._state = on
		local targetBg = on and Color3.fromRGB(0,122,204) or Color3.fromRGB(70,70,74)
		local targetKnob = on and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
		if instant then
			sw.BackgroundColor3 = targetBg
			knob.Position = targetKnob
			animing = false
			return
		end
		pcall(function() TweenService:Create(sw, TweenInfo.new(0.18), {BackgroundColor3 = targetBg}):Play() end)
		pcall(function() TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Back), {Position = targetKnob}):Play() end)
		delay(0.22, function() animing = false end)
	end
	local function toggleHandler()
		if animing then return end
		state = not state
		setVisual(state, false)
		item._state = state
		if type(item.onToggle) == "function" then
			spawn(function() pcall(function() item.onToggle(state) end) end)
		end
	end
	sw.MouseButton1Click:Connect(toggleHandler)
	if sw.Activated then sw.Activated:Connect(toggleHandler) end
	setVisual(state, true)
	return container, sw
end
local function createSliderControl(parent, item)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1,0,0,96)
	container.BackgroundTransparency = 1
	container.ZIndex = parent.ZIndex + 1
	local bg = Instance.new("Frame", container)
	bg.Size = UDim2.new(1,0,0,74)
	bg.Position = UDim2.new(0,0,0,10)
	bg.BackgroundColor3 = Color3.fromRGB(250,250,250)
	bg.BackgroundTransparency = 0.02
	bg.BorderSizePixel = 0
	Instance.new("UICorner", bg).CornerRadius = UDim.new(0,12)
	bg.ZIndex = container.ZIndex
	local label = Instance.new("TextLabel", bg)
	label.Name = "Label"
	label.Size = UDim2.new(0.72, -12, 0, 20)
	label.Position = UDim2.new(0,10,0,8)
	label.BackgroundTransparency = 1
	label.Text = item.title or "Slider"
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(30,30,30)
	label.ZIndex = bg.ZIndex + 2
	label.TextXAlignment = Enum.TextXAlignment.Left
	local desc = Instance.new("TextLabel", bg)
	desc.Name = "Desc"
	desc.Size = UDim2.new(0.72, -12, 0, 14)
	desc.Position = UDim2.new(0,10,0,30)
	desc.BackgroundTransparency = 1
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 11
	desc.Text = item.desc or ""
	desc.TextColor3 = Color3.fromRGB(100,100,100)
	desc.ZIndex = bg.ZIndex + 2
	desc.TextXAlignment = Enum.TextXAlignment.Left
	local slider = Instance.new("Frame", bg)
	slider.Name = "Slider"
	slider.Size = UDim2.new(0.9, 0, 0, 18)
	slider.Position = UDim2.new(0.05, 0, 1, -26)
	slider.BackgroundColor3 = Color3.fromRGB(44,44,48)
	slider.BorderSizePixel = 0
	slider.ZIndex = CenterPanel.ZIndex + 40
	Instance.new("UICorner", slider).CornerRadius = UDim.new(0,8)
	local fill = Instance.new("Frame", slider)
	fill.Name = "Fill"
	fill.Size = UDim2.new(0.5,0,1,0)
	fill.Position = UDim2.new(0,0,0,0)
	fill.BackgroundColor3 = Color3.fromRGB(0,122,204)
	fill.BorderSizePixel = 0
	fill.ZIndex = slider.ZIndex + 1
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)
	local knob = Instance.new("Frame", slider)
	knob.Name = "Knob"
	knob.Size = UDim2.new(0,16,0,16)
	knob.Position = UDim2.new(0.5, -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
	knob.BorderSizePixel = 0
	knob.Active = true
	knob.ZIndex = slider.ZIndex + 2
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,8)
	local valueLabel = Instance.new("TextLabel", bg)
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 80, 0, 18)
	valueLabel.Position = UDim2.new(1, -100, 0, 28)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 12
	valueLabel.TextColor3 = Color3.fromRGB(30,30,30)
	valueLabel.ZIndex = bg.ZIndex + 2
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local minVal = tonumber(item.min) or 0
	local maxVal = tonumber(item.max) or 100
	local cur = tonumber(item._value) or tonumber(item.default) or math.floor((minVal + maxVal)/2)
	item._value = cur
	local function setPositionFromValue(v, instant)
		local pct = (v - minVal) / math.max(1, (maxVal - minVal))
		pct = math.clamp(pct, 0, 1)
		if instant then
			fill.Size = UDim2.new(pct, 0, 1, 0)
			knob.Position = UDim2.new(pct, -8, 0.5, -8)
		else
			pcall(function() TweenService:Create(fill, TweenInfo.new(0.12), {Size = UDim2.new(pct,0,1,0)}):Play() end)
			pcall(function() TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Position = UDim2.new(pct, -8, 0.5, -8)}):Play() end)
		end
		valueLabel.Text = tostring(math.floor(v))
	end
	setPositionFromValue(cur, true)
	local dragging = false
	local dragConn, endConn
	local function beginDrag(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragConn = UserInputService.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
				local okPos, pos = pcall(function() return inp.Position end)
				local okAbs, absPos = pcall(function() return slider.AbsolutePosition end)
				local okSize, absSize = pcall(function() return slider.AbsoluteSize end)
				if not okPos or not okAbs or not okSize or not pos or not absPos or not absSize then return end
				local relX = math.clamp((pos.X - absPos.X) / math.max(1, absSize.X), 0, 1)
				local newVal = minVal + relX * (maxVal - minVal)
				cur = math.floor(newVal + 0.5)
				setPositionFromValue(cur, true)
			end
		end)
		endConn = UserInputService.InputEnded:Connect(function(inp)
			if inp == input then
				dragging = false
				if dragConn and dragConn.Connected then dragConn:Disconnect() end
				if endConn and endConn.Connected then endConn:Disconnect() end
				item._value = cur
				if type(item.onChange) == "function" then
					spawn(function() pcall(function() item.onChange(cur) end) end)
				end
			end
		end)
	end
	knob.InputBegan:Connect(beginDrag)
	slider.InputBegan:Connect(beginDrag)
	return container
end
local selectionIndicator = nil
local INDICATOR_WIDTH = 6
local INDICATOR_MARGIN_LEFT = 4
local INDICATOR_TWEEN_TIME = 0.22
local INDICATOR_COLOR = Color3.fromRGB(0,102,204)
local selectedButton = nil
local function setSelectedButton(btn)
	if not btn then return end
	if not selectionIndicator or not selectionIndicator.Parent then
		selectionIndicator = Instance.new("Frame")
		selectionIndicator.Name = "SelectionIndicator"
		selectionIndicator.BackgroundColor3 = INDICATOR_COLOR
		selectionIndicator.BorderSizePixel = 0
		selectionIndicator.Size = UDim2.new(0, INDICATOR_WIDTH, 0, LEFT_ITEM_HEIGHT)
		selectionIndicator.Position = UDim2.new(0, INDICATOR_MARGIN_LEFT, 0, 0)
		selectionIndicator.ZIndex = LeftList.ZIndex + 1
		selectionIndicator.Parent = LeftList
		local ic = Instance.new("UICorner", selectionIndicator)
		ic.CornerRadius = UDim.new(0, 6)
		selectionIndicator.Visible = false
	end
	if selectedButton and selectedButton.Parent and selectedButton ~= btn then
		pcall(function()
			local bgTween = TweenService:Create(selectedButton, TweenInfo.new(INDICATOR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(255,255,255),
				BackgroundTransparency = 0.02
			})
			bgTween:Play()
		end)
		pcall(function()
			local textTween = TweenService:Create(selectedButton, TweenInfo.new(INDICATOR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextColor3 = Color3.fromRGB(40,40,40)
			})
			textTween:Play()
		end)
	end
	selectedButton = btn
	pcall(function() selectedButton.ZIndex = LeftList.ZIndex + 3 end)
	pcall(function()
		local bgTween = TweenService:Create(selectedButton, TweenInfo.new(INDICATOR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = INDICATOR_COLOR,
			BackgroundTransparency = 0
		})
		bgTween:Play()
	end)
	pcall(function()
		local textTween = TweenService:Create(selectedButton, TweenInfo.new(INDICATOR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = Color3.fromRGB(255,255,255)
		})
		textTween:Play()
	end)
	spawn(function()
		local tries = 0
		while (not selectedButton or selectedButton.AbsolutePosition.Y == 0 or LeftList.AbsolutePosition.Y == 0) and tries < 10 do
			tries = tries + 1
			wait(0.03)
		end
		if not selectionIndicator or not selectionIndicator.Parent then return end
		local ok, err = pcall(function()
			local listAbs = LeftList.AbsolutePosition
			local btnAbs = selectedButton.AbsolutePosition
			local btnSize = selectedButton.AbsoluteSize
			local targetY = btnAbs.Y - listAbs.Y
			local targetSizeY = btnSize.Y
			selectionIndicator.Visible = true
			local tweenInfo = TweenInfo.new(INDICATOR_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local posTween = TweenService:Create(selectionIndicator, tweenInfo, {
				Position = UDim2.new(0, INDICATOR_MARGIN_LEFT, 0, targetY)
			})
			local sizeTween = TweenService:Create(selectionIndicator, tweenInfo, {
				Size = UDim2.new(0, INDICATOR_WIDTH, 0, targetSizeY)
			})
			posTween:Play(); sizeTween:Play()
		end)
		if not ok then
			pcall(function()
				selectionIndicator.Position = UDim2.new(0, INDICATOR_MARGIN_LEFT, 0, selectedButton.Position.Y.Offset)
				selectionIndicator.Size = UDim2.new(0, INDICATOR_WIDTH, 0, selectedButton.Size.Y.Offset)
				selectionIndicator.Visible = true
			end)
		end
	end)
end
local function renderRight(items)
	local prevY = 0
	pcall(function() prevY = RightList.CanvasPosition.Y end)
	clearContainer(RightList)
	RightList.CanvasSize = UDim2.new(0,0,0,0)
	local contentHeight = 0
	for i, item in ipairs(items) do
		if item.type == "toggle" then
			local holder = Instance.new("Frame", RightList)
			holder.Size = UDim2.new(1, -12, 0, 64)
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = RightList.ZIndex + 1
			local extraOffset = 24
			local startOffset = -(holder.Size.Y.Offset + extraOffset)
			local content = Instance.new("Frame", holder)
			content.Size = UDim2.new(1, 0, 1, 0)
			content.Position = UDim2.new(0, 0, 0, startOffset)
			content.BackgroundTransparency = 1
			content.BorderSizePixel = 0
			content.ZIndex = holder.ZIndex + 1
			local control, sw = createToggleControl(content, item)
			for _, descChild in ipairs(content:GetDescendants()) do
				if descChild:IsA("TextLabel") then
					pcall(function() descChild.TextTransparency = 1 end)
				end
			end
			spawn(function()
				local delayTime = math.min(0.12 + (i-1) * 0.03, 0.32)
				wait(delayTime)
				local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				pcall(function() TweenService:Create(content, tweenInfo, {Position = UDim2.new(0,0,0,0)}):Play() end)
				local textTweenTime = 0.28
				for _, descChild in ipairs(content:GetDescendants()) do
					if descChild:IsA("TextLabel") then
						pcall(function()
							TweenService:Create(descChild, TweenInfo.new(textTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								TextTransparency = 0
							}):Play()
						end)
					end
				end
			end)
			contentHeight = contentHeight + holder.Size.Y.Offset + (RightListLayout.Padding.Offset or 8)
		elseif item.type == "slider" then
			local holder = Instance.new("Frame", RightList)
			holder.Size = UDim2.new(1, -12, 0, 96)
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = RightList.ZIndex + 1
			local extraOffset = 24
			local startOffset = -(holder.Size.Y.Offset + extraOffset)
			local content = Instance.new("Frame", holder)
			content.Size = UDim2.new(1,0,1,0)
			content.Position = UDim2.new(0,0,0,startOffset)
			content.BackgroundTransparency = 1
			content.BorderSizePixel = 0
			content.ZIndex = holder.ZIndex + 1
			createSliderControl(content, item)
			for _, descChild in ipairs(content:GetDescendants()) do
				if descChild:IsA("TextLabel") then
					pcall(function() descChild.TextTransparency = 1 end)
				end
			end
			spawn(function()
				local delayTime = math.min(0.12 + (i-1) * 0.03, 0.32)
				wait(delayTime)
				local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				pcall(function() TweenService:Create(content, tweenInfo, {Position = UDim2.new(0,0,0,0)}):Play() end)
				local textTweenTime = 0.28
				for _, descChild in ipairs(content:GetDescendants()) do
					if descChild:IsA("TextLabel") then
						pcall(function()
							TweenService:Create(descChild, TweenInfo.new(textTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								TextTransparency = 0
							}):Play()
						end)
					end
				end
			end)
			contentHeight = contentHeight + holder.Size.Y.Offset + (RightListLayout.Padding.Offset or 8)
		else
			local holder = Instance.new("Frame", RightList)
			holder.Size = UDim2.new(1, -12, 0, 56)
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = RightList.ZIndex + 1
			local extraOffset = 24
			local startOffset = -(holder.Size.Y.Offset + extraOffset)
			local entry = Instance.new("TextButton", holder)
			entry.Size = UDim2.new(1, 0, 1, 0)
			entry.Position = UDim2.new(0, 0, 0, startOffset)
			entry.BackgroundColor3 = Color3.fromRGB(255,255,255)
			entry.BackgroundTransparency = 0.03
			entry.BorderSizePixel = 0
			entry.ZIndex = holder.ZIndex + 1
			entry.AutoButtonColor = true
			entry.Active = true
			entry.Text = ""
			entry.ClipsDescendants = true
			Instance.new("UICorner", entry).CornerRadius = UDim.new(0,6)
			local title = Instance.new("TextLabel", entry)
			title.Size = UDim2.new(1, -100, 0, 24)
			title.Position = UDim2.new(0, 8, 0, 6)
			title.BackgroundTransparency = 1
			title.Font = Enum.Font.GothamBold
			title.TextSize = 14
			title.Text = item.title or ("Item "..i)
			title.TextColor3 = Color3.fromRGB(25,25,25)
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.ZIndex = entry.ZIndex + 2
			title.TextTransparency = 1
			local desc = Instance.new("TextLabel", entry)
			desc.Size = UDim2.new(1, -100, 0, 18)
			desc.Position = UDim2.new(0, 8, 0, 28)
			desc.BackgroundTransparency = 1
			desc.Font = Enum.Font.Gotham
			desc.TextSize = 12
			desc.Text = item.desc or ""
			desc.TextColor3 = Color3.fromRGB(90,90,90)
			desc.TextXAlignment = Enum.TextXAlignment.Left
			desc.ZIndex = entry.ZIndex + 2
			desc.TextTransparency = 1
			if entry:GetAttribute("busy") == nil then
				entry:SetAttribute("busy", false)
			end
			local function activateEntry()
				if entry:GetAttribute("busy") then return end
				entry:SetAttribute("busy", true)
				spawn(function()
					if type(item.onClick) == "function" then
						local ok, res = pcall(function() item.onClick() end)
						if not ok then
							pcall(function() print(res) end)
						end
					end
				end)
				spawn(function()
					task.wait(0.6)
					pcall(function() entry:SetAttribute("busy", false) end)
				end)
			end
			if entry.Activated then
				entry.Activated:Connect(activateEntry)
			end
			entry.MouseButton1Click:Connect(activateEntry)
			spawn(function()
				local delayTime = math.min(0.12 + (i-1) * 0.03, 0.32)
				wait(delayTime)
				local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local moveTween = TweenService:Create(entry, tweenInfo, {
					Position = UDim2.new(0, 0, 0, 0)
				})
				local titleTween = TweenService:Create(title, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0
				})
				local descTween = TweenService:Create(desc, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0
				})
				moveTween:Play(); titleTween:Play(); descTween:Play()
			end)
			contentHeight = contentHeight + holder.Size.Y.Offset + (RightListLayout.Padding.Offset or 8)
		end
	end
	RightList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
	delay(0.02, function()
		pcall(function()
			local visibleH = RightList.AbsoluteSize.Y or 0
			local maxY = math.max(0, contentHeight - visibleH)
			local newY = math.clamp(prevY or 0, 0, maxY)
			RightList.CanvasPosition = Vector2.new(0, newY)
		end)
	end)
end
local function renderLeft(categories)
	local prevY = 0
	pcall(function() prevY = LeftList.CanvasPosition.Y end)
	local prevSelectedText = selectedButton and selectedButton.Text
	clearContainer(LeftList)
	LeftList.CanvasSize = UDim2.new(0,0,0,0)
	local totalH = 0
	local anyButton = false
	for i, cat in ipairs(categories) do
		local btn = Instance.new("TextButton", LeftList)
		btn.Size = UDim2.new(1, -12, 0, LEFT_ITEM_HEIGHT)
		btn.Position = UDim2.new(0, -200, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
		btn.BackgroundTransparency = 0.02
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.Text = cat.name or ("Category "..i)
		btn.TextColor3 = Color3.fromRGB(40,40,40)
		btn.ZIndex = LeftList.ZIndex + 2
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
		btn.TextXAlignment = Enum.TextXAlignment.Center
		btn.TextYAlignment = Enum.TextYAlignment.Center
		btn.TextTransparency = 1
		pcall(function() btn:SetAttribute("unlock_popup_open", false) end)
		btn.MouseButton1Click:Connect(function()
			if selectedButton == btn then
				return
			end
			setSelectedButton(btn)
			renderRight(cat.items or {})
			RightTitle.Text = cat.name or "内容"
		end)
		totalH = totalH + btn.Size.Y.Offset + (LeftListLayout.Padding.Offset or LEFT_ITEM_PADDING)
		anyButton = true
		spawn(function()
			local delayTime = math.min(0.12 + (i-1) * 0.03, 0.32)
			wait(delayTime)
			local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local moveTween = TweenService:Create(btn, tweenInfo, {
				Position = UDim2.new(0, 6, 0, 0)
			})
			local textTween = TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			})
			moveTween:Play(); textTween:Play()
		end)
	end
	LeftList.CanvasSize = UDim2.new(0, 0, 0, totalH)
	delay(0.02, function()
		pcall(function()
			local visibleH = LeftList.AbsoluteSize.Y or 0
			local maxY = math.max(0, totalH - visibleH)
			local newY = math.clamp(prevY or 0, 0, maxY)
			LeftList.CanvasPosition = Vector2.new(0, newY)
		end)
	end)
	delay(0.03, function()
		local visibleH = LeftList.AbsoluteSize.Y
		local contentH = LeftList.CanvasSize.Y.Offset
		if contentH <= visibleH then
			LeftList.Active = false
			LeftList.CanvasPosition = Vector2.new(0, 0)
		else
			LeftList.Active = true
		end
		if not anyButton then
			if selectionIndicator and selectionIndicator.Parent then
				selectionIndicator.Visible = false
			end
			return
		end
		if prevSelectedText then
			for _, v in ipairs(LeftList:GetChildren()) do
				if v:IsA("TextButton") and v.Text == prevSelectedText then
					setSelectedButton(v)
					for _, cat in ipairs(categories) do
						if cat.name == v.Text then
							renderRight(cat.items or {})
							RightTitle.Text = cat.name or "内容"
							break
						end
					end
					return
				end
			end
		end
		if selectedButton and selectedButton.Parent then
			setSelectedButton(selectedButton)
			return
		end
		for idx, v in ipairs(LeftList:GetChildren()) do
			if v:IsA("TextButton") then
				setSelectedButton(v)
				for _, cat in ipairs(categories) do
					if cat.name == v.Text then
						renderRight(cat.items or {})
						RightTitle.Text = cat.name or "内容"
						break
					end
				end
				break
			end
		end
	end)
end
local alive = true
local function disconnectAllConnections()
	for _, c in ipairs(trackedConnections) do
		pcall(function() c:Disconnect() end)
	end
	trackedConnections = {}
end
local function stopAllTasks()
	alive = false
	spawnedTasks = {}
end
local function cleanupEverything()
	alive = false
	disconnectAllConnections()
	pcall(function()
		if ScreenGui and ScreenGui.Parent then
			ScreenGui:Destroy()
		end
	end)
end
_G.MeleeAutoAttackCleanup = cleanupEverything
local ToolSoundEvent = nil
local NamespaceModule = nil
local MeleeSendHit = nil
do
	pcall(function() ToolSoundEvent = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("ToolSound") end)
	pcall(function()
		local ServiceFolder = ReplicatedStorage:WaitForChild("Service")
		NamespaceModule = require(ServiceFolder:WaitForChild("Namespaces"))
		MeleeSendHit = NamespaceModule.MeleeReplication.packets.sendHit.send
	end)
end
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
local function refreshChar(char)
	character = char
	rootPart = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
end
if LocalPlayer and LocalPlayer.Character then
	task.spawn(function() refreshChar(LocalPlayer.Character) end)
end
if LocalPlayer then
	trackConnection(LocalPlayer.CharacterAdded:Connect(function(ch)
		if not alive then return end
		refreshChar(ch)
	end))
end
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
	pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(tool, cfg.Sound1) end end)
	task.wait(0.025)
	pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(tool, cfg.Sound2) end end)
end
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
		local swing = nil
		local pull = nil
		local anim = nil
		if pcall(function() swing = tool:GetAttribute("SwingCooldown") end) then end
		if pcall(function() pull = tool:GetAttribute("PulloutTime") end) then end
		if pcall(function() anim = tool:GetAttribute("AnimationAttack") end) then end
		weaponInfo[tool].swing = tonumber(swing) or weaponInfo[tool].swing
		weaponInfo[tool].pull = tonumber(pull) or weaponInfo[tool].pull
		weaponInfo[tool].anim = tostring(anim) ~= "nil" and tostring(anim) or weaponInfo[tool].anim
	end)
	local c1 = tool.Equipped:Connect(function()
		if not alive then return end
		weaponInfo[tool].equipped = true
	end)
	table.insert(conns, c1); trackConnection(c1)
	local c2 = tool.Unequipped:Connect(function()
		if not alive then return end
		weaponInfo[tool].equipped = false
	end)
	table.insert(conns, c2); trackConnection(c2)
	local c3 = tool.Activated:Connect(function()
		if not alive then return end
		weaponInfo[tool].lastManual = os.clock()
	end)
	table.insert(conns, c3); trackConnection(c3)
	if tool.GetAttribute and tool.AttributeChanged then
		local c4 = tool.AttributeChanged:Connect(function(attr)
			if not alive then return end
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
		end)
		table.insert(conns, c4); trackConnection(c4)
	end
	local c5 = tool.AncestryChanged:Connect(function(child, parent)
		if not alive then
			c5:Disconnect()
			return
		end
		if not tool:IsDescendantOf(game) then
			unhookWeapon(tool)
		end
	end)
	table.insert(conns, c5); trackConnection(c5)
	weaponHooks[tool] = conns
	currentHookedTool = tool
end
local toolListenersInstalled = false
local function hookAllTools()
	if toolListenersInstalled then return end
	toolListenersInstalled = true
	local function tryHookTool(obj)
		if not obj or not obj:IsA("Tool") then return end
		pcall(function()
			hookWeapon(obj)
		end)
	end
	if LocalPlayer and LocalPlayer.Character then
		for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
			tryHookTool(obj)
		end
	end
	if LocalPlayer and LocalPlayer:FindFirstChild("Backpack") then
		for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
			tryHookTool(obj)
		end
	end
	if LocalPlayer then
		local c_backpack = LocalPlayer.ChildAdded:Connect(function(child)
			if not alive then return end
			if child and child:IsA("Backpack") then
				task.delay(0.05, function()
					if LocalPlayer and LocalPlayer:FindFirstChild("Backpack") then
						for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
							tryHookTool(obj)
						end
						trackConnection(LocalPlayer.Backpack.ChildAdded:Connect(function(child2)
							if not alive then return end
							task.delay(0.05, function() tryHookTool(child2) end)
						end))
					end
				end)
			end
		end)
		trackConnection(c_backpack)
	end
	if LocalPlayer and LocalPlayer:FindFirstChild("Backpack") then
		trackConnection(LocalPlayer.Backpack.ChildAdded:Connect(function(child)
			if not alive then return end
			task.delay(0.05, function()
				if alive and child and child:IsA("Tool") then
					pcall(function() hookWeapon(child) end)
				end
			end)
		end))
	end
	if LocalPlayer and LocalPlayer.Character then
		trackConnection(LocalPlayer.Character.ChildAdded:Connect(function(child)
			if not alive then return end
			task.delay(0.05, function()
				if alive and child and child:IsA("Tool") then
					pcall(function() hookWeapon(child) end)
				end
			end)
		end))
	end
end
task.spawn(function()
	table.insert(spawnedTasks, coroutine.running())
	task.wait(0.05)
	if alive then
		pcall(hookAllTools)
	end
end)
local hitQueue = {}
local whitelist = {}
local whitelistButtons = {}

-- Helper: remove a player (by UserId) from lockedTargets and queued hits
local function removePlayerFromLockedTargets(userId)
	if not userId then return end
	if lockedTargets then
		local newLocked = {}
		for _, p in ipairs(lockedTargets) do
			if p and p.UserId ~= userId then
				table.insert(newLocked, p)
			end
		end
		if #newLocked == 0 then
			lockedTargets = nil
			attackLockExpire = 0
		else
			lockedTargets = newLocked
		end
	end
	-- remove any queued hits targeting that player
	for i = #hitQueue, 1, -1 do
		local e = hitQueue[i]
		if e and e.tarPlayer and e.tarPlayer.UserId == userId then
			table.remove(hitQueue, i)
		end
	end
	-- clear aimTarget if it matches
	if aimTarget and aimTarget.UserId == userId then
		aimTarget = nil
	end
end

local function enqueueHit(payload)
	if not payload or not payload.tarHum then return end
	-- If the hit targets a whitelisted player, ignore it
	if payload.tarPlayer and whitelist[payload.tarPlayer.UserId] then
		return
	end
	payload.snapshotHealth = payload.tarHum.Health
	table.insert(hitQueue, payload)
end
spawn(function()
	table.insert(spawnedTasks, coroutine.running())
	while alive do
		if hitFlushInterval and hitFlushInterval > 0 then
			task.wait(hitFlushInterval)
		else
			task.wait()
		end
		if not alive then break end
		if #hitQueue > 0 then
			local toSend = hitQueue
			hitQueue = {}
			for _, entry in ipairs(toSend) do
				if entry and entry.tarHum and entry.tarLimb and entry.tool then
					-- ensure the player wasn't whitelisted in the meantime
					local targetPlr = entry.tarPlayer
					if targetPlr and whitelist[targetPlr.UserId] then
						-- skip
					else
						pcall(function()
							if MeleeSendHit then MeleeSendHit({entry.tarHum, entry.tarLimb, entry.tool}) end
						end)
						if entry.needCommit then
							task.wait(0.03)
							pcall(function()
								if ToolSoundEvent then ToolSoundEvent:FireServer(entry.tool, "Commit") end
							end)
						end
						task.wait(0.02)
					end
				end
			end
		end
	end
end)
spawn(function()
	table.insert(spawnedTasks, coroutine.running())
	while alive do
		task.wait(0.05)
		if not alive then break end
		if #hitQueue > 0 then
			for i = #hitQueue, 1, -1 do
				local entry = hitQueue[i]
				if entry and entry.tarHum and entry.snapshotHealth then
					-- skip if whitelisted
					local targetPlr = entry.tarPlayer
					if targetPlr and whitelist[targetPlr.UserId] then
						table.remove(hitQueue, i)
					else
						local ok, cur = pcall(function() return entry.tarHum.Health end)
						if ok and type(cur) == "number" and cur < entry.snapshotHealth then
							pcall(function()
								if MeleeSendHit then MeleeSendHit({entry.tarHum, entry.tarLimb, entry.tool}) end
							end)
							if entry.needCommit then
								task.wait(0.02)
								pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(entry.tool, "Commit") end end)
							end
							table.remove(hitQueue, i)
						end
					end
				end
			end
		end
	end
end)
local lastObservedHealth = {}
-- collectTargets now skips whitelisted players
local function collectTargets(maxCount, maxRange)
	if not rootPart then return {} end
	local results = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and (not whitelist[plr.UserId]) then
			local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			local tarHum = plr.Character:FindFirstChild("Humanoid")
			if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
				if teamCheck then
					if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
						-- same team -> skip
					else
						local dis = (rootPart.Position - tarRoot.Position).Magnitude
						if dis <= maxRange then
							local limb = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head") or tarRoot
							local params = RaycastParams.new()
							params.FilterType = Enum.RaycastFilterType.Blacklist
							if character then params.FilterDescendantsInstances = {character} end
							local ray = workspace:Raycast(rootPart.Position, limb.Position - rootPart.Position, params)
							if not ray or ray.Instance and ray.Instance:IsDescendantOf(plr.Character) then
								local score = dis
								local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head")
								if head then score = score - 3.0 end
								local toTarget = (tarRoot.Position - rootPart.Position)
								if toTarget.Magnitude > 0 then
									local dir = toTarget.Unit
									local forward = rootPart.CFrame.LookVector
									local dot = forward:Dot(dir)
									if dot and dot > 0.5 then score = score - 1.5 end
								end
								if aimTarget and aimTarget == plr then score = score - 4.0 end
								table.insert(results, {plr=plr, dist=dis, score=score})
							end
						end
					end
				else
					local dis = (rootPart.Position - tarRoot.Position).Magnitude
					if dis <= maxRange then
						local limb = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head") or tarRoot
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Blacklist
						if character then params.FilterDescendantsInstances = {character} end
						local ray = workspace:Raycast(rootPart.Position, limb.Position - rootPart.Position, params)
						if not ray or ray.Instance and ray.Instance:IsDescendantOf(plr.Character) then
							local score = dis
							local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head")
							if head then score = score - 3.0 end
							local tarHum2 = plr.Character:FindFirstChild("Humanoid")
							if tarHum2 and tarHum2.Health and tarHum2.MaxHealth and tarHum2.Health < (tarHum2.MaxHealth * 0.5) then
								score = score - 2.0
							end
							local toTarget = (tarRoot.Position - rootPart.Position)
							if toTarget.Magnitude > 0 then
								local dir = toTarget.Unit
								local forward = rootPart.CFrame.LookVector
								local dot = forward:Dot(dir)
								if dot and dot > 0.5 then score = score - 1.5 end
							end
							if aimTarget and aimTarget == plr then score = score - 4.0 end
							table.insert(results, {plr=plr, dist=dis, score=score})
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
local renderConn = RunService.RenderStepped:Connect(function()
	if not alive then renderConn:Disconnect(); return end
	if not rootPart then return end
	local now = os.clock()
	if silentAim and now - lastSilentTime >= silentCooldown then
		local candidates = collectTargets(1, silentRange)
		local targetPlr = candidates[1]
		if targetPlr and targetPlr.Character then
			-- ensure still not whitelisted (redundant but safe)
			if whitelist[targetPlr.UserId] then
				-- skip
			else
				local tarLimb = targetPlr.Character:FindFirstChild("Head") or targetPlr.Character:FindFirstChild("head") or targetPlr.Character:FindFirstChild("HumanoidRootPart")
				if tarLimb then
					pcall(function()
						lookAtYawOnly(rootPart, tarLimb.Position)
					end)
					lastSilentTime = now
				end
			end
		end
	end
	if autoAttack and silentAim then
		local candidates = collectTargets(1, attackRange)
		local preTarget = candidates[1]
		if preTarget and preTarget.Character then
			-- ensure not whitelisted
			if whitelist[preTarget.UserId] then
				aimTarget = nil
			else
				local tarLimb = preTarget.Character:FindFirstChild("Head") or preTarget.Character:FindFirstChild("head") or preTarget.Character:FindFirstChild("HumanoidRootPart")
				if tarLimb then
					local tarRoot = preTarget.Character:FindFirstChild("HumanoidRootPart")
					local predPos = predictTargetPosition(tarRoot, tarLimb, 0.9)
					pcall(function()
						lookAtYawOnly(rootPart, predPos)
					end)
					aimTarget = preTarget
				end
			end
		else
			aimTarget = nil
		end
	else
		aimTarget = nil
	end
end)
trackConnection(renderConn)
local heartbeatConn = RunService.Heartbeat:Connect(function()
	if not alive then heartbeatConn:Disconnect(); return end
	if not autoAttack or not rootPart then return end
	local now = os.clock()
	local heldTool = (function()
		if not LocalPlayer or not LocalPlayer.Character then return nil end
		local char = LocalPlayer.Character
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then return tool end
		for _, obj in ipairs(char:GetChildren()) do
			if obj and obj:IsA("Tool") then return obj end
		end
		return nil
	end)()
	if heldTool then
	else
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
	-- sanitize lockedTargets to remove any newly-whitelisted players
	if lockedTargets and now < attackLockExpire then
		local filtered = {}
		for _, p in ipairs(lockedTargets) do
			if p and (not whitelist[p.UserId]) then
				table.insert(filtered, p)
			end
		end
		if #filtered == 0 then
			lockedTargets = nil
			attackLockExpire = 0
		else
			lockedTargets = filtered
		end
	end
	if lockedTargets and now < attackLockExpire then
		for _, plr in ipairs(lockedTargets) do
			if plr and plr.Character and (not whitelist[plr.UserId]) then
				local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				local tarHum = plr.Character:FindFirstChild("Humanoid")
				if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
					if (rootPart.Position - tarRoot.Position).Magnitude <= attackRange then
						local limb = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head") or tarRoot
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Blacklist
						if character then params.FilterDescendantsInstances = {character} end
						local ray = workspace:Raycast(rootPart.Position, limb.Position - rootPart.Position, params)
						if not ray or ray.Instance and ray.Instance:IsDescendantOf(plr.Character) then
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
		end
	end
	if (not lockedTargets) or (#targetsToAttack == 0) then
		local newTargets = collectTargets(maxTargets, attackRange)
		if #newTargets == 0 then return end
		lockedTargets = newTargets
		attackLockExpire = now + currentCooldown
		for _, plr in ipairs(lockedTargets) do
			if plr and plr.Character and (not whitelist[plr.UserId]) then
				local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				local tarHum = plr.Character:FindFirstChild("Humanoid")
				if tarRoot and tarHum and tarHum.Health > 0 and tarHum:GetState() ~= Enum.HumanoidStateType.Dead then
					if (rootPart.Position - tarRoot.Position).Magnitude <= attackRange then
						local limb = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("head") or tarRoot
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Blacklist
						if character then params.FilterDescendantsInstances = {character} end
						local ray = workspace:Raycast(rootPart.Position, limb.Position - rootPart.Position, params)
						if not ray or ray.Instance and ray.Instance:IsDescendantOf(plr.Character) then
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
			if plr and plr.UserId and not alreadyAttacked[plr.UserId] and (not whitelist[plr.UserId]) then
				targetPlr = plr
				break
			end
		end
		if not targetPlr then
			local list = collectTargets(20, attackRange)
			for _, p in ipairs(list) do
				if p and p.UserId and not alreadyAttacked[p.UserId] and (not whitelist[p.UserId]) then
					targetPlr = p
					break
				end
			end
		end
		if not targetPlr then break end
		if targetPlr and targetPlr.Character then
			local tarChar = targetPlr.Character
			local tarHum = tarChar:FindFirstChild("Humanoid")
			local tarLimb = tarChar:FindFirstChild("Head") or tarChar:FindFirstChild("head") or tarChar:FindFirstChild("HumanoidRootPart")
			if tarHum and tarLimb then
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
						pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(heldTool, "Swing") end end)
						needCommit = false
					else
						pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(heldTool, "Plan") end end)
						needCommit = true
					end
				end
				local uid = targetPlr.UserId
				local prevHealth = lastObservedHealth[uid] or tarHum.Health
				if tarHum.Health < prevHealth then
					pcall(function()
						if MeleeSendHit then MeleeSendHit({tarHum, tarLimb, heldTool}) end
					end)
					if needCommit then
						task.wait(0.03)
						pcall(function() if ToolSoundEvent then ToolSoundEvent:FireServer(heldTool, "Commit") end end)
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
		if idx < maxTargets then task.wait(0.02) end
	end
end)
trackConnection(heartbeatConn)
local categories = {}
local function openWhitelistPopup()
	if not ScreenGui or not ScreenGui.Parent then return end
	local POP_W, POP_H = 420, 300
	local popup = Instance.new("Frame", ScreenGui)
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.Size = UDim2.new(0, 0, 0, 0)
	popup.Position = UDim2.new(0.5, 0, 0.5, -80)
	popup.BackgroundColor3 = Color3.fromRGB(24,24,26)
	popup.BackgroundTransparency = 1
	popup.BorderSizePixel = 0
	popup.ZIndex = CenterPanel.ZIndex + 400
	local cornerPopup = Instance.new("UICorner", popup)
	cornerPopup.CornerRadius = UDim.new(0,8)
	local title = Instance.new("TextLabel", popup)
	title.Size = UDim2.new(1, -24, 0, 28)
	title.Position = UDim2.new(0, 12, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(230,230,230)
	title.Text = "Whitelist"
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = popup.ZIndex + 1
	local listFrame = Instance.new("ScrollingFrame", popup)
	listFrame.Size = UDim2.new(1, -24, 1, -64)
	listFrame.Position = UDim2.new(0, 12, 0, 44)
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 8
	listFrame.ZIndex = popup.ZIndex + 1
	local listLayout = Instance.new("UIListLayout", listFrame)
	listLayout.Padding = UDim.new(0,6)
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local function makePlayerButton(plr)
		if not plr then return end
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1,0,0,28)
		container.BackgroundTransparency = 1
		container.Parent = listFrame
		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(1,0,0,28)
		btn.Position = UDim2.new(0,0,0,0)
		btn.BackgroundColor3 = Color3.fromRGB(245,240,247)
		btn.BorderSizePixel = 0
		btn.Text = plr.Name .. " (" .. tostring(plr.UserId) .. ")"
		btn.TextColor3 = Color3.fromRGB(80,30,120)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.ZIndex = listFrame.ZIndex + 1
		local corner = Instance.new("UICorner", btn)
		corner.CornerRadius = UDim.new(0,8)
		local details = Instance.new("Frame", container)
		details.Size = UDim2.new(1,0,0,0)
		details.Position = UDim2.new(0,0,0,28)
		details.BackgroundTransparency = 1
		details.BorderSizePixel = 0
		details.ZIndex = btn.ZIndex + 1
		local status = Instance.new("TextLabel", details)
		status.Size = UDim2.new(1, -12, 0, 24)
		status.Position = UDim2.new(0, 6, 0, 0)
		status.BackgroundTransparency = 1
		status.Font = Enum.Font.Gotham
		status.TextSize = 13
		status.Text = whitelist[plr.UserId] and "已加入白名单" or "未加入"
		status.TextColor3 = Color3.fromRGB(200,200,200)
		status.TextXAlignment = Enum.TextXAlignment.Left
		status.ZIndex = details.ZIndex + 1
		local open = false
		local function updateVisual()
			if whitelist[plr.UserId] then
				btn.BackgroundColor3 = Color3.fromRGB(255,220,235)
				btn.TextColor3 = Color3.fromRGB(160,40,140)
				status.Text = "已加入白名单"
			else
				btn.BackgroundColor3 = Color3.fromRGB(245,240,247)
				btn.TextColor3 = Color3.fromRGB(80,30,120)
				status.Text = "未加入"
			end
		end
		local function toggleDetails()
			open = not open
			local targetH = open and 28 or 0
			local tween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(details, tween, {Size = UDim2.new(1,0,0,targetH)}):Play()
		end
		trackConnection(btn.MouseButton1Click:Connect(function()
			if whitelist[plr.UserId] then
				whitelist[plr.UserId] = nil
			else
				whitelist[plr.UserId] = true
			end
			updateVisual()
			toggleDetails()
			-- ensure any locks/queues/aims related to this player are cleared
			removePlayerFromLockedTargets(plr.UserId)
		end))
		whitelistButtons[plr.UserId] = btn
		updateVisual()
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			makePlayerButton(plr)
		end
	end
	trackConnection(Players.PlayerAdded:Connect(function(plr)
		task.delay(0.05, function() makePlayerButton(plr) end)
	end))
	trackConnection(Players.PlayerRemoving:Connect(function(plr)
		local b = whitelistButtons[plr.UserId]
		if b then pcall(function() b:Destroy() end) end
		whitelist[plr.UserId] = nil
		whitelistButtons[plr.UserId] = nil
		-- ensure removed player is also removed from locks/queues
		removePlayerFromLockedTargets(plr.UserId)
	end))
	local closeBtn = Instance.new("TextButton", popup)
	closeBtn.Size = UDim2.new(0, 100, 0, 30)
	closeBtn.Position = UDim2.new(1, -116, 1, -40)
	closeBtn.BackgroundColor3 = Color3.fromRGB(140,140,140)
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
	closeBtn.Text = "关闭"
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)
	closeBtn.ZIndex = popup.ZIndex + 2
	local function showWithAnimation()
		local tweenInfo = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		popup.BackgroundTransparency = 1
		popup.Size = UDim2.new(0, 0, 0, 0)
		popup.Position = UDim2.new(0.5, 0, 0.5, -80)
		TweenService:Create(popup, tweenInfo, {Size = UDim2.new(0, POP_W, 0, POP_H), BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		task.delay(0.26, function()
			makeDraggable(popup)
		end)
	end
	local function closeWithAnimation()
		local tween = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local t1 = TweenService:Create(popup, tween, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -80)})
		t1:Play()
		t1.Completed:Wait()
		pcall(function() popup:Destroy() end)
	end
	closeBtn.MouseButton1Click:Connect(closeWithAnimation)
	showWithAnimation()
end
categories = {
	{
		name = "主要功能",
		items = {
			{
				title = "Auto Attack",
				type = "toggle",
				desc = "自动攻击 开/关",
				defaultOn = autoAttack,
				onToggle = function(on)
					autoAttack = (on == true)
				end
			},
			{
				title = "Silent Aim",
				type = "toggle",
				desc = "静默瞄准 开/关",
				defaultOn = silentAim,
				onToggle = function(on)
					silentAim = (on == true)
				end
			},
			{
				title = "Always Aim Head",
				type = "toggle",
				desc = "优先瞄准头部",
				defaultOn = alwaysHead,
				onToggle = function(on)
					alwaysHead = (on == true)
				end
			},
			{
				title = "Team Check",
				type = "toggle",
				desc = "是否检查队伍",
				defaultOn = teamCheck,
				onToggle = function(on)
					teamCheck = (on == true)
				end
			},
			{
				title = "Use Native Weapon Speed",
				type = "toggle",
				desc = "使用武器自身冷却",
				defaultOn = useNativeSpeed,
				onToggle = function(on)
					useNativeSpeed = (on == true)
				end
			},
			{
				title = "Latency Compensation (by Ping)",
				type = "toggle",
				desc = "延迟补偿（按 Ping）",
				defaultOn = latencyCompEnabled,
				onToggle = function(on)
					latencyCompEnabled = (on == true)
				end
			},
			{
				title = "Attack Range",
				type = "slider",
				min = 0,
				max = 14,
				default = attackRange,
				desc = "攻击范围（米）",
				onChange = function(v)
					attackRange = math.floor(tonumber(v) or attackRange)
				end
			},
			{
				title = "Attack Cooldown (s)",
				type = "slider",
				min = 0.05,
				max = 5,
				default = attackCoolDown,
				desc = "攻击冷却（秒）",
				onChange = function(v)
					attackCoolDown = math.max(0.05, tonumber(v) or attackCoolDown)
				end
			},
			{
				title = "Targets (simultaneous)",
				type = "slider",
				min = 1,
				max = 3,
				default = maxTargets,
				desc = "同时攻击目标数量",
				onChange = function(v)
					local n = math.clamp(math.floor((tonumber(v) or maxTargets)+0.5), 1, 3)
					maxTargets = n
				end
			},
			{
				title = "Silent Aim Range",
				type = "slider",
				min = 0,
				max = 20,
				default = silentRange,
				desc = "静默瞄准范围",
				onChange = function(v)
					silentRange = math.floor((tonumber(v) or silentRange) * 100 + 0.5) / 100
				end
			},
			{
				title = "Silent Cooldown (s)",
				type = "slider",
				min = 0,
				max = 5,
				default = silentCooldown,
				desc = "静默冷却（秒）",
				onChange = function(v)
					silentCooldown = math.floor((tonumber(v) or silentCooldown) * 100 + 0.5) / 100
				end
			},
			{
				title = "Hit Send Delay (s)",
				type = "slider",
				min = 0,
				max = 1,
				default = hitFlushInterval,
				desc = "发送击中包延迟",
				onChange = function(v)
					hitFlushInterval = math.clamp(tonumber(v) or hitFlushInterval, 0, 10)
				end
			},
			{
				title = "Latency Factor",
				type = "slider",
				min = 0.1,
				max = 3,
				default = latencyFactor,
				desc = "延迟补偿因子",
				onChange = function(v)
					latencyFactor = math.max(0.1, tonumber(v) or latencyFactor)
				end
			},
			{
				title = "Whitelist",
				desc = "打开白名单窗口",
				onClick = function()
					openWhitelistPopup()
				end
			},
			{
				title = "Stop & Cleanup",
				desc = "停止脚本并清理 UI",
				onClick = function()
					cleanupEverything()
				end
			},
			{
				title = "Re-hook Tools",
				desc = "重新挂载武器监听（调试）",
				onClick = function()
					pcall(function() hookAllTools() end)
				end
			}
		}
	}
}
renderLeft(categories)
if categories[1] then
	renderRight(categories[1].items or {})
	RightTitle.Text = categories[1].name or "内容"
end
local dragging = false
local dragInput = nil
local dragStart = Vector2.new(0,0)
local panelStart = Vector2.new(0,0)
local function readInputPosition(input)
	local ok, pos = pcall(function() return input.Position end)
	if ok and pos then return pos end
	local ok2, mpos = pcall(function() return UserInputService:GetMouseLocation() end)
	if ok2 and mpos then return mpos end
	return nil
end
local function onInputBeganForDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragInput = input
		local pos = readInputPosition(input)
		if pos then
			dragStart = pos
		else
			dragStart = Vector2.new(0,0)
		end
		local ap = CenterPanel.AbsolutePosition
		if typeof(ap) == "Vector2" then
			panelStart = ap
		else
			panelStart = Vector2.new(ap.X or 0, ap.Y or 0)
		end
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				dragInput = nil
			end
		end)
	end
end
TitleLabel.InputBegan:Connect(onInputBeganForDrag)
CenterPanel.InputBegan:Connect(onInputBeganForDrag)
UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	local pos = readInputPosition(input)
	if not pos then return end
	local delta = pos - dragStart
	local newAbs = Vector2.new(panelStart.X + delta.X, panelStart.Y + delta.Y)
	CenterPanel.Position = UDim2.new(0, newAbs.X, 0, newAbs.Y)
end)
local MiniBtn = Instance.new("TextButton", CenterPanel)
MiniBtn.Size = UDim2.new(0, 28, 0, 28)
MiniBtn.Position = UDim2.new(1, -36, 0, 6)
MiniBtn.AnchorPoint = Vector2.new(0, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
MiniBtn.BackgroundTransparency = 0.02
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 16
MiniBtn.Text = "●"
MiniBtn.TextColor3 = Color3.fromRGB(80,80,80)
MiniBtn.ZIndex = CenterPanel.ZIndex + 50
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0,6)
if IS_PC then
	pcall(function()
		MiniBtn.Visible = false
		MiniBtn.Active = false
		MiniBtn.AutoButtonColor = false
	end)
end
local IsBall = false
local savedState = {}
local HITBOX_SIZE = 120
local BallHitbox = Instance.new("Frame", ScreenGui)
BallHitbox.Name = "BallHitbox"
BallHitbox.Size = UDim2.new(0, HITBOX_SIZE, 0, HITBOX_SIZE)
BallHitbox.BackgroundTransparency = 1
BallHitbox.BorderSizePixel = 0
BallHitbox.ZIndex = CenterPanel.ZIndex + 200
BallHitbox.Visible = false
BallHitbox.Active = true
BallHitbox.ClipsDescendants = false
if IS_PC then
	pcall(function()
		BallHitbox.Visible = false
		BallHitbox.Active = false
	end)
end
local CLICK_RADIUS_FACTOR = 0.62
local function isPosInsideBall(pos, clickOnly)
	if not pos then return false end
	local ballTopLeft = savedState.BallAbsPosition
	local ballTarget = savedState.BallTarget
	if not ballTopLeft or not ballTarget then
		local ok, abs = pcall(function() return CenterPanel.AbsolutePosition, CenterPanel.AbsoluteSize end)
		if ok and abs and abs ~= nil then
			local absPos, absSize = abs[1], abs[2]
			if absPos and absSize then
				ballTopLeft = Vector2.new(absPos.X, absPos.Y)
				ballTarget = {W = absSize.X, H = absSize.Y}
			end
		end
	end
	if not ballTopLeft or not ballTarget then return false end
	local bw, bh = ballTarget.W or 48, ballTarget.H or 48
	local center = Vector2.new(ballTopLeft.X + bw/2, ballTopLeft.Y + bh/2)
	local dx = pos.X - center.X
	local dy = pos.Y - center.Y
	local dist = math.sqrt(dx*dx + dy*dy)
	local radius = math.max(bw, bh) / 2
	if clickOnly then
		radius = radius * CLICK_RADIUS_FACTOR
	end
	return dist <= radius
end
local isAnimating = false
local _origCenterClips = CenterPanel.ClipsDescendants
local _origCenterBg = CenterPanel.BackgroundColor3
local _origCenterBgTrans = CenterPanel.BackgroundTransparency
local _origCenterCorner = CenterCorner.CornerRadius
local function shrinkToBall()
	if IsBall then return end
	if isAnimating then return end
	isAnimating = true
	local panelAbsPos, panelAbsSize = (function() return CenterPanel.AbsolutePosition, CenterPanel.AbsoluteSize end)()
	savedState.PanelAbsPosition = Vector2.new(panelAbsPos.X, panelAbsPos.Y)
	savedState.PanelAbsSize = Vector2.new(panelAbsSize.X, panelAbsSize.Y)
	local targetW, targetH = 48, 48
	local ballTopLeft
	if savedState.BallAbsPosition then
		ballTopLeft = Vector2.new(savedState.BallAbsPosition.X, savedState.BallAbsPosition.Y)
	else
		ballTopLeft = Vector2.new(math.floor(savedState.PanelAbsPosition.X + savedState.PanelAbsSize.X/2 - targetW/2), math.floor(savedState.PanelAbsPosition.Y + savedState.PanelAbsSize.Y/2 - targetH/2))
	end
	local hitOffsetX = math.floor((HITBOX_SIZE - targetW) / 2)
	local hitOffsetY = math.floor((HITBOX_SIZE - targetH) / 2)
	savedState.BallTarget = {W = targetW, H = targetH, HitOffsetX = hitOffsetX, HitOffsetY = hitOffsetY}
	savedState.BallAbsPosition = Vector2.new(ballTopLeft.X, ballTopLeft.Y)
	IsBall = true
	pcall(function() StatusFrame.Visible = false end)
	pcall(function() CenterPanel.ClipsDescendants = true end)
	local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = TweenService:Create(CenterPanel, tweenInfo, {
		Size = UDim2.new(0, targetW, 0, targetH),
		Position = UDim2.new(0, ballTopLeft.X, 0, ballTopLeft.Y)
	})
	t:Play()
	t.Completed:Connect(function()
		CenterCorner.CornerRadius = UDim.new(1,0)
		CenterPanel.BackgroundColor3 = PINK_BG
		CenterPanel.BackgroundTransparency = 0
		TitleLabel.Visible = false
		LeftArea.Visible = false
		RightArea.Visible = false
		MiniBtn.Visible = false
		pcall(function() StatusFrame.Visible = false end)
		BallHitbox.Position = UDim2.new(0, ballTopLeft.X - hitOffsetX, 0, ballTopLeft.Y - hitOffsetY)
		BallHitbox.Visible = true
		isAnimating = false
	end)
end
local function restoreFromBall()
	if not IsBall then return end
	if isAnimating then return end
	isAnimating = true
	IsBall = false
	BallHitbox.Visible = false
	CenterCorner.CornerRadius = _origCenterCorner or UDim.new(0,12)
	CenterPanel.BackgroundColor3 = _origCenterBg or PINK_BG
	CenterPanel.BackgroundTransparency = _origCenterBgTrans or 0.05
	TitleLabel.Visible = true
	LeftArea.Visible = true
	RightArea.Visible = true
	MiniBtn.Visible = true
	local targetPos = savedState.PanelAbsPosition or Vector2.new( (workspace.CurrentCamera.ViewportSize.X - PANEL_WIDTH)/2, (workspace.CurrentCamera.ViewportSize.Y/2 + CENTER_Y_OFFSET) )
	local targetSize = savedState.PanelAbsSize or Vector2.new(PANEL_WIDTH, PANEL_HEIGHT)
	pcall(function() CenterPanel.ClipsDescendants = true end)
	local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = TweenService:Create(CenterPanel, tweenInfo, {
		Size = UDim2.new(0, targetSize.X, 0, targetSize.Y),
		Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
	})
	t:Play()
	t.Completed:Connect(function()
		pcall(function() StatusFrame.Visible = true end)
		pcall(function() CenterPanel.ClipsDescendants = _origCenterClips end)
		isAnimating = false
	end)
end
MiniBtn.MouseButton1Click:Connect(function()
	if isAnimating then return end
	if IsBall then
		restoreFromBall()
	else
		shrinkToBall()
	end
end)
do
	local ballDragging = false
	local ballDragInput = nil
	local ballDragStart = Vector2.new(0,0)
	local ballHitStartPanelTopLeft = Vector2.new(0,0)
	local DRAG_THRESHOLD = 6
	local function readInputPosition2(input)
		local ok, pos = pcall(function() return input.Position end)
		if ok and pos then return pos end
		local ok2, mpos = pcall(function() return UserInputService:GetMouseLocation() end)
		if ok2 and mpos then return mpos end
		return nil
	end
	local function onBallInputBegan(input)
		if not IsBall then return end
		if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then return end
		local pos = readInputPosition2(input)
		if not pos then return end
		if not isPosInsideBall(pos, false) then
			return
		end
		ballDragging = true
		ballDragInput = input
		ballDragStart = pos
		local panelAbsPos = CenterPanel.AbsolutePosition
		ballHitStartPanelTopLeft = Vector2.new(panelAbsPos.X, panelAbsPos.Y)
		local maybeClick = true
		local inputRef = input
		input.Changed:Connect(function()
			if inputRef.UserInputState == Enum.UserInputState.End then
				if maybeClick then
					local endPos = readInputPosition2(inputRef)
					if endPos and isPosInsideBall(endPos, true) then
						restoreFromBall()
					end
				else
					if savedState.BallAbsPosition then
						local curPanelPos = CenterPanel.AbsolutePosition
						savedState.BallAbsPosition = Vector2.new(curPanelPos.X, curPanelPos.Y)
					end
				end
				ballDragging = false
				ballDragInput = nil
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if inp ~= ballDragInput or not ballDragging then return end
			local pos = readInputPosition2(inp)
			if not pos then return end
			local delta = pos - ballDragStart
			if maybeClick and (math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD) then
				maybeClick = false
			end
			local newPanelTopLeft = Vector2.new(ballHitStartPanelTopLeft.X + delta.X, ballHitStartPanelTopLeft.Y + delta.Y)
			CenterPanel.Position = UDim2.new(0, newPanelTopLeft.X, 0, newPanelTopLeft.Y)
			savedState.BallAbsPosition = Vector2.new(newPanelTopLeft.X, newPanelTopLeft.Y)
			if savedState.BallTarget then
				local hitOffsetX = savedState.BallTarget.HitOffsetX or math.floor((HITBOX_SIZE - savedState.BallTarget.W)/2)
				local hitOffsetY = savedState.BallTarget.HitOffsetY or math.floor((HITBOX_SIZE - savedState.BallTarget.H)/2)
				BallHitbox.Position = UDim2.new(0, newPanelTopLeft.X - hitOffsetX, 0, newPanelTopLeft.Y - hitOffsetY)
			else
				BallHitbox.Position = UDim2.new(0, newPanelTopLeft.X - math.floor((HITBOX_SIZE-48)/2), 0, newPanelTopLeft.Y - math.floor((HITBOX_SIZE-48)/2))
			end
		end)
	end
	BallHitbox.InputBegan:Connect(onBallInputBegan)
	CenterPanel.InputBegan:Connect(function(input)
		if IsBall then onBallInputBegan(input) end
	end)
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Delete and alive then
		alive = false
		pcall(function() ScreenGui:Destroy() end)
	end
end)
local function enableAnyKeyListener(bind)
	local AnyKeyConn
	if bind then
		AnyKeyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == bind then
					if IsBall then restoreFromBall() else shrinkToBall() end
				end
			end
		end)
		table.insert(trackedConnections, AnyKeyConn)
	end
end
local AnyKeyBind = nil
local BindingPrompt = nil
local function showKeyBindPrompt()
	if not IS_PC then return end
	if BindingPrompt and BindingPrompt.Parent then
		pcall(function() BindingPrompt:Destroy() end)
		BindingPrompt = nil
	end
	BindingPrompt = Instance.new("Frame", ScreenGui)
	BindingPrompt.Size = UDim2.new(0, 360, 0, 120)
	BindingPrompt.Position = UDim2.new(0.5, -180, 0.5, -60)
	BindingPrompt.BackgroundColor3 = Color3.fromRGB(20,20,22)
	BindingPrompt.BackgroundTransparency = 0.02
	BindingPrompt.BorderSizePixel = 0
	BindingPrompt.ZIndex = CenterPanel.ZIndex + 400
	Instance.new("UICorner", BindingPrompt).CornerRadius = UDim.new(0, 8)
	local title = Instance.new("TextLabel", BindingPrompt)
	title.Size = UDim2.new(1, -24, 0, 28)
	title.Position = UDim2.new(0, 12, 0, 12)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(200,200,200)
	title.Text = "按下要绑定的任意键（Esc 取消）"
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.ZIndex = BindingPrompt.ZIndex + 1
	local hint = Instance.new("TextLabel", BindingPrompt)
	hint.Size = UDim2.new(1, -24, 0, 48)
	hint.Position = UDim2.new(0, 12, 0, 44)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.TextSize = 14
	hint.TextColor3 = Color3.fromRGB(160,160,160)
	hint.Text = "按下后将保存该键，之后按该键即可切换小球/恢复"
	hint.TextWrapped = true
	hint.TextXAlignment = Enum.TextXAlignment.Center
	hint.ZIndex = BindingPrompt.ZIndex + 1
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local kc = input.KeyCode
			if kc == Enum.KeyCode.Escape then
				if conn then pcall(function() conn:Disconnect() end) end
				pcall(function() BindingPrompt:Destroy() end)
				BindingPrompt = nil
				return
			end
			AnyKeyBind = kc
			if conn then pcall(function() conn:Disconnect() end) end
			pcall(function() BindingPrompt:Destroy() end)
			BindingPrompt = nil
			enableAnyKeyListener(AnyKeyBind)
		end
	end)
	makeDraggable(BindingPrompt)
end
local function tryResolveReplication()
	pcall(function() ToolSoundEvent = ToolSoundEvent or ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("ToolSound") end)
	pcall(function()
		if not MeleeSendHit then
			local ServiceFolder = ReplicatedStorage:FindFirstChild("Service")
			if ServiceFolder then
				local ok, nm = pcall(function() return require(ServiceFolder:FindFirstChild("Namespaces")) end)
				if ok and nm and nm.MeleeReplication and nm.MeleeReplication.packets and nm.MeleeReplication.packets.sendHit then
					MeleeSendHit = nm.MeleeReplication.packets.sendHit.send
				end
			end
		end
	end)
end
spawn(function()
	while ScreenGui and ScreenGui.Parent do
		task.wait(1)
	end
	cleanupEverything()
end)
