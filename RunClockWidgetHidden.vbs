Set shell = CreateObject("WScript.Shell")
scriptPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\ClockWidget.ps1"
powerShellPath = shell.ExpandEnvironmentStrings("%WINDIR%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
shell.Run """" & powerShellPath & """ -NoProfile -ExecutionPolicy Bypass -File """ & scriptPath & """", 0, False
