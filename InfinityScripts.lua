-- Services (Cached for performance)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Prevent duplicate GUIs & cleanup connections
if PlayerGui:FindFirstChild("InfinityScriptsGui") then
    PlayerGui.InfinityScriptsGui:Destroy()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfinityScriptsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

---------------------------------------------------------
-- OPTIMIZED RGB STROKE ANIMATOR
---------------------------------------------------------
local rgbStrokes = {}

local function AddRGBStroke(stroke)
    table.insert(rgbStrokes, stroke)
end

local hue = 0
local rgbConnection
rgbConnection = RunService.RenderStepped:Connect(function(dt)
    if not ScreenGui or not ScreenGui.Parent then
        rgbConnection:Disconnect()
        return
    end
    hue = (hue + (dt * 0.2)) % 1
    local color = Color3.fromHSV(hue, 0.85, 1)
    for i = #rgbStrokes, 1, -1 do
        local stroke = rgbStrokes[i]
        if stroke and stroke.Parent then
            stroke.Color = color
        else
            table.remove(rgbStrokes, i)
        end
    end
end)

---------------------------------------------------------
-- 10-SECOND INTRO / LOADING SCREEN
---------------------------------------------------------
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Size = UDim2.new(0, 260, 0, 185)
LoadingFrame.Position = UDim2.new(0.5, -130, 0.5, -92)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 10)
LoadCorner.Parent = LoadingFrame

local LoadStroke = Instance.new("UIStroke")
LoadStroke.Thickness = 2
LoadStroke.Parent = LoadingFrame
AddRGBStroke(LoadStroke)

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, 0, 0, 24)
LoadTitle.Position = UDim2.new(0, 0, 0, 12)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "⚡ INFINITY SCRIPTS"
LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadTitle.TextSize = 13
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Parent = LoadingFrame

-- Quotes Cycling Label
local QuoteLabel = Instance.new("TextLabel")
QuoteLabel.Size = UDim2.new(1, -20, 0, 32)
QuoteLabel.Position = UDim2.new(0, 10, 0, 38)
QuoteLabel.BackgroundTransparency = 1
QuoteLabel.Text = "Scripts you haven't know must be Here!"
QuoteLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
QuoteLabel.TextSize = 9
QuoteLabel.Font = Enum.Font.GothamMedium
QuoteLabel.TextWrapped = true
QuoteLabel.Parent = LoadingFrame

-- Progress Bar Background
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, -30, 0, 6)
ProgressBG.Position = UDim2.new(0, 15, 0, 76)
ProgressBG.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
ProgressBG.BorderSizePixel = 0
ProgressBG.Parent = LoadingFrame

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(1, 0)
ProgressCorner.Parent = ProgressBG

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBG

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = ProgressBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 14)
StatusLabel.Position = UDim2.new(0, 0, 0, 88)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading assets... 0%"
StatusLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
StatusLabel.TextSize = 8
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = LoadingFrame

-- Intro Discord Copy Button
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(1, -30, 0, 24)
DiscordBtn.Position = UDim2.new(0, 15, 0, 142)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.BorderSizePixel = 0
DiscordBtn.Text = "💬 Join Our Discord"
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordBtn.TextSize = 9
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.Parent = LoadingFrame

local DiscCorner = Instance.new("UICorner")
DiscCorner.CornerRadius = UDim.new(0, 6)
DiscCorner.Parent = DiscordBtn

local FastTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

DiscordBtn.MouseButton1Click:Connect(function()
    local discordInvite = "https://discord.gg/yourlink"
    if setclipboard then
        setclipboard(discordInvite)
        DiscordBtn.Text = "✔ Link Copied!"
        TweenService:Create(DiscordBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(46, 139, 87)}):Play()
        task.wait(1.5)
        DiscordBtn.Text = "💬 Join Our Discord"
        TweenService:Create(DiscordBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
    else
        DiscordBtn.Text = "✕ Clipboard Unsupported"
    end
end)

---------------------------------------------------------
-- UNIVERSAL DRAGGING HANDLER
---------------------------------------------------------
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

