Zoom for Subnautica 2 — v1.1.3

I kept swimming halfway across a biome to find out the blob was a rock,
not a fish. So I made this.

Press Z. World gets closer. Press Z again, back to normal. While you're
zoomed, hit + or = to crank it tighter (down to FOV 10). Hit - to back
it off. Numpad works too if that's your thing.

Your hands, the scuba mask, and whatever tool you're holding all get
hidden while zoomed. Otherwise they balloon up at narrow FOV and it
looks awful. Yes I tried not hiding them. It was awful.


Install
-------
You need UE4SS for SN2 first. The community fork, not the regular one
(regular one's scan fails on SN2 right now):
   https://github.com/Subnautica2Modding/Subnautica2-UE4SS

Then drop the Zoom folder into:
   <your Steam>/steamapps/common/Subnautica2/Subnautica2/Binaries/Win64/ue4ss/Mods/

Open mods.txt in that same Mods folder. Add a line that says
   Zoom : 1
above the Keybinds line.

Launch. If UE4SS console says "[Zoom] loaded v1.1.3 standalone" you're
good.


About the toggle
----------------
I wanted hold-to-zoom. Press and hold Z, world close, let go, world
normal. Couldn't get it. UE4SS for SN2 doesn't expose key release
events — RegisterKeyBind only knows about presses. I tried hooking
PlayerController:InputKey. Didn't fire. Other SN2 FOV mods landed
on toggle for the same reason.

If a future UE4SS lands key polling I'll switch this to hold.


Tweaking it
-----------
Top of Scripts/main.lua there's a CONFIG table:
   start_fov   what zoom jumps to (60)
   min_fov     how far + goes (10)
   step        how much each press changes (5)
   ease        seconds to ease in/out (0.12)

Edit, save, restart the game. There's no hot reload here.


Stuff that's a bit broken
-------------------------
If you die or ragdoll while zoomed the FOV can stick. Tap Z twice to
clear it. I'd fix this properly but it's rare enough that I haven't.

The component names I hide are hardcoded — ScubaMaskTopLeft and friends.
If Unknown Worlds renames them in a patch the hide list breaks (mod
keeps working, you just see weird stuff). Open Scripts/main.lua, find
HIDE_NAMES at the top, replace the names. Pretty obvious.


MIT license. Fork it, ship your own.
