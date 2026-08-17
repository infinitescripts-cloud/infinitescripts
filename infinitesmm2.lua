-- ==========================================
-- CHUNK 1 OF 3 (PASTE FIRST)
-- ==========================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local BlackPurpleBlueTheme = {
   TextColor = Color3.fromRGB(255, 255, 255),
   Background = Color3.fromRGB(15, 15, 20),
   Topbar = Color3.fromRGB(25, 25, 32),
   Shadow = Color3.fromRGB(10, 10, 15),
   NotificationBackground = Color3.fromRGB(22, 22, 30),
   NotificationActionsBackground = Color3.fromRGB(138, 92, 246),
   TabBackground = Color3.fromRGB(35, 35, 45),
   TabStroke = Color3.fromRGB(60, 60, 80),
   TabBackgroundSelected = Color3.fromRGB(124, 58, 237),
   TabTextColor = Color3.fromRGB(200, 200, 220),
   SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
   ElementBackground = Color3.fromRGB(28, 28, 38),
   ElementBackgroundHover = Color3.fromRGB(38, 38, 52),
   SecondaryElementBackground = Color3.fromRGB(20, 20, 28),
   ElementStroke = Color3.fromRGB(55, 55, 75),
   SecondaryElementStroke = Color3.fromRGB(45, 45, 65),
   SliderBackground = Color3.fromRGB(40, 40, 55),
   SliderProgress = Color3.fromRGB(14, 165, 233),
   SliderStroke = Color3.fromRGB(56, 189, 248),
   ToggleBackground = Color3.fromRGB(30, 30, 40),
   ToggleEnabled = Color3.fromRGB(37, 99, 235),
   ToggleDisabled = Color3.fromRGB(70, 70, 85),
   ToggleEnabledStroke = Color3.fromRGB(96, 165, 250),
   ToggleDisabledStroke = Color3.fromRGB(90, 90, 110),
   ToggleEnabledOuterStroke = Color3.fromRGB(59, 130, 246),
   ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 55),
   DropdownSelected = Color3.fromRGB(109, 40, 217),
   DropdownUnselected = Color3.fromRGB(28, 28, 38),
   InputBackground = Color3.fromRGB(25, 25, 35),
   InputStroke = Color3.fromRGB(99, 102, 241),
   PlaceholderColor = Color3.fromRGB(160, 160, 185)
}

local Window = Rayfield:CreateWindow({
   Name = "Infinite's MM2 | Main Hub",
   Icon = "sword",
   LoadingTitle = "Loading Infinite MM2...",
   LoadingSubtitle = "Created by poppingirlx & Ashy_Ash7474",
   Theme = BlackPurpleBlueTheme,
   ShowText = "Infinite MM2",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "InfiniteMM2_Main",
      FileName = "MainConfig"
   },
   KeySystem = false,
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

_G.espEveryoneEnabled = false
_G.espEveryoneLoop = nil
_G.murdererOnlyEnabled = false
_G.murdererOnlyLoop = nil
_G.sheriffHeroOnlyEnabled = false
_G.sheriffHeroOnlyLoop = nil
_G.droppedGunEnabled = false
_G.droppedGunLoop = nil
_G.showSelfESP = false
_G.roleNotifyEnabled = false
_G.roleNotifyLoop = nil
_G.lastMurderer = nil
_G.lastSheriff = nil
_G.gunNotifyEnabled = false
_G.gunNotifyLoop = nil
_G.gunExists = false
_G.roleCache = {}

local function getMyRole()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    for _, v in ipairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local t = v.Text
            if t:find("Murderer") then return "Murderer" end
            if t:find("Sheriff") then return "Sheriff" end
        end
    end
end

local myRole = getMyRole()
if myRole then _G.roleCache[LocalPlayer] = myRole end

if LocalPlayer:FindFirstChild("PlayerGui") then
    LocalPlayer.PlayerGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = obj.Text
            if t:find("Murderer") then _G.roleCache[LocalPlayer] = "Murderer"
            elseif t:find("Sheriff") then _G.roleCache[LocalPlayer] = "Sheriff" end
        end
    end)
end

