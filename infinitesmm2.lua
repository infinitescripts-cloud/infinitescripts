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
   LoadingSubtitle = "Created by the shallea",
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

-- Global Variables & Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local espEveryoneEnabled = false
local espEveryoneLoop = nil

local droppedGunEnabled = false
local droppedGunLoop = nil

local showSelfESP = false

-- Role Cache & Tracking
local roleCache = {}

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
if myRole then roleCache[LocalPlayer] = myRole end

if LocalPlayer:FindFirstChild("PlayerGui") then
    LocalPlayer.PlayerGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local t = obj.Text
            if t:find("Murderer") then roleCache[LocalPlayer] = "Murderer"
            elseif t:find("Sheriff") then roleCache[LocalPlayer] = "Sheriff" end
        end
    end)
end

local function watchPlayer(p)
    p.ChildAdded:Connect(function(c)
        if c:IsA("BoolValue") and c.Value == true then
            if c.Name == "Murderer" then roleCache[p] = "Murderer"
            elseif c.Name == "Sheriff" then roleCache[p] = "Sheriff" end
        elseif c:IsA("StringValue") and (c.Value == "Murderer" or c.Value == "Sheriff") then
            roleCache[p] = c.Value
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

local function scanRoles()
    for _, p in ipairs(Players:GetPlayers()) do
        if not roleCache[p] then
            for _, c in ipairs(p:GetChildren()) do
                if c:IsA("BoolValue") and c.Value == true then
                    if c.Name == "Murderer" then roleCache[p] = "Murderer"
                    elseif c.Name == "Sheriff" then roleCache[p] = "Sheriff" end
                elseif c:IsA("StringValue") and (c.Value == "Murderer" or c.Value == "Sheriff") then
                    roleCache[p] = c.Value
                end
            end
        end
    end
end

-- Shared Helpers
local function alive(p)
    local c = p.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function hasKnife(p)
    local c = p.Character
    if not c then return false end
    local bp = p:FindFirstChild("Backpack")
    return (bp and bp:FindFirstChild("Knife")) or c:FindFirstChild("Knife")
end

local function hasGun(p)
    local c = p.Character
    if not c then return false end
    local bp = p:FindFirstChild("Backpack")
    return (bp and bp:FindFirstChild("Gun")) or c:FindFirstChild("Gun")
end

local function getMurderer()
    for p, r in pairs(roleCache) do
        if r == "Murderer" and alive(p) then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if alive(p) and hasKnife(p) then return p end
    end
    return nil
end

local function getMap()
    return Workspace:FindFirstChild("TheGunDrop") or Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Normal") or Workspace:FindFirstChild("Factory") or Workspace:FindFirstChild("House") or Workspace:FindFirstChild("Hospital") or Workspace:FindFirstChild("Hotel") or Workspace:FindFirstChild("Mansion") or Workspace:FindFirstChild("Office") or Workspace:FindFirstChild("PoliceStation") or Workspace:FindFirstChild("ResearchFacility") or Workspace:FindFirstChild("MilBase") or Workspace:FindFirstChild("Bank") or Workspace:FindFirstChild("BioLab")
end

-- Cleanup Functions
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

local function CleanGunESP()
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == "GunDropESP" or item.Name == "GunDropText" then
            item:Destroy()
        end
    end
end

-- ESP Logic Functions
local function UpdateESPEveryone()
    scanRoles()
    local murderer = getMurderer()
    local sheriff = nil
    local hero = nil

    for p, r in pairs(roleCache) do
        if r == "Sheriff" and alive(p) then sheriff = p; break end
    end

    if not sheriff then
        for _, p in ipairs(Players:GetPlayers()) do
            if alive(p) and p:FindFirstChild("Sheriff") and p.Sheriff.Value == true then
                sheriff = p; roleCache[p] = "Sheriff"; break
            end
        end
    end

    local gunner = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if alive(p) and hasGun(p) then gunner = p; break end
    end
    if gunner then
        if sheriff and gunner ~= sheriff then
            hero = gunner; roleCache[gunner] = "Hero"
        elseif not sheriff then
            sheriff = gunner; roleCache[gunner] = "Sheriff"
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer and not showSelfESP then
            local c = p.Character
            if c then
                local h = c:FindFirstChild("ESP_MM2")
                if h then h.Enabled = false end
                local t = c:FindFirstChild("ESP_Text_MM2")
                if t then t.Enabled = false end
            end
            continue
        end

        local c = p.Character
        if not c then continue end

        local name, color
        if p == murderer then
            name, color = "Murderer", Color3.fromRGB(255,0,0)
        elseif p == sheriff then
            name, color = "Sheriff", Color3.fromRGB(0,0,255)
        elseif p == hero then
            name, color = "Hero", Color3.fromRGB(255,215,0)
        else
            local root = c:FindFirstChild("HumanoidRootPart")
            if root and murderer and murderer.Character then
                local ap = murderer.Character:FindFirstChild("HumanoidRootPart")
                if ap then
                    local dist = (root.Position - ap.Position).Magnitude
                    color = dist > 300 and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,255,0)
                else
                    color = Color3.fromRGB(255,255,255)
                end
            else
                color = Color3.fromRGB(255,255,255)
            end
            name = nil
        end

        local h = c:FindFirstChild("ESP_MM2")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "ESP_MM2"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = c
        end
        if color then
            h.Enabled = true
            h.FillColor = color
            h.FillTransparency = (color == Color3.fromRGB(255,255,255)) and 0.9 or 0.4
        else
            h.Enabled = false
        end

        local tg = c:FindFirstChild("ESP_Text_MM2")
        if not tg then
            tg = Instance.new("BillboardGui")
            tg.Name = "ESP_Text_MM2"
            tg.Size = UDim2.new(0,200,0,50)
            tg.Adornee = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
            tg.StudsOffset = Vector3.new(0,2.5,0)
            tg.AlwaysOnTop = true
            tg.Parent = c

            local lbl = Instance.new("TextLabel")
            lbl.Name = "RoleLabel"
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.FredokaOne
            lbl.TextSize = 20
            lbl.TextStrokeTransparency = 0.5
            lbl.TextScaled = false
            lbl.Parent = tg
        end
        local lbl = tg:FindFirstChild("RoleLabel")
        if name and color then
            tg.Enabled = true
            lbl.Text = name
            lbl.TextColor3 = color
        else
            tg.Enabled = false
            lbl.Text = ""
        end
    end
