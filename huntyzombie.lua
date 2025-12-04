-- Hunty Zombie Script (Cleaned Version)
-- Original from discord.gg/25ms

-- Remove existing GUI if present
if game:GetService("CoreGui"):FindFirstChild("ToraScript") then 
    game:GetService("CoreGui").ToraScript:Destroy() 
end

-- Load library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = Library:CreateWindow("Hunty Zombie")

-- Variables
local TimestampOffset = 0
local LocalPlayer = game:GetService("Players").LocalPlayer
local Distance = 0

-- Timestamp Attack Box
Window:AddBox({
    text = "timestamp attack (1,2, or -1,-2)", 
    flag = "box", 
    value = "timestamp fix", 
    callback = function(value)
        TimestampOffset = tonumber(value) or 0
    end
})

-- Auto Attack Toggle
Window:AddToggle({
    text = "Auto Attack", 
    flag = "toggle", 
    state = false, 
    callback = function(state)
        _G.Attack = state
        print("Attack:", state)
        if state then
            Attack()
        end
    end
})

function Attack()
    spawn(function()
        while _G.Attack do
            task.wait(0.1)
            pcall(function()
                local timestamp = os.time() + tick() % 1
                local args = {
                    buffer.fromstring("\8\4\1"), 
                    {timestamp + TimestampOffset}
                }
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args))
            end)
        end
    end)
end

-- Distance Slider
Window:AddSlider({
    text = "Set Distance", 
    flag = "slider1", 
    value = 0, 
    min = 0, 
    max = 20, 
    callback = function(value)
        Distance = value
    end
})

-- Auto Mobs Toggle
Window:AddToggle({
    text = "Auto Mobs", 
    flag = "autoMobs", 
    state = false, 
    callback = function(state)
        _G.Mobs = state
        if state then
            spawn(AutoMobs)
        end
    end
})

function AutoMobs()
    spawn(function()
        -- Wait for character
        if LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
        
        -- Wait until all rooms are activated
        repeat
            task.wait(0.5)
            
            -- Check objective
            if LocalPlayer.PlayerGui.MainScreen.ObjectiveDisplay.ObjectiveElement.List.Value.Label.Text ~= "0" then
                _G.Mobs = true
            else
                _G.Mobs = false
                task.wait(7)
            end
            
            -- Check for unactivated rooms
            local allRoomsActivated = true
            for _, descendant in pairs(workspace:GetDescendants()) do
                if descendant:IsA("Model") and descendant:GetAttribute("roomIndex") and not descendant:GetAttribute("activated") then
                    allRoomsActivated = false
                    break
                end
            end
        until allRoomsActivated or not _G.Mobs
        
        -- Main loop
        while true do
            task.wait()
            
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            -- Find and teleport to mob
            for _, descendant in pairs(workspace.Entities:GetDescendants()) do
                if descendant.Name == "HumanoidRootPart" and descendant.Anchored == true and rootPart then
                    rootPart.CFrame = descendant.CFrame * CFrame.new(0, Distance, 0)
                end
            end
            
            if not _G.Mobs then 
                return 
            end
        end
    end)
end

-- Reconnect on character respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    if _G.Mobs then
        task.wait(1)
        AutoMobs()
    end
end)

-- Auto Doors Toggle
Window:AddToggle({
    text = "Auto Doors", 
    flag = "autoDoors", 
    state = false, 
    callback = function(state)
        _G.AutoDoors = state
        if state then
            spawn(AutoDoors)
        end
    end
})

function AutoDoors()
    while _G.AutoDoors do
        task.wait(1)
        
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and 
               descendant:GetAttribute("roomIndex") and 
               not descendant:GetAttribute("activated") and 
               descendant:GetAttribute("locked") == false then
                
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = descendant:GetPivot() * CFrame.new(0, 5, 0)
                task.wait(0.2)
            end
        end
        
        if not _G.AutoDoors then 
            return 
        end
    end
end

-- Auto Skills & Perks Toggle
Window:AddToggle({
    text = "Auto Skills & Perks", 
    flag = "toggle", 
    state = false, 
    callback = function(state)
        _G.Skills = state
        print("Skills:", state)
        if state then
            Skills()
        end
    end
})

function Skills()
    spawn(function()
        while _G.Skills do
            wait()
            pcall(function()
                -- Skill 1
                local args1 = {buffer.fromstring("\8\3\1"), {os.time()}}
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args1))
                
                -- Skill 2
                local args2 = {buffer.fromstring("\8\5\1"), {os.time()}}
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args2))
                
                -- Skill 3
                local args3 = {buffer.fromstring("\8\6\1"), {os.time()}}
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args3))
                
                -- Skill 4
                local args4 = {buffer.fromstring("\8\7\1"), {os.time()}}
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args4))
                
                -- Perk
                local args5 = {buffer.fromstring("\f")}
                game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable"):FireServer(unpack(args5))
                
                wait(1)
            end)
        end
    end)
end

-- Collect Coins Toggle
Window:AddToggle({
    text = "Collect Coins", 
    flag = "toggle", 
    state = false, 
    callback = function(state)
        _G.Coins = state
        print("Coins:", state)
        if state then
            Coins()
        end
    end
})

function Coins()
    spawn(function()
        while _G.Coins do
            wait()
            pcall(function()
                for _, item in pairs(workspace.DropItems:GetChildren()) do
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                    wait()
                end
                wait()
            end)
        end
    end)
end

-- Auto Escape Toggle
Window:AddToggle({
    text = "Auto Escape", 
    flag = "toggle", 
    state = false, 
    callback = function(state)
        _G.Escape = state
        print("Escape:", state)
        if state then
            Escape()
        end
    end
})

function Escape()
    spawn(function()
        while _G.Escape do
            wait()
            pcall(function()
                -- Find and activate radio
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant.Name == "RadioObjective" and descendant.ProximityPrompt.Enabled == true then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = descendant.CFrame
                        wait(0.2)
                        fireproximityprompt(descendant.ProximityPrompt)
                    end
                end
                
                -- Check if escape objective is active
                if game:GetService("Players").LocalPlayer.PlayerGui.MainScreen.ObjectiveDisplay.ObjectiveElement.List.Description.Text == "ESCAPE" then
                    _G.Mobs = false
                    _G.Coins = false
                    wait(0.5)
                    
                    -- Find and activate helicopter
                    for _, descendant in pairs(workspace:GetDescendants()) do
                        if descendant.Name == "HeliObjective" and descendant.ProximityPrompt.Enabled == true then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = descendant.CFrame
                            wait(0.2)
                            fireproximityprompt(descendant.ProximityPrompt)
                        end
                    end
                end
                
                -- Find and activate generators
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant.Name == "gen" and descendant.pom.Enabled == true then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = descendant.CFrame
                        wait(0.2)
                        fireproximityprompt(descendant.pom)
                    end
                end
                
                wait(2)
            end)
        end
    end)
end

-- Credits Label
Window:AddLabel({
    text = "YouTube: Tora IsMe"
})

-- Initialize GUI
Library:Init()

-- Jump fix
game:GetService("UserInputService").JumpRequest:Connect(function()
    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end)
