-- Mushlec Hub | Loader
-- Taro file ini di Github (public), ini yang dishare ke user
-- Isi logic script lu ada di Supabase Storage (private), diprotect by key

if not script_key then
    error("[Mushlec] No key provided. Set your key first:\nscript_key = 'YOUR_KEY_HERE'")
    return
end

local BASE_URL = "https://choco-nine-omega.vercel.app/api/script"

local ok, result = pcall(function()
    return game:HttpGet(BASE_URL .. "?key=" .. tostring(script_key), true)
end)

if not ok then
    error("[Mushlec] Failed to reach server. Check your connection.")
    return
end

-- Kalau key invalid/banned, API return error("...") — langsung keeksekusi sebagai lua
-- Kalau valid, API return isi script lu
loadstring(result)()