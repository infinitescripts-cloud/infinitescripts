-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Custom Theme: Black/White with Blue & Purple Hues
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

-- Create Main Window
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

-- ==========================================
-- TAB 1: MAIN
-- ==========================================
local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateSection("Security & Verification Notice")

MainTab:CreateParagraph({
   Title = "Security Warning",
   Content = "Hey! Just to make sure if you DID bypass the authentication, Please follow our strict rules while using the script. One, Do not copy link anything in this script. Two destroy the script, and three this may contain malicious content and phishing if you got this group another uploading site other than rscripts. Made by SHELLALEE BYE!"
})

MainTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      Rayfield:Destroy()
   end,
})

MainTab:CreateSection("Script Credits")

MainTab:CreateParagraph({
   Title = "Development Credits",
   Content = "Created By: Shellaes Dw & Ashy_Ash7474\nSpecial thanks to the Sirius team for the Rayfield UI library framework."
})

MainTab:CreateParagraph({
   Title = "About Infinite's MM2",
   Content = "This script was built specifically for Murder Mystery 2 with security features, custom theme styling, and role-specific utilities."
})

-- ==========================================
-- TAB 2: COMBAT
-- ==========================================
local CombatTab = Window:CreateTab("Combat", "crosshair")

-- ==========================================
-- TAB 3: VISUALS
-- ==========================================
local VisualsTab = Window:CreateTab("Visuals", "eye")

VisualsTab:CreateSection("ESP Options")

-- Global Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espEveryoneEnabled = false
local espEveryoneLoop = nil

local murdererOnlyEnabled = false
local murdererOnlyLoop = nil

local sheriffHeroOnlyEnabled = false
local sheriffHeroOnlyLoop = nil

local showSelfESP = false

-- Shared Helpers
local function isAlive(p)
    local char = p.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function hasGun(p)
    local char = p.Character
    if not char then return false end
    local bp = p:FindFirstChild("Backpack")
    return (bp and bp:FindFirstChild("Gun")) ~= nil or char:FindFirstChild("Gun") ~= nil
end

-- Utility Function to Clean ESP Instances
local function CleanESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("ESP_MM2")
            if h then h:Destroy() end

            local textGui = p.Character:FindFirstChild("ESP_Text_MM2")
            if textGui then textGui:Destroy() end
        end
    end
end

-- ==========================================
-- LOGIC 1: ESP EVERYONE (Updated with BoolValue & Distance Logic)
-- ==========================================
local xerifeDestaRodada = nil

local function getAliveMurdererBool()
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) and p:FindFirstChild("Murderer") and p.Murderer.Value == true then
            return p
        end
    end
    return nil
end

local function GetRoleInfoEveryone(p)
    local char = p.Character
    if not char then return nil, nil end

    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return nil, nil end

    local root = char:FindFirstChild("HumanoidRootPart")

    -- 1. Check role BoolValues FIRST (works during countdown)
    if p:FindFirstChild("Murderer") and p.Murderer.Value == true then
        return "Murderer", Color3.fromRGB(255, 0, 0)
    end

    if p:FindFirstChild("Sheriff") and p.Sheriff.Value == true then
        xerifeDestaRodada = p
        return "Sheriff", Color3.fromRGB(0, 0, 255)
    end

    -- 2. Check for gun holder (for Hero or if Sheriff picked up gun)
    local bp = p:FindFirstChild("Backpack")
    local gun = (bp and bp:FindFirstChild("Gun")) or char:FindFirstChild("Gun")
    if gun then
        if xerifeDestaRodada == nil or (xerifeDestaRodada.Character and xerifeDestaRodada.Character.Humanoid.Health <= 0) then
            xerifeDestaRodada = p
            return "Sheriff", Color3.fromRGB(0, 0, 255)
        end
        if p == xerifeDestaRodada then
            return "Sheriff", Color3.fromRGB(0, 0, 255)
        else
            return "Hero", Color3.fromRGB(255, 215, 0)
        end
    end

    -- 3. No role, no gun → Innocent or Lobby (based on distance to Murderer)
    local murderer = getAliveMurdererBool()
    if murderer and murderer.Character and root then
        local assassinPos = murderer.Character:FindFirstChild("HumanoidRootPart")
        if assassinPos then
            local dist = (root.Position - assassinPos.Position).Magnitude
            if dist > 300 then
                return nil, Color3.fromRGB(255, 255, 255)  -- Lobby
            end
            return nil, Color3.fromRGB(0, 255, 0)  -- Innocent
        end
    end

    -- Fallback: no murderer found → show as Lobby
    return nil, Color3.fromRGB(255, 255, 255)
