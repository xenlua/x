-- Enhanced Smart Checkpoint GUI - Mobile Friendly Version with Auto Delay
-- Replaces Avantrix library with custom mobile-optimized GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Script Variables (same as original)
local autoCheckpointEnabled = false
local autoRespawnEnabled = false
local autoCheckpointConnection = nil
local statusUpdateConnection = nil
local retryAttempts = 0
local maxRetryAttempts = 3
local autoCheckpointDelay = 1 -- NEW: Delay variable in seconds

-- Detection variables
local detectedCheckpoints = {}
local detectedSummitAreas = {}
local maxCheckpoints = 0
local currentCheckpointIndex = 1

-- Enhanced patterns for checkpoint detection (same as original)
local CHECKPOINT_PATTERNS = {
    "^CP%d+$", "^cp%d+$", "^Checkpoint%d+$", "^checkpoint%d+$",
    "^Stage%d+$", "^stage%d+$", "^Point%d+$", "^point%d+$",
    "^%d+$", "^Level%d+$", "^level%d+$","^CheckpointPart%d+$"
}

local SUMMIT_PATTERNS = {
    "^Summit$", "^summit$", "^SUMMIT$", "^SummitArea$", "^summitarea$", "^SUMMITAREA$",
    "^Puncak$", "^puncak$", "^PUNCAK$", "^Finish$", "^finish$", "^FINISH$",
    "^End$", "^end$", "^END$", "^Final$", "^final$", "^FINAL$",
    "^Win$", "^win$", "^WIN$","^SummitPart$"
}

-- GUI Creation Functions
local function createScreenGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SmartCheckpointGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    -- Try to parent to CoreGui first, fallback to PlayerGui
    pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not screenGui.Parent then
        screenGui.Parent = playerGui
    end
    
    return screenGui
end

local function createMainFrame(parent)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    
    -- Mobile-responsive sizing
    local screenSize = workspace.CurrentCamera.ViewportSize
    local isMobile = screenSize.X < 800 or screenSize.Y < 600
    
    if isMobile then
        mainFrame.Size = UDim2.new(0.95, 0, 0.8, 0) -- 95% width, 80% height on mobile
        mainFrame.Position = UDim2.new(0.025, 0, 0.1, 0) -- Centered on mobile
    else
        mainFrame.Size = UDim2.new(0, 380, 0, 500)
        mainFrame.Position = UDim2.new(0, 20, 0, 20)
    end
    
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = parent
    
    -- Auto-scale text based on screen size
    local textScale = isMobile and 0.8 or 1.0
    mainFrame:SetAttribute("TextScale", textScale)
    mainFrame:SetAttribute("IsMobile", isMobile)
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 8 or 12)
    corner.Parent = mainFrame
    
    -- Drop shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, isMobile and 8 or 12)
    shadowCorner.Parent = shadow
    
    return mainFrame
end

local function createHeader(parent)
    local isMobile = parent:GetAttribute("IsMobile") or false
    local textScale = parent:GetAttribute("TextScale") or 1.0
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, isMobile and 40 or 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    header.BorderSizePixel = 0
    header.Parent = parent
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, isMobile and 8 or 12)
    headerCorner.Parent = header
    
    -- Fix bottom corners
    local headerFix = Instance.new("Frame")
    local fixHeight = isMobile and 20 or 25
    headerFix.Size = UDim2.new(1, 0, 0, fixHeight)
    headerFix.Position = UDim2.new(0, 0, 1, -fixHeight)
    headerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, isMobile and -70 or -100, 1, 0)
    title.Position = UDim2.new(0, isMobile and 10 or 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Smart Checkpoint v1.1"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = math.floor(18 * textScale)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextScaled = isMobile
    title.Parent = header
    
    -- Hide/Minimize button
    local hideButton = Instance.new("TextButton")
    hideButton.Name = "HideButton"
    local buttonSize = isMobile and 25 or 35
    local buttonOffset = isMobile and 30 or 45
    local buttonY = isMobile and 7.5 or 7.5
    hideButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    hideButton.Position = UDim2.new(1, -buttonOffset, 0, buttonY)
    hideButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    hideButton.BorderSizePixel = 0
    hideButton.Text = "-"
    hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hideButton.TextSize = math.floor(20 * textScale)
    hideButton.Font = Enum.Font.GothamBold
    hideButton.TextScaled = isMobile
    hideButton.Parent = header
    
    local hideCorner = Instance.new("UICorner")
    hideCorner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
    hideCorner.Parent = hideButton
    
    return header, hideButton
end

local function createTabButton(parent, text, position, isActive)
    local mainFrame = parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.33, -5, 0, isMobile and 28 or 35)
    button.Position = position
    button.BackgroundColor3 = isActive and Color3.fromRGB(55, 155, 255) or Color3.fromRGB(45, 45, 55)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = math.floor(14 * textScale)
    button.Font = Enum.Font.Gotham
    button.TextScaled = isMobile
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
    corner.Parent = button
    
    return button
end

local function createScrollFrame(parent)
    local isMobile = parent:GetAttribute("IsMobile") or false
    
    local scrollFrame = Instance.new("ScrollingFrame")
    local topOffset = isMobile and 85 or 105
    local sideMargin = isMobile and 10 or 20
    scrollFrame.Size = UDim2.new(1, -sideMargin, 1, -(topOffset + 15))
    scrollFrame.Position = UDim2.new(0, sideMargin/2, 0, topOffset)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = isMobile and 6 or 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(55, 155, 255)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, isMobile and 6 or 8)
    layout.Parent = scrollFrame
    
    -- Auto-resize canvas
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    return scrollFrame
end

