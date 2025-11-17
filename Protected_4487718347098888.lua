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
if wrSuccess then
else
end


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
        -- Get all children dari Items folder
        local itemsFolder = rs:FindFirstChild("Items")
        if not itemsFolder then
            return
        end        
        for _, fishModule in pairs(itemsFolder:GetChildren()) do
            if fishModule:IsA("ModuleScript") then
                moduleCount = moduleCount + 1
                
                -- Force load/require module (not just read)
                local modSuccess, data = pcall(function()
                    local loadedModule = require(fishModule)
                    -- Ensure module is fully loaded by accessing properties
                    if loadedModule then
                        return loadedModule
                    end
                    return nil
                end)

                if modSuccess and data then
                    -- Cache ALL items, not just Fish type
                    if data.Data then
                        -- Check if it has an Id
                        if data.Data.Id then
                            fishModulesCache[data.Data.Id] = {
                                Name = data.Data.Name or fishModule.Name,
                                SellPrice = data.SellPrice or 0,
                                Weight = data.Weight,
                                Probability = data.Probability,
                                Tier = data.Data.Tier or 1,
                                Icon = data.Data.Icon or "",
                                Type = data.Data.Type or "Unknown",
                                FullData = data -- Store full data for reference
                            }
                            successCount = successCount + 1
                        else
                            -- Module doesn't have Id, still count as processed
                            table.insert(failedModules, {name = fishModule.Name, reason = "No ID"})
                        end
                    else
                        -- Module doesn't have Data table
                        table.insert(failedModules, {name = fishModule.Name, reason = "No Data"})
                    end
                else
                    -- Failed to require module
                    table.insert(failedModules, {name = fishModule.Name, reason = "Require failed"})
                    warn("[Fish It] Failed to load:", fishModule.Name)
                end
                
                -- Small delay to prevent overwhelming
                if moduleCount % 50 == 0 then
                    task.wait()
                end
            end
        end
        
        cacheLoaded = true
    end)

    local loadTime = math.round((tick() - loadingStart) * 100) / 100

    if success then
        if #failedModules > 0 then
            for _, fail in ipairs(failedModules) do
            end
        end
    else
    end

    return success, successCount, moduleCount, loadTime
end
local loadSuccess, fishLoaded, totalModules, loadTime = loadFishModules()


-- ========================================
-- PHASE 2: LOAD UI AFTER DATA IS READY
-- ========================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/XenonLoader/WindUI/refs/heads/main/dist/main.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Plant")

local ver="v07"

local function lerpCol(c1,c2,t)return("#%02x%02x%02x"):format(math.floor((1-t)*c1[1]+t*c2[1]),math.floor((1-t)*c1[2]+t*c2[2]),math.floor((1-t)*c1[3]+t*c2[3]))end

local function hex2rgb(h) h=h:sub(1,1)=="#" and h:sub(2) or h return{tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)}end

local function grad(w) if not w or #w==0 then return"Error"end local sc,ec=getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.startingColor or"ea00ff")or hex2rgb("ea00ff"),getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.endingColor or"5700ff")or hex2rgb("5700ff")local r=""local st=1/math.max(#w-1,1)for i=1,#w do r=r..('<font color="%s">%s</font>'):format(lerpCol(sc,ec,st*(i-1)),w:sub(i,i))end return r end

local function fmtVer(v) return ("  v"..v:sub(2):gsub(".","%0.")):sub(1,-2) end

-- Function untuk generate random weight berdasarkan fish data
local function generateWeightForFish(fishData, seed)
    if not fishData or not fishData.Weight then
        return nil
    end

    local weightData = fishData.Weight.Default or fishData.Weight
    if not weightData or not weightData.Min or not weightData.Max then
        return nil
    end

    local min = tonumber(weightData.Min) or 0
    local max = tonumber(weightData.Max) or 0

    if min == 0 and max == 0 then
        return nil
    end

    local rng
    if seed then
        rng = Random.new(seed)
    else
        rng = Random.new()
    end

    -- Generate random weight between min and max
    local randomWeight = min + (max - min) * rng:NextNumber()
    return math.round(randomWeight * 100) / 100  -- Round to 2 decimals
end

