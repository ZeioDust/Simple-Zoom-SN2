-- Zoom for SN2. Press Z, world gets closer. Press Z again, normal.
-- + or = while zoomed for tighter, - to back off. Numpad works too.
--
-- Toggle, not hold. UE4SS for SN2 doesn't expose key release events
-- so I had to settle. If a future build lands key polling I'll redo it.

local UEHelpers = require("UEHelpers")

local CONFIG = {
    base_fov = 90.0, start_fov = 60.0, min_fov = 10.0, step = 5.0, ease = 0.12,
}

-- Stuff that gets hidden while zoomed. Hide first-person attached meshes
-- and they stop scaling up at narrow FOV. DO NOT add "Scuba Mask Stencil"
-- to this list, I tried, it leaves a blue square where your mask was.
-- "Head" would also be a mistake (it's the player model, not the helmet).
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
    -- Don't use FindFirstOf("PlayerController") here. Returns the wrong
    -- controller sometimes (some lobby thing, not your local player).
end

local function get_pawn()
    local pc = get_pc()
    if not pc then return end
    local p = pc.Pawn
    if p and p:IsValid() then return p end
end

-- The annoying part: SN2's camera tick overwrites LockedFOV every frame.
-- Setting the field alone does nothing. ProcessConsoleExec("FOV X") flips
-- an internal override flag that survives the tick. Belt and braces: do both.
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

-- pawn:ForEachComponent(nil, fn) errors with "UObject nullptr" in this
-- UE4SS build. So we walk the AttachChildren tree by hand. Less elegant,
-- doesn't crash.
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

-- Tick: ease cur_fov toward target_fov.
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

local function zoom_in()
    if not zooming then return end
    target_fov = math.max(CONFIG.min_fov, target_fov - CONFIG.step)
    print(string.format("[Zoom] in -> %.0f", target_fov))
end
local function zoom_out()
    if not zooming then return end
    target_fov = math.min(CONFIG.base_fov, target_fov + CONFIG.step)
    print(string.format("[Zoom] out -> %.0f", target_fov))
end

-- Top row keys (the ones next to backspace) and numpad. Bind both because
-- people with full keyboards use numpad and laptop people don't have one.
RegisterKeyBind(Key.OEM_PLUS,  zoom_in)
RegisterKeyBind(Key.OEM_MINUS, zoom_out)
RegisterKeyBind(Key.ADD,       zoom_in)
RegisterKeyBind(Key.SUBTRACT,  zoom_out)

print("[Zoom] loaded v1.1.2 standalone.")
