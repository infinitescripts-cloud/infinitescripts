-- Define Custom Black/White Theme with Blue & Purple Hues
local BlackPurpleBlueTheme = {
   TextColor = Color3.fromRGB(255, 255, 255),

   Background = Color3.fromRGB(15, 15, 20),           -- Deep midnight black
   Topbar = Color3.fromRGB(25, 25, 32),               -- Dark slate top bar
   Shadow = Color3.fromRGB(10, 10, 15),

   NotificationBackground = Color3.fromRGB(22, 22, 30),
   NotificationActionsBackground = Color3.fromRGB(138, 92, 246), -- Purple notification accent

   -- Tab Bar Styling (Purple & Blue Highlights)
   TabBackground = Color3.fromRGB(35, 35, 45),
   TabStroke = Color3.fromRGB(60, 60, 80),
   TabBackgroundSelected = Color3.fromRGB(124, 58, 237), -- Vibrant Purple selection
   TabTextColor = Color3.fromRGB(200, 200, 220),
   SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

   -- Interactive Element Backgrounds
   ElementBackground = Color3.fromRGB(28, 28, 38),
   ElementBackgroundHover = Color3.fromRGB(38, 38, 52),
   SecondaryElementBackground = Color3.fromRGB(20, 20, 28),
   ElementStroke = Color3.fromRGB(55, 55, 75),
   SecondaryElementStroke = Color3.fromRGB(45, 45, 65),

   -- Sliders (Electric Blue)
   SliderBackground = Color3.fromRGB(40, 40, 55),
   SliderProgress = Color3.fromRGB(14, 165, 233),     -- Cyan / Electric Blue
   SliderStroke = Color3.fromRGB(56, 189, 248),

   -- Toggles (Neon Blue / Indigo)
   ToggleBackground = Color3.fromRGB(30, 30, 40),
   ToggleEnabled = Color3.fromRGB(37, 99, 235),        -- Deep Royal Blue
   ToggleDisabled = Color3.fromRGB(70, 70, 85),
   ToggleEnabledStroke = Color3.fromRGB(96, 165, 250),
   ToggleDisabledStroke = Color3.fromRGB(90, 90, 110),
   ToggleEnabledOuterStroke = Color3.fromRGB(59, 130, 246),
   ToggleDisabledOuterStroke = Color3.fromRGB(40, 40, 55),

   -- Dropdowns & Inputs (Soft Purple Accent)
   DropdownSelected = Color3.fromRGB(109, 40, 217),    -- Deep Purple
   DropdownUnselected = Color3.fromRGB(28, 28, 38),

   InputBackground = Color3.fromRGB(25, 25, 35),
   InputStroke = Color3.fromRGB(99, 102, 241),         -- Indigo Blue border
   PlaceholderColor = Color3.fromRGB(160, 160, 185)
}

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the Main Window
local Window = Rayfield:CreateWindow({
   Name = "Infinite's MM2 | Loader",
   Icon = "crosshair",
   LoadingTitle = "Infinite MM2 Script",
   LoadingSubtitle = "the new era !",
   Theme = BlackPurpleBlueTheme, -- Applying the custom palette here
   ShowText = "Infinite's MM2",

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "InfiniteMM2",
      FileName = "LoaderConfig"
   },

   KeySystem = false,
})

-- Main Tab
local MainTab = Window:CreateTab("Script Execution", "play")

-- Security Section Header
MainTab:CreateSection("Official Source Warning")

-- Updated Label Warning with Dark Red Background
MainTab:CreateLabel(
   "If this script came from other sites other than rscripts, Please destroy it.", 
   "triangle-alert", 
   Color3.fromRGB(120, 20, 20), 
   true
)

-- Authentication Paragraph Instructions
MainTab:CreateParagraph({
   Title = "Authentication Notice",
   Content = "Hello! Please click Verify Script for authentication. If Official, scroll down and click \"Execute Infinite's MM2\" Thanks!"
})

-- Script Verification Button
MainTab:CreateButton({
   Name = "Verify Script",
   Callback = function()
      local Players = game:GetService("Players")
      local localPlayer = Players.LocalPlayer
      local username = localPlayer and localPlayer.Name or ""

      local isCreator = (username:lower() == "poppingirlx" or username:lower() == "ashy_ash7474")

      local scriptSource = debug.info(1, "s") or ""
      local isFromRscripts = string.find(scriptSource:lower(), "rscripts.net") ~= nil

      if isCreator then
         Rayfield:Notify({
            Title = "Welcome Creator",
            Content = "The owner! Welcome. Completely for you to enjoy.",
            Duration = 5,
            Image = "crown",
         })
      elseif isFromRscripts then
         Rayfield:Notify({
            Title = "Verification Success",
            Content = "This script is 100% official, Thanks!",
            Duration = 5,
            Image = "check-circle",
         })
      else
         Rayfield:Notify({
            Title = "Auto Self-Destruct Initiated",
            Content = "This UI is auto self destructing, since it came from an unofficial site.\nCiao!",
            Duration = 10,
            Image = "trash-2",
         })

         task.delay(10, function()
            Rayfield:Destroy()
         end)
      end
   end,
})

-- Execution Section
MainTab:CreateSection("Script Controls")

-- Main Script Loader Button
MainTab:CreateButton({
   Name = "Execute Infinite MM2",
   Callback = function()
      Rayfield:Notify({
         Title = "Loading Script",
         Content = "Infinite MM2 is executing...",
         Duration = 4,
         Image = "check-circle",
      })

      loadstring(game:HttpGet("https://raw.githubusercontent.com/infinitescripts-cloud/infinitescripts/main/infinitesmm2.lua"))()
   end,
})