---------------------------------------------------------
-- COMPACT DRAGGABLE RGB TOGGLE CIRCLE (36px)
---------------------------------------------------------
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenButton"
OpenBtn.Size = UDim2.new(0, 36, 0, 36)
OpenBtn.Position = UDim2.new(0, 12, 0.5, -18)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
OpenBtn.BorderSizePixel = 0
OpenBtn.AutoButtonColor = false
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0
OpenStroke.Parent = OpenBtn
AddRGBStroke(OpenStroke)

task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId, 
        Enum.ThumbnailType.HeadShot, 
        Enum.ThumbnailSize.Size100x100
    )
    if isReady and OpenBtn and OpenBtn.Parent then
        OpenBtn.Image = content
    end
end)

MakeDraggable(OpenBtn)

---------------------------------------------------------
-- COMPACT MOBILE MAIN FRAME (250px x 240px)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0
MainStroke.Parent = MainFrame
AddRGBStroke(MainStroke)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 26)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

MakeDraggable(MainFrame, TopBar)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ INFINITY SCRIPTS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 10
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 1, 0)
CloseBtn.Position = UDim2.new(1, -26, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

---------------------------------------------------------
-- SCROLLING CONTAINER
---------------------------------------------------------
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -12, 1, -32)
ScrollContainer.Position = UDim2.new(0, 6, 0, 28)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 2
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = ScrollContainer

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 6)
end)

---------------------------------------------------------
-- MINI PROFILE BANNER (32px Height)
---------------------------------------------------------
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(1, 0, 0, 32)
ProfileCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
ProfileCard.BorderSizePixel = 0
ProfileCard.Parent = ScrollContainer

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 5)
ProfileCorner.Parent = ProfileCard

local ProfileStroke = Instance.new("UIStroke")
ProfileStroke.Thickness = 1
ProfileStroke.Transparency = 0.6
ProfileStroke.Parent = ProfileCard
AddRGBStroke(ProfileStroke)

local AvatarHolder = Instance.new("ImageLabel")
AvatarHolder.Size = UDim2.new(0, 22, 0, 22)
AvatarHolder.Position = UDim2.new(0, 5, 0.5, -11)
AvatarHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
AvatarHolder.BorderSizePixel = 0
AvatarHolder.Parent = ProfileCard

local HolderCorner = Instance.new("UICorner")
HolderCorner.CornerRadius = UDim.new(1, 0)
HolderCorner.Parent = AvatarHolder

task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId, 
        Enum.ThumbnailType.HeadShot, 
        Enum.ThumbnailSize.Size100x100
    )
    if isReady and AvatarHolder and AvatarHolder.Parent then
        AvatarHolder.Image = content
    end
end)

local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Size = UDim2.new(1, -34, 0, 11)
DisplayNameLabel.Position = UDim2.new(0, 32, 0, 5)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = LocalPlayer.DisplayName
DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayNameLabel.TextSize = 10
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLabel.Parent = ProfileCard

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Size = UDim2.new(1, -34, 0, 10)
UsernameLabel.Position = UDim2.new(0, 32, 0, 16)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. LocalPlayer.Name
UsernameLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
UsernameLabel.TextSize = 8
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.Parent = ProfileCard

---------------------------------------------------------
-- EXPANDABLE DROPDOWN CATEGORIES
---------------------------------------------------------
local function CreateDropdown(categoryTitle)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = categoryTitle .. "_Dropdown"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 24)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = ScrollContainer

    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 5)
    DropdownCorner.Parent = DropdownFrame

    local DropdownStroke = Instance.new("UIStroke")
    DropdownStroke.Thickness = 1
    DropdownStroke.Transparency = 0.8
    DropdownStroke.Parent = DropdownFrame
    AddRGBStroke(DropdownStroke)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = "  ▶  " .. categoryTitle
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 9
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.Parent = DropdownFrame

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -8, 0, 0)
    ContentContainer.Position = UDim2.new(0, 4, 0, 26)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = DropdownFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 3)
    ContentLayout.Parent = ContentContainer

    local isOpen = false

    local function UpdateHeight()
        local contentHeight = ContentLayout.AbsoluteContentSize.Y
        local targetHeight = isOpen and (28 + contentHeight) or 24
        
        TweenService:Create(DropdownFrame, FastTween, {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }):Play()
    end

    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)

    ToggleBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ToggleBtn.Text = (isOpen and "  ▼  " or "  ▶  ") .. categoryTitle
        UpdateHeight()
    end)

    return ContentContainer
