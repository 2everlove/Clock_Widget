# ClockWidget modules

`ClockWidget.ps1` contains application bootstrap and visual tree construction.
Feature logic is dot-sourced from these files:

- `ClockWidget.Core.ps1`: config snapshots, persistence, tray icon, startup, widget visibility, move mode.
- `ClockWidget.ClockDisplay.ps1`: real clock text, background styling, outline rendering, clock-related settings.
- `ClockWidget.BdoTime.ps1`: Black Desert in-game time, transition text, BDO icons, BDO settings.
- `ClockWidget.BossAlert.ps1`: boss schedule data, boss alert display, highlight animation, boss row editor helpers.
- `ClockWidget.SettingsWindow.ps1`: settings window layout, preview refresh, shared settings controls.

Keep UI behavior stable by editing feature modules first and leaving the bootstrap order in `ClockWidget.ps1` unchanged unless a new module is added.
