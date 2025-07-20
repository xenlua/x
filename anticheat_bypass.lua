--[[
    Enhanced Bypasses for Popular Roblox Anticheats
    Supports: Adonis, Vanguard, Sentinel, Hyperion, Aegis, and more
    With Webhook Logging Support
]]

-- Configuration
local WEBHOOK_URL = "YOUR_WEBHOOK_URL_HERE" -- Replace with your Discord webhook URL
local ENABLE_WEBHOOK = false -- Set to true to enable webhook logging

-- Initialize shared variables if they don't exist
local wax = _G.wax or {}
_G.wax = wax

if not wax.shared then
    wax.shared = {}
end

-- Initialize required components
if not wax.shared.SaveManager then
    wax.shared.SaveManager = {
        GetState = function(key)
            return true -- Default to enabled
        end
    }
end

if not wax.shared.Hooks then
    wax.shared.Hooks = {}
end

if not wax.shared.Hooking then
    wax.shared.Hooking = {
        HookFunction = function(original, replacement)
            return replacement
        end
    }
end

-- Initialize anticheat status
wax.shared.AnticheatDisabled = false
wax.shared.AnticheatName = "N/A"
wax.shared.DetectedAnticheats = {}

-- Webhook logging function
local function sendWebhook(title, description, color)
    if not ENABLE_WEBHOOK or not WEBHOOK_URL or WEBHOOK_URL == "YOUR_WEBHOOK_URL_HERE" then
        return
    end
    
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        local embed = {
            title = title,
            description = description,
            color = color or 3447003, -- Blue default
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            fields = {
                {
                    name = "Player",
                    value = player.Name .. " (" .. player.UserId .. ")",
                    inline = true
                },
                {
                    name = "Game",
                    value = game.PlaceId,
                    inline = true
                }
            }
        }
        
        local data = {
            embeds = {embed}
        }
        
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

local BypassState = wax.shared.SaveManager:GetState("AnticheatBypass")
local BypassEnabled = if typeof(BypassState) == "boolean" then BypassState else true

if not BypassEnabled then
    sendWebhook("🔒 Anticheat Bypass", "Disabled by user settings", 16711680) -- Red
    return
end

-- Check if required functions exist
if not getreg or not getgc or not isfunctionhooked then
    sendWebhook("⚠️ Anticheat Bypass", "Required functions not available (getreg, getgc, or isfunctionhooked)", 16776960) -- Yellow
    return
end

sendWebhook("🛡️ Anticheat Bypass", "Starting detection and bypass process...", 3447003) -- Blue

-- Anticheat Detection Patterns
local AnticheatPatterns = {
    Adonis = {
        threads = {".Core.Anti", ".Plugins.Anti_Cheat", "Adonis_Anti", "Anti", "Core.Anti", "Plugins.Anti_Cheat"},
        functions = {"Detected", "AntiCheat", "Detection", "Check", "Kick", "Ban"},
        remotes = {"Adonis_Remote", "AC_Remote", "Remote", "Event"},
        keywords = {"adonis", "anti", "cheat", "detection", "core", "admin"}
    },
    Vanguard = {
        threads = {".Vanguard", ".VG_Anti", ".Security"},
        functions = {"VanguardDetected", "SecurityBreach", "VG_Check"},
        remotes = {"VanguardRemote", "SecurityRemote"},
        keywords = {"vanguard", "security", "breach"}
    },
    Sentinel = {
        threads = {".Sentinel", ".SentinelAC", ".Guard"},
        functions = {"SentinelDetected", "GuardCheck", "SentinelScan"},
        remotes = {"SentinelRemote", "GuardRemote"},
        keywords = {"sentinel", "guard", "scan"}
    },
    Hyperion = {
        threads = {".Hyperion", ".HyperionAC", ".Hyper"},
        functions = {"HyperionDetected", "HyperCheck", "HyperScan"},
        remotes = {"HyperionRemote", "HyperRemote"},
        keywords = {"hyperion", "hyper", "detection"}
    },
    Aegis = {
        threads = {".Aegis", ".AegisAC", ".Shield"},
        functions = {"AegisDetected", "ShieldBreach", "AegisCheck"},
        remotes = {"AegisRemote", "ShieldRemote"},
        keywords = {"aegis", "shield", "protection"}
    },
    Kronos = {
        threads = {".Kronos", ".KronosAC", ".Time"},
        functions = {"KronosDetected", "TimeCheck", "KronosScan"},
        remotes = {"KronosRemote", "TimeRemote"},
        keywords = {"kronos", "time", "temporal"}
    },
    Phoenix = {
        threads = {".Phoenix", ".PhoenixAC", ".Fire"},
        functions = {"PhoenixDetected", "FireCheck", "PhoenixScan"},
        remotes = {"PhoenixRemote", "FireRemote"},
        keywords = {"phoenix", "fire", "rebirth"}
    },
    Nexus = {
        threads = {".Nexus", ".NexusAC", ".Core"},
        functions = {"NexusDetected", "CoreCheck", "NexusScan"},
        remotes = {"NexusRemote", "CoreRemote"},
        keywords = {"nexus", "core", "central"}
    }
}

