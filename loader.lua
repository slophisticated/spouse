-- Mushlec Hub | Loader
-- Taro file ini di Github (public)

if not script_key then
    error("[Mushlec] No key provided.\nscript_key = 'YOUR_KEY_HERE'")
    return
end

local BASE_URL = "https://choco-nine-omega.vercel.app/api/script"

-- Signature secret — harus sama persis sama LOADER_SIGNATURE di .env Vercel lu
-- Ini bukan key user, ini internal secret antara loader & server
local SIGNATURE = "2840ee36f3d92d5625bee1633b643819a4f54025a3fe832429cf0ebca3f15af8"

-- Ambil HWID device
local hwid = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
local username = game.Players.LocalPlayer and game.Players.LocalPlayer.Name or "unknown"
local gameId = tostring(game.PlaceId)

local ok, result = pcall(function()
    return (syn and syn.request or http and http.request or request)({
        Url = BASE_URL .. "?key=" .. tostring(script_key),
        Method = "GET",
        Headers = {
            ["x-hwid"] = hwid,
            ["x-signature"] = SIGNATURE,
            ["x-username"] = username,
            ["x-game"] = gameId,
            ["x-executor"] = identifyexecutor and identifyexecutor() or "unknown",
        }
    })
end)

if not ok or not result then
    error("[Mushlec] Failed to reach server. Check your connection.")
    return
end

loadstring(result.Body)()