local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- Titik A (X Z dan ROTASI dipakai)
local PointA = CFrame.new(
    -18200.3672, 34.0200882, -551.759155,
    0.915695131, -0.0046, 0.4018,
    0.0024, 0.9999, 0.0060,
    -0.4018, -0.0045, 0.9156
)

local function getVehicle()
    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local car = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
        if car and car.PrimaryPart then
            return car
        end
    end
end

local function raycastGround(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { lp.Character }

    local origin = pos + Vector3.new(0, 200, 0)
    local direction = Vector3.new(0, -500, 0)

    return Workspace:Raycast(origin, direction, params)
end

local function teleportSafe()
    local car = getVehicle()
    if not car then
        warn("Mobil ga ketemu")
        return
    end

    local root = car.PrimaryPart
    local hit = raycastGround(PointA.Position)

    if not hit then
        warn("Aspal ga ke-detect")
        return
    end

    root.CFrame =
        CFrame.new(hit.Position + Vector3.new(0, 5, 0))
        * PointA.Rotation

    print("TP aman ke aspal")
end

teleportSafe()
