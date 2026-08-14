-- =============================================
-- ORION UI LIBRARY v3.0 - Delta Executor Optimized
-- PART 1: CORE FRAMEWORK
-- =============================================

local OrionLib = {}
OrionLib.__index = OrionLib

OrionLib.Config = {
    Theme = {
        Background = Color3.fromRGB(30, 30, 35),
        BackgroundAlt = Color3.fromRGB(40, 40, 47),
        Primary = Color3.fromRGB(66, 133, 244),
        PrimaryDark = Color3.fromRGB(50, 100, 200),
        Secondary = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 70),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 193, 7),
    },
    AnimationSpeed = 0.3,
    DefaultFont = Enum.Font.Gotham,
    NotificationDuration = 5,
}

local OrionUI = {}
OrionUI.__index = OrionUI

function OrionUI.new(config)
    local self = setmetatable({}, OrionUI)
    
    self.config = config or {}
    self.name = self.config.Name or "Orion UI"
    self.saveConfig = self.config.SaveConfig or false
    self.configFolder = self.config.ConfigFolder or "OrionConfig"
    self.hidePremium = self.config.HidePremium or false
    self.tabs = {}
    self.activeTab = nil
    self.elements = {}
    self.flags = {}
    self.theme = OrionLib.Config.Theme
    
    -- ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "OrionUI"
    self.screenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 600, 0, 450)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    self.mainFrame.BackgroundColor3 = self.theme.Background
    self.mainFrame.BackgroundTransparency = 0
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.ClipsDescendants = true
    self.mainFrame.Parent = self.screenGui
    
    -- Title Bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 40)
    self.titleBar.BackgroundColor3 = self.theme.Primary
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    -- Title Label
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "TitleLabel"
    self.titleLabel.Size = UDim2.new(1, -80, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = self.name
    self.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.titleLabel.TextSize = 18
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.Parent = self.titleBar
    
    -- Close Button
    self.closeBtn = Instance.new("TextButton")
    self.closeBtn.Name = "CloseBtn"
    self.closeBtn.Size = UDim2.new(0, 30, 0, 30)
    self.closeBtn.Position = UDim2.new(1, -35, 0, 5)
    self.closeBtn.BackgroundTransparency = 1
    self.closeBtn.Text = "✕"
    self.closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeBtn.TextSize = 18
    self.closeBtn.Font = Enum.Font.Gotham
    self.closeBtn.Parent = self.titleBar
    self.closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
        if self.config.CloseCallback then
            self.config.CloseCallback()
        end
    end)
    
    -- Tab Container
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(0, 200, 1, -40)
    self.tabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.tabContainer.BackgroundColor3 = self.theme.BackgroundAlt
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.Parent = self.mainFrame
    
    -- Content Container
    self.contentContainer = Instance.new("ScrollingFrame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, -200, 1, -40)
    self.contentContainer.Position = UDim2.new(0, 200, 0, 40)
    self.contentContainer.BackgroundColor3 = self.theme.Background
    self.contentContainer.BorderSizePixel = 0
    self.contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.contentContainer.ScrollBarThickness = 6
    self.contentContainer.ScrollBarImageColor3 = self.theme.Primary
    self.contentContainer.Parent = self.mainFrame
    
    self:MakeDraggable()
    
    if self.saveConfig then
        self:LoadConfig()
    end
    
    return self
end

function OrionUI:MakeDraggable()
    local dragging = false
    local dragInput, dragStart, startPos
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function OrionUI:MakeTab(config)
    local tab = {
        name = config.Name or "Tab",
        icon = config.Icon or "",
        premiumOnly = config.PremiumOnly or false,
        elements = {},
        sections = {},
        ui = self,
    }
    
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tab.name
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, #self.tabs * 40 + 5)
    btn.BackgroundTransparency = 1
    btn.Text = tab.icon .. " " .. tab.name
    btn.TextColor3 = self.theme.TextDim
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.Parent = self.tabContainer
    
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    tab.button = btn
    table.insert(self.tabs, tab)
    
    if #self.tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function OrionUI:SelectTab(tab)
    for _, child in ipairs(self.contentContainer:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("ScrollingFrame") then
            child:Destroy()
        end
    end
    
    for _, t in ipairs(self.tabs) do
        if t == tab then
            t.button.TextColor3 = self.theme.Secondary
            t.button.BackgroundColor3 = self.theme.Background
            t.button.BackgroundTransparency = 0.2
        else
            t.button.TextColor3 = self.theme.TextDim
            t.button.BackgroundTransparency = 1
        end
    end
    
    self.activeTab = tab
    
    local yOffset = 10
    for _, section in ipairs(tab.sections or {}) do
        local sectionFrame = self:CreateSection(section.name)
        sectionFrame.Position = UDim2.new(0, 10, 0, yOffset)
        yOffset = yOffset + 30
        
        for _, element in ipairs(section.elements or {}) do
            element:Render(sectionFrame, yOffset)
            yOffset = yOffset + element:GetHeight() + 5
        end
    end
    
    self.contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
end

function OrionUI:CreateSection(name)
    local frame = Instance.new("Frame")
    frame.Name = "Section_" .. name
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = self.contentContainer
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = self.theme.Primary
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    return frame
end

function OrionUI:AddSection(tab, config)
    local section = {
        name = config.Name or "Section",
        elements = {},
        ui = self,
    }
    table.insert(tab.sections, section)
    return section
end

-- =============================================
-- ORION UI LIBRARY v3.0 - Delta Executor Optimized
-- PART 2: UI COMPONENTS
-- =============================================

function OrionUI:AddButton(section, config)
    local element = {
        type = "Button",
        name = config.Name or "Button",
        callback = config.Callback or function() end,
        height = 35,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local btn = Instance.new("TextButton")
        btn.Name = "Button"
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundColor3 = self.ui.theme.Primary
        btn.Text = self.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(self.callback)
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = self.ui.theme.PrimaryDark
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = self.ui.theme.Primary
        end)
    end
    
    function element:GetHeight()
        return self.height
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddToggle(section, config)
    local element = {
        type = "Toggle",
        name = config.Name or "Toggle",
        default = config.Default or false,
        flag = config.Flag or nil,
        callback = config.Callback or function() end,
        value = config.Default or false,
        height = 35,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = self.name
        label.TextColor3 = self.ui.theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Name = "ToggleBtn"
        toggleBtn.Size = UDim2.new(0, 40, 0, 25)
        toggleBtn.Position = UDim2.new(1, -45, 0.5, -12.5)
        toggleBtn.BackgroundColor3 = self.value and self.ui.theme.Success or self.ui.theme.Border
        toggleBtn.Text = self.value and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleBtn.TextSize = 12
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.Parent = frame
        
        toggleBtn.MouseButton1Click:Connect(function()
            self.value = not self.value
            toggleBtn.BackgroundColor3 = self.value and self.ui.theme.Success or self.ui.theme.Border
            toggleBtn.Text = self.value and "ON" or "OFF"
            self.callback(self.value)
            if self.flag and self.ui.saveConfig then
                self.ui:SaveConfig()
            end
        end)
        
        if self.flag then
            self.ui.flags[self.flag] = self
        end
    end
    
    function element:GetHeight()
        return self.height
    end
    
    function element:Set(value)
        self.value = value
        self.callback(value)
        if self.flag and self.ui.saveConfig then
            self.ui:SaveConfig()
        end
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddSlider(section, config)
    local element = {
        type = "Slider",
        name = config.Name or "Slider",
        min = config.Min or 0,
        max = config.Max or 100,
        default = config.Default or 50,
        increment = config.Increment or 1,
        valueName = config.ValueName or "",
        flag = config.Flag or nil,
        callback = config.Callback or function() end,
        value = config.Default or 50,
        height = 50,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -80, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = self.name .. " (" .. self.value .. (self.valueName ~= "" and " " .. self.valueName or "") .. ")"
        label.TextColor3 = self.ui.theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "SliderFrame"
        sliderFrame.Size = UDim2.new(1, 0, 0, 6)
        sliderFrame.Position = UDim2.new(0, 0, 0, 28)
        sliderFrame.BackgroundColor3 = self.ui.theme.Border
        sliderFrame.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((self.value - self.min) / (self.max - self.min), 0, 1, 0)
        fill.BackgroundColor3 = self.ui.theme.Primary
        fill.Parent = sliderFrame
        
        local function updateSlider(input)
            local relative = (input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X
            relative = math.clamp(relative, 0, 1)
            local newValue = self.min + (self.max - self.min) * relative
            newValue = math.round(newValue / self.increment) * self.increment
            newValue = math.clamp(newValue, self.min, self.max)
            self.value = newValue
            fill.Size = UDim2.new((self.value - self.min) / (self.max - self.min), 0, 1, 0)
            label.Text = self.name .. " (" .. self.value .. (self.valueName ~= "" and " " .. self.valueName or "") .. ")"
            self.callback(self.value)
            if self.flag and self.ui.saveConfig then
                self.ui:SaveConfig()
            end
        end
        
        local dragging = false
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        sliderFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        sliderFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                updateSlider(input)
            end
        end)
        
        if self.flag then
            self.ui.flags[self.flag] = self
        end
    end
    
    function element:GetHeight()
        return self.height
    end
    
    function element:Set(value)
        self.value = math.clamp(value, self.min, self.max)
        self.callback(self.value)
        if self.flag and self.ui.saveConfig then
            self.ui:SaveConfig()
        end
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddDropdown(section, config)
    local element = {
        type = "Dropdown",
        name = config.Name or "Dropdown",
        options = config.Options or {},
        default = config.Default or "",
        flag = config.Flag or nil,
        callback = config.Callback or function() end,
        value = config.Default or "",
        height = 40,
        ui = self,
        open = false,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.ClipsDescendants = true
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -60, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = self.name
        label.TextColor3 = self.ui.theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Name = "DropdownBtn"
        dropdownBtn.Size = UDim2.new(0, 60, 0, 25)
        dropdownBtn.Position = UDim2.new(1, -65, 0.5, -12.5)
        dropdownBtn.BackgroundColor3 = self.ui.theme.BackgroundAlt
        dropdownBtn.Text = self.value ~= "" and self.value or "Select"
        dropdownBtn.TextColor3 = self.ui.theme.Text
        dropdownBtn.TextSize = 12
        dropdownBtn.Font = Enum.Font.Gotham
        dropdownBtn.Parent = frame
        
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = "DropdownFrame"
        dropdownFrame.Size = UDim2.new(0, 60, 0, 0)
        dropdownFrame.Position = UDim2.new(1, -65, 0.5, 12.5)
        dropdownFrame.BackgroundColor3 = self.ui.theme.BackgroundAlt
        dropdownFrame.ClipsDescendants = true
        dropdownFrame.Parent = frame
        
        local dropdownList = Instance.new("UIListLayout")
        dropdownList.Name = "DropdownList"
        dropdownList.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownList.Parent = dropdownFrame
        
        local function updateDropdown()
            for _, child in ipairs(dropdownFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for _, option in ipairs(self.options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Name = "Option_" .. option
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = option
                optBtn.TextColor3 = self.ui.theme.Text
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.Parent = dropdownFrame
                
                optBtn.MouseButton1Click:Connect(function()
                    self.value = option
                    dropdownBtn.Text = option
                    self.callback(option)
                    dropdownFrame.Size = UDim2.new(0, 60, 0, 0)
                    frame.Size = UDim2.new(1, -20, 0, self.height)
                    self.open = false
                    if self.flag and self.ui.saveConfig then
                        self.ui:SaveConfig()
                    end
                end)
            end
            
            dropdownFrame.Size = UDim2.new(0, 60, 0, #self.options * 25)
            frame.Size = UDim2.new(1, -20, 0, self.height + #self.options * 25)
        end
        
        dropdownBtn.MouseButton1Click:Connect(function()
            if self.open then
                dropdownFrame.Size = UDim2.new(0, 60, 0, 0)
                frame.Size = UDim2.new(1, -20, 0, self.height)
                self.open = false
            else
                updateDropdown()
                self.open = true
            end
        end)
        
        if self.flag then
            self.ui.flags[self.flag] = self
        end
    end
    
    function element:GetHeight()
        return self.height
    end
    
    function element:Set(value)
        self.value = value
        self.callback(value)
        if self.flag and self.ui.saveConfig then
            self.ui:SaveConfig()
        end
    end
    
    function element:Refresh(options, clear)
        self.options = options
        if clear then
            self.value = ""
        end
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddColorpicker(section, config)
    local element = {
        type = "Colorpicker",
        name = config.Name or "Colorpicker",
        default = config.Default or Color3.fromRGB(255, 0, 0),
        flag = config.Flag or nil,
        callback = config.Callback or function() end,
        value = config.Default or Color3.fromRGB(255, 0, 0),
        height = 35,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -45, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = self.name
        label.TextColor3 = self.ui.theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local colorBtn = Instance.new("ImageButton")
        colorBtn.Name = "ColorBtn"
        colorBtn.Size = UDim2.new(0, 30, 0, 25)
        colorBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
        colorBtn.BackgroundColor3 = self.value
        colorBtn.Image = "rbxassetid://5064669615"
        colorBtn.Parent = frame
        
        colorBtn.MouseButton1Click:Connect(function()
            local colorPicker = Instance.new("Frame")
            colorPicker.Name = "ColorPicker"
            colorPicker.Size = UDim2.new(0, 200, 0, 200)
            colorPicker.Position = UDim2.new(0.5, -100, 0.5, -100)
            colorPicker.BackgroundColor3 = self.ui.theme.Background
            colorPicker.BorderSizePixel = 1
            colorPicker.BorderColor3 = self.ui.theme.Border
            colorPicker.Parent = self.ui.screenGui
            
            local hue = 0
            local saturation = 1
            local value = 1
            
            local spectrum = Instance.new("Frame")
            spectrum.Name = "Spectrum"
            spectrum.Size = UDim2.new(1, -20, 1, -50)
            spectrum.Position = UDim2.new(0, 10, 0, 10)
            spectrum.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
            spectrum.Parent = colorPicker
            
            local hueSlider = Instance.new("Frame")
            hueSlider.Name = "HueSlider"
            hueSlider.Size = UDim2.new(1, -20, 0, 10)
            hueSlider.Position = UDim2.new(0, 10, 1, -20)
            hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueSlider.Parent = colorPicker
            
            local function updateColor()
                local color = Color3.fromHSV(hue, saturation, value)
                spectrum.BackgroundColor3 = color
                colorBtn.BackgroundColor3 = color
                self.value = color
                self.callback(color)
                if self.flag and self.ui.saveConfig then
                    self.ui:SaveConfig()
                end
            end
            
            spectrum.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local relative = (input.Position.X - spectrum.AbsolutePosition.X) / spectrum.AbsoluteSize.X
                    hue = math.clamp(relative, 0, 1)
                    updateColor()
                end
            end)
            
            local closePicker = Instance.new("TextButton")
            closePicker.Name = "ClosePicker"
            closePicker.Size = UDim2.new(0, 30, 0, 30)
            closePicker.Position = UDim2.new(1, -35, 0, 5)
            closePicker.BackgroundTransparency = 1
            closePicker.Text = "✕"
            closePicker.TextColor3 = self.ui.theme.Text
            closePicker.TextSize = 16
            closePicker.Font = Enum.Font.Gotham
            closePicker.Parent = colorPicker
            closePicker.MouseButton1Click:Connect(function()
                colorPicker:Destroy()
            end)
        end)
        
        if self.flag then
            self.ui.flags[self.flag] = self
        end
    end
    
    function element:GetHeight()
        return self.height
    end
    
    function element:Set(color)
        self.value = color
        self.callback(color)
        if self.flag and self.ui.saveConfig then
            self.ui:SaveConfig()
        end
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddTextbox(section, config)
    local element = {
        type = "Textbox",
        name = config.Name or "Textbox",
        default = config.Default or "",
        flag = config.Flag or nil,
        callback = config.Callback or function() end,
        value = config.Default or "",
        height = 35,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local frame = Instance.new("Frame")
        frame.Name = "Element_" .. self.name
        frame.Size = UDim2.new(1, -20, 0, self.height)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0, 80, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = self.name
        label.TextColor3 = self.ui.theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local textBox = Instance.new("TextBox")
        textBox.Name = "TextBox"
        textBox.Size = UDim2.new(1, -90, 1, 0)
        textBox.Position = UDim2.new(0, 85, 0, 0)
        textBox.BackgroundColor3 = self.ui.theme.BackgroundAlt
        textBox.Text = self.value
        textBox.TextColor3 = self.ui.theme.Text
        textBox.TextSize = 14
        textBox.Font = Enum.Font.Gotham
        textBox.Parent = frame
        
        textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                self.value = textBox.Text
                self.callback(self.value)
                if self.flag and self.ui.saveConfig then
                    self.ui:SaveConfig()
                end
            end
        end)
        
        if self.flag then
            self.ui.flags[self.flag] = self
        end
    end
    
    function element:GetHeight()
        return self.height
    end
    
    function element:Set(value)
        self.value = value
        self.callback(value)
        if self.flag and self.ui.saveConfig then
            self.ui:SaveConfig()
        end
    end
    
    table.insert(section.elements, element)
    return element
end

function OrionUI:AddLabel(section, config)
    local element = {
        type = "Label",
        text = config.Text or "",
        height = 25,
        ui = self,
    }
    
    function element:Render(parent, yOffset)
        local label = Instance.new("TextLabel")
        label.Name = "Label_" .. self.text
        label.Size = UDim2.new(1, -20, 0, self.height)
        label.Position = UDim2.new(0, 0, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = self.text
        label.TextColor3 = self.ui.theme.TextDim
        label.TextSize = 13
        label.TextXAlignment = Enum.Text

-- =============================================
-- ORION UI LIBRARY v3.0 - Delta Executor Optimized
-- PART 3: NOTIFICATIONS, CONFIG, EXPORT
-- =============================================

function OrionLib:MakeNotification(config)
    config = config or {}
    local name = config.Name or "Notification"
    local content = config.Content or ""
    local image = config.Image or ""
    local duration = config.Time or OrionLib.Config.NotificationDuration
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification_" .. name
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -320, 0, 10)
    notification.BackgroundColor3 = OrionLib.Config.Theme.BackgroundAlt
    notification.BorderSizePixel = 1
    notification.BorderColor3 = OrionLib.Config.Theme.Primary
    notification.ClipsDescendants = true
    notification.Parent = game:GetService("CoreGui")
    
    if image ~= "" then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 40, 1, -10)
        icon.Position = UDim2.new(0, 5, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = image
        icon.Parent = notification
    end
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = OrionLib.Config.Theme.Primary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -60, 0, 20)
    contentLabel.Position = UDim2.new(0, 50, 0, 28)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = OrionLib.Config.Theme.Text
    contentLabel.TextSize = 12
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.Parent = notification
    
    notification.Position = UDim2.new(1, 0, 0, 10)
    local tween = game:GetService("TweenService"):Create(notification, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 0, 10)}
    )
    tween:Play()
    
    task.delay(duration, function()
        local tweenOut = game:GetService("TweenService"):Create(notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 0, 0, 10)}
        )
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

function OrionUI:SaveConfig()
    if not self.saveConfig then return end
    
    local data = {}
    for flag, element in pairs(self.flags) do
        if element.type == "Toggle" then
            data[flag] = element.value
        elseif element.type == "Slider" then
            data[flag] = element.value
        elseif element.type == "Dropdown" then
            data[flag] = element.value
        elseif element.type == "Colorpicker" then
            data[flag] = {
                R = element.value.R,
                G = element.value.G,
                B = element.value.B,
            }
        elseif element.type == "Textbox" then
            data[flag] = element.value
        elseif element.type == "Bind" then
            data[flag] = tostring(element.value)
        end
    end
    
    local json = game:GetService("HttpService"):JSONEncode(data)
    writefile(self.configFolder .. "/config.json", json)
end

function OrionUI:LoadConfig()
    if not self.saveConfig then return end
    
    local success, data = pcall(function()
        return readfile(self.configFolder .. "/config.json")
    end)
    
    if not success then return end
    
    local decoded = game:GetService("HttpService"):JSONDecode(data)
    for flag, value in pairs(decoded) do
        local element = self.flags[flag]
        if element then
            if element.type == "Colorpicker" then
                element:Set(Color3.fromRGB(value.R, value.G, value.B))
            elseif element.type == "Bind" then
                element:Set(Enum.KeyCode[value])
            else
                element:Set(value)
            end
        end
    end
end

function OrionUI:Destroy()
    self.screenGui:Destroy()
end

function OrionLib:MakeWindow(config)
    return OrionUI.new(config)
end

return OrionLib