local function getActualWeight(lastItem, fishData)
    local actualWeight = nil
    local variant = "Default"

    pcall(function()
        if lastItem and type(lastItem) == "table" then
            -- Try direct Weight property (number)
            if lastItem.Weight and type(lastItem.Weight) == "number" then
                actualWeight = lastItem.Weight
                return
            end

            -- Try lowercase weight
            if lastItem.weight and type(lastItem.weight) == "number" then
                actualWeight = lastItem.weight
                return
            end

            -- Try Metadata table
            if lastItem.Metadata and type(lastItem.Metadata) == "table" then
                if lastItem.Metadata.Weight and type(lastItem.Metadata.Weight) == "number" then
                    actualWeight = lastItem.Metadata.Weight
                    return
                elseif lastItem.Metadata.weight and type(lastItem.Metadata.weight) == "number" then
                    actualWeight = lastItem.Metadata.weight
                    return
                end
            end

            -- Try Data.Weight
            if lastItem.Data and lastItem.Data.Weight and type(lastItem.Data.Weight) == "number" then
                actualWeight = lastItem.Data.Weight
                return
            end
        end
    end)

    -- Determine variant based on actual weight if available
    if actualWeight and fishData and fishData.Weight then
        pcall(function()
            -- Check if weight falls in Big range
            if fishData.Weight.Big then
                local bigMin = fishData.Weight.Big.Min or 0
                local bigMax = fishData.Weight.Big.Max or 0
                if actualWeight >= bigMin and actualWeight <= bigMax then
                    variant = "Big"
                    return
                end
            end
            
            -- Check if weight falls in Huge range (if exists)
            if fishData.Weight.Huge then
                local hugeMin = fishData.Weight.Huge.Min or 0
                local hugeMax = fishData.Weight.Huge.Max or 0
                if actualWeight >= hugeMin and actualWeight <= hugeMax then
                    variant = "Huge"
                    return
                end
            end
            
            -- Check if weight falls in Giant range (if exists)
            if fishData.Weight.Giant then
                local giantMin = fishData.Weight.Giant.Min or 0
                local giantMax = fishData.Weight.Giant.Max or 0
                if actualWeight >= giantMin and actualWeight <= giantMax then
                    variant = "Giant"
                    return
                end
            end
            
            -- Otherwise it's Default
            variant = "Default"
        end)
    end

    -- If no actual weight found, generate random weight based on fish data
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

        -- Get from cache
        if fishModulesCache[fishId] then
            local fishData = fishModulesCache[fishId]

            info.Name = fishData.Name or "Unknown"
            info.SellPrice = fishData.SellPrice or 0

            -- Try to get actual weight from item with variant detection
            local actualWeight, variant = getActualWeight(lastItem, fishData)

            -- Simple weight display
            if actualWeight and actualWeight > 0 then
                local weight = tonumber(actualWeight) or 0
                info.Weight = string.format("%.2f kg", weight)
            elseif fishData.Weight then
                -- Check for Default weight range
                if fishData.Weight.Default then
                    local minW = tonumber(fishData.Weight.Default.Min) or 0
                    local maxW = tonumber(fishData.Weight.Default.Max) or 0
                    info.Weight = string.format("%.2f - %.2f kg", minW, maxW)
                -- Check for Min/Max directly
                elseif fishData.Weight.Min and fishData.Weight.Max then
                    local minW = tonumber(fishData.Weight.Min) or 0
                    local maxW = tonumber(fishData.Weight.Max) or 0
                    info.Weight = string.format("%.2f - %.2f kg", minW, maxW)
                end
            end

            -- Chance - Display as raw decimal value from module
            if fishData.Probability and fishData.Probability.Chance then
                local chance = fishData.Probability.Chance
                info.Chance = tostring(chance)
            end

            -- Rarity
            if fishData.Tier and TiersData then
                local tierInfo = TiersData[fishData.Tier]
                if tierInfo and tierInfo.Name then
                    info.Rarity = tierInfo.Name
                end
            end

            -- Icon
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
Window:DisableTopbarButtons({
    "Fullscreen",
})

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
    Desc = [[<font color="rgb(255,255,255)">NEWS v07:</font>
[+] Pre-load all fish data before UI
[+] Webhook independent from fishing mode
[+] Enhanced initialization process
[+] Better performance and reliability

v06:
[+] Enhanced Fish Info Display
[+] Shows Fish Name, Price, Weight & Chance
]],
})

