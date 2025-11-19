local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")

-- Cache untuk menyimpan fish modules yang sudah di-load
local fishModulesCache = {}
local cacheLoaded = false
local WeightRandom = nil
local TiersData = nil

local wrSuccess = pcall(function()
    WeightRandom = require(rs.Shared.WeightRandom)
end)

local tiersSuccess = pcall(function()
    TiersData = require(rs.Tiers)
end)

-- LOAD ALL FISH MODULES FIRST (BEFORE UI)
local function loadFishModules()
    if cacheLoaded then return true end

    local loadingStart = tick()
    local moduleCount = 0
    local successCount = 0
    local failedModules = {}

    local success = pcall(function()
        local itemsFolder = rs:FindFirstChild("Items")
        if not itemsFolder then return end        
        
        for _, fishModule in pairs(itemsFolder:GetChildren()) do
            if fishModule:IsA("ModuleScript") then
                moduleCount = moduleCount + 1
                
                local modSuccess, data = pcall(function()
                    local loadedModule = require(fishModule)
                    if loadedModule then return loadedModule end
                    return nil
                end)

                if modSuccess and data then
                    if data.Data then
                        if data.Data.Id then
                            fishModulesCache[data.Data.Id] = {
                                Name = data.Data.Name or fishModule.Name,
                                SellPrice = data.SellPrice or 0,
                                Weight = data.Weight,
                                Probability = data.Probability,
                                Tier = data.Data.Tier or 1,
                                Icon = data.Data.Icon or "",
                                Type = data.Data.Type or "Unknown",
                                FullData = data
                            }
                            successCount = successCount + 1
                        else
                            table.insert(failedModules, {name = fishModule.Name, reason = "No ID"})
                        end
                    else
                        table.insert(failedModules, {name = fishModule.Name, reason = "No Data"})
                    end
                else
                    table.insert(failedModules, {name = fishModule.Name, reason = "Require failed"})
                    warn("[Fish It] Failed to load:", fishModule.Name)
                end
                
                if moduleCount % 50 == 0 then task.wait() end
            end
        end
        
        cacheLoaded = true
    end)

    local loadTime = math.round((tick() - loadingStart) * 100) / 100
    return success, successCount, moduleCount, loadTime
end

local loadSuccess, fishLoaded, totalModules, loadTime = loadFishModules()

-- UI SETUP
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/XenonLoader/WindUI/refs/heads/main/dist/main.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Plant")

local ver="v08"

local function lerpCol(c1,c2,t)return("#%02x%02x%02x"):format(math.floor((1-t)*c1[1]+t*c2[1]),math.floor((1-t)*c1[2]+t*c2[2]),math.floor((1-t)*c1[3]+t*c2[3]))end
local function hex2rgb(h) h=h:sub(1,1)=="#" and h:sub(2) or h return{tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)}end
local function grad(w) if not w or #w==0 then return"Error"end local sc,ec=getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.startingColor or"ea00ff")or hex2rgb("ea00ff"),getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.endingColor or"5700ff")or hex2rgb("5700ff")local r=""local st=1/math.max(#w-1,1)for i=1,#w do r=r..('<font color="%s">%s</font>'):format(lerpCol(sc,ec,st*(i-1)),w:sub(i,i))end return r end
local function fmtVer(v) return ("  v"..v:sub(2):gsub(".","%0.")):sub(1,-2) end

local function generateWeightForFish(fishData, seed)
    if not fishData or not fishData.Weight then return nil end
    local weightData = fishData.Weight.Default or fishData.Weight
    if not weightData or not weightData.Min or not weightData.Max then return nil end

    local min = tonumber(weightData.Min) or 0
    local max = tonumber(weightData.Max) or 0
    if min == 0 and max == 0 then return nil end

    local rng = seed and Random.new(seed) or Random.new()
    local randomWeight = min + (max - min) * rng:NextNumber()
    return math.round(randomWeight * 100) / 100
end

