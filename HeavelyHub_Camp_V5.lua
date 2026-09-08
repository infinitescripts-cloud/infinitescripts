--========================================================--
-- HEAVELY HUB (CAMP)
-- Total Roblox Drama
-- Luna UI + Camp logic integration
-- No Autoplay
--========================================================--

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local player = Players.LocalPlayer
local Window
local firetouchinterest = firetouchinterest
local fireclickdetector = fireclickdetector

--========================================================--
-- CAMP CHECK
--========================================================--

if game.PlaceId ~= 4939362930 then
    warn("Heavely Hub (Camp): Camp place not detected.")
    return
end

local function char()
    return player.Character
end

local function root()
    local c = char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local function hum()
    local c = char()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function assets()
    return workspace:FindFirstChild("Assets")
end

local function season()
    return ReplicatedStorage:FindFirstChild("Season")
end

local function safeNotify(title, content)
    pcall(function()
        Window:Notify({Title = title, Content = content, Duration = 4})
    end)
end

--========================================================--
-- STATE
--========================================================--

local S = {
    autoObby = false,
    math = false,
    mathDelay = 0,
    autoCollect = false,
    autoDodgeballs = false,
    dodgeProtection = false,
    paintProtection = false,
    swordFight = false,
    cliffESP = false,
    statueESP = false,
    bagESP = false,
    notifyVotes = false,
    exposeVotes = false,
    printVotes = false,
    notifyJury = false,
    autoRound = false,
    waterWalk = false,
    playerESP = false,
    targetHighlight = false,
    walkSpeed = 16,
    jumpPower = 50,
    fov = 70,
    target = "None",
    customName = "",
    rainbowName = false,
    rainbowSpeed = .5,
    rainbowMarsh = false
}

local CONN = {}
local ESP = {}

local function disconnect(k)
    if CONN[k] then pcall(function() CONN[k]:Disconnect() end) CONN[k] = nil end
end

--========================================================--
-- WINDOW
--========================================================--

Window = Luna:CreateWindow({
    Name = "Heavely Hub (Camp)",
    Subtitle = "Total Roblox Drama",
    LogoID = 117588015510601,
    LoadingEnabled = true,
    LoadingTitle = "Heavely Hub",
    LoadingSubtitle = "Loading Camp interface...",
    ConfigSettings = {RootFolder = "HeavelyHub", ConfigFolder = "Configs"},
    KeySystem = false
})

Window:CreateHomeTab({SupportedExecutors = {}, DiscordInvite = "", Icon = 2})

local ICON = {
    Main=127889862453151, Challenges=113884228231281, Characters=103422319407938,
    Universal=111578783307093, Utilities=115083821531795, Client=73331152826648,
    Setting=134998527925514
}

local function tab(name, icon)
    return Window:CreateTab({Name=name, Icon=icon, ImageSource="Custom", ShowTitle=true})
end

local Main = tab("Main", ICON.Main)
local Challenges = tab("Challenges", ICON.Challenges)
local Characters = tab("Characters", ICON.Characters)
local Universal = tab("Universal", ICON.Universal)
local Utilities = tab("Utilities", ICON.Utilities)
local Client = tab("Client", ICON.Client)
local Setting = tab("Setting", ICON.Setting)

--========================================================--
-- MAIN: VOTING
--========================================================--

local function voteFolder()
    local se = season()
    local voting = se and se:FindFirstChild("Voting")
    return se, voting and voting:FindFirstChild("Votes")
end

local function voteText(v)
    local se = season()
    local pf = se and se:FindFirstChild("Players")
    local rv = pf and pf:FindFirstChild(tostring(v.Value))
    local dv = pf and pf:FindFirstChild(tostring(v.Name))
    return tostring(rv and rv.Value or v.Value), tostring(dv and dv.Value or v.Name)
end

Main:CreateSection("Voting")
Main:CreateToggle({Name="Notify Votes", CurrentValue=false, Callback=function(v)
    S.notifyVotes=v; disconnect("votesNotify")
    if v then
        local _, votes=voteFolder()
        if votes then CONN.votesNotify=votes.ChildAdded:Connect(function(x)
            local a,b=voteText(x); safeNotify("Vote Update", a.." voted for "..b)
        end) end
    end
end})

Main:CreateToggle({Name="Expose Votes", CurrentValue=false, Callback=function(v)
    S.exposeVotes=v; disconnect("votesExpose")
    if v then
        local _, votes=voteFolder()
        if votes then CONN.votesExpose=votes.ChildAdded:Connect(function(x)
            local a,b=voteText(x)
            pcall(function()
                local ch=TextChatService.TextChannels.RBXGeneral
                if ch then ch:SendAsync(a.." voted for "..b) end
            end)
        end) end
    end
end})

Main:CreateToggle({Name="Print Votes in Console", CurrentValue=false, Callback=function(v)
    S.printVotes=v; disconnect("votesPrint")
    if v then
        local _, votes=voteFolder()
        if votes then CONN.votesPrint=votes.ChildAdded:Connect(function(x)
            local a,b=voteText(x); print(a.." voted for "..b)
        end) end
    end
end})

Main:CreateToggle({Name="Notify & Print Exile Votes", CurrentValue=false, Callback=function(v)
    S.notifyVotes=v; S.printVotes=v; disconnect("votesExile")
    if v then
        local _, votes=voteFolder()
        if votes then CONN.votesExile=votes.ChildAdded:Connect(function(x)
            local a,b=voteText(x); print(a.." voted for "..b); safeNotify("Exile Vote", a.." voted for "..b)
        end) end
    end
end})

Main:CreateToggle({Name="Notify Jury Votes", CurrentValue=false, Callback=function(v)
    S.notifyJury=v
    if not v then
        if CONN.jury then for _,c in ipairs(CONN.jury) do pcall(function() c:Disconnect() end) end end
        CONN.jury=nil
        return
    end
    CONN.jury={}
    local se=season(); local jury=se and se:FindFirstChild("Jury")
    if jury then
        local function watch(j)
            local list=j:FindFirstChild("List") or j:WaitForChild("List",2)
            if list then table.insert(CONN.jury,list.ChildAdded:Connect(function(x)
                local voter=j.Value; local votee=x.Value
                local pf=se:FindFirstChild("Players")
                local mapped=pf and pf:FindFirstChild(x.Name)
                if mapped then votee=mapped.Value end
                safeNotify("Jury Vote",tostring(voter).." voted for "..tostring(votee))
            end)) end
        end
        for _,j in ipairs(jury:GetChildren()) do watch(j) end
        table.insert(CONN.jury,jury.ChildAdded:Connect(watch))
    end
end})

Main:CreateSection("Webhook")
local webhookURL=""
Main:CreateInput({Name="Webhook", PlaceholderText="Webhook URL...", CurrentValue="", Numeric=false, Callback=function(v) webhookURL=v end})
Main:CreateToggle({Name="Send Votes to Webhook", CurrentValue=false, Callback=function(v)
    -- Kept as the UI control; webhook dispatch is intentionally not enabled in this build.
    if v then safeNotify("Webhook", "Webhook control enabled, but outbound dispatch is disabled.") end
end})

--========================================================--
-- MAIN: STATUE
--========================================================--

local function grabStatues()
    local idols=workspace:FindFirstChild("Idols")
    if not idols then return end
    local r=root(); if not r then return end
    for _,v in ipairs(idols:GetDescendants()) do
        if (v.Name=="Bag" or v.Name=="SafetyStatue") and v:FindFirstChild("hit") then
            local h=v.hit
            if h:IsA("BasePart") then
                h.CanCollide=false; h.Transparency=1; h.CFrame=r.CFrame
            end
        end
    end
end

Main:CreateSection("Safety Statue")
Main:CreateButton({Name="Get Safety Statue", Callback=grabStatues})
Main:CreateButton({Name="Get Safety Statue Immediately", Callback=function()
    task.spawn(function() for _=1,50 do grabStatues(); task.wait(.05) end end)
end})
Main:CreateButton({Name="Detect Who Has Statue", Callback=function()
    local se=season(); local voting=se and se:FindFirstChild("Voting")
    local idol=se and se:FindFirstChild("Twists") and se.Twists:FindFirstChild("Idol")
    if idol and idol.Value and tostring(idol.Value)~="" then
        local pf=se and se:FindFirstChild("Players"); local x=pf and pf:FindFirstChild(tostring(idol.Value))
        safeNotify("Statue Owner", tostring(x and x.Value or idol.Value).." has the statue")
    else
        safeNotify("Statue Owner","Nobody currently has the statue.")
    end
end})

local function statueESP(on)
    local idols=workspace:FindFirstChild("Idols"); if not idols then return end
    for _,v in ipairs(idols:GetDescendants()) do
        if v.Name=="SafetyStatue" and v:IsA("Model") then
            local old=v:FindFirstChild("HeavelyStatueESP")
            if on and not old then
                local h=Instance.new("Highlight"); h.Name="HeavelyStatueESP"; h.FillTransparency=1; h.OutlineColor=Color3.new(1,1,1); h.Parent=v
            elseif not on and old then old:Destroy() end
        end
    end
