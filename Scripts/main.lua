-- Zoom v1.1.1 standalone (no AlterraAPI dependency).
local UEHelpers = require("UEHelpers")

local CONFIG = {
    base_fov = 90.0, start_fov = 60.0, min_fov = 10.0, step = 5.0, ease = 0.12,
}

local HIDE_NAMES = {
    ["ScubaMaskSections"]    = true,
    ["ScubaMaskTopLeft"]     = true,
    ["ScubaMaskTopRight"]    = true,
    ["ScubaMaskNose"]        = true,
    ["ScubaMaskBottomLeft"]  = true,
    ["ScubaMaskBottomRight"] = true,
    ["Hands"]                = true,
    ["EquippedMesh"]         = true,
}

local zooming, target_fov, cur_fov = false, CONFIG.base_fov, CONFIG.base_fov
local hidden = {}

local function get_pc()
    local pc = UEHelpers.GetPlayerController()
    if pc and pc:IsValid() then return pc end
end

local function get_pawn()
    local pc = get_pc()
    if not pc then return end
    local p = pc.Pawn
    if p and p:IsValid() then return p end
end

local function set_fov(fov)
    local pc = get_pc(); if not pc then return end
    pcall(function()
        local cm = pc.PlayerCameraManager
        if cm and cm:IsValid() then
            cm.DefaultFOV = fov; cm.LockedFOV = fov
        end
        pc:ProcessConsoleExec("FOV " .. string.format("%.0f", fov), nil, pc)
    end)
end

local function walk(comp, cb)
    if not comp or not comp:IsValid() then return end
    cb(comp)
    pcall(function()
        local children = comp.AttachChildren
        if children then
            for i = 1, #children do
                local c = children[i]; if c then walk(c, cb) end
            end
        end
    end)
end

local function hide_things()
    if #hidden > 0 then return end
    local pawn = get_pawn(); if not pawn then return end
    walk(pawn.RootComponent, function(c)
        pcall(function()
            local n = c:GetFName():ToString()
            if HIDE_NAMES[n] then
                c:SetVisibility(false, false)
                table.insert(hidden, c)
            end
        end)
    end)
end

local function show_things()
    for _, c in ipairs(hidden) do
        pcall(function() if c:IsValid() then c:SetVisibility(true, false) end end)
    end
    hidden = {}
end

local last_t = os.clock()
LoopAsync(0, function()
    local now = os.clock(); local dt = now - last_t; last_t = now
    if math.abs(cur_fov - target_fov) > 0.1 then
        cur_fov = cur_fov + (target_fov - cur_fov) * math.min(1.0, dt / CONFIG.ease)
        set_fov(cur_fov)
    end
    return false
end)

RegisterKeyBind(Key.Z, function()
    if zooming then
        zooming = false; target_fov = CONFIG.base_fov; show_things()
        print("[Zoom] OFF")
    else
        zooming = true; target_fov = CONFIG.start_fov; hide_things()
        print("[Zoom] ON")
    end
end)

RegisterKeyBind(Key.OEM_PLUS, function()
    if not zooming then return end
    target_fov = math.max(CONFIG.min_fov, target_fov - CONFIG.step)
    print(string.format("[Zoom] in -> %.0f", target_fov))
end)

RegisterKeyBind(Key.OEM_MINUS, function()
    if not zooming then return end
    target_fov = math.min(CONFIG.base_fov, target_fov + CONFIG.step)
    print(string.format("[Zoom] out -> %.0f", target_fov))
end)

print("[Zoom] loaded v1.1.1 standalone.")
