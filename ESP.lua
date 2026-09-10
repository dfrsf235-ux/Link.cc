task.spawn(function()
    task.wait(15)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local Workspace, RunService, Players, Lighting = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), cloneref(game:GetService("Lighting"))
    local lplayer = Players.LocalPlayer
    local Cam = Workspace.CurrentCamera
    local RotationAngle, Tick = -45, tick()
    local Weapon_Icons = {
        ["Wooden Bow"] = "http://www.roblox.com/asset/?id=17677465400",
        ["Crossbow"] = "http://www.roblox.com/asset/?id=17677473017",
        ["Salvaged SMG"] = "http://www.roblox.com/asset/?id=17677463033",
        ["Salvaged AK47"] = "http://www.roblox.com/asset/?id=17677455113",
        ["Salvaged AK74u"] = "http://www.roblox.com/asset/?id=17677442346",
        ["Salvaged M14"] = "http://www.roblox.com/asset/?id=17677444642",
        ["Salvaged Python"] = "http://www.roblox.com/asset/?id=17677451737",
        ["Military PKM"] = "http://www.roblox.com/asset/?id=17677449448",
        ["Military M4A1"] = "http://www.roblox.com/asset/?id=17677479536",
        ["Bruno's M4A1"] = "http://www.roblox.com/asset/?id=17677471185",
        ["Military Barrett"] = "http://www.roblox.com/asset/?id=17677482998",
        ["Salvaged Skorpion"] = "http://www.roblox.com/asset/?id=17677459658",
        ["Salvaged Pump Action"] = "http://www.roblox.com/asset/?id=17677457186",
        ["Military AA12"] = "http://www.roblox.com/asset/?id=17677475227",
        ["Salvaged Break Action"] = "http://www.roblox.com/asset/?id=17677468751",
        ["Salvaged Pipe Rifle"] = "http://www.roblox.com/asset/?id=17677468751",
        ["Salvaged P250"] = "http://www.roblox.com/asset/?id=17677447257",
        ["Nail Gun"] = "http://www.roblox.com/asset/?id=17677484756"
    }
    local Functions = {}
    do
        function Functions:Create(Class, Properties)
            local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
            for Property, Value in pairs(Properties) do
                _Instance[Property] = Value
            end
            return _Instance
        end
        function Functions:FadeOutOnDist(element, distance, ESP)
            local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
            if element:IsA("TextLabel") then
                element.TextTransparency = 1 - transparency
            elseif element:IsA("ImageLabel") then
                element.ImageTransparency = 1 - transparency
            elseif element:IsA("UIStroke") then
                element.Transparency = 1 - transparency
            elseif element:IsA("Frame") then
                element.BackgroundTransparency = 1 - transparency
            elseif element:IsA("Highlight") then
                element.FillTransparency = 1 - transparency
                element.OutlineTransparency = 1 - transparency
            end
        end
    end
    local function getRig(plr)
        local char = plr and plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return nil
        end
        local vms = workspace:FindFirstChild("Viewmodels")
        if not vms then
            return nil
        end
        local best, bestD = nil, 10
        for _, m in ipairs(vms:GetChildren()) do
            if m:IsA("Model") then
                local head = m:FindFirstChild("head")
                local pos = head and head.Position or m:GetPivot().Position
                local d = (pos - hrp.Position).Magnitude
                if d < bestD then
                    best, bestD = m, d
                end
            end
        end
        return best
    end
    local ESP = {
        Enabled = true,
        TeamCheck = true,
        MaxDistance = 200,
        FontSize = 11,
        FadeOut = {
            OnDistance = true,
            OnDeath = false,
            OnLeave = false
        },
        Options = {
            Teamcheck = false,
            TeamcheckRGB = Color3.fromRGB(0, 255, 0),
            Friendcheck = true,
            FriendcheckRGB = Color3.fromRGB(0, 255, 0),
            Highlight = false,
            HighlightRGB = Color3.fromRGB(255, 0, 0)
        },
        Drawing = {
            Chams = {
                Enabled = true,
                Thermal = true,
                FillRGB = Color3.fromRGB(119, 120, 255),
                Fill_Transparency = 100,
                OutlineRGB = Color3.fromRGB(119, 120, 255),
                Outline_Transparency = 100,
                VisibleCheck = true
            },
            Names = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255)
            },
            Flags = {
                Enabled = true
            },
            Distances = {
                Enabled = true,
                Position = "Text",
                RGB = Color3.fromRGB(255, 255, 255)
            },
            Weapons = {
                Enabled = true,
                WeaponTextRGB = Color3.fromRGB(119, 120, 255),
                Outlined = false,
                Gradient = false,
                GradientRGB1 = Color3.fromRGB(255, 255, 255),
                GradientRGB2 = Color3.fromRGB(119, 120, 255)
            },
            Healthbar = {
                Enabled = true,
                HealthText = true,
                Lerp = false,
                HealthTextRGB = Color3.fromRGB(119, 120, 255),
                Width = 3.5,
                Gradient = true,
                GradientRGB1 = Color3.fromRGB(200, 0, 0),
                GradientRGB2 = Color3.fromRGB(60, 60, 125),
                GradientRGB3 = Color3.fromRGB(119, 120, 255),
                LengthScale = 1.2
            },
            Boxes = {
                Animate = true,
                RotationSpeed = 300,
                Gradient = false,
                GradientRGB1 = Color3.fromRGB(119, 120, 255),
                GradientRGB2 = Color3.fromRGB(0, 0, 0),
                GradientFill = true,
                GradientFillRGB1 = Color3.fromRGB(119, 120, 255),
                GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
                Filled = {
                    Enabled = true,
                    Transparency = 0.75,
                    RGB = Color3.fromRGB(0, 0, 0)
                },
                Full = {
                    Enabled = true,
                    RGB = Color3.fromRGB(255, 255, 255)
                },
                Corner = {
                    Enabled = true,
                    RGB = Color3.fromRGB(255, 255, 255)
                },
                Scale = 1.25,
                CornerScale = 1.6
            }
        },
        Connections = {
            RunService = RunService
        },
        Fonts = {}
    }

    -- Ensure global whitelist exists (safe if Aimbot script not yet run)
    if getgenv then
        if not getgenv().AimbotWhitelist then
            getgenv().AimbotWhitelist = {}
        end
    end

    local CurrentTarget = nil
    local function CreateESPHolder()
        local existing = CoreGui:FindFirstChild("ESPHolder")
        if existing then
            existing:Destroy()
        end
        local ScreenGui = Functions:Create("ScreenGui", {
            Parent = CoreGui,
            Name = "ESPHolder",
            ResetOnSpawn = false
        })
        return ScreenGui
    end
    local function StartESP()
        local ScreenGui = CreateESPHolder()
        local function DupeCheck(plr)
            if ScreenGui:FindFirstChild(plr.Name) then
                ScreenGui[plr.Name]:Destroy()
            end
        end
        local function ESPForPlayer(plr)
            coroutine.wrap(DupeCheck)(plr)
            local Name = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
            local Distance = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
            local Weapon = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
            local Box = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
            local Gradient1 = Functions:Create("UIGradient", {Parent = Box, Enabled = ESP.Drawing.Boxes.GradientFill, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)}})
            local Outline = Functions:Create("UIStroke", {Parent = Box, Enabled = ESP.Drawing.Boxes.Gradient, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
            local Gradient2 = Functions:Create("UIGradient", {Parent = Outline, Enabled = ESP.Drawing.Boxes.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)}})
            local Healthbar = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
            local BehindHealthbar = Functions:Create("Frame", {Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
            local HealthText = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
            local Chams = Functions:Create("Highlight", {Parent = ScreenGui, FillTransparency = 1, OutlineTransparency = 0, OutlineColor = ESP.Drawing.Chams.OutlineRGB, DepthMode = "AlwaysOnTop"})
            local WeaponIcon = Functions:Create("ImageLabel", {Parent = ScreenGui, BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(0, 40, 0, 40)})
            local Gradient3 = Functions:Create("UIGradient", {Parent = WeaponIcon, Rotation = -90, Enabled = ESP.Drawing.Weapons.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Weapons.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Weapons.GradientRGB2)}})
            local LeftTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local LeftSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local RightTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local RightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local BottomSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local BottomDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local BottomRightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local BottomRightDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
            local Flag1 = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
            local Flag2 = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
            local fixedW, fixedH, fixedComputed, fixedBaseDist = nil, nil, false, nil
            plr.CharacterAdded:Connect(function()
                fixedComputed = false
                fixedW, fixedH, fixedBaseDist = nil, nil, nil
            end)
            local Updater = function()
                local Connection
                local function HideESP()
                    Box.Visible = false
                    Name.Visible = false
                    Distance.Visible = false
                    Weapon.Visible = false
                    Healthbar.Visible = false
                    BehindHealthbar.Visible = false
                    HealthText.Visible = false
                    WeaponIcon.Visible = false
                    LeftTop.Visible = false
                    LeftSide.Visible = false
                    BottomSide.Visible = false
                    BottomDown.Visible = false
                    RightTop.Visible = false
                    RightSide.Visible = false
                    BottomRightSide.Visible = false
                    BottomRightDown.Visible = false
                    Flag1.Visible = false
                    Chams.Enabled = false
                    Flag2.Visible = false
                    if not plr then
                        ScreenGui:Destroy()
                        if Connection then
                            Connection:Disconnect()
                        end
                    end
                end
                Connection = RunService.RenderStepped:Connect(function()
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local HRP = char.HumanoidRootPart
                        local Humanoid = char:FindFirstChild("Humanoid")
                        local rig = getRig(plr)
                        local cf, sz
                        if rig then
                            cf, sz = rig:GetBoundingBox()
                        else
                            cf, sz = CFrame.new(HRP.Position), Vector3.new(1, 2, 1)
                        end
                        local Pos, OnScreen = Cam:WorldToScreenPoint(cf.Position)
                        local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                        if OnScreen and Dist <= ESP.MaxDistance and ESP.Enabled then
                            local sc = 1
                            if Pos.Z and Pos.Z > 0 then
                                sc = Cam.ViewportSize.Y / (Pos.Z * 2)
                            end
                            if not fixedComputed then
                                fixedW = math.max(16, sz.X * sc * ESP.Drawing.Boxes.Scale)
                                fixedH = math.max(32, sz.Y * sc * ESP.Drawing.Boxes.Scale)
                                fixedBaseDist = Dist > 0 and Dist or 1
                                fixedComputed = true
                            end
                            local scale = 1
                            if fixedBaseDist and Dist and Dist > 0 then
                                scale = math.min(1, fixedBaseDist / Dist)
                                scale = math.max(0.3, scale)
                            end
                            local w = fixedW * scale
                            local h = fixedH * scale
                            if ESP.FadeOut.OnDistance then
                                Functions:FadeOutOnDist(Box, Dist, ESP)
                                Functions:FadeOutOnDist(Outline, Dist, ESP)
                                Functions:FadeOutOnDist(Name, Dist, ESP)
                                Functions:FadeOutOnDist(Distance, Dist, ESP)
                                Functions:FadeOutOnDist(Weapon, Dist, ESP)
                                Functions:FadeOutOnDist(Healthbar, Dist, ESP)
                                Functions:FadeOutOnDist(BehindHealthbar, Dist, ESP)
                                Functions:FadeOutOnDist(HealthText, Dist, ESP)
                                Functions:FadeOutOnDist(WeaponIcon, Dist, ESP)
                                Functions:FadeOutOnDist(LeftTop, Dist, ESP)
                                Functions:FadeOutOnDist(LeftSide, Dist, ESP)
                                Functions:FadeOutOnDist(BottomSide, Dist, ESP)
                                Functions:FadeOutOnDist(BottomDown, Dist, ESP)
                                Functions:FadeOutOnDist(RightTop, Dist, ESP)
                                Functions:FadeOutOnDist(RightSide, Dist, ESP)
                                Functions:FadeOutOnDist(BottomRightSide, Dist, ESP)
                                Functions:FadeOutOnDist(BottomRightDown, Dist, ESP)
                                Functions:FadeOutOnDist(Chams, Dist, ESP)
                                Functions:FadeOutOnDist(Flag1, Dist, ESP)
                                Functions:FadeOutOnDist(Flag2, Dist, ESP)
                            end
                            if ESP.TeamCheck and plr ~= lplayer and ((lplayer.Team ~= plr.Team and plr.Team) or (not lplayer.Team and not plr.Team)) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                                Chams.Adornee = rig or plr.Character
                                Chams.Enabled = ESP.Drawing.Chams.Enabled
                                Chams.FillColor = ESP.Drawing.Chams.FillRGB
                                Chams.OutlineColor = ESP.Drawing.Chams.OutlineRGB
                                if ESP.Drawing.Chams.Thermal then
                                    local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
                                    Chams.FillTransparency = ESP.Drawing.Chams.Fill_Transparency * breathe_effect * 0.01
                                    Chams.OutlineTransparency = ESP.Drawing.Chams.Outline_Transparency * breathe_effect * 0.01
                                end
                                if ESP.Drawing.Chams.VisibleCheck then
                                    Chams.DepthMode = "Occluded"
                                else
                                    Chams.DepthMode = "AlwaysOnTop"
                                end
                                LeftTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftTop.Size = UDim2.new(0, w / 5 * ESP.Drawing.Boxes.CornerScale, 0, 1)
                                LeftSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftSide.Size = UDim2.new(0, 1, 0, h / 5 * ESP.Drawing.Boxes.CornerScale)
                                BottomSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomSide.Size = UDim2.new(0, 1, 0, h / 5 * ESP.Drawing.Boxes.CornerScale)
                                BottomSide.AnchorPoint = Vector2.new(0, 5)
                                BottomDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomDown.Size = UDim2.new(0, w / 5 * ESP.Drawing.Boxes.CornerScale, 0, 1)
                                BottomDown.AnchorPoint = Vector2.new(0, 1)
                                RightTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
                                RightTop.Size = UDim2.new(0, w / 5 * ESP.Drawing.Boxes.CornerScale, 0, 1)
                                RightTop.AnchorPoint = Vector2.new(1, 0)
                                RightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
                                RightSide.Size = UDim2.new(0, 1, 0, h / 5 * ESP.Drawing.Boxes.CornerScale)
                                RightSide.AnchorPoint = Vector2.new(0, 0)
                                BottomRightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5 * ESP.Drawing.Boxes.CornerScale)
                                BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                                BottomRightDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightDown.Size = UDim2.new(0, w / 5 * ESP.Drawing.Boxes.CornerScale, 0, 1)
                                BottomRightDown.AnchorPoint = Vector2.new(1, 1)
                                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                Box.Size = UDim2.new(0, w, 0, h)
                                Box.Visible = ESP.Drawing.Boxes.Full.Enabled
                                if ESP.Drawing.Boxes.Filled.Enabled then
                                    Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    if ESP.Drawing.Boxes.GradientFill then
                                        Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency
                                    else
                                        Box.BackgroundTransparency = 1
                                    end
                                    Box.BorderSizePixel = 1
                                else
                                    Box.BackgroundTransparency = 1
                                end
                                RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                                if ESP.Drawing.Boxes.Animate then
                                    Gradient1.Rotation = RotationAngle
                                    Gradient2.Rotation = RotationAngle
                                else
                                    Gradient1.Rotation = -45
                                    Gradient2.Rotation = -45
                                end
                                Tick = tick()
                                local health = Humanoid.Health / Humanoid.MaxHealth
                                local hbFullHeight = h * ESP.Drawing.Healthbar.LengthScale
                                local hbTop = Pos.Y - hbFullHeight / 2
                                Healthbar.Visible = ESP.Drawing.Healthbar.Enabled
                                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, hbTop + hbFullHeight * (1 - health))
                                Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, hbFullHeight * health)
                                BehindHealthbar.Visible = ESP.Drawing.Healthbar.Enabled
                                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, hbTop)
                                BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, hbFullHeight)
                                if ESP.Drawing.Healthbar.HealthText then
                                    local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                                    HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 6 + ESP.Drawing.Healthbar.Width + 2, 0, hbTop + hbFullHeight * (1 - health) + 3)
                                    HealthText.Text = tostring(healthPercentage)
                                    HealthText.Visible = Humanoid.Health < Humanoid.MaxHealth
                                    if ESP.Drawing.Healthbar.Lerp then
                                        local color = health >= 0.75 and Color3.fromRGB(0, 255, 0) or health >= 0.5 and Color3.fromRGB(255, 255, 0) or health >= 0.25 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 0, 0)
                                        HealthText.TextColor3 = color
                                    else
                                        HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
                                    end
                                end
                                Name.Visible = ESP.Drawing.Names.Enabled

                                -- New: read global whitelist safely and render name color with priority:
                                -- whitelist > friend > enemy
                                local whitelist = (getgenv and getgenv().AimbotWhitelist) or {}

                                if whitelist[plr.UserId] then
                                    -- White-listed: (W) player's name, W is green (0,255,0)
                                    Name.Text = string.format('(<font color="rgb(%d, %d, %d)">W</font>) %s', 0, 255, 0, plr.Name)
                                elseif ESP.Options.Friendcheck and lplayer:IsFriendsWith(plr.UserId) then
                                    -- Friend: (F) green per FriendcheckRGB
                                    Name.Text = string.format('(<font color="rgb(%d, %d, %d)">F</font>) %s', ESP.Options.FriendcheckRGB.R * 255, ESP.Options.FriendcheckRGB.G * 255, ESP.Options.FriendcheckRGB.B * 255, plr.Name)
                                else
                                    -- Enemy: (E) red
                                    Name.Text = string.format('(<font color="rgb(%d, %d, %d)">E</font>) %s', 255, 0, 0, plr.Name)
                                end

                                Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
                                if ESP.Drawing.Distances.Enabled then
                                    if ESP.Drawing.Distances.Position == "Bottom" then
                                        Weapon.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 18)
                                        WeaponIcon.Position = UDim2.new(0, Pos.X - 21, 0, Pos.Y + h / 2 + 15)
                                        Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                                        Distance.Text = string.format("%d meters", math.floor(Dist))
                                        Distance.Visible = true
                                    elseif ESP.Drawing.Distances.Position == "Text" then
                                        Weapon.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 8)
                                        WeaponIcon.Position = UDim2.new(0, Pos.X - 21, 0, Pos.Y + h / 2 + 5)
                                        Distance.Visible = false
                                        -- Also update name-with-distance using same priority logic (white-list > friend > enemy)
                                        local whitelist2 = (getgenv and getgenv().AimbotWhitelist) or {}
                                        if whitelist2[plr.UserId] then
                                            Name.Text = string.format('(<font color="rgb(%d, %d, %d)">W</font>) %s [%d]', 0, 255, 0, plr.Name, math.floor(Dist))
                                        elseif ESP.Options.Friendcheck and lplayer:IsFriendsWith(plr.UserId) then
                                            Name.Text = string.format('(<font color="rgb(%d, %d, %d)">F</font>) %s [%d]', ESP.Options.FriendcheckRGB.R * 255, ESP.Options.FriendcheckRGB.G * 255, ESP.Options.FriendcheckRGB.B * 255, plr.Name, math.floor(Dist))
                                        else
                                            Name.Text = string.format('(<font color="rgb(%d, %d, %d)">E</font>) %s [%d]', 255, 0, 0, plr.Name, math.floor(Dist))
                                        end
                                        Name.Visible = ESP.Drawing.Names.Enabled
                                    end
                                end
                                Weapon.Text = "none"
                                Weapon.Visible = ESP.Drawing.Weapons.Enabled
                            else
                                HideESP()
                            end
                        else
                            HideESP()
                        end
                    else
                        HideESP()
                    end
                end)
            end
            coroutine.wrap(Updater)()
        end
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name ~= lplayer.Name then
                coroutine.wrap(ESPForPlayer)(v)
            end
        end
        Players.PlayerAdded:Connect(function(v)
            coroutine.wrap(ESPForPlayer)(v)
        end)
    end
    local function StopESP()
        local existing = CoreGui:FindFirstChild("ESPHolder")
        if existing then
            existing:Destroy()
        end
    end
    local function RefreshESP()
        StopESP()
        if ESP.Enabled then
            StartESP()
        end
    end
    RunService.RenderStepped:Connect(function()
        local center = Cam.ViewportSize / 2
        local best, bestD = nil, math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lplayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local rig = getRig(plr)
                local cf, sz
                if rig then
                    cf, sz = rig:GetBoundingBox()
                else
                    cf, sz = CFrame.new(hrp.Position), Vector3.new(1, 2, 1)
                end
                local screenPos, ons = Cam:WorldToScreenPoint(cf.Position)
                local Dist = (Cam.CFrame.Position - hrp.Position).Magnitude / 3.5714285714
                if ons and Dist <= ESP.MaxDistance then
                    local d2 = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d2 < bestD then
                        bestD = d2
                        best = plr
                    end
                end
            end
        end
        CurrentTarget = best
    end)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "iOS_Dark_ModernUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 310, 0, 50)
    Main.Position = UDim2.new(0.5, -155, 0.25, 0)
    Main.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Active = true
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 16)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(48, 48, 51)
    MainStroke.Thickness = 1.2
    local TopHeader = Instance.new("Frame", Main)
    TopHeader.Name = "TopHeader"
    TopHeader.Size = UDim2.new(1, 0, 0, 50)
    TopHeader.BackgroundTransparency = 1
    local Title = Instance.new("TextLabel", TopHeader)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 16, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Link.cc · Dark"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    local MainArrowBtn = Instance.new("TextButton", TopHeader)
    MainArrowBtn.Name = "MainArrowBtn"
    MainArrowBtn.Size = UDim2.new(0, 36, 0, 36)
    MainArrowBtn.Position = UDim2.new(1, -44, 0.5, -18)
    MainArrowBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    MainArrowBtn.AutoButtonColor = false
    MainArrowBtn.Font = Enum.Font.GothamBold
    MainArrowBtn.Text = "∨"
    MainArrowBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
    MainArrowBtn.TextSize = 13
    MainArrowBtn.ZIndex = 5
    local BtnCorner = Instance.new("UICorner", MainArrowBtn)
    BtnCorner.CornerRadius = UDim.new(1, 0)
    local Dragging, DragInput, DragStart, StartPos
    TopHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    TopHeader.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    local ContentHolder = Instance.new("Frame", Main)
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -24, 0, 0)
    ContentHolder.Position = UDim2.new(0, 12, 0, 50)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.ClipsDescendants = true
    local ContentLayout = Instance.new("UIListLayout", ContentHolder)
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local isMainExpanded = false
    local function updateMainUI()
        local contentHeight = ContentLayout.AbsoluteContentSize.Y
        local targetMainHeight = isMainExpanded and (50 + contentHeight + 14) or 50
        TweenService:Create(MainArrowBtn, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Rotation = isMainExpanded and 180 or 0,
            BackgroundColor3 = isMainExpanded and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(44, 44, 46),
            TextColor3 = isMainExpanded and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 205)
        }):Play()
        TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 310, 0, targetMainHeight)
        }):Play()
        TweenService:Create(ContentHolder, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -24, 0, isMainExpanded and contentHeight or 0)
        }):Play()
    end
    MainArrowBtn.MouseButton1Click:Connect(function()
        isMainExpanded = not isMainExpanded
        updateMainUI()
    end)
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isMainExpanded then updateMainUI() end
    end)
    local UI = {}
    function UI.CreateCategory(categoryTitle)
        local CatFrame = Instance.new("Frame", ContentHolder)
        CatFrame.Size = UDim2.new(1, 0, 0, 42)
        CatFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
        CatFrame.ClipsDescendants = true
        Instance.new("UICorner", CatFrame).CornerRadius = UDim.new(0, 12)
        local CatHeader = Instance.new("TextButton", CatFrame)
        CatHeader.Size = UDim2.new(1, 0, 0, 42)
        CatHeader.BackgroundTransparency = 1
        CatHeader.Text = ""
        local CatTitle = Instance.new("TextLabel", CatHeader)
        CatTitle.Size = UDim2.new(1, -40, 1, 0)
        CatTitle.Position = UDim2.new(0, 14, 0, 0)
        CatTitle.BackgroundTransparency = 1
        CatTitle.Font = Enum.Font.GothamMedium
        CatTitle.Text = categoryTitle
        CatTitle.TextColor3 = Color3.fromRGB(235, 235, 245)
        CatTitle.TextSize = 13
        CatTitle.TextXAlignment = Enum.TextXAlignment.Left
        local CatArrow = Instance.new("TextLabel", CatHeader)
        CatArrow.Size = UDim2.new(0, 30, 1, 0)
        CatArrow.Position = UDim2.new(1, -34, 0, 0)
        CatArrow.BackgroundTransparency = 1
        CatArrow.Font = Enum.Font.GothamBold
        CatArrow.Text = "›"
        CatArrow.TextColor3 = Color3.fromRGB(120, 120, 128)
        CatArrow.TextSize = 16
        local ItemsHolder = Instance.new("Frame", CatFrame)
        ItemsHolder.Size = UDim2.new(1, 0, 0, 0)
        ItemsHolder.Position = UDim2.new(0, 0, 0, 42)
        ItemsHolder.BackgroundTransparency = 1
        local ItemsLayout = Instance.new("UIListLayout", ItemsHolder)
        ItemsLayout.Padding = UDim.new(0, 4)
        ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        local isCatExpanded = false
        local function updateCatHeight()
            local itemsHeight = ItemsLayout.AbsoluteContentSize.Y
            local targetHeight = isCatExpanded and (42 + itemsHeight + 8) or 42
            TweenService:Create(CatArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Rotation = isCatExpanded and 90 or 0
            }):Play()
            TweenService:Create(CatFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            TweenService:Create(ItemsHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, isCatExpanded and itemsHeight or 0)
            }):Play()
        end
        CatHeader.MouseButton1Click:Connect(function()
            isCatExpanded = not isCatExpanded
            updateCatHeight()
        end)
        ItemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isCatExpanded then updateCatHeight() end
        end)
        return ItemsHolder
    end
    function UI.AddToggle(parent, titleText, defaultState, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 38)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.Text = titleText
        label.TextColor3 = Color3.fromRGB(200, 200, 205)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        local switch = Instance.new("TextButton", frame)
        switch.Size = UDim2.new(0, 42, 0, 22)
        switch.Position = UDim2.new(1, -52, 0.5, -11)
        switch.BackgroundColor3 = defaultState and Color3.fromRGB(50, 215, 75) or Color3.fromRGB(58, 58, 60)
        switch.Text = ""
        switch.AutoButtonColor = false
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame", switch)
        knob.Size = defaultState and UDim2.new(0, 18, 0, 18) or UDim2.new(0, 16, 0, 16)
        knob.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local state = defaultState
        switch.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = state and Color3.fromRGB(50, 215, 75) or Color3.fromRGB(58, 58, 60)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -8),
                Size = UDim2.new(0, 18, 0, 18)
            }):Play()
            if callback then callback(state) end
        end)
    end
    function UI.AddSlider(parent, titleText, minVal, maxVal, defaultVal, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 46)
        frame.BackgroundTransparency = 1
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.6, 0, 0, 18)
        label.Position = UDim2.new(0, 14, 0, 4)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.Text = titleText
        label.TextColor3 = Color3.fromRGB(200, 200, 205)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        local valLabel = Instance.new("TextLabel", frame)
        valLabel.Size = UDim2.new(0.4, -14, 0, 18)
        valLabel.Position = UDim2.new(0.6, 0, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Font = Enum.Font.GothamBold
        valLabel.Text = tostring(defaultVal)
        valLabel.TextColor3 = Color3.fromRGB(100, 100, 105)
        valLabel.TextSize = 11
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        local sliderBg = Instance.new("Frame", frame)
        sliderBg.Size = UDim2.new(1, -28, 0, 4)
        sliderBg.Position = UDim2.new(0, 14, 0, 30)
        sliderBg.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
        local sliderFill = Instance.new("Frame", sliderBg)
        local pct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
        Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
        local sliderThumb = Instance.new("Frame", sliderFill)
        sliderThumb.Size = UDim2.new(0, 12, 0, 12)
        sliderThumb.Position = UDim2.new(1, -6, 0.5, -6)
        sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", sliderThumb).CornerRadius = UDim.new(1, 0)
        local tweenInInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tweenOutInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local dragging = false
        local function update(input)
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local rel = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(minVal + rel * (maxVal - minVal))
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(val)
            if callback then callback(val) end
        end
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                TweenService:Create(valLabel, tweenInInfo, {
                    TextColor3 = Color3.fromRGB(10, 132, 255)
                }):Play()
                update(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    TweenService:Create(valLabel, tweenOutInfo, {
                        TextColor3 = Color3.fromRGB(100, 100, 105)
                    }):Play()
                end
            end
        end)
    end
    local Cat1 = UI.CreateCategory("视觉辅助参数")
    UI.AddToggle(Cat1, "开启 ESP", ESP.Enabled, function(v)
        ESP.Enabled = v
        RefreshESP()
    end)
    UI.AddToggle(Cat1, "队伍检测", ESP.TeamCheck, function(v)
        ESP.TeamCheck = v
        RefreshESP()
    end)
    UI.AddSlider(Cat1, "最大渲染距离", 50, 2000, ESP.MaxDistance, function(v)
        ESP.MaxDistance = v
    end)
    local Cat2 = UI.CreateCategory("显示元素")
    UI.AddToggle(Cat2, "显示名称", ESP.Drawing.Names.Enabled, function(v)
        ESP.Drawing.Names.Enabled = v
    end)
    UI.AddToggle(Cat2, "显示距离", ESP.Drawing.Distances.Enabled, function(v)
        ESP.Drawing.Distances.Enabled = v
    end)
    UI.AddToggle(Cat2, "显示武器", ESP.Drawing.Weapons.Enabled, function(v)
        ESP.Drawing.Weapons.Enabled = v
    end)
    UI.AddToggle(Cat2, "显示血条", ESP.Drawing.Healthbar.Enabled, function(v)
        ESP.Drawing.Healthbar.Enabled = v
    end)
    UI.AddToggle(Cat2, "显示盒子", ESP.Drawing.Boxes.Full.Enabled, function(v)
        ESP.Drawing.Boxes.Full.Enabled = v
    end)
    UI.AddToggle(Cat2, "角落线", ESP.Drawing.Boxes.Corner.Enabled, function(v)
        ESP.Drawing.Boxes.Corner.Enabled = v
    end)
    UI.AddToggle(Cat2, "透视(Chams)", ESP.Drawing.Chams.Enabled, function(v)
        ESP.Drawing.Chams.Enabled = v
    end)
    UI.AddSlider(Cat2, "方框缩放(%)", 100, 200, math.floor(ESP.Drawing.Boxes.Scale * 100), function(v)
        ESP.Drawing.Boxes.Scale = v / 100
    end)
    UI.AddSlider(Cat2, "角落线放大(%)", 100, 300, math.floor(ESP.Drawing.Boxes.CornerScale * 100), function(v)
        ESP.Drawing.Boxes.CornerScale = v / 100
    end)
    UI.AddSlider(Cat2, "血条宽度(px)", 1, 10, math.floor(ESP.Drawing.Healthbar.Width), function(v)
        ESP.Drawing.Healthbar.Width = v
    end)
    UI.AddSlider(Cat2, "血条长度(%)", 100, 200, math.floor(ESP.Drawing.Healthbar.LengthScale * 100), function(v)
        ESP.Drawing.Healthbar.LengthScale = v / 100
    end)
    local Cat3 = UI.CreateCategory("选项")
    UI.AddToggle(Cat3, "好友标记", ESP.Options.Friendcheck, function(v)
        ESP.Options.Friendcheck = v
    end)
    UI.AddToggle(Cat3, "渐隐随距离", ESP.FadeOut.OnDistance, function(v)
        ESP.FadeOut.OnDistance = v
    end)
    isMainExpanded = true
    updateMainUI()
    if ESP.Enabled then
        StartESP()
    end
end)