end
Main:CreateToggle({Name="Safety Statue ESP", CurrentValue=false, Callback=function(v) S.statueESP=v; statueESP(v) end})
Main:CreateToggle({Name="Bag ESP", CurrentValue=false, Callback=function(v)
    S.bagESP=v
    local idols=workspace:FindFirstChild("Idols"); if not idols then return end
    for _,bag in ipairs(idols:GetDescendants()) do
        if bag.Name=="Bag" and bag:IsA("Model") then
            local old=bag:FindFirstChild("HeavelyBagESP")
            if v and not old then
                local p=bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart")
                if p then
                    local h=Instance.new("Highlight"); h.Name="HeavelyBagESP"; h.FillTransparency=1; h.OutlineColor=Color3.new(1,1,1); h.Parent=bag
                    local bb=Instance.new("BillboardGui"); bb.Name="HeavelyBagLabel"; bb.Size=UDim2.new(0,180,0,40); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Adornee=p; bb.Parent=bag
                    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text="SAFETY BAG"; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=0; t.TextScaled=true; t.Font=Enum.Font.GothamBold; t.Parent=bb
                end
            elseif not v then
                if old then old:Destroy() end
                local l=bag:FindFirstChild("HeavelyBagLabel"); if l then l:Destroy() end
            end
        end
    end
end})

Main:CreateSection("Rounds / More")
local roundNames={
    Undecided="Round not decided yet - the twist hasn't been set.",
    normal="Normal Round - Casual round, nothing special.",
    purge="Purge Round - This will be a purge round.",
    double="Double Elimination - Two people will be eliminated.",
    singleswap="Sike Round - Eliminated player gets swapped to another team.",
    exile="Exile Vote Round - There will be an exile vote.",
    votereveal="Vote Reveal - Kyle will expose the votes this round."
}
local function currentTwist()
    local se=season(); local twists=se and se:FindFirstChild("Twists")
    return twists and twists:FindFirstChild("CurrentTwist")
end
local function detectRound()
    local t=currentTwist()
    if not t then safeNotify("Round Detected","CurrentTwist was not found yet."); return end
    safeNotify("Round Detected",roundNames[t.Value] or ("Unknown round type: "..tostring(t.Value)))
end
Main:CreateButton({Name="Detect Round", Callback=detectRound})
Main:CreateToggle({Name="Auto-detect Round", CurrentValue=false, Callback=function(v)
    S.autoRound=v; disconnect("round")
    if v then
        local t=currentTwist()
        if t then
            CONN.round=t:GetPropertyChangedSignal("Value"):Connect(function() detectRound() end)
            detectRound()
        else
            CONN.round=RunService.Heartbeat:Connect(function()
                if not S.autoRound then return end
                local now=currentTwist()
                if now then
                    disconnect("round")
                    CONN.round=now:GetPropertyChangedSignal("Value"):Connect(function() detectRound() end)
                    detectRound()
                end
            end)
        end
    end
end})
Main:CreateButton({Name="Detect Teamers", Callback=function()
    local se=season(); local pf=se and se:FindFirstChild("Players")
    if not pf then safeNotify("Teamers","Season.Players was not found."); return end
    local found=false
    for i,p1 in ipairs(Players:GetPlayers()) do
        for j,p2 in ipairs(Players:GetPlayers()) do
            if j>i then
                local ok,friends=pcall(function() return p1:IsFriendsWith(p2.UserId) end)
                if ok and friends then
                    found=true
                    local d1=pf:FindFirstChild(p1.Name); local d2=pf:FindFirstChild(p2.Name)
                    safeNotify("Teamer Detected",tostring(d1 and d1.Value or p1.Name).." is friends with "..tostring(d2 and d2.Value or p2.Name))
                    task.wait(.4)
                end
            end
        end
    end
    if not found then safeNotify("No Teamers Found","No friend pairs detected in this lobby.") end
end})
Main:CreateButton({Name="Fling / Restart Day", Callback=function() safeNotify("Restart Day","The source uses an external reanimation payload; it is not embedded in this build.") end})
Main:CreateButton({Name="Limb Reanimation", Callback=function() safeNotify("Limb Reanimation","The source uses an external reanimation payload; it is not embedded in this build.") end})
Main:CreateButton({Name="Destroy Extravagant Names", Callback=function()
    local function destroyLongText(parent)
        for _,x in ipairs(parent:GetDescendants()) do
            if (x:IsA("TextLabel") or x:IsA("TextButton") or x:IsA("TextBox")) and #x.Text>750 then x:Destroy() end
        end
    end
    destroyLongText(player.PlayerGui); destroyLongText(workspace)
    safeNotify("Names","Long text elements removed.")
end})
Main:CreateButton({Name="Remove Cutscene", Callback=function()
    local ev=ReplicatedStorage:FindFirstChild("Events"); local cam=ev and ev:FindFirstChild("Camera")
    if cam then cam:Destroy() end
    local h=hum(); local c=workspace.CurrentCamera
    if h and c then c.CameraType=Enum.CameraType.Custom; c.CameraSubject=h end
end})

--========================================================--
-- CHALLENGES: EXACT CAMP EQUIVALENTS WITH YOUR NAMES
--========================================================--

Challenges:CreateSection("Obby")

local function winObby()
    local a=assets(); local r=root(); if not a or not r then return end
    local finish=a:FindFirstChild("Finish",true)
    if finish and finish:IsA("BasePart") then
        finish.CanCollide=false; finish.Transparency=1; task.wait(); finish.Position=r.Position
    end
end

Challenges:CreateButton({Name="Win Obby", Callback=winObby})
Challenges:CreateToggle({Name="Auto Win Obby", CurrentValue=false, Callback=function(v)
    S.autoObby=v
    disconnect("obby")
    if v then CONN.obby=task.spawn(function()
        while S.autoObby do winObby(); task.wait(.1) end
    end) end
end})

Challenges:CreateToggle({Name="Obby Invincibility", CurrentValue=false, Callback=function(v)
    local a=assets(); if not a then return end
    for _,x in ipairs(a:GetDescendants()) do
        if x.Name=="Mud" or x.Name=="Water" or x.Name=="Lava" then
            local ti=x:FindFirstChild("TouchInterest")
            if v and ti then ti:Destroy() end
        end
    end
end})

Challenges:CreateSection("Spleef")
Challenges:CreateToggle({Name="Disable Spinner / Sweeper Parts", CurrentValue=false, Callback=function(v)
    if not v then return end
    local function disable(part)
        for _,x in ipairs(part:GetChildren()) do
            if x:IsA("TouchTransmitter") then x:Destroy() end
        end
    end
    for _,x in ipairs(workspace:GetDescendants()) do if x:IsA("UnionOperation") then disable(x) end end
    disconnect("sweep")
    CONN.sweep=workspace.DescendantAdded:Connect(function(x)
        if x:IsA("UnionOperation") then task.wait(); disable(x) end
    end)
end})

Challenges:CreateToggle({Name="Spleef Invincibility", CurrentValue=false, Callback=function(v)
    local a=assets(); local sp=a and a:FindFirstChild("Spleef"); local p=sp and sp:FindFirstChild("Part")
    if v and p then local ti=p:FindFirstChild("TouchInterest"); if ti then ti:Destroy() end end
end})

Challenges:CreateButton({Name="Remove Every Fragment in Spleef", Callback=function()
    local a=assets(); local r=root(); if not a or not r then return end
    for _,x in ipairs(a:GetDescendants()) do
        if x.Name=="SpleefPart" and firetouchinterest then
            pcall(function() firetouchinterest(r,x,0) end)
        end
    end
end})

Challenges:CreateSection("Math Mania")
local function solveMathOnce()
    local gui=player.PlayerGui:FindFirstChild("MathMania"); if not gui then return end
    for n=1,10 do
        if not S.math then break end
        local q=gui:FindFirstChild(tostring(n))
        if q then
            local mt=q:FindFirstChild("MainText"); local box=q:FindFirstChild("Box"); local enter=q:FindFirstChild("Enter")
            if mt and box then
                local expression=mt.Text:gsub("=",""):gsub("?",""):gsub(" ","")
                local ok,result=pcall(function() return loadstring("return "..expression)() end)
                if ok and result then
                    box.Text=tostring(result)
                    if enter and getconnections then
                        for _,signal in ipairs({enter.MouseButton1Click,enter.MouseButton1Down,enter.Activated}) do
                            pcall(function() for _,c in ipairs(getconnections(signal)) do if c.Function then c:Fire() end end end)
                        end
                    end
                    if S.mathDelay>0 then task.wait(S.mathDelay) end
                end
            end
        end
    end
end
Challenges:CreateToggle({Name="Auto Answer Math Mania", CurrentValue=false, Callback=function(v)
    S.math=v; disconnect("math")
    if v then task.spawn(function() while S.math do solveMathOnce(); task.wait() end end) end
end})
Challenges:CreateSlider({Name="Math Mania Answer Delay", Range={0,10}, Increment=.1, Suffix="s", CurrentValue=0, Callback=function(v) S.mathDelay=v end})

Challenges:CreateSection("Dodgeball / Paintball")
Challenges:CreateToggle({Name="Auto Take Dodgeballs", CurrentValue=false, Callback=function(v)
    S.autoDodgeballs=v; disconnect("dodge")
    if v then task.spawn(function()
        while S.autoDodgeballs do
            local r=root(); local a=assets()
            if r and a and firetouchinterest then
                for _,x in ipairs(a:GetDescendants()) do
                    if x:IsA("BasePart") and x.Name:lower():find("dodgeball") then
                        pcall(function() firetouchinterest(r,x,0); firetouchinterest(r,x,1) end)
                    end
                end
            end
            task.wait(.1)
        end
    end) end
end})

