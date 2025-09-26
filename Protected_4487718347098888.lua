local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xenlua/Xens/refs/heads/main/ui/Avantrix.lua"))() 
local FlagsManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/xenlua/Xens/refs/heads/main/ui/Flags"))()

local LPH_JIT_MAX = function(...) return(...) end;
local LPH_NO_VIRTUALIZE = function(...) return(...) end;
local LPH_CRASH = function(...) while task.wait() do game:GetService("ScriptContext"):SetTimeout(math.huge);while true do while true do while true do while true do while true do while true do while true do while true do print("noob") end end end end end end end end end end;
local LRM_UserNote = "Owner"
local LRM_ScriptVersion = "v1.2"
local ClonedPrint = print

if LPH_OBFUSCATED then
    ClonedPrint = print
    print = function(...)end
    warn = function(...)end

    local PreventSkidsToMakeGayThings = loadstring(game:HttpGet("https://raw.githubusercontent.com/Hosvile/InfiniX/a40a158d22fd4f4733beb2f67379866ccb17906f/Library/Anti/AntiDebug/main.lua", true))()

    if not (type(PreventSkidsToMakeGayThings) == "table") then
        LPH_CRASH()
    end
end

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Format version function
function formatVersion(version)
    local formattedVersion = "v" .. version:sub(2):gsub(".", "%0.")
    return formattedVersion:sub(1, #formattedVersion - 1)
end

-- Initialize main GUI
local main = lib:Load({
    Title = 'Mount Atin Script '..formatVersion(LRM_ScriptVersion)..' | ' .. gradient("Avantrix").. " | ",
    ToggleButton = "rbxassetid://100227182680708",
})

-- Create tabs
local tabs = {
    Welcome = main:AddTab("Information"),
    Main = main:AddTab("Mount Atin"),
    Settings = main:AddTab("Settings"),
}

main:SelectTab()

-- Create sections
local sections = {
    Welcome = tabs.Welcome:AddSection({Defualt = true, Locked = true}),
    AutoClimb = tabs.Main:AddSection({Title = "Auto Climb", Description = "Automatic checkpoint climbing", Defualt = true, Locked = false}),
    ManualControls = tabs.Main:AddSection({Title = "Manual Controls", Description = "Manual checkpoint controls", Defualt = false, Locked = false}),
    Status = tabs.Main:AddSection({Title = "Status", Description = "Current climbing status", Defualt = false, Locked = false}),
    Configuration = tabs.Settings:AddSection({Title = "Configuration", Description = "Script configuration", Defualt = true, Locked = false}),
}

-- Variables
local var = {}

-- Initialize welcome paragraph
var.WelcomeParagraph = sections.Welcome:AddParagraph({
    Title = gradient("Loading..."), 
    Description = "Please wait..\nIf you've been stuck on this for a long time please join our discord and report it.\nYou could also try:\n- Re-execute\n- Rejoin"
})

var.WelcomeParagraph:SetTitle(gradient("Welcome to Mount Atin Script!"))
var.WelcomeParagraph:SetDesc([[<font color="rgb(255,255,255)">NEWS:</font>
[+] Mount Atin Auto Checkpoint System
[+] Smart Puncak Detection (Summit)
[+] Auto Climb with Custom Delays
[+] Manual Checkpoint Controls
[+] Real-time Climbing Status
[+] Backup Touch Methods
[+] Character Spawn Auto-Run
[/] All features optimized for Mount Atin

<b><font color='rgb(255, 255, 255)'>----------------------------------------[Features]--------------------------------------</font></b>

<font color="rgb(255,255,255)">Version:</font> ]] .. formatVersion(LRM_ScriptVersion) .. [[

<font color="rgb(255,255,255)">Mount Atin Features:</font>
• Auto Climb - Automatically climb all checkpoints to summit
• Smart Sorting - Checkpoints sorted numerically (1,2,3...Puncak)
• Puncak Detection - Automatically detects and saves summit for last
• Custom Delays - Configurable delay between checkpoints
• Backup Methods - Multiple touch methods for reliability
• Auto Start - Automatically starts when character spawns
• Manual Controls - Touch specific checkpoints manually
• Status Display - Real-time climbing progress

<font color="rgb(255,255,255)">How it works:</font>
1. Detects all checkpoints in workspace["Obby Checkpoints"].Checkpoints
2. Sorts numbered checkpoints (1, 2, 3, etc.) in order
3. Saves "Puncak" checkpoint for the final summit
4. Uses firetouchinterest or backup position method
5. Automatically runs on character spawn

<font color="rgb(255,255,255)">Instructions:</font>
1. Enable "Auto Climb" to automatically climb to summit
2. Adjust delay between checkpoints in settings
3. Use manual controls for specific operations
4. Monitor progress in Status section
5. Script auto-runs when you spawn/respawn

<font color="rgb(255,255,255)">Discord:</font> discord.gg/cF8YeDPt2G]])

-- Add Discord button
sections.Welcome:AddButton({
    Title = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/cF8YeDPt2G")
        lib:Dialog({
            Title = "Success",
            Content = "Discord link copied to clipboard!",
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
    end,
})

-- Game Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local checkpointsFolder = workspace["Obby Checkpoints"].Checkpoints

-- Script Variables
local autoClimbEnabled = false
local checkpointDelay = 0.1
local autoClimbConnection = nil
local statusUpdateConnection = nil
local currentCheckpointIndex = 0
local totalCheckpoints = 0
local isClimbing = false

-- Status Paragraphs
var.StatusParagraph = sections.Status:AddParagraph({
    Title = "Climbing Status",
    Description = "Loading status..."
})

var.ProgressParagraph = sections.Status:AddParagraph({
    Title = "Progress Info",
    Description = "Initializing..."
})

var.CheckpointsParagraph = sections.Status:AddParagraph({
    Title = "Checkpoints Info",
    Description = "Scanning checkpoints..."
})

-- Function untuk mendapatkan semua checkpoints dan mengurutkannya
local function getAllCheckpoints()
    local regularCheckpoints = {}
    local puncakCheckpoint = nil
    
    for _, checkpoint in pairs(checkpointsFolder:GetChildren()) do
        if checkpoint:IsA("BasePart") and checkpoint:FindFirstChild("TouchInterest") then
            if checkpoint.Name == "Puncak" then
                puncakCheckpoint = checkpoint
            else
                table.insert(regularCheckpoints, checkpoint)
            end
        end
    end
    
    -- Sort checkpoint biasa berdasarkan nama (1, 2, 3, etc.)
    table.sort(regularCheckpoints, function(a, b)
        local numA = tonumber(a.Name) or 0
        local numB = tonumber(b.Name) or 0
        return numA < numB
    end)
    
    -- Gabungkan: checkpoint biasa dulu, Puncak terakhir
    local allCheckpoints = {}
    for _, checkpoint in ipairs(regularCheckpoints) do
        table.insert(allCheckpoints, checkpoint)
    end
    if puncakCheckpoint then
        table.insert(allCheckpoints, puncakCheckpoint)
    end
    
    return allCheckpoints, #regularCheckpoints, puncakCheckpoint ~= nil
end

-- Function untuk menyentuh checkpoint dengan berbagai metode
local function touchCheckpoint(checkpoint, humanoidRootPart)
    local success = false
    
    -- Metode 1: firetouchinterest (untuk exploit environment)
    if firetouchinterest then
        firetouchinterest(humanoidRootPart, checkpoint, 0) -- Touch start
        task.wait(0.05)
        firetouchinterest(humanoidRootPart, checkpoint, 1) -- Touch end
        success = true
    end
    
    -- Metode 2: Manual touch simulation (backup method)
    if not success and checkpoint.TouchInterest then
        -- Simulasi menyentuh dengan menggerakkan character
        local originalPos = humanoidRootPart.CFrame
        humanoidRootPart.CFrame = checkpoint.CFrame + Vector3.new(0, checkpoint.Size.Y/2 + 5, 0)
        task.wait(0.05)
        humanoidRootPart.CFrame = originalPos
        success = true
    end
    
    return success
end

-- Function untuk auto climb semua checkpoints
local function autoClimbWithDelay(delayTime)
    if isClimbing then return end
    isClimbing = true
    
    delayTime = delayTime or checkpointDelay
    
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local checkpoints, regularCount, hasPuncak = getAllCheckpoints()
    totalCheckpoints = #checkpoints
    currentCheckpointIndex = 0
    
    for i, checkpoint in ipairs(checkpoints) do
        if not autoClimbEnabled then break end
        
        currentCheckpointIndex = i
        local success = touchCheckpoint(checkpoint, humanoidRootPart)
        
        if success then
            -- Show success message for important checkpoints
            if checkpoint.Name == "Puncak" then
                lib:Dialog({
                    Title = "Summit Reached! 🏔️",
                    Content = "🎉 Congratulations! You've reached the summit of Mount Atin!",
                    Buttons = {
                        {
                            Title = "Awesome!",
                            Variant = "Primary",
                            Callback = function() end,
                        }
                    }
                })
            end
        end
        
        task.wait(delayTime)
    end
    
    isClimbing = false
    
    if autoClimbEnabled and currentCheckpointIndex >= totalCheckpoints then
        lib:Dialog({
            Title = "Climb Complete! 🎯",
            Content = "✅ Successfully climbed all " .. totalCheckpoints .. " checkpoints!\n🏔️ Mount Atin conquered!",
            Buttons = {
                {
                    Title = "Great!",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
    end
end

-- Function untuk menyentuh checkpoint tertentu berdasarkan nomor
local function touchSpecificCheckpoint(checkpointNumber)
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local targetCheckpoint = checkpointsFolder:FindFirstChild(tostring(checkpointNumber))
    
    if targetCheckpoint and targetCheckpoint:FindFirstChild("TouchInterest") then
        local success = touchCheckpoint(targetCheckpoint, humanoidRootPart)
        return success, targetCheckpoint.Name
    end
    
    return false, "Not found"
end

-- Function untuk menyentuh Puncak
local function touchPuncak()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local puncakCheckpoint = checkpointsFolder:FindFirstChild("Puncak")
    
    if puncakCheckpoint and puncakCheckpoint:FindFirstChild("TouchInterest") then
        local success = touchCheckpoint(puncakCheckpoint, humanoidRootPart)
        if success then
            lib:Dialog({
                Title = "Summit Reached! 🏔️",
                Content = "🎉 You've successfully reached the Puncak (Summit) of Mount Atin!",
                Buttons = {
                    {
                        Title = "Amazing!",
                        Variant = "Primary",
                        Callback = function() end,
                    }
                }
            })
        end
        return success
    else
        lib:Dialog({
            Title = "Puncak Not Found",
            Content = "❌ Puncak checkpoint not found or not accessible",
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
        return false
    end
end

-- Status Update Function
local function updateStatus()
    local checkpoints, regularCount, hasPuncak = getAllCheckpoints()
    totalCheckpoints = #checkpoints
    
    local statusText = string.format([[<font color="rgb(100,255,100)">Current Progress:</font> %d/%d checkpoints
<font color="rgb(255,255,100)">Climbing Status:</font> %s
<font color="rgb(100,200,255)">Auto Climb:</font> %s
<font color="rgb(255,150,100)">Delay Setting:</font> %.1fs]], 
        currentCheckpointIndex, 
        totalCheckpoints,
        isClimbing and "🧗‍♂️ Climbing..." or (autoClimbEnabled and "⏳ Ready" or "⏸️ Stopped"),
        autoClimbEnabled and "✅ ON" or "❌ OFF",
        checkpointDelay
    )
    
    var.StatusParagraph:SetDesc(statusText)
    
    local progressPercent = totalCheckpoints > 0 and (currentCheckpointIndex / totalCheckpoints) * 100 or 0
    local progressText = string.format([[<font color="rgb(150,255,150)">Progress:</font> %.1f%% Complete
<font color="rgb(255,200,150)">Status:</font> %s
<font color="rgb(200,150,255)">Next Target:</font> %s]], 
        progressPercent,
        currentCheckpointIndex >= totalCheckpoints and "🏆 Summit Reached!" or "🚀 Climbing in Progress",
        currentCheckpointIndex < totalCheckpoints and (currentCheckpointIndex < regularCount and "Checkpoint " .. (currentCheckpointIndex + 1) or "Puncak (Summit)") or "Complete!"
    )
    
    var.ProgressParagraph:SetDesc(progressText)
    
    local checkpointsText = string.format([[<font color="rgb(200,200,200)">Total Checkpoints:</font> %d
<font color="rgb(150,255,150)">Regular Checkpoints:</font> %d
<font color="rgb(255,200,100)">Summit (Puncak):</font> %s
<font color="rgb(100,200,255)">All Accessible:</font> %s]], 
        totalCheckpoints,
        regularCount,
        hasPuncak and "✅ Found" or "❌ Not Found",
        totalCheckpoints > 0 and "✅ Ready" or "❌ No Checkpoints"
    )
    
    var.CheckpointsParagraph:SetDesc(checkpointsText)
end

-- Auto Climb Section
sections.AutoClimb:AddToggle("AutoClimb", {
    Title = "Auto Climb",
    Default = false,
    Description = "Automatically climb all checkpoints to reach the summit",
    Callback = function(value)
        autoClimbEnabled = value
        if value then
            task.spawn(function()
                autoClimbWithDelay(checkpointDelay)
            end)
            lib:Dialog({
                Title = "Auto Climb Started! 🧗‍♂️",
                Content = "🏔️ Starting automatic climb of Mount Atin!\n⏱️ Delay: " .. checkpointDelay .. "s between checkpoints",
                Buttons = {
                    {
                        Title = "Let's Climb!",
                        Variant = "Primary",
                        Callback = function() end,
                    }
                }
            })
        else
            isClimbing = false
            lib:Dialog({
                Title = "Auto Climb Stopped",
                Content = "⏹️ Auto climb has been stopped.",
                Buttons = {
                    {
                        Title = "OK",
                        Variant = "Primary",
                        Callback = function() end,
                    }
                }
            })
        end
    end,
})

sections.AutoClimb:AddButton({
    Title = "Instant Climb All",
    Description = "Instantly climb all checkpoints with minimal delay",
    Callback = function()
        autoClimbEnabled = true
        task.spawn(function()
            autoClimbWithDelay(0.05) -- Very fast delay
        end)
        lib:Dialog({
            Title = "Instant Climb! ⚡",
            Content = "🚀 Starting instant climb to the summit!",
            Buttons = {
                {
                    Title = "Go!",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
    end,
})

-- Manual Controls Section
sections.ManualControls:AddButton({
    Title = "Touch Puncak (Summit)",
    Description = "Directly touch the Puncak checkpoint",
    Callback = function()
        touchPuncak()
    end,
})


sections.ManualControls:AddButton({
    Title = "Show All Checkpoints",
    Description = "Display all available checkpoints",
    Callback = function()
        local checkpoints, regularCount, hasPuncak = getAllCheckpoints()
        local debugText = "🏔️ Mount Atin Checkpoints (" .. #checkpoints .. " total):\n\n"
        
        debugText = debugText .. "📋 Regular Checkpoints (" .. regularCount .. "):\n"
        for i, checkpoint in ipairs(checkpoints) do
            if checkpoint.Name ~= "Puncak" then
                local hasTouch = checkpoint:FindFirstChild("TouchInterest") and "✅" or "❌"
                debugText = debugText .. "• " .. checkpoint.Name .. " " .. hasTouch .. "\n"
            end
        end
        
        if hasPuncak then
            debugText = debugText .. "\n🏔️ Summit:\n• Puncak ✅\n"
        else
            debugText = debugText .. "\n❌ Puncak (Summit) not found\n"
        end
        
        debugText = debugText .. "\n📊 Status: " .. (isClimbing and "Currently Climbing" or "Ready to Climb")
        debugText = debugText .. "\n⏱️ Current Delay: " .. checkpointDelay .. "s"
        
        lib:Dialog({
            Title = "Mount Atin Checkpoints",
            Content = debugText,
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
    end,
})

sections.ManualControls:AddButton({
    Title = "Reset Progress",
    Description = "Reset climbing progress counter",
    Callback = function()
        currentCheckpointIndex = 0
        isClimbing = false
        lib:Dialog({
            Title = "Progress Reset",
            Content = "🔄 Climbing progress has been reset!",
            Buttons = {
                {
                    Title = "OK",
                    Variant = "Primary",
                    Callback = function() end,
                }
            }
        })
    end,
})

-- Configuration Section
sections.Configuration:AddSlider("CheckpointDelay", {
    Title = "Checkpoint Delay",
    Description = "Delay between touching checkpoints (seconds)",
    Default = 0.1,
    Min = 0.05,
    Max = 2.0,
    Increment = 0.05,
    Callback = function(value)
        checkpointDelay = value
    end,
})

-- Start status updates
statusUpdateConnection = RunService.Heartbeat:Connect(function()
    updateStatus()
end)

-- Auto-run saat character spawn
player.CharacterAdded:Connect(function()
    task.wait(2) -- Wait for character to fully load
    currentCheckpointIndex = 0
    isClimbing = false
    
    -- Check if auto start is enabled
    if FlagsManager:GetFlag("AutoStartOnSpawn") ~= false then -- Default true
        task.wait(0.5) -- Additional small delay
        autoClimbEnabled = true
        task.spawn(function()
            autoClimbWithDelay(checkpointDelay)
        end)
    end
end)

-- Jalankan sekali saat script dimuat
if player.Character then
    task.spawn(function()
        task.wait(0.5) -- Small delay for initial load
        currentCheckpointIndex = 0
        isClimbing = false
        
        -- Auto start on first load if enabled
        if FlagsManager:GetFlag("AutoStartOnSpawn") ~= false then
            autoClimbEnabled = true
            autoClimbWithDelay(checkpointDelay)
        end
    end)
end

-- Config System
FlagsManager:SetLibrary(lib)
FlagsManager:SetIgnoreIndexes({})
FlagsManager:SetFolder("Avantrix/MountAtinScript")
FlagsManager:InitSaveSystem(tabs.Settings)

-- Cleanup function
local function cleanup()
    autoClimbEnabled = false
    isClimbing = false
    if autoClimbConnection then
        autoClimbConnection:Disconnect()
    end
    if statusUpdateConnection then
        statusUpdateConnection:Disconnect()
    end
end

-- Cleanup when player leaves
Players.PlayerRemoving:Connect(function(player_leaving)
    if player_leaving == player then
        cleanup()
    end
end)