local function watchPlayer(p)
    p.ChildAdded:Connect(function(c)
        if c:IsA("BoolValue") and c.Value == true then
            if c.Name == "Murderer" then _G.roleCache[p] = "Murderer"
            elseif c.Name == "Sheriff" then _G.roleCache[p] = "Sheriff" end
        elseif c:IsA("StringValue") and (c.Value == "Murderer" or c.Value == "Sheriff") then
            _G.roleCache[p] = c.Value
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

_G.scanRoles = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if not _G.roleCache[p] then
            for _, c in ipairs(p:GetChildren()) do
                if c:IsA("BoolValue") and c.Value == true then
                    if c.Name == "Murderer" then _G.roleCache[p] = "Murderer"
                    elseif c.Name == "Sheriff" then _G.roleCache[p] = "Sheriff" end
                elseif c:IsA("StringValue") and (c.Value == "Murderer" or c.Value == "Sheriff") then
                    _G.roleCache[p] = c.Value
                end
            end
        end
    end
end

-- ==========================================
-- CHUNK 2 OF 3 (PASTE SECOND)
-- ==========================================

local function ESPIndicatorModule()
    local e = {}; e.__index = e
    local RunS, PlayersS, HttpS, TweenS = RunService, Players, HttpService, TweenService
    e.Groups = {}; e.TargetIndex = {}
    e.Defaults = {
        AccentColor = Color3.new(1,1,0),
        HighlightFillTransparency = 0.7,
        HighlightOutlineTransparency = 0,
        HighlightDepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        ArrowShow = false,
        ArrowEdgePadding = 50,
        ArrowMinDistance = 0,
        ArrowSize = UDim2.new(0,30,0,30),
        ArrowImage = "rbxassetid://97136202386756",
        ArrowShowDistanceText = true,
        ArrowDistanceFont = Enum.Font.Montserrat,
        ArrowDistanceTextSize = 18,
        ShowLabel = false,
        LabelText = "Target",
        LabelMaxDistance = 99999,
        LabelOffset = Vector3.new(0,2,0),
        Parent = game:GetService("CoreGui")
    }

    function e.new(b)
        local c = setmetatable({}, e)
        c.Settings = {}
        for a, def in pairs(e.Defaults) do c.Settings[a] = (b and b[a]~=nil) and b[a] or def end
        local parent = c.Settings.Parent or LocalPlayer:WaitForChild("PlayerGui")
        c.ScreenGui = Instance.new("ScreenGui")
        c.ScreenGui.Name = "ESPIndicators_Hub"
        c.ScreenGui.IgnoreGuiInset = true; c.ScreenGui.ResetOnSpawn = false; c.ScreenGui.Parent = parent
        
        c.ArrowTemplate = Instance.new("ImageLabel")
        c.ArrowTemplate.Name = "ArrowTemplate"
        c.ArrowTemplate.Size = c.Settings.ArrowSize
        c.ArrowTemplate.AnchorPoint = Vector2.new(0.5,0.5)
        c.ArrowTemplate.BackgroundTransparency = 1
        c.ArrowTemplate.Image = c.Settings.ArrowImage
        c.ArrowTemplate.ImageColor3 = c.Settings.AccentColor
        c.ArrowTemplate.Visible = false
        c.ArrowTemplate.Parent = c.ScreenGui
        
        c.Scaler = Instance.new("UIScale")
        c.Scaler.Name = "Scaler"; c.Scaler.Scale = 0; c.Scaler.Parent = c.ArrowTemplate
        c.Indicators = {}
        c._updateConn = RunS.RenderStepped:Connect(function() c:_update() end)
        c._cleanupConn = RunS.Heartbeat:Connect(function()
            c:_cleanupOrphanedArrows(); c:_cleanupOrphanedHighlights(); c:_cleanupOrphanedLabels()
        end)
        return c
    end

    function e:AddGroup(groupName) local g = e.Groups[groupName] or {enabled=true,properties={},targets={}} e.Groups[groupName]=g return g end

    function e:RemoveGroup(groupName)
        local g = e.Groups[groupName] if not g then return false end
        for _, t in ipairs(g.targets) do
            local idx = e.TargetIndex[t] if idx then for i,gn in ipairs(idx) do if gn==groupName then table.remove(idx,i) break end end if #idx==0 then e.TargetIndex[t]=nil end end
            if not e.TargetIndex[t] then self:Remove(t) end
        end
        e.Groups[groupName]=nil; return true
    end

    function e:ClearAllGroups() for gn,_ in pairs(e.Groups) do self:RemoveGroup(gn) end end

    function e:Add(target, opts)
        opts = opts or {}
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight_"..HttpService:GenerateGUID(false)
        highlight.Adornee = target
        highlight.FillTransparency = opts.HighlightFillTransparency or self.Settings.HighlightFillTransparency
        highlight.FillColor = opts.AccentColor or self.Settings.AccentColor
        highlight.OutlineColor = opts.AccentColor or self.Settings.AccentColor
        highlight.OutlineTransparency = opts.HighlightOutlineTransparency or self.Settings.HighlightOutlineTransparency
        highlight.DepthMode = opts.HighlightDepthMode or self.Settings.HighlightDepthMode
        highlight.Parent = self.ScreenGui

        local arrow, scaler, distanceLabel
        if (opts.ArrowShow or self.Settings.ArrowShow) then
            arrow = self.ArrowTemplate:Clone()
            arrow.Name = "Arrow_"..HttpService:GenerateGUID(false)
            arrow.ImageColor3 = opts.AccentColor or self.Settings.AccentColor
            arrow.Visible = true; arrow.Parent = self.ScreenGui
            scaler = arrow:FindFirstChild("Scaler")
            if (opts.ArrowShowDistanceText or self.Settings.ArrowShowDistanceText) then
                distanceLabel = Instance.new("TextLabel")
                distanceLabel.Name = "DistanceLabel"
                distanceLabel.AnchorPoint = Vector2.new(0.5,0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.Font = opts.ArrowDistanceFont or self.Settings.ArrowDistanceFont
                distanceLabel.TextSize = opts.ArrowDistanceTextSize or self.Settings.ArrowDistanceTextSize
                distanceLabel.TextColor3 = opts.AccentColor or self.Settings.AccentColor
                distanceLabel.Parent = arrow
            end
        end

        local billboard
        if (opts.ShowLabel or self.Settings.ShowLabel) then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "Label_"..HttpService:GenerateGUID(false)
            billboard.AlwaysOnTop = true
            billboard.MaxDistance = self.Settings.LabelMaxDistance
            billboard.Size = UDim2.new(0,70,0,70)
            billboard.StudsOffset = self.Settings.LabelOffset
            billboard.Adornee = target
            billboard.Parent = self.ScreenGui
            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "TextLabel"
            textLabel.Size = UDim2.new(1,0,1,0)
            textLabel.AnchorPoint = Vector2.new(0.5,0.5)
            textLabel.Position = UDim2.new(0.5,0,0.5,0)
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextScaled = true; textLabel.TextWrapped = true; textLabel.TextSize = 14
            textLabel.TextColor3 = opts.AccentColor or self.Settings.AccentColor
            textLabel.Text = opts.LabelText or self.Settings.LabelText
            textLabel.Parent = billboard
            Instance.new("UIStroke", textLabel)
        end

        self.Indicators[target] = {Highlight=highlight, Arrow=arrow, Scaler=scaler, DistanceLabel=distanceLabel, Label=billboard, Options=opts}
        local groupName = opts.GroupName or self.Settings.GroupName
        if groupName then self:AddToGroup(target, groupName) end
    end

    function e:Remove(target)
        local ind = self.Indicators[target] if not ind then return end
        if ind.Highlight then ind.Highlight.Adornee=nil; ind.Highlight:Destroy() end
        if ind.Arrow then ind.Arrow:Destroy() end
        if ind.Label then ind.Label:Destroy() end
        local idx = e.TargetIndex[target]
        if idx then for _,gn in ipairs(idx) do local g=e.Groups[gn] if g then for i,t in ipairs(g.targets) do if t==target then table.remove(g.targets,i) break end end end end e.TargetIndex[target]=nil end
        self.Indicators[target]=nil
    end

    function e:AddToGroup(target, groupName)
        local g = self:AddGroup(groupName)
        if not table.find(g.targets, target) then table.insert(g.targets, target) end
        local idx = e.TargetIndex[target] or {}; e.TargetIndex[target]=idx
        if not table.find(idx, groupName) then table.insert(idx, groupName) end
        for prop, val in pairs(g.properties) do self:SetGroupProperty(groupName, prop, val) end
        if not g.enabled then local ind = self.Indicators[target] if ind and ind.Highlight then ind.Highlight.Enabled=false end end
        return true
    end

    function e:SetGroupProperty(gn, prop, val)
        local g = self:AddGroup(gn); g.properties[prop]=val
        for _,t in ipairs(g.targets) do
            local ind = self.Indicators[t]
            if ind and prop=="AccentColor" then
                if ind.Highlight then ind.Highlight.FillColor=val; ind.Highlight.OutlineColor=val end
                if ind.Arrow then ind.Arrow.ImageColor3=val end
                if ind.DistanceLabel then ind.DistanceLabel.TextColor3=val end
                if ind.Label and ind.Label:FindFirstChild("TextLabel") then ind.Label.TextLabel.TextColor3=val end
            end
        end
    end

    function e:_cleanupOrphanedHighlights() for _,c in ipairs(self.ScreenGui:GetChildren()) do if c:IsA("Highlight") and not table.find(self:_allHighlights(),c) then c.Adornee=nil; c:Destroy() end end end
    function e:_allHighlights() local l={} for _,ind in pairs(self.Indicators) do if ind.Highlight then table.insert(l,ind.Highlight) end end return l end
    function e:_cleanupOrphanedArrows() for _,c in ipairs(self.ScreenGui:GetChildren()) do if c:IsA("ImageLabel") and c.Name:match("^Arrow_") and not table.find(self:_allArrows(),c) then c:Destroy() end end end
    function e:_allArrows() local l={} for _,ind in pairs(self.Indicators) do if ind.Arrow then table.insert(l,ind.Arrow) end end return l end
    function e:_cleanupOrphanedLabels() for _,c in ipairs(self.ScreenGui:GetChildren()) do if c:IsA("BillboardGui") and c.Name:match("^Label_") and not table.find(self:_allLabels(),c) then c.Adornee=nil; c:Destroy() end end end
    function e:_allLabels() local l={} for _,ind in pairs(self.Indicators) do if ind.Label then table.insert(l,ind.Label) end end return l end

    function e:_update()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local w,h = camera.ViewportSize.X, camera.ViewportSize.Y
        for target, ind in pairs(self.Indicators) do
            local opts, arrow, scaler = ind.Options, ind.Arrow, ind.Scaler
            if (not arrow or not scaler) and self.Settings.ArrowShow then self:Remove(target) continue end
            if not arrow then continue end
            local pos
            if target:IsA("Model") then pos = (target.PrimaryPart and target.PrimaryPart.Position) or target:GetModelCFrame().p
            elseif target:IsA("BasePart") then pos = target.Position else continue end
            local screenPos, onScreen = camera:WorldToViewportPoint(pos)
            local dist = (camera.CFrame.p - pos).Magnitude
            local minDist = opts.ArrowMinDistance or self.Settings.ArrowMinDistance
            local edgePad = opts.ArrowEdgePadding or self.Settings.ArrowEdgePadding
            if onScreen and dist > minDist then
                TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=0}):Play()
            else
                TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()
                local d,g = w-edgePad*2, h-edgePad*2
                local camCF = camera.CFrame
                local radius = math.sqrt((d/2)^2 + (g/2)^2)
                local dir = pos - camCF.Position
                local localDir = camCF:VectorToObjectSpace(dir)
                local dirUnit = Vector2.new(localDir.X, localDir.Y).Unit
                local clampedX = math.clamp(screenPos.X, edgePad, w - edgePad)
                local clampedY = math.clamp(screenPos.Y, edgePad, h - edgePad)
                if clampedX == screenPos.X and clampedY == screenPos.Y and onScreen then
                    TweenService:Create(scaler, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=0}):Play()
                else
                    local edgeVec = dirUnit * radius
                    local finalVec
                    if math.abs(edgeVec.Y) > g/2 then finalVec = dirUnit * math.abs((g/2)/dirUnit.Y) else finalVec = dirUnit * math.abs((d/2)/dirUnit.X) end
                    local xPos = w/2 + finalVec.X
                    local yPos = h/2 - finalVec.Y
                    local angle = math.atan2(dirUnit.X, dirUnit.Y)
                    TweenService:Create(arrow, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.fromOffset(xPos,yPos), Rotation=math.deg(angle)}):Play()
                end
                if ind.DistanceLabel then
                    ind.DistanceLabel.Text = string.format("%dm", math.round(dist))
                    local offsetY = (opts.ArrowSize and opts.ArrowSize.Y.Offset or self.Settings.ArrowSize.Y.Offset) + 16
                    ind.DistanceLabel.Position = UDim2.new(0.5,0,0,offsetY)
                end
            end
        end
    end
    return e