end

local function UpdateESPEveryone()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer and not showSelfESP then
            local char = p.Character
            if char then
                local h = char:FindFirstChild("ESP_MM2")
                if h then h.Enabled = false end
                local t = char:FindFirstChild("ESP_Text_MM2")
                if t then t.Enabled = false end
            end
            continue
        end

        local char = p.Character
        if not char then continue end

        local roleName, roleColor = GetRoleInfoEveryone(p)

        local h = char:FindFirstChild("ESP_MM2")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "ESP_MM2"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
        end

        if roleColor then
            h.Enabled = true
            h.FillColor = roleColor
            h.FillTransparency = (roleColor == Color3.fromRGB(255, 255, 255)) and 0.9 or 0.4
        else
            h.Enabled = false
        end

        local textGui = char:FindFirstChild("ESP_Text_MM2")
        if not textGui then
            textGui = Instance.new("BillboardGui")
            textGui.Name = "ESP_Text_MM2"
            textGui.Size = UDim2.new(0, 200, 0, 50)
            textGui.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            textGui.StudsOffset = Vector3.new(0, 2.5, 0)
            textGui.AlwaysOnTop = true
            textGui.Parent = char

            local label = Instance.new("TextLabel")
            label.Name = "RoleLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.FredokaOne
            label.TextSize = 20
            label.TextStrokeTransparency = 0.5
            label.TextScaled = false
            label.Parent = textGui
        end

        local label = textGui:FindFirstChild("RoleLabel")

        if roleName and roleColor then
            textGui.Enabled = true
            label.Text = roleName
            label.TextColor3 = roleColor
        else
            textGui.Enabled = false
            label.Text = ""
        end
    end
end

-- ==========================================
-- LOGIC 2: MURDERER ONLY ESP
-- ==========================================
local function IsMurderer(p)
    local char = p.Character
    if not char then return false end

    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local bp = p:FindFirstChild("Backpack")
    local knife = (bp and bp:FindFirstChild("Knife")) or char:FindFirstChild("Knife")
    return knife ~= nil or (p:FindFirstChild("Murderer") and p.Murderer.Value == true)
end

local function UpdateMurdererOnly()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer and not showSelfESP then
            local char = p.Character
            if char then
                local h = char:FindFirstChild("ESP_MM2")
                if h then h.Enabled = false end
                local t = char:FindFirstChild("ESP_Text_MM2")
                if t then t.Enabled = false end
            end
            continue
        end

        local char = p.Character
        if not char then continue end

        local h = char:FindFirstChild("ESP_MM2")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "ESP_MM2"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
        end

        local textGui = char:FindFirstChild("ESP_Text_MM2")
        if not textGui then
            textGui = Instance.new("BillboardGui")
            textGui.Name = "ESP_Text_MM2"
            textGui.Size = UDim2.new(0, 200, 0, 50)
            textGui.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            textGui.StudsOffset = Vector3.new(0, 2.5, 0)
            textGui.AlwaysOnTop = true
            textGui.Parent = char

            local label = Instance.new("TextLabel")
            label.Name = "RoleLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.FredokaOne
            label.TextSize = 20
            label.TextStrokeTransparency = 0.5
            label.TextScaled = false
            label.Parent = textGui
        end

        local label = textGui:FindFirstChild("RoleLabel")

        if IsMurderer(p) then
            h.Enabled = true
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.4

            textGui.Enabled = true
            label.Text = "Murderer"
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            h.Enabled = false
            textGui.Enabled = false
            label.Text = ""
        end
    end
end

-- ==========================================
-- LOGIC 3: SHERIFF / HERO ONLY ESP
-- ==========================================
local originalSheriff = nil
local lockedHero = nil
local lastMurdererSheriff = nil

local function getAliveMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) then
            local char = p.Character
            local bp = p:FindFirstChild("Backpack")
            if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) or (p:FindFirstChild("Murderer") and p.Murderer.Value == true) then
                return p
            end
        end
    end
    return nil
end

