--[[
    2 Tab UI with AutoFarm Integration
    Tab 1: AutoFarm Controls
    Tab 2: Settings (kosong untuk sekarang)
]]

-- Load AutoFarm Logic
local AutoFarmLogic = loadstring(game:HttpGet("https://pastebin.com/eVTbiMVW"))()
-- Atau kalau local testing: local AutoFarmLogic = require(script.AutoFarmLogic)

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = WindUI:CreateWindow({
    Title = "AutoFarm Hub",
    Icon = "rbxassetid://10723415903",
    Author = "Your Name",
    Folder = "AutoFarmConfig",
    Size = UDim2.fromOffset(570, 480),
    KeySystem = false,
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 170,
})

-- Create Tab 1 - AutoFarm
local Tab1 = Window:Tab({
    Title = "AutoFarm",
    Icon = "zap",
})

-- Create Tab 2 - Settings
local Tab2 = Window:Tab({
    Title = "Settings", 
    Icon = "settings",
})

-- ====================
-- TAB 1: AUTOFARM
-- ====================

local Tab1Section = Tab1:Section({
    Title = "AutoFarm Controls"
})

-- Status indicator
local statusText = "Stopped"
Tab1Section:Paragraph({
    Title = "Status",
    Paragraph = "Status: " .. statusText
})

-- Speed Slider (0-710 studs, displayed as km/h)
local currentSpeed = 100
Tab1Section:Slider({
    Title = "Speed",
    Description = "Max: 740 km/h (710 studs/s)",
    Default = 100,
    Min = 0,
    Max = 710,
    Callback = function(value)
        currentSpeed = value
        AutoFarmLogic:SetSpeed(value)
        
        -- Convert to km/h for display
        local kmh = AutoFarmLogic:StudsToKmh(value)
        WindUI:Notification({
            Title = "Speed Updated",
            Description = string.format("%d studs/s ≈ %d km/h", value, kmh),
            Duration = 2
        })
    end
})

-- Teleport Position Input (optional)
local teleportPos = Vector3.new(0, 10, 0) -- Default spawn point
Tab1Section:Input({
    Title = "Teleport Position (X,Y,Z)",
    Description = "Format: 0,10,0",
    Placeholder = "0,10,0",
    Callback = function(value)
        -- Parse input "x,y,z"
        local coords = string.split(value, ",")
        if #coords == 3 then
            local x = tonumber(coords[1])
            local y = tonumber(coords[2])
            local z = tonumber(coords[3])
            
            if x and y and z then
                teleportPos = Vector3.new(x, y, z)
                WindUI:Notification({
                    Title = "Position Set",
                    Description = string.format("Teleport to: %.1f, %.1f, %.1f", x, y, z),
                    Duration = 3
                })
            else
                WindUI:Notification({
                    Title = "Error",
                    Description = "Invalid coordinates! Use format: x,y,z",
                    Duration = 3
                })
            end
        end
    end
})

-- Start Button
Tab1Section:Button({
    Title = "Start AutoFarm",
    Callback = function()
        if AutoFarmLogic.IsRunning then
            WindUI:Notification({
                Title = "Already Running",
                Description = "AutoFarm is already active!",
                Duration = 3
            })
            return
        end
        
        -- Set speed sebelum start
        AutoFarmLogic:SetSpeed(currentSpeed)
        
        -- Start autofarm with teleport
        AutoFarmLogic:Start(teleportPos)
        
        statusText = "Running"
        WindUI:Notification({
            Title = "AutoFarm Started",
            Description = "Teleporting and starting auto-drive...",
            Duration = 3
        })
    end
})

-- Stop Button
Tab1Section:Button({
    Title = "Stop AutoFarm",
    Callback = function()
        if not AutoFarmLogic.IsRunning then
            WindUI:Notification({
                Title = "Not Running",
                Description = "AutoFarm is not active!",
                Duration = 3
            })
            return
        end
        
        AutoFarmLogic:StopAutoDrive()
        
        statusText = "Stopped"
        WindUI:Notification({
            Title = "AutoFarm Stopped",
            Description = "Auto-drive has been stopped.",
            Duration = 3
        })
    end
})

-- Divider
Tab1Section:Divider()

-- Quick Actions
local Tab1Section2 = Tab1:Section({
    Title = "Quick Actions"
})

-- Teleport Only (tanpa start)
Tab1Section2:Button({
    Title = "Teleport Only",
    Callback = function()
        AutoFarmLogic:TeleportWithVehicle(teleportPos)
        WindUI:Notification({
            Title = "Teleported",
            Description = "Moved to position!",
            Duration = 2
        })
    end
})

-- Get Current Position
Tab1Section2:Button({
    Title = "Get Current Position",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            local posText = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            
            -- Copy to clipboard (jika executor support)
            if setclipboard then
                setclipboard(posText)
                WindUI:Notification({
                    Title = "Position Copied",
                    Description = posText,
                    Duration = 5
                })
            else
                WindUI:Notification({
                    Title = "Current Position",
                    Description = posText,
                    Duration = 5
                })
            end
        end
    end
})

-- ====================
-- TAB 2: SETTINGS (Empty for now)
-- ====================

-- Welcome notification
WindUI:Notification({
    Title = "AutoFarm Loaded",
    Description = "Set your speed and press Start!",
    Duration = 5
})

print("AutoFarm UI loaded successfully!")