end

local function CreateScriptButton(title, parentContainer, scriptFunc)
    local ScriptBtn = Instance.new("TextButton")
    ScriptBtn.Size = UDim2.new(1, 0, 0, 24)
    ScriptBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    ScriptBtn.BorderSizePixel = 0
    ScriptBtn.Text = "  ⚡  " .. title
    ScriptBtn.TextColor3 = Color3.fromRGB(240, 240, 250)
    ScriptBtn.TextSize = 8
    ScriptBtn.Font = Enum.Font.GothamMedium
    ScriptBtn.TextXAlignment = Enum.TextXAlignment.Left
    ScriptBtn.Parent = parentContainer

    local ScriptBtnCorner = Instance.new("UICorner")
    ScriptBtnCorner.CornerRadius = UDim.new(0, 4)
    ScriptBtnCorner.Parent = ScriptBtn

    local ScriptBtnStroke = Instance.new("UIStroke")
    ScriptBtnStroke.Thickness = 1
    ScriptBtnStroke.Transparency = 0.9
    ScriptBtnStroke.Parent = ScriptBtn
    AddRGBStroke(ScriptBtnStroke)

    ScriptBtn.MouseButton1Click:Connect(function()
        ScriptBtn.Text = "  ✔ Executing..."
        TweenService:Create(ScriptBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(0, 180, 120)}):Play()
        
        if scriptFunc then
            task.spawn(scriptFunc)
        end
        
        task.wait(0.8)
        ScriptBtn.Text = "  ⚡  " .. title
        TweenService:Create(ScriptBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(26, 26, 36)}):Play()
    end)
end

local function CreateAdButton(title, parentContainer, linkUrl, successText)
    local AdBtn = Instance.new("TextButton")
    AdBtn.Size = UDim2.new(1, 0, 0, 24)
    AdBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
    AdBtn.BorderSizePixel = 0
    AdBtn.Text = "  📢  " .. title
    AdBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    AdBtn.TextSize = 8
    AdBtn.Font = Enum.Font.GothamBold
    AdBtn.TextXAlignment = Enum.TextXAlignment.Left
    AdBtn.Parent = parentContainer

    local AdCorner = Instance.new("UICorner")
    AdCorner.CornerRadius = UDim.new(0, 4)
    AdCorner.Parent = AdBtn

    local AdStroke = Instance.new("UIStroke")
    AdStroke.Thickness = 1
    AdStroke.Color = Color3.fromRGB(255, 215, 0)
    AdStroke.Transparency = 0.6
    AdStroke.Parent = AdBtn

    AdBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(linkUrl)
            AdBtn.Text = "  ✔ " .. (successText or "Link Copied!")
            TweenService:Create(AdBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(46, 139, 87)}):Play()
            task.wait(1.5)
            AdBtn.Text = "  📢  " .. title
            TweenService:Create(AdBtn, FastTween, {BackgroundColor3 = Color3.fromRGB(35, 30, 50)}):Play()
        else
            AdBtn.Text = "  ✕ Clipboard Unsupported"
        end
    end)
end

---------------------------------------------------------
-- POPULATE CATEGORIES, PROMOTIONS & SCRIPTS
---------------------------------------------------------

-- 1. Community & Support Ads
local adsCategory = CreateDropdown("📢 Community & Support")
CreateAdButton("Join Our Discord Server", adsCategory, "https://discord.gg/yourlink", "DC Link Copied!")
CreateAdButton("Subscribe on YouTube", adsCategory, "https://youtube.com/@yourchannel", "YT Link Copied!")
CreateAdButton("Follow Our TikTok", adsCategory, "https://tiktok.com/@yourprofile", "TikTok Copied!")

-- 2. Age Evolution
local ageEvoCategory = CreateDropdown("🦕 Age Evolution")
CreateScriptButton("Age Evolution", ageEvoCategory, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lyamnigeldanauto21-dotcom/infinityscripts/main/aet.lua"))()
end)