end

_G.GlobalIndicators = ESPIndicatorModule().new({
    ArrowEdgePadding = 50,
    ArrowShowDistanceText = false,
    Parent = game:GetService("CoreGui")
})

_G.findMurderer = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then return p end
    end
    return nil
end

_G.findSheriff = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then return p end
    end
    return nil
end

_G.getMap = function()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:FindFirstChild("CoinContainer") and child:FindFirstChild("Spawns") then return child end
    end
    return Workspace:FindFirstChild("TheGunDrop") or Workspace:FindFirstChild("Map")
end

_G.CleanESP = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("ESP_MM2")
            if h then h:Destroy() end
            local textGui = p.Character:FindFirstChild("ESP_Text_MM2")
            if textGui then textGui:Destroy() end
        end
    end
end

_G.CleanGunESP = function()
    _G.GlobalIndicators:RemoveGroup("dropped_gun")
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == "GunDropESP" or item.Name == "GunDropText" then item:Destroy() end
    end
end

-- ==========================================
-- CHUNK 3 OF 3 (PASTE THIRD)
-- ==========================================

local function notifyRoles()
    if not _G.roleNotifyEnabled then return end
    local murd = _G.findMurderer()
    local sher = _G.findSheriff()

    if murd == _G.lastMurderer and sher == _G.lastSheriff then return end
    _G.lastMurderer, _G.lastSheriff = murd, sher

    local msg = (murd and ("🔪 Murderer: " .. murd.Name) or "🔪 Murderer: Not found") .. "\n" ..
                (sher and ("🔫 Sheriff: " .. sher.Name) or "🔫 Sheriff: Not found")

    Rayfield:Notify({
        Title = "Roles Detected",
        Content = msg,
        Duration = 6,
        Image = "eye"
    })