local function createSection(parent, title, description)
    local mainFrame = parent.Parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
    corner.Parent = section
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, isMobile and 6 or 8)
    layout.Parent = section
    
    local padding = Instance.new("UIPadding")
    local paddingSize = isMobile and 10 or 15
    padding.PaddingTop = UDim.new(0, paddingSize)
    padding.PaddingBottom = UDim.new(0, paddingSize)
    padding.PaddingLeft = UDim.new(0, paddingSize)
    padding.PaddingRight = UDim.new(0, paddingSize)
    padding.Parent = section
    
    if title then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, isMobile and 20 or 25)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(55, 155, 255)
        titleLabel.TextSize = math.floor(16 * textScale)
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextScaled = isMobile
        titleLabel.LayoutOrder = 1
        titleLabel.Parent = section
    end
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0, isMobile and 16 or 20)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        descLabel.TextSize = math.floor(12 * textScale)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextScaled = isMobile
        descLabel.TextWrapped = true
        descLabel.LayoutOrder = 2
        descLabel.Parent = section
    end
    
    -- Auto-resize section
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local extraPadding = isMobile and 20 or 30
        section.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + extraPadding)
    end)
    
    return section
end

local function createToggle(parent, text, description, defaultValue, callback)
    local mainFrame = parent.Parent.Parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, isMobile and 50 or 60)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    local toggleWidth = isMobile and 45 or 60
    label.Size = UDim2.new(1, -toggleWidth, 0, isMobile and 20 or 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = math.floor(14 * textScale)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextScaled = isMobile
    label.TextWrapped = true
    label.Parent = toggleFrame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -toggleWidth, 0, isMobile and 16 or 20)
        descLabel.Position = UDim2.new(0, 0, 0, isMobile and 20 or 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = math.floor(11 * textScale)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextWrapped = true
        descLabel.TextScaled = isMobile
        descLabel.Parent = toggleFrame
    end
    
    local toggle = Instance.new("TextButton")
    local buttonWidth = isMobile and 40 or 50
    local buttonHeight = isMobile and 20 or 25
    toggle.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
    toggle.Position = UDim2.new(1, -buttonWidth, 0, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(55, 155, 55) or Color3.fromRGB(155, 55, 55)
    toggle.BorderSizePixel = 0
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = math.floor(12 * textScale)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = isMobile
    toggle.Parent = toggleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 4 or 6)
    corner.Parent = toggle
    
    local isEnabled = defaultValue
    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggle.Text = isEnabled and "ON" or "OFF"
        toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(55, 155, 55) or Color3.fromRGB(155, 55, 55)
        
        -- Animate
        local tween = TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(55, 155, 55) or Color3.fromRGB(155, 55, 55)
        })
        tween:Play()
        
        if callback then
            callback(isEnabled)
        end
    end)
    
    return toggle
end

local function createButton(parent, text, description, callback)
    local mainFrame = parent.Parent.Parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local buttonFrame = Instance.new("Frame")
    local frameHeight = description and (isMobile and 50 or 60) or (isMobile and 32 or 40)
    buttonFrame.Size = UDim2.new(1, 0, 0, frameHeight)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, isMobile and 28 or 35)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(55, 155, 255)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = math.floor(14 * textScale)
    button.Font = Enum.Font.GothamMedium
    button.TextScaled = isMobile
    button.Parent = buttonFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 6 or 8)
    corner.Parent = button
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0, isMobile and 16 or 20)
        descLabel.Position = UDim2.new(0, 0, 0, isMobile and 30 or 38)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = math.floor(11 * textScale)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextWrapped = true
        descLabel.TextScaled = isMobile
        descLabel.Parent = buttonFrame
    end
    
    button.MouseButton1Click:Connect(function()
        -- Button press animation
        local pressedHeight = isMobile and 26 or 33
        local tween = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, pressedHeight)})
        tween:Play()
        tween.Completed:Connect(function()
            local normalHeight = isMobile and 28 or 35
            local tween2 = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, normalHeight)})
            tween2:Play()
        end)
        
        if callback then
            callback()
        end
    end)
    
    return button
end

local function createTextLabel(parent, text, description)
    local mainFrame = parent.Parent.Parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Size = UDim2.new(1, 0, 0, 0)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, isMobile and 3 or 5)
    layout.Parent = labelFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, isMobile and 20 or 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = text
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = math.floor(14 * textScale)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextScaled = isMobile
    titleLabel.TextWrapped = true
    titleLabel.LayoutOrder = 1
    titleLabel.Parent = labelFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description or ""
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.TextSize = math.floor(12 * textScale)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextWrapped = true
    descLabel.TextScaled = isMobile
    descLabel.LayoutOrder = 2
    descLabel.Parent = labelFrame
    
    -- Auto-resize description
    descLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local textService = game:GetService("TextService")
        local textSize = textService:GetTextSize(descLabel.Text, descLabel.TextSize, descLabel.Font, Vector2.new(descLabel.AbsoluteSize.X, math.huge))
        descLabel.Size = UDim2.new(1, 0, 0, textSize.Y)
    end)
    
    -- Auto-resize frame
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        labelFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    -- Return both labels so we can update them
    return {
        setTitle = function(newText)
            titleLabel.Text = newText
        end,
        setDescription = function(newText)
            descLabel.Text = newText
        end
    }
end

