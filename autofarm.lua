local AutoFarm = {}
AutoFarm.IsRunning = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

local speed = 100
local tween

-- TITIK A & B NAIK MOBIL. SUDAH DITINGGIIN
local PointA = CFrame.new(
    -18200.3672, 37.5, -551.759155,
    0.915695131, -0.0046, 0.4018,
    0.0024, 0.9999, 0.0060,
    -0.4018, -0.0045, 0.9156
)

local PointB = CFrame.new(
    -34486.7344, 36.5, -32823.1719,
    -0.8459, 0.0024, -0.5332,
    0.0006, 0.9999, 0.0034,
    0.5332, 0.0025, -0.8459
)

function AutoFarm:SetSpeed(v)
    speed = math.clamp(v, 10, 710)
end

local function getVehicleRoot()
    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local seat = hum.SeatPart
    if not seat then return end

    return seat:FindFirstAncestorWhichIsA("Model")
end

local function tweenTo(root, cf)
    if tween then tween:Cancel() end

    local dist = (root.Position - cf.Position).Magnitude
    local time = dist / speed

    tween = TweenService:Create(
        root,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = cf }
    )
    tween:Play()
    tween.Completed:Wait()
end

function AutoFarm:Start()
    if AutoFarm.IsRunning then return end
    AutoFarm.IsRunning = true

    local car = getVehicleRoot()
    if not car or not car.PrimaryPart then return end

    local root = car.PrimaryPart

    -- TELEPORT KE A
    root.CFrame = PointA

    task.spawn(function()
        while AutoFarm.IsRunning do
            tweenTo(root, PointB)
            if not AutoFarm.IsRunning then break end
            tweenTo(root, PointA)
        end
    end)
end

function AutoFarm:StopAutoDrive()
    AutoFarm.IsRunning = false
    if tween then
        tween:Cancel()
        tween = nil
    end
end

return AutoFarm