end

local function checkGunNotifier()
    if not _G.gunNotifyEnabled then return end
    local map = _G.getMap()
    if not map then
        if _G.gunExists then
            _G.gunExists = false
            Rayfield:Notify({ Title = "Gun Status", Content = "Map not found – gun status unknown.", Duration = 4, Image = "bell" })
        end
        return
    end

    local gun = map:FindFirstChild("GunDrop") or Workspace:FindFirstChild("GunDrop")
    if gun then
        if not _G.gunExists then
            _G.gunExists = true
            local posStr = string.format("(%.1f, %.1f, %.1f)", gun.Position.X, gun.Position.Y, gun.Position.Z)
            Rayfield:Notify({ Title = "🔫 Gun Dropped!", Content = "The gun is on the ground at " .. posStr, Duration = 5, Image = "bell" })
        end
    else
        if _G.gunExists then
            _G.gunExists = false
            task.wait(0.3)
            local picker = _G.findSheriff()
            if picker then
                local txt = (picker == LocalPlayer) and "You picked up the gun!" or (picker.Name .. " picked up the gun.")
                Rayfield:Notify({ Title = "Gun Picked Up", Content = txt, Duration = 4, Image = "bell" })
            else
                Rayfield:Notify({ Title = "Gun Disappeared", Content = "The gun vanished (despawned or round ended).", Duration = 4, Image = "bell" })
            end
        end
    end
