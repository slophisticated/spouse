local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- KOORDINAT TUJUAN
local PointA = CFrame.new(
    -18158.0664, 34.5178947, -454.243683,
    0.89404887, -0.000757645816, 0.447968811,
    6.20140418e-06, 0.999998569, 0.00167891255,
    -0.447969437, -0.0014982518, 0.894047618
)

local function teleportVehicle(character)
    local vehicleSeat =
        character:FindFirstChildWhichIsA("VehicleSeat", true)
        or workspace:FindFirstChildWhichIsA("VehicleSeat", true)

    if not vehicleSeat then
        warn("VehicleSeat tidak ditemukan")
        return
    end

    local vehicleModel = vehicleSeat:FindFirstAncestorOfClass("Model")
    if not vehicleModel or not vehicleModel.PrimaryPart then
        warn("Model atau PrimaryPart tidak valid")
        return
    end

    local pp = vehicleModel.PrimaryPart

    -- Simpan velocity
    local oldVel = pp.AssemblyLinearVelocity
    local oldAng = pp.AssemblyAngularVelocity

    -- Teleport
    vehicleModel:PivotTo(PointA)

    -- Restore velocity
    pp.AssemblyLinearVelocity = oldVel
    pp.AssemblyAngularVelocity = oldAng
end

-- Trigger langsung
if player.Character then
    teleportVehicle(player.Character)
end

player.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    teleportVehicle(character)
end)
