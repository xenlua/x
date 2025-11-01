local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/XenonLoader/WindUI/refs/heads/main/dist/main.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Plant")

local ver="v09"

local function lerpCol(c1,c2,t)return("#%02x%02x%02x"):format(math.floor((1-t)*c1[1]+t*c2[1]),math.floor((1-t)*c1[2]+t*c2[2]),math.floor((1-t)*c1[3]+t*c2[3]))end

local function hex2rgb(h) h=h:sub(1,1)=="#" and h:sub(2) or h return{tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)}end

local function grad(w) if not w or #w==0 then return"Error"end local sc,ec=getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.startingColor or"ea00ff")or hex2rgb("ea00ff"),getgenv and getgenv().GradientColor and hex2rgb(getgenv().GradientColor.endingColor or"5700ff")or hex2rgb("5700ff")local r=""local st=1/math.max(#w-1,1)for i=1,#w do r=r..('<font color="%s">%s</font>'):format(lerpCol(sc,ec,st*(i-1)),w:sub(i,i))end return r end

local function fmtVer(v) return ("  v"..v:sub(2):gsub(".","%0.")):sub(1,-2) end

-- Cache untuk menyimpan fish modules yang sudah di-load
local fishModulesCache = {}
local cacheLoaded = false
local WeightRandom = nil
local TiersData = nil

-- Load WeightRandom module
pcall(function()
    WeightRandom = require(rs.Shared.WeightRandom)
end)

-- Load Tiers data for rarity
pcall(function()
    TiersData = require(rs.Tiers)
end)

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