-- Enhanced Thread Detection
local function detectAnticheatThreads()
    local detectedAnticheats = {}
    
    pcall(function()
        for _, thread in getreg() do
            if typeof(thread) ~= "thread" then
                continue
            end

            local success, source = pcall(debug.info, thread, 1, "s")
            
            if success and source then
                for anticheatName, patterns in pairs(AnticheatPatterns) do
                    for _, pattern in pairs(patterns.threads) do
                        if string.find(source:lower(), pattern:lower()) or source == pattern then
                            if not table.find(detectedAnticheats, anticheatName) then
                                table.insert(detectedAnticheats, anticheatName)
                            end
                        end
                    end
                end
                
                -- Additional Adonis specific checks
                if string.find(source:lower(), "anti") or string.find(source:lower(), "adonis") or string.find(source:lower(), "core") then
                    if not table.find(detectedAnticheats, "Adonis") then
                        table.insert(detectedAnticheats, "Adonis")
                    end
                end
            end
        end
    end)
    
    return detectedAnticheats
end

-- Enhanced Function Detection
local function detectAnticheatFunctions()
    local detectedAnticheats = {}
    
    pcall(function()
        for _, value in getgc(true) do
            if typeof(value) ~= "table" then
                continue
            end

            -- Check for Adonis specific detection
            local detectedFunction = rawget(value, "Detected")
            if typeof(detectedFunction) == "function" then
                local success, source = pcall(debug.info, detectedFunction, "s")
                if success and source then
                    if string.find(source:lower(), "anti") or string.find(source:lower(), "core") then
                        if not table.find(detectedAnticheats, "Adonis") then
                            table.insert(detectedAnticheats, "Adonis")
                        end
                    end
                end
            end

            for anticheatName, patterns in pairs(AnticheatPatterns) do
                for _, funcName in pairs(patterns.functions) do
                    local funcRef = rawget(value, funcName)
                    if typeof(funcRef) == "function" then
                        local success, source = pcall(debug.info, funcRef, "s")
                        
                        if success then
                            -- Check if source matches any thread patterns
                            for _, threadPattern in pairs(patterns.threads) do
                                if string.find(source:lower(), threadPattern:lower()) or source == threadPattern then
                                    if not table.find(detectedAnticheats, anticheatName) then
                                        table.insert(detectedAnticheats, anticheatName)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return detectedAnticheats
end

-- Enhanced Remote Detection
local function detectAnticheatRemotes()
    local detectedAnticheats = {}
    
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        local function scanFolder(folder, folderName)
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    for anticheatName, patterns in pairs(AnticheatPatterns) do
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower()) then
                                if not table.find(detectedAnticheats, anticheatName) then
                                    table.insert(detectedAnticheats, anticheatName)
                                end
                            end
                        end
                        
                        -- Check keywords in remote names
                        for _, keyword in pairs(patterns.keywords) do
                            if string.find(child.Name:lower(), keyword) then
                                if not table.find(detectedAnticheats, anticheatName) then
                                    table.insert(detectedAnticheats, anticheatName)
                                end
                            end
                        end
                    end
                    
                    -- Special check for any remote with "Remote" in name (likely Adonis)
                    if string.find(child.Name:lower(), "remote") then
                        if not table.find(detectedAnticheats, "Adonis") then
                            table.insert(detectedAnticheats, "Adonis")
                        end
                    end
                end
                
                -- Recursively scan subfolders
                if child:IsA("Folder") then
                    scanFolder(child, child.Name)
                end
            end
        end
        
        scanFolder(ReplicatedStorage, "ReplicatedStorage")
    end)
    
    return detectedAnticheats
end

