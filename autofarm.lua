local AutoFarm = {}
AutoFarm.IsRunning = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local speed = 100
local hbConn

-- TITIK A NAIK MOBIL. DITINGGIIN BIAR GA NABRAK
local PointA = CFrame.new(
    -18200.3672, 37.5, -551.759155,
    0.915695131, -0.00464598555, 0.401846796,
    0.00240602833, 0.999978602, 0.00607867865,
    -0.401866436, -0.00459936215, 0.915686727
)

function AutoFarm:SetSpeed(v)
    speed = v
end

local function getCar()
    if not lp.Character then return end
    return lp.Character:FindFirstChildWhichIsA("Model")
end

function AutoFarm:Start()
    if AutoFarm.IsRunning then return end
    AutoFarm.IsRunning = true

    local car = getCar()
    if not car then return end

    local root = car.PrimaryPart or car:FindFirstChild("Chassis")
    if not root then return end

    -- TELEPORT KE TITIK A
    root.CFrame = PointA

    hbConn = RunService.Heartbeat:Connect(function(dt)
        if not AutoFarm.IsRunning then return end

        -- GASPOL MAJU
        root.AssemblyLinearVelocity =
            root.CFrame.LookVector * speed
    end)
end

function AutoFarm:StopAutoDrive()
    AutoFarm.IsRunning = false
    if hbConn then
        hbConn:Disconnect()
        hbConn = nil
    end
end

return AutoFarm
