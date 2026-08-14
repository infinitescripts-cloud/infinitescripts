-- =========================================================================
--               MM2 SCRIPT LOADER (FULLY CUSTOMIZABLE)
-- =========================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--------------------------------------------------------------------------------
-- 1. MAIN LOADER WINDOW CONFIG
--------------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "🔪 Infinite's MM2 | LOADER",            -- Main Title
    LoadingTitle = "The multiverse is loading.. 👿",      -- Splash Screen Title
    LoadingSubtitle = "by Your Name",        -- Splash Screen Subtitle
    
    -- TOGGLE PILL & KEYBIND CUSTOMIZATION
    ToggleKey = Enum.KeyCode.K,             -- Keybind to open/hide UI on PC
    OpenTitle = "Open Infinite's MM2",          -- Text on the floating toggle pill
    
    ConfigurationSaving = {
        Enabled = false                      -- Keep false for pure script loaders
    },
    Discord = {
        Enabled = false,                     -- Set to true if you have a Discord
        Invite = "discord.gg/yourinvite",
        RememberJoins = true
    },
    KeySystem = false                        -- Set to true if you want a key system
})

--------------------------------------------------------------------------------
-- 2. LOADER TAB (ADD YOUR DECAL ID BELOW)
--------------------------------------------------------------------------------
-- Replace '1234567890' with your custom Roblox Decal / Asset ID for the Tab Icon
local MainTab = Window:CreateTab("MM2 Loader", 71537746553437) 

MainTab:CreateSection("Script Controls")

-- Custom Banner Decal inside the menu
MainTab:CreateImage({
    Title = "MM2 Script Preview",
    Image = 115612691469930,                      -- Your Decal Asset ID here
})

-- Script Selection Dropdown
local SelectedScript = "Main MM2 Script"

MainTab:CreateDropdown({
    Name = "Select MM2 Feature / Mode",
    Options = {"Main MM2 Script", "Auto-Farm Coins", "Silent Aim / Sheriff Bot", "Custom / Test Mode"},
    CurrentOption = {"Main MM2 Script"},
    MultipleOptions = false,
    Flag = "MM2_ScriptSelect",
    Callback = function(Options)
        SelectedScript = Options[1]
    end,
})

-- Execution Button
MainTab:CreateButton({
    Name = "▶ Launch Script",
    Callback = function()
        -- Notification with Custom Decal
        Rayfield:Notify({
            Title = "MM2 Hub Executing",
            Content = "Loading " .. SelectedScript .. "...",
            Duration = 3,
            Image = 1234567890,              -- Your Decal Asset ID for Notification
        })
        
        task.wait(1.5)
        
        -- Cleanly unload loader UI before running main script
        Rayfield:Destroy()
        
        -- =========================================
        -- SCRIPT EXECUTION LOGIC (PASTE LINKS HERE)
        -- =========================================
        if SelectedScript == "Main MM2 Script" then
            print("Launching Main MM2 Script...")
            -- loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_1"))()
            
        elseif SelectedScript == "Auto-Farm Coins" then
            print("Launching MM2 Auto-Farm...")
            -- loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_2"))()
            
        elseif SelectedScript == "Silent Aim / Sheriff Bot" then
            print("Launching Sheriff Bot...")
            -- loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL_3"))()
            
        elseif SelectedScript == "Custom / Test Mode" then
            print("Test Mode initialized.")
        end
    end,
})

--------------------------------------------------------------------------------
-- 3. EXTRA INFO TAB
--------------------------------------------------------------------------------
local InfoTab = Window:CreateTab("Info", 1234567890)

InfoTab:CreateSection("Loader Info")

InfoTab:CreateParagraph({
    Title = "FUCK THIS SCRIPT LOL",
    Content = "Game: Murder Mystery 2\nStatus: Undetected\nVersion: 1.0.0"
})

InfoTab:CreateButton({
    Name = "Close Loader",
    Callback = function()
        Rayfield:Destroy()
    end,
})