local function getActualWeight(lastItem, fishData)
    local actualWeight = nil
    local variant = "Default"

    pcall(function()
        if lastItem and type(lastItem) == "table" then
            if lastItem.Weight and type(lastItem.Weight) == "number" then
                actualWeight = lastItem.Weight
                return
            end
            if lastItem.weight and type(lastItem.weight) == "number" then
                actualWeight = lastItem.weight
                return
            end
            if lastItem.Metadata and type(lastItem.Metadata) == "table" then
                if lastItem.Metadata.Weight and type(lastItem.Metadata.Weight) == "number" then
                    actualWeight = lastItem.Metadata.Weight
                    return
                elseif lastItem.Metadata.weight and type(lastItem.Metadata.weight) == "number" then
                    actualWeight = lastItem.Metadata.weight
                    return
                end
            end
            if lastItem.Data and lastItem.Data.Weight and type(lastItem.Data.Weight) == "number" then
                actualWeight = lastItem.Data.Weight
                return
            end
        end
    end)

    if actualWeight and fishData and fishData.Weight then
        pcall(function()
            if fishData.Weight.Big then
                local bigMin = fishData.Weight.Big.Min or 0
                local bigMax = fishData.Weight.Big.Max or 0
                if actualWeight >= bigMin and actualWeight <= bigMax then
                    variant = "Big"
                    return
                end
            end
            if fishData.Weight.Huge then
                local hugeMin = fishData.Weight.Huge.Min or 0
                local hugeMax = fishData.Weight.Huge.Max or 0
                if actualWeight >= hugeMin and actualWeight <= hugeMax then
                    variant = "Huge"
                    return
                end
            end
            if fishData.Weight.Giant then
                local giantMin = fishData.Weight.Giant.Min or 0
                local giantMax = fishData.Weight.Giant.Max or 0
                if actualWeight >= giantMin and actualWeight <= giantMax then
                    variant = "Giant"
                    return
                end
            end
            variant = "Default"
        end)
    end

    if not actualWeight and fishData then
        pcall(function()
            local seed = nil
            if lastItem and lastItem.UUID then
                seed = lastItem.UUID:gsub("-", "")
                seed = tonumber(seed:sub(1, 8), 16) or nil
            elseif lastItem and lastItem.Id then
                seed = lastItem.Id
            end
            actualWeight = generateWeightForFish(fishData, seed)
        end)
    end

    return actualWeight, variant
end

local function getFishInfo(fishId, lastItem)
    local info = {
        Name = "Unknown",
        SellPrice = 0,
        Weight = "0.00 kg",
        Chance = "0%",
        Rarity = "Unknown",
        Icon = ""
    }

    pcall(function()
        if not fishId then return end

        if fishModulesCache[fishId] then
            local fishData = fishModulesCache[fishId]
            info.Name = fishData.Name or "Unknown"
            info.SellPrice = fishData.SellPrice or 0

            local actualWeight, variant = getActualWeight(lastItem, fishData)

            if actualWeight and actualWeight > 0 then
                local weight = tonumber(actualWeight) or 0
                info.Weight = string.format("%.2f kg", weight)
            elseif fishData.Weight then
                if fishData.Weight.Default then
                    local minW = tonumber(fishData.Weight.Default.Min) or 0
                    local maxW = tonumber(fishData.Weight.Default.Max) or 0
                    info.Weight = string.format("%.2f - %.2f kg", minW, maxW)
                elseif fishData.Weight.Min and fishData.Weight.Max then
                    local minW = tonumber(fishData.Weight.Min) or 0
                    local maxW = tonumber(fishData.Weight.Max) or 0
                    info.Weight = string.format("%.2f - %.2f kg", minW, maxW)
                end
            end

            if fishData.Probability and fishData.Probability.Chance then
                local chance = fishData.Probability.Chance
                info.Chance = tostring(chance)
            end

            if fishData.Tier and TiersData then
                local tierInfo = TiersData[fishData.Tier]
                if tierInfo and tierInfo.Name then
                    info.Rarity = tierInfo.Name
                end
            end

            if fishData.Icon and fishData.Icon ~= "" then
                info.Icon = fishData.Icon
            end
        end
    end)

    return info
end

-- CREATE WINDOW
local Window = WindUI:CreateWindow({
    Title = 'Fish It',
    Icon = "fishIt",
    Author = grad("Avantrix"),
    Folder = "AutoFishing",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Plant",
    HideSearchBar = false,
    SideBarWidth = 200,
    Acrylic = false,
})

