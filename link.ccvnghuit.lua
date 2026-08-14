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
                    pcall(function() if isMeleeTool(child) then hookWeapon(child) end end)
                end
            end)
        end))
    end

    if LocalPlayer and LocalPlayer.Character then
        trackConnection(LocalPlayer.Character.ChildAdded:Connect(function(child)
            if not alive then return end
            task.delay(0.05, function()
                if alive and child and child:IsA("Tool") then
                    pcall(function() if isMeleeTool(child) then hookWeapon(child) end end)
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

-- sync loops for switches/sliders with tracked connections and alive checks
trackConnection((function()
    local conn = RunService.Heartbeat:Connect(function()
        -- noop heartbeat connection used to keep reference in trackedConnections if needed
    end)
    return conn
end)())

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = AutoSwitch.Get()
    while alive do
        local cur = AutoSwitch.Get()
        if cur ~= prev then
            prev = cur
            autoAttack = cur
            InfoLabel.Text = autoAttack and "Status: Running" or "Status: Disabled"
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = SilentSwitch.Get()
    while alive do
        local cur = SilentSwitch.Get()
        if cur ~= prev then
            prev = cur
            silentAim = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = TeamCheckSwitch.Get()
    while alive do
        local cur = TeamCheckSwitch.Get()
        if cur ~= prev then
            prev = cur
            teamCheck = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = AlwaysHeadSwitch.Get()
    while alive do
        local cur = AlwaysHeadSwitch.Get()
        if cur ~= prev then
            prev = cur
            alwaysHead = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = UseNativeSpeedSwitch.Get()
    while alive do
        local cur = UseNativeSpeedSwitch.Get()
        if cur ~= prev then
            prev = cur
            useNativeSpeed = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = LatencyCompSwitch.Get()
    while alive do
        local cur = LatencyCompSwitch.Get()
        if cur ~= prev then
            prev = cur
            latencyCompEnabled = cur
        end
        task.wait(0.08)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    local prev = LatencyFactorSlider.Get()
    while alive do
        local cur = LatencyFactorSlider.Get()
        if cur ~= prev then
            prev = cur
            latencyFactor = cur
        end
        task.wait(0.12)
    end
end)

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    while alive do
        local r = RangeSlider.Get() or 14
        if r > 14 then r = 14 end
        attackRange = math.floor(r * 100 + 0.5) / 100
        RangeSlider.ValueLabel.Text = string.format("%.2f m", attackRange)

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
        SilentRangeSlider.ValueLabel.Text = string.format("%.2f m", silentRange)

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
        if pcall(function() return tool:GetAttribute(a) end) ~= nil then
            if tool:GetAttribute(a) ~= nil then
                return true
            end
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
    if not LocalPlayer or not LocalPlayer.Character then return nil end
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

-- Hit queue and flushing logic
local hitQueue = {}

local function enqueueHit(payload)
    if not payload or not payload.tarHum then return end
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

spawn(function()
    table.insert(spawnedTasks, coroutine.running())
    while alive do
        task.wait(0.05)
        if not alive then break end
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

-- Silent aim yaw-only and auto aim adjustments (RenderStepped)
local renderConn = RunService.RenderStepped:Connect(function()
    if not alive then renderConn:Disconnect(); return end
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
trackConnection(renderConn)

-- Main attack loop (Heartbeat)
local heartbeatConn = RunService.Heartbeat:Connect(function()
    if not alive then heartbeatConn:Disconnect(); return end
    if not autoAttack or not rootPart then return end
    local now = os.clock()
    local heldTool = getHeldWeapon()
    if heldTool then
        pcall(function() WeaponCheckLabel.Text = "Held Weapon: " .. heldTool.Name end)
    else
        pcall(function() WeaponCheckLabel.Text = "Held Weapon: None" end)
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