end

local function UpdateDroppedGunESP()
    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if not gunDrop then
        local currentMap = getMap()
        if currentMap then
            gunDrop = currentMap:FindFirstChild("GunDrop")
        end
    end

    if gunDrop then
        local h = gunDrop:FindFirstChild("GunDropESP")
        if not h then
            h = Instance.new("Highlight")
            h.Name = "GunDropESP"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = Color3.fromRGB(243, 255, 19)
            h.OutlineColor = Color3.fromRGB(243, 255, 19)
            h.FillTransparency = 0.4
            h.Parent = gunDrop
        end
        h.Enabled = true

        local textGui = gunDrop:FindFirstChild("GunDropText")
        if not textGui then
            textGui = Instance.new("BillboardGui")
            textGui.Name = "GunDropText"
            textGui.Size = UDim2.new(0, 200, 0, 50)
            textGui.Adornee = gunDrop
            textGui.StudsOffset = Vector3.new(0, 2, 0)
            textGui.AlwaysOnTop = true
            textGui.Parent = gunDrop

            local label = Instance.new("TextLabel")
            label.Name = "GunLabel"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.FredokaOne
            label.TextSize = 20
            label.Text = "Dropped Gun!"
            label.TextColor3 = Color3.fromRGB(243, 255, 19)
            label.TextStrokeTransparency = 0.5
            label.TextScaled = false
            label.Parent = textGui
        end
        textGui.Enabled = true
    else
        CleanGunESP()
    end
end

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
CombatTab:CreateSection("Combat Controls")

-- ==========================================
-- TAB 3: VISUALS
-- ==========================================
local VisualsTab = Window:CreateTab("Visuals", "eye")

VisualsTab:CreateSection("ESP Options")

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
         CleanESP()
      end
   end,
})

VisualsTab:CreateToggle({
   Name = "Dropped Gun",
   CurrentValue = false,
   Flag = "DroppedGunToggle",
   Callback = function(Value)
      droppedGunEnabled = Value
      if droppedGunEnabled then
         droppedGunLoop = task.spawn(function()
            while droppedGunEnabled do
               pcall(UpdateDroppedGunESP)
               task.wait(0.2)
            end
         end)
      else
         if droppedGunLoop then task.cancel(droppedGunLoop) end
         CleanGunESP()
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

-- ==========================================
-- TAB 4: PLAYER
-- ==========================================
local PlayerTab = Window:CreateTab("Player", "user")
PlayerTab:CreateSection("Player Configurations")

-- ==========================================
-- TAB 5: FUN
-- ==========================================
local FunTab = Window:CreateTab("Fun", "smile")
FunTab:CreateSection("Fun Utilities")