-- Enhanced Script Detection
local function detectAnticheatScripts()
    local detectedAnticheats = {}
    
    pcall(function()
        for _, service in pairs({game:GetService("ServerScriptService"), game:GetService("StarterPlayerScripts"), game:GetService("ReplicatedStorage")}) do
            local function scanScripts(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                        for anticheatName, patterns in pairs(AnticheatPatterns) do
                            for _, keyword in pairs(patterns.keywords) do
                                if string.find(child.Name:lower(), keyword) then
                                    if not table.find(detectedAnticheats, anticheatName) then
                                        table.insert(detectedAnticheats, anticheatName)
                                    end
                                end
                            end
                        end
                    end
                    
                    if child:IsA("Folder") then
                        scanScripts(child)
                    end
                end
            end
            
            scanScripts(service)
        end
    end)
    
    return detectedAnticheats
end

-- Universal Bypass Function
local function bypassAnticheat(anticheatName)
    local success = false
    
    -- Method 1: Hook Detection Functions
    pcall(function()
        for _, value in getgc(true) do
            if typeof(value) ~= "table" then
                continue
            end

            local patterns = AnticheatPatterns[anticheatName]
            if patterns then
                for _, funcName in pairs(patterns.functions) do
                    local detectedFunction = rawget(value, funcName)
                    if typeof(detectedFunction) == "function" then
                        local funcSource = pcall(function()
                            return debug.info(detectedFunction, "s")
                        end)
                        
                        if funcSource then
                            for _, threadPattern in pairs(patterns.threads) do
                                if string.find(funcSource, threadPattern) then
                                    if not isfunctionhooked(detectedFunction) then
                                        wax.shared.Hooks[detectedFunction] = wax.shared.Hooking.HookFunction(
                                            detectedFunction,
                                            function(...)
                                                return task.wait(9e9)
                                            end
                                        )
                                        success = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Method 2: Hook Remote Events
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local patterns = AnticheatPatterns[anticheatName]
        
        if patterns then
            local function hookRemotes(folder)
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("RemoteEvent") then
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower()) then
                                local originalFire = child.FireServer
                                child.FireServer = function(...)
                                    return -- Block the remote
                                end
                                success = true
                            end
                        end
                    elseif child:IsA("RemoteFunction") then
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower()) then
                                local originalInvoke = child.InvokeServer
                                child.InvokeServer = function(...)
                                    return nil -- Block the remote
                                end
                                success = true
                            end
                        end
                    elseif child:IsA("Folder") then
                        hookRemotes(child)
                    end
                end
            end
            
            hookRemotes(ReplicatedStorage)
        end
    end)
    
    return success
end

-- Main Detection and Bypass Process
local function runAnticheatBypass()
    local allDetectedAnticheats = {}
    
    -- Run all detection methods
    local threadDetected = detectAnticheatThreads()
    local functionDetected = detectAnticheatFunctions()
    local remoteDetected = detectAnticheatRemotes()
    local scriptDetected = detectAnticheatScripts()
    
    -- Combine all detections
    for _, anticheat in pairs(threadDetected) do
        if not table.find(allDetectedAnticheats, anticheat) then
            table.insert(allDetectedAnticheats, anticheat)
        end
    end
    
    for _, anticheat in pairs(functionDetected) do
        if not table.find(allDetectedAnticheats, anticheat) then
            table.insert(allDetectedAnticheats, anticheat)
        end
    end
    
    for _, anticheat in pairs(remoteDetected) do
        if not table.find(allDetectedAnticheats, anticheat) then
            table.insert(allDetectedAnticheats, anticheat)
        end
    end
    
    for _, anticheat in pairs(scriptDetected) do
        if not table.find(allDetectedAnticheats, anticheat) then
            table.insert(allDetectedAnticheats, anticheat)
        end
    end
    
    -- Store detected anticheats
    wax.shared.DetectedAnticheats = allDetectedAnticheats
    
    if #allDetectedAnticheats > 0 then
        local detectedList = table.concat(allDetectedAnticheats, ", ")
        sendWebhook("🎯 Anticheats Detected", "Found: " .. detectedList, 16776960) -- Yellow
        
        local bypassedCount = 0
        local bypassResults = {}
        
        for _, anticheatName in pairs(allDetectedAnticheats) do
            if bypassAnticheat(anticheatName) then
                bypassedCount = bypassedCount + 1
                table.insert(bypassResults, "✅ " .. anticheatName)
            else
                table.insert(bypassResults, "❌ " .. anticheatName)
            end
        end
        
        if bypassedCount > 0 then
            wax.shared.AnticheatDisabled = true
            wax.shared.AnticheatName = table.concat(allDetectedAnticheats, ", ")
            
            local resultText = table.concat(bypassResults, "\n")
            sendWebhook("🛡️ Bypass Results", 
                "Successfully bypassed " .. bypassedCount .. "/" .. #allDetectedAnticheats .. " anticheats\n\n" .. resultText, 
                65280) -- Green
        else
            sendWebhook("⚠️ Bypass Failed", "No anticheats were successfully bypassed", 16711680) -- Red
        end
    else
        sendWebhook("✅ All Clear", "No known anticheats detected - You're safe!", 65280) -- Green
    end
end

-- Run the bypass
runAnticheatBypass()

-- Continuous monitoring (optional)
spawn(function()
    while true do
        task.wait(30) -- Check every 30 seconds
        
        -- Re-run detection for newly loaded anticheats
        local newDetected = detectAnticheatThreads()
        for _, anticheat in pairs(newDetected) do
            if not table.find(wax.shared.DetectedAnticheats, anticheat) then
                table.insert(wax.shared.DetectedAnticheats, anticheat)
                sendWebhook("🔄 New Anticheat", "Newly detected: " .. anticheat, 16776960) -- Yellow
                bypassAnticheat(anticheat)
            end
        end
    end
end)

sendWebhook("🛡️ Bypass Complete", "Anticheat bypass initialization finished", 3447003) -- Blue
