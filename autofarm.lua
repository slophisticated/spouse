-- autofarm.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoFarmLogic = {}

-- ===== PUBLIC STATE =====
AutoFarmLogic.IsRunning = false
AutoFarmLogic.CurrentSpeed = 100
AutoFarmLogic.MaxSpeed = 710

-- ===== CONFIG =====
local TELEPORT_Y = 6
local RECOVER_CHECK = 0.5

-- Point A & B (CF mobil)
local POINT_A = CFrame.new(
    -18200.3672, 34.0200882, -551.759155,
    0.915695131, -0.00464598555, 0.401846796,
    0.00240602833, 0.999978602, 0.00607867865,
    -0.401866436, -0.00459936215, 0.915686727
)

local POINT_B = CFrame.new(
    -34486.7344, 33.8133202, -32823.1719,
    -0.84594214, 0.00241268822, -0.533269227,
    0.000685837469, 0.999993861, 0.00343634025,
    0.533274233, 0.00254120934, -0.845938623
)

local player = Players.LocalPlayer
local currentTween
local hbConn

-- ===== INTERNAL =====
local function getVehicle()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.SeatPart then
        return hum.SeatPart.Parent
    end
end

local function getRoot(vehicle)
    return vehicle and vehicle.PrimaryPart
end

local function teleportRemote(cf)
    pcall(function()
        ReplicatedStorage.Remotes.UnauthorizedTeleport:FireServer(cf, cf, 300)
    end)
end

-- ===== GROUND CHECK =====
local function wheelsTouchGround(vehicle)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { vehicle }
    params.FilterType = Enum.RaycastFilterType.Blacklist

    for _,p in pairs(vehicle:GetDescendants()) do
        if p:IsA("BasePart") and p.Name:lower():find("wheel") then
            if workspace:Raycast(p.Position, Vector3.new(0,-3,0), params) then
                return true
            end
        end
    end
    return false
end

local function settleOnRoad(vehicle, timeout)
    local root = getRoot(vehicle)
    local start = tick()

    while tick() - start < (timeout or 2) do
        if wheelsTouchGround(vehicle) then
            return true
        end
        root.CFrame = CFrame.new(0,-0.4,0)
        task.wait(0.05)
    end
end

-- ===== RECOVER =====
local function isStuck(vehicle)
    local root = getRoot(vehicle)
    if not root then return true end
    if math.abs(root.CFrame.UpVector.Y) < 0.6 then return true end
    if root.AssemblyLinearVelocity.Magnitude < 5 then return true end
    return false
end

local function recover(vehicle)
    local root = getRoot(vehicle)
    if not root then return end

    root.CFrame = CFrame.new(
        root.Position + Vector3.new(0,6,0),
        root.Position + root.CFrame.LookVector
    )

    task.wait(0.2)
    settleOnRoad(vehicle, 2)
end

-- ===== DRIVE =====
local function driveTo(vehicle, targetCF)
    local root = getRoot(vehicle)
    if not root then return end

    local dist = (root.Position - targetCF.Position).Magnitude
    local dur = dist / AutoFarmLogic.CurrentSpeed

    currentTween = TweenService:Create(
        root,
        TweenInfo.new(dur, Enum.EasingStyle.Linear),
        { CFrame = targetCF }
    )

    currentTween:Play()
    currentTween.Completed:Wait()
end

-- ===== PUBLIC API =====
function AutoFarmLogic:SetSpeed(speed)
    AutoFarmLogic.CurrentSpeed = math.clamp(speed, 0, AutoFarmLogic.MaxSpeed)
end

function AutoFarmLogic:Start()
    if AutoFarmLogic.IsRunning then return end
    AutoFarmLogic.IsRunning = true

    task.spawn(function()
        while AutoFarmLogic.IsRunning do
            local vehicle = getVehicle()
            if not vehicle or not vehicle.PrimaryPart then break end

            teleportRemote(POINT_A * CFrame.new(0, TELEPORT_Y, 0))
            task.wait(0.4)

            settleOnRoad(vehicle, 2)

            if hbConn then hbConn:Disconnect() end
            local last = tick()
            hbConn = RunService.Heartbeat:Connect(function()
                if tick() - last >= RECOVER_CHECK then
                    last = tick()
                    if isStuck(vehicle) then
                        if currentTween then currentTween:Cancel() end
                        recover(vehicle)
                    end
                end
            end)

            driveTo(vehicle, POINT_B)
            driveTo(vehicle, POINT_A)
        end
    end)
end

function AutoFarmLogic:StopAutoDrive()
    AutoFarmLogic.IsRunning = false
    if hbConn then hbConn:Disconnect() end
    if currentTween then currentTween:Cancel() end
end

return AutoFarmLogic