local function createSlider(parent, text, description, defaultValue, minValue, maxValue, callback)
    local mainFrame = parent.Parent.Parent.Parent
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local textScale = mainFrame:GetAttribute("TextScale") or 1.0
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 60 or 70)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    local valueWidth = isMobile and 40 or 50
    label.Size = UDim2.new(1, -valueWidth, 0, isMobile and 20 or 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = math.floor(14 * textScale)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextScaled = isMobile
    label.TextWrapped = true
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, valueWidth, 0, isMobile and 20 or 25)
    valueLabel.Position = UDim2.new(1, -valueWidth, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Color3.fromRGB(55, 155, 255)
    valueLabel.TextSize = math.floor(14 * textScale)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextScaled = isMobile
    valueLabel.Parent = sliderFrame
    
    if description then
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, 0, 0, isMobile and 16 or 20)
        descLabel.Position = UDim2.new(0, 0, 0, isMobile and 20 or 25)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = description
        descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        descLabel.TextSize = math.floor(11 * textScale)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextScaled = isMobile
        descLabel.TextWrapped = true
        descLabel.Parent = sliderFrame
    end
    
    local sliderBG = Instance.new("Frame")
    local sliderHeight = isMobile and 6 or 8
    sliderBG.Size = UDim2.new(1, 0, 0, sliderHeight)
    sliderBG.Position = UDim2.new(0, 0, 1, -(sliderHeight + 4))
    sliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, sliderHeight/2)
    sliderCorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(55, 155, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, sliderHeight/2)
    fillCorner.Parent = sliderFill
    
    local currentValue = defaultValue
    
    local function updateSlider(value)
        currentValue = math.clamp(value, minValue, maxValue)
        -- For delay slider, allow decimal values
        if text:lower():find("delay") then
            currentValue = math.floor(currentValue * 10 + 0.5) / 10 -- Round to 1 decimal place
            valueLabel.Text = string.format("%.1fs", currentValue)
        else
            currentValue = math.floor(currentValue + 0.5) -- Round to nearest integer
            valueLabel.Text = tostring(currentValue)
        end
        
        local fillSize = (currentValue - minValue) / (maxValue - minValue)
        local tween = TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(fillSize, 0, 1, 0)})
        tween:Play()
        
        if callback then
            callback(currentValue)
        end
    end
    
    -- Handle mouse/touch input
    local dragging = false
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            updateSlider(newValue)
        end
    end)
    
    sliderBG.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local newValue = minValue + (maxValue - minValue) * relativeX
            updateSlider(newValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return updateSlider
end

-- Create dialog function
local function showDialog(title, content, buttons)
    local dialogBG = Instance.new("Frame")
    dialogBG.Size = UDim2.new(1, 0, 1, 0)
    dialogBG.Position = UDim2.new(0, 0, 0, 0)
    dialogBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dialogBG.BackgroundTransparency = 0.5
    dialogBG.BorderSizePixel = 0
    dialogBG.ZIndex = 100
    
    -- Try CoreGui first, fallback to PlayerGui
    pcall(function()
        dialogBG.Parent = CoreGui
    end)
    if not dialogBG.Parent then
        dialogBG.Parent = playerGui
    end
    
    local dialog = Instance.new("Frame")
    dialog.Size = UDim2.new(0, 350, 0, 200)
    dialog.Position = UDim2.new(0.5, -175, 0.5, -100)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 101
    dialog.Parent = dialogBG
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialog
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 0, 40)
    titleLabel.Position = UDim2.new(0, 15, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.ZIndex = 102
    titleLabel.Parent = dialog
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -30, 0, 100)
    contentLabel.Position = UDim2.new(0, 15, 0, 55)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.TextSize = 14
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextWrapped = true
    contentLabel.ZIndex = 102
    contentLabel.Parent = dialog
    
    -- Buttons
    if buttons then
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -30, 0, 35)
        buttonFrame.Position = UDim2.new(0, 15, 1, -50)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.ZIndex = 102
        buttonFrame.Parent = dialog
        
        local buttonCount = #buttons
        for i, buttonData in ipairs(buttons) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1/buttonCount, -5, 1, 0)
            button.Position = UDim2.new((i-1)/buttonCount, (i-1)*5, 0, 0)
            button.BackgroundColor3 = buttonData.Variant == "Primary" and Color3.fromRGB(55, 155, 255) or Color3.fromRGB(155, 55, 55)
            button.BorderSizePixel = 0
            button.Text = buttonData.Title
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 14
            button.Font = Enum.Font.GothamMedium
            button.ZIndex = 103
            button.Parent = buttonFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                dialogBG:Destroy()
                if buttonData.Callback then
                    buttonData.Callback()
                end
            end)
        end
    end
    
    -- Auto-close after 10 seconds if no buttons
    if not buttons then
        task.wait(10)
        if dialogBG.Parent then
            dialogBG:Destroy()
        end
    end
end

-- All the original detection and checkpoint functions (keeping them the same)
local function extractNumberFromName(name)
    if string.match(name, "^%d+$") then
        return tonumber(name)
    end
    
    for _, pattern in ipairs(CHECKPOINT_PATTERNS) do
        if pattern ~= "^%d+$" and string.match(name, pattern) then
            local number = string.match(name, "%d+")
            if number then
                return tonumber(number)
            end
        end
    end
    
    return nil
end

local function isSummitArea(name)
    for _, pattern in ipairs(SUMMIT_PATTERNS) do
        if string.match(name, pattern) then
            return true
        end
    end
    return false
end

local function isValidCheckpoint(name, number)
    if string.match(name, "^%d+$") and number then
        return true
    end
    
    for _, pattern in ipairs(CHECKPOINT_PATTERNS) do
        if string.match(name, pattern) then
            return true
        end
    end
    
    return false
end