-- These two names are mapped to the source's protection behavior.
-- The original logic reacted by resetting the local character when the event appeared.
Challenges:CreateToggle({Name="Dodgeball Invincibility", CurrentValue=false, Callback=function(v)
    S.dodgeProtection=v; disconnect("dodgeProtect")
    if v then
        CONN.dodgeProtect=task.spawn(function()
            local triggered=false
            while S.dodgeProtection do
                local a=assets()
                local giver=a and a:FindFirstChild("DodgeballGiver", true)
                if giver and not triggered then
                    triggered=true
                    local h=hum(); if h then h.Health=0 end
                elseif not giver then
                    triggered=false
                end
                task.wait(.1)
            end
        end)
    end
end})
Challenges:CreateToggle({Name="Paintball Invincibility", CurrentValue=false, Callback=function(v)
    S.paintProtection=v; disconnect("paintProtect")
    if v then
        CONN.paintProtect=task.spawn(function()
            local triggered=false
            while S.paintProtection do
                local a=assets()
                local arena=a and (a:FindFirstChild("Paintball", true) or a:FindFirstChild("PaintballArena", true))
                if arena and not triggered then
                    triggered=true
                    local h=hum(); if h then h.Health=0 end
                elseif not arena then
                    triggered=false
                end
                task.wait(.1)
            end
        end)
    end
end})

Challenges:CreateSection("Camp Events")
local cliffObjects={}
local function clearCliff()
    for part,o in pairs(cliffObjects) do pcall(function() o.bill:Destroy() end); pcall(function() o.hl:Destroy() end); cliffObjects[part]=nil end
end
local function makeCliff(part)
    if cliffObjects[part] or not part:IsA("BasePart") then return end
    local h=Instance.new("Highlight"); h.Name="HeavelyCliffHighlight"; h.FillTransparency=1; h.OutlineColor=Color3.new(1,1,1); h.Parent=part
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,260,0,70); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=part
    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text="FINISH"; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=0; t.TextScaled=true; t.Font=Enum.Font.GothamBold; t.Parent=bb
    cliffObjects[part]={bill=bb,hl=h,label=t}
end
Challenges:CreateToggle({Name="Cliff Diving ESP", CurrentValue=false, Callback=function(v)
    S.cliffESP=v; disconnect("cliffAdd"); disconnect("cliffRender"); clearCliff()
    if v then
        for _,x in ipairs(workspace:GetDescendants()) do if x:IsA("BasePart") and x.Name:lower()=="finish" then makeCliff(x) end end
        CONN.cliffAdd=workspace.DescendantAdded:Connect(function(x) if S.cliffESP and x:IsA("BasePart") and x.Name:lower()=="finish" then makeCliff(x) end end)
        CONN.cliffRender=RunService.RenderStepped:Connect(function()
            local r=root(); if not r then return end
            for part,o in pairs(cliffObjects) do if part.Parent then local d=(part.Position-r.Position).Magnitude; o.bill.Enabled=d<=500; o.label.Text=string.format("FINISH\n%.1f studs",d) end end
        end)
    end
end})
Challenges:CreateToggle({Name="Auto Get All Coins and Gems", CurrentValue=false, Callback=function(v)
    S.autoCollect=v
    if v then task.spawn(function()
        while S.autoCollect do
            local r=root(); local a=assets()
            if r and a then
                for _,x in ipairs(a:GetDescendants()) do
                    if (x.Name=="Coin" or x.Name=="Gem") and x:IsA("BasePart") then x.CanCollide=false; x.Position=r.Position end
                end
            end
            task.wait(.5)
        end
    end) end
end})
Challenges:CreateButton({Name="Finish Pancake", Callback=function()
    local a=assets(); if not a then return end
    for _,x in ipairs(a:GetDescendants()) do
        if x.Name==player.Name then
            local cd=x:FindFirstChild("ClickDetector")
            if cd and fireclickdetector then for _=1,80 do pcall(function() fireclickdetector(cd) end) end end
        end
    end
end})
Challenges:CreateButton({Name="Succeed Block Push", Callback=function()
    local r=root(); if not r then return end
    for _,box in ipairs(workspace:GetDescendants()) do
        if box:IsA("Part") and box.Name=="SingularBox" and (box.Position-r.Position).Magnitude<=100 then
            for _,gold in ipairs(workspace:GetDescendants()) do
                if gold:IsA("Part") and gold.Name=="Gold" then
                    box.Position=gold.Position+Vector3.new(0,3,0); r.CFrame=CFrame.new(box.Position+Vector3.new(0,3,0)); return
                end
            end
        end
    end
end})

Challenges:CreateButton({Name="Slay Everyone in Swordfight", Callback=function()
    if not firetouchinterest then return end
    local backpack=player:FindFirstChild("Backpack"); local c=char(); local h=hum(); local tool
    if backpack and h then
        for _,t in ipairs(backpack:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("sword") then tool=t; break end end
        if tool then pcall(function() h:EquipTool(tool) end) end
    end
    tool=c and c:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        pcall(function() tool:Activate() end)
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                for _,part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then pcall(function() firetouchinterest(tool.Handle,part,0); firetouchinterest(tool.Handle,part,1) end) end
                end
            end
        end
    end
end})

--========================================================--
-- UNIVERSAL
--========================================================--

Universal:CreateSection("Movement")
Universal:CreateSlider({Name="Walk Speed",Range={1,350},Increment=1,CurrentValue=16,Callback=function(v) S.walkSpeed=v; local h=hum(); if h then h.WalkSpeed=v end end})
Universal:CreateSlider({Name="Jump Power",Range={1,350},Increment=1,CurrentValue=50,Callback=function(v) S.jumpPower=v; local h=hum(); if h then h.JumpPower=v end end})
Universal:CreateSlider({Name="Camera FOV",Range={30,120},Increment=1,CurrentValue=70,Callback=function(v) S.fov=v; if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=v end end})
Universal:CreateSection("Player")
Universal:CreateToggle({Name="Water Walk",CurrentValue=false,Callback=function(v)
    S.waterWalk=v
    local map=workspace:FindFirstChild("Map"); local camp=map and map:FindFirstChild("Roblox Drama: Camp"); local cm=camp and camp:FindFirstChild("Map"); local lake=cm and cm:FindFirstChild("Lake"); local water=lake and lake:FindFirstChild("Water")
    if water then water.CanCollide=v end
end})
Universal:CreateButton({Name="Disable Lake Damage",Callback=function()
    local map=workspace:FindFirstChild("Map"); local camp=map and map:FindFirstChild("Roblox Drama: Camp"); local sand=camp and camp:FindFirstChild("Sand"); local ti=sand and sand:FindFirstChild("TouchInterest"); if ti then ti:Destroy() end
end})
Universal:CreateButton({Name="Remove Map Barriers",Callback=function()
    for _,x in ipairs(workspace:GetDescendants()) do if x.Name=="Glass" or x.Name=="ChallengeGlass" or x.Name=="AwardCeremony" or x.Name=="Drop-Off" then x:Destroy() end end
end})
local targetDropdown
local targetList={"None"}
local function refreshTargets()
    targetList={"None"}; local se=season(); local pf=se and se:FindFirstChild("Players")
    if pf then for _,x in ipairs(pf:GetChildren()) do if x.Name~=player.Name and x:IsA("ValueBase") then table.insert(targetList,tostring(x.Value)) end end end
    if targetDropdown then pcall(function() targetDropdown:Refresh(targetList); targetDropdown:Set({targetList[1]}) end) end
    S.target=targetList[1]
end
refreshTargets()
targetDropdown=Universal:CreateDropdown({Name="Target Player",Options=targetList,CurrentOption={targetList[1]},MultipleOptions=false,Callback=function(v) S.target=type(v)=="table" and v[1] or v end})
Universal:CreateButton({Name="Refresh Player Targets",Callback=refreshTargets})
Universal:CreateButton({Name="Teleport to Target",Callback=function()
    local se=season(); local pf=se and se:FindFirstChild("Players"); local r=root(); if not pf or not r or S.target=="None" then return end
    for _,x in ipairs(pf:GetChildren()) do if tostring(x.Value)==tostring(S.target) then local p=Players:FindFirstChild(x.Name); local tr=p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if tr then r.CFrame=tr.CFrame end end end
end})
Universal:CreateToggle({Name="Target Highlight",CurrentValue=false,Callback=function(v)
    S.targetHighlight=v
    for _,p in ipairs(Players:GetPlayers()) do local c=p.Character; local h=c and c:FindFirstChild("HeavelyTargetHighlight"); if h then h:Destroy() end end
    if v and S.target~="None" then
        local se=season(); local pf=se and se:FindFirstChild("Players")
        if pf then for _,x in ipairs(pf:GetChildren()) do if tostring(x.Value)==tostring(S.target) then local p=Players:FindFirstChild(x.Name); if p and p.Character then local h=Instance.new("Highlight"); h.Name="HeavelyTargetHighlight"; h.FillColor=Color3.fromRGB(255,221,0); h.OutlineColor=Color3.fromRGB(255,221,0); h.Parent=p.Character end end end end
    end
end})
Universal:CreateSection("Combat")
local aimEnabled=false
local aimSmooth=50
local aimDistance=500
local aimFov=150
local visibilityCheck=true
local hitboxEnabled=false
local hitboxSize=.5
local originalSizes={}
local function nearestTarget()
    local cam=workspace.CurrentCamera; if not cam then return nil end
    local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local best,bestD=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then
            local c=p.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); local h=c and c:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health>0 then
                local dist=(r.Position-(root() and root().Position or r.Position)).Magnitude
                local pos,on=cam:WorldToViewportPoint(r.Position)
                local sd=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                if on and dist<=aimDistance and sd<=aimFov and sd<bestD then
                    local visible=true
                    if visibilityCheck then
                        local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={char(),c}
                        local hit=workspace:Raycast(cam.CFrame.Position,r.Position-cam.CFrame.Position,params)
                        visible=hit==nil
                    end
                    if visible then best,bestD=p,sd end
                end
            end
        end
    end
    return best
end
Universal:CreateToggle({Name="Aimbot",CurrentValue=false,Callback=function(v) aimEnabled=v; disconnect("aim") end})
Universal:CreateToggle({Name="Player ESP",CurrentValue=false,Callback=function(v)
    S.playerESP=v
    for p,h in pairs(ESP) do if not v and h then h:Destroy(); ESP[p]=nil end end
    if v then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                local h=Instance.new("Highlight"); h.Name="HeavelyPlayerESP"; h.FillTransparency=.65; h.OutlineTransparency=0; h.Parent=p.Character; ESP[p]=h
            end
        end
    end
end})
Universal:CreateToggle({Name="Hitbox Expansion",CurrentValue=false,Callback=function(v)
    hitboxEnabled=v
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                if v then
                    originalSizes[r]=originalSizes[r] or r.Size
                    r.Size=Vector3.new(2+hitboxSize*2,2+hitboxSize*2,1+hitboxSize*2)
                elseif originalSizes[r] then r.Size=originalSizes[r] end
            end
        end
    end
end})
Universal:CreateToggle({Name="Visibility Check",CurrentValue=true,Callback=function(v) visibilityCheck=v end})
Universal:CreateSlider({Name="Aim Smoothness",Range={1,100},Increment=1,CurrentValue=50,Callback=function(v) aimSmooth=v end})
Universal:CreateSlider({Name="Aim Distance",Range={50,1000},Increment=10,CurrentValue=500,Callback=function(v) aimDistance=v end})
Universal:CreateSlider({Name="Aim FOV",Range={10,500},Increment=5,CurrentValue=150,Callback=function(v) aimFov=v end})
Universal:CreateSlider({Name="Hitbox Size",Range={0,10},Increment=.5,CurrentValue=.5,Callback=function(v) hitboxSize=v end})
Universal:CreateSection("Visuals")
Universal:CreateButton({Name="Apply Shaders",Callback=function()
    Lighting.Brightness=2; Lighting.GlobalShadows=false; Lighting.FogEnd=100000; Lighting.EnvironmentDiffuseScale=0; Lighting.EnvironmentSpecularScale=0
    safeNotify("Shaders","Local lighting enhancement applied.")
end})
Universal:CreateButton({Name="Open Utility Panel",Callback=function() safeNotify("Utility Panel","Use the Utilities tab.") end})
Universal:CreateButton({Name="Open Sound Controls",Callback=function()
    for _,x in ipairs(game:GetDescendants()) do if x:IsA("Sound") then x.Volume=math.clamp(x.Volume,0,1) end end
    safeNotify("Sound Controls","Sound controls are client-side only.")
end})

--========================================================--
-- UTILITIES
--========================================================--