-- Show loading stats
Tabs.Information:Paragraph({
    Title = "Loading Status",
    Desc = string.format([[<font color="rgb(100,255,100)">✓Modules: %d/%d loaded (%.2fs)</font>]],
        fishLoaded or 0,
        totalModules or 0,
        loadTime or 0,
        wrSuccess and "Loaded" or "Failed",
        tiersSuccess and "Loaded" or "Failed"
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
getgenv().AutoFish=false getgenv().AutoClickSpeed=0.01 getgenv().FishingCooldown=0 getgenv().FishingMode="Legit" getgenv().ReelDelay=1 getgenv().AutoCastDelay=0.3
getgenv().StopAllAnimations = false
local lgThread,blThread,lgActive,blActive

-- WEBHOOK VARIABLES
getgenv().WebhookEnabled = false
getgenv().WebhookURL = ""
getgenv().WebhookRarityFilter = {"All"}

-- HELPER FUNCTION TO STOP FISHING
local function stopFish()pcall(function()local fc=require(rs.Controllers.FishingController)if fc.RequestClientStopFishing then fc:RequestClientStopFishing(true)end end)end

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
        
        if not rarityMatched then
            return
        end
    end

    task.spawn(function()
        local success, err = pcall(function()
            local hs = game:GetService("HttpService")
            local color = rarityColors[rarity] or 8421504

            -- ALWAYS GET ICON FIRST BEFORE SENDING
            local imageUrl = nil
            
            if fishIcon and fishIcon ~= "" then                
                local assetId = fishIcon:match("rbxassetid://(%d+)") 
                    or fishIcon:match("rbxasset://(%d+)")
                    or fishIcon:match("http://www%.roblox%.com/asset/%?id=(%d+)")
                    or fishIcon:match("https://www%.roblox%.com/asset/%?id=(%d+)")
                    or fishIcon:match("^(%d+)$")
                
                if assetId then
                    
                    -- Check if asset ID is extremely long (likely an internal ID)
                    local isLongId = string.len(assetId) > 15
                    
                    if isLongId then
                        imageUrl = nil
                    else
                        -- METHOD 1: Try to get thumbnail URL from Roblox API (tr.rbxcdn.com)
                        local thumbnailSuccess, thumbnailUrl = pcall(function()
                            local thumbUrl = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"
                            
                            local response
                            local requestSuccess = false
                            
                            -- Try different HTTP methods
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
                        
                        -- If thumbnail API succeeded, use it
                        if thumbnailSuccess and thumbnailUrl and (thumbnailUrl:find("rbxcdn%.com") or thumbnailUrl:find("roblox%.com")) then
                            imageUrl = thumbnailUrl
                        else
                            
                            -- Try multiple fallback URLs
                            local fallbackUrls = {
                                "https://assetgame.roblox.com/Thumbs/Asset.ashx?assetId=" .. assetId .. "&x=420&y=420&format=png",
                                "https://www.roblox.com/asset-thumbnail/image?assetId=" .. assetId .. "&width=420&height=420&format=png",
                                "https://assetgame.roblox.com/asset-thumbnail/image?assetId=" .. assetId .. "&width=420&height=420"
                            }
                            
                            -- Use first fallback URL
                            imageUrl = fallbackUrls[1]
                        end
                    end
                else
                end
            else
            end

            -- Wait a bit to ensure icon is processed
            task.wait(0.15)

            local timeNow = os.date("*t")
            local months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
            local footerText = string.format("Avantrix • %s %d, %d", months[timeNow.month], timeNow.day, timeNow.year)

            local embed = {
                title = "🐟 " .. playerName .. " just caught a **" .. fishName .. "**!",
                color = color,
                fields = {
                    {
                        name = "⭐ Rarity",
                        value = rarity,
                        inline = true
                    },
                    {
                        name = "🎯 Catch Chance",
                        value = chance .. "%",
                        inline = true
                    },
                    {
                        name = "💰 Sell Price",
                        value = tostring(price) .. " Coins",
                        inline = true
                    },
                    {
                        name = "⚖️ Weight",
                        value = weight,
                        inline = false
                    }
                },
                timestamp = DateTime.now():ToIsoDate(),
                footer = {
                    text = footerText
                }
            }

            -- Only add image if we successfully got the URL
            if imageUrl and imageUrl ~= "" then
                embed.image = {url = imageUrl}
            else
            end

            local payload = {
                username = "FISH IT | Fish Alert",
                avatar_url = "https://cdn.discordapp.com/attachments/1234567890/fishit-icon.png",
                embeds = { embed }
            }

            local json = hs:JSONEncode(payload)
            
            -- Send to Discord
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
            WindUI:Notify({Title = "Webhook Error", Content = "Failed to send webhook", Duration = 3})
        end
    end)
end

-- Global rep for accessing inventory data
local rep = nil
local webhookMonitorThread = nil

-- WEBHOOK MONITOR (INDEPENDENT - BERJALAN TERPISAH DARI FISHING)
local function startWebhookMonitor()
    -- Stop existing monitor if any
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
        
        if not rep then
            return
        end

        local lastCount = 0
        
        -- Initialize last count
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

        -- Main monitoring loop
        while getgenv().WebhookEnabled do
            task.wait(0.5) -- Check every 0.5 seconds
            
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

                -- New fish detected!
                if fishCount > lastCount then
                    lastCount = fishCount
                    
                    if itms and #itms > 0 then
                        local lastItem = itms[#itms]
                        local itemData = iu:GetItemData(lastItem.Id)
                        
                        if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                            local fishId = itemData.Data.Id
                            local info = getFishInfo(fishId, lastItem)
                            
                            
                            -- Send webhook
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
local function startLegit()lgActive=true lgThread=task.spawn(function()
        repeat task.wait() until game:IsLoaded()

        local nr=rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")local rfCancel=nr:WaitForChild("RF/CancelFishingInputs")

        local cons=require(rs.Shared.Constants)cons.FishingCooldownTime=getgenv().FishingCooldown cons.GetPower=function()return 1 end
        local fc=require(rs.Controllers.FishingController)local Replion=require(rs.Packages.Replion)

        local rep pcall(function()rep=Replion.Client:WaitReplion("Data",10)end)if not rep then return end fc._getPower=function()return 1 end

        local st={IDLE="idle",CASTING="casting",WAITING="waiting",MINIGAME="minigame",REELING="reeling",COMPLETED="completed"}local cs,lg,mgC=st.IDLE,nil,false local cam=workspace.CurrentCamera local lct,cc,stuckTimer,stuckState=0,0,0,st.IDLE

        local function detSt()local g=fc:GetCurrentGUID()local ocd=fc.OnCooldown and fc:OnCooldown()or false if g then if cs~=st.MINIGAME then lg=g mgC=false end return st.MINIGAME end if lg and not g then local busy=false pcall(function()if(fc.FishingLine and fc.FishingLine.Parent)or(fc.FishingBobber and fc.FishingBobber.Parent)or fc._isFishing or fc._isReeling then busy=true end end)if busy then return st.REELING else if mgC then return st.COMPLETED else lg=nil return st.IDLE end end end return ocd and st.WAITING or st.IDLE end

        while lgActive and getgenv().AutoFish and getgenv().FishingMode=="Legit"do local ct=tick()pcall(function()if not rep or rep:GetExpect("EquippedType")~="Fishing Rods"then cs,lg,mgC,stuckTimer,stuckState=st.IDLE,nil,false,0,st.IDLE stopFish()return end local ns=detSt()if ns~=cs then cs=ns stuckTimer=0 stuckState=cs else stuckTimer=stuckTimer+1 end if cs==st.IDLE then if not fc:OnCooldown()then rfCancel:InvokeServer()fc:RequestChargeFishingRod(nil,true)cs=st.CASTING stuckTimer=0 end elseif cs==st.MINIGAME then if ct-lct>=getgenv().AutoClickSpeed+math.random()*0.1 then fc:FishingMinigameClick()lct=ct cc+=1 end if not fc:GetCurrentGUID()and lg then mgC=true cs=st.COMPLETED stuckTimer=0 end elseif cs==st.WAITING then if stuckTimer>150 then lgActive=false stopFish()return end elseif cs==st.COMPLETED then lg,mgC,cs,stuckTimer=nil,false,st.IDLE,0 end if stuckTimer>200 and cs==stuckState then lgActive=false stopFish()return end end)if cc>=9e9 then task.wait(0.1+math.random()*0.1)cc=0 else task.wait(0.05)end end
    end)
end

local function startBlat()if blThread then task.cancel(blThread)blThread=nil end blActive=true blThread=task.spawn(function()
        local nr=rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

		local rfCharge,rfStart,reFish,reEquip,rfCancel,reText=nr:WaitForChild("RF/ChargeFishingRod"),nr:WaitForChild("RF/RequestFishingMinigameStarted"),nr:WaitForChild("RE/FishingCompleted"),nr:WaitForChild("RE/EquipToolFromHotbar"),nr:WaitForChild("RF/CancelFishingInputs"),nr:WaitForChild("RE/ReplicateTextEffect")

		local ac,Replion,iu=require(rs.Controllers.AnimationController),require(rs.Packages.Replion),require(rs.Shared.ItemUtility)

		local isProc,hasReel,compFire,isReel,canCast,lfc,lct,lcTime,waitFish,firstCast=false,false,false,false,true,0,tick(),0,false,false
		local lastRodCheck,rodNotEquipped=tick(),false

		pcall(function()rep=Replion.Client:WaitReplion("Data",10)end)if not rep then WindUI:Notify({Title="Error",Content="Failed to get player data!",Duration=3})return end

		local function getFish()local c=0 pcall(function()for _,i in ipairs(rep:GetExpect({"Inventory","Items"}))do local d=iu:GetItemData(i.Id)if d and d.Data.Type=="Fish"then c+=1 end end end)return c end

		lfc=getFish()

		local function cast()if not canCast or isReel or rodNotEquipped then return end canCast=false task.spawn(function()pcall(function()rfCancel:InvokeServer()reEquip:FireServer(1)task.wait(0.02)rfCharge:InvokeServer(tick())task.wait(0.02)rfStart:InvokeServer(-1.25,100)end)isProc,hasReel,compFire,isReel,waitFish,firstCast=false,false,false,false,false,true lct=tick()task.defer(function()canCast=true end)end)end

		cast()

		local invTh=task.spawn(function()while blActive and getgenv().AutoFish do task.defer(function()local cfc=getFish()if cfc>lfc then lfc=cfc isReel=false waitFish,lcTime=false,0 pcall(function()ac:StopAnimation("FishCaught")ac:StopAnimation("ReelIntermission")end)task.spawn(function()task.wait(math.max(getgenv().AutoCastDelay,0.05))lct=tick()task.defer(cast)end)end end)task.wait(0.1)end end)

		local monTh=task.spawn(function()while blActive and getgenv().AutoFish do task.defer(function()pcall(function()if rep:GetExpect("EquippedType")~="Fishing Rods"then rodNotEquipped=true return end rodNotEquipped=false local ri=ac:GetAnimationData("ReelingIdle")if ri and not hasReel then hasReel,isReel=true,true end local int=ac:GetAnimationData("ReelIntermission")if int and hasReel and not compFire then compFire,isProc=true,true task.spawn(function()task.wait(getgenv().ReelDelay or 0.02)for i=1,2 do reFish:FireServer()end task.wait(0.001)if firstCast and not waitFish then waitFish=true lcTime=tick()end end)isReel=false end end)end)task.wait(0.03)end end)

		reText.OnClientEvent:Connect(function(d)if not(d and d.TextData and d.TextData.EffectType=="Exclaim")then return end local hd=plr.Character and plr.Character:FindFirstChild("Head")if hd and d.Container==hd then isReel=true task.spawn(function()task.wait(getgenv().ReelDelay or 0.015)for i=1,3 do reFish:FireServer()end task.wait(0.001)if firstCast and not waitFish then waitFish=true lcTime=tick()end isReel=false lct=tick()end)end end)

		task.spawn(function()local lfTick=0 while blActive and getgenv().AutoFish do if not firstCast then task.wait(1)continue end if rodNotEquipped then task.wait(0.5)continue end local now=tick()local sComp,sCast,sLastFix=now-lcTime,now-lct,now-lfTick if waitFish and sComp>0.5 and sLastFix>2 then lfTick=now waitFish=false lcTime=0 if not isReel and canCast then cast()end end if sCast>6 and not isReel and not waitFish and sLastFix>4 then lfTick=now waitFish=false WindUI:Notify({Title="Auto Fix",Content="Recasting stuck...",Duration=0.8})cast()lct=now end task.wait(0.05)end end)

		while blActive and getgenv().AutoFish do if not rep:GetExpect("EquippedType")=="Fishing Rods" then blActive=false break end task.wait(0.5)end if invTh then task.cancel(invTh)end if monTh then task.cancel(monTh)end stopFish()end)end

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
        
        -- Send test webhook
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

local ReelDelayInput = Tabs.Fishing:Input({
    Title = "Reel Delay",
    Desc = "Delay before completing fishing (seconds)",
    Value = "1",
    InputIcon = "clock",
    Type = "Input",
    Placeholder = "Enter delay in seconds...",
    Callback = function(input)
        local delay = tonumber(input)
        if delay and delay >= 0.1 then
            getgenv().ReelDelay = delay
            WindUI:Notify({
                Title = "Reel Delay",
                Content = "Reel delay set to " .. delay .. " seconds",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid number (minimum 0.1)",
                Duration = 2
            })
        end
    end
})

local AutoCastDelayInput = Tabs.Fishing:Input({
    Title = "Auto Cast Delay",
    Desc = "Delay for instant cast after catching fish",
    Value = "0.3",
    InputIcon = "zap",
    Type = "Input",
    Placeholder = "Enter delay in seconds...",
    Callback = function(input)
        local delay = tonumber(input)
        if delay and delay >= 0 then
            getgenv().AutoCastDelay = delay
            WindUI:Notify({
                Title = "Auto Cast Delay",
                Content = "Auto cast delay set to " .. delay .. " seconds",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid number (minimum 0)",
                Duration = 2
            })
        end
    end
})

AutoCastDelayInput:Lock()

local FishingModeDropdown = Tabs.Fishing:Dropdown({
    Title = "Fishing Mode",
    Values = { "Legit", "Blatant" },
    Value = "Legit",
    Callback = function(option)
        getgenv().FishingMode = option
        WindUI:Notify({
            Title = "Fishing Mode",
            Content = "Mode changed to " .. option,
            Duration = 2
        })

        if getgenv().AutoFish then stopFish()if option=="Blatant"then lgActive=false if lgThread then task.cancel(lgThread)lgThread=nil end if not blActive then startBlat()end else blActive=false if blThread then task.cancel(blThread)blThread=nil end if not lgActive then startLegit()end end end
    end
})

local AutoFishToggle = Tabs.Fishing:Toggle({
    Title = "Enable Auto Fishing",
    Desc = "Automatically fish with selected mode",
    Value = false,
    Callback = function(value)
        getgenv().AutoFish = value

        if value then WindUI:Notify({Title="Auto Fishing",Content="Auto fishing enabled! Mode: "..getgenv().FishingMode,Duration=2})if getgenv().FishingMode=="Blatant"then if not blActive then startBlat()end else if not lgActive then startLegit()end end else WindUI:Notify({Title="Auto Fishing",Content="Auto fishing disabled!",Duration=2})stopFish()lgActive,blActive=false,false if lgThread then task.cancel(lgThread)lgThread=nil end if blThread then task.cancel(blThread)blThread=nil end end
    end
})

local animStopThread = nil
local animConnection = nil

local StopAnimationsToggle = Tabs.Fishing:Toggle({
    Title = "Stop All Animations",
    Desc = "Stop all animations with maximum power",
    Value = false,
    Callback = function(value)
        getgenv().StopAllAnimations = value

        -- Stop existing thread and connections
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
                Content = "All animations are now being stopped",
                Duration = 2
            })

            -- Create aggressive animation stopper
            animStopThread = task.spawn(function()
                local ac = pcall(function() return require(rs.Controllers.AnimationController) end) and require(rs.Controllers.AnimationController) or nil
                
                while getgenv().StopAllAnimations do
                    pcall(function()
                        -- Method 1: Stop via AnimationController if available
                        if ac and ac.StopAllAnimations then
                            ac:StopAllAnimations()
                        end
                        
                        -- Method 2: Direct character animation stopping
                        local char = plr.Character
                        if char then
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                -- Stop ALL playing tracks immediately
                                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                                    track:Stop(0)
                                    track:Destroy()
                                end

                                -- Stop Animator tracks
                                local animator = humanoid:FindFirstChildOfClass("Animator")
                                if animator then
                                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                        track:Stop(0)
                                        track:Destroy()
                                    end
                                end
                                
                                -- Reset humanoid state
                                pcall(function()
                                    humanoid:ChangeState(Enum.HumanoidStateType.Landing)
                                end)
                            end
                            
                            -- Stop AnimationController tracks
                            for _, obj in pairs(char:GetDescendants()) do
                                if obj:IsA("AnimationTrack") then
                                    obj:Stop(0)
                                    obj:Destroy()
                                end
                            end
                        end
                    end)
                    
                    task.wait(0.001) -- Ultra fast checking
                end
            end)
            
            -- Additional protection: Hook animation playing
            task.spawn(function()
                while getgenv().StopAllAnimations do
                    pcall(function()
                        local char = plr.Character
                        if char then
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                local animator = humanoid:FindFirstChildOfClass("Animator")
                                if animator then
                                    -- Intercept AnimationPlayed event
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
                Content = "Animation stopper disabled",
                Duration = 2
            })
        end
    end
})

-- ANTI AFK
plr.Idled:Connect(function()pcall(function()vu:CaptureController()vu:ClickButton2(Vector2.new(0,0))end)end)
Window:SelectTab(1)