end

-- TAB 1: MAIN
local MainTab = Window:CreateTab("Main", "home")
MainTab:CreateSection("Security & Verification Notice")
MainTab:CreateParagraph({ Title = "Security Warning", Content = "Hey! Just to make sure if you DID bypass the authentication, Please follow our strict rules while using the script. One, Do not copy link anything in this script. Two destroy the script, and three this may contain malicious content and phishing if you got this group another uploading site other than rscripts. Made by SHELLALEE BYE!" })
MainTab:CreateButton({ Name = "Destroy GUI", Callback = function() Rayfield:Destroy() end })
MainTab:CreateSection("Script Credits")
MainTab:CreateParagraph({ Title = "Development Credits", Content = "Created By: Shellaes Dw & Ashy_Ash7474\nSpecial thanks to the Sirius team for the Rayfield UI library framework." })

-- TAB 2: COMBAT
local CombatTab = Window:CreateTab("Combat", "crosshair")
CombatTab:CreateSection("Combat Controls")

-- TAB 3: VISUALS
local VisualsTab = Window:CreateTab("Visuals", "eye")
VisualsTab:CreateSection("ESP Options")

VisualsTab:CreateToggle({
   Name = "ESP Everyone",
   CurrentValue = false,
   Flag = "ESPEveryoneToggle",
   Callback = function(Value)
      _G.espEveryoneEnabled = Value
      if Value then
         _G.espEveryoneLoop = task.spawn(function()
            while _G.espEveryoneEnabled do
               pcall(function()
                   _G.scanRoles()
                   local murderer = _G.findMurderer()
                   local currentSheriff = _G.findSheriff()
                   for _, p in ipairs(Players:GetPlayers()) do
                       if p == LocalPlayer and not _G.showSelfESP then continue end
                       local c = p.Character
                       if not c then continue end
                       local name, color = nil, Color3.fromRGB(255,255,255)
                       if p == murderer then name, color = "Murderer", Color3.fromRGB(255,0,0)
                       elseif p == currentSheriff then name, color = "Sheriff", Color3.fromRGB(0,0,255) end
                       
                       local h = c:FindFirstChild("ESP_MM2") or Instance.new("Highlight", c)
                       h.Name = "ESP_MM2"
                       h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                       h.FillColor = color
                       h.FillTransparency = 0.4
                   end
               end)
               task.wait(0.15)
            end
         end)
      else
         if _G.espEveryoneLoop then task.cancel(_G.espEveryoneLoop) end
         _G.CleanESP()
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Only Murderer",
   CurrentValue = false,
   Flag = "OnlyMurdererToggle",
   Callback = function(Value)
      _G.murdererOnlyEnabled = Value
      if Value then
         _G.murdererOnlyLoop = task.spawn(function()
            while _G.murdererOnlyEnabled do
               pcall(function()
                   _G.GlobalIndicators:RemoveGroup("murderer")
                   local murd = _G.findMurderer()
                   if murd and murd.Character and (murd ~= LocalPlayer or _G.showSelfESP) then
                       _G.GlobalIndicators:Add(murd.Character, { AccentColor = Color3.new(1,0,0.01), ArrowShow = true, ArrowMinDistance = 0, ArrowSize = UDim2.new(0,40,0,40), LabelText = "Murderer", ShowLabel = true, GroupName = "murderer" })
                   end
               end)
               task.wait(0.5)
            end
         end)
      else
         if _G.murdererOnlyLoop then task.cancel(_G.murdererOnlyLoop) end
         _G.GlobalIndicators:RemoveGroup("murderer")
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Dropped Gun ESP",
   CurrentValue = false,
   Flag = "DroppedGunToggle",
   Callback = function(Value)
      _G.droppedGunEnabled = Value
      if Value then
         _G.droppedGunLoop = task.spawn(function()
            while _G.droppedGunEnabled do
               pcall(function()
                   _G.GlobalIndicators:RemoveGroup("dropped_gun")
                   local gunDrop = Workspace:FindFirstChild("GunDrop") or (_G.getMap() and _G.getMap():FindFirstChild("GunDrop"))
                   if gunDrop then
                       _G.GlobalIndicators:Add(gunDrop, { AccentColor = Color3.fromRGB(243, 255, 19), ArrowShow = true, ArrowMinDistance = 0, ArrowSize = UDim2.new(0, 30, 0, 30), LabelText = "Dropped Gun!", ShowLabel = true, GroupName = "dropped_gun" })
                   end
               end)
               task.wait(0.5)
            end
         end)
      else
         if _G.droppedGunLoop then task.cancel(_G.droppedGunLoop) end
         _G.CleanGunESP()
      end
   end,
})