Utilities:CreateSection("Character")
Utilities:CreateButton({Name="Refresh Character",Callback=function() player:LoadCharacter() end})
Utilities:CreateButton({Name="Reset Character",Callback=function() local h=hum(); if h then h.Health=0 end end})
Utilities:CreateButton({Name="Force Respawn",Callback=function() player:LoadCharacter() end})
Utilities:CreateSection("Camp Locations")
local locations={
    ["Main Island"]=CFrame.new(150,-17,-417), ["Spectator Island"]=CFrame.new(33,-16,31),
    ["Exile Island"]=CFrame.new(-116,-14,-166), ["Voting Grounds"]=CFrame.new(-23,95,-514),
    ["Boat"]=CFrame.new(89,63,-148), ["Bathroom"]=CFrame.new(17,65,-24)
}
for name,cf in pairs(locations) do Utilities:CreateButton({Name=name,Callback=function() local r=root(); if r then r.CFrame=cf end end}) end
Utilities:CreateSection("Player Inspector")
local inspect="None"; local inspectDropdown=Utilities:CreateDropdown({Name="Inspect Player",Options={"None"},CurrentOption={"None"},MultipleOptions=false,Callback=function(v) inspect=type(v)=="table" and v[1] or v end})
Utilities:CreateButton({Name="Refresh Player List",Callback=function() refreshTargets(); pcall(function() inspectDropdown:Refresh(targetList); inspectDropdown:Set({targetList[1]}) end) end})
Utilities:CreateButton({Name="View Player Stats",Callback=function()
    local p=Players:FindFirstChild(inspect); if not p then return end
    local ds=p:FindFirstChild("DataStore"); if not ds then safeNotify("Stats","DataStore not found."); return end
    local lines={}; for _,n in ipairs({"CampWins","ComebackWins","Coins","GamesPlayed","IdolsFound"}) do local x=ds:FindFirstChild(n); if x then table.insert(lines,n..": "..tostring(x.Value)) end end
    safeNotify(inspect.." Stats",#lines>0 and table.concat(lines,"\n") or "No readable stats found.")
end})
Utilities:CreateButton({Name="List Player Skins",Callback=function()
    local p=Players:FindFirstChild(inspect); local ds=p and p:FindFirstChild("DataStore"); local s=ds and ds:FindFirstChild("Skins"); local out={}; if s then for _,x in ipairs(s:GetChildren()) do table.insert(out,x.Name) end end; safeNotify("Skins",#out>0 and table.concat(out,"\n") or "No skins found.")
end})
Utilities:CreateButton({Name="List Player Marshmallows",Callback=function()
    local p=Players:FindFirstChild(inspect); local ds=p and p:FindFirstChild("DataStore"); local s=ds and ds:FindFirstChild("Marshmallows"); local out={}; if s then for _,x in ipairs(s:GetChildren()) do table.insert(out,x.Name) end end; safeNotify("Marshmallows",#out>0 and table.concat(out,"\n") or "No marshmallows found.")
end})
Utilities:CreateButton({Name="View Confessional",Callback=function()
    local p=Players:FindFirstChild(inspect); local ds=p and p:FindFirstChild("DataStore"); local c=ds and ds:FindFirstChild("Confessional"); safeNotify("Confessional",c and tostring(c.Value) or "No confessional found.")
end})
Utilities:CreateSection("Server")
Utilities:CreateButton({Name="Rejoin Server",Callback=function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end})
Utilities:CreateButton({Name="Server Hop",Callback=function()
    local ok,data=pcall(function() return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and data and data.data then for _,sv in ipairs(data.data) do if sv.id~=game.JobId and sv.playing<sv.maxPlayers then TeleportService:TeleportToPlaceInstance(game.PlaceId,sv.id,player); break end end end
end})
Utilities:CreateButton({Name="Copy Job ID",Callback=function() if setclipboard then setclipboard(game.JobId) end end})

--========================================================--
-- CHARACTERS
--========================================================--

Characters:CreateSection("Free")
Characters:CreateButton({Name="Male Character",Callback=function()
    local e=ReplicatedStorage:FindFirstChild("Events"); local b=e and e:FindFirstChild("Buy")
    if b then b:FireServer("Gender","Male") end
end})
Characters:CreateButton({Name="Female Character",Callback=function()
    local e=ReplicatedStorage:FindFirstChild("Events"); local b=e and e:FindFirstChild("Buy")
    if b then b:FireServer("Gender","Female") end
end})
Characters:CreateSection("Paid")
Characters:CreateButton({Name="Crash Server",Callback=function() safeNotify("Crash Server","Disabled in this build.") end})

local selectedSymbol=""
local characterName=""
local symbolMap={None="",[" Verified"]="\u{e000}",[" Premium"]="\u{e001}",[" Robux"]="\u{e002}"}
Characters:CreateDropdown({Name="Select Symbol for Character",Options={"None"," Verified"," Premium"," Robux"},CurrentOption={"None"},MultipleOptions=false,Callback=function(v)
    local x=type(v)=="table" and v[1] or v; selectedSymbol=symbolMap[x] or ""
end})
Characters:CreateButton({Name="Buy Symbol for Character (@60)",Callback=function()
    local e=ReplicatedStorage:FindFirstChild("Events"); local b=e and e:FindFirstChild("Buy")
    if b and selectedSymbol~="" then b:FireServer("Character",selectedSymbol) end
end})
Characters:CreateInput({Name="Character Name",PlaceholderText="Enter character name...",CurrentValue="",Numeric=false,Callback=function(v) characterName=v; S.customName=v end})
Characters:CreateButton({Name="Buy Character (@60)",Callback=function()
    if characterName=="" then return end
    local final=characterName..(selectedSymbol~="" and (" "..selectedSymbol) or "")
    local e=ReplicatedStorage:FindFirstChild("Events"); local b=e and e:FindFirstChild("Buy")
    if b then b:FireServer("Character",final) end
end})

-- Source-derived client skin inventory
local skinMap={}; local skinFaceMap={}; local skinList={}
local skinRoot=ReplicatedStorage:FindFirstChild("Products") and ReplicatedStorage.Products:FindFirstChild("CharacterSelection") and ReplicatedStorage.Products.CharacterSelection:FindFirstChild("Characters")
if skinRoot then
    for _,gender in ipairs(skinRoot:GetChildren()) do
        for _,character in ipairs(gender:GetChildren()) do
            local skins=character:FindFirstChild("Skins")
            if skins then
                for _,skin in ipairs(skins:GetChildren()) do
                    local label=gender.Name.." | "..character.Name.." | "..skin.Name
                    table.insert(skinList,label); skinMap[label]=skin
                    local fd=skin:FindFirstChildOfClass("Decal") or character:FindFirstChildOfClass("Decal")
                    skinFaceMap[label]=fd and fd.Texture or ""
                end
            end
        end
    end
end
table.sort(skinList)
local function findAttachment(c,name)
    for _,x in ipairs(c:GetDescendants()) do if x:IsA("Attachment") and x.Name==name then return x end end
end
local function applySkin(skinObj,faceTexture)
    local c=char(); if not c then return end
    for _,x in ipairs(c:GetChildren()) do
        if x:IsA("Shirt") or x:IsA("Pants") or x:IsA("Accessory") or x:IsA("ShirtGraphic") or x:IsA("CharacterMesh") or x:IsA("Hat") then x:Destroy() end
    end
    local head=c:FindFirstChild("Head")
    if head and faceTexture~="" then
        local d=head:FindFirstChildOfClass("Decal") or Instance.new("Decal")
        d.Name="face"; d.Face=Enum.NormalId.Front; d.Texture=faceTexture; d.Parent=head
    end
    local clothes=skinObj:FindFirstChild("Clothes"); if not clothes then return end
    local shirt=clothes:FindFirstChildOfClass("Shirt"); if shirt then shirt:Clone().Parent=c end
    local pants=clothes:FindFirstChildOfClass("Pants"); if pants then pants:Clone().Parent=c end
    local bc=clothes:FindFirstChildOfClass("BodyColors"); if bc then local old=c:FindFirstChildOfClass("BodyColors"); if old then old:Destroy() end; bc:Clone().Parent=c end
    for _,x in ipairs(clothes:GetChildren()) do
        if x:IsA("CharacterMesh") then x:Clone().Parent=c end
        if x:IsA("Accessory") or x:IsA("Hat") then
            local clone=x:Clone(); local handle=clone:FindFirstChild("Handle")
            if handle then
                handle.Massless=true
                local ha=handle:FindFirstChildOfClass("Attachment")
                if ha then
                    local ca=findAttachment(c,ha.Name)
                    if ca then local rc=Instance.new("RigidConstraint"); rc.Attachment0=ca; rc.Attachment1=ha; rc.Parent=clone end
                end
            end
            clone.Parent=c
        end
    end
end

local marshmallowData={
    ["Marshmallow"]="http://www.roblox.com/asset/?id=4921967564",
    ["Mr.Coconut Marshmallow"]="http://www.roblox.com/asset/?id=4993225404",
    ["Cook Surprise Marshmallow"]="http://www.roblox.com/asset/?id=4993211976",
    ["Soda Marshmallow"]="http://www.roblox.com/asset/?id=13424792834",
    ["Dino Marshmallow"]="http://www.roblox.com/asset/?id=13424788699",
    ["Official 3-4 Marshmallow"]="http://www.roblox.com/asset/?id=9005433388",
    ["Furious Trout Marshmallow"]="http://www.roblox.com/asset/?id=13557360275",
    ["Orange Marshmallow"]="http://www.roblox.com/asset/?id=4993231360",
    ["Cabbage Marshmallow"]="http://www.roblox.com/asset/?id=13424785412",
    ["Toxic Marshmallow"]="http://www.roblox.com/asset/?id=4939073413",
    ["Grip Marshmallow"]="http://www.roblox.com/asset/?id=14253207872",
    ["Vote Me Marshmallow"]="http://www.roblox.com/asset/?id=13424797492",
    ["Honey Dipped Marshmallow"]="http://www.roblox.com/asset/?id=13424799638",
    ["Banana Marshmallow"]="http://www.roblox.com/asset/?id=4922748526",
    ["Cursed Idol Marshmallow"]="http://www.roblox.com/asset/?id=4993221853",
    ["Choc Dipped Marshmallow"]="http://www.roblox.com/asset/?id=10420319581",
    ["Candyfloss Marshmallow"]="http://www.roblox.com/asset/?id=4939071806",
    ["Guilty Gift Marshmallow"]="http://www.roblox.com/asset/?id=13424790186",
    ["Coconut Marshmallow"]="http://www.roblox.com/asset/?id=4922749819",
    ["Official Marshmallow"]="http://www.roblox.com/asset/?id=6190482040",
    ["Chocolate Marshmallow"]="http://www.roblox.com/asset/?id=8989965765",
    ["Toasted Marshmallow"]="http://www.roblox.com/asset/?id=11109548044",
    ["Surfboard Marshmallow"]="http://www.roblox.com/asset/?id=14253216830",
    ["Official 2 Marshmallow"]="http://www.roblox.com/asset/?id=6918605850",
    ["Stink Bomb Marshmallow"]="http://www.roblox.com/asset/?id=14253212538",
    ["Deathly Frog Marshmallow"]="http://www.roblox.com/asset/?id=13557357445",
    ["Heart Marshmallow"]="http://www.roblox.com/asset/?id=11109545563",
    ["Burnt Marshmallow"]="http://www.roblox.com/asset/?id=4939257688",
    ["Spooky Skull Marshmallow"]="http://www.roblox.com/asset/?id=13424794215",
    ["Camo Marshmallow"]="http://www.roblox.com/asset/?id=4993218908",
    ["Star Barrel Marshmallow"]="http://www.roblox.com/asset/?id=13557362587",
    ["Candycane Marshmallow"]="http://www.roblox.com/asset/?id=8087099712",
    ["Claus Marshmallow"]="http://www.roblox.com/asset/?id=8087103731",
    ["Gingerbread Marshmallow"]="http://www.roblox.com/asset/?id=8087104305",
    ["Snowflake Marshmallow"]="http://www.roblox.com/asset/?id=8087108522",
    ["Snowman Marshmallow"]="http://www.roblox.com/asset/?id=8087109234",
    ["Xmas Tree Marshmallow"]="http://www.roblox.com/asset/?id=8087102391",
    ["Official 5 Marshmallow"]="http://www.roblox.com/asset/?id=12089683577",
    ["Refresher Marshmallow"]="http://www.roblox.com/asset/?id=10420322407",
    ["Friendly Fish Marshmallow"]="http://www.roblox.com/asset/?id=6213300124",
    ["Popcorn Marshmallow"]="http://www.roblox.com/asset/?id=14253210682",
    ["Salt&Pepper Marshmallow"]="http://www.roblox.com/asset/?id=4939073043",
    ["Grape Marshmallow"]="http://www.roblox.com/asset/?id=4939072171",
    ["Mutant Marshmallow"]="http://www.roblox.com/asset/?id=4993228141",
    ["Blue Sky Marshmallow"]="http://www.roblox.com/asset/?id=6213301823",
    ["Rainbow Marshmallow"]="http://www.roblox.com/asset/?id=11109546611",
    ["Animatronic Marshmallow"]="http://www.roblox.com/asset/?id=14253197608",
    ["Fly Trap Marshmallow"]="http://www.roblox.com/asset/?id=13557358447",
    ["Lightning Marshmallow"]="http://www.roblox.com/asset/?id=6213299603",
    ["Official 6 Marshmallow"]="http://www.roblox.com/asset/?id=13883154348",
    ["Cave Marshmallow"]="http://www.roblox.com/asset/?id=14253202968",
    ["Briefcase Marshmallow"]="http://www.roblox.com/asset/?id=14253200770",
    ["Alien Slime Marshmallow"]="http://www.roblox.com/asset/?id=14253195386",
    ["Strawberry Marshmallow"]="http://www.roblox.com/asset/?id=8989965284",
    ["Gaffer Marshmallow"]="http://www.roblox.com/asset/?id=14253205269",
    ["Bane Marshmallow"]="http://www.roblox.com/asset/?id=4939072726",
    ["All Star Marshmallow"]="http://www.roblox.com/asset/?id=4993216167",
    ["Voting Machine Marshmallow"]="http://www.roblox.com/asset/?id=14253219599",
    ["Mint Choc Chip Marshmallow"]="http://www.roblox.com/asset/?id=10420505533",
    ["Dropped Marshmallow"]="http://www.roblox.com/asset/?id=6213298209",
    ["Spiderweb Marshmallow"]="http://www.roblox.com/asset/?id=14891850347",
    ["Mummy Marshmallow"]="http://www.roblox.com/asset/?id=14891849082",
    ["Jack-o-lantern Marshmallow"]="http://www.roblox.com/asset/?id=14891848232",
    ["Cauldron Marshmallow"]="http://www.roblox.com/asset/?id=14891845147",
    ["Ghost Marshmallow"]="http://www.roblox.com/asset/?id=14891847267",
    ["Candy Corn Marshmallow"]="http://www.roblox.com/asset/?id=14891843386",
    ["Black Cat Marshmallow"]="http://www.roblox.com/asset/?id=14891842127",
    ["Frankenstein Marshmallow"]="http://www.roblox.com/asset/?id=14891846020",
    ["Candy Cane Marshmallow"]="http://www.roblox.com/asset/?id=15484725814",
    ["Christmas Gift Marshmallow"]="http://www.roblox.com/asset/?id=15484726913",
    ["Christmas Tree Marshmallow"]="http://www.roblox.com/asset/?id=15484727551",
    ["Festive Lights Marshmallow"]="http://www.roblox.com/asset/?id=15484728253",
    ["Frosted Marshmallow"]="http://www.roblox.com/asset/?id=15484728905",
    ["Hot Chocolate Marshmallow"]="http://www.roblox.com/asset/?id=15484729538",
    ["Jingle Bell Marshmallow"]="http://www.roblox.com/asset/?id=15484730291",
    ["Mr Snow Marshmallow"]="http://www.roblox.com/asset/?id=15484731148",
    ["Reindeer Marshmallow"]="http://www.roblox.com/asset/?id=15484731823",
    ["Santa Suit Marshmallow"]="http://www.roblox.com/asset/?id=15484732509",
    ["Snowglobe Marshmallow"]="http://www.roblox.com/asset/?id=15484733560",
    ["The Grunch Marshmallow"]="http://www.roblox.com/asset/?id=15484734379",
    ["Bacon Grease Marshmallow"]="http://www.roblox.com/asset/?id=16029143731",
    ["Pink Paint Marshmallow"]="http://www.roblox.com/asset/?id=16029151877",
    ["Skunk Tail Marshmallow"]="http://www.roblox.com/asset/?id=16029163767",
    ["Rodent Face Marshmallow"]="http://www.roblox.com/asset/?id=16029162747",
    ["Candy Marshmallow"]="http://www.roblox.com/asset/?id=16029146948",
    ["Lychee Soda Marshmallow"]="http://www.roblox.com/asset/?id=16029149121",
    ["Banana Soda Marshmallow"]="http://www.roblox.com/asset/?id=16029144639",
    ["The Wolves Marshmallow"]="http://www.roblox.com/asset/?id=16029164794",
    ["Young Chester Marshmallow"]="http://www.roblox.com/asset/?id=16029185414",
    ["Owl Mascot Marshmallow"]="http://www.roblox.com/asset/?id=16029150192",
    ["Racoon Marshmallow"]="http://www.roblox.com/asset/?id=16029160256",
    ["Abstract Cake Marshmallow"]="http://www.roblox.com/asset/?id=16029142769",
    ["Circus Snake Marshmallow"]="http://www.roblox.com/asset/?id=16029148014",
    ["Bogey Marshmallow"]="http://www.roblox.com/asset/?id=16029145643",
    ["Sap Removal Marshmallow"]="http://www.roblox.com/asset/?id=16029165998",
    ["Carrot Marshmallow"]="http://www.roblox.com/asset/?id=16735788642",
    ["Easter Basket Marshmallow"]="http://www.roblox.com/asset/?id=16735790050",
    ["Easter Bunny Marshmallow"]="http://www.roblox.com/asset/?id=16726342799",
    ["Easter Chick Marshmallow"]="http://www.roblox.com/asset/?id=16735787584",
    ["Easter Egg Marshmallow"]="http://www.roblox.com/asset/?id=16735791814",
    ["Lion Marshmallow"]="http://www.roblox.com/asset/?id=16726346946",
    ["Official 7 Marshmallow"]="http://www.roblox.com/asset/?id=16752097514",
}
local marshList={}; for n in pairs(marshmallowData) do table.insert(marshList,n) end; table.sort(marshList)
local function applyMarshmallow(tex)
    local c=char(); local h=c and c:FindFirstChild("Head"); local g=h and h:FindFirstChild("MarshmallowGUI"); local sec=g and g:FindFirstChild("Sector"); local img=sec and sec:FindFirstChildOfClass("ImageLabel")
    if img then img.Image=tex end
end

Characters:CreateSection("Skin Modifier (Client)")
local skinOptions={"None"}; for _,x in ipairs(skinList) do table.insert(skinOptions,x) end
Characters:CreateDropdown({Name="Skin Modifier",Options=skinOptions,CurrentOption={"None"},MultipleOptions=false,Callback=function(v)
    local label=type(v)=="table" and v[1] or v; local sk=skinMap[label]; if sk then applySkin(sk,skinFaceMap[label]); safeNotify("Skin Applied",sk.Name) end
end})
Characters:CreateDropdown({Name="Elimination Modifier",Options={"None","Sleigh Elimination"},CurrentOption={"None"},MultipleOptions=false,Callback=function(v)
    local x=type(v)=="table" and v[1] or v
    if x=="Sleigh Elimination" then
        local elim=workspace:FindFirstChild("ElimMethod"); local products=ReplicatedStorage:FindFirstChild("Products")
        local camp=products and products:FindFirstChild("ElimMethods") and products.ElimMethods:FindFirstChild("Camp")
        local template=camp and camp:FindFirstChild("Sleigh Elimination")
        if elim and template then for _,q in ipairs(elim:GetChildren()) do q:Destroy() end; template:Clone().Parent=elim end
    end
end})
Characters:CreateDropdown({Name="Marshmallow Modifier",Options=(#marshList>0 and marshList or {"None"}),CurrentOption={(marshList[1] or "None")},MultipleOptions=false,Callback=function(v)
    local x=type(v)=="table" and v[1] or v; if marshmallowData[x] then applyMarshmallow(marshmallowData[x]) end
end})
Characters:CreateButton({Name="Get All Skins (Marsh, Skins, Client)",Callback=function()
    local ds=player:FindFirstChild("DataStore"); local shop=ReplicatedStorage:FindFirstChild("Products") and ReplicatedStorage.Products:FindFirstChild("Shop") and ReplicatedStorage.Products.Shop:FindFirstChild("Items")
    if ds and shop then
        for _,cat in ipairs(shop:GetChildren()) do
            local dst=ds:FindFirstChild(cat.Name)
            if dst then for _,x in ipairs(dst:GetChildren()) do x:Destroy() end; for _,x in ipairs(cat:GetChildren()) do x:Clone().Parent=dst end end
        end
        safeNotify("Inventory","Shop items copied into the local DataStore.")
    end
end})
Characters:CreateSection("Custom Skin Creator")
local customShirt="None"; local customPants="None"; local customAcc="None"
local shirtOptions={"None"}; local pantsOptions={"None"}; local accOptions={"None"}
local shirtMap={}; local pantsMap={}; local accMap={}
for label,sk in pairs(skinMap) do
    local clothes=sk:FindFirstChild("Clothes")
    if clothes then
        local sh=clothes:FindFirstChildOfClass("Shirt"); if sh and sh.ShirtTemplate~="" then local l=sk.Name.." (shirt)"; if not shirtMap[l] then shirtMap[l]=sh; table.insert(shirtOptions,l) end end
        local pa=clothes:FindFirstChildOfClass("Pants"); if pa and pa.PantsTemplate~="" then local l=sk.Name.." (pants)"; if not pantsMap[l] then pantsMap[l]=pa; table.insert(pantsOptions,l) end end
        for _,a in ipairs(clothes:GetChildren()) do if a:IsA("Accessory") or a:IsA("Hat") then local l=sk.Name.." - "..a.Name; if not accMap[l] then accMap[l]=a; table.insert(accOptions,l) end end end
    end
end
table.sort(shirtOptions); table.sort(pantsOptions); table.sort(accOptions)
Characters:CreateDropdown({Name="Shirts",Options=shirtOptions,CurrentOption={"None"},MultipleOptions=false,Callback=function(v) customShirt=type(v)=="table" and v[1] or v end})
Characters:CreateDropdown({Name="Pants",Options=pantsOptions,CurrentOption={"None"},MultipleOptions=false,Callback=function(v) customPants=type(v)=="table" and v[1] or v end})
Characters:CreateDropdown({Name="Accessories",Options=accOptions,CurrentOption={"None"},MultipleOptions=false,Callback=function(v) customAcc=type(v)=="table" and v[1] or v end})
Characters:CreateButton({Name="Load a Skin",Callback=function()
    local c=char(); if not c then return end
    if customShirt~="None" and shirtMap[customShirt] then for _,x in ipairs(c:GetChildren()) do if x:IsA("Shirt") then x:Destroy() end end; shirtMap[customShirt]:Clone().Parent=c end
    if customPants~="None" and pantsMap[customPants] then for _,x in ipairs(c:GetChildren()) do if x:IsA("Pants") then x:Destroy() end end; pantsMap[customPants]:Clone().Parent=c end
    if customAcc~="None" and accMap[customAcc] then local a=accMap[customAcc]:Clone(); a.Parent=c end
end})
local selectedSavedSkin = "None"
local function skinFolder()
    return "HeavelyHub/CustomSkins"
end
local function savedSkinNames()
    local out={"None"}
    if isfolder and listfiles then
        pcall(function()
            if not isfolder("HeavelyHub") then makefolder("HeavelyHub") end
            if not isfolder(skinFolder()) then makefolder(skinFolder()) end
            for _,path in ipairs(listfiles(skinFolder())) do
                local n=tostring(path):match("([^/\\]+)%.json$")
                if n and n~="" then table.insert(out,n) end
            end
        end)
    end
    table.sort(out)
    return out
end
local savedDropdown
local function saveCurrentSkin(name)
    if not writefile or not makefolder then return false,"File APIs unavailable" end
    local c=char(); if not c then return false,"Character unavailable" end
    pcall(function() if not isfolder("HeavelyHub") then makefolder("HeavelyHub") end end)
    pcall(function() if not isfolder(skinFolder()) then makefolder(skinFolder()) end end)
    local d={face="",shirt="",pants="",accessories={}}
    local h=c:FindFirstChild("Head"); local face=h and h:FindFirstChildOfClass("Decal"); if face then d.face=face.Texture end
    local sh=c:FindFirstChildOfClass("Shirt"); if sh then d.shirt=sh.ShirtTemplate end
    local pa=c:FindFirstChildOfClass("Pants"); if pa then d.pants=pa.PantsTemplate end
    for _,x in ipairs(c:GetChildren()) do if x:IsA("Accessory") or x:IsA("Hat") then table.insert(d.accessories,x.Name) end end
    local ok,err=pcall(function() writefile(skinFolder().."/"..name..".json",HttpService:JSONEncode(d)) end)
    return ok,err
end
local function loadSavedSkin(name)
    if not readfile then return false,"File APIs unavailable" end
    local ok,src=pcall(readfile,skinFolder().."/"..name..".json"); if not ok then return false,"Skin not found" end
    local ok2,d=pcall(function() return HttpService:JSONDecode(src) end); if not ok2 or not d then return false,"Invalid skin file" end
    local c=char(); if not c then return false,"Character unavailable" end
    for _,x in ipairs(c:GetChildren()) do if x:IsA("Shirt") or x:IsA("Pants") or x:IsA("Accessory") or x:IsA("Hat") then x:Destroy() end end
    local h=c:FindFirstChild("Head"); if h and d.face and d.face~="" then local f=h:FindFirstChildOfClass("Decal") or Instance.new("Decal"); f.Name="face"; f.Face=Enum.NormalId.Front; f.Texture=d.face; f.Parent=h end
    if d.shirt and d.shirt~="" then local sh=Instance.new("Shirt"); sh.ShirtTemplate=d.shirt; sh.Parent=c end
    if d.pants and d.pants~="" then local pa=Instance.new("Pants"); pa.PantsTemplate=d.pants; pa.Parent=c end
    for _,accName in ipairs(d.accessories or {}) do
        for _,sk in pairs(skinMap) do
            local cl=sk:FindFirstChild("Clothes"); local acc=cl and cl:FindFirstChild(accName)
            if acc and (acc:IsA("Accessory") or acc:IsA("Hat")) then
                local clone=acc:Clone(); clone.Parent=c; break
            end
        end
    end
    return true
end
Characters:CreateInput({Name="Save Custom Skin (press Enter to save)",PlaceholderText="Enter save name...",CurrentValue="",Numeric=false,Callback=function(v)
    local n=tostring(v or ""):match("^%s*(.-)%s*$"); if n=="" then return end
    local ok,err=saveCurrentSkin(n); if ok then safeNotify("Skin Saved",n); if savedDropdown then pcall(function() savedDropdown:Refresh(savedSkinNames()) end) end else safeNotify("Save Failed",tostring(err)) end
end})
savedDropdown=Characters:CreateDropdown({Name="Load Custom Skin",Options=savedSkinNames(),CurrentOption={"None"},MultipleOptions=false,Callback=function(v)
    selectedSavedSkin=type(v)=="table" and v[1] or v; if selectedSavedSkin and selectedSavedSkin~="None" then local ok,err=loadSavedSkin(selectedSavedSkin); if ok then safeNotify("Skin Loaded",selectedSavedSkin) else safeNotify("Load Failed",tostring(err)) end end
end})
Characters:CreateButton({Name="Delete Selected Skin",Callback=function()
    if selectedSavedSkin=="None" or not delfile then return end
    local ok=pcall(function() delfile(skinFolder().."/"..selectedSavedSkin..".json") end)
    if ok then safeNotify("Skin Deleted",selectedSavedSkin); selectedSavedSkin="None"; if savedDropdown then pcall(function() savedDropdown:Refresh(savedSkinNames()) end) end end
end})

Client:CreateSection("Equipment")
local gearOptions={"Sword","Dodgeball","PaintballGun","Meatball","Snowball","Pool Noodle","Sheriff","Key"}
local function equipGear(toolName)
    local c=char(); if not c then return end
    local tools=ReplicatedStorage:FindFirstChild("Tools") or ReplicatedStorage:FindFirstChild("Tool")
    local src=tools and tools:FindFirstChild(toolName,true)
    if src and src:IsA("Tool") then
        for _,x in ipairs(c:GetChildren()) do if x:IsA("Tool") and x.Name==toolName then x:Destroy() end end
        src:Clone().Parent=c
        safeNotify("Gear",toolName.." equipped locally")
    else
        safeNotify("Gear",toolName.." was not found in the current Camp assets")
    end
end
Client:CreateDropdown({Name="Equipment Locker",Options=gearOptions,CurrentOption={gearOptions[1]},MultipleOptions=false,Callback=function(v) local x=type(v)=="table" and v[1] or v; if x then equipGear(x) end end})
Client:CreateButton({Name="Player Collision",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character then
            for _,part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide=true end
            end
        end
    end
end})

Client:CreateSection("Nameplate")
Client:CreateInput({Name="Custom Name",PlaceholderText="Enter display name...",CurrentValue="",Numeric=false,Callback=function(v) S.customName=v end})
Client:CreateToggle({Name="VIP Nameplate",CurrentValue=false,Callback=function(v)
    local c=char(); local h=c and c:FindFirstChild("Head"); local pn=h and h:FindFirstChild("playerName"); local vip=pn and pn:FindFirstChild("VIP"); if vip then vip.Visible=v end
end})
Client:CreateToggle({Name="Rainbow Name",CurrentValue=false,Callback=function(v) S.rainbowName=v end})
Client:CreateSlider({Name="Rainbow Speed",Range={0,5},Increment=.1,CurrentValue=.5,Callback=function(v) S.rainbowSpeed=v end})
Client:CreateColorPicker({Name="Name Color",Color=Color3.fromRGB(255,182,193),Callback=function(v) S.nameColor=v end})
Client:CreateToggle({Name="Show All Usernames",CurrentValue=false,Callback=function(v)
    for _,p in ipairs(Players:GetPlayers()) do
        local c=p.Character; local h=c and c:FindFirstChild("Head"); local old=h and h:FindFirstChild("UsernameTag")
        if old then old:Destroy() end
        if v and h then
            local bb=Instance.new("BillboardGui"); bb.Name="UsernameTag"; bb.Adornee=h; bb.Size=UDim2.new(0,120,0,20); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=h
            local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=p.Name; t.TextScaled=true; t.Font=Enum.Font.GothamMedium; t.TextColor3=Color3.new(1,1,1); t.TextStrokeTransparency=.5; t.Parent=bb
        end
    end
end})
Client:CreateButton({Name="Fake #1 Leaderboard",Callback=function()
    local board=workspace:FindFirstChild("WinLeaderboard")
    local sf=board and board:FindFirstChildWhichIsA("SurfaceGui",true)
    local scroll=sf and sf:FindFirstChild("ScrollingFrame",true)
    if not scroll then safeNotify("Leaderboard","Camp leaderboard not found") return end
    for _,frame in ipairs(scroll:GetChildren()) do
        local place=frame:FindFirstChild("Place",true); local pn=frame:FindFirstChild("PName",true)
        if place and pn and tostring(place.Text)=="1" then pn.Text=player.Name; safeNotify("Leaderboard","Client-side preview updated"); return end
    end
end})
Client:CreateButton({Name="Print Skins",Callback=function() print("[Heavely Hub] Camp skins:",table.concat(skinList," | ")) end})
Client:CreateButton({Name="Print Marshmallows",Callback=function() print("[Heavely Hub] Camp marshmallows:",table.concat(marshList," | ")) end})

Client:CreateSection("Fonts")
Client:CreateButton({Name="Starborn Typeface",Callback=function()
    if not (writefile and isfile and getcustomasset and Font) then safeNotify("Font","Custom font APIs unavailable") return end
    local ok=pcall(function()
        local t="HeavelyHub_Starborn.ttf"; local j="HeavelyHub_Starborn.json"; local url="https://drive.google.com/uc?export=download&id=1k9H8G60p7iaJL4hHcyWEXgWJbONqam8_"
        if not isfile(t) then writefile(t,game:HttpGet(url)) end
        writefile(j,HttpService:JSONEncode({name="Starborn",faces={{name="Regular",weight=400,style="normal",assetId=getcustomasset(t)}}}))
        local ff=Font.new(getcustomasset(j)); for _,d in ipairs(game:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then pcall(function() d.FontFace=ff end) end end
    end); safeNotify("Font",ok and "Starborn applied" or "Failed to apply Starborn")
end})
Client:CreateButton({Name="Minecraft Typeface",Callback=function()
    if not (writefile and isfile and getcustomasset and Font) then safeNotify("Font","Custom font APIs unavailable") return end
    local ok=pcall(function()
        local t="HeavelyHub_Minecrafter.ttf"; local j="HeavelyHub_Minecrafter.json"; local url="https://drive.google.com/uc?export=download&id=1_LSZQUGrKHzJctxK7Jp8rVRRVWIvdif4"
        if not isfile(t) then writefile(t,game:HttpGet(url)) end
        writefile(j,HttpService:JSONEncode({name="Minecrafter",faces={{name="Regular",weight=400,style="normal",assetId=getcustomasset(t)}}}))
        local ff=Font.new(getcustomasset(j)); for _,d in ipairs(game:GetDescendants()) do if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then pcall(function() d.FontFace=ff end) end end
    end); safeNotify("Font",ok and "Minecraft applied" or "Failed to apply Minecraft")
end})
Client:CreateSection("Leaderboard")
Client:CreateButton({Name="Preview Leaderboard",Callback=function() safeNotify("Leaderboard","Leaderboard preview is client-side only.") end})
Client:CreateSection("Camp Stats")
Client:CreateInput({Name="Custom Coins",PlaceholderText="Numbers only...",CurrentValue="",Numeric=true,Callback=function(v) local d=player:FindFirstChild("DataStore"); local x=d and d:FindFirstChild("Coins"); if x then pcall(function() x.Value=tonumber(v) or x.Value end) end end})
Client:CreateInput({Name="Custom Camp Wins",PlaceholderText="Numbers only...",CurrentValue="",Numeric=true,Callback=function(v) local d=player:FindFirstChild("DataStore"); local x=d and d:FindFirstChild("CampWins"); if x then pcall(function() x.Value=tonumber(v) or x.Value end) end end})
Client:CreateSection("Camp Environment")
Client:CreateButton({Name="Halloween Environment",Callback=function() loadstring(game:HttpGet("https://pastebin.com/raw/nVKRChaK"))() end})
Client:CreateButton({Name="Christmas Environment",Callback=function() loadstring(game:HttpGet("https://pastebin.com/raw/ju6mhwzn"))() end})
Client:CreateButton({Name="Valentine Environment",Callback=function()
    local winterColor=Color3.fromRGB(255,152,220); local greenColor=Color3.fromRGB(148,190,129)
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then local n=obj.BrickColor.Name:lower(); if n=="olivine" or n:find("green") then obj.Color=greenColor; obj.Material=Enum.Material.SmoothPlastic end end
        if obj:IsA("MeshPart") and obj.Name=="Leaves" then obj.Color=winterColor; obj.Material=Enum.Material.SmoothPlastic end
    end
end})
Client:CreateSection("Marshmallow")
Client:CreateToggle({Name="Rainbow Marshmallow",CurrentValue=false,Callback=function(v) S.rainbowMarsh=v end})

Setting:CreateSection("Interface")
Setting:CreateLabel({Text="Heavely Hub (Camp) • V1"})
Setting:CreateLabel({Text="Camp-only logic integration"})
Setting:CreateSection("Configuration")
local cfgName="None"; local cfgFolder="HeavelyHub/Configs"; local cfgDrop
local function cfgList() local out={"None"}; if isfolder and listfiles then pcall(function() if not isfolder("HeavelyHub") then makefolder("HeavelyHub") end; if not isfolder(cfgFolder) then makefolder(cfgFolder) end; for _,path in ipairs(listfiles(cfgFolder)) do local n=tostring(path):match("([^/\\]+)%.json$"); if n then table.insert(out,n) end end end) end; table.sort(out); return out end
local function cfgData() return HttpService:JSONEncode({walkSpeed=S.walkSpeed,jumpPower=S.jumpPower,fov=S.fov,mathDelay=S.mathDelay,rainbowSpeed=S.rainbowSpeed,customName=S.customName,rainbowName=S.rainbowName,rainbowMarsh=S.rainbowMarsh}) end
local function applyCfg(d) if d.walkSpeed then S.walkSpeed=d.walkSpeed end; if d.jumpPower then S.jumpPower=d.jumpPower end; if d.fov then S.fov=d.fov end; if d.mathDelay then S.mathDelay=d.mathDelay end; if d.rainbowSpeed then S.rainbowSpeed=d.rainbowSpeed end; if d.customName then S.customName=d.customName end; if d.rainbowName~=nil then S.rainbowName=d.rainbowName end; if d.rainbowMarsh~=nil then S.rainbowMarsh=d.rainbowMarsh end; local h=hum(); if h then h.WalkSpeed=S.walkSpeed; h.JumpPower=S.jumpPower end; if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=S.fov end end
cfgDrop=Setting:CreateDropdown({Name="Load Configuration",Options=cfgList(),CurrentOption={"None"},MultipleOptions=false,Callback=function(v) local n=type(v)=="table" and v[1] or v; cfgName=n or "None"; if cfgName=="None" or not readfile then return end; local ok,src=pcall(readfile,cfgFolder.."/"..cfgName..".json"); if ok then local ok2,d=pcall(function() return HttpService:JSONDecode(src) end); if ok2 then applyCfg(d); safeNotify("Configuration","Loaded "..cfgName) end end end})
Setting:CreateInput({Name="Save Configuration",PlaceholderText="Configuration name...",CurrentValue="",Numeric=false,Callback=function(v) local n=tostring(v or ""):match("^%s*(.-)%s*$"); if n=="" or not writefile then return end; pcall(function() if not isfolder("HeavelyHub") then makefolder("HeavelyHub") end; if not isfolder(cfgFolder) then makefolder(cfgFolder) end; writefile(cfgFolder.."/"..n..".json",cfgData()) end); if cfgDrop then pcall(function() cfgDrop:Refresh(cfgList()) end) end; safeNotify("Configuration","Saved "..n) end})
Setting:CreateButton({Name="Delete Selected Configuration",Callback=function() if cfgName=="None" or not delfile then return end; local ok=pcall(function() delfile(cfgFolder.."/"..cfgName..".json") end); if ok then cfgName="None"; if cfgDrop then pcall(function() cfgDrop:Refresh(cfgList()) end) end; safeNotify("Configuration","Deleted configuration") end end})
Setting:CreateButton({Name="Reset Interface",Callback=function() S.walkSpeed=16; S.jumpPower=50; S.fov=70; S.mathDelay=0; S.rainbowSpeed=.5; S.customName=""; S.rainbowName=false; S.rainbowMarsh=false; local h=hum(); if h then h.WalkSpeed=16; h.JumpPower=50 end; if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=70 end; safeNotify("Interface","Reset complete") end})
Setting:CreateSection("About")
Setting:CreateLabel({Text="Heavely Hub • Total Roblox Drama"})
Setting:CreateLabel({Text="Camp-only build • No Autoplay"})
Setting:CreateLabel({Text="Creds to ChatGPT ♥️"})
Setting:CreateLabel({Text="V1.0"})

--========================================================--
-- RUNTIME
--========================================================--

CONN.aim=RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target=nearestTarget()
        local r=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local cam=workspace.CurrentCamera
        if r and cam then
            local alpha=math.clamp(aimSmooth/100,0.01,1)
            local desired=CFrame.new(cam.CFrame.Position,r.Position)
            cam.CFrame=cam.CFrame:Lerp(desired,alpha)
        end
    end
    if hitboxEnabled then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    originalSizes[r]=originalSizes[r] or r.Size
                    r.Size=Vector3.new(2+hitboxSize*2,2+hitboxSize*2,1+hitboxSize*2)
                    r.Transparency=math.clamp(hitboxSize/10,0,.5)
                end
            end
        end
    end
end)


CONN.char=player.CharacterAdded:Connect(function(c)
    task.wait(.5)
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=S.walkSpeed; h.JumpPower=S.jumpPower end
end)

CONN.name=RunService.RenderStepped:Connect(function()
    local c=char(); if not c then return end
    for _,x in ipairs(c:GetDescendants()) do
        if x:IsA("TextLabel") or x:IsA("TextButton") then
            if S.customName~="" then x.Text=S.customName end
            if S.rainbowName then x.TextColor3=Color3.fromHSV((tick()*S.rainbowSpeed)%1,.6,1) end
        end
    end
end)

CONN.playerAdded=Players.PlayerAdded:Connect(function(p)
    CONN[p.UserId]=p.CharacterAdded:Connect(function(c)
        task.wait(.25)
        if S.playerESP and p~=player then
            local h=c:FindFirstChild("HeavelyPlayerESP") or Instance.new("Highlight")
            h.Name="HeavelyPlayerESP"; h.FillTransparency=.65; h.Parent=c; ESP[p]=h
        end
        if S.targetHighlight and S.target==p.Name then
            local h=c:FindFirstChild("HeavelyTargetHighlight") or Instance.new("Highlight")
            h.Name="HeavelyTargetHighlight"; h.FillColor=Color3.fromRGB(255,221,0); h.OutlineColor=Color3.fromRGB(255,221,0); h.Parent=c
        end
    end)
end)

print("[Heavely Hub] Camp build loaded — no Autoplay features included.")
