-- ts file was generated at discord.gg/25ms


if game:GetService("CoreGui"):FindFirstChild("ToraScript") then
    game:GetService("CoreGui").ToraScript:Destroy()
end
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local v2 = v1:CreateWindow("Deadly Delivery")
v2:AddToggle({
    text = "Find Items",
    flag = "toggle",
    state = false,
    callback = function(p3)
        _G.Find = p3
        print("Find: ", p3)
        if p3 then
            Find()
        end
    end
})
function Find()
    _G.Find = true
    task.spawn(function()
        while task.wait(0.2) and _G.Find do
            pcall(function()
                local v4 = game:GetService("Players")
                local vu5 = game:GetService("TweenService")
                local v6 = v4.LocalPlayer
                local vu7 = (v6.Character or v6.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
                local v8 = v6.PlayerGui.Main.HomePage
                local vu9 = v8.Bottom
                local vu10 = workspace["\239\191\189\239\191\189\230\162\175"].Left4.Check
                local vu11 = nil
                local function v14()
                    for v12 = 1, 4 do
                        local v13 = vu9[tostring(v12)]:GetAttribute("uid")
                        if v13 == nil or v13 == "" then
                            return false
                        end
                    end
                    return true
                end
                local function v25()
                    local v15, v16, v17 = pairs(workspace.GameSystem.InteractiveItem:GetDescendants())
                    while true do
                        local v18
                        v17, v18 = v15(v16, v17)
                        if v17 == nil then
                            break
                        end
                        if v18:GetAttribute("Open") == false and (v18:FindFirstChild("Root") and not string.find(v18.Name, "Cabinet")) then
                            vu7.CFrame = CFrame.new(v18.Interactable.Position)
                            wait()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remote_Event"):FireServer(unpack({
                                "\r\239\191\189\239\191\189\1",
                                {
                                    v18
                                }
                            }))
                            wait()
                            game:GetService("ReplicatedStorage"):WaitForChild("Remote_Event"):FireServer(unpack({
                                "\7\239\191\189\239\191\189\1",
                                {
                                    v18
                                }
                            }))
                            return
                        end
                    end
                    local v19, v20, v21 = pairs(workspace.GameSystem.Loots.World:GetDescendants())
                    while true do
                        local v22
                        v21, v22 = v19(v20, v21)
                        if v21 == nil then
                            break
                        end
                        if (v22.Name == "Interactable" or v22.Name == "Handle") and v22.Parent:GetAttribute("uid") then
                            vu7.CFrame = CFrame.new(v22.Position)
                            wait()
                            local v23 = {
                                "\r\239\191\189\239\191\189\1",
                                {
                                    v22.Parent
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remote_Event"):FireServer(unpack(v23))
                            wait()
                            local v24 = {
                                "\7\239\191\189\239\191\189\1",
                                {
                                    v22.Parent
                                }
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Remote_Event"):FireServer(unpack(v24))
                            return
                        end
                    end
                end
                local function v29()
                    local v26 = vu10.Position
                    local v27 = (vu7.Position - v26).Magnitude
                    local v28 = math.clamp(v27 / 45, 0.25, 2)
                    if vu11 then
                        vu11:Cancel()
                    end
                    vu11 = vu5:Create(vu7, TweenInfo.new(v28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        CFrame = CFrame.new(v26)
                    })
                    vu11:Play()
                    wait(3)
                end
                local v30 = v8.HandsFull.Visible
                local v31 = v14()
                if v30 then
                    v29()
                    return
                elseif v31 then
                    v29()
                else
                    if vu11 then
                        local v32 = vu11
                        vu11.Cancel(v32)
                        vu11 = nil
                    end
                    v25()
                end
            end)
        end
    end)
end
v2:AddButton({
    text = "Go to Elevator",
    flag = "button",
    callback = function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace["\239\191\189\239\191\189\230\162\175"].Left4.Check.CFrame * CFrame.new(0, 0, 10)
    end
})
v1:Init()