VisualsTab:CreateSection("Notifications")

VisualsTab:CreateToggle({
   Name = "Instant Role Notify",
   CurrentValue = false,
   Flag = "InstantRoleNotifyToggle",
   Callback = function(Value)
      _G.roleNotifyEnabled = Value
      if Value then
         _G.lastMurderer, _G.lastSheriff = nil, nil
         Rayfield:Notify({ Title = "Role Notify", Content = "Active – watching for role changes.", Duration = 3, Image = "bell" })
         _G.roleNotifyLoop = task.spawn(function()
            while _G.roleNotifyEnabled do
               pcall(notifyRoles)
               task.wait(1.5)
            end
         end)
      else
         if _G.roleNotifyLoop then task.cancel(_G.roleNotifyLoop) end
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Gun Drop Notifier",
   CurrentValue = false,
   Flag = "GunDropNotifierToggle",
   Callback = function(Value)
      _G.gunNotifyEnabled = Value
      if Value then
         _G.gunExists = false
         Rayfield:Notify({ Title = "Gun Notifier", Content = "Active – will alert when gun drops or gets picked up.", Duration = 3, Image = "bell" })
         _G.gunNotifyLoop = task.spawn(function()
            while _G.gunNotifyEnabled do
               pcall(checkGunNotifier)
               task.wait(2)
            end
         end)
      else
         if _G.gunNotifyLoop then task.cancel(_G.gunNotifyLoop) end
         _G.gunExists = false
      end
   end,
})

-- TAB 4 & 5
local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateSection("Player Configurations")

local FunTab = Window:CreateTab("Fun", "smile")
FunTab:CreateSection("Fun Utilities")
