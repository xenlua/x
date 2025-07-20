--[[
    Enhanced Bypasses for Popular Roblox Anticheats
    Supports: Adonis, Vanguard, Sentinel, Hyperion, Aegis, and more
    With Webhook Logging Support
    
    Usage: loadstring(game:HttpGet("path/to/AnticheatBypass.lua"))()
]]

-- Configuration
local CONFIG = {
    WEBHOOK_URL = "", -- Set your Discord webhook URL here
    ENABLE_WEBHOOK = true, -- Set to false to disable webhook logging
    ENABLE_CONTINUOUS_MONITORING = true, -- Monitor for new anticheats
    MONITORING_INTERVAL = 30, -- Check every 30 seconds
    DEBUG_MODE = false, -- Enable debug prints
}

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Initialize shared variables
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

-- Debug function
local function debugPrint(...)
    if CONFIG.DEBUG_MODE then
        print("[ANTICHEAT BYPASS]", ...)
    end
end

-- Webhook logging function
local function sendWebhook(title, description, color)
    if not CONFIG.ENABLE_WEBHOOK or not CONFIG.WEBHOOK_URL or CONFIG.WEBHOOK_URL == "" then
        debugPrint("Webhook disabled or URL not set")
        return
    end
    
    local success, result = pcall(function()
        local gameInfo = "Unknown"
        pcall(function()
            gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        
        local embed = {
            title = title,
            description = description,
            color = color or 3447003, -- Blue default
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            fields = {
                {
                    name = "Player",
                    value = LocalPlayer.Name .. " (" .. LocalPlayer.UserId .. ")",
                    inline = true
                },
                {
                    name = "Game",
                    value = tostring(game.PlaceId),
                    inline = true
                },
                {
                    name = "Game Name",
                    value = gameInfo,
                    inline = true
                }
            }
        }
        
        local data = {
            embeds = {embed}
        }
        
        local response = HttpService:PostAsync(
            CONFIG.WEBHOOK_URL, 
            HttpService:JSONEncode(data), 
            Enum.HttpContentType.ApplicationJson
        )
        
        debugPrint("Webhook sent successfully:", title)
        return response
    end)
    
    if not success then
        debugPrint("Webhook failed:", result)
    end
end

-- Check if bypass is enabled
local function checkBypassEnabled()
    local BypassState = wax.shared.SaveManager:GetState("AnticheatBypass")
    local BypassEnabled = if typeof(BypassState) == "boolean" then BypassState else true
    
    if not BypassEnabled then
        sendWebhook("🔒 Anticheat Bypass", "Disabled by user settings", 16711680) -- Red
        return false
    end
    
    return true
end

-- Check required functions
local function checkRequiredFunctions()
    local requiredFunctions = {"getreg", "getgc"}
    local missingFunctions = {}
    
    for _, funcName in pairs(requiredFunctions) do
        if not _G[funcName] and not getfenv()[funcName] then
            table.insert(missingFunctions, funcName)
        end
    end
    
    if #missingFunctions > 0 then
        local missing = table.concat(missingFunctions, ", ")
        sendWebhook("⚠️ Anticheat Bypass", "Missing required functions: " .. missing, 16776960) -- Yellow
        debugPrint("Missing functions:", missing)
        return false
    end
    
    return true
end

-- Anticheat Detection Patterns
local AnticheatPatterns = {
    Adonis = {
        threads = {".Core.Anti", ".Plugins.Anti_Cheat", "Adonis_Anti", "Anti", "Core.Anti", "Plugins.Anti_Cheat", "MainModule"},
        functions = {"Detected", "AntiCheat", "Detection", "Check", "Kick", "Ban", "Flag"},
        remotes = {"Adonis_Remote", "AC_Remote", "Remote", "Event", "AdminRemote"},
        keywords = {"adonis", "anti", "cheat", "detection", "core", "admin", "mainmodule"},
        scripts = {"Adonis", "MainModule", "Anti", "Core"}
    },
    Vanguard = {
        threads = {".Vanguard", ".VG_Anti", ".Security", ".VanguardAC"},
        functions = {"VanguardDetected", "SecurityBreach", "VG_Check", "VanguardFlag"},
        remotes = {"VanguardRemote", "SecurityRemote", "VG_Remote"},
        keywords = {"vanguard", "security", "breach", "vg"},
        scripts = {"Vanguard", "VanguardAC", "Security"}
    },
    Sentinel = {
        threads = {".Sentinel", ".SentinelAC", ".Guard", ".SentinelGuard"},
        functions = {"SentinelDetected", "GuardCheck", "SentinelScan", "SentinelFlag"},
        remotes = {"SentinelRemote", "GuardRemote", "Sentinel_Remote"},
        keywords = {"sentinel", "guard", "scan", "sentinelac"},
        scripts = {"Sentinel", "SentinelAC", "Guard"}
    },
    Hyperion = {
        threads = {".Hyperion", ".HyperionAC", ".Hyper", ".HyperionGuard"},
        functions = {"HyperionDetected", "HyperCheck", "HyperScan", "HyperionFlag"},
        remotes = {"HyperionRemote", "HyperRemote", "Hyperion_Remote"},
        keywords = {"hyperion", "hyper", "detection", "hyperionac"},
        scripts = {"Hyperion", "HyperionAC", "Hyper"}
    },
    Aegis = {
        threads = {".Aegis", ".AegisAC", ".Shield", ".AegisShield"},
        functions = {"AegisDetected", "ShieldBreach", "AegisCheck", "AegisFlag"},
        remotes = {"AegisRemote", "ShieldRemote", "Aegis_Remote"},
        keywords = {"aegis", "shield", "protection", "aegisac"},
        scripts = {"Aegis", "AegisAC", "Shield"}
    },
    Kronos = {
        threads = {".Kronos", ".KronosAC", ".Time", ".KronosGuard"},
        functions = {"KronosDetected", "TimeCheck", "KronosScan", "KronosFlag"},
        remotes = {"KronosRemote", "TimeRemote", "Kronos_Remote"},
        keywords = {"kronos", "time", "temporal", "kronosac"},
        scripts = {"Kronos", "KronosAC", "Time"}
    },
    Phoenix = {
        threads = {".Phoenix", ".PhoenixAC", ".Fire", ".PhoenixGuard"},
        functions = {"PhoenixDetected", "FireCheck", "PhoenixScan", "PhoenixFlag"},
        remotes = {"PhoenixRemote", "FireRemote", "Phoenix_Remote"},
        keywords = {"phoenix", "fire", "rebirth", "phoenixac"},
        scripts = {"Phoenix", "PhoenixAC", "Fire"}
    },
    Nexus = {
        threads = {".Nexus", ".NexusAC", ".Core", ".NexusCore"},
        functions = {"NexusDetected", "CoreCheck", "NexusScan", "NexusFlag"},
        remotes = {"NexusRemote", "CoreRemote", "Nexus_Remote"},
        keywords = {"nexus", "core", "central", "nexusac"},
        scripts = {"Nexus", "NexusAC", "Core"}
    }
}

-- Enhanced Thread Detection
local function detectAnticheatThreads()
    local detectedAnticheats = {}
    
    local success, result = pcall(function()
        local getreg_func = getreg or getfenv().getreg
        if not getreg_func then
            debugPrint("getreg function not available")
            return
        end
        
        for _, thread in pairs(getreg_func()) do
            if typeof(thread) ~= "thread" then
                continue
            end

            local threadSuccess, source = pcall(function()
                if debug and debug.info then
                    return debug.info(thread, 1, "s")
                elseif getfenv().debug and getfenv().debug.info then
                    return getfenv().debug.info(thread, 1, "s")
                end
                return nil
            end)
            
            if threadSuccess and source and source ~= "" then
                debugPrint("Checking thread source:", source)
                
                for anticheatName, patterns in pairs(AnticheatPatterns) do
                    for _, pattern in pairs(patterns.threads) do
                        if string.find(source:lower(), pattern:lower(), 1, true) then
                            if not table.find(detectedAnticheats, anticheatName) then
                                table.insert(detectedAnticheats, anticheatName)
                                debugPrint("Detected anticheat via thread:", anticheatName, "Pattern:", pattern)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    if not success then
        debugPrint("Thread detection failed:", result)
    end
    
    return detectedAnticheats
end

-- Enhanced Function Detection
local function detectAnticheatFunctions()
    local detectedAnticheats = {}
    
    local success, result = pcall(function()
        local getgc_func = getgc or getfenv().getgc
        if not getgc_func then
            debugPrint("getgc function not available")
            return
        end
        
        for _, value in pairs(getgc_func(true)) do
            if typeof(value) ~= "table" then
                continue
            end

            for anticheatName, patterns in pairs(AnticheatPatterns) do
                for _, funcName in pairs(patterns.functions) do
                    local funcRef = rawget(value, funcName)
                    if typeof(funcRef) == "function" then
                        local funcSuccess, source = pcall(function()
                            if debug and debug.info then
                                return debug.info(funcRef, "s")
                            elseif getfenv().debug and getfenv().debug.info then
                                return getfenv().debug.info(funcRef, "s")
                            end
                            return nil
                        end)
                        
                        if funcSuccess and source then
                            debugPrint("Found function:", funcName, "Source:", source)
                            
                            -- Check if source matches any thread patterns
                            for _, threadPattern in pairs(patterns.threads) do
                                if string.find(source:lower(), threadPattern:lower(), 1, true) then
                                    if not table.find(detectedAnticheats, anticheatName) then
                                        table.insert(detectedAnticheats, anticheatName)
                                        debugPrint("Detected anticheat via function:", anticheatName, "Function:", funcName)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    if not success then
        debugPrint("Function detection failed:", result)
    end
    
    return detectedAnticheats
end

-- Enhanced Remote Detection
local function detectAnticheatRemotes()
    local detectedAnticheats = {}
    
    local success, result = pcall(function()
        local function scanFolder(folder, folderName)
            if not folder then return end
            
            for _, child in pairs(folder:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    debugPrint("Checking remote:", child.Name)
                    
                    for anticheatName, patterns in pairs(AnticheatPatterns) do
                        -- Check remote name patterns
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower(), 1, true) then
                                if not table.find(detectedAnticheats, anticheatName) then
                                    table.insert(detectedAnticheats, anticheatName)
                                    debugPrint("Detected anticheat via remote:", anticheatName, "Remote:", child.Name)
                                end
                            end
                        end
                        
                        -- Check keywords in remote names
                        for _, keyword in pairs(patterns.keywords) do
                            if string.find(child.Name:lower(), keyword, 1, true) then
                                if not table.find(detectedAnticheats, anticheatName) then
                                    table.insert(detectedAnticheats, anticheatName)
                                    debugPrint("Detected anticheat via keyword:", anticheatName, "Keyword:", keyword)
                                end
                            end
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
    
    if not success then
        debugPrint("Remote detection failed:", result)
    end
    
    return detectedAnticheats
end

-- Enhanced Script Detection
local function detectAnticheatScripts()
    local detectedAnticheats = {}
    
    local success, result = pcall(function()
        local services = {ReplicatedStorage}
        
        for _, service in pairs(services) do
            local function scanScripts(parent)
                if not parent then return end
                
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                        debugPrint("Checking script:", child.Name)
                        
                        for anticheatName, patterns in pairs(AnticheatPatterns) do
                            -- Check script names
                            for _, scriptName in pairs(patterns.scripts) do
                                if string.find(child.Name:lower(), scriptName:lower(), 1, true) then
                                    if not table.find(detectedAnticheats, anticheatName) then
                                        table.insert(detectedAnticheats, anticheatName)
                                        debugPrint("Detected anticheat via script:", anticheatName, "Script:", child.Name)
                                    end
                                end
                            end
                            
                            -- Check keywords
                            for _, keyword in pairs(patterns.keywords) do
                                if string.find(child.Name:lower(), keyword, 1, true) then
                                    if not table.find(detectedAnticheats, anticheatName) then
                                        table.insert(detectedAnticheats, anticheatName)
                                        debugPrint("Detected anticheat via script keyword:", anticheatName, "Keyword:", keyword)
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
    
    if not success then
        debugPrint("Script detection failed:", result)
    end
    
    return detectedAnticheats
end

-- Universal Bypass Function
local function bypassAnticheat(anticheatName)
    local success = false
    local bypassMethods = {}
    
    debugPrint("Attempting to bypass:", anticheatName)
    
    -- Method 1: Hook Detection Functions
    local method1Success = pcall(function()
        local getgc_func = getgc or getfenv().getgc
        if not getgc_func then return end
        
        for _, value in pairs(getgc_func(true)) do
            if typeof(value) ~= "table" then
                continue
            end

            local patterns = AnticheatPatterns[anticheatName]
            if patterns then
                for _, funcName in pairs(patterns.functions) do
                    local detectedFunction = rawget(value, funcName)
                    if typeof(detectedFunction) == "function" then
                        local funcSuccess, funcSource = pcall(function()
                            if debug and debug.info then
                                return debug.info(detectedFunction, "s")
                            elseif getfenv().debug and getfenv().debug.info then
                                return getfenv().debug.info(detectedFunction, "s")
                            end
                            return nil
                        end)
                        
                        if funcSuccess and funcSource then
                            for _, threadPattern in pairs(patterns.threads) do
                                if string.find(funcSource:lower(), threadPattern:lower(), 1, true) then
                                    if not wax.shared.Hooks[detectedFunction] then
                                        wax.shared.Hooks[detectedFunction] = wax.shared.Hooking.HookFunction(
                                            detectedFunction,
                                            function(...)
                                                debugPrint("Blocked anticheat function:", funcName)
                                                return task.wait(9e9)
                                            end
                                        )
                                        table.insert(bypassMethods, "Function Hook: " .. funcName)
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
    
    if method1Success then
        debugPrint("Method 1 (Function Hook) completed for:", anticheatName)
    end
    
    -- Method 2: Hook Remote Events
    local method2Success = pcall(function()
        local patterns = AnticheatPatterns[anticheatName]
        
        if patterns then
            local function hookRemotes(folder)
                if not folder then return end
                
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("RemoteEvent") then
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower(), 1, true) then
                                local originalFire = child.FireServer
                                child.FireServer = function(...)
                                    debugPrint("Blocked RemoteEvent:", child.Name)
                                    return -- Block the remote
                                end
                                table.insert(bypassMethods, "RemoteEvent Block: " .. child.Name)
                                success = true
                            end
                        end
                    elseif child:IsA("RemoteFunction") then
                        for _, remoteName in pairs(patterns.remotes) do
                            if string.find(child.Name:lower(), remoteName:lower(), 1, true) then
                                local originalInvoke = child.InvokeServer
                                child.InvokeServer = function(...)
                                    debugPrint("Blocked RemoteFunction:", child.Name)
                                    return nil -- Block the remote
                                end
                                table.insert(bypassMethods, "RemoteFunction Block: " .. child.Name)
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
    
    if method2Success then
        debugPrint("Method 2 (Remote Hook) completed for:", anticheatName)
    end
    
    if success then
        debugPrint("Successfully bypassed:", anticheatName, "Methods:", table.concat(bypassMethods, ", "))
    else
        debugPrint("Failed to bypass:", anticheatName)
    end
    
    return success, bypassMethods
end

-- Main Detection and Bypass Process
local function runAnticheatBypass()
    debugPrint("Starting anticheat detection and bypass process...")
    
    local allDetectedAnticheats = {}
    
    -- Run all detection methods
    local threadDetected = detectAnticheatThreads()
    local functionDetected = detectAnticheatFunctions()
    local remoteDetected = detectAnticheatRemotes()
    local scriptDetected = detectAnticheatScripts()
    
    -- Combine all detections
    local detectionSources = {
        {threadDetected, "Thread"},
        {functionDetected, "Function"},
        {remoteDetected, "Remote"},
        {scriptDetected, "Script"}
    }
    
    for _, detection in pairs(detectionSources) do
        local detected, source = detection[1], detection[2]
        for _, anticheat in pairs(detected) do
            if not table.find(allDetectedAnticheats, anticheat) then
                table.insert(allDetectedAnticheats, anticheat)
                debugPrint("Added anticheat from", source, "detection:", anticheat)
            end
        end
    end
    
    -- Store detected anticheats
    wax.shared.DetectedAnticheats = allDetectedAnticheats
    
    if #allDetectedAnticheats > 0 then
        local detectedList = table.concat(allDetectedAnticheats, ", ")
        debugPrint("Detected anticheats:", detectedList)
        sendWebhook("🎯 Anticheats Detected", "Found: " .. detectedList, 16776960) -- Yellow
        
        local bypassedCount = 0
        local bypassResults = {}
        local allBypassMethods = {}
        
        for _, anticheatName in pairs(allDetectedAnticheats) do
            local bypassed, methods = bypassAnticheat(anticheatName)
            if bypassed then
                bypassedCount = bypassedCount + 1
                table.insert(bypassResults, "✅ " .. anticheatName)
                for _, method in pairs(methods) do
                    table.insert(allBypassMethods, method)
                end
            else
                table.insert(bypassResults, "❌ " .. anticheatName)
            end
        end
        
        if bypassedCount > 0 then
            wax.shared.AnticheatDisabled = true
            wax.shared.AnticheatName = table.concat(allDetectedAnticheats, ", ")
            
            local resultText = table.concat(bypassResults, "\n")
            local methodText = #allBypassMethods > 0 and ("\n\nMethods Used:\n" .. table.concat(allBypassMethods, "\n")) or ""
            
            sendWebhook("🛡️ Bypass Results", 
                "Successfully bypassed " .. bypassedCount .. "/" .. #allDetectedAnticheats .. " anticheats\n\n" .. resultText .. methodText, 
                65280) -- Green
                
            debugPrint("Bypass completed successfully. Bypassed:", bypassedCount, "out of", #allDetectedAnticheats)
        else
            sendWebhook("⚠️ Bypass Failed", "No anticheats were successfully bypassed", 16711680) -- Red
            debugPrint("All bypass attempts failed")
        end
    else
        sendWebhook("✅ All Clear", "No known anticheats detected - You're safe!", 65280) -- Green
        debugPrint("No anticheats detected")
    end
    
    return allDetectedAnticheats
end

-- Continuous monitoring function
local function startContinuousMonitoring()
    if not CONFIG.ENABLE_CONTINUOUS_MONITORING then
        return
    end
    
    debugPrint("Starting continuous monitoring...")
    
    task.spawn(function()
        while true do
            task.wait(CONFIG.MONITORING_INTERVAL)
            
            debugPrint("Running periodic anticheat check...")
            
            -- Re-run detection for newly loaded anticheats
            local newDetected = detectAnticheatThreads()
            for _, anticheat in pairs(newDetected) do
                if not table.find(wax.shared.DetectedAnticheats, anticheat) then
                    table.insert(wax.shared.DetectedAnticheats, anticheat)
                    sendWebhook("🔄 New Anticheat", "Newly detected: " .. anticheat, 16776960) -- Yellow
                    debugPrint("New anticheat detected:", anticheat)
                    
                    local bypassed, methods = bypassAnticheat(anticheat)
                    if bypassed then
                        sendWebhook("✅ New Bypass", "Successfully bypassed newly detected: " .. anticheat, 65280) -- Green
                    else
                        sendWebhook("❌ Bypass Failed", "Failed to bypass newly detected: " .. anticheat, 16711680) -- Red
                    end
                end
            end
        end
    end)
end

-- Main execution function
local function main()
    debugPrint("Initializing Enhanced Anticheat Bypass...")
    
    -- Check if bypass is enabled
    if not checkBypassEnabled() then
        return false
    end
    
    -- Check required functions
    if not checkRequiredFunctions() then
        return false
    end
    
    sendWebhook("🛡️ Anticheat Bypass", "Starting detection and bypass process...", 3447003) -- Blue
    
    -- Run the main bypass process
    local detectedAnticheats = runAnticheatBypass()
    
    -- Start continuous monitoring
    startContinuousMonitoring()
    
    sendWebhook("🛡️ Bypass Complete", "Anticheat bypass initialization finished", 3447003) -- Blue
    debugPrint("Anticheat bypass initialization completed")
    
    return true, detectedAnticheats
end

-- Export functions for external use
local AnticheatBypass = {
    run = main,
    detectAnticheats = runAnticheatBypass,
    bypassAnticheat = bypassAnticheat,
    sendWebhook = sendWebhook,
    config = CONFIG,
    patterns = AnticheatPatterns
}

-- Auto-run if not being required
if not _G.ANTICHEAT_BYPASS_LOADED then
    _G.ANTICHEAT_BYPASS_LOADED = true
    main()
end

return AnticheatBypass