local function loadFishModules()
    if cacheLoaded then return end

    pcall(function()
        for _, fishModule in pairs(rs.Items:GetChildren()) do
            if fishModule:IsA("ModuleScript") then
                local success, data = pcall(function()
                    return require(fishModule)
                end)

                if success and data and data.Data and data.Data.Type == "Fish" then
                    fishModulesCache[data.Data.Id] = {
                        Name = data.Data.Name,
                        SellPrice = data.SellPrice or 0,
                        Weight = data.Weight,
                        Probability = data.Probability,
                        Tier = data.Data.Tier or 1,
                        Icon = data.Data.Icon or ""
                    }
                end
            end
        end
        cacheLoaded = true
    end)
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
    Desc = [[<font color="rgb(255,255,255)">NEWS v09:</font>
[+] Deteksi text success yang benar
[+] Support: OK, GOOD, GREAT, AMAZING, PERFECT!, PERFECTION!
[+] Fallback ke Exclaim jika text gagal
[+] Smart reset berdasarkan MultiCastDelay

v08:
[+] Fixed Multi-Cast Queue System
[+] FIFO Pattern: Cast bergantian
[+] Auto-reset jika sistem macet
]],
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
getgenv().AutoFish=false getgenv().AutoClickSpeed=0.1 getgenv().FishingCooldown=0 getgenv().FishingMode="Legit" getgenv().ReelDelay=1.8 getgenv().AutoCastDelay=0.3 getgenv().MultiCastDelay=1 getgenv().MultiCastEnabled=false
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

            local imageUrl = nil            
            if fishIcon and fishIcon ~= "" then
                local assetId = fishIcon:match("rbxassetid://(%d+)") 
                    or fishIcon:match("rbxasset://(%d+)")
                    or fishIcon:match("http://www%.roblox%.com/asset/%?id=(%d+)")
                    or fishIcon:match("^(%d+)$")
                
                if assetId then
                    local thumbnailSuccess, thumbnailUrl = pcall(function()
                        local thumbUrl = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"
                        local response
                        
                        if request then
                            response = request({Url = thumbUrl, Method = "GET"})
                        elseif syn and syn.request then
                            response = syn.request({Url = thumbUrl, Method = "GET"})
                        elseif http_request then
                            response = http_request({Url = thumbUrl, Method = "GET"})
                        else
                            response = {Body = hs:GetAsync(thumbUrl)}
                        end
                        
                        if response and response.Body then
                            local data = hs:JSONDecode(response.Body)
                            if data and data.data and data.data[1] and data.data[1].imageUrl then
                                return data.data[1].imageUrl
                            end
                        end
                        return nil
                    end)
                    
                    if thumbnailSuccess and thumbnailUrl then
                        imageUrl = thumbnailUrl
                    else
                        imageUrl = "https://assetdelivery.roblox.com/v1/asset/?id=" .. assetId
                    end
                end
            end

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

            if imageUrl then
                embed.image = {url = imageUrl}
            end

            local payload = {
                username = "FISH IT | Fish Alert",
                avatar_url = "https://cdn.discordapp.com/attachments/1234567890/fishit-icon.png",
                embeds = { embed }
            }

            local json = hs:JSONEncode(payload)
            
            local response
            if request then
                response = request({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
            elseif syn and syn.request then
                response = syn.request({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
            elseif http_request then
                response = http_request({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
            else
                response = hs:PostAsync(getgenv().WebhookURL, json, Enum.HttpContentType.ApplicationJson, false)
            end
        end)

        if not success then
            WindUI:Notify({Title = "Webhook Error", Content = "Failed to send webhook", Duration = 3})
        end
    end)
end

-- LEGIT FISHING FUNCTION
local function startLegit()lgActive=true lgThread=task.spawn(function()
        repeat task.wait() until game:IsLoaded()

        local nr=rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")local rfCancel=nr:WaitForChild("RF/CancelFishingInputs")

        local cons=require(rs.Shared.Constants)cons.FishingCooldownTime=getgenv().FishingCooldown cons.GetPower=function()return 1 end
        local fc=require(rs.Controllers.FishingController)local Replion=require(rs.Packages.Replion)

        local rep pcall(function()rep=Replion.Client:WaitReplion("Data",10)end)if not rep then return end fc._getPower=function()return 1 end

        local st={IDLE="idle",CASTING="casting",WAITING="waiting",MINIGAME="minigame",REELING="reeling",COMPLETED="completed"}local cs,lg,mgC=st.IDLE,nil,false local cam=workspace.CurrentCamera local lct,cc=0,0


        local function detSt()local g=fc:GetCurrentGUID()local ocd=fc.OnCooldown and fc:OnCooldown()or false if g then if cs~=st.MINIGAME then lg=g mgC=false end return st.MINIGAME end if lg and not g then local busy=false pcall(function()if(fc.FishingLine and fc.FishingLine.Parent)or(fc.FishingBobber and fc.FishingBobber.Parent)or fc._isFishing or fc._isReeling then busy=true end end)if busy then return st.REELING else if mgC then return st.COMPLETED else lg=nil return st.IDLE end end end return ocd and st.WAITING or st.IDLE end

        while lgActive and getgenv().AutoFish and getgenv().FishingMode=="Legit"do local ct=tick()pcall(function()if not rep or rep:GetExpect("EquippedType")~="Fishing Rods"then cs,lg,mgC=st.IDLE,nil,false stopFish()return end local ns=detSt()if ns~=cs then cs=ns end if cs==st.IDLE then if not fc:OnCooldown()then rfCancel:InvokeServer()fc:RequestChargeFishingRod(nil,true)cs=st.CASTING end elseif cs==st.MINIGAME then if ct-lct>=getgenv().AutoClickSpeed+math.random()*0.1 then fc:FishingMinigameClick()lct=ct cc+=1 end if not fc:GetCurrentGUID()and lg then mgC=true cs=st.COMPLETED end elseif cs==st.COMPLETED then lg,mgC,cs=nil,false,st.IDLE end end)if cc>=9e9 then task.wait(0.1+math.random()*0.1)cc=0 else task.wait()end end
    end)
end

-- Global rep for accessing inventory data
local rep = nil

-- WEBHOOK MONITOR (INDEPENDENT)
local function startWebhookMonitor()
    task.spawn(function()
        local Replion = require(rs.Packages.Replion)
        local iu = require(rs.Shared.ItemUtility)
        local repData = nil
        pcall(function()repData=Replion.Client:WaitReplion("Data",10)end)
        if not repData then return end

        local lastCount = 0
        while getgenv().WebhookEnabled do
            task.defer(function()
                pcall(function()
                    local itms=repData:GetExpect({"Inventory","Items"})
                    local fishCount = 0
                    if itms then
                        for _,i in ipairs(itms)do
                            local d=iu:GetItemData(i.Id)
                            if d and d.Data.Type=="Fish"then fishCount+=1 end
                        end
                    end

                    if fishCount > lastCount then
                        lastCount = fishCount
                        if itms and #itms>0 then
                            local lastItem = itms[#itms]
                            local itemData = iu:GetItemData(lastItem.Id)
                            if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                                local fishId = itemData.Data.Id
                                local info = getFishInfo(fishId, lastItem)
                                sendWebhook(info.Name, info.Rarity, info.Chance, tostring(info.SellPrice), info.Weight, plr.Name, info.Icon)
                            end
                        end
                    end
                end)
            end)
            task.wait(0.5)
        end
    end)
end

-- BLATANT FISHING WITH QUEUE SYSTEM
local function startBlat()
	if blThread then 
		task.cancel(blThread)
		blThread=nil 
	end 
	
	blActive=true 
	blThread=task.spawn(function()
		-- Load fish modules at start
		loadFishModules()

		local nr=rs:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

		local rfCharge=nr:WaitForChild("RF/ChargeFishingRod")
		local rfStart=nr:WaitForChild("RF/RequestFishingMinigameStarted")
		local reFish=nr:WaitForChild("RE/FishingCompleted")
		local reEquip=nr:WaitForChild("RE/EquipToolFromHotbar")
		local rfCancel=nr:WaitForChild("RF/CancelFishingInputs")
		local reText=nr:WaitForChild("RE/ReplicateTextEffect")

		local ac=require(rs.Controllers.AnimationController)
		local Replion=require(rs.Packages.Replion)
		local iu=require(rs.Shared.ItemUtility)

		-- Queue system
		local castQueue = {}
		local waitingForReel = {}
		local textConnection = nil
		local monitorThread = nil
		local invThread = nil

		pcall(function()rep=Replion.Client:WaitReplion("Data",10)end)
		if not rep then 
			WindUI:Notify({Title="Error",Content="Failed to get player data!",Duration=3})
			return 
		end

		local function getFish()
			local c=0 
			pcall(function()
				for _,i in ipairs(rep:GetExpect({"Inventory","Items"}))do 
					local d=iu:GetItemData(i.Id)
					if d and d.Data.Type=="Fish"then 
						c+=1 
					end 
				end 
			end)
			return c 
		end

		local function getLastFish()
			local n="Unknown Fish"
			local p,w,c,r,ico="0 coins","0-0 kg","0%","Unknown",""

			pcall(function()
				local itms=rep:GetExpect({"Inventory","Items"})
				if itms and #itms>0 then
					local lastItem = itms[#itms]
					local itemData = iu:GetItemData(lastItem.Id)

					if itemData and itemData.Data and itemData.Data.Type == "Fish" then
						local fishId = itemData.Data.Id
						local info = getFishInfo(fishId, lastItem)

						n = info.Name
						p = tostring(info.SellPrice)
						w = info.Weight
						c = info.Chance
						r = info.Rarity
						ico = info.Icon
					end
				end
			end)

			return n,p,w,c,r,ico
		end

		local lfc=getFish()

		local function cast()
			if not blActive or not getgenv().AutoFish then return end
			
			local castId = tick()
			local castData = {
				id = castId,
				time = castId,
				waitingForReel = true,
				completed = false
			}
			
			table.insert(castQueue, castData)
			waitingForReel[castId] = castData

			task.spawn(function()
				pcall(function()
					rfCancel:InvokeServer()
					reEquip:FireServer(1)
					task.wait(0.02)
					rfCharge:InvokeServer(castId)
					task.wait(0.02)
					rfStart:InvokeServer(-1.25,100)
				end)
			end)

			return castId
		end

		local function completeCast(castId)
			task.spawn(function()
				-- Tunggu ReelDelay
				task.wait(getgenv().ReelDelay or 1.8)
				
				-- Fire FishingCompleted 2x
				pcall(function()
					for i = 1, 2 do
						reFish:FireServer()
						task.wait(0.01)
					end
				end)
				
				-- Mark completed dan remove dari waiting
				if waitingForReel[castId] then
					waitingForReel[castId].completed = true
					waitingForReel[castId] = nil
				end
				
				-- Tunggu AutoCastDelay
				task.wait(math.max(getgenv().AutoCastDelay or 0.3, 0.1))
				
				-- Lempar cast baru jika masih aktif
				if blActive and getgenv().AutoFish then
					cast()
				end
			end)
		end

		-- Pattern: Lempar Cast1 → tunggu delay → Lempar Cast2
		if getgenv().MultiCastEnabled then
			cast()
			task.spawn(function()
				task.wait(getgenv().MultiCastDelay or 1)
				if blActive and getgenv().AutoFish then
					cast()
				end
			end)
		else
			cast()
		end

		-- Inventory monitoring thread
		invThread=task.spawn(function()
			while blActive and getgenv().AutoFish do
				task.defer(function()
					pcall(function()
						local cfc=getFish()
						if cfc>lfc then
							lfc=cfc
							pcall(function()
								ac:StopAnimation("FishCaught")
								ac:StopAnimation("ReelIntermission")
							end)
							local n,p,w,c,r,ico=getLastFish()

							task.spawn(function()
								WindUI:Notify({
									Title="Fish Caught!",
									Content=string.format([[%s
Rarity: %s
Price: %s coins
Weight: %s
Chance: %s
Total: %d fish]],
										n,r,p,w,c,cfc
									),
									Duration=4
								})
							end)
						end
					end)
				end)
				task.wait(0.1)
			end
		end)

		-- Text handler untuk tracking success text (OK, GOOD, GREAT, etc)
		local successTexts = {
			["OK"] = true,
			["GOOD"] = true,
			["GREAT"] = true,
			["AMAZING"] = true,
			["PERFECT!"] = true,
			["PERFECTION!"] = true
		}
		
		textConnection = reText.OnClientEvent:Connect(function(d)
			if not blActive or not getgenv().AutoFish then return end
			local hd=plr.Character and plr.Character:FindFirstChild("Head")
			if hd and d.Container==hd then
				if d.TextData then
					local textType = d.TextData.EffectType
					local textContent = d.TextData.Text
					local now = tick()
					
					-- Check jika text adalah success text (OK, GOOD, GREAT, dll)
					if textContent and successTexts[textContent] then
						-- Success text terdeteksi, cari cast yang paling lama
						for i = 1, #castQueue do
							local castData = castQueue[i]
							if castData and castData.waitingForReel and not castData.completed then
								-- Check apakah sudah cukup lama (minimal 0.3s sejak cast)
								if now - castData.time >= 0.3 then
									castData.waitingForReel = false
									completeCast(castData.id)
									table.remove(castQueue, i)
									break
								end
							end
						end
					elseif textType == "Exclaim" then
						-- Backup: Exclaim juga bisa jadi tanda berhasil
						for i = 1, #castQueue do
							local castData = castQueue[i]
							if castData and castData.waitingForReel and not castData.completed then
								if now - castData.time >= 0.3 then
									castData.waitingForReel = false
									completeCast(castData.id)
									table.remove(castQueue, i)
									break
								end
							end
						end
					end
				end
			end
		end)

		-- Monitor system - auto reset jika macet (dengan delay sesuai MultiCastDelay)
		local lastResetTime = 0
		monitorThread = task.spawn(function()
			while blActive and getgenv().AutoFish do
				-- Monitor interval berdasarkan MultiCastDelay + buffer
				local monitorInterval = math.max((getgenv().MultiCastDelay or 1) * 2, 10)
				task.wait(monitorInterval)
				
				if not blActive or not getgenv().AutoFish then break end
				
				local now = tick()
				-- Cegah reset spam, minimal delay = MultiCastDelay * 3
				local minResetDelay = (getgenv().MultiCastDelay or 1) * 3
				if now - lastResetTime < minResetDelay then
					continue
				end
				
				-- Check apakah ada cast aktif
				local hasActiveCast = false
				for _, castData in ipairs(castQueue) do
					if castData and castData.waitingForReel and not castData.completed then
						hasActiveCast = true
						break
					end
				end
				
				-- Jika tidak ada cast aktif, RESET
				if not hasActiveCast then
					lastResetTime = now
					
					-- Clear queue
					castQueue = {}
					waitingForReel = {}
					
					-- Stop fishing
					pcall(function()
						rfCancel:InvokeServer()
						stopFish()
					end)
					
					task.wait(0.5)
					
					-- Restart pattern jika masih aktif
					if blActive and getgenv().AutoFish then
						if getgenv().MultiCastEnabled then
							cast()
							task.spawn(function()
								task.wait(getgenv().MultiCastDelay or 1)
								if blActive and getgenv().AutoFish then
									cast()
								end
							end)
						else
							cast()
						end
					end
				end
			end
		end)

		-- Cleanup old casts
		task.spawn(function()
			while blActive and getgenv().AutoFish do
				task.wait(5)
				local now = tick()
				
				-- Clean waitingForReel
				for castId, castData in pairs(waitingForReel) do
					if now - castData.time > 30 then
						waitingForReel[castId] = nil
					end
				end
				
				-- Clean castQueue
				for i = #castQueue, 1, -1 do
					if castQueue[i] and now - castQueue[i].time > 30 then
						table.remove(castQueue, i)
					end
				end
			end
		end)

		-- Wait until stopped
		while blActive and getgenv().AutoFish do 
			task.wait(1)
		end
		
		-- CLEANUP saat toggle off
		blActive = false
		
		-- Disconnect text handler
		if textConnection then
			textConnection:Disconnect()
			textConnection = nil
		end
		
		-- Cancel threads
		if invThread then
			task.cancel(invThread)
			invThread = nil
		end
		
		if monitorThread then
			task.cancel(monitorThread)
			monitorThread = nil
		end
		
		-- Clear queues
		castQueue = {}
		waitingForReel = {}
		
		-- Stop fishing
		stopFish()
	end)
end

-- WEBHOOK TAB
local WebhookSection = Tabs.Webhook:Section({
    Title = "Discord Webhook",
    TextSize = 18,
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
    Desc = "Send fish catch notifications to Discord",
    Value = false,
    Callback = function(value)
        getgenv().WebhookEnabled = value
        if value then
            startWebhookMonitor()
            WindUI:Notify({
                Title = "Webhook",
                Content = "Discord alerts enabled",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Webhook",
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
    Value = "1.8",
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

local MultiCastDelayInput = Tabs.Fishing:Input({
    Title = "Multi Cast Delay",
    Desc = "Delay between multiple casts (seconds)",
    Value = "1",
    InputIcon = "layers",
    Type = "Input",
    Placeholder = "Enter delay in seconds...",
    Callback = function(input)
        local delay = tonumber(input)
        if delay and delay >= 0.5 then
            getgenv().MultiCastDelay = delay
            WindUI:Notify({
                Title = "Multi Cast Delay",
                Content = "Multi cast delay set to " .. delay .. " seconds",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid number (minimum 0.5)",
                Duration = 2
            })
        end
    end
})

local MultiCastToggle = Tabs.Fishing:Toggle({
    Title = "Enable Multi Cast",
    Desc = "Cast multiple rods at once for faster fishing",
    Value = false,
    Callback = function(value)
        getgenv().MultiCastEnabled = value
        WindUI:Notify({
            Title = "Multi Cast",
            Content = value and "Multi cast enabled!" or "Multi cast disabled!",
            Duration = 2
        })
    end
})

local AutoClickSpeedInput = Tabs.Fishing:Input({
    Title = "Auto Click Speed",
    Desc = "Speed between clicks in Legit mode (seconds)",
    Value = "0.1",
    InputIcon = "mouse-pointer",
    Type = "Input",
    Placeholder = "Enter speed in seconds...",
    Callback = function(input)
        local speed = tonumber(input)
        if speed and speed >= 0.01 then
            getgenv().AutoClickSpeed = speed
            WindUI:Notify({
                Title = "Auto Click Speed",
                Content = "Click speed set to " .. speed .. " seconds",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid number (minimum 0.01)",
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
            Content = "Mode changed to " .. option,
            Duration = 2
        })

        if getgenv().AutoFish then 
            stopFish()
            if option=="Blatant"then 
                lgActive=false 
                if lgThread then 
                    task.cancel(lgThread)
                    lgThread=nil 
                end 
                if not blActive then 
                    startBlat()
                end 
            else 
                blActive=false 
                if blThread then 
                    task.cancel(blThread)
                    blThread=nil 
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
    Desc = "Automatically fish with selected mode",
    Value = false,
    Callback = function(value)
        getgenv().AutoFish = value

        if value then 
            WindUI:Notify({
                Title="Auto Fishing",
                Content="Auto fishing enabled! Mode: "..getgenv().FishingMode,
                Duration=2
            })
            if getgenv().FishingMode=="Blatant"then 
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
                Title="Auto Fishing",
                Content="Auto fishing disabled!",
                Duration=2
            })
            
            -- Stop everything
            stopFish()
            lgActive=false
            blActive=false
            
            if lgThread then 
                task.cancel(lgThread)
                lgThread=nil 
            end 
            
            if blThread then 
                task.cancel(blThread)
                blThread=nil 
            end
        end
    end
})

-- ANTI AFK
plr.Idled:Connect(function()
    pcall(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0,0))
    end)
end)

Window:SelectTab(1)