local function scanWorkspaceForCheckpoints()
    detectedCheckpoints = {}
    detectedSummitAreas = {}
    maxCheckpoints = 0
    
    local function scanContainer(container, depth, path)
        if depth > 10 then return end -- Increased depth for thorough scanning
        
        path = path or container.Name
        
        pcall(function()
            for _, child in pairs(container:GetChildren()) do
                if child:IsA("BasePart") and child:FindFirstChild("TouchInterest") then
                    local number = extractNumberFromName(child.Name)
                    if number then
                        if isValidCheckpoint(child.Name, number) then
                            detectedCheckpoints[number] = child
                            if number > maxCheckpoints then
                                maxCheckpoints = number
                            end
                            print("✅ Detected checkpoint:", child.Name, "-> Number:", number, "at path:", path .. "/" .. child.Name)
                        end
                    else
                        local isValidSummit = false
                        for _, pattern in ipairs(SUMMIT_PATTERNS) do
                            if string.match(child.Name, pattern) then
                                isValidSummit = true
                                break
                            end
                        end
                        
                        if isValidSummit then
                            table.insert(detectedSummitAreas, child)
                            print("🏁 Detected summit:", child.Name, "at path:", path .. "/" .. child.Name)
                        end
                    end
                end
                -- Scan ALL containers (Folders, Models, etc.) - not just checkpoint-related ones
                if child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") or 
                   child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("ObjectValue") or
                   child:IsA("BoolValue") or child:IsA("NumberValue") then
                    scanContainer(child, depth + 1, path .. "/" .. child.Name)
                end
            end
        end)
    end
    
    -- Comprehensive workspace scanning - scan EVERYTHING
    print("🔍 Starting comprehensive workspace scan...")
    scanContainer(workspace, 0, "workspace")
    
    -- Also scan common service locations where checkpoints might be
    local servicesToScan = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"), -- May not be accessible but try anyway
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer")
    }
    
    for _, service in ipairs(servicesToScan) do
        if service then
            pcall(function()
                print("🔍 Scanning service:", service.Name)
                scanContainer(service, 0, service.Name)
            end)
        end
    end
    
    local detectedCount = 0
    for num, checkpoint in pairs(detectedCheckpoints) do
        detectedCount = detectedCount + 1
        print("🎯 Final detected CP" .. num .. ":", checkpoint.Name, "Parent:", checkpoint.Parent and checkpoint.Parent.Name or "nil", checkpoint:FindFirstChild("TouchInterest") and "✅" or "❌")
    end
    
    print("📊 Comprehensive scan complete:", detectedCount, "checkpoints,", #detectedSummitAreas, "summit areas, max:", maxCheckpoints)
    
    return detectedCheckpoints, detectedSummitAreas, maxCheckpoints
end

local function getPlayerCheckpointValue()
    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        local commonNames = {"Stage", "stage", "STAGE", "Checkpoint", "checkpoint", "CHECKPOINT", "Level", "level", "LEVEL", "CP", "cp"}
        
        for _, name in ipairs(commonNames) do
            local value = leaderstats:FindFirstChild(name)
            if value then
                return value.Value
            end
        end
    end
    return 0
end

local function findCheckpointByNumber(number)
    return detectedCheckpoints[number]
end

local function updateCurrentIndex()
    local playerCheckpoint = getPlayerCheckpointValue()
    currentCheckpointIndex = playerCheckpoint + 1
    if currentCheckpointIndex > maxCheckpoints then
        currentCheckpointIndex = maxCheckpoints
    end
end

local function respawnCharacter()
    if autoRespawnEnabled then
        if player.Character then
            player.Character:BreakJoints()
        end
        player:LoadCharacter()
        task.wait(3)
        return true
    end
    return false
end

local function waitForCheckpoint(checkpointNumber, timeout)
    timeout = timeout or 8
    local startTime = tick()
    
    while tick() - startTime < timeout do
        local checkpoint = detectedCheckpoints[checkpointNumber]
        if checkpoint and checkpoint:FindFirstChild("TouchInterest") then
            return checkpoint
        end
        task.wait(0.2)
    end
    
    return nil
end

local function touchSingleCheckpoint(checkpointNumber)
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local checkpoint = waitForCheckpoint(checkpointNumber, 8)
    
    if not checkpoint then
        return false, "Checkpoint " .. checkpointNumber .. " not found"
    end
    
    if firetouchinterest then
        local success = false
        
        pcall(function()
            firetouchinterest(humanoidRootPart, checkpoint, 0)
            task.wait(0.1)
            firetouchinterest(humanoidRootPart, checkpoint, 1)
            success = true
        end)
        
        if not success then
            pcall(function()
                firetouchinterest(checkpoint, humanoidRootPart, 0)
                task.wait(0.2)
                firetouchinterest(checkpoint, humanoidRootPart, 1)
                success = true
            end)
        end
        
        if not success then
            pcall(function()
                local originalPosition = humanoidRootPart.CFrame
                humanoidRootPart.CFrame = checkpoint.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.1)
                firetouchinterest(humanoidRootPart, checkpoint, 0)
                task.wait(0.1)
                firetouchinterest(humanoidRootPart, checkpoint, 1)
                task.wait(0.1)
                humanoidRootPart.CFrame = originalPosition
                success = true
            end)
        end
        
        return true, "Success"
    end
    return false, "firetouchinterest not available"
end

local function touchSummitArea()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local playerCheckpoint = getPlayerCheckpointValue()
    
    if playerCheckpoint >= maxCheckpoints then
        for _, summitArea in ipairs(detectedSummitAreas) do
            if summitArea and summitArea:FindFirstChild("TouchInterest") then
                if firetouchinterest then
                    local success = false
                    
                    pcall(function()
                        firetouchinterest(humanoidRootPart, summitArea, 0)
                        task.wait(0.1)
                        firetouchinterest(humanoidRootPart, summitArea, 1)
                        success = true
                    end)
                    
                    if not success then
                        pcall(function()
                            firetouchinterest(summitArea, humanoidRootPart, 0)
                            task.wait(0.1)
                            firetouchinterest(summitArea, humanoidRootPart, 1)
                            success = true
                        end)
                    end
                    
                    if not success then
                        pcall(function()
                            local originalPosition = humanoidRootPart.CFrame
                            humanoidRootPart.CFrame = summitArea.CFrame + Vector3.new(0, 5, 0)
                            task.wait(0.1)
                            firetouchinterest(humanoidRootPart, summitArea, 0)
                            task.wait(0.1)
                            firetouchinterest(humanoidRootPart, summitArea, 1)
                            task.wait(0.1)
                            humanoidRootPart.CFrame = originalPosition
                            success = true
                        end)
                    end
                    
                    return true
                end
            end
        end
        
        return false
    else
        return false
    end
end

