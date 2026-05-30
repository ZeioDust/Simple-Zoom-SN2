# Changelog

## 1.0.0

- Z toggles zoom (FOV 90 → 60).
- `+` zooms in further (down to FOV 10), `-` zooms back out.
- Smooth FOV ease (~0.12s).
- Hides scuba mask sections while zoomed so you're not looking through a porthole.
- Forces FOV via PlayerCameraManager + ProcessConsoleExec("FOV X") since SN2's camera overwrites DefaultFOV per frame.

Dropped from the original spec: hold-to-zoom (UE4SS for SN2 doesn't expose key release), scroll-wheel level cycling (no mouse wheel in `RegisterKeyBind`), vehicle/sprint disable (not worth implementing without proper input detection).
