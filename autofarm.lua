local AutoFarm = {}
AutoFarm.IsRunning = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local speed = 100
local tween

-- POINT A & B
local PointA = CFrame.new(
    -18200.3672, 40, -551.759155,
    0.915695131, -0.0046, 0.4018,
    0.0024, 0.9999, 0.0060,
    -0.4018, -0.0045, 0.9156
)

local PointB = CFrame.new(
    -34486.7344, 40, -32823.1719,
    -0.8459, 0.0024, -0.5332,
    0.0006, 0.9999, 0.0034,
    0.5332, 0.0025, -0.8459
)

function AutoFarm:SetSpeed(v)
    speed = math.clamp(v, 10, 710)
end

local function getVehicle()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then return end
    local car = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
    if car and car.PrimaryPart then
        return car
    end
end

-- NUNGGU MOBIL NYENTUH ASPAL
local function waitForGround(root)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { root.Parent }
    params.FilterType = Enum.RaycastFilterType.Blacklist

    for _ = 1, 120 do
        local result = Workspace:Raycast(
            root.Position,
            Vector3.new(0, -20, 0),
            params
        )

        if result then
            -- snap ke atas aspal dikit
            root.CFrame =
                CFrame.new(
                    result.Position + Vector3.new(0, 2.5, 0)
                ) * root.CFrame.Rotation
            return true
        end

        task.wait(0.05)
    end

    return false
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

    local car = getVehicle()
    if not car then return end

    local root = car.PrimaryPart

    -- TP KE A
    root.CFrame = PointA

    -- TUNGGU BAN NYENTUH ASPAL
    if not waitForGround(root) then
        warn("Ground not detected")
        return
    end

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