Window:EditOpenButton({
    Title = "Open Avantrix",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:SetToggleKey(Enum.KeyCode.G)
WindUI:SetNotificationLower(true)
Window:DisableTopbarButtons({"Fullscreen"})
Window:Tag({
    Title = fmtVer(ver),
    Color = Color3.fromHex("#30ff6a")
})

-- SECTIONS AND TABS
local Sections = {
    Main = Window:Section({ Title = "Features", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true }),
}

local Tabs = {
    Information = Sections.Main:Tab({
        Title = "Information",
        Icon = "airplay",
        Desc = "Information about the script"
    }),
    Fishing = Sections.Main:Tab({
        Title = "Auto Fishing",
        Icon = "fish",
        Desc = "Auto fishing features"
    }),
    Webhook = Sections.Main:Tab({
        Title = "Webhook",
        Icon = "book",
        Desc = ""
    }),
    Configuration = Sections.Settings:Tab({
        Title = "Configuration",
        Icon = "settings",
        Desc = "Save and load settings"
    }),
}

-- INFORMATION TAB
Tabs.Information:Section({
    Title = grad("UPDATED"),
    TextSize = 18,
})

Tabs.Information:Paragraph({
    Title = "Update Log",
    Desc = [[<font color="rgb(255,255,255)">NEWS v08:</font>
[+] Fixed timing system
[+] Delay Cast - waktu tunggu sebelum cast ulang
[+] Delay Complete - waktu tunggu sebelum complete
[+] Cast berdasarkan timer, bukan deteksi ikan

v07:
[+] Pre-load all fish data before UI
[+] Webhook independent from fishing mode
]],
})

Tabs.Information:Paragraph({
    Title = "Loading Status",
    Desc = string.format([[<font color="rgb(100,255,100)">✓Modules: %d/%d loaded (%.2fs)</font>]],
        fishLoaded or 0,
        totalModules or 0,
        loadTime or 0
    ),
})

Tabs.Information:Code({
    Title = "Discord",
    Code = [[https://discord.gg/cF8YeDPt2G]],
    OnCopy = function()
        setclipboard("https://discord.gg/cF8YeDPt2G")
        WindUI:Notify({
            Title = "Copied!",
            Content = "Discord link copied to clipboard",
            Duration = 2
        })
    end
})

-- AUTO FISHING VARIABLES
getgenv().AutoFish = false
getgenv().AutoClickSpeed = 0.01
getgenv().FishingCooldown = 0
getgenv().FishingMode = "Legit"
getgenv().DelayComplete = 1.1  -- Delay sebelum complete
getgenv().DelayCast = 2.5      -- Delay sebelum cast ulang
getgenv().StopAllAnimations = false

local lgThread, blThread, lgActive, blActive

-- WEBHOOK VARIABLES
getgenv().WebhookEnabled = false
getgenv().WebhookURL = ""
getgenv().WebhookRarityFilter = {"All"}

local function stopFish()
    pcall(function()
        local fc = require(rs.Controllers.FishingController)
        if fc.RequestClientStopFishing then
            fc:RequestClientStopFishing(true)
        end
    end)
end

-- RARITY COLORS FOR WEBHOOK
local rarityColors = {
    ["Common"] = 8421504,
    ["Uncommon"] = 65280,
    ["Rare"] = 255,
    ["Epic"] = 10494192,
    ["Legendary"] = 16776960,
    ["Mythic"] = 16711680,
    ["SECRET"] = 16711935
}

local function sendWebhook(fishName, rarity, chance, price, weight, playerName, fishIcon)
    if not getgenv().WebhookEnabled or not getgenv().WebhookURL or getgenv().WebhookURL == "" then
        return
    end

    local filters = getgenv().WebhookRarityFilter or {"All"}
    local hasAll = false
    
    for _, filter in ipairs(filters) do
        if filter == "All" then
            hasAll = true
            break
        end
    end
    
    if not hasAll then
        local rarityMatched = false
        for _, filter in ipairs(filters) do
            if rarity == filter then
                rarityMatched = true
                break
            end
        end
        if not rarityMatched then return end
    end

    task.spawn(function()
        local success, err = pcall(function()
            local hs = game:GetService("HttpService")
            local color = rarityColors[rarity] or 8421504
            local imageUrl = nil
            
            if fishIcon and fishIcon ~= "" then                
                local assetId = fishIcon:match("rbxassetid://(%d+)") 
                    or fishIcon:match("rbxasset://(%d+)")
                    or fishIcon:match("http://www%.roblox%.com/asset/%?id=(%d+)")
                    or fishIcon:match("https://www%.roblox%.com/asset/%?id=(%d+)")
                    or fishIcon:match("^(%d+)$")
                
                if assetId then
                    local isLongId = string.len(assetId) > 15
                    
                    if not isLongId then
                        local thumbnailSuccess, thumbnailUrl = pcall(function()
                            local thumbUrl = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"
                            
                            local response
                            local requestSuccess = false
                            
                            if request then
                                requestSuccess, response = pcall(function()
                                    return request({Url = thumbUrl, Method = "GET"})
                                end)
                            elseif syn and syn.request then
                                requestSuccess, response = pcall(function()
                                    return syn.request({Url = thumbUrl, Method = "GET"})
                                end)
                            elseif http_request then
                                requestSuccess, response = pcall(function()
                                    return http_request({Url = thumbUrl, Method = "GET"})
                                end)
                            else
                                requestSuccess, response = pcall(function()
                                    return {Body = hs:GetAsync(thumbUrl)}
                                end)
                            end
                            
                            if requestSuccess and response and response.Body then
                                local data = hs:JSONDecode(response.Body)
                                if data and data.data and data.data[1] and data.data[1].imageUrl then
                                    return data.data[1].imageUrl
                                end
                            end
                            return nil
                        end)
                        
                        if thumbnailSuccess and thumbnailUrl and (thumbnailUrl:find("rbxcdn%.com") or thumbnailUrl:find("roblox%.com")) then
                            imageUrl = thumbnailUrl
                        else
                            imageUrl = "https://assetgame.roblox.com/Thumbs/Asset.ashx?assetId=" .. assetId .. "&x=420&y=420&format=png"
                        end
                    end
                end
            end

            task.wait(0.15)

            local timeNow = os.date("*t")
            local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
            local footerText = string.format("Avantrix • %s %d, %d", months[timeNow.month], timeNow.day, timeNow.year)

            local embed = {
                title = "🐟 " .. playerName .. " just caught a **" .. fishName .. "**!",
                color = color,
                fields = {
                    {name = "⭐ Rarity", value = rarity, inline = true},
                    {name = "🎯 Catch Chance", value = chance .. "%", inline = true},
                    {name = "💰 Sell Price", value = tostring(price) .. " Coins", inline = true},
                    {name = "⚖️ Weight", value = weight, inline = false}
                },
                timestamp = DateTime.now():ToIsoDate(),
                footer = {text = footerText}
            }

            if imageUrl and imageUrl ~= "" then
                embed.image = {url = imageUrl}
            end

            local payload = {
                username = "FISH IT | Fish Alert",
                avatar_url = "https://cdn.discordapp.com/attachments/1234567890/fishit-icon.png",
                embeds = { embed }
            }

            local json = hs:JSONEncode(payload)
            local response
            local sendSuccess = false
            
            if request then
                sendSuccess, response = pcall(function()
                    return request({
                        Url = getgenv().WebhookURL, 
                        Method = "POST", 
                        Headers = {["Content-Type"] = "application/json"}, 
                        Body = json
                    })
                end)
            elseif syn and syn.request then
                sendSuccess, response = pcall(function()
                    return syn.request({
                        Url = getgenv().WebhookURL, 
                        Method = "POST", 
                        Headers = {["Content-Type"] = "application/json"}, 
                        Body = json
                    })
                end)
            elseif http_request then
                sendSuccess, response = pcall(function()
                    return http_request({
                        Url = getgenv().WebhookURL, 
                        Method = "POST", 
                        Headers = {["Content-Type"] = "application/json"}, 
                        Body = json
                    })
                end)
            else
                sendSuccess, response = pcall(function()
                    return hs:PostAsync(getgenv().WebhookURL, json, Enum.HttpContentType.ApplicationJson, false)
                end)
            end
        end)

        if not success then
            warn("[Fish It] ✗ Webhook error:", err)
        end
    end)
end

local rep = nil
local webhookMonitorThread = nil

local function startWebhookMonitor()
    if webhookMonitorThread then
        task.cancel(webhookMonitorThread)
        webhookMonitorThread = nil
    end

    webhookMonitorThread = task.spawn(function()
        local Replion = require(rs.Packages.Replion)
        local iu = require(rs.Shared.ItemUtility)
        
        pcall(function()
            rep = Replion.Client:WaitReplion("Data", 10)
        end)
        
        if not rep then return end

        local lastCount = 0
        
        pcall(function()
            local itms = rep:GetExpect({"Inventory","Items"})
            if itms then
                for _, i in ipairs(itms) do
                    local d = iu:GetItemData(i.Id)
                    if d and d.Data.Type == "Fish" then
                        lastCount += 1
                    end
                end
            end
        end)

        while getgenv().WebhookEnabled do
            task.wait(0.5)
            
            pcall(function()
                local itms = rep:GetExpect({"Inventory","Items"})
                local fishCount = 0
                
                if itms then
                    for _, i in ipairs(itms) do
                        local d = iu:GetItemData(i.Id)
                        if d and d.Data.Type == "Fish" then
                            fishCount += 1
                        end
                    end
                end

                if fishCount > lastCount then
                    lastCount = fishCount
                    
                    if itms and #itms > 0 then
                        local lastItem = itms[#itms]
                        local itemData = iu:GetItemData(lastItem.Id)
                        
                        if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                            local fishId = itemData.Data.Id
                            local info = getFishInfo(fishId, lastItem)
                            
                            sendWebhook(
                                info.Name,
                                info.Rarity,
                                info.Chance,
                                tostring(info.SellPrice),
                                info.Weight,
                                plr.Name,
                                info.Icon
                            )
                        end
                    end
                end
            end)
        end
    end)
end

local function stopWebhookMonitor()
    if webhookMonitorThread then
        task.cancel(webhookMonitorThread)
        webhookMonitorThread = nil
    end
end

-- LEGIT FISHING FUNCTION
local function startLegit()
    lgActive = true
    lgThread = task.spawn(function()
        repeat task.wait() until game:IsLoaded()

        local nr = rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
        local rfCancel = nr:WaitForChild("RF/CancelFishingInputs")

        local cons = require(rs.Shared.Constants)
        cons.FishingCooldownTime = getgenv().FishingCooldown
        cons.GetPower = function() return 1 end
        
        local fc = require(rs.Controllers.FishingController)
        local Replion = require(rs.Packages.Replion)

        local rep
        pcall(function()
            rep = Replion.Client:WaitReplion("Data", 10)
        end)
        
        if not rep then return end
        fc._getPower = function() return 1 end

        local st = {
            IDLE = "idle",
            CASTING = "casting",
            WAITING = "waiting",
            MINIGAME = "minigame",
            REELING = "reeling",
            COMPLETED = "completed"
        }
        
        local cs, lg, mgC = st.IDLE, nil, false
        local cam = workspace.CurrentCamera
        local lct, cc, stuckTimer, stuckState = 0, 0, 0, st.IDLE
        local lastCastTime = 0

        local function detSt()
            local g = fc:GetCurrentGUID()
            local ocd = fc.OnCooldown and fc:OnCooldown() or false
            
            if g then
                if cs ~= st.MINIGAME then
                    lg = g
                    mgC = false
                end
                return st.MINIGAME
            end
            
            if lg and not g then
                local busy = false
                pcall(function()
                    if (fc.FishingLine and fc.FishingLine.Parent) or 
                       (fc.FishingBobber and fc.FishingBobber.Parent) or 
                       fc._isFishing or fc._isReeling then
                        busy = true
                    end
                end)
                
                if busy then
                    return st.REELING
                else
                    if mgC then
                        return st.COMPLETED
                    else
                        lg = nil
                        return st.IDLE
                    end
                end
            end
            
            return ocd and st.WAITING or st.IDLE
        end

        while lgActive and getgenv().AutoFish and getgenv().FishingMode == "Legit" do
            local ct = tick()
            
            pcall(function()
                if not rep or rep:GetExpect("EquippedType") ~= "Fishing Rods" then
                    cs, lg, mgC, stuckTimer, stuckState = st.IDLE, nil, false, 0, st.IDLE
                    stopFish()
                    return
                end

                local ns = detSt()
                
                if ns ~= cs then
                    cs = ns
                    stuckTimer = 0
                    stuckState = cs
                else
                    stuckTimer = stuckTimer + 1
                end

                if cs == st.IDLE then
                    -- CAST BERDASARKAN DELAY TIMER
                    local timeSinceLastCast = ct - lastCastTime
                    
                    if timeSinceLastCast >= getgenv().DelayCast and not fc:OnCooldown() then
                        rfCancel:InvokeServer()
                        fc:RequestChargeFishingRod(nil, true)
                        cs = st.CASTING
                        stuckTimer = 0
                        lastCastTime = ct
                    end
                    
                elseif cs == st.MINIGAME then
                    if ct - lct >= getgenv().AutoClickSpeed + math.random() * 0.1 then
                        fc:FishingMinigameClick()
                        lct = ct
                        cc += 1
                    end
                    
                    if not fc:GetCurrentGUID() and lg then
                        mgC = true
                        cs = st.COMPLETED
                        stuckTimer = 0
                    end
                    
                elseif cs == st.WAITING then
                    if stuckTimer > 150 then
                        lgActive = false
                        stopFish()
                        return
                    end
                    
                elseif cs == st.COMPLETED then
                    -- Reset state setelah complete
                    lg, mgC = nil, false
                    cs = st.IDLE
                    stuckTimer = 0
                end

                if stuckTimer > 200 and cs == stuckState then
                    lgActive = false
                    stopFish()
                    return
                end
            end)

            if cc >= 9e9 then
                task.wait(0.1 + math.random() * 0.1)
                cc = 0
            else
                task.wait(0.05)
            end
        end
    end)
end

local function startBlat()
    if blThread then
        task.cancel(blThread)
        blThread = nil
    end
    
    blActive = true
    blThread = task.spawn(function()
        local nr = rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
        local rfCharge = nr:WaitForChild("RF/ChargeFishingRod")
        local rfStart = nr:WaitForChild("RF/RequestFishingMinigameStarted")
        local reFish = nr:WaitForChild("RE/FishingCompleted")
        local reEquip = nr:WaitForChild("RE/EquipToolFromHotbar")
        local rfCancel = nr:WaitForChild("RF/CancelFishingInputs")
        local reText = nr:WaitForChild("RE/ReplicateTextEffect")

        local Replion = require(rs.Packages.Replion)

        pcall(function()
            rep = Replion.Client:WaitReplion("Data", 10)
        end)
        
        if not rep then
            WindUI:Notify({
                Title = "Error",
                Content = "Failed to get player data!",
                Duration = 3
            })
            return
        end

        local rodNotEquipped = false
        local lastCastTime = 0
        local avgPing = 0
        local pingHistory = {}
        local maxPingHistory = 10
        
        -- Function untuk menghitung rata-rata ping
        local function updatePing()
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            
            table.insert(pingHistory, ping)
            if #pingHistory > maxPingHistory then
                table.remove(pingHistory, 1)
            end
            
            local total = 0
            for _, p in ipairs(pingHistory) do
                total = total + p
            end
            avgPing = total / #pingHistory
            
            return avgPing
        end
        
        -- Update ping setiap detik
        task.spawn(function()
            while blActive and getgenv().AutoFish do
                updatePing()
                task.wait(1)
            end
        end)

        local function cast()
            if rodNotEquipped then return end
            
            local currentTime = tick()
            local timeSinceLastCast = currentTime - lastCastTime
            
            -- Konversi ping dari ms ke seconds, lalu kompensasi
            local pingCompensation = avgPing / 1000
            local effectiveDelay = math.max(0.1, getgenv().DelayCast - pingCompensation)
            
            -- Pastikan tidak cast terlalu cepat
            if timeSinceLastCast < effectiveDelay then
                return
            end
            
            lastCastTime = currentTime
            
            task.spawn(function()
                pcall(function()
                    rfCancel:InvokeServer()
                    reEquip:FireServer(1)
                    rfCharge:InvokeServer(tick())
                    rfStart:InvokeServer(-1.25, 0.1)
                end)
            end)
        end

        -- EXCLAIM DETECTION - LANGSUNG EKSEKUSI
        reText.OnClientEvent:Connect(function(d)
            if not (d and d.TextData and d.TextData.EffectType == "Exclaim") then return end
            
            local hd = plr.Character and plr.Character:FindFirstChild("Head")
            if hd and d.Container == hd then
                -- Kompensasi ping untuk delay complete
                local pingCompensation = avgPing / 1000
                local adjustedDelay = math.max(0, getgenv().DelayComplete - (pingCompensation * 0.5))
                
                task.wait(adjustedDelay)
                for i = 1, 3 do
                    reFish:FireServer()
                end
            end
        end)

        -- Rod check thread
        task.spawn(function()
            while blActive and getgenv().AutoFish do
                task.wait(0.05)
                pcall(function()
                    if rep:GetExpect("EquippedType") ~= "Fishing Rods" then
                        rodNotEquipped = true
                    else
                        rodNotEquipped = false
                    end
                end)
            end
        end)

        -- MAIN AUTO CAST LOOP dengan adaptive timing
        while blActive and getgenv().AutoFish do
            if not rodNotEquipped then
                cast()
            end
            
            -- Gunakan delay yang sudah dikompensasi dengan ping
            local pingCompensation = avgPing / 1000
            local adaptiveDelay = math.max(0.1, getgenv().DelayCast - pingCompensation)
            
            task.wait(adaptiveDelay)
        end
        
        stopFish()
    end)
end


-- WEBHOOK TAB
local WebhookSection = Tabs.Webhook:Section({
    Title = "Discord Webhook",
    TextSize = 18,
})

Tabs.Webhook:Paragraph({
    Title = "How It Works",
    Desc = [[Webhook monitor works independently from fishing mode.
It monitors your inventory for new fish catches and sends notifications to Discord.

Simply enable the webhook and set your URL - it will detect fish automatically!]],
})

local WebhookURLInput = WebhookSection:Input({
    Title = "Webhook URL",
    Desc = "Paste your Discord webhook URL here",
    Value = "",
    InputIcon = "link",
    Type = "Input",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(input)
        if input and input ~= "" then
            getgenv().WebhookURL = input
            WindUI:Notify({
                Title = "Webhook URL",
                Content = "Webhook URL set successfully",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid webhook URL",
                Duration = 2
            })
        end
    end
})

local TestWebhookButton = WebhookSection:Button({
    Title = "Test Webhook",
    Desc = "Send a test notification to Discord",
    Callback = function()
        if not getgenv().WebhookEnabled then
            WindUI:Notify({
                Title = "Webhook Disabled",
                Content = "Please enable Discord alerts first",
                Duration = 2
            })
            return
        end
        
        if not getgenv().WebhookURL or getgenv().WebhookURL == "" then
            WindUI:Notify({
                Title = "No Webhook URL",
                Content = "Please set your webhook URL first",
                Duration = 2
            })
            return
        end
        
        sendWebhook(
            "Test Fish",
            "Legendary",
            "0.01",
            99999,
            "50.00 kg",
            plr.Name,
            ""
        )
        
        WindUI:Notify({
            Title = "Test Sent",
            Content = "Check your Discord channel!",
            Duration = 3
        })
    end
})

local WebhookRarityDropdown = WebhookSection:Dropdown({
    Title = "Alert on Rarity",
    Values = { "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" },
    Value = { "All" },
    Multi = true,
    AllowNone = true,
    Callback = function(options)
        getgenv().WebhookRarityFilter = options
        
        local filterText = "All"
        if type(options) == "table" then
            if #options == 0 then
                filterText = "None (Disabled)"
            else
                filterText = table.concat(options, ", ")
            end
        elseif type(options) == "string" then
            filterText = options
        end
        
        WindUI:Notify({
            Title = "Rarity Filter",
            Content = "Alerts set for: " .. filterText,
            Duration = 2
        })
    end
})

local WebhookToggle = WebhookSection:Toggle({
    Title = "Enable Discord Alerts",
    Desc = "Monitor inventory and send fish notifications",
    Value = false,
    Callback = function(value)
        getgenv().WebhookEnabled = value
        if value then
            startWebhookMonitor()
            WindUI:Notify({
                Title = "Webhook Active",
                Content = "Now monitoring for fish catches",
                Duration = 2
            })
        else
            stopWebhookMonitor()
            WindUI:Notify({
                Title = "Webhook Stopped",
                Content = "Discord alerts disabled",
                Duration = 2
            })
        end
    end
})

-- FISHING TAB
Tabs.Fishing:Section({
    Title = "Auto Fishing Controls",
    TextSize = 18,
})

local DelayCastInput = Tabs.Fishing:Input({
    Title = "Delay Cast",
    Desc = "Waktu tunggu sebelum cast ulang (detik)",
    Value = "2.5",
    InputIcon = "clock",
    Type = "Input",
    Placeholder = "Masukkan delay cast...",
    Callback = function(input)
        local delay = tonumber(input)
        if delay and delay >= 0.1 then
            getgenv().DelayCast = delay
            WindUI:Notify({
                Title = "Delay Cast",
                Content = "Delay Cast diatur ke " .. delay .. " detik",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Input Tidak Valid",
                Content = "Masukkan angka minimal 0.1",
                Duration = 2
            })
        end
    end
})

local DelayCompleteInput = Tabs.Fishing:Input({
    Title = "Delay Complete",
    Desc = "Waktu tunggu sebelum complete fishing (detik)",
    Value = "1.1",
    InputIcon = "zap",
    Type = "Input",
    Placeholder = "Masukkan delay complete...",
    Callback = function(input)
        local delay = tonumber(input)
        if delay and delay >= 0.1 then
            getgenv().DelayComplete = delay
            WindUI:Notify({
                Title = "Delay Complete",
                Content = "Delay Complete diatur ke " .. delay .. " detik",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Input Tidak Valid",
                Content = "Masukkan angka minimal 0.1",
                Duration = 2
            })
        end
    end
})

local FishingModeDropdown = Tabs.Fishing:Dropdown({
    Title = "Fishing Mode",
    Values = { "Legit", "Blatant" },
    Value = "Legit",
    Callback = function(option)
        getgenv().FishingMode = option
        WindUI:Notify({
            Title = "Fishing Mode",
            Content = "Mode diubah ke " .. option,
            Duration = 2
        })

        if getgenv().AutoFish then
            stopFish()
            
            if option == "Blatant" then
                lgActive = false
                if lgThread then
                    task.cancel(lgThread)
                    lgThread = nil
                end
                if not blActive then
                    startBlat()
                end
            else
                blActive = false
                if blThread then
                    task.cancel(blThread)
                    blThread = nil
                end
                if not lgActive then
                    startLegit()
                end
            end
        end
    end
})

local AutoFishToggle = Tabs.Fishing:Toggle({
    Title = "Enable Auto Fishing",
    Desc = "Otomatis fishing dengan mode yang dipilih",
    Value = false,
    Callback = function(value)
        getgenv().AutoFish = value

        if value then
            WindUI:Notify({
                Title = "Auto Fishing",
                Content = "Auto fishing aktif! Mode: " .. getgenv().FishingMode,
                Duration = 2
            })
            
            if getgenv().FishingMode == "Blatant" then
                if not blActive then
                    startBlat()
                end
            else
                if not lgActive then
                    startLegit()
                end
            end
        else
            WindUI:Notify({
                Title = "Auto Fishing",
                Content = "Auto fishing dinonaktifkan!",
                Duration = 2
            })
            
            stopFish()
            lgActive, blActive = false, false
            
            if lgThread then
                task.cancel(lgThread)
                lgThread = nil
            end
            if blThread then
                task.cancel(blThread)
                blThread = nil
            end
        end
    end
})

local animStopThread = nil
local animConnection = nil

local StopAnimationsToggle = Tabs.Fishing:Toggle({
    Title = "Stop All Animations",
    Desc = "Hentikan semua animasi dengan kekuatan maksimum",
    Value = false,
    Callback = function(value)
        getgenv().StopAllAnimations = value

        if animStopThread then
            task.cancel(animStopThread)
            animStopThread = nil
        end
        
        if animConnection then
            animConnection:Disconnect()
            animConnection = nil
        end

        if value then
            WindUI:Notify({
                Title = "Stop Animations",
                Content = "Semua animasi sedang dihentikan",
                Duration = 2
            })

            animStopThread = task.spawn(function()
                local ac = pcall(function() return require(rs.Controllers.AnimationController) end) and require(rs.Controllers.AnimationController) or nil
                
                while getgenv().StopAllAnimations do
                    pcall(function()
                        if ac and ac.StopAllAnimations then
                            ac:StopAllAnimations()
                        end
                        
                        local char = plr.Character
                        if char then
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                    track:Stop(0)
                                    track:Destroy()
                                end

                                local animator = humanoid:FindFirstChildOfClass("Animator")
                                if animator then
                                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                        track:Stop(0)
                                        track:Destroy()
                                    end
                                end
                                
                                pcall(function()
                                    humanoid:ChangeState(Enum.HumanoidStateType.Landing)
                                end)
                            end
                            
                            for _, obj in pairs(char:GetDescendants()) do
                                if obj:IsA("AnimationTrack") then
                                    obj:Stop(0)
                                    obj:Destroy()
                                end
                            end
                        end
                    end)
                    
                    task.wait(0.001)
                end
            end)
            
            task.spawn(function()
                while getgenv().StopAllAnimations do
                    pcall(function()
                        local char = plr.Character
                        if char then
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                local animator = humanoid:FindFirstChildOfClass("Animator")
                                if animator then
                                    if not animConnection then
                                        animConnection = animator.AnimationPlayed:Connect(function(track)
                                            if getgenv().StopAllAnimations then
                                                task.spawn(function()
                                                    track:Stop(0)
                                                    track:Destroy()
                                                end)
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            
        else
            WindUI:Notify({
                Title = "Stop Animations",
                Content = "Animation stopper dinonaktifkan",
                Duration = 2
            })
        end
    end
})

-- ANTI AFK
plr.Idled:Connect(function()
    pcall(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0))
    end)
end)

Window:SelectTab(1)