-- MODIFIED: Updated auto checkpoint loop with delay functionality
local function autoCheckpointLoop()
    retryAttempts = 0
    
    while autoCheckpointEnabled do
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        
        if retryAttempts % 5 == 0 then
            scanWorkspaceForCheckpoints()
        end
        
        local character = player.Character
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        
        local playerCheckpoint = getPlayerCheckpointValue()
        
        if playerCheckpoint >= maxCheckpoints then
            local summitTouched = touchSummitArea()
            if not summitTouched then
                -- Continue the loop to keep scanning
            end
        end
        
        local nextCheckpointNumber = playerCheckpoint + 1
        
        if nextCheckpointNumber <= maxCheckpoints then
            local nextCheckpoint = findCheckpointByNumber(nextCheckpointNumber)
            
            if not nextCheckpoint or not nextCheckpoint:FindFirstChild("TouchInterest") then
                if autoRespawnEnabled then
                    respawnCharacter()
                    retryAttempts = 0
                    task.wait(1)
                    continue
                else
                    retryAttempts = retryAttempts + 1
                    
                    if retryAttempts >= maxRetryAttempts then
                        retryAttempts = 0
                        task.wait(2)
                    else
                        task.wait(0.5)
                    end
                    continue
                end
            end
            
            if autoCheckpointEnabled then
                local success, message = touchSingleCheckpoint(nextCheckpointNumber)
                if success then
                    retryAttempts = 0
                    local startTime = tick()
                    local initialCheckpoint = getPlayerCheckpointValue()
                    
                    while tick() - startTime < 3 do
                        local currentCheckpoint = getPlayerCheckpointValue()
                        if currentCheckpoint > initialCheckpoint then
                            break
                        end
                        task.wait(0.1)
                    end
                    
                    -- NEW: Apply user-defined delay after successful checkpoint touch
                    task.wait(autoCheckpointDelay)
                else
                    if autoRespawnEnabled then
                        respawnCharacter()
                        retryAttempts = 0
                    else
                        retryAttempts = retryAttempts + 1
                        task.wait(0.5)
                    end
                end
            end
        else
            if playerCheckpoint >= maxCheckpoints then
                touchSummitArea()
                task.wait(2)
            end
        end
        
        task.wait(0.5)
    end
end

