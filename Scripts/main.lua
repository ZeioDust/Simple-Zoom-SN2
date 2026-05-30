-- Zoom mod for SN2.
-- Tries to hook PlayerController:InputKey for true hold-to-zoom (Z down/up).
-- Falls back to toggle if the hook doesn't fire.
-- On first zoom, dumps every pawn component name so we can find the real
-- helmet/visor name to add to HELMET_HINTS.
local UEHelpers = require("UEHelpers")

local BASE_FOV = 90.0
local MIN_FOV = 10.0
local START_FOV = 60.0
local STEP = 5.0
local EASE = 0.12

local zooming = false
local target_fov = BASE_FOV
local cur_fov = BASE_FOV
local last_log = 0
local hidden_comps = {}
local dumped_once = false

-- Only the 5 visible scuba mask sections. NOT "Scuba Mask Stencil" (used for
-- masking the underwater blue tint \xe2\x80\x94 hiding it leaves a blue square artifact).
-- NOT "Head" (that's the player model). NOT VolumeTracker (not a mesh).
local HELMET_NAMES = {
    ["ScubaMaskSections"] = true,
    ["ScubaMaskTopLeft"] = true,
    ["ScubaMaskTopRight"] = true,
    ["ScubaMaskNose"] = true,
    ["ScubaMaskBottomLeft"] = true,
    ["ScubaMaskBottomRight"] = true,
}

local function lower(s) return string.lower(tostring(s or "")) end

local function looks_like_helmet(name)
    return HELMET_NAMES[tostring(name)] == true
end

local function get_pawn()
    local pc = UEHelpers.GetPlayerController()
    if not pc or not pc:IsValid() then return nil end
    local pawn = pc.Pawn
    if not pawn or not pawn:IsValid() then return nil end
    return pawn
end

-- Walk RootComponent's attach tree to enumerate all scene components.
local function walk(comp, depth, cb)
    if not comp or not comp:IsValid() then return end
    cb(comp, depth)
    pcall(function()
        local children = comp.AttachChildren
        if children then
            local n = #children
            for i = 1, n do
                local child = children[i]
                if child then walk(child, depth + 1, cb) end
            end
        end
    end)
end

local function dump_components()
    if dumped_once then return end
    dumped_once = true
    local pawn = get_pawn()
    if not pawn then print("[Zoom] DUMP: no pawn"); return end
    print("[Zoom] ===== PAWN COMPONENTS =====")
    print("[Zoom] pawn class: " .. pawn:GetClass():GetFName():ToString())
    walk(pawn.RootComponent, 0, function(comp, d)
        pcall(function()
            local n = comp:GetFName():ToString()
            local cls = comp:GetClass():GetFName():ToString()
            print(string.format("[Zoom] %s%s  (%s)", string.rep("  ", d), n, cls))
        end)
    end)
    print("[Zoom] ===== END COMPONENTS =====")
end

local function hide_helmet()
    if #hidden_comps > 0 then return end
    local pawn = get_pawn()
    if not pawn then return end
    walk(pawn.RootComponent, 0, function(comp, _)
        pcall(function()
            local n = comp:GetFName():ToString()
            if looks_like_helmet(n) then
                comp:SetVisibility(false, false)
                table.insert(hidden_comps, comp)
                print("[Zoom] hidden: " .. n)
            end
        end)
    end)
end

local function show_helmet()
    for _, comp in ipairs(hidden_comps) do
        pcall(function()
            if comp:IsValid() then comp:SetVisibility(true, false) end
        end)
    end
    hidden_comps = {}
end

local function apply(fov)
    local pc = UEHelpers.GetPlayerController()
    if not pc or not pc:IsValid() then return end
    pcall(function()
        local cm = pc.PlayerCameraManager
        if cm and cm:IsValid() then
            cm.DefaultFOV = fov
            cm.LockedFOV = fov
            pcall(function() cm:SetFOV(fov) end)
        end
        pc:ProcessConsoleExec("FOV " .. string.format("%.0f", fov), nil, pc)
    end)
end

local function start_zoom()
    if zooming then return end
    zooming = true
    target_fov = START_FOV
    dump_components()
    hide_helmet()
    print("[Zoom] ON")
end

local function stop_zoom()
    if not zooming then return end
    zooming = false
    target_fov = BASE_FOV
    show_helmet()
    print("[Zoom] OFF")
end

-- Try to hook PlayerController:InputKey for real hold/release.
-- Sig: InputKey(FInputKeyEventArgs) or older (Key, EventType, AmountDepressed, bGamepad)
-- We just observe and check key name + event type. EventType: 0=Pressed, 1=Released.
local hook_fired = false
pcall(function()
    RegisterHook("/Script/Engine.PlayerController:InputKey", function(ctx, args, event_arg3, event_arg4)
        hook_fired = true
        -- We can't easily inspect FKey/FInputKeyEventArgs reliably across UE versions,
        -- so just dump on first fire to see what we get.
        -- If we can't read it, this hook is useless and toggle is the only option.
    end)
end)

local last = os.clock()
LoopAsync(0, function()
    local now = os.clock()
    local dt = now - last
    last = now

    if math.abs(cur_fov - target_fov) > 0.1 then
        cur_fov = cur_fov + (target_fov - cur_fov) * math.min(1.0, dt / EASE)
        apply(cur_fov)
    end

    if zooming and now - last_log > 0.5 then
        print(string.format("[Zoom] FOV=%.1f -> %.1f", cur_fov, target_fov))
        last_log = now
    end
    return false
end)

-- Z = toggle (only reliable input method available)
RegisterKeyBind(Key.Z, function()
    if zooming then stop_zoom() else start_zoom() end
end)

RegisterKeyBind(Key.OEM_PLUS, function()
    if not zooming then return end
    target_fov = math.max(MIN_FOV, target_fov - STEP)
    print(string.format("[Zoom] zoom in  -> FOV %.0f", target_fov))
end)

RegisterKeyBind(Key.OEM_MINUS, function()
    if not zooming then return end
    target_fov = math.min(START_FOV, target_fov + STEP)
    print(string.format("[Zoom] zoom out -> FOV %.0f", target_fov))
end)

print("[Zoom] loaded. Z = toggle zoom. +/- = adjust while zoomed.")
print("[Zoom] On first zoom, component names will be dumped \xe2\x80\x94 paste them back.")
