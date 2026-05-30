Zoom v1.1.2 for Subnautica 2

What it does
------------
Press Z to zoom in, Z again to zoom out.
Press + or = while zoomed to zoom further (down to FOV 10).
Press - while zoomed to zoom back out (up to FOV 90).
Numpad + and - work too.

Hides your scuba mask, hands, and equipped tool while zoomed
so nothing scales weirdly at narrow FOV.

Install
-------
1. Install UE4SS for SN2 first:
   https://github.com/Subnautica2Modding/Subnautica2-UE4SS

2. Drop the Zoom folder into:
   <Steam>/steamapps/common/Subnautica2/Subnautica2/Binaries/Win64/ue4ss/Mods/

3. Open ue4ss/Mods/mods.txt in any text editor.
   Add this line above the "Keybinds : 1" line:
     Zoom : 1

4. Launch the game. If the UE4SS console prints
   "[Zoom] loaded v1.1.2 standalone", you're in.

Config
------
Open Scripts/main.lua. Top of the file:
  start_fov  - what zoom jumps to on Z press (default 60)
  min_fov    - how far + can crank it (default 10)
  step       - FOV change per +/- press (default 5)
  ease       - transition smoothness (default 0.12s)

Known issues
------------
- Hold-to-zoom isn't possible in this UE4SS build.
  Toggle only.
- If FOV stays stuck after you die or ragdoll, tap Z twice
  to clear it.
- Component names in HIDE_NAMES are hardcoded for the
  current SN2 build. If a patch renames them, edit the
  list at the top of main.lua.

License
-------
MIT. Take it, fork it, do whatever.
