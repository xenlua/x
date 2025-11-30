-- Enhanced FPS Booster Script
-- Optimized version with better performance

-- Configuration
_G.Ignore = _G.Ignore or {}

-- Wait for game to load
if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

-- Default Settings
if not _G.Settings then
    _G.Settings = {
        Players = {
            IgnoreMe = true,
            IgnoreOthers = true,
            IgnoreTools = true
        },
        Meshes = {
            NoMesh = false,
            NoTexture = false,
            Destroy = false
        },
        Images = {
            Invisible = true,
            Destroy = false
        },
        Explosions = {
            Smaller = true,
            Invisible = false,
            Destroy = false
        },
        Particles = {
            Invisible = true,
            Destroy = false
        },
        TextLabels = {
            LowerQuality = false,
            Invisible = false,
            Destroy = false
        },
        MeshParts = {
            LowerQuality = true,
            Invisible = false,
            NoTexture = false,
            NoMesh = false,
            Destroy = false
        },
        Other = {
            FPSCap = true,
            NoCameraEffects = true,
            NoClothes = true,
            LowWaterGraphics = true,
            NoShadows = true,
            LowRendering = true,
            LowQualityParts = true,
            LowQualityModels = true,
            ResetMaterials = true,
            ClearNilInstances = false
        }
    }
end

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ParticleTypes = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

-- Helper Functions
local function IsPartOfOtherCharacter(instance)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and instance:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function IsDescendantOfIgnored(instance)
    for _, ignored in ipairs(_G.Ignore) do
        if instance:IsDescendantOf(ignored) then
            return true
        end
    end
    return false
end

local function ShouldProcess(instance)
    if instance:IsDescendantOf(Players) then
        return false
    end
    
    -- Check player ignore settings
    if _G.Settings.Players.IgnoreOthers and IsPartOfOtherCharacter(instance) then
        return false
    end
    
    if _G.Settings.Players.IgnoreMe and LocalPlayer.Character and instance:IsDescendantOf(LocalPlayer.Character) then
        return false
    end
    
    if _G.Settings.Players.IgnoreTools and (instance:IsA("BackpackItem") or instance:FindFirstAncestorWhichIsA("BackpackItem")) then
        return false
    end
    
    -- Check ignore list
    if #_G.Ignore > 0 and (table.find(_G.Ignore, instance) or IsDescendantOfIgnored(instance)) then
        return false
    end
    
    return true
end

