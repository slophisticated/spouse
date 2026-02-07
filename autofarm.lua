--[[
    AutoFarm Logic
    Handles teleportation and auto-drive functionality
]]

local AutoFarmLogic = {}

-- Variables
AutoFarmLogic.IsRunning = false
AutoFarmLogic.CurrentSpeed = 100 -- Default speed in studs/second
AutoFarmLogic.MaxSpeed = 710 -- Maximum speed (710 studs = 740 kmh)
AutoFarmLogic.Player = game:GetService("Players").LocalPlayer
AutoFarmLogic.Character = nil
AutoFarmLogic.Vehicle = nil
AutoFarmLogic.Connection = nil

-- Helper function to get player's vehicle
function AutoFarmLogic:GetVehicle()
    local character = self.Player.Character
    if not character then return nil end
    
    -- Cari vehicle di workspace atau di character
    -- Sesuaikan dengan game lo, ini contoh umum
    local vehicle = character:FindFirstChildWhichIsA("VehicleSeat") 
        or character.Parent:FindFirstChildWhichIsA("VehicleSeat")
    
    -- Atau cek parent character apa itu vehicle
    if character.Parent and character.Parent:FindFirstChild("VehicleSeat") then
        return character.Parent
    end
    
    -- Cek kalau player lagi duduk di vehicle seat
    if character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if humanoid.SeatPart and humanoid.SeatPart.Parent then
            return humanoid.SeatPart.Parent
        end
    end
    
    return nil
end

-- Teleport player with vehicle to starting position
function AutoFarmLogic:TeleportWithVehicle(position)
    local args = {
        CFrame.new(-18201.427734375, 35.660972595214844, -577.551513671875, 0.9684789180755615, -0.11916763335466385, 0.21874108910560608, 0.21634814143180847, 0.8376425504684448, -0.5015460848808289, -0.12345877289772034, 0.5330610275268555, 0.8370208144187927),
        CFrame.new(-18121.8125, 52.93954849243164, -434.3309326171875, 0.9280281662940979, 0.004116744268685579, 0.37248721718788147, 0.036326222121715546, 0.9941729307174683, -0.10149210691452026, -0.3707345128059387, 0.10771859437227249, 0.9224709272384644),
        306.72869873046875
    }
    
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnauthorizedTeleport"):FireServer(unpack(args))
    end)
    
    if success then
        print("Teleported using RemoteEvent")
        return true
    else
        warn("Teleport failed!")
        return false
    end
end

-- Start auto-drive
function AutoFarmLogic:StartAutoDrive()
    if self.IsRunning then
        warn("Auto-drive already running!")
        return
    end
    
    self.IsRunning = true
    print("Starting auto-drive at speed:", self.CurrentSpeed, "studs/s")
    
    local character = self.Player.Character
    if not character then
        warn("Character not found!")
        self.IsRunning = false
        return
    end
    
    local vehicle = self:GetVehicle()
    
    if vehicle then
        -- Mode 1: Dengan vehicle
        self:AutoDriveVehicle(vehicle)
    else
        -- Mode 2: Tanpa vehicle (jalan kaki/terbang)
        self:AutoDriveCharacter(character)
    end
end

-- Auto-drive for vehicle
function AutoFarmLogic:AutoDriveVehicle(vehicle)
    local vehicleSeat = vehicle:FindFirstChildWhichIsA("VehicleSeat")
    local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
    
    if not primaryPart then
        warn("Vehicle doesn't have a primary part!")
        self.IsRunning = false
        return
    end
    
    -- Create BodyVelocity untuk kontrol kecepatan
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(100000, 0, 100000) -- Ga ngaruh ke Y (gravity)
    bodyVel.P = 10000
    bodyVel.Parent = primaryPart
    
    -- RunService loop untuk update velocity
    local RunService = game:GetService("RunService")
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.IsRunning then
            bodyVel:Destroy()
            return
        end
        
        if not vehicle or not vehicle.Parent then
            self:StopAutoDrive()
            return
        end
        
        -- Gerak lurus ke depan terus (Look Vector)
        local direction = primaryPart.CFrame.LookVector
        bodyVel.Velocity = direction * self.CurrentSpeed
        
        -- Optional: Auto throttle VehicleSeat
        if vehicleSeat then
            vehicleSeat.ThrottleFloat = 1 -- Gas penuh
            vehicleSeat.SteerFloat = 0 -- Lurus
        end
    end)
end

-- Auto-drive for character (no vehicle)
function AutoFarmLogic:AutoDriveCharacter(character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoidRootPart or not humanoid then
        warn("Character parts not found!")
        self.IsRunning = false
        return
    end
    
    -- Create BodyVelocity
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(100000, 0, 100000)
    bodyVel.P = 10000
    bodyVel.Parent = humanoidRootPart
    
    -- RunService loop
    local RunService = game:GetService("RunService")
    self.Connection = RunService.Heartbeat:Connect(function()
        if not self.IsRunning then
            bodyVel:Destroy()
            return
        end
        
        if not character or not character.Parent then
            self:StopAutoDrive()
            return
        end
        
        -- Gerak lurus ke depan
        local direction = humanoidRootPart.CFrame.LookVector
        bodyVel.Velocity = direction * self.CurrentSpeed
    end)
end

-- Stop auto-drive
function AutoFarmLogic:StopAutoDrive()
    if not self.IsRunning then
        return
    end
    
    self.IsRunning = false
    print("Stopping auto-drive")
    
    -- Disconnect RunService
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    
    -- Remove BodyVelocity
    local character = self.Player.Character
    if character then
        local vehicle = self:GetVehicle()
        
        if vehicle then
            local primaryPart = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")
            if primaryPart then
                local bodyVel = primaryPart:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
        else
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bodyVel = hrp:FindFirstChildOfClass("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
        end
    end
end

-- Set speed (0 to 710 studs)
function AutoFarmLogic:SetSpeed(speed)
    -- Clamp speed between 0 and max
    self.CurrentSpeed = math.clamp(speed, 0, self.MaxSpeed)
    print("Speed set to:", self.CurrentSpeed, "studs/s")
end

-- Convert studs to km/h (approximate)
function AutoFarmLogic:StudsToKmh(studs)
    -- 1 stud ≈ 1.04 km/h (approximate conversion)
    return math.floor(studs * 1.04)
end

-- Convert km/h to studs
function AutoFarmLogic:KmhToStuds(kmh)
    -- Reverse conversion
    return math.floor(kmh / 1.04)
end

-- Main start function (teleport + auto-drive)
function AutoFarmLogic:Start(teleportPosition)
    print("Starting AutoFarm...")
    
    -- Teleport dulu
    if teleportPosition then
        self:TeleportWithVehicle(teleportPosition)
        task.wait(0.5) -- Wait biar teleport selesai
    end
    
    -- Start auto-drive
    self:StartAutoDrive()
end

return AutoFarmLogic