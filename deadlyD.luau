-- Deadly Delivery Script (Cleaned Version)
-- Original from discord.gg/25ms

-- Remove existing GUI if present
if game:GetService("CoreGui"):FindFirstChild("ToraScript") then
    game:GetService("CoreGui").ToraScript:Destroy()
end

-- Load library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local Window = Library:CreateWindow("Deadly Delivery")

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local LocalPlayer = Players.LocalPlayer
local CurrentTween = nil

-- Find Items Toggle
Window:AddToggle({
    text = "Find Items",
    flag = "toggle",
    state = false,
    callback = function(state)
        _G.Find = state
        print("Find:", state)
        if state then
            Find()
        end
    end
})

-- Check if all 4 slots are filled
local function AllSlotsFilled()
    local mainGui = LocalPlayer.PlayerGui.Main.HomePage
    local bottomSection = mainGui.Bottom
    
    for slot = 1, 4 do
        local slotUid = bottomSection[tostring(slot)]:GetAttribute("uid")
        if slotUid == nil or slotUid == "" then
            return false
        end
    end
    return true
end

-- Collect items from world
local function CollectItems()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Check interactive items (boxes, containers, etc.)
    for _, descendant in pairs(workspace.GameSystem.InteractiveItem:GetDescendants()) do
        if descendant:GetAttribute("Open") == false and 
           descendant:FindFirstChild("Root") and 
           not string.find(descendant.Name, "Cabinet") then
            
            -- Teleport to item
            rootPart.CFrame = CFrame.new(descendant.Interactable.Position)
            wait()
            
            -- Open container
            ReplicatedStorage:WaitForChild("Remote_Event"):FireServer(unpack({
                "\r\239\191\189\239\191\189\1",
                {descendant}
            }))
            wait()
            
            -- Interact with container
            ReplicatedStorage:WaitForChild("Remote_Event"):FireServer(unpack({
                "\7\239\191\189\239\191\189\1",
                {descendant}
            }))
            return
        end
    end
    
    -- Check loose items in world
    for _, descendant in pairs(workspace.GameSystem.Loots.World:GetDescendants()) do
        if (descendant.Name == "Interactable" or descendant.Name == "Handle") and 
           descendant.Parent:GetAttribute("uid") then
            
            -- Teleport to item
            rootPart.CFrame = CFrame.new(descendant.Position)
            wait()
            
            -- Pick up item
            local args1 = {
                "\r\239\191\189\239\191\189\1",
                {descendant.Parent}
            }
            ReplicatedStorage:WaitForChild("Remote_Event"):FireServer(unpack(args1))
            wait()
            
            -- Confirm pickup
            local args2 = {
                "\7\239\191\189\239\191\189\1",
                {descendant.Parent}
            }
            ReplicatedStorage:WaitForChild("Remote_Event"):FireServer(unpack(args2))
            return
        end
    end
end

-- Move to elevator smoothly
local function MoveToElevator()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local elevatorCheck = workspace["\239\191\189\239\191\189\230\162\175"].Left4.Check
    
    local targetPosition = elevatorCheck.Position
    local distance = (rootPart.Position - targetPosition).Magnitude
    local tweenTime = math.clamp(distance / 45, 0.25, 2)
    
    -- Cancel previous tween if exists
    if CurrentTween then
        CurrentTween:Cancel()
    end
    
    -- Create and play tween
    CurrentTween = TweenService:Create(
        rootPart,
        TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(targetPosition)}
    )
    CurrentTween:Play()
    wait(3)
end

-- Main Find function
function Find()
    _G.Find = true
    task.spawn(function()
        while task.wait(0.2) and _G.Find do
            pcall(function()
                local mainGui = LocalPlayer.PlayerGui.Main.HomePage
                local handsFull = mainGui.HandsFull.Visible
                local slotsFilled = AllSlotsFilled()
                
                -- If hands full or all slots filled, go to elevator
                if handsFull then
                    MoveToElevator()
                    return
                elseif slotsFilled then
                    MoveToElevator()
                else
                    -- Cancel tween if running
                    if CurrentTween then
                        CurrentTween:Cancel()
                        CurrentTween = nil
                    end
                    -- Collect items
                    CollectItems()
                end
            end)
        end
    end)
end

-- Go to Elevator Button
Window:AddButton({
    text = "Go to Elevator",
    flag = "button",
    callback = function()
        local character = game.Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local elevatorCheck = workspace["\239\191\189\239\191\189\230\162\175"].Left4.Check
            rootPart.CFrame = elevatorCheck.CFrame * CFrame.new(0, 0, 10)
        end
    end
})

-- Initialize GUI
Library:Init()