-- Create the main GUI
local function createMainGUI()
    local screenGui = createScreenGui()
    local mainFrame = createMainFrame(screenGui)
    local header, hideButton = createHeader(mainFrame)
    
    -- Tab navigation
    local tabFrame = Instance.new("Frame")
    local isMobile = mainFrame:GetAttribute("IsMobile") or false
    local sideMargin = isMobile and 10 or 20
    local headerHeight = isMobile and 40 or 50
    local tabHeight = isMobile and 30 or 40
    
    tabFrame.Size = UDim2.new(1, -sideMargin, 0, tabHeight)
    tabFrame.Position = UDim2.new(0, sideMargin/2, 0, headerHeight + 10)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local infoTab = createTabButton(tabFrame, "Info", UDim2.new(0, 0, 0, 0), true)
    local autoTab = createTabButton(tabFrame, "Auto", UDim2.new(0.33, 2.5, 0, 0), false)
    local settingsTab = createTabButton(tabFrame, "Settings", UDim2.new(0.66, 5, 0, 0), false)
    
    -- Content frames
    local infoFrame = createScrollFrame(mainFrame)
    local autoFrame = createScrollFrame(mainFrame)
    local settingsFrame = createScrollFrame(mainFrame)
    
    infoFrame.Visible = true
    autoFrame.Visible = false
    settingsFrame.Visible = false
    
    -- Tab switching
    local currentTab = infoTab
    
    local function switchTab(tab, frame)
        currentTab.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        currentTab = tab
        tab.BackgroundColor3 = Color3.fromRGB(55, 155, 255)
        
        infoFrame.Visible = false
        autoFrame.Visible = false
        settingsFrame.Visible = false
        
        frame.Visible = true
    end
    
    infoTab.MouseButton1Click:Connect(function() switchTab(infoTab, infoFrame) end)
    autoTab.MouseButton1Click:Connect(function() switchTab(autoTab, autoFrame) end)
    settingsTab.MouseButton1Click:Connect(function() switchTab(settingsTab, settingsFrame) end)
    
    -- Hide/Show functionality
    local isMinimized = false
    hideButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        hideButton.Text = isMinimized and "+" or "-"
        
        local minHeight = isMobile and 40 or 50
        local maxHeight = isMobile and (screenSize.Y * 0.8) or 500
        local targetSize
        
        if isMobile then
            targetSize = isMinimized and UDim2.new(0.95, 0, 0, minHeight) or UDim2.new(0.95, 0, 0.8, 0)
        else
            targetSize = isMinimized and UDim2.new(0, 380, 0, minHeight) or UDim2.new(0, 380, 0, maxHeight)
        end
        
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
        tween:Play()
        
        tabFrame.Visible = not isMinimized
        infoFrame.Visible = not isMinimized and infoFrame.Visible
        autoFrame.Visible = not isMinimized and autoFrame.Visible  
        settingsFrame.Visible = not isMinimized and settingsFrame.Visible
    end)
    
    -- INFO TAB
    local welcomeSection = createSection(infoFrame, "Welcome to Smart Checkpoint Script!", "Enhanced detection system with mobile-friendly interface")
    
    local welcomeLabel = createTextLabel(welcomeSection, "System Status", "Loading...")
    
    -- Update welcome message
    task.spawn(function()
        task.wait(1)
        scanWorkspaceForCheckpoints()
        
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        
        welcomeLabel.setTitle("Enhanced Detection Complete!")
        welcomeLabel.setDescription(string.format([[✅ FIXED: Pure numeric checkpoints (1, 2, 3, etc.)
⏱️ NEW: Customizable auto checkpoint delay

📍 Detected: %d checkpoints
🎯 Summit areas: %d  
🏁 Max checkpoint: %d

🔧 What's New:
• Auto checkpoint delay slider (0.1s - 10s)
• Numeric checkpoint detection (1,2,3)
• Enhanced pattern matching
• Better validation logic
• More reliable scanning

💡 Mobile-optimized interface with drag support

Join discord for updates: discord.gg/cF8YeDPt2G]], detectedCount, #detectedSummitAreas, maxCheckpoints))
    end)
    
    createButton(welcomeSection, "Copy Discord Link", "Get support and updates", function()
        setclipboard("https://discord.gg/cF8YeDPt2G")
        showDialog("Success", "Discord link copied to clipboard!", {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    -- AUTO TAB
    local autoCheckpointSection = createSection(autoFrame, "Auto Checkpoint", "Automatic checkpoint touching system")
    
    createToggle(autoCheckpointSection, "Smart Auto Checkpoint", "FIXED: Now properly detects numeric checkpoints (1, 2, 3, etc.)", false, function(value)
        autoCheckpointEnabled = value
        if value then
            retryAttempts = 0
            scanWorkspaceForCheckpoints()
            task.spawn(autoCheckpointLoop)
        end
    end)
    
    createToggle(autoCheckpointSection, "Auto Respawn (Optional)", "Automatically respawn when needed (Optional enhancement)", false, function(value)
        autoRespawnEnabled = value
        if value then
            showDialog("Auto Respawn", "🔄 Auto Respawn enabled for enhanced reliability.", {
                {Title = "OK", Variant = "Primary", Callback = function() end}
            })
        end
    end)
    
    local manualSection = createSection(autoFrame, "Manual Controls", "Manual checkpoint controls")
    
    createButton(manualSection, "Test Touch Method", "Test different touch methods on next checkpoint", function()
        scanWorkspaceForCheckpoints()
        updateCurrentIndex()
        
        local playerCheckpoint = getPlayerCheckpointValue()
        local nextCheckpointNumber = playerCheckpoint + 1
        local nextCheckpoint = detectedCheckpoints[nextCheckpointNumber]
        
        if not nextCheckpoint then
            showDialog("Test Failed", "❌ Next checkpoint not found: " .. nextCheckpointNumber, {
                {Title = "OK", Variant = "Primary", Callback = function() end}
            })
            return
        end
        
        if not player.Character then
            showDialog("Test Failed", "❌ Character not found", {
                {Title = "OK", Variant = "Primary", Callback = function() end}
            })
            return
        end
        
        local character = player.Character
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        
        local testResults = {}
        
        -- Test methods...
        local method1Success = false
        pcall(function()
            firetouchinterest(humanoidRootPart, nextCheckpoint, 0)
            task.wait(0.1)
            firetouchinterest(humanoidRootPart, nextCheckpoint, 1)
            method1Success = true
        end)
        table.insert(testResults, "Method 1 (Standard): " .. (method1Success and "✅" or "❌"))
        
        task.wait(0.5)
        
        local method2Success = false
        pcall(function()
            firetouchinterest(nextCheckpoint, humanoidRootPart, 0)
            task.wait(0.1)
            firetouchinterest(nextCheckpoint, humanoidRootPart, 1)
            method2Success = true
        end)
        table.insert(testResults, "Method 2 (Reverse): " .. (method2Success and "✅" or "❌"))
        
        task.wait(0.5)
        
        local method3Success = false
        pcall(function()
            local originalPosition = humanoidRootPart.CFrame
            humanoidRootPart.CFrame = nextCheckpoint.CFrame + Vector3.new(0, 5, 0)
            task.wait(0.1)
            firetouchinterest(humanoidRootPart, nextCheckpoint, 0)
            task.wait(0.1)
            firetouchinterest(humanoidRootPart, nextCheckpoint, 1)
            task.wait(0.1)
            humanoidRootPart.CFrame = originalPosition
            method3Success = true
        end)
        table.insert(testResults, "Method 3 (Teleport): " .. (method3Success and "✅" or "❌"))
        
        local resultText = "🧪 TOUCH METHOD TEST RESULTS\n\n"
        resultText = resultText .. "Target: " .. nextCheckpoint.Name .. " (CP" .. nextCheckpointNumber .. ")\n\n"
        
        for _, result in ipairs(testResults) do
            resultText = resultText .. result .. "\n"
        end
        
        resultText = resultText .. "\n💡 firetouchinterest available: " .. (firetouchinterest and "✅" or "❌")
        resultText = resultText .. "\n💡 TouchInterest found: " .. (nextCheckpoint:FindFirstChild("TouchInterest") and "✅" or "❌")
        
        showDialog("Touch Method Test", resultText, {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    createButton(manualSection, "Rescan Workspace", "Manually rescan workspace for checkpoints", function()
        scanWorkspaceForCheckpoints()
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        showDialog("Workspace Scanned", string.format("🔍 Scan Complete!\n\n📍 Found %d checkpoints\n🎯 Found %d summit areas\n🏁 Max checkpoint: %d\n\n✨ Numeric checkpoints (1,2,3) now properly detected!", 
            detectedCount,
            #detectedSummitAreas,
            maxCheckpoints), {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    createButton(manualSection, "Touch Next Checkpoint", "Touch the next checkpoint in sequence", function()
        scanWorkspaceForCheckpoints()
        updateCurrentIndex()
        if currentCheckpointIndex <= maxCheckpoints then
            local success, message = touchSingleCheckpoint(currentCheckpointIndex)
            if success then
                showDialog("Success", "✅ Checkpoint " .. currentCheckpointIndex .. " touched successfully!", {
                    {Title = "OK", Variant = "Primary", Callback = function() end}
                })
            else
                showDialog("Failed", "❌ " .. message, {
                    {Title = "OK", Variant = "Primary", Callback = function() end}
                })
            end
        else
            touchSummitArea()
        end
    end)
    
    createButton(manualSection, "Touch Summit Area", "Touch any detected summit area", function()
        scanWorkspaceForCheckpoints()
        touchSummitArea()
    end)
    
    createButton(manualSection, "Manual Respawn", "Manually respawn character", function()
        if player.Character then
            player.Character:BreakJoints()
        end
        player:LoadCharacter()
        showDialog("Respawn", "🔄 Character respawned!", {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    local statusSection = createSection(autoFrame, "Status", "Current checkpoint status")
    local statusLabel = createTextLabel(statusSection, "Checkpoint Status", "Loading status...")
    local progressLabel = createTextLabel(statusSection, "Progress Info", "Initializing smart detection...")
    local detectionLabel = createTextLabel(statusSection, "Detection Info", "Scanning workspace...")
    
    -- Status update function
    local function updateStatus()
        local playerCheckpoint = getPlayerCheckpointValue()
        local nextCheckpointNumber = playerCheckpoint + 1
        local nextCheckpoint = detectedCheckpoints[nextCheckpointNumber]
        
        local statusText = string.format([[Current Checkpoint: %d/%d
Next Target: %s
Auto Checkpoint: %s
Auto Respawn: %s
Auto Delay: %.1fs
Next CP Status: %s
Retry Attempts: %d/%d]], 
            playerCheckpoint, 
            maxCheckpoints,
            nextCheckpointNumber <= maxCheckpoints and "CP" .. nextCheckpointNumber or "Summit Area",
            autoCheckpointEnabled and "✅ ON" or "❌ OFF",
            autoRespawnEnabled and "✅ ON" or "❌ OFF",
            autoCheckpointDelay,
            nextCheckpoint and nextCheckpoint:FindFirstChild("TouchInterest") and "✅ Ready" or "❌ Not Available",
            retryAttempts,
            maxRetryAttempts
        )
        
        statusLabel.setDescription(statusText)
        
        -- Progress info
        local availableCount = 0
        local missingCheckpoints = {}
        
        for i = nextCheckpointNumber, maxCheckpoints do
            local cp = detectedCheckpoints[i]
            if cp and cp:FindFirstChild("TouchInterest") then
                availableCount = availableCount + 1
            else
                table.insert(missingCheckpoints, i)
            end
        end
        
        local progressText = string.format([[Available Checkpoints: %d
Progress: %.1f%%
Mode: %s
Sequential Mode: ✅ ENABLED
Next CP Status: %s
Missing CPs: %s]], 
            availableCount,
            maxCheckpoints > 0 and (playerCheckpoint / maxCheckpoints) * 100 or 0,
            playerCheckpoint >= maxCheckpoints and "🏆 Ready for Summit!" or "🚀 In Progress",
            nextCheckpoint and nextCheckpoint:FindFirstChild("TouchInterest") and "✅ Ready" or "❌ Not Available",
            #missingCheckpoints > 0 and table.concat(missingCheckpoints, ", ") or "None"
        )
        
        progressLabel.setDescription(progressText)
        
        -- Detection info
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        
        local detectionText = string.format([[Detected Checkpoints: %d
Max Checkpoint: %d
Summit Areas: %d
Detection Mode: %s
Auto Delay: %.1fs
Supported Patterns: Numbers (1,2,3), CP, Checkpoint, Stage, Point, Puncak]], 
            detectedCount,
            maxCheckpoints,
            #detectedSummitAreas,
            "🎯 Sequential + Numeric Enhanced",
            autoCheckpointDelay
        )
        
        detectionLabel.setDescription(detectionText)
    end
    
    -- SETTINGS TAB
    local configSection = createSection(settingsFrame, "Configuration", "Script configuration")
    
    -- NEW: Auto Checkpoint Delay Slider
    createSlider(configSection, "Auto Checkpoint Delay", "Delay between checkpoint touches (0.1s - 10s)", 1, 0.1, 10, function(value)
        autoCheckpointDelay = value
        showDialog("Delay Updated", string.format("⏱️ Auto checkpoint delay set to %.1f seconds\n\nThis controls how long to wait after successfully touching each checkpoint.", value), {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    createSlider(configSection, "Max Retry Attempts", "Maximum retry attempts before longer wait", 3, 1, 10, function(value)
        maxRetryAttempts = value
    end)
    
    createButton(configSection, "Force Rescan All", "Force complete workspace rescan", function()
        scanWorkspaceForCheckpoints()
        updateCurrentIndex()
        retryAttempts = 0
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        showDialog("Force Rescan Complete", string.format("🔄 Complete rescan finished!\n\n📍 Checkpoints: %d\n🎯 Summit Areas: %d\n🏁 Max: %d\n\n✨ Numeric detection enhanced!", 
            detectedCount,
            #detectedSummitAreas,
            maxCheckpoints), {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    createButton(configSection, "Show Detection Report", "Show detailed detection results", function()
        scanWorkspaceForCheckpoints()
        
        local reportText = "🔍 SMART DETECTION REPORT (FIXED)\n\n"
        
        reportText = reportText .. "📊 SUMMARY:\n"
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        reportText = reportText .. "• Total Checkpoints: " .. detectedCount .. "\n"
        reportText = reportText .. "• Max Checkpoint: " .. maxCheckpoints .. "\n"
        reportText = reportText .. "• Summit Areas: " .. #detectedSummitAreas .. "\n"
        reportText = reportText .. "• Auto Delay: " .. string.format("%.1fs", autoCheckpointDelay) .. "\n\n"
        
        reportText = reportText .. "🎯 SUPPORTED PATTERNS (ENHANCED):\n"
        reportText = reportText .. "• ✨ Pure Numbers: 1, 2, 3, 4, etc. (FIXED!)\n"
        reportText = reportText .. "• Prefixed: CP1, Checkpoint1, Stage1, Point1\n"
        reportText = reportText .. "• Summit: Summit, Puncak, Finish, End, Final, Win\n\n"
        
        reportText = reportText .. "📍 DETECTED CHECKPOINTS:\n"
        if next(detectedCheckpoints) then
            local sortedNums = {}
            for num, _ in pairs(detectedCheckpoints) do
                table.insert(sortedNums, num)
            end
            table.sort(sortedNums)
            
            for _, num in ipairs(sortedNums) do
                local cp = detectedCheckpoints[num]
                local hasTouch = cp:FindFirstChild("TouchInterest") and "✅" or "❌"
                local parentName = cp.Parent and cp.Parent.Name or "nil"
                reportText = reportText .. "• " .. num .. " (" .. cp.Name .. ") in " .. parentName .. " " .. hasTouch .. "\n"
            end
        else
            reportText = reportText .. "• No checkpoints detected\n"
        end
        
        reportText = reportText .. "\n🎯 SUMMIT AREAS:\n"
        if #detectedSummitAreas > 0 then
            for _, summit in ipairs(detectedSummitAreas) do
                local hasTouch = summit:FindFirstChild("TouchInterest") and "✅" or "❌"
                local parentName = summit.Parent and summit.Parent.Name or "nil"
                reportText = reportText .. "• " .. summit.Name .. " in " .. parentName .. " " .. hasTouch .. "\n"
            end
        else
            reportText = reportText .. "• No summit areas detected\n"
        end
        
        reportText = reportText .. "\n📈 PLAYER STATUS:\n"
        reportText = reportText .. "• Current Stage: " .. getPlayerCheckpointValue() .. "/" .. maxCheckpoints .. "\n"
        reportText = reportText .. "• Next Target: " .. currentCheckpointIndex .. "\n"
        reportText = reportText .. "• Ready for Summit: " .. (getPlayerCheckpointValue() >= maxCheckpoints and "Yes" or "No") .. "\n"
        reportText = reportText .. "• Auto Delay: " .. string.format("%.1fs", autoCheckpointDelay) .. "\n"
        
        reportText = reportText .. "\n🔧 LATEST FEATURES:\n"
        reportText = reportText .. "• ⏱️ Customizable auto checkpoint delay (0.1s - 10s)\n"
        reportText = reportText .. "• ✅ Pure numeric checkpoint detection (1,2,3) now works!\n"
        reportText = reportText .. "• ✅ Enhanced pattern matching priority\n"
        reportText = reportText .. "• ✅ Better validation logic\n"
        reportText = reportText .. "• ✅ More frequent rescans for reliability\n"
        reportText = reportText .. "• ✅ Comprehensive workspace scanning (not just folders)\n"
        reportText = reportText .. "• ✅ Scans ALL containers and services\n"
        reportText = reportText .. "• ✅ Mobile-optimized interface with drag support\n"
        
        showDialog("Enhanced Detection Report", reportText, {
            {Title = "OK", Variant = "Primary", Callback = function() end}
        })
    end)
    
    -- Start status updates
    statusUpdateConnection = RunService.Heartbeat:Connect(function()
        updateStatus()
    end)
    
    -- Enhanced leaderstats monitoring
    local function setupSmartLeaderstatsMonitoring()
        local leaderstats = player:WaitForChild("leaderstats", 10)
        if leaderstats then
            local commonNames = {"Stage", "stage", "STAGE", "Checkpoint", "checkpoint", "CHECKPOINT", "Level", "level", "LEVEL"}
            
            for _, name in ipairs(commonNames) do
                local checkpointValue = leaderstats:FindFirstChild(name)
                if checkpointValue then
                    checkpointValue.Changed:Connect(function(newValue)
                        currentCheckpointIndex = newValue + 1
                        if currentCheckpointIndex > maxCheckpoints then
                            currentCheckpointIndex = maxCheckpoints
                        end
                        
                        retryAttempts = 0
                        
                        if newValue >= maxCheckpoints and autoCheckpointEnabled then
                            task.spawn(function()
                                task.wait(0.5)
                                touchSummitArea()
                            end)
                        end
                    end)
                    break
                end
            end
        end
    end
    
    -- Character spawn handling
    player.CharacterAdded:Connect(function()
        task.wait(3)
        scanWorkspaceForCheckpoints()
        setupSmartLeaderstatsMonitoring()
        updateCurrentIndex()
        retryAttempts = 0
        
        if autoCheckpointEnabled then
            task.spawn(autoCheckpointLoop)
        end
    end)
    
    -- Initial load
    if player.Character then
        task.spawn(function()
            task.wait(2)
            scanWorkspaceForCheckpoints()
            setupSmartLeaderstatsMonitoring()
            updateCurrentIndex()
            retryAttempts = 0
            
            if autoCheckpointEnabled then
                task.spawn(autoCheckpointLoop)
            end
        end)
    end
    
    -- Cleanup
    local function cleanup()
        autoCheckpointEnabled = false
        if autoCheckpointConnection then
            autoCheckpointConnection:Disconnect()
        end
        if statusUpdateConnection then
            statusUpdateConnection:Disconnect()
        end
    end
    
    Players.PlayerRemoving:Connect(function(player_leaving)
        if player_leaving == player then
            cleanup()
        end
    end)
    
    -- Initial welcome dialog
    task.spawn(function()
        task.wait(3)
        scanWorkspaceForCheckpoints()
        
        local screenSize = workspace.CurrentCamera.ViewportSize
        local isMobile = screenSize.X < 800 or screenSize.Y < 600
        
        local detectedCount = 0
        for _, _ in pairs(detectedCheckpoints) do
            detectedCount = detectedCount + 1
        end
        
        local deviceType = isMobile and "📱 Mobile Device Detected" or "🖥️ Desktop Device Detected"
        
        showDialog("Smart Checkpoint System - Auto-Scaled", string.format("🤖 Enhanced Detection Complete!\n\n%s\n✅ Auto-scaled interface for your device\n✅ FIXED: Pure numeric checkpoints (1, 2, 3, etc.)\n✅ Touch-friendly controls\n\n📍 Detected: %d checkpoints\n🎯 Summit areas: %d\n🏁 Max checkpoint: %d\n\n🔧 Features:\n• Responsive design\n• Drag to move GUI\n• Click (-) to minimize\n• Auto-scaling text and buttons\n\n💡 Join discord for support!", 
            deviceType,
            detectedCount,
            #detectedSummitAreas,
            maxCheckpoints), {
            {
                Title = "Copy Discord",
                Variant = "Primary",
                Callback = function()
                    setclipboard("https://discord.gg/cF8YeDPt2G")
                end,
            },
            {
                Title = "OK",
                Variant = "Ghost",
                Callback = function() end,
            }
        })
    end)
end

-- Initialize the GUI
createMainGUI()
