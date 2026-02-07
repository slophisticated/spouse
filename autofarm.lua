local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- TITIK A (NAIK MOBIL)
local PointA = CFrame.new(
    -18200.3672, 34.0200882, -551.759155,
    0.915695131, -0.00464598555, 0.401846796,
    0.00240602833, 0.999978602, 0.00607867865,
    -0.401866436, -0.00459936215, 0.915686727
)

local Y_OFFSET = 6 -- ini kunci. bisa dinaikin

local function getVehicle()
    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if hum.SeatPart then
        local car = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
        if car and car.PrimaryPart then
            return car
        end
    end
end

local function teleportToA()
    local car = getVehicle()
    if not car then
        warn("Mobil tidak ditemukan")
        return
    end

    local root = car.PrimaryPart

    -- TP KE ATAS DIKIT
    root.CFrame =
        CFrame.new(
            PointA.Position + Vector3.new(0, Y_OFFSET, 0)
        ) * PointA.Rotation

    print("TP ke titik A")
end

-- EKSEKUSI
teleportToA()