-- 3. Pony Legends
local ponyCategory = CreateDropdown("🦄 Pony Legends")
CreateScriptButton("Pony Legends", ponyCategory, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lyamnigeldanauto21-dotcom/infinityscripts/main/ponylegends.lua"))()
end)

-- 4. Mega Princess
local princessCategory = CreateDropdown("👑 Mega Princess")
CreateScriptButton("Mega Princess", princessCategory, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lyamnigeldanauto21-dotcom/infinity/main/InfinityScripts.lua"))()
end)

-- 5. Murder Mystery 2
local mm2Category = CreateDropdown("🔪 Murder Mystery 2")

CreateScriptButton("MM2 (Yarmh)", mm2Category, function()
    local src = ""
    pcall(function() 
        src = game:HttpGet("https://yarhm.com", false)
    end)
    if src == "" then
        StarterGui:SetCore("SendNotification", {
            Title = "YARHM Outage";
            Text = "YARHM Online is currently unavailable! Sorry for the inconvenience. Using YARHM Offline.";
            Duration = 5;
        })
        src = game:HttpGet("https://raw.githubusercontent.com/Joystickplays/psychic-octo-invention/main/source/yarhm/1.21/yarhm.lua", false)
    end
    loadstring(src)()
end)

CreateScriptButton("MM2 (Waguri)", mm2Category, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Waguriiiii/Murder-mystery-2/refs/heads/main/Waguri.lua"))()
end)

CreateScriptButton("MM2 (Foxname)", mm2Category, function()
    loadstring(game:HttpGet("https://foxname.top/loader"))()
end)

CreateScriptButton("MM2 (SP HUB)", mm2Category, function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/as6cd0/SP_Hub/refs/heads/main/Loader"))()
end)

CreateScriptButton("Infinite MM2", mm2Category, function()
    StarterGui:SetCore("SendNotification", {
        Title = "Infinite MM2";
        Text = "Coming Soon!";
        Duration = 5;
    })
end)

-- 6. Universal Utilities
local utilityCategory = CreateDropdown("⚙️ Universal Tools")
CreateScriptButton("Infinite Yield FE", utilityCategory, function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)
CreateScriptButton("Rejoin Server", utilityCategory, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

---------------------------------------------------------
-- TOGGLE SYSTEM (OPEN / CLOSE)
---------------------------------------------------------
local function ToggleUI()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, FastTween, {Size = UDim2.new(0, 250, 0, 0)}):Play()
        task.wait(0.12)
        MainFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 250, 0, 240)
        }):Play()
    end
end

OpenBtn.MouseButton1Click:Connect(ToggleUI)
CloseBtn.MouseButton1Click:Connect(ToggleUI)

---------------------------------------------------------
-- INTRO SEQUENCE CONTROLLER (10-SECOND LOADER)
---------------------------------------------------------
task.spawn(function()
    local quotes = {
        "Scripts you haven't know must be Here!",
        "Don't forget to join our Discord!",
        "Subscribe to our YouTube channel!",
        "Loading MM2, Pony Legends & Age Evolution...",
        "Setting up custom RGB strokes...",
        "Ready to execute!"
    }
    
    local totalTime = 10
    local steps = 100
    
    for i = 1, steps do
        local progress = i / steps
        ProgressBar.Size = UDim2.new(progress, 0, 1, 0)
        StatusLabel.Text = string.format("Loading assets... %d%%", math.floor(progress * 100))
        
        if i % 18 == 0 then
            QuoteLabel.Text = quotes[(math.floor(i / 18) % #quotes) + 1]
        end
        
        task.wait(totalTime / steps)
    end
    
    -- Transition out of intro
    TweenService:Create(LoadingFrame, FastTween, {Size = UDim2.new(0, 260, 0, 0)}):Play()
    task.wait(0.15)
    LoadingFrame:Destroy()
    
    -- Show Floating RGB Avatar Circle
    OpenBtn.Visible = true
    
    -- Reveal Main Frame
    MainFrame.Size = UDim2.new(0, 250, 0, 0)
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 250, 0, 240)
    }):Play()
end)
