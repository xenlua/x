local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Daftar posisi teleport (edit sesuai koordinat yang kamu inginkan)
local teleportPoints = {
    CFrame.new(625, 1799, 3433),
    CFrame.new(791, 2151, 3914),
}

-- Fungsi teleport
local function teleportToPoints()
    for _, point in ipairs(teleportPoints) do
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            hrp.CFrame = point
        end

        task.wait(3) -- jeda antar teleport (ubah jika perlu)
    end
end

-- Jalankan teleport
teleportToPoints()
