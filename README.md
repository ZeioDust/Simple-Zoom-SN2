# Zoom

Press Z, world gets closer. Press Z again, world goes back. + and - while zoomed to crank the magnification up or down.

Built this because spotting a fragment 40m away in murky water is a pain when you can't tell if the blob is a fish or a rock. Now you can squint without swimming over.

## Install

1. UE4SS in your Subnautica 2 install. Use the SN2 community fork: https://github.com/Subnautica2Modding/Subnautica2-UE4SS — the vanilla UE4SS PS scan fails on SN2 right now. Contents go in `Subnautica2/Binaries/Win64/`.
2. Drop the `Zoom` folder into `Subnautica2/Binaries/Win64/ue4ss/Mods/`.
3. Add `Zoom : 1` to `ue4ss/Mods/mods.txt` (above the built-in Keybinds line).
4. Launch. `[Zoom] loaded.` in the UE4SS console means it's alive.

## Controls

- **Z** — toggle zoom (jumps to FOV 60)
- **= / +** — zoom in further, down to FOV 10
- **- / _** — zoom back out, up to FOV 90

Hides the scuba mask geometry while zoomed so you're not staring through a porthole.

## Why toggle and not hold

Wanted hold-to-zoom. Couldn't get it. The UE4SS build for SN2 doesn't expose `IsKeyDown`, `RegisterKeyBind` only fires on press not release, and hooking PlayerController::InputKey didn't fire either. Toggle is what works. Comfort Tweaks and other published SN2 FOV mods landed on the same answer.

If a future UE4SS build adds key polling I'll switch this to hold.

## Known issues

- **Hands and equipped tools scale up at low FOV.** This is how Unreal renders first-person attached meshes — same FOV as the world, so they grow when the world narrows. The clean fix needs a separate weapon-FOV render pass which means writing C++. Not happening in Lua. The scuba mask hide handles the worst of it; the hands you just live with.
- **FOV doesn't reset if you ragdoll/die while zoomed.** Tap Z twice to clear it.
- **Component name list is hardcoded for the current SN2 build.** If a patch renames `ScubaMaskTopLeft` etc., the hide list in `Scripts/main.lua` needs updating. Run with Z pressed once and grep the UE4SS log for the `===== PAWN COMPONENTS =====` dump to find the new names.

## Config

`Scripts/main.lua`, top of the file:

- `START_FOV` — what zoom jumps to on press (default 60)
- `MIN_FOV` — how far + can push it (default 10)
- `STEP` — FOV change per + / - press (default 5)
- `EASE` — transition time in seconds (default 0.12)
- `HELMET_NAMES` — set of component names to hide while zoomed

## License

MIT. Take it, fork it, ship your own.