local function UpdateSheriffHeroOnly()
    local currentMurderer = getAliveMurderer()

    if not currentMurderer then
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            if char then
                local h = char:FindFirstChild("ESP_MM2")
                if h then h.Enabled = false end
                local t = char:FindFirstChild("ESP_Text_MM2")
                if t then t.Enabled = false end
            end
        end
        lastMurdererSheriff = nil
        return
    end

    if lastMurdererSheriff ~= currentMurderer then
        originalSheriff = nil
        lockedHero = nil
        lastMurdererSheriff = currentMurderer
    end

    local gunHolder = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if isAlive(p) and hasGun(p) then
            gunHolder = p
            break
        end
    end

    local sheriffPlayer = nil
    local heroPlayer = nil

    if gunHolder then
        if originalSheriff == nil then
            originalSheriff = gunHolder
            sheriffPlayer = gunHolder
        else
            if gunHolder == originalSheriff and isAlive(originalSheriff) then
                sheriffPlayer = originalSheriff
            else
                if lockedHero == nil or not isAlive(lockedHero) or not hasGun(lockedHero) then
                    lockedHero = gunHolder
                end
                heroPlayer = lockedHero
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer and not showSelfESP then
            local char = p.Character
            if char then
                local h = char:FindFirstChild("ESP_MM2")
                if h then h.Enabled = false end
                local t = char:FindFirstChild("ESP_Text_MM2")
                if t then t.Enabled = false end
            end
            continue
        end

        local char = p.Character
        if not char then continue end

        local h = char:FindFirstChild("ESP_MM2")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "ESP_MM2"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
        end

        local textGui = char:FindFirstChild("ESP_Text_MM2")
        if not textGui then
            textGui = Instance.new("BillboardGui")
            textGui.Name = "ESP_Text_MM2"
            textGui.Size = UDim2.new(0, 200, 0, 50)
            textGui.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            textGui.StudsOffset = Vector3.new(0, 2.5, 0)
            textGui.AlwaysOnTop = true
            textGui.Parent = char

            local label = Instance.new("TextLabel")
            label.Name = "RoleLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.FredokaOne
            label.TextSize = 20
            label.TextStrokeTransparency = 0.5
            label.TextScaled = false
            label.Parent = textGui
        end

        local label = textGui:FindFirstChild("RoleLabel")

        if p == sheriffPlayer then
            h.Enabled = true
            h.FillColor = Color3.fromRGB(0, 0, 255)
            h.FillTransparency = 0.4
            textGui.Enabled = true
            label.Text = "Sheriff"
            label.TextColor3 = Color3.fromRGB(0, 0, 255)

        elseif p == heroPlayer then
            h.Enabled = true
            h.FillColor = Color3.fromRGB(255, 215, 0)
            h.FillTransparency = 0.4
            textGui.Enabled = true
            label.Text = "Hero"
            label.TextColor3 = Color3.fromRGB(255, 215, 0)

        else
            h.Enabled = false
            textGui.Enabled = false
            label.Text = ""
        end
    end
end

-- ==========================================
-- VISUALS TOGGLES
-- ==========================================
VisualsTab:CreateToggle({
   Name = "ESP Everyone",
   CurrentValue = false,
   Flag = "ESPEveryoneToggle",
   Callback = function(Value)
      espEveryoneEnabled = Value
      if espEveryoneEnabled then
         espEveryoneLoop = task.spawn(function()
            while espEveryoneEnabled do
               pcall(UpdateESPEveryone)
               task.wait(0.15)
            end
         end)
      else
         if espEveryoneLoop then task.cancel(espEveryoneLoop) end
         xerifeDestaRodada = nil
         CleanESP()
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Show Self ESP",
   CurrentValue = false,
   Flag = "ShowSelfESPToggle",
   Callback = function(Value)
      showSelfESP = Value
   end,
})

VisualsTab:CreateToggle({
   Name = "Murderer Only",
   CurrentValue = false,
   Flag = "MurdererOnlyToggle",
   Callback = function(Value)
      murdererOnlyEnabled = Value
      if murdererOnlyEnabled then
         murdererOnlyLoop = task.spawn(function()
            while murdererOnlyEnabled do
               pcall(UpdateMurdererOnly)
               task.wait(0.2)
            end
         end)
      else
         if murdererOnlyLoop then task.cancel(murdererOnlyLoop) end
         CleanESP()
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Sheriff/Hero Only",
   CurrentValue = false,
   Flag = "SheriffHeroOnlyToggle",
   Callback = function(Value)
      sheriffHeroOnlyEnabled = Value
      if sheriffHeroOnlyEnabled then
         sheriffHeroOnlyLoop = task.spawn(function()
            while sheriffHeroOnlyEnabled do
               pcall(UpdateSheriffHeroOnly)
               task.wait(0.15)
            end
         end)
      else
         if sheriffHeroOnlyLoop then task.cancel(sheriffHeroOnlyLoop) end
         originalSheriff = nil
         lockedHero = nil
         lastMurdererSheriff = nil
         CleanESP()
      end
   end,
})

-- ==========================================
-- OTHER TABS
-- ==========================================
local PlayerTab = Window:CreateTab("Player", "user")
local FunTab = Window:CreateTab("Fun", "smile")