local function ProcessInstance(instance)
    if not ShouldProcess(instance) then return end
    
    local className = instance.ClassName
    
    -- Meshes
    if instance:IsA("DataModelMesh") then
        if instance:IsA("SpecialMesh") then
            if _G.Settings.Meshes.NoMesh then
                instance.MeshId = ""
            end
            if _G.Settings.Meshes.NoTexture then
                instance.TextureId = ""
            end
        end
        if _G.Settings.Meshes.Destroy then
            instance:Destroy()
        end
    
    -- Face Images
    elseif instance:IsA("FaceInstance") then
        if _G.Settings.Images.Invisible then
            instance.Transparency = 1
            instance.Shiny = 1
        end
        if _G.Settings.Images.Destroy then
            instance:Destroy()
        end
    
    -- Shirt Graphics
    elseif instance:IsA("ShirtGraphic") then
        if _G.Settings.Images.Invisible then
            instance.Graphic = ""
        end
        if _G.Settings.Images.Destroy then
            instance:Destroy()
        end
    
    -- Particles
    elseif table.find(ParticleTypes, className) then
        if _G.Settings.Particles.Invisible then
            instance.Enabled = false
        end
        if _G.Settings.Particles.Destroy then
            instance:Destroy()
        end
    
    -- Camera Effects
    elseif instance:IsA("PostEffect") and _G.Settings.Other.NoCameraEffects then
        instance.Enabled = false
    
    -- Explosions
    elseif instance:IsA("Explosion") then
        if _G.Settings.Explosions.Smaller then
            instance.BlastPressure = 1
            instance.BlastRadius = 1
        end
        if _G.Settings.Explosions.Invisible then
            instance.BlastPressure = 1
            instance.BlastRadius = 1
            instance.Visible = false
        end
        if _G.Settings.Explosions.Destroy then
            instance:Destroy()
        end
    
    -- Clothing
    elseif (instance:IsA("Clothing") or instance:IsA("SurfaceAppearance") or instance:IsA("BaseWrap")) and _G.Settings.Other.NoClothes then
        instance:Destroy()
    
    -- Base Parts
    elseif instance:IsA("BasePart") and not instance:IsA("MeshPart") and _G.Settings.Other.LowQualityParts then
        instance.Material = Enum.Material.Plastic
        instance.Reflectance = 0
    
    -- Text Labels
    elseif instance:IsA("TextLabel") and instance:IsDescendantOf(workspace) then
        if _G.Settings.TextLabels.LowerQuality then
            instance.Font = Enum.Font.SourceSans
            instance.TextScaled = false
            instance.RichText = false
            instance.TextSize = 14
        end
        if _G.Settings.TextLabels.Invisible then
            instance.Visible = false
        end
        if _G.Settings.TextLabels.Destroy then
            instance:Destroy()
        end
    
    -- Models
    elseif instance:IsA("Model") and _G.Settings.Other.LowQualityModels then
        instance.LevelOfDetail = Enum.ModelLevelOfDetail.StreamingMesh
    
    -- Mesh Parts
    elseif instance:IsA("MeshPart") then
        if _G.Settings.MeshParts.LowerQuality then
            instance.RenderFidelity = Enum.RenderFidelity.Performance
            instance.Reflectance = 0
            instance.Material = Enum.Material.Plastic
        end
        if _G.Settings.MeshParts.Invisible then
            instance.Transparency = 1
            instance.RenderFidelity = Enum.RenderFidelity.Performance
        end
        if _G.Settings.MeshParts.NoTexture then
            instance.TextureID = ""
        end
        if _G.Settings.MeshParts.NoMesh then
            instance.MeshId = ""
        end
        if _G.Settings.MeshParts.Destroy then
            instance:Destroy()
        end
    end
end

-- Apply Global Settings
local function ApplyGlobalSettings()
    -- Water Graphics
    if _G.Settings.Other.LowWaterGraphics then
        task.spawn(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if not terrain then
                terrain = workspace:WaitForChild("Terrain", 10)
            end
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
                if sethiddenproperty then
                    pcall(sethiddenproperty, terrain, "Decoration", false)
                end
            end
        end)
    end
    
    -- Shadows
    if _G.Settings.Other.NoShadows then
        task.spawn(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            if sethiddenproperty then
                pcall(sethiddenproperty, Lighting, "Technology", 2)
            end
        end)
    end
    
    -- Rendering
    if _G.Settings.Other.LowRendering then
        task.spawn(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
    end
    
    -- Materials
    if _G.Settings.Other.ResetMaterials then
        task.spawn(function()
            for _, material in ipairs(MaterialService:GetChildren()) do
                material:Destroy()
            end
            MaterialService.Use2022Materials = false
        end)
    end
    
    -- FPS Cap
    if _G.Settings.Other.FPSCap then
        task.spawn(function()
            if setfpscap then
                local capValue = _G.Settings.Other.FPSCap
                if type(capValue) == "number" then
                    setfpscap(capValue)
                elseif capValue == true then
                    setfpscap(1000)
                end
            end
        end)
    end
    
    -- Clear Nil Instances
    if _G.Settings.Other.ClearNilInstances then
        task.spawn(function()
            if getnilinstances then
                for _, instance in ipairs(getnilinstances()) do
                    pcall(function() instance:Destroy() end)
                end
            end
        end)
    end
end

-- Main Execution
ApplyGlobalSettings()

-- Process existing instances
for _, instance in ipairs(game:GetDescendants()) do
    pcall(ProcessInstance, instance)
end

-- Monitor new instances
game.DescendantAdded:Connect(function(instance)
    task.wait(_G.LoadedWait or 0.1)
    pcall(ProcessInstance, instance)
end)
