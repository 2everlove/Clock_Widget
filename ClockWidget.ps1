Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class NativeWindowTools {
    public const int GWL_EXSTYLE = -20;
    public const long WS_EX_TOOLWINDOW = 0x00000080L;
    public const long WS_EX_APPWINDOW = 0x00040000L;

    [DllImport("user32.dll", EntryPoint = "GetWindowLong")]
    private static extern int GetWindowLong32(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll", EntryPoint = "GetWindowLongPtr")]
    private static extern IntPtr GetWindowLongPtr64(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll", EntryPoint = "SetWindowLong")]
    private static extern int SetWindowLong32(IntPtr hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll", EntryPoint = "SetWindowLongPtr")]
    private static extern IntPtr SetWindowLongPtr64(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool DestroyIcon(IntPtr hIcon);

    public static IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex) {
        if (IntPtr.Size == 8) {
            return GetWindowLongPtr64(hWnd, nIndex);
        }
        return new IntPtr(GetWindowLong32(hWnd, nIndex));
    }

    public static IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong) {
        if (IntPtr.Size == 8) {
            return SetWindowLongPtr64(hWnd, nIndex, dwNewLong);
        }
        return new IntPtr(SetWindowLong32(hWnd, nIndex, dwNewLong.ToInt32()));
    }
}
"@

$script:AppName = "ClockWidget"
$script:AppDir = Split-Path -Parent $PSCommandPath
$script:ConfigPath = Join-Path $script:AppDir "clock_widget_config.json"
$script:DefaultTrayIconPath = Join-Path $script:AppDir "clock_widget_cyberpunk.ico"
$script:CustomTrayIconPath = Join-Path $script:AppDir "clock_widget_custom_icon"
$script:BdoBlackSpiritIconPath = Join-Path $script:AppDir "bdo_black_spirit_variant.png"
$script:BdoPapuIconPath = Join-Path $script:AppDir "bdo_papu_variant.png"
$script:StartupPath = Join-Path ([Environment]::GetFolderPath("Startup")) "$($script:AppName).vbs"
$script:PowerShellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
$script:SettingsWindow = $null

function Get-DefaultConfig {
    [pscustomobject]@{
        X = 80
        Y = 80
        FontSize = 34
        BackgroundOpacity = 0.86
        BackgroundColor = "#111111"
        TextColor = "#FFFFFF"
        TextColorTransparent = $false
        TextOutlineColor = "#000000"
        TextOutlineColorTransparent = $false
        FontFamily = "Segoe UI"
        TrayIconPath = ""
        TimeFormat = "24"
        MeridiemLanguage = "en"
        BdoTimeEnabled = $false
        BdoTimeFormat = "24"
        BdoIconType = "blackSpirit"
        BdoIconEnabled = $true
        BdoFontSize = 14
        BdoTimeOffsetSeconds = 0
        BdoTextColor = "#FF66FF"
        BdoTextColorTransparent = $false
        BdoTextOutlineColor = "#000000"
        BdoTextOutlineColorTransparent = $false
        BdoFontFamily = "Segoe UI"
        BdoTransitionEnabled = $false
        BdoTransitionFontSize = 12
        BdoTransitionTextColor = "#FFFFFF"
        BdoTransitionTextColorTransparent = $false
        BdoTransitionTextOutlineColor = "#000000"
        BdoTransitionTextOutlineColorTransparent = $false
        BdoTransitionFontFamily = "Segoe UI"
        BossAlertEnabled = $true
        BossFontSize = 14
        BossTextColor = "#FFFFFF"
        BossTextColorTransparent = $false
        BossTextOutlineColor = "#000000"
        BossTextOutlineColorTransparent = $false
        BossFontFamily = "Segoe UI"
        BossAlertBeforeSeconds = 86400
        BossAlertAfterSeconds = 0
        BossMarginTop = 0
        BossMarginBottom = 0
        BossHighlightAnimationSeconds = 1.5
        BossHighlightColor = "#FFFFFF"
        BossRows = @()
    }
}

function Read-WidgetConfig {
    if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
        return Get-DefaultConfig
    }

    try {
        $config = Get-Content -LiteralPath $script:ConfigPath -Raw | ConvertFrom-Json
        $default = Get-DefaultConfig

        foreach ($name in "X", "Y", "FontSize", "BackgroundColor", "TextColor", "TextColorTransparent", "TextOutlineColor", "TextOutlineColorTransparent", "FontFamily", "TrayIconPath", "TimeFormat", "MeridiemLanguage", "BdoTimeEnabled", "BdoTimeFormat", "BdoIconType", "BdoIconEnabled", "BdoFontSize", "BdoTimeOffsetSeconds", "BdoTextColor", "BdoTextColorTransparent", "BdoTextOutlineColor", "BdoTextOutlineColorTransparent", "BdoFontFamily", "BdoTransitionEnabled", "BdoTransitionFontSize", "BdoTransitionTextColor", "BdoTransitionTextColorTransparent", "BdoTransitionTextOutlineColor", "BdoTransitionTextOutlineColorTransparent", "BdoTransitionFontFamily", "BossAlertEnabled", "BossFontSize", "BossTextColor", "BossTextColorTransparent", "BossTextOutlineColor", "BossTextOutlineColorTransparent", "BossFontFamily", "BossAlertBeforeSeconds", "BossAlertAfterSeconds", "BossMarginTop", "BossMarginBottom", "BossHighlightAnimationSeconds", "BossHighlightColor", "BossRows") {
            if ($null -eq $config.$name) {
                $config | Add-Member -NotePropertyName $name -NotePropertyValue $default.$name
            }
        }

        if ($null -eq $config.BackgroundOpacity) {
            if ($null -ne $config.Opacity) {
                $config | Add-Member -NotePropertyName BackgroundOpacity -NotePropertyValue ([double]$config.Opacity)
            }
            else {
                $config | Add-Member -NotePropertyName BackgroundOpacity -NotePropertyValue $default.BackgroundOpacity
            }
        }

        return $config
    }
    catch {
        return Get-DefaultConfig
    }
}

function Get-BossDayDefinitions {
    @(
        [pscustomobject]@{ Key = "Mon"; Label = "월"; DayOfWeek = [System.DayOfWeek]::Monday }
        [pscustomobject]@{ Key = "Tue"; Label = "화"; DayOfWeek = [System.DayOfWeek]::Tuesday }
        [pscustomobject]@{ Key = "Wed"; Label = "수"; DayOfWeek = [System.DayOfWeek]::Wednesday }
        [pscustomobject]@{ Key = "Thu"; Label = "목"; DayOfWeek = [System.DayOfWeek]::Thursday }
        [pscustomobject]@{ Key = "Fri"; Label = "금"; DayOfWeek = [System.DayOfWeek]::Friday }
        [pscustomobject]@{ Key = "Sat"; Label = "토"; DayOfWeek = [System.DayOfWeek]::Saturday }
        [pscustomobject]@{ Key = "Sun"; Label = "일"; DayOfWeek = [System.DayOfWeek]::Sunday }
    )
}

function Get-BossDayKey {
    param([System.DayOfWeek]$DayOfWeek)

    switch ($DayOfWeek) {
        "Monday" { "Mon" }
        "Tuesday" { "Tue" }
        "Wednesday" { "Wed" }
        "Thursday" { "Thu" }
        "Friday" { "Fri" }
        "Saturday" { "Sat" }
        default { "Sun" }
    }
}

function Normalize-BossTime {
    param([object]$Value)

    $text = ([string]$Value).Trim()
    if ($text -notmatch '^(\d{1,2}):(\d{1,2})$') {
        return $null
    }

    $hour = [int]$matches[1]
    $minute = [int]$matches[2]
    if ($hour -lt 0 -or $hour -gt 23 -or $minute -lt 0 -or $minute -gt 59) {
        return $null
    }

    "{0:00}:{1:00}" -f $hour, $minute
}

function Split-BossTimeParts {
    param([object]$Value)

    $time = Normalize-BossTime $Value
    if ($null -eq $time) {
        return [pscustomobject]@{ Hour = "12"; Minute = "00" }
    }

    $parts = $time.Split(":")
    [pscustomobject]@{
        Hour = [string]([int]$parts[0])
        Minute = "{0:00}" -f ([int]$parts[1])
    }
}

function Normalize-BossRows {
    param([object]$Rows)

    $dayKeys = @((Get-BossDayDefinitions | ForEach-Object { $_.Key }))
    $normalized = @()
    foreach ($row in @($Rows)) {
        if ($null -eq $row) {
            continue
        }

        $name = ([string]$row.Name).Trim()
        $days = @($row.Days) | Where-Object { $dayKeys -contains ([string]$_) } | Select-Object -Unique
        $times = @($row.Times) | ForEach-Object { Normalize-BossTime $_ } | Where-Object { $null -ne $_ } | Sort-Object -Unique
        $dayTimes = [ordered]@{}
        foreach ($key in $dayKeys) {
            $dayTimes[$key] = @()
        }
        if ($row.PSObject.Properties["DayTimes"]) {
            foreach ($key in $dayKeys) {
                $value = if ($row.DayTimes.PSObject.Properties[$key]) { $row.DayTimes.PSObject.Properties[$key].Value } else { @() }
                $dayTimes[$key] = @($value) |
                    ForEach-Object { Normalize-BossTime $_ } |
                    Where-Object { $null -ne $_ } |
                    Sort-Object -Unique
            }
        }
        else {
            foreach ($key in $days) {
                $dayTimes[$key] = @($times)
            }
        }
        $days = @($dayKeys | Where-Object { @($dayTimes[$_]).Count -gt 0 })
        [int]$priority = 0
        [void][int]::TryParse(([string]$row.Priority), [ref]$priority)

        $normalized += [pscustomobject]@{
            Name = $name
            Days = @($days)
            Times = @($dayTimes.Values | ForEach-Object { $_ } | Sort-Object -Unique)
            DayTimes = [pscustomobject]$dayTimes
            Priority = [Math]::Max(0, [Math]::Min(10, $priority))
            Highlight = [bool]$row.Highlight
            Alert = if ($null -eq $row.Alert) { $true } else { [bool]$row.Alert }
        }
    }

    @($normalized)
}

function Copy-BossRows {
    param([object]$Rows)

    @(Normalize-BossRows $Rows | ForEach-Object {
        [pscustomobject]@{
            Name = [string]$_.Name
            Days = @($_.Days)
            Times = @($_.Times)
            DayTimes = [pscustomobject]$_.DayTimes
            Priority = [int]$_.Priority
            Highlight = [bool]$_.Highlight
            Alert = [bool]$_.Alert
        }
    })
}

function Get-BossRowsSignature {
    param([object]$Rows)

    @(Normalize-BossRows $Rows) | ConvertTo-Json -Depth 6 -Compress
}

function Save-WidgetConfig {
    if ($null -eq $script:Window) {
        return
    }

    Clamp-WidgetToScreenBounds

    [pscustomobject]@{
        X = [int]$script:Window.Left
        Y = [int]$script:Window.Top
        FontSize = [int]$script:FontSize
        BackgroundOpacity = [double]$script:BackgroundOpacity
        BackgroundColor = [string]$script:BackgroundColor
        TextColor = [string]$script:TextColor
        TextColorTransparent = [bool]$script:TextColorTransparent
        TextOutlineColor = [string]$script:TextOutlineColor
        TextOutlineColorTransparent = [bool]$script:TextOutlineColorTransparent
        FontFamily = [string]$script:FontFamily
        TrayIconPath = [string]$script:TrayIconPath
        TimeFormat = [string]$script:TimeFormat
        MeridiemLanguage = [string]$script:MeridiemLanguage
        BdoTimeEnabled = [bool]$script:BdoTimeEnabled
        BdoTimeFormat = [string]$script:BdoTimeFormat
        BdoIconType = [string]$script:BdoIconType
        BdoIconEnabled = [bool]$script:BdoIconEnabled
        BdoFontSize = [int]$script:BdoFontSize
        BdoTimeOffsetSeconds = [int]$script:BdoTimeOffsetSeconds
        BdoTextColor = [string]$script:BdoTextColor
        BdoTextColorTransparent = [bool]$script:BdoTextColorTransparent
        BdoTextOutlineColor = [string]$script:BdoTextOutlineColor
        BdoTextOutlineColorTransparent = [bool]$script:BdoTextOutlineColorTransparent
        BdoFontFamily = [string]$script:BdoFontFamily
        BdoTransitionEnabled = [bool]$script:BdoTransitionEnabled
        BdoTransitionFontSize = [int]$script:BdoTransitionFontSize
        BdoTransitionTextColor = [string]$script:BdoTransitionTextColor
        BdoTransitionTextColorTransparent = [bool]$script:BdoTransitionTextColorTransparent
        BdoTransitionTextOutlineColor = [string]$script:BdoTransitionTextOutlineColor
        BdoTransitionTextOutlineColorTransparent = [bool]$script:BdoTransitionTextOutlineColorTransparent
        BdoTransitionFontFamily = [string]$script:BdoTransitionFontFamily
        BossAlertEnabled = [bool]$script:BossAlertEnabled
        BossFontSize = [int]$script:BossFontSize
        BossTextColor = [string]$script:BossTextColor
        BossTextColorTransparent = [bool]$script:BossTextColorTransparent
        BossTextOutlineColor = [string]$script:BossTextOutlineColor
        BossTextOutlineColorTransparent = [bool]$script:BossTextOutlineColorTransparent
        BossFontFamily = [string]$script:BossFontFamily
        BossAlertBeforeSeconds = [int]$script:BossAlertBeforeSeconds
        BossAlertAfterSeconds = [int]$script:BossAlertAfterSeconds
        BossMarginTop = [int]$script:BossMarginTop
        BossMarginBottom = [int]$script:BossMarginBottom
        BossHighlightAnimationSeconds = [double]$script:BossHighlightAnimationSeconds
        BossHighlightColor = [string]$script:BossHighlightColor
        BossRows = @(Copy-BossRows $script:BossRows)
    } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $script:ConfigPath -Encoding UTF8
}

function Get-SettingsPropertyNames {
    @(
        "FontSize", "BackgroundOpacity", "BackgroundColor", "TextColor", "TextColorTransparent",
        "TextOutlineColor", "TextOutlineColorTransparent", "FontFamily",
        "TrayIconPath", "TimeFormat", "MeridiemLanguage",
        "BdoTimeEnabled", "BdoTimeFormat", "BdoIconType", "BdoIconEnabled", "BdoFontSize", "BdoTimeOffsetSeconds",
        "BdoTextColor", "BdoTextColorTransparent", "BdoTextOutlineColor", "BdoTextOutlineColorTransparent", "BdoFontFamily",
        "BdoTransitionEnabled", "BdoTransitionFontSize", "BdoTransitionTextColor", "BdoTransitionTextColorTransparent",
        "BdoTransitionTextOutlineColor", "BdoTransitionTextOutlineColorTransparent", "BdoTransitionFontFamily",
        "BossAlertEnabled", "BossFontSize", "BossTextColor", "BossTextColorTransparent",
        "BossTextOutlineColor", "BossTextOutlineColorTransparent", "BossFontFamily",
        "BossAlertBeforeSeconds", "BossAlertAfterSeconds", "BossMarginTop", "BossMarginBottom",
        "BossHighlightAnimationSeconds", "BossHighlightColor", "BossRows", "StartupEnabled"
    )
}

function Get-SettingsSnapshot {
    [pscustomobject]@{
        FontSize = [int]$script:FontSize
        BackgroundOpacity = [double]$script:BackgroundOpacity
        BackgroundColor = [string]$script:BackgroundColor
        TextColor = [string]$script:TextColor
        TextColorTransparent = [bool]$script:TextColorTransparent
        TextOutlineColor = [string]$script:TextOutlineColor
        TextOutlineColorTransparent = [bool]$script:TextOutlineColorTransparent
        FontFamily = [string]$script:FontFamily
        TrayIconPath = [string]$script:TrayIconPath
        TimeFormat = [string]$script:TimeFormat
        MeridiemLanguage = [string]$script:MeridiemLanguage
        BdoTimeEnabled = [bool]$script:BdoTimeEnabled
        BdoTimeFormat = [string]$script:BdoTimeFormat
        BdoIconType = [string]$script:BdoIconType
        BdoIconEnabled = [bool]$script:BdoIconEnabled
        BdoFontSize = [int]$script:BdoFontSize
        BdoTimeOffsetSeconds = [int]$script:BdoTimeOffsetSeconds
        BdoTextColor = [string]$script:BdoTextColor
        BdoTextColorTransparent = [bool]$script:BdoTextColorTransparent
        BdoTextOutlineColor = [string]$script:BdoTextOutlineColor
        BdoTextOutlineColorTransparent = [bool]$script:BdoTextOutlineColorTransparent
        BdoFontFamily = [string]$script:BdoFontFamily
        BdoTransitionEnabled = [bool]$script:BdoTransitionEnabled
        BdoTransitionFontSize = [int]$script:BdoTransitionFontSize
        BdoTransitionTextColor = [string]$script:BdoTransitionTextColor
        BdoTransitionTextColorTransparent = [bool]$script:BdoTransitionTextColorTransparent
        BdoTransitionTextOutlineColor = [string]$script:BdoTransitionTextOutlineColor
        BdoTransitionTextOutlineColorTransparent = [bool]$script:BdoTransitionTextOutlineColorTransparent
        BdoTransitionFontFamily = [string]$script:BdoTransitionFontFamily
        BossAlertEnabled = [bool]$script:BossAlertEnabled
        BossFontSize = [int]$script:BossFontSize
        BossTextColor = [string]$script:BossTextColor
        BossTextColorTransparent = [bool]$script:BossTextColorTransparent
        BossTextOutlineColor = [string]$script:BossTextOutlineColor
        BossTextOutlineColorTransparent = [bool]$script:BossTextOutlineColorTransparent
        BossFontFamily = [string]$script:BossFontFamily
        BossAlertBeforeSeconds = [int]$script:BossAlertBeforeSeconds
        BossAlertAfterSeconds = [int]$script:BossAlertAfterSeconds
        BossMarginTop = [int]$script:BossMarginTop
        BossMarginBottom = [int]$script:BossMarginBottom
        BossHighlightAnimationSeconds = [double]$script:BossHighlightAnimationSeconds
        BossHighlightColor = [string]$script:BossHighlightColor
        BossRows = @(Copy-BossRows $script:BossRows)
        StartupEnabled = [bool](Test-StartupEnabled)
    }
}

function Copy-SettingsSnapshot {
    param([object]$Snapshot)

    $copy = [ordered]@{}
    foreach ($name in (Get-SettingsPropertyNames)) {
        $copy[$name] = $Snapshot.$name
    }
    [pscustomobject]$copy
}

function Test-SettingsSnapshotEqual {
    param(
        [object]$Left,
        [object]$Right
    )

    if ($null -eq $Left -or $null -eq $Right) {
        return $false
    }

    foreach ($name in (Get-SettingsPropertyNames)) {
        if ($name -eq "BossRows") {
            if ((Get-BossRowsSignature $Left.BossRows) -ne (Get-BossRowsSignature $Right.BossRows)) {
                return $false
            }
            continue
        }
        if ([string]$Left.$name -ne [string]$Right.$name) {
            return $false
        }
    }
    return $true
}

function Set-SettingsVariables {
    param([object]$Snapshot)

    $script:FontSize = [int]$Snapshot.FontSize
    $script:BackgroundOpacity = [double]$Snapshot.BackgroundOpacity
    $script:BackgroundColor = [string]$Snapshot.BackgroundColor
    $script:TextColor = [string]$Snapshot.TextColor
    $script:TextColorTransparent = [bool]$Snapshot.TextColorTransparent
    $script:TextOutlineColor = [string]$Snapshot.TextOutlineColor
    $script:TextOutlineColorTransparent = [bool]$Snapshot.TextOutlineColorTransparent
    $script:FontFamily = [string]$Snapshot.FontFamily
    $script:TrayIconPath = [string]$Snapshot.TrayIconPath
    $script:TimeFormat = [string]$Snapshot.TimeFormat
    $script:MeridiemLanguage = [string]$Snapshot.MeridiemLanguage
    $script:BdoTimeEnabled = [bool]$Snapshot.BdoTimeEnabled
    $script:BdoTimeFormat = [string]$Snapshot.BdoTimeFormat
    $script:BdoIconType = [string]$Snapshot.BdoIconType
    $script:BdoIconEnabled = [bool]$Snapshot.BdoIconEnabled
    $script:BdoFontSize = [int]$Snapshot.BdoFontSize
    $script:BdoTimeOffsetSeconds = [int]$Snapshot.BdoTimeOffsetSeconds
    $script:BdoTextColor = [string]$Snapshot.BdoTextColor
    $script:BdoTextColorTransparent = [bool]$Snapshot.BdoTextColorTransparent
    $script:BdoTextOutlineColor = [string]$Snapshot.BdoTextOutlineColor
    $script:BdoTextOutlineColorTransparent = [bool]$Snapshot.BdoTextOutlineColorTransparent
    $script:BdoFontFamily = [string]$Snapshot.BdoFontFamily
    $script:BdoTransitionEnabled = [bool]$Snapshot.BdoTransitionEnabled
    $script:BdoTransitionFontSize = [int]$Snapshot.BdoTransitionFontSize
    $script:BdoTransitionTextColor = [string]$Snapshot.BdoTransitionTextColor
    $script:BdoTransitionTextColorTransparent = [bool]$Snapshot.BdoTransitionTextColorTransparent
    $script:BdoTransitionTextOutlineColor = [string]$Snapshot.BdoTransitionTextOutlineColor
    $script:BdoTransitionTextOutlineColorTransparent = [bool]$Snapshot.BdoTransitionTextOutlineColorTransparent
    $script:BdoTransitionFontFamily = [string]$Snapshot.BdoTransitionFontFamily
    $script:BossAlertEnabled = [bool]$Snapshot.BossAlertEnabled
    $script:BossFontSize = [int]$Snapshot.BossFontSize
    $script:BossTextColor = [string]$Snapshot.BossTextColor
    $script:BossTextColorTransparent = [bool]$Snapshot.BossTextColorTransparent
    $script:BossTextOutlineColor = [string]$Snapshot.BossTextOutlineColor
    $script:BossTextOutlineColorTransparent = [bool]$Snapshot.BossTextOutlineColorTransparent
    $script:BossFontFamily = [string]$Snapshot.BossFontFamily
    $script:BossAlertBeforeSeconds = [int]$Snapshot.BossAlertBeforeSeconds
    $script:BossAlertAfterSeconds = [int]$Snapshot.BossAlertAfterSeconds
    $script:BossMarginTop = [int]$Snapshot.BossMarginTop
    $script:BossMarginBottom = [int]$Snapshot.BossMarginBottom
    $script:BossHighlightAnimationSeconds = [double]$Snapshot.BossHighlightAnimationSeconds
    $script:BossHighlightColor = [string]$Snapshot.BossHighlightColor
    $script:BossRows = @(Copy-BossRows $Snapshot.BossRows)
}

function Set-StartupState {
    param([bool]$Enabled)

    if ($Enabled) {
        if (-not (Test-StartupEnabled)) {
            Enable-Startup
        }
    }
    else {
        if (Test-StartupEnabled) {
            Disable-Startup
        }
    }

    if ($script:StartupMenuItem) {
        $script:StartupMenuItem.IsChecked = Test-StartupEnabled
    }
}

function Apply-SettingsSnapshot {
    param(
        [object]$Snapshot,
        [bool]$Persist
    )

    Set-SettingsVariables $Snapshot
    if ($script:BackgroundLayer) {
        $script:BackgroundLayer.Fill = Get-BackgroundBrush $script:BackgroundOpacity
        $script:BackgroundLayer.Opacity = $script:BackgroundOpacity
    }
    Update-BdoLogo
    Apply-ClockTextStyle
    Apply-BdoTimeStyle
    Apply-BossAlertStyle
    if ($script:BossAlertPanel) {
        $script:BossAlertPanel.Children.Clear()
    }
    Update-ClockText
    Apply-TrayIcon
    Set-StartupState ([bool]$Snapshot.StartupEnabled)

    if ($Persist) {
        Save-WidgetConfig
    }
}

function Invoke-WithSettingsSnapshot {
    param(
        [object]$Snapshot,
        [scriptblock]$ScriptBlock
    )

    $current = Get-SettingsSnapshot
    try {
        Set-SettingsVariables $Snapshot
        & $ScriptBlock
    }
    finally {
        Set-SettingsVariables $current
    }
}

function Set-OptionsGroupVisibility {
    param(
        [object]$Expander,
        [object]$Panel,
        [bool]$Visible,
        [bool]$ExpandWhenVisible = $false
    )

    $visibility = if ($Visible) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    if ($Expander) {
        $Expander.Visibility = $visibility
        if ($Visible -and $ExpandWhenVisible) {
            $Expander.IsExpanded = $true
        }
    }
    elseif ($Panel) {
        $Panel.Visibility = $visibility
    }
}

function Sync-SettingsControlsFromDraft {
    if ($null -eq $script:SettingsDraft -or $script:SyncingSettingsControls) {
        return
    }

    $draft = $script:SettingsDraft
    $script:SyncingSettingsControls = $true
    try {
        if ($script:StartupCheckBox) { $script:StartupCheckBox.IsChecked = [bool]$draft.StartupEnabled }
        if ($script:BdoTimeCheckBox) { $script:BdoTimeCheckBox.IsChecked = [bool]$draft.BdoTimeEnabled }
        Set-OptionsGroupVisibility $script:BdoOptionsExpander $script:BdoOptionsPanel ([bool]$draft.BdoTimeEnabled)
        if ($script:BdoTimeFormat24RadioButton) { $script:BdoTimeFormat24RadioButton.IsChecked = ($draft.BdoTimeFormat -ne "12") }
        if ($script:BdoTimeFormat12RadioButton) { $script:BdoTimeFormat12RadioButton.IsChecked = ($draft.BdoTimeFormat -eq "12") }
        if ($script:BdoIconEnabledCheckBox) { $script:BdoIconEnabledCheckBox.IsChecked = [bool]$draft.BdoIconEnabled }
        if ($script:BdoIconChoicePanel) { $script:BdoIconChoicePanel.Visibility = if ($draft.BdoIconEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
        if ($script:BdoBlackSpiritRadioButton) { $script:BdoBlackSpiritRadioButton.IsChecked = ($draft.BdoIconType -ne "papu") }
        if ($script:BdoPapuRadioButton) { $script:BdoPapuRadioButton.IsChecked = ($draft.BdoIconType -eq "papu") }
        if ($script:BdoFontSizeSlider) { $script:BdoFontSizeSlider.Value = [double]$draft.BdoFontSize }
        if ($script:BdoFontSizeValueText) { $script:BdoFontSizeValueText.Text = [string]$draft.BdoFontSize }
        if ($script:BdoTimeOffsetTextBox) { $script:BdoTimeOffsetTextBox.Text = [string]$draft.BdoTimeOffsetSeconds }
        if ($script:BdoTextColorText) { $script:BdoTextColorText.Text = [string]$draft.BdoTextColor }
        Set-ColorSwatch $script:BdoTextColorSwatch $draft.BdoTextColor
        if ($script:BdoTextOutlineColorText) { $script:BdoTextOutlineColorText.Text = [string]$draft.BdoTextOutlineColor }
        Set-ColorSwatch $script:BdoTextOutlineColorSwatch $draft.BdoTextOutlineColor
        if ($script:BdoFontFamilyText) { Set-FontValueText $script:BdoFontFamilyText $draft.BdoFontFamily }
        if ($script:BdoTransitionCheckBox) { $script:BdoTransitionCheckBox.IsChecked = [bool]$draft.BdoTransitionEnabled }
        if ($script:BdoTransitionOptionsPanel) { $script:BdoTransitionOptionsPanel.Visibility = if ($draft.BdoTransitionEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
        if ($script:BdoTransitionFontSizeSlider) { $script:BdoTransitionFontSizeSlider.Value = [double]$draft.BdoTransitionFontSize }
        if ($script:BdoTransitionFontSizeValueText) { $script:BdoTransitionFontSizeValueText.Text = [string]$draft.BdoTransitionFontSize }
        if ($script:BdoTransitionTextColorText) { $script:BdoTransitionTextColorText.Text = [string]$draft.BdoTransitionTextColor }
        Set-ColorSwatch $script:BdoTransitionTextColorSwatch $draft.BdoTransitionTextColor
        if ($script:BdoTransitionTextOutlineColorText) { $script:BdoTransitionTextOutlineColorText.Text = [string]$draft.BdoTransitionTextOutlineColor }
        Set-ColorSwatch $script:BdoTransitionTextOutlineColorSwatch $draft.BdoTransitionTextOutlineColor
        if ($script:BdoTransitionFontFamilyText) { Set-FontValueText $script:BdoTransitionFontFamilyText $draft.BdoTransitionFontFamily }

        if ($script:BossAlertCheckBox) { $script:BossAlertCheckBox.IsChecked = [bool]$draft.BossAlertEnabled }
        Set-OptionsGroupVisibility $script:BossOptionsExpander $script:BossOptionsPanel ([bool]$draft.BossAlertEnabled)
        if ($script:BossFontSizeSlider) { $script:BossFontSizeSlider.Value = [double]$draft.BossFontSize }
        if ($script:BossFontSizeValueText) { $script:BossFontSizeValueText.Text = [string]$draft.BossFontSize }
        if ($script:BossMarginTopSlider) { $script:BossMarginTopSlider.Value = [double]$draft.BossMarginTop }
        if ($script:BossMarginTopValueText) { $script:BossMarginTopValueText.Text = [string]$draft.BossMarginTop }
        if ($script:BossMarginBottomSlider) { $script:BossMarginBottomSlider.Value = [double]$draft.BossMarginBottom }
        if ($script:BossMarginBottomValueText) { $script:BossMarginBottomValueText.Text = [string]$draft.BossMarginBottom }
        if ($script:BossHighlightAnimationTextBox) { $script:BossHighlightAnimationTextBox.Text = ([double]$draft.BossHighlightAnimationSeconds).ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture) }
        if ($script:BossHighlightColorText) { $script:BossHighlightColorText.Text = [string]$draft.BossHighlightColor }
        Set-ColorSwatch $script:BossHighlightColorSwatch $draft.BossHighlightColor
        Refresh-BossRowsEditor
        Set-BossAlertTimeInputControls "Before" ([int]$draft.BossAlertBeforeSeconds)
        Set-BossAlertTimeInputControls "After" ([int]$draft.BossAlertAfterSeconds)
        if ($script:BossTextColorText) { $script:BossTextColorText.Text = [string]$draft.BossTextColor }
        Set-ColorSwatch $script:BossTextColorSwatch $draft.BossTextColor
        if ($script:BossTextOutlineColorText) { $script:BossTextOutlineColorText.Text = [string]$draft.BossTextOutlineColor }
        Set-ColorSwatch $script:BossTextOutlineColorSwatch $draft.BossTextOutlineColor
        if ($script:BossFontFamilyText) { Set-FontValueText $script:BossFontFamilyText $draft.BossFontFamily }

        if ($script:TimeFormat24RadioButton) { $script:TimeFormat24RadioButton.IsChecked = ($draft.TimeFormat -ne "12") }
        if ($script:TimeFormat12RadioButton) { $script:TimeFormat12RadioButton.IsChecked = ($draft.TimeFormat -eq "12") }
        if ($script:MeridiemLanguagePanel) { $script:MeridiemLanguagePanel.Visibility = if ($draft.TimeFormat -eq "12") { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
        if ($script:MeridiemEnglishRadioButton) { $script:MeridiemEnglishRadioButton.IsChecked = ($draft.MeridiemLanguage -ne "ko") }
        if ($script:MeridiemKoreanRadioButton) { $script:MeridiemKoreanRadioButton.IsChecked = ($draft.MeridiemLanguage -eq "ko") }
        if ($script:FontSizeSlider) { $script:FontSizeSlider.Value = [double]$draft.FontSize }
        if ($script:FontSizeValueText) { $script:FontSizeValueText.Text = [string]$draft.FontSize }
        if ($script:BackgroundOpacityValueText) { $script:BackgroundOpacityValueText.Text = [string]([int][Math]::Round([double]$draft.BackgroundOpacity * 100)) }
        if ($script:BackgroundColorText) { $script:BackgroundColorText.Text = [string]$draft.BackgroundColor }
        Set-ColorSwatch $script:BackgroundColorSwatch $draft.BackgroundColor
        if ($script:TextColorText) { $script:TextColorText.Text = [string]$draft.TextColor }
        Set-ColorSwatch $script:TextColorSwatch $draft.TextColor
        if ($script:TextOutlineColorText) { $script:TextOutlineColorText.Text = [string]$draft.TextOutlineColor }
        Set-ColorSwatch $script:TextOutlineColorSwatch $draft.TextOutlineColor
        if ($script:FontFamilyText) { Set-FontValueText $script:FontFamilyText $draft.FontFamily }
    if ($script:TrayIconPathText) { $script:TrayIconPathText.Text = [System.IO.Path]::GetFileName($draft.TrayIconPath) }

        Sync-TransparentColorControls
        Update-TrayIconPreview
        Update-SettingsPreview
    }
    finally {
        $script:SyncingSettingsControls = $false
    }
}

function Set-SettingsDraftValue {
    param(
        [string]$Name,
        [object]$Value
    )

    if ($script:SyncingSettingsControls) {
        return $true
    }
    if ($null -eq $script:SettingsDraft) {
        return $false
    }

    $script:SettingsDraft.$Name = $Value
    $script:SettingsDirty = -not (Test-SettingsSnapshotEqual $script:SettingsDraft $script:SettingsOriginal)
    Sync-SettingsControlsFromDraft
    Request-SettingsPreviewUpdate
    return $true
}

function Test-StartupEnabled {
    Test-Path -LiteralPath $script:StartupPath
}

function Hide-WindowFromAltTab {
    if ($null -eq $script:Window) {
        return
    }

    $helper = New-Object System.Windows.Interop.WindowInteropHelper $script:Window
    $handle = $helper.Handle
    if ($handle -eq [IntPtr]::Zero) {
        return
    }

    $style = [NativeWindowTools]::GetWindowLongPtr($handle, [NativeWindowTools]::GWL_EXSTYLE).ToInt64()
    $style = ($style -bor [NativeWindowTools]::WS_EX_TOOLWINDOW) -band (-bnot [NativeWindowTools]::WS_EX_APPWINDOW)
    [NativeWindowTools]::SetWindowLongPtr($handle, [NativeWindowTools]::GWL_EXSTYLE, (New-Object IntPtr $style)) | Out-Null
}

function Get-WidgetWindowBoundsSize {
    if ($null -eq $script:Window) {
        return [pscustomobject]@{ Width = 0.0; Height = 0.0 }
    }

    $width = [double]$script:Window.ActualWidth
    $height = [double]$script:Window.ActualHeight

    if ($width -le 0 -or $height -le 0) {
        $script:Window.Measure([System.Windows.Size]::new([double]::PositiveInfinity, [double]::PositiveInfinity))
        $desired = $script:Window.DesiredSize
        if ($width -le 0) {
            $width = [double]$desired.Width
        }
        if ($height -le 0) {
            $height = [double]$desired.Height
        }
    }

    [pscustomobject]@{
        Width = [double][Math]::Max(1.0, $width)
        Height = [double][Math]::Max(1.0, $height)
    }
}

function Clamp-WidgetToScreenBounds {
    if ($null -eq $script:Window) {
        return
    }

    $bounds = Get-WidgetWindowBoundsSize
    $screenLeft = [double][System.Windows.SystemParameters]::VirtualScreenLeft
    $screenTop = [double][System.Windows.SystemParameters]::VirtualScreenTop
    $screenRight = $screenLeft + [double][System.Windows.SystemParameters]::VirtualScreenWidth
    $screenBottom = $screenTop + [double][System.Windows.SystemParameters]::VirtualScreenHeight

    $maxLeft = [Math]::Max($screenLeft, $screenRight - $bounds.Width)
    $maxTop = [Math]::Max($screenTop, $screenBottom - $bounds.Height)
    $nextLeft = [Math]::Min($maxLeft, [Math]::Max($screenLeft, [double]$script:Window.Left))
    $nextTop = [Math]::Min($maxTop, [Math]::Max($screenTop, [double]$script:Window.Top))

    if ([Math]::Abs($script:Window.Left - $nextLeft) -gt 0.1) {
        $script:Window.Left = $nextLeft
    }
    if ([Math]::Abs($script:Window.Top - $nextTop) -gt 0.1) {
        $script:Window.Top = $nextTop
    }
}

function Update-TrayToggleText {
    if ($script:TrayToggleItem) {
        if ($script:Window -and $script:Window.IsVisible) {
            $script:TrayToggleItem.Text = "위젯 숨기기"
        }
        else {
            $script:TrayToggleItem.Text = "위젯 보이기"
        }
    }

    if ($script:WidgetToggleMenuItem) {
        if ($script:Window -and $script:Window.IsVisible) {
            $script:WidgetToggleMenuItem.Header = "위젯 숨기기"
        }
        else {
            $script:WidgetToggleMenuItem.Header = "위젯 보이기"
        }
    }
}

function Set-WidgetVisible {
    param([bool]$Visible)

    if ($Visible) {
        $script:Window.Show()
        $script:Window.Activate()
        Hide-WindowFromAltTab
    }
    else {
        Save-WidgetConfig
        $script:Window.Hide()
    }

    Update-TrayToggleText
}

function Toggle-WidgetVisible {
    Set-WidgetVisible (-not $script:Window.IsVisible)
}

function Create-TrayIcon {
    $script:TrayMenu = New-Object System.Windows.Forms.ContextMenuStrip

    $settingsItem = $script:TrayMenu.Items.Add("설정")
    $settingsItem.Add_Click({ Show-SettingsWindow })

    $script:TrayToggleItem = $script:TrayMenu.Items.Add("위젯 숨기기")
    $script:TrayToggleItem.Add_Click({ Toggle-WidgetVisible })

    $script:TrayMenu.Items.Add("-") | Out-Null

    $exitItem = $script:TrayMenu.Items.Add("종료")
    $exitItem.Add_Click({
        Save-WidgetConfig
        if ($script:TrayIcon) {
            $script:TrayIcon.Visible = $false
        }
        $script:Window.Close()
    })

    $script:TrayIcon = New-Object System.Windows.Forms.NotifyIcon
    $script:TrayIcon.Text = "Clock Widget"
    $script:TrayIcon.ContextMenuStrip = $script:TrayMenu
    $script:TrayIcon.Visible = $true
    $script:TrayIcon.Add_DoubleClick({ Toggle-WidgetVisible })
    Apply-TrayIcon

    Update-TrayToggleText
}

function Enable-Startup {
    $command = "`"$script:PowerShellPath`" -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $escapedCommand = $command.Replace('"', '""')
    $startupScript = @"
Set shell = CreateObject("WScript.Shell")
shell.Run "$escapedCommand", 0, False
"@
    Set-Content -LiteralPath $script:StartupPath -Value $startupScript -Encoding ASCII
}

function Disable-Startup {
    if (Test-Path -LiteralPath $script:StartupPath) {
        Remove-Item -LiteralPath $script:StartupPath
    }
}

function Ensure-DefaultTrayIcon {
    if (Test-Path -LiteralPath $script:DefaultTrayIconPath) {
        if ((Get-Item -LiteralPath $script:DefaultTrayIconPath).Length -gt 0) {
            return
        }
        Remove-Item -LiteralPath $script:DefaultTrayIconPath -Force
    }

    $bitmap = New-Object System.Drawing.Bitmap 64, 64, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $outer = New-Object System.Drawing.Rectangle 5, 5, 54, 54
    $inner = New-Object System.Drawing.Rectangle 11, 11, 42, 42
    $accent = New-Object System.Drawing.Rectangle 14, 14, 36, 36

    $glowCyan = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 0, 255, 255)), 4
    $glowMagenta = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 255, 0, 210)), 4
    $graphics.DrawArc($glowCyan, $outer, 200, 210)
    $graphics.DrawArc($glowMagenta, $outer, 20, 210)

    $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outer, ([System.Drawing.Color]::FromArgb(255, 0, 235, 255)), ([System.Drawing.Color]::FromArgb(255, 255, 0, 220)), ([System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
    $graphics.FillEllipse($gradient, $outer)

    $coreBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 10, 12, 28))
    $graphics.FillEllipse($coreBrush, $inner)

    $ringPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 0, 255, 255)), 2
    $graphics.DrawEllipse($ringPen, $accent)

    $magentaPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 36, 220)), 4
    $cyanPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 0, 255, 255)), 3
    $graphics.DrawLine($magentaPen, 32, 32, 32, 18)
    $graphics.DrawLine($cyanPen, 32, 32, 45, 38)

    $centerBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $graphics.FillEllipse($centerBrush, 28, 28, 8, 8)

    $hIcon = $bitmap.GetHicon()
    $icon = [System.Drawing.Icon]::FromHandle($hIcon)
    $stream = [System.IO.File]::Open($script:DefaultTrayIconPath, [System.IO.FileMode]::Create)
    try {
        $icon.Save($stream)
    }
    finally {
        $stream.Dispose()
        $icon.Dispose()
        [NativeWindowTools]::DestroyIcon($hIcon) | Out-Null
        $graphics.Dispose()
        $bitmap.Dispose()
        $glowCyan.Dispose()
        $glowMagenta.Dispose()
        $gradient.Dispose()
        $coreBrush.Dispose()
        $ringPen.Dispose()
        $magentaPen.Dispose()
        $cyanPen.Dispose()
        $centerBrush.Dispose()
    }
}

function Test-UsableFile {
    param([string]$Path)

    (Test-Path -LiteralPath $Path) -and ((Get-Item -LiteralPath $Path).Length -gt 0)
}

function Save-BdoBlackSpiritIcon {
    $bitmap = New-Object System.Drawing.Bitmap 96, 96, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $dark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 28, 30))
    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 0, 0, 0)), 5
    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $red = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 210, 0, 20))
    $smilePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 4
    $gemOutline = New-Object System.Drawing.Pen ([System.Drawing.Color]::Black), 4
    $cyanPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 0, 245, 255)), 2
    $magentaPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180, 255, 0, 210)), 2

    $bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bodyPath.AddBezier(15, 59, 17, 21, 37, 11, 48, 10)
    $bodyPath.AddBezier(59, 11, 80, 20, 81, 59, 81, 59)
    $bodyPath.AddBezier(81, 59, 93, 67, 82, 79, 76, 72)
    $bodyPath.AddBezier(76, 72, 72, 91, 60, 91, 58, 73)
    $bodyPath.AddLine(38, 73, 38, 73)
    $bodyPath.AddBezier(38, 73, 36, 91, 24, 90, 20, 72)
    $bodyPath.AddBezier(20, 72, 13, 79, 3, 67, 15, 59)
    $bodyPath.CloseFigure()
    $graphics.FillPath($dark, $bodyPath)
    $graphics.DrawPath($cyanPen, $bodyPath)
    $graphics.DrawPath($outline, $bodyPath)
    $graphics.DrawArc($magentaPen, 20, 19, 56, 60, 208, 122)

    $gem = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gem.AddPolygon(@(
        (New-Object System.Drawing.Point 48, 18),
        (New-Object System.Drawing.Point 62, 32),
        (New-Object System.Drawing.Point 48, 47),
        (New-Object System.Drawing.Point 34, 32)
    ))
    $graphics.FillPath($white, $gem)
    $graphics.DrawPath($gemOutline, $gem)
    $curlPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::Black), 4
    $graphics.DrawArc($curlPen, 43, 25, 13, 13, 20, 245)

    $graphics.FillEllipse($red, 31, 42, 8, 8)
    $graphics.FillEllipse($red, 57, 42, 8, 8)
    $graphics.DrawArc($smilePen, 41, 50, 16, 8, 20, 140)

    $bitmap.Save($script:BdoBlackSpiritIconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bodyPath.Dispose()
    $gem.Dispose()
    $dark.Dispose()
    $outline.Dispose()
    $white.Dispose()
    $red.Dispose()
    $smilePen.Dispose()
    $gemOutline.Dispose()
    $cyanPen.Dispose()
    $magentaPen.Dispose()
    $curlPen.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

function Save-BdoPapuIcon {
    $bitmap = New-Object System.Drawing.Bitmap 96, 96, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 20, 20, 24)), 4
    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $blue = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 180, 225, 246))
    $pink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 210, 214))
    $green = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 158, 187, 136))
    $dark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 15, 15, 20))
    $mouthBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 145, 105))
    $hatBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245, 110, 105, 128))
    $hatLine = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 3
    $cyanPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(170, 0, 245, 255)), 2
    $magentaPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 255, 0, 210)), 2

    $leftEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $leftEar.AddPolygon(@((New-Object System.Drawing.Point 20, 39), (New-Object System.Drawing.Point 9, 7), (New-Object System.Drawing.Point 39, 32)))
    $rightEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rightEar.AddPolygon(@((New-Object System.Drawing.Point 76, 39), (New-Object System.Drawing.Point 87, 7), (New-Object System.Drawing.Point 57, 32)))
    $graphics.FillPath($white, $leftEar)
    $graphics.FillPath($white, $rightEar)
    $graphics.DrawPath($cyanPen, $leftEar)
    $graphics.DrawPath($magentaPen, $rightEar)
    $graphics.DrawPath($outline, $leftEar)
    $graphics.DrawPath($outline, $rightEar)

    $graphics.FillEllipse($white, 17, 24, 62, 48)
    $graphics.DrawArc($cyanPen, 17, 24, 62, 48, 190, 110)
    $graphics.DrawArc($magentaPen, 17, 24, 62, 48, 300, 70)
    $graphics.DrawEllipse($outline, 17, 24, 62, 48)
    $graphics.FillEllipse($blue, 24, 32, 48, 23)
    $graphics.FillPie($green, 26, 58, 44, 30, 0, 180)

    $graphics.FillEllipse($dark, 33, 43, 6, 11)
    $graphics.FillEllipse($dark, 57, 43, 6, 11)
    $graphics.FillEllipse($mouthBrush, 42, 48, 13, 18)
    $graphics.DrawEllipse($outline, 42, 48, 13, 18)
    $graphics.FillEllipse($pink, 63, 56, 8, 8)

    $graphics.FillEllipse($hatBrush, 34, 13, 34, 19)
    $graphics.DrawArc($hatLine, 35, 23, 32, 10, 185, 160)

    $bitmap.Save($script:BdoPapuIconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $leftEar.Dispose()
    $rightEar.Dispose()
    $outline.Dispose()
    $white.Dispose()
    $blue.Dispose()
    $pink.Dispose()
    $green.Dispose()
    $dark.Dispose()
    $mouthBrush.Dispose()
    $hatBrush.Dispose()
    $hatLine.Dispose()
    $cyanPen.Dispose()
    $magentaPen.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

function Ensure-BdoLogoAssets {
    Save-BdoBlackSpiritIcon
    Save-BdoPapuIcon
}

function Get-BdoLogoPath {
    Ensure-BdoLogoAssets
    if ($script:BdoIconType -eq "papu") {
        return $script:BdoPapuIconPath
    }
    return $script:BdoBlackSpiritIconPath
}

function Get-EffectiveTrayIconPath {
    Ensure-DefaultTrayIcon
    if (-not [string]::IsNullOrWhiteSpace($script:TrayIconPath) -and (Test-Path -LiteralPath $script:TrayIconPath)) {
        return $script:TrayIconPath
    }
    return $script:DefaultTrayIconPath
}

function New-TrayIconObject {
    $path = Get-EffectiveTrayIconPath

    try {
        if ([System.IO.Path]::GetExtension($path).ToLowerInvariant() -eq ".ico") {
            return New-Object System.Drawing.Icon $path
        }

        $bitmap = New-Object System.Drawing.Bitmap $path
        $hIcon = $bitmap.GetHicon()
        try {
            $icon = [System.Drawing.Icon]::FromHandle($hIcon)
            return $icon.Clone()
        }
        finally {
            [NativeWindowTools]::DestroyIcon($hIcon) | Out-Null
            $bitmap.Dispose()
        }
    }
    catch {
        return [System.Drawing.SystemIcons]::Information.Clone()
    }
}

function New-WpfImageSource {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $image = New-Object System.Windows.Media.Imaging.BitmapImage
    $image.BeginInit()
    $image.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $image.UriSource = New-Object System.Uri $Path
    $image.EndInit()
    $image.Freeze()
    $image
}

function Update-TrayIconPreview {
    $path = Get-EffectiveTrayIconPath
    if ($script:SettingsDraft -and -not [string]::IsNullOrWhiteSpace($script:SettingsDraft.TrayIconPath) -and (Test-Path -LiteralPath $script:SettingsDraft.TrayIconPath)) {
        $path = [string]$script:SettingsDraft.TrayIconPath
    }
    if ($script:TrayIconPathText) {
        $script:TrayIconPathText.Text = [System.IO.Path]::GetFileName($path)
    }
    if ($script:TrayIconPreviewImage) {
        $script:TrayIconPreviewImage.Source = New-WpfImageSource $path
    }
}

function Apply-TrayIcon {
    if (-not $script:TrayIcon) {
        return
    }

    $newIcon = New-TrayIconObject
    $oldIcon = $script:CurrentTrayIcon
    $script:TrayIcon.Icon = $newIcon
    $script:CurrentTrayIcon = $newIcon

    if ($oldIcon) {
        $oldIcon.Dispose()
    }

    Update-TrayIconPreview
}

function Show-TrayIconDialog {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "트레이 아이콘 선택"
    $dialog.Filter = "Icon or image files (*.ico;*.png;*.jpg;*.jpeg;*.bmp)|*.ico;*.png;*.jpg;*.jpeg;*.bmp|All files (*.*)|*.*"
    $dialog.Multiselect = $false

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $extension = [System.IO.Path]::GetExtension($dialog.FileName)
        $target = "$script:CustomTrayIconPath$extension"
        Copy-Item -LiteralPath $dialog.FileName -Destination $target -Force
        if (Set-SettingsDraftValue "TrayIconPath" $target) {
            return
        }
        $script:TrayIconPath = $target
        Apply-TrayIcon
        Save-WidgetConfig
    }
}

function ConvertTo-WpfColor {
    param(
        [string]$Hex,
        [string]$Fallback
    )

    try {
        return [System.Windows.Media.ColorConverter]::ConvertFromString($Hex)
    }
    catch {
        return [System.Windows.Media.ColorConverter]::ConvertFromString($Fallback)
    }
}

function ConvertTo-DrawingColor {
    param(
        [string]$Hex,
        [string]$Fallback
    )

    $color = ConvertTo-WpfColor $Hex $Fallback
    [System.Drawing.Color]::FromArgb($color.R, $color.G, $color.B)
}

function ConvertTo-HexColor {
    param([System.Drawing.Color]$Color)

    "#{0:X2}{1:X2}{2:X2}" -f $Color.R, $Color.G, $Color.B
}

function Normalize-HexColorInput {
    param(
        [string]$Value,
        [string]$Fallback
    )

    $text = ([string]$Value).Trim()
    if ($text -notmatch '^#') {
        $text = "#$text"
    }

    if ($text -match '^#[0-9A-Fa-f]{6}$') {
        return $text.ToUpperInvariant()
    }

    return ([string]$Fallback).ToUpperInvariant()
}

function Set-ColorSettingByName {
    param(
        [string]$Name,
        [string]$Value
    )

    $fallback = [string](Get-SettingOrScriptValue $Name)
    $nextValue = Normalize-HexColorInput $Value $fallback
    switch ($Name) {
        "BackgroundColor" { Set-BackgroundColor $nextValue }
        "TextColor" { Set-TextColor $nextValue }
        "TextOutlineColor" { Set-TextOutlineColor $nextValue }
        "BdoTextColor" { Set-BdoTextColor $nextValue }
        "BdoTextOutlineColor" { Set-BdoTextOutlineColor $nextValue }
        "BdoTransitionTextColor" { Set-BdoTransitionTextColor $nextValue }
        "BdoTransitionTextOutlineColor" { Set-BdoTransitionTextOutlineColor $nextValue }
        "BossTextColor" { Set-BossTextColor $nextValue }
        "BossTextOutlineColor" { Set-BossTextOutlineColor $nextValue }
        "BossHighlightColor" { Set-BossHighlightColor $nextValue }
    }
}

function New-ColorBrushOrTransparent {
    param(
        [string]$Hex,
        [string]$Fallback,
        [bool]$Transparent
    )

    if ($Transparent) {
        return [System.Windows.Media.Brushes]::Transparent
    }

    $color = ConvertTo-WpfColor $Hex $Fallback
    New-Object System.Windows.Media.SolidColorBrush $color
}

function Get-OutlineEffectOpacity {
    param([bool]$Transparent)

    if ($Transparent) { 0 } else { 1 }
}

function Get-WidgetPadding {
    param([int]$Value)

    $horizontal = [double][Math]::Max(2, [Math]::Round($Value * 0.18))
    $vertical = [double][Math]::Max(1, [Math]::Round($Value * 0.06))
    New-Object System.Windows.Thickness $horizontal, $vertical, $horizontal, $vertical
}

function Get-BackgroundBrush {
    param([double]$Opacity)

    $baseColor = ConvertTo-WpfColor $script:BackgroundColor "#111111"
    $color = [System.Windows.Media.Color]::FromRgb($baseColor.R, $baseColor.G, $baseColor.B)
    New-Object System.Windows.Media.SolidColorBrush $color
}

function Get-PreviewBackgroundBrush {
    param([double]$Opacity)

    $baseColor = ConvertTo-WpfColor $script:BackgroundColor "#111111"
    $alpha = [byte][Math]::Max(0, [Math]::Min(255, [Math]::Round($Opacity * 255)))
    $color = [System.Windows.Media.Color]::FromArgb($alpha, $baseColor.R, $baseColor.G, $baseColor.B)
    New-Object System.Windows.Media.SolidColorBrush $color
}

function Get-TextBrush {
    New-ColorBrushOrTransparent $script:TextColor "#FFFFFF" $script:TextColorTransparent
}

function Get-TextOutlineBrush {
    New-ColorBrushOrTransparent $script:TextOutlineColor "#000000" $script:TextOutlineColorTransparent
}

function Get-BdoTextBrush {
    New-ColorBrushOrTransparent $script:BdoTextColor "#FF66FF" $script:BdoTextColorTransparent
}

function Get-BdoTextOutlineBrush {
    New-ColorBrushOrTransparent $script:BdoTextOutlineColor "#000000" $script:BdoTextOutlineColorTransparent
}

function Get-BdoTransitionTextBrush {
    New-ColorBrushOrTransparent $script:BdoTransitionTextColor "#FFFFFF" $script:BdoTransitionTextColorTransparent
}

function Get-BdoTransitionTextOutlineBrush {
    New-ColorBrushOrTransparent $script:BdoTransitionTextOutlineColor "#000000" $script:BdoTransitionTextOutlineColorTransparent
}

function Get-BossTextBrush {
    New-ColorBrushOrTransparent $script:BossTextColor "#FFFFFF" $script:BossTextColorTransparent
}

function Get-BossTextOutlineBrush {
    New-ColorBrushOrTransparent $script:BossTextOutlineColor "#000000" $script:BossTextOutlineColorTransparent
}

function Get-BossHighlightBrush {
    $baseColor = ConvertTo-WpfColor $script:BossHighlightColor "#FFFFFF"
    $color = [System.Windows.Media.Color]::FromArgb(180, $baseColor.R, $baseColor.G, $baseColor.B)
    New-Object System.Windows.Media.SolidColorBrush $color
}

function Get-OutlineThickness {
    [double][Math]::Max(1.0, [Math]::Round($script:FontSize * 0.04, 1))
}

function Get-BdoOutlineThickness {
    [double][Math]::Max(0.75, [Math]::Round($script:BdoFontSize * 0.06, 1))
}

function New-ClockTextBlock {
    param([System.Windows.Media.Brush]$Brush)

    $block = New-Object System.Windows.Controls.TextBlock
    $block.Text = "00:00:00"
    $block.FontFamily = New-Object System.Windows.Media.FontFamily $script:FontFamily
    $block.FontSize = [double]$script:FontSize
    $block.FontWeight = [System.Windows.FontWeights]::Bold
    $block.Foreground = $Brush
    $block.Margin = Get-WidgetPadding $script:FontSize
    $block.LineHeight = [double]($script:FontSize * 1.0)
    $block.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $block.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $block.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $block
}

function New-BdoTextBlock {
    param([System.Windows.Media.Brush]$Brush)

    $block = New-Object System.Windows.Controls.TextBlock
    $block.Text = "00:00"
    $block.FontFamily = New-Object System.Windows.Media.FontFamily $script:BdoFontFamily
    $block.FontSize = [double]$script:BdoFontSize
    $block.FontWeight = [System.Windows.FontWeights]::Bold
    $block.Foreground = $Brush
    $block.Margin = New-Object System.Windows.Thickness 0
    $block.LineHeight = [double]($script:BdoFontSize * 1.0)
    $block.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $block.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $block.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $block
}

function Apply-ClockTextStyle {
    if (-not $script:TextBlock) {
        return
    }

    $fontFamily = New-Object System.Windows.Media.FontFamily $script:FontFamily
    $padding = Get-WidgetPadding $script:FontSize
    $lineHeight = [double]($script:FontSize * 1.0)
    $outlineBrush = Get-TextOutlineBrush
    $fillBrush = Get-TextBrush
    $outlineThickness = Get-OutlineThickness

    if ($script:OutlineTextBlocks) {
        foreach ($item in $script:OutlineTextBlocks) {
            $item.Block.FontFamily = $fontFamily
            $item.Block.FontSize = [double]$script:FontSize
            $item.Block.LineHeight = $lineHeight
            $item.Block.Margin = $padding
            $item.Block.Foreground = $outlineBrush
            $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $outlineThickness), ($item.Y * $outlineThickness)
        }
    }

    $script:TextBlock.FontFamily = $fontFamily
    $script:TextBlock.FontSize = [double]$script:FontSize
    $script:TextBlock.LineHeight = $lineHeight
    $script:TextBlock.Margin = $padding
    $script:TextBlock.Foreground = $fillBrush

    Apply-BossAlertStyle
}

function Apply-BossAlertStyle {
    if (-not $script:BossAlertPanel -and -not $script:BossAlertTextBlock) {
        return
    }

    $bossFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))
    if ($script:BossAlertPanel) {
        $script:BossAlertPanel.Margin = New-Object System.Windows.Thickness 2, $script:BossMarginTop, 2, $script:BossMarginBottom
        foreach ($child in @($script:BossAlertPanel.Children)) {
            if ($child -is [System.Windows.Controls.Border] -and $child.Child -is [System.Windows.Controls.TextBlock]) {
                Apply-BossAlertTextBlockStyle $child.Child $bossFontSize
            }
        }
    }
    elseif ($script:BossAlertTextBlock) {
        Apply-BossAlertTextBlockStyle $script:BossAlertTextBlock $bossFontSize
        $script:BossAlertTextBlock.Margin = New-Object System.Windows.Thickness 2, $script:BossMarginTop, 2, $script:BossMarginBottom
    }
}

function Apply-BossAlertTextBlockStyle {
    param(
        [System.Windows.Controls.TextBlock]$TextBlock,
        [double]$FontSize = ([double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize)))
    )

    $TextBlock.FontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
    $TextBlock.FontSize = $FontSize
    $TextBlock.LineHeight = [double]($FontSize * 1.32)
    $TextBlock.Foreground = Get-BossTextBrush
    $TextBlock.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
        Color = (ConvertTo-WpfColor $script:BossTextOutlineColor "#000000")
        BlurRadius = 0
        ShadowDepth = 1
        Opacity = (Get-OutlineEffectOpacity $script:BossTextOutlineColorTransparent)
    }
}

function Start-BossHighlightAnimation {
    param(
        [System.Windows.Controls.Border]$Border,
        [System.Windows.Shapes.Rectangle]$FillElement = $null
    )

    $brush = Get-BossHighlightBrush
    $seconds = [double][Math]::Max(0.2, [Math]::Min(10.0, $script:BossHighlightAnimationSeconds))

    if ($FillElement) {
        $FillElement.Fill = $brush
        $FillElement.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $FillElement.Width = [double]::NaN
        $FillElement.RenderTransformOrigin = New-Object System.Windows.Point 0, 0.5
        $scale = New-Object System.Windows.Media.ScaleTransform 0, 1
        $FillElement.RenderTransform = $scale
        $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
        $animation.From = 0.0
        $animation.To = 1.0
        $animation.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds($seconds))
        $animation.AutoReverse = $true
        $animation.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        $animation.EasingFunction = New-Object System.Windows.Media.Animation.SineEase -Property @{
            EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut
        }
        $scale.BeginAnimation([System.Windows.Media.ScaleTransform]::ScaleXProperty, $animation)
    }
    else {
        $brush.Opacity = 0.0
        $Border.Background = $brush
        $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
        $animation.From = 0.0
        $animation.To = 1.0
        $animation.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds($seconds))
        $animation.AutoReverse = $true
        $animation.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        $animation.EasingFunction = New-Object System.Windows.Media.Animation.SineEase -Property @{
            EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut
        }
        $brush.BeginAnimation([System.Windows.Media.Brush]::OpacityProperty, $animation)
    }
}

function New-BossAlertDisplayItem {
    param(
        [string]$Text,
        [object]$BossParts = @(),
        [string]$StableKey = $Text
    )

    $border = New-Object System.Windows.Controls.Border
    $border.CornerRadius = New-Object System.Windows.CornerRadius 3
    $border.Padding = New-Object System.Windows.Thickness 0
    $border.Margin = New-Object System.Windows.Thickness 0, 0, 0, 1
    $border.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $border.Uid = $StableKey
    $border.Background = [System.Windows.Media.Brushes]::Transparent

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.FontWeight = [System.Windows.FontWeights]::Bold
    $textBlock.TextAlignment = [System.Windows.TextAlignment]::Center
    $textBlock.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $textBlock.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    Apply-BossAlertTextBlockStyle $textBlock

    if (@($BossParts).Count -gt 0) {
        $suffix = $Text -replace '^\[[^\]]+\]', ''
        $textBlock.Inlines.Add((New-Object System.Windows.Documents.Run "[")) | Out-Null
        for ($i = 0; $i -lt @($BossParts).Count; $i++) {
            if ($i -gt 0) {
                $textBlock.Inlines.Add((New-Object System.Windows.Documents.Run " / ")) | Out-Null
            }
            $part = @($BossParts)[$i]
            if ([bool]$part.Highlight) {
                $nameBorder = New-Object System.Windows.Controls.Border
                $nameBorder.CornerRadius = New-Object System.Windows.CornerRadius 3
                $nameBorder.Padding = New-Object System.Windows.Thickness 2, 1, 2, 1
                $nameBorder.Margin = New-Object System.Windows.Thickness 0
                $nameBorder.ClipToBounds = $true

                $nameGrid = New-Object System.Windows.Controls.Grid
                $fill = New-Object System.Windows.Shapes.Rectangle
                $fill.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
                $fill.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
                $fill.RadiusX = 3
                $fill.RadiusY = 3
                $fill.IsHitTestVisible = $false
                $nameGrid.Children.Add($fill) | Out-Null

                $nameText = New-Object System.Windows.Controls.TextBlock
                $nameText.Text = [string]$part.Name
                $nameText.FontWeight = [System.Windows.FontWeights]::Bold
                $nameText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
                $nameText.FontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))
                $nameText.Foreground = Get-BossTextBrush
                $nameText.LineHeight = [double]([Math]::Max(8, [Math]::Min(48, $script:BossFontSize)) * 1.2)
                $nameText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
                $nameGrid.Children.Add($nameText) | Out-Null
                $nameBorder.Child = $nameGrid
                Start-BossHighlightAnimation $nameBorder $fill
                $textBlock.Inlines.Add((New-Object System.Windows.Documents.InlineUIContainer $nameBorder)) | Out-Null
            }
            else {
                $textBlock.Inlines.Add((New-Object System.Windows.Documents.Run ([string]$part.Name))) | Out-Null
            }
        }
        $suffixRun = New-Object System.Windows.Documents.Run ("]$suffix")
        $textBlock.Inlines.Add($suffixRun) | Out-Null
    }
    else {
        $textBlock.Text = $Text
        $suffixRun = $null
    }

    $border.Child = $textBlock
    $border.Tag = [pscustomobject]@{
        TextBlock = $textBlock
        SuffixRun = $suffixRun
        HasBossParts = (@($BossParts).Count -gt 0)
    }
    $border
}

function Update-BossAlertDisplayItemText {
    param(
        [System.Windows.Controls.Border]$Item,
        [string]$Text
    )

    if (-not $Item -or -not $Item.Tag) {
        return
    }

    if ([bool]$Item.Tag.HasBossParts -and $Item.Tag.SuffixRun) {
        $suffix = $Text -replace '^\[[^\]]+\]', ''
        $Item.Tag.SuffixRun.Text = "]$suffix"
    }
    elseif ($Item.Tag.TextBlock) {
        $Item.Tag.TextBlock.Text = $Text
    }
}

function Apply-BdoTimeStyle {
    if (-not $script:BdoTimePanel) {
        return
    }

    $fontFamily = New-Object System.Windows.Media.FontFamily $script:BdoFontFamily
    $lineHeight = [double]($script:BdoFontSize * 1.0)
    $outlineBrush = Get-BdoTextOutlineBrush
    $fillBrush = Get-BdoTextBrush
    $outlineThickness = Get-BdoOutlineThickness

    if ($script:BdoOutlineTextBlocks) {
        foreach ($item in $script:BdoOutlineTextBlocks) {
            $item.Block.FontFamily = $fontFamily
            $item.Block.FontSize = [double]$script:BdoFontSize
            $item.Block.LineHeight = $lineHeight
            $item.Block.Foreground = $outlineBrush
            $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $outlineThickness), ($item.Y * $outlineThickness)
        }
    }

    $script:BdoTimeTextBlock.FontFamily = $fontFamily
    $script:BdoTimeTextBlock.FontSize = [double]$script:BdoFontSize
    $script:BdoTimeTextBlock.LineHeight = $lineHeight
    $script:BdoTimeTextBlock.Foreground = $fillBrush
    $script:BdoTimePanel.Margin = New-Object System.Windows.Thickness 0, ([Math]::Max(2, [Math]::Round($script:BdoFontSize * 0.10))), 0, -2

    if ($script:BdoTransitionTextBlock) {
        $transitionFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BdoTransitionFontSize))
        $script:BdoTransitionTextBlock.FontFamily = New-Object System.Windows.Media.FontFamily $script:BdoTransitionFontFamily
        $script:BdoTransitionTextBlock.FontSize = $transitionFontSize
        $script:BdoTransitionTextBlock.LineHeight = [double]($transitionFontSize * 1.0)
        $script:BdoTransitionTextBlock.Foreground = Get-BdoTransitionTextBrush
        $script:BdoTransitionTextBlock.Margin = New-Object System.Windows.Thickness 6, 0, 0, 0
        $script:BdoTransitionTextBlock.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
            Color = (ConvertTo-WpfColor $script:BdoTransitionTextOutlineColor "#000000")
            BlurRadius = 0
            ShadowDepth = 1
            Opacity = (Get-OutlineEffectOpacity $script:BdoTransitionTextOutlineColorTransparent)
        }
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled) {
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }

    if ($script:BdoLogoImage) {
        $iconSize = [double][Math]::Max(16, [Math]::Min(30, [Math]::Round($script:BdoFontSize * 1.25)))
        $script:BdoLogoImage.Width = $iconSize
        $script:BdoLogoImage.Height = $iconSize
        if ($script:BdoIconEnabled) {
            $script:BdoLogoImage.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BdoLogoImage.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }

    if ($script:BdoTimeEnabled) {
        $script:BdoTimePanel.Visibility = [System.Windows.Visibility]::Visible
    }
    else {
        $script:BdoTimePanel.Visibility = [System.Windows.Visibility]::Collapsed
    }
}

function Get-ClockText {
    param([datetime]$Value = (Get-Date))

    if ($script:TimeFormat -eq "12") {
        if ($script:MeridiemLanguage -eq "ko") {
            return $Value.ToString("tt hh:mm:ss", [System.Globalization.CultureInfo]::GetCultureInfo("ko-KR"))
        }

        return $Value.ToString("tt hh:mm:ss", [System.Globalization.CultureInfo]::GetCultureInfo("en-US")).ToUpperInvariant()
    }

    $Value.ToString("HH:mm:ss")
}

function Get-BdoGameTimeText {
    param([datetime]$UtcNow = ([datetime]::UtcNow))

    $state = Get-BdoGameTimeState $UtcNow
    $hours = [int]$state.Hours
    $minutes = [int]$state.Minutes

    if ($script:BdoTimeFormat -eq "12") {
        $period = if ($hours -lt 12) { "AM" } else { "PM" }
        $displayHour = $hours % 12
        if ($displayHour -eq 0) {
            $displayHour = 12
        }
        return "{0} {1:00}:{2:00}" -f $period, $displayHour, $minutes
    }

    "{0:00}:{1:00}" -f $hours, $minutes
}

function Get-BdoGameTimeState {
    param([datetime]$UtcNow = ([datetime]::UtcNow))

    $UtcNow = $UtcNow.AddSeconds(-2)
    $anchor = [datetime]::SpecifyKind(([datetime]"2018-06-08T20:20:00"), [System.DateTimeKind]::Utc)
    $cycleSeconds = 4 * 60 * 60
    $daySeconds = 200 * 60
    $dayStartMinutes = 7 * 60
    $nightStartMinutes = 22 * 60
    $dayGameMinutesPerRealMinute = 4.5
    $nightGameMinutesPerRealMinute = 13.5
    $baseCalibrationSeconds = 150
    $elapsedSeconds = ($UtcNow - $anchor).TotalSeconds
    $position = $elapsedSeconds % $cycleSeconds
    if ($position -lt 0) {
        $position += $cycleSeconds
    }

    if ($position -lt $daySeconds) {
        $gameMinutes = $dayStartMinutes + (($position / 60.0) * $dayGameMinutesPerRealMinute)
    }
    else {
        $gameMinutes = $nightStartMinutes + ((($position - $daySeconds) / 60.0) * $nightGameMinutesPerRealMinute)
    }

    $gameMinutes = ($gameMinutes + (($baseCalibrationSeconds + [double]$script:BdoTimeOffsetSeconds) / 60.0)) % 1440
    if ($gameMinutes -lt 0) {
        $gameMinutes += 1440
    }

    $displayGameMinutes = [int][Math]::Floor($gameMinutes)
    $hours = [int][Math]::Floor($displayGameMinutes / 60)
    $minutes = [int]($displayGameMinutes % 60)
    $isDay = ($gameMinutes -ge $dayStartMinutes -and $gameMinutes -lt $nightStartMinutes)
    if ($isDay) {
        $remainingGameMinutes = $nightStartMinutes - $gameMinutes
        $remainingRealSeconds = ($remainingGameMinutes / $dayGameMinutesPerRealMinute) * 60.0
        $nextLabel = "밤까지"
    }
    else {
        if ($gameMinutes -ge $nightStartMinutes) {
            $remainingGameMinutes = (24 * 60) - $gameMinutes + $dayStartMinutes
        }
        else {
            $remainingGameMinutes = $dayStartMinutes - $gameMinutes
        }
        $remainingRealSeconds = ($remainingGameMinutes / $nightGameMinutesPerRealMinute) * 60.0
        $nextLabel = "낮까지"
    }

    [pscustomobject]@{
        GameMinutes = [double]$gameMinutes
        Hours = [int]$hours
        Minutes = [int]$minutes
        IsDay = [bool]$isDay
        NextPhaseLabel = [string]$nextLabel
        RemainingRealSeconds = [double][Math]::Max(0, $remainingRealSeconds)
    }
}

function Get-BdoTransitionText {
    param([datetime]$UtcNow = ([datetime]::UtcNow))

    $state = Get-BdoGameTimeState $UtcNow
    $remainingMinutes = [int][Math]::Ceiling(([double]$state.RemainingRealSeconds) / 60.0)
    "({0} {1}분)" -f $state.NextPhaseLabel, $remainingMinutes
}

function Get-BossSchedule {
    @(
        [pscustomobject]@{ Time = "00:15"; Mon = ""; Tue = ""; Wed = ""; Thu = "벨"; Fri = ""; Sat = ""; Sun = "가모스" }
        [pscustomobject]@{ Time = "02:00"; Mon = "불가살 / 크자카"; Tue = "우투리 / 누베르"; Wed = "금돼지왕 / 오핀"; Thu = "금돼지왕 / 카란다"; Fri = "산군 / 쿠툼"; Sat = "불가살 / 쿠툼"; Sun = "산군 / 누베르" }
        [pscustomobject]@{ Time = "11:00"; Mon = "우투리 / 누베르"; Tue = "금돼지왕 / 쿠툼"; Wed = ""; Thu = "산군 / 크자카"; Fri = "불가살 / 카란다"; Sat = "우투리 / 카란다"; Sun = "불가살 / 쿠툼" }
        [pscustomobject]@{ Time = "14:00"; Mon = "가모스"; Tue = "가모스"; Wed = "가모스"; Thu = "가모스"; Fri = "가모스"; Sat = "가모스"; Sun = "가모스" }
        [pscustomobject]@{ Time = "16:00"; Mon = "금돼지왕 / 쿠툼"; Tue = "산군 / 누베르"; Wed = "산군 / 카란다"; Thu = "불가살 / 누베르"; Fri = "우투리 / 크자카"; Sat = "금돼지왕 / 크자카"; Sun = "우투리 / 카란다" }
        [pscustomobject]@{ Time = "17:00"; Mon = ""; Tue = ""; Wed = ""; Thu = ""; Fri = ""; Sat = "검은그림자"; Sun = "벨" }
        [pscustomobject]@{ Time = "19:00"; Mon = ""; Tue = ""; Wed = "귄트 / 무라카"; Thu = ""; Fri = ""; Sat = "귄트 / 무라카"; Sun = "" }
        [pscustomobject]@{ Time = "20:00"; Mon = "산군 / 카란다"; Tue = "불가살 / 크자카"; Wed = "불가살 / 쿠툼"; Thu = "우투리 / 누베르"; Fri = "금돼지왕 / 누베르"; Sat = ""; Sun = "산군 / 크자카" }
        [pscustomobject]@{ Time = "23:15"; Mon = "가모스"; Tue = "가모스"; Wed = "가모스"; Thu = "가모스"; Fri = "가모스"; Sat = ""; Sun = "가모스" }
        [pscustomobject]@{ Time = "23:30"; Mon = "불가살 / 오핀"; Tue = "우투리 / 카란다"; Wed = "우투리 / 크자카"; Thu = "금돼지왕 / 쿠툼"; Fri = "산군 / 오핀"; Sat = ""; Sun = "금돼지왕 / 누베르" }
    )
}

function Get-CustomBossScheduleEntries {
    foreach ($row in @(Normalize-BossRows $script:BossRows)) {
        if (-not [bool]$row.Alert -or [string]::IsNullOrWhiteSpace($row.Name) -or @($row.Days).Count -eq 0) {
            continue
        }

        foreach ($day in @($row.Days)) {
            foreach ($time in @($row.DayTimes.PSObject.Properties[$day].Value)) {
                [pscustomobject]@{
                    Time = [string]$time
                    DayKey = [string]$day
                    Name = [string]$row.Name
                    Priority = [int]$row.Priority
                    Highlight = [bool]$row.Highlight
                    Alert = [bool]$row.Alert
                }
            }
        }
    }
}

function Get-BossNameForDay {
    param(
        [object]$Entry,
        [System.DayOfWeek]$DayOfWeek
    )

    switch ($DayOfWeek) {
        "Monday" { return $Entry.Mon }
        "Tuesday" { return $Entry.Tue }
        "Wednesday" { return $Entry.Wed }
        "Thursday" { return $Entry.Thu }
        "Friday" { return $Entry.Fri }
        "Saturday" { return $Entry.Sat }
        default { return $Entry.Sun }
    }
}

function Get-BossScheduleEventsForDay {
    param([System.DayOfWeek]$DayOfWeek)

    $dayKey = Get-BossDayKey $DayOfWeek
    foreach ($entry in (Get-BossSchedule)) {
        $bossName = Get-BossNameForDay $entry $DayOfWeek
        if ([string]::IsNullOrWhiteSpace($bossName)) {
            continue
        }

        [pscustomobject]@{
            Time = [string]$entry.Time
            Name = [string]$bossName
            Priority = 10
            Highlight = $false
            Alert = $true
        }
    }

    foreach ($entry in (Get-CustomBossScheduleEntries | Where-Object { $_.DayKey -eq $dayKey })) {
        [pscustomobject]@{
            Time = [string]$entry.Time
            Name = [string]$entry.Name
            Priority = [int]$entry.Priority
            Highlight = [bool]$entry.Highlight
            Alert = [bool]$entry.Alert
        }
    }
}

function Format-BossAlertDuration {
    param([int]$TotalSeconds)

    $TotalSeconds = [Math]::Max(0, $TotalSeconds)
    if ($TotalSeconds -gt 3600) {
        $hours = [Math]::Floor(($TotalSeconds / 3600.0) * 10) / 10
        return "{0}시간" -f $hours.ToString("0.0", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    $hours = [int][Math]::Floor($TotalSeconds / 3600)
    $minutes = [int][Math]::Floor(($TotalSeconds % 3600) / 60)
    $seconds = [int]($TotalSeconds % 60)

    if ($hours -gt 0) {
        if ($minutes -gt 0) {
            return "{0}시간 {1}분" -f $hours, $minutes
        }
        if ($seconds -gt 0) {
            return "{0}시간 {1}초" -f $hours, $seconds
        }
        return "{0}시간" -f $hours
    }

    if ($minutes -gt 0) {
        if ($seconds -gt 0) {
            return "{0}분 {1}초" -f $minutes, $seconds
        }
        return "{0}분" -f $minutes
    }

    "{0}초" -f $seconds
}

function Get-BossAlertItems {
    param([datetime]$Now = (Get-Date))

    $beforeSeconds = [int][Math]::Max(0, $script:BossAlertBeforeSeconds)
    $afterSeconds = [int][Math]::Max(0, $script:BossAlertAfterSeconds)
    $events = @()
    foreach ($dayOffset in -1..7) {
        $targetDate = $Now.Date.AddDays($dayOffset)
        foreach ($entry in (Get-BossScheduleEventsForDay $targetDate.DayOfWeek)) {
            $parts = $entry.Time.Split(":")
            $eventTime = $targetDate.AddHours([int]$parts[0]).AddMinutes([int]$parts[1])
            $deltaSeconds = [int][Math]::Ceiling(($eventTime - $Now).TotalSeconds)
            if ($deltaSeconds -ge 0 -and $deltaSeconds -le $beforeSeconds) {
                $events += [pscustomobject]@{
                    Time = $eventTime
                    Priority = [int]$entry.Priority
                    Highlight = [bool]$entry.Highlight
                    Name = [string]$entry.Name
                    State = "before"
                    DeltaSeconds = $deltaSeconds
                }
            }
            elseif ($deltaSeconds -lt 0 -and ([Math]::Abs($deltaSeconds) -le $afterSeconds)) {
                $events += [pscustomobject]@{
                    Time = $eventTime
                    Priority = [int]$entry.Priority
                    Highlight = [bool]$entry.Highlight
                    Name = [string]$entry.Name
                    State = "now"
                    DeltaSeconds = $deltaSeconds
                }
            }
        }
    }

    $grouped = @()
    foreach ($group in ($events | Group-Object { "{0:O}|{1}" -f $_.Time, $_.State })) {
        $items = @($group.Group | Sort-Object Priority, Name)
        if ($items.Count -eq 0) {
            continue
        }

        $bossNames = @($items | ForEach-Object { $_.Name }) -join " / "
        $first = $items[0]
        $text = if ($first.State -eq "before") {
            "[{0}] 등장 {1} 전" -f $bossNames, (Format-BossAlertDuration ([int]$first.DeltaSeconds))
        }
        else {
            "[{0}] 등장" -f $bossNames
        }
        $grouped += [pscustomobject]@{
            Time = $first.Time
            Priority = [int]$first.Priority
            Highlight = [bool](@($items | Where-Object { $_.Highlight }).Count -gt 0)
            BossParts = @($items | ForEach-Object { [pscustomobject]@{ Name = [string]$_.Name; Highlight = [bool]$_.Highlight } })
            Key = "{0:O}|{1}|{2}" -f $first.Time, $first.State, (@($items | ForEach-Object { "{0}:{1}" -f $_.Name, ([bool]$_.Highlight) }) -join "/")
            Text = $text
        }
    }

    $grouped |
        Sort-Object Time, Priority, Text |
        Select-Object -First 2 |
        ForEach-Object { $_ }
}

function Get-BossAlertLines {
    param([datetime]$Now = (Get-Date))

    Get-BossAlertItems $Now | ForEach-Object { $_.Text }
}

function Update-ClockText {
    if ($script:TextBlock) {
        $text = Get-ClockText
        if ($script:OutlineTextBlocks) {
            foreach ($item in $script:OutlineTextBlocks) {
                $item.Block.Text = $text
            }
        }
        $script:TextBlock.Text = $text
    }

    if ($script:BdoTimeTextBlock) {
        $bdoText = Get-BdoGameTimeText
        if ($script:BdoOutlineTextBlocks) {
            foreach ($item in $script:BdoOutlineTextBlocks) {
                $item.Block.Text = $bdoText
            }
        }
        $script:BdoTimeTextBlock.Text = $bdoText
    }
    if ($script:BdoTransitionTextBlock) {
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled) {
            $script:BdoTransitionTextBlock.Text = Get-BdoTransitionText
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BdoTransitionTextBlock.Text = ""
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }

    if ($script:BossAlertPanel) {
        if (-not $script:BossAlertEnabled) {
            $script:BossAlertPanel.Children.Clear()
            $script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $bossAlerts = @(Get-BossAlertItems)
        if ($bossAlerts.Count -gt 0) {
            $previousText = @($script:BossAlertPanel.Children | ForEach-Object {
                if ($_ -is [System.Windows.Controls.Border]) {
                    $_.Uid
                }
            }) -join [Environment]::NewLine
            $nextText = @($bossAlerts | ForEach-Object { $_.Key }) -join [Environment]::NewLine
            if ($previousText -ne $nextText) {
                $script:BossAlertPanel.Children.Clear()
                foreach ($alert in $bossAlerts) {
                    $script:BossAlertPanel.Children.Add((New-BossAlertDisplayItem $alert.Text $alert.BossParts $alert.Key)) | Out-Null
                }
            }
            else {
                for ($i = 0; $i -lt $bossAlerts.Count; $i++) {
                    Update-BossAlertDisplayItemText $script:BossAlertPanel.Children[$i] $bossAlerts[$i].Text
                }
            }
            $script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BossAlertPanel.Children.Clear()
            $script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
    elseif ($script:BossAlertTextBlock) {
        if (-not $script:BossAlertEnabled) {
            $script:BossAlertTextBlock.Text = ""
            $script:BossAlertTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $bossAlerts = @(Get-BossAlertLines)
        if ($bossAlerts.Count -gt 0) {
            $script:BossAlertTextBlock.Text = ($bossAlerts -join [Environment]::NewLine)
            $script:BossAlertTextBlock.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BossAlertTextBlock.Text = ""
            $script:BossAlertTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
}

function Apply-WidgetSize {
    Apply-ClockTextStyle
    Apply-BdoTimeStyle
    Update-SettingsPreview
}

function Set-WidgetFontSize {
    param([int]$Value)

    if (Set-SettingsDraftValue "FontSize" ([Math]::Max(12, [Math]::Min(96, $Value))) ) {
        return
    }

    $script:FontSize = [Math]::Max(12, [Math]::Min(96, $Value))
    Apply-WidgetSize
    if ($script:FontSizeSlider) {
        $script:FontSizeSlider.Value = [double]$script:FontSize
    }
    if ($script:FontSizeValueText) {
        $script:FontSizeValueText.Text = [string]$script:FontSize
    }
    Save-WidgetConfig
}

function Set-BackgroundOpacity {
    param([double]$Value)

    if (Set-SettingsDraftValue "BackgroundOpacity" ([Math]::Max(0.0, [Math]::Min(1.0, $Value))) ) {
        return
    }

    $script:BackgroundOpacity = [Math]::Max(0.0, [Math]::Min(1.0, $Value))
    $script:BackgroundLayer.Opacity = $script:BackgroundOpacity
    if ($script:BackgroundOpacityValueText) {
        $script:BackgroundOpacityValueText.Text = [string]([int][Math]::Round($script:BackgroundOpacity * 100))
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BackgroundColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BackgroundColor" $Value) {
        return
    }

    $script:BackgroundColor = $Value
    $script:BackgroundLayer.Fill = Get-BackgroundBrush $script:BackgroundOpacity
    if ($script:BackgroundColorText) {
        $script:BackgroundColorText.Text = $script:BackgroundColor
    }
    Set-ColorSwatch $script:BackgroundColorSwatch $script:BackgroundColor
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-TextColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "TextColor" $Value) {
        return
    }

    $script:TextColor = $Value
    Apply-ClockTextStyle
    if ($script:TextColorText) {
        $script:TextColorText.Text = $script:TextColor
    }
    Set-ColorSwatch $script:TextColorSwatch $script:TextColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-TextOutlineColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "TextOutlineColor" $Value) {
        return
    }

    $script:TextOutlineColor = $Value
    Apply-ClockTextStyle
    if ($script:TextOutlineColorText) {
        $script:TextOutlineColorText.Text = $script:TextOutlineColor
    }
    Set-ColorSwatch $script:TextOutlineColorSwatch $script:TextOutlineColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ColorTransparency {
    param(
        [string]$Name,
        [bool]$Value
    )

    if (Set-SettingsDraftValue $Name $Value) {
        return
    }

    Set-Variable -Scope Script -Name $Name -Value $Value
    switch ($Name) {
        { $_ -in @("TextColorTransparent", "TextOutlineColorTransparent") } {
            Apply-ClockTextStyle
        }
        { $_ -in @("BdoTextColorTransparent", "BdoTextOutlineColorTransparent", "BdoTransitionTextColorTransparent", "BdoTransitionTextOutlineColorTransparent") } {
            Apply-BdoTimeStyle
        }
        { $_ -in @("BossTextColorTransparent", "BossTextOutlineColorTransparent") } {
            Apply-BossAlertStyle
        }
    }
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-FontFamily {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (Set-SettingsDraftValue "FontFamily" $Value) {
        return
    }

    $script:FontFamily = $Value
    Apply-WidgetSize
    if ($script:FontFamilyText) {
        Set-FontValueText $script:FontFamilyText $script:FontFamily
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-TimeFormat {
    param([string]$Value)

    $nextValue = if ($Value -ne "12") { "24" } else { "12" }
    if (Set-SettingsDraftValue "TimeFormat" $nextValue) {
        return
    }

    if ($Value -ne "12") {
        $script:TimeFormat = "24"
    }
    else {
        $script:TimeFormat = "12"
    }

    if ($script:MeridiemLanguagePanel) {
        if ($script:TimeFormat -eq "12") {
            $script:MeridiemLanguagePanel.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:MeridiemLanguagePanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }

    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-MeridiemLanguage {
    param([string]$Value)

    $nextValue = if ($Value -eq "ko") { "ko" } else { "en" }
    if (Set-SettingsDraftValue "MeridiemLanguage" $nextValue) {
        return
    }

    if ($Value -eq "ko") {
        $script:MeridiemLanguage = "ko"
    }
    else {
        $script:MeridiemLanguage = "en"
    }

    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTimeEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "BdoTimeEnabled" $Value) {
        return
    }

    $script:BdoTimeEnabled = $Value
    Apply-BdoTimeStyle
    Set-OptionsGroupVisibility $script:BdoOptionsExpander $script:BdoOptionsPanel $script:BdoTimeEnabled $true
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoIconType {
    param([string]$Value)

    $nextValue = if ($Value -eq "papu") { "papu" } else { "blackSpirit" }
    if (Set-SettingsDraftValue "BdoIconType" $nextValue) {
        return
    }

    if ($Value -eq "papu") {
        $script:BdoIconType = "papu"
    }
    else {
        $script:BdoIconType = "blackSpirit"
    }

    Update-BdoLogo
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTimeFormat {
    param([string]$Value)

    $nextValue = if ($Value -eq "12") { "12" } else { "24" }
    if (Set-SettingsDraftValue "BdoTimeFormat" $nextValue) {
        return
    }

    $script:BdoTimeFormat = $nextValue
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoIconEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "BdoIconEnabled" $Value) {
        return
    }

    $script:BdoIconEnabled = $Value
    Apply-BdoTimeStyle
    if ($script:BdoIconChoicePanel) {
        if ($script:BdoIconEnabled) {
            $script:BdoIconChoicePanel.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BdoIconChoicePanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoFontSize {
    param([int]$Value)

    if (Set-SettingsDraftValue "BdoFontSize" ([Math]::Max(8, [Math]::Min(48, $Value))) ) {
        return
    }

    $script:BdoFontSize = [Math]::Max(8, [Math]::Min(48, $Value))
    Apply-BdoTimeStyle
    if ($script:BdoFontSizeSlider) {
        $script:BdoFontSizeSlider.Value = [double]$script:BdoFontSize
    }
    if ($script:BdoFontSizeValueText) {
        $script:BdoFontSizeValueText.Text = [string]$script:BdoFontSize
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTimeOffsetSeconds {
    param([int]$Value)

    if (Set-SettingsDraftValue "BdoTimeOffsetSeconds" ([Math]::Max(-180, [Math]::Min(180, $Value))) ) {
        return
    }

    $script:BdoTimeOffsetSeconds = [Math]::Max(-180, [Math]::Min(180, $Value))
    if ($script:BdoTimeOffsetTextBox) {
        $script:BdoTimeOffsetTextBox.Text = [string]$script:BdoTimeOffsetSeconds
    }
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Apply-BdoTimeOffsetInput {
    if (-not $script:BdoTimeOffsetTextBox) {
        return
    }

    [int]$value = 0
    if ([int]::TryParse($script:BdoTimeOffsetTextBox.Text, [ref]$value)) {
        Set-BdoTimeOffsetSeconds $value
    }
    else {
        $script:BdoTimeOffsetTextBox.Text = [string]$script:BdoTimeOffsetSeconds
    }
}

function Set-BdoTextColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BdoTextColor" $Value) {
        return
    }

    $script:BdoTextColor = $Value
    Apply-BdoTimeStyle
    if ($script:BdoTextColorText) {
        $script:BdoTextColorText.Text = $script:BdoTextColor
    }
    Set-ColorSwatch $script:BdoTextColorSwatch $script:BdoTextColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTextOutlineColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BdoTextOutlineColor" $Value) {
        return
    }

    $script:BdoTextOutlineColor = $Value
    Apply-BdoTimeStyle
    if ($script:BdoTextOutlineColorText) {
        $script:BdoTextOutlineColorText.Text = $script:BdoTextOutlineColor
    }
    Set-ColorSwatch $script:BdoTextOutlineColorSwatch $script:BdoTextOutlineColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoFontFamily {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (Set-SettingsDraftValue "BdoFontFamily" $Value) {
        return
    }

    $script:BdoFontFamily = $Value
    Apply-BdoTimeStyle
    if ($script:BdoFontFamilyText) {
        Set-FontValueText $script:BdoFontFamilyText $script:BdoFontFamily
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTransitionEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "BdoTransitionEnabled" $Value) {
        return
    }

    $script:BdoTransitionEnabled = $Value
    if ($script:BdoTransitionOptionsPanel) {
        $script:BdoTransitionOptionsPanel.Visibility = if ($script:BdoTransitionEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    }
    Apply-BdoTimeStyle
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTransitionFontSize {
    param([int]$Value)

    $nextValue = [Math]::Max(8, [Math]::Min(48, $Value))
    if (Set-SettingsDraftValue "BdoTransitionFontSize" $nextValue) {
        return
    }

    $script:BdoTransitionFontSize = $nextValue
    Apply-BdoTimeStyle
    if ($script:BdoTransitionFontSizeSlider) {
        $script:BdoTransitionFontSizeSlider.Value = [double]$script:BdoTransitionFontSize
    }
    if ($script:BdoTransitionFontSizeValueText) {
        $script:BdoTransitionFontSizeValueText.Text = [string]$script:BdoTransitionFontSize
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTransitionTextColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BdoTransitionTextColor" $Value) {
        return
    }

    $script:BdoTransitionTextColor = $Value
    Apply-BdoTimeStyle
    if ($script:BdoTransitionTextColorText) {
        $script:BdoTransitionTextColorText.Text = $script:BdoTransitionTextColor
    }
    Set-ColorSwatch $script:BdoTransitionTextColorSwatch $script:BdoTransitionTextColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTransitionTextOutlineColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BdoTransitionTextOutlineColor" $Value) {
        return
    }

    $script:BdoTransitionTextOutlineColor = $Value
    Apply-BdoTimeStyle
    if ($script:BdoTransitionTextOutlineColorText) {
        $script:BdoTransitionTextOutlineColorText.Text = $script:BdoTransitionTextOutlineColor
    }
    Set-ColorSwatch $script:BdoTransitionTextOutlineColorSwatch $script:BdoTransitionTextOutlineColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BdoTransitionFontFamily {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (Set-SettingsDraftValue "BdoTransitionFontFamily" $Value) {
        return
    }

    $script:BdoTransitionFontFamily = $Value
    Apply-BdoTimeStyle
    if ($script:BdoTransitionFontFamilyText) {
        Set-FontValueText $script:BdoTransitionFontFamilyText $script:BdoTransitionFontFamily
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossAlertEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "BossAlertEnabled" $Value) {
        return
    }

    $script:BossAlertEnabled = $Value
    Set-OptionsGroupVisibility $script:BossOptionsExpander $script:BossOptionsPanel $script:BossAlertEnabled $true
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossFontSize {
    param([int]$Value)

    if (Set-SettingsDraftValue "BossFontSize" ([Math]::Max(8, [Math]::Min(48, $Value))) ) {
        return
    }

    $script:BossFontSize = [Math]::Max(8, [Math]::Min(48, $Value))
    Apply-BossAlertStyle
    if ($script:BossFontSizeSlider) {
        $script:BossFontSizeSlider.Value = [double]$script:BossFontSize
    }
    if ($script:BossFontSizeValueText) {
        $script:BossFontSizeValueText.Text = [string]$script:BossFontSize
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossAlertTimeInputControls {
    param(
        [string]$Kind,
        [int]$TotalSeconds
    )

    $TotalSeconds = [Math]::Max(0, $TotalSeconds)
    $minutes = [int][Math]::Floor($TotalSeconds / 60)
    $seconds = [int]($TotalSeconds % 60)
    if ($Kind -eq "After") {
        $minuteBox = $script:BossAfterMinutesTextBox
        $secondBox = $script:BossAfterSecondsTextBox
    }
    else {
        $minuteBox = $script:BossBeforeMinutesTextBox
        $secondBox = $script:BossBeforeSecondsTextBox
    }

    if ($minuteBox) {
        $minuteBox.Text = [string]$minutes
    }
    if ($secondBox) {
        $secondBox.Text = [string]$seconds
    }
}

function Get-BossAlertSecondsFromInput {
    param(
        [System.Windows.Controls.TextBox]$MinuteBox,
        [System.Windows.Controls.TextBox]$SecondBox,
        [int]$MaxSeconds
    )

    [int]$minutes = 0
    [int]$seconds = 0
    if ($MinuteBox) {
        [void][int]::TryParse($MinuteBox.Text, [ref]$minutes)
    }
    if ($SecondBox) {
        [void][int]::TryParse($SecondBox.Text, [ref]$seconds)
    }

    $totalSeconds = ([Math]::Max(0, $minutes) * 60) + [Math]::Max(0, $seconds)
    [int][Math]::Max(0, [Math]::Min($MaxSeconds, $totalSeconds))
}

function Set-BossAlertBeforeSeconds {
    param([int]$Value)

    $nextValue = [int][Math]::Max(0, [Math]::Min(604800, $Value))
    if (Set-SettingsDraftValue "BossAlertBeforeSeconds" $nextValue) {
        return
    }

    $script:BossAlertBeforeSeconds = $nextValue
    Set-BossAlertTimeInputControls "Before" $script:BossAlertBeforeSeconds
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossAlertAfterSeconds {
    param([int]$Value)

    $nextValue = [int][Math]::Max(0, [Math]::Min(86400, $Value))
    if (Set-SettingsDraftValue "BossAlertAfterSeconds" $nextValue) {
        return
    }

    $script:BossAlertAfterSeconds = $nextValue
    Set-BossAlertTimeInputControls "After" $script:BossAlertAfterSeconds
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Apply-BossAlertBeforeInput {
    $value = Get-BossAlertSecondsFromInput $script:BossBeforeMinutesTextBox $script:BossBeforeSecondsTextBox 604800
    Set-BossAlertBeforeSeconds $value
}

function Apply-BossAlertAfterInput {
    $value = Get-BossAlertSecondsFromInput $script:BossAfterMinutesTextBox $script:BossAfterSecondsTextBox 86400
    Set-BossAlertAfterSeconds $value
}

function Set-BossMarginTop {
    param([int]$Value)

    if (Set-SettingsDraftValue "BossMarginTop" ([Math]::Max(0, [Math]::Min(40, $Value))) ) {
        return
    }

    $script:BossMarginTop = [Math]::Max(0, [Math]::Min(40, $Value))
    Apply-BossAlertStyle
    if ($script:BossMarginTopSlider) {
        $script:BossMarginTopSlider.Value = [double]$script:BossMarginTop
    }
    if ($script:BossMarginTopValueText) {
        $script:BossMarginTopValueText.Text = [string]$script:BossMarginTop
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossMarginBottom {
    param([int]$Value)

    if (Set-SettingsDraftValue "BossMarginBottom" ([Math]::Max(0, [Math]::Min(40, $Value))) ) {
        return
    }

    $script:BossMarginBottom = [Math]::Max(0, [Math]::Min(40, $Value))
    Apply-BossAlertStyle
    if ($script:BossMarginBottomSlider) {
        $script:BossMarginBottomSlider.Value = [double]$script:BossMarginBottom
    }
    if ($script:BossMarginBottomValueText) {
        $script:BossMarginBottomValueText.Text = [string]$script:BossMarginBottom
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossTextColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BossTextColor" $Value) {
        return
    }

    $script:BossTextColor = $Value
    Apply-BossAlertStyle
    if ($script:BossTextColorText) {
        $script:BossTextColorText.Text = $script:BossTextColor
    }
    Set-ColorSwatch $script:BossTextColorSwatch $script:BossTextColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossTextOutlineColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BossTextOutlineColor" $Value) {
        return
    }

    $script:BossTextOutlineColor = $Value
    Apply-BossAlertStyle
    if ($script:BossTextOutlineColorText) {
        $script:BossTextOutlineColorText.Text = $script:BossTextOutlineColor
    }
    Set-ColorSwatch $script:BossTextOutlineColorSwatch $script:BossTextOutlineColor
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossHighlightColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BossHighlightColor" $Value) {
        return
    }

    $script:BossHighlightColor = $Value
    if ($script:BossHighlightColorText) {
        $script:BossHighlightColorText.Text = $script:BossHighlightColor
    }
    Set-ColorSwatch $script:BossHighlightColorSwatch $script:BossHighlightColor
    if ($script:BossAlertPanel) {
        $script:BossAlertPanel.Children.Clear()
    }
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossFontFamily {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (Set-SettingsDraftValue "BossFontFamily" $Value) {
        return
    }

    $script:BossFontFamily = $Value
    Apply-BossAlertStyle
    if ($script:BossFontFamilyText) {
        Set-FontValueText $script:BossFontFamilyText $script:BossFontFamily
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Get-EditableBossRows {
    if ($script:SettingsDraft -and $null -ne $script:SettingsDraft.BossRows) {
        return @(Copy-BossRows $script:SettingsDraft.BossRows)
    }
    @(Copy-BossRows $script:BossRows)
}

function Set-BossRows {
    param([object]$Rows)

    $nextRows = @(Copy-BossRows $Rows)
    if (Set-SettingsDraftValue "BossRows" $nextRows) {
        return
    }

    $script:BossRows = @($nextRows)
    Refresh-BossRowsEditor
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BossHighlightAnimationSeconds {
    param([double]$Value)

    $nextValue = [double][Math]::Max(0.2, [Math]::Min(10.0, $Value))
    if (Set-SettingsDraftValue "BossHighlightAnimationSeconds" $nextValue) {
        return
    }

    $script:BossHighlightAnimationSeconds = $nextValue
    if ($script:BossHighlightAnimationTextBox) {
        $script:BossHighlightAnimationTextBox.Text = $script:BossHighlightAnimationSeconds.ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture)
    }
    if ($script:BossAlertPanel) {
        $script:BossAlertPanel.Children.Clear()
    }
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Apply-BossHighlightAnimationInput {
    [double]$seconds = $script:BossHighlightAnimationSeconds
    if ($script:BossHighlightAnimationTextBox) {
        [void][double]::TryParse($script:BossHighlightAnimationTextBox.Text, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$seconds)
    }
    Set-BossHighlightAnimationSeconds $seconds
}

function Get-BossDaysSummary {
    param([object]$Days)

    $labels = @()
    foreach ($definition in Get-BossDayDefinitions) {
        if (@($Days) -contains $definition.Key) {
            $labels += $definition.Label
        }
    }
    if ($labels.Count -eq 0) {
        return "미설정"
    }
    $labels -join ""
}

function Get-BossTimesSummary {
    param([object]$Times)

    $items = @($Times) | ForEach-Object { Normalize-BossTime $_ } | Where-Object { $null -ne $_ } | Sort-Object -Unique
    if ($items.Count -eq 0) {
        return "미설정"
    }
    $items -join ", "
}

function Get-BossRowTimesSummary {
    param([object]$BossRow)

    $parts = @()
    foreach ($definition in Get-BossDayDefinitions) {
        if (@($BossRow.Days) -notcontains $definition.Key) {
            continue
        }

        $times = @($BossRow.DayTimes.PSObject.Properties[$definition.Key].Value) |
            ForEach-Object { Normalize-BossTime $_ } |
            Where-Object { $null -ne $_ } |
            Sort-Object -Unique
        if ($times.Count -gt 0) {
            $parts += ("{0} {1}" -f $definition.Label, ($times -join " / "))
        }
    }

    if ($parts.Count -eq 0) {
        return "미설정"
    }
    $parts -join [Environment]::NewLine
}

function Add-BossRow {
    $rows = @(Get-EditableBossRows)
    $rows += [pscustomobject]@{
        Name = "이벤트 보스"
        Days = @()
        Times = @()
        DayTimes = [pscustomobject]([ordered]@{
            Mon = @()
            Tue = @()
            Wed = @()
            Thu = @()
            Fri = @()
            Sat = @()
            Sun = @()
        })
        Priority = 0
        Highlight = $false
        Alert = $true
    }
    Set-BossRows $rows
}

function Remove-BossRow {
    param([int]$Index)

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $nextRows = @()
    for ($i = 0; $i -lt $rows.Count; $i++) {
        if ($i -ne $Index) {
            $nextRows += $rows[$i]
        }
    }
    Set-BossRows $nextRows
}

function Update-BossRowName {
    param(
        [int]$Index,
        [string]$Name
    )

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $rows[$Index].Name = ([string]$Name).Trim()
    Set-BossRows $rows
}

function Update-BossRowPriority {
    param(
        [int]$Index,
        [string]$Value
    )

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    [int]$priority = 0
    [void][int]::TryParse($Value, [ref]$priority)
    $rows[$Index].Priority = [Math]::Max(0, [Math]::Min(10, $priority))
    Set-BossRows $rows
}

function Update-BossRowAlert {
    param(
        [int]$Index,
        [bool]$Value
    )

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $rows[$Index].Alert = $Value
    Set-BossRows $rows
}

function Update-BossRowHighlight {
    param(
        [int]$Index,
        [bool]$Value
    )

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $rows[$Index].Highlight = $Value
    Set-BossRows $rows
}

function Show-BossDaysDialog {
    param([int]$Index)

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $dialog = New-Object System.Windows.Window
    $dialog.Title = "요일 설정"
    $dialog.Width = 280
    $dialog.Height = 260
    $dialog.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterOwner
    if ($script:SettingsWindow) { $dialog.Owner = $script:SettingsWindow }

    $panel = New-Object System.Windows.Controls.StackPanel
    $panel.Margin = New-Object System.Windows.Thickness 14
    $checks = @{}
    foreach ($definition in Get-BossDayDefinitions) {
        $check = New-Object System.Windows.Controls.CheckBox
        $check.Content = $definition.Label
        $check.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8
        $check.IsChecked = (@($rows[$Index].Days) -contains $definition.Key)
        $checks[$definition.Key] = $check
        $panel.Children.Add($check) | Out-Null
    }

    $buttonPanel = New-Object System.Windows.Controls.StackPanel
    $buttonPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $buttonPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "확인"
    $okButton.Width = 72
    $okButton.Margin = New-Object System.Windows.Thickness 0, 8, 8, 0
    $okButton.Add_Click({
        $nextDays = @()
        foreach ($definition in Get-BossDayDefinitions) {
            if ([bool]$checks[$definition.Key].IsChecked) {
                $nextDays += $definition.Key
            }
        }
        $rows[$Index].Days = @($nextDays)
        Set-BossRows $rows
        $dialog.DialogResult = $true
        $dialog.Close()
    }.GetNewClosure())
    $buttonPanel.Children.Add($okButton) | Out-Null
    $cancelButton = New-Object System.Windows.Controls.Button
    $cancelButton.Content = "취소"
    $cancelButton.Width = 72
    $cancelButton.Margin = New-Object System.Windows.Thickness 0, 8, 0, 0
    $cancelButton.Add_Click({ $dialog.Close() }.GetNewClosure())
    $buttonPanel.Children.Add($cancelButton) | Out-Null
    $panel.Children.Add($buttonPanel) | Out-Null
    $dialog.Content = $panel
    $dialog.ShowDialog() | Out-Null
}

function Show-BossTimesDialog {
    param([int]$Index)

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }
    $selectedDays = @(Get-BossDayDefinitions)

    $dialog = New-Object System.Windows.Window
    $dialog.Title = "시간 설정"
    $dialog.Width = 420
    $dialog.Height = 520
    $dialog.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterOwner
    if ($script:SettingsWindow) { $dialog.Owner = $script:SettingsWindow }

    $root = New-Object System.Windows.Controls.DockPanel
    $root.Margin = New-Object System.Windows.Thickness 14
    $root.LastChildFill = $true

    $dayEditors = @{}
    $contentPanel = New-Object System.Windows.Controls.StackPanel

    if ($selectedDays.Count -eq 0) {
        $notice = New-Object System.Windows.Controls.TextBlock
        $notice.Text = "먼저 요일을 설정해 주세요."
        $notice.Margin = New-Object System.Windows.Thickness 0, 0, 0, 12
        $contentPanel.Children.Add($notice) | Out-Null
    }
    else {
        $addTimeBox = {
            param(
                [string]$DayKey,
                [System.Windows.Controls.StackPanel]$TargetPanel,
                [string]$Value
            )

            $parts = Split-BossTimeParts $Value
            $rowPanel = New-Object System.Windows.Controls.StackPanel
            $rowPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
            $rowPanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

            $hourBox = New-Object System.Windows.Controls.TextBox
            $hourBox.Width = 44
            $hourBox.MaxLength = 2
            $hourBox.Text = $parts.Hour
            $hourBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
            $rowPanel.Children.Add($hourBox) | Out-Null

            $hourLabel = New-Object System.Windows.Controls.TextBlock
            $hourLabel.Text = " 시 "
            $hourLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $rowPanel.Children.Add($hourLabel) | Out-Null

            $minuteBox = New-Object System.Windows.Controls.TextBox
            $minuteBox.Width = 44
            $minuteBox.MaxLength = 2
            $minuteBox.Text = $parts.Minute
            $minuteBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
            $rowPanel.Children.Add($minuteBox) | Out-Null

            $minuteLabel = New-Object System.Windows.Controls.TextBlock
            $minuteLabel.Text = " 분"
            $minuteLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $rowPanel.Children.Add($minuteLabel) | Out-Null

            $entry = [pscustomobject]@{
                HourBox = $hourBox
                MinuteBox = $minuteBox
            }

            $remove = New-Object System.Windows.Controls.Button
            $remove.Content = "-"
            $remove.Width = 28
            $remove.Margin = New-Object System.Windows.Thickness 8, 0, 0, 0
            $remove.Tag = [pscustomobject]@{
                Row = $rowPanel
                Entry = $entry
                List = $dayEditors[$DayKey]
                Panel = $TargetPanel
            }
            $remove.Add_Click({
                param($sender, $eventArgs)
                $sender.Tag.Panel.Children.Remove($sender.Tag.Row) | Out-Null
                $sender.Tag.List.Remove($sender.Tag.Entry) | Out-Null
            })
            $rowPanel.Children.Add($remove) | Out-Null

            $TargetPanel.Children.Add($rowPanel) | Out-Null
            $dayEditors[$DayKey].Add($entry) | Out-Null
        }.GetNewClosure()

        foreach ($definition in $selectedDays) {
            $dayBlock = New-Object System.Windows.Controls.Border
            $dayBlock.BorderThickness = New-Object System.Windows.Thickness 0, 0, 0, 1
            $dayBlock.BorderBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(210, 210, 210))
            $dayBlock.Margin = New-Object System.Windows.Thickness 0, 0, 0, 12
            $dayBlock.Padding = New-Object System.Windows.Thickness 0, 0, 0, 10

            $dayPanel = New-Object System.Windows.Controls.StackPanel
            $title = New-Object System.Windows.Controls.TextBlock
            $title.Text = "$($definition.Label)요일"
            $title.FontWeight = [System.Windows.FontWeights]::Bold
            $title.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8
            $dayPanel.Children.Add($title) | Out-Null

            $timeListPanel = New-Object System.Windows.Controls.StackPanel
            $dayEditors[$definition.Key] = New-Object System.Collections.ArrayList
            foreach ($time in @($rows[$Index].DayTimes.PSObject.Properties[$definition.Key].Value)) {
                & $addTimeBox $definition.Key $timeListPanel $time
            }
            $dayPanel.Children.Add($timeListPanel) | Out-Null

            $addButton = New-Object System.Windows.Controls.Button
            $addButton.Content = "+"
            $addButton.Width = 34
            $addButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
            $addButton.Tag = [pscustomobject]@{
                DayKey = $definition.Key
                Panel = $timeListPanel
                AddHandler = $addTimeBox
            }
            $addButton.Add_Click({
                param($sender, $eventArgs)
                & $sender.Tag.AddHandler $sender.Tag.DayKey $sender.Tag.Panel "12:00"
            })
            $dayPanel.Children.Add($addButton) | Out-Null

            $dayBlock.Child = $dayPanel
            $contentPanel.Children.Add($dayBlock) | Out-Null
        }
    }

    $scroll = New-Object System.Windows.Controls.ScrollViewer
    $scroll.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
    $scroll.Content = $contentPanel

    $buttonPanel = New-Object System.Windows.Controls.StackPanel
    $buttonPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $buttonPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    [System.Windows.Controls.DockPanel]::SetDock($buttonPanel, [System.Windows.Controls.Dock]::Bottom)
    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "확인"
    $okButton.Width = 72
    $okButton.Margin = New-Object System.Windows.Thickness 0, 8, 8, 0
    $okButton.Add_Click({
        $nextDayTimes = [ordered]@{}
        foreach ($definition in Get-BossDayDefinitions) {
            if ($dayEditors.ContainsKey($definition.Key)) {
                $times = @()
                foreach ($entry in @($dayEditors[$definition.Key])) {
                    $hourText = ([string]$entry.HourBox.Text).Trim()
                    $minuteText = ([string]$entry.MinuteBox.Text).Trim()
                    [int]$hour = 0
                    [int]$minute = 0

                    if ($hourText -notmatch '^\d{1,2}$' -or -not [int]::TryParse($hourText, [ref]$hour) -or $hour -lt 0 -or $hour -gt 23) {
                        [System.Windows.MessageBox]::Show(
                            "$($definition.Label)요일의 시는 0부터 23까지 숫자 1~2자리로 입력해 주세요.",
                            "시간 입력 오류",
                            [System.Windows.MessageBoxButton]::OK,
                            [System.Windows.MessageBoxImage]::Warning
                        ) | Out-Null
                        $entry.HourBox.Focus() | Out-Null
                        $entry.HourBox.SelectAll()
                        return
                    }

                    if ($minuteText -notmatch '^\d{1,2}$' -or -not [int]::TryParse($minuteText, [ref]$minute) -or $minute -lt 0 -or $minute -gt 59) {
                        [System.Windows.MessageBox]::Show(
                            "$($definition.Label)요일의 분은 0부터 59까지 숫자 1~2자리로 입력해 주세요.",
                            "시간 입력 오류",
                            [System.Windows.MessageBoxButton]::OK,
                            [System.Windows.MessageBoxImage]::Warning
                        ) | Out-Null
                        $entry.MinuteBox.Focus() | Out-Null
                        $entry.MinuteBox.SelectAll()
                        return
                    }

                    $times += ("{0:00}:{1:00}" -f $hour, $minute)
                }

                $nextDayTimes[$definition.Key] = @($times | Sort-Object -Unique)
            }
            else {
                $nextDayTimes[$definition.Key] = @($rows[$Index].DayTimes.PSObject.Properties[$definition.Key].Value)
            }
        }
        $rows[$Index].DayTimes = [pscustomobject]$nextDayTimes
        $rows[$Index].Times = @($nextDayTimes.Values | ForEach-Object { $_ } | Sort-Object -Unique)
        $rows[$Index].Days = @((Get-BossDayDefinitions) | Where-Object { @($nextDayTimes[$_.Key]).Count -gt 0 } | ForEach-Object { $_.Key })
        Set-BossRows $rows
        $dialog.DialogResult = $true
        $dialog.Close()
    }.GetNewClosure())
    $buttonPanel.Children.Add($okButton) | Out-Null
    $cancelButton = New-Object System.Windows.Controls.Button
    $cancelButton.Content = "취소"
    $cancelButton.Width = 72
    $cancelButton.Margin = New-Object System.Windows.Thickness 0, 8, 0, 0
    $cancelButton.Add_Click({ $dialog.Close() }.GetNewClosure())
    $buttonPanel.Children.Add($cancelButton) | Out-Null
    $root.Children.Add($buttonPanel) | Out-Null
    $root.Children.Add($scroll) | Out-Null

    $dialog.Content = $root
    $dialog.ShowDialog() | Out-Null
}

function Update-SettingsPreview {
    if ($script:SettingsDraft -and -not $script:PreviewUsesDraftSnapshot) {
        Invoke-WithSettingsSnapshot $script:SettingsDraft {
            $script:PreviewUsesDraftSnapshot = $true
            try {
                Update-SettingsPreview
            }
            finally {
                $script:PreviewUsesDraftSnapshot = $false
            }
        }
        return
    }

    $previewTime = Get-ClockText ([datetime]"2026-01-01 13:34:56")

    if ($script:ColorPreviewBackground) {
        $script:ColorPreviewBackground.Background = Get-PreviewBackgroundBrush $script:BackgroundOpacity
        $script:ColorPreviewBackground.Opacity = 1.0
    }
    if ($script:ColorPreviewText) {
        $script:ColorPreviewText.Foreground = Get-TextBrush
        $script:ColorPreviewText.FontFamily = New-Object System.Windows.Media.FontFamily $script:FontFamily
        $script:ColorPreviewText.Text = $previewTime
        $script:ColorPreviewText.FontSize = [double][Math]::Max(16, [Math]::Min(42, $script:FontSize))
        $script:ColorPreviewText.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
            Color = (ConvertTo-WpfColor $script:TextOutlineColor "#000000")
            BlurRadius = 0
            ShadowDepth = 1
            Opacity = (Get-OutlineEffectOpacity $script:TextOutlineColorTransparent)
        }
    }

    if ($script:BdoPreviewPanel) {
        if ($script:BdoTimeEnabled) {
            $script:BdoPreviewPanel.Visibility = [System.Windows.Visibility]::Visible
        }
        else {
            $script:BdoPreviewPanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
    if ($script:BdoPreviewImage) {
        if ($script:BdoTimeEnabled -and $script:BdoIconEnabled) {
            $script:BdoPreviewImage.Visibility = [System.Windows.Visibility]::Visible
            $script:BdoPreviewImage.Source = New-WpfImageSource (Get-BdoLogoPath)
        }
        else {
            $script:BdoPreviewImage.Visibility = [System.Windows.Visibility]::Collapsed
            $script:BdoPreviewImage.Source = $null
        }
    }
    if ($script:BdoPreviewText) {
        $script:BdoPreviewText.Text = Get-BdoGameTimeText
        $script:BdoPreviewText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BdoFontFamily
        $script:BdoPreviewText.FontSize = [double][Math]::Max(10, [Math]::Min(32, $script:BdoFontSize))
        $script:BdoPreviewText.Foreground = Get-BdoTextBrush
        $script:BdoPreviewText.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
            Color = (ConvertTo-WpfColor $script:BdoTextOutlineColor "#000000")
            BlurRadius = 0
            ShadowDepth = 1
            Opacity = (Get-OutlineEffectOpacity $script:BdoTextOutlineColorTransparent)
        }
    }
    if ($script:BdoTransitionPreviewText) {
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled) {
            $script:BdoTransitionPreviewText.Visibility = [System.Windows.Visibility]::Visible
            $script:BdoTransitionPreviewText.Text = Get-BdoTransitionText
            $script:BdoTransitionPreviewText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BdoTransitionFontFamily
            $script:BdoTransitionPreviewText.FontSize = [double][Math]::Max(9, [Math]::Min(28, $script:BdoTransitionFontSize))
            $script:BdoTransitionPreviewText.Foreground = Get-BdoTransitionTextBrush
            $script:BdoTransitionPreviewText.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
                Color = (ConvertTo-WpfColor $script:BdoTransitionTextOutlineColor "#000000")
                BlurRadius = 0
                ShadowDepth = 1
                Opacity = (Get-OutlineEffectOpacity $script:BdoTransitionTextOutlineColorTransparent)
            }
        }
        else {
            $script:BdoTransitionPreviewText.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
    if ($script:BossPreviewText) {
        if ($script:BossAlertEnabled) {
            $previewRow = @(Normalize-BossRows $script:BossRows |
                Where-Object { [bool]$_.Alert -and -not [string]::IsNullOrWhiteSpace($_.Name) } |
                Sort-Object Priority, Name |
                Select-Object -First 1)
            if ($previewRow.Count -gt 0) {
                $previewName = [string]$previewRow[0].Name
                $previewHighlighted = [bool]$previewRow[0].Highlight
            }
            else {
                $previewName = "가모스"
                $previewHighlighted = $false
            }
            if ($script:BossPreviewBorder) {
                $script:BossPreviewBorder.Visibility = [System.Windows.Visibility]::Visible
                $script:BossPreviewBorder.Margin = New-Object System.Windows.Thickness 0, $script:BossMarginTop, 0, $script:BossMarginBottom
                if ($script:BossPreviewBorder.Background -is [System.Windows.Media.Brush]) {
                    $script:BossPreviewBorder.Background.BeginAnimation([System.Windows.Media.Brush]::OpacityProperty, $null)
                }
                $script:BossPreviewBorder.Background = [System.Windows.Media.Brushes]::Transparent
            }
            $script:BossPreviewText.Visibility = [System.Windows.Visibility]::Visible
            $script:BossPreviewText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
            $script:BossPreviewText.FontSize = [double][Math]::Max(10, [Math]::Min(32, $script:BossFontSize))
            $script:BossPreviewText.Foreground = Get-BossTextBrush
            $script:BossPreviewText.Margin = New-Object System.Windows.Thickness 0
            $script:BossPreviewText.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
                Color = (ConvertTo-WpfColor $script:BossTextOutlineColor "#000000")
                BlurRadius = 0
                ShadowDepth = 1
                Opacity = (Get-OutlineEffectOpacity $script:BossTextOutlineColorTransparent)
            }
            $script:BossPreviewText.Inlines.Clear()
            $script:BossPreviewText.Inlines.Add((New-Object System.Windows.Documents.Run "[")) | Out-Null
            if ($previewHighlighted) {
                $nameBorder = New-Object System.Windows.Controls.Border
                $nameBorder.CornerRadius = New-Object System.Windows.CornerRadius 3
                $nameBorder.Padding = New-Object System.Windows.Thickness 2, 1, 2, 1
                $nameBorder.ClipToBounds = $true
                $nameGrid = New-Object System.Windows.Controls.Grid
                $fill = New-Object System.Windows.Shapes.Rectangle
                $fill.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
                $fill.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
                $fill.RadiusX = 3
                $fill.RadiusY = 3
                $fill.IsHitTestVisible = $false
                $nameGrid.Children.Add($fill) | Out-Null
                $nameText = New-Object System.Windows.Controls.TextBlock
                $nameText.Text = $previewName
                $nameText.FontWeight = [System.Windows.FontWeights]::Bold
                $nameText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
                $nameText.FontSize = [double][Math]::Max(10, [Math]::Min(32, $script:BossFontSize))
                $nameText.Foreground = Get-BossTextBrush
                $nameText.LineHeight = [double]([Math]::Max(10, [Math]::Min(32, $script:BossFontSize)) * 1.2)
                $nameText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
                $nameGrid.Children.Add($nameText) | Out-Null
                $nameBorder.Child = $nameGrid
                Start-BossHighlightAnimation $nameBorder $fill
                $script:BossPreviewText.Inlines.Add((New-Object System.Windows.Documents.InlineUIContainer $nameBorder)) | Out-Null
            }
            else {
                $script:BossPreviewText.Inlines.Add((New-Object System.Windows.Documents.Run $previewName)) | Out-Null
            }
            $script:BossPreviewText.Inlines.Add((New-Object System.Windows.Documents.Run "] 등장 45분 전")) | Out-Null
        }
        else {
            $script:BossPreviewText.Visibility = [System.Windows.Visibility]::Collapsed
            if ($script:BossPreviewBorder) {
                $script:BossPreviewBorder.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
    }
}

function Request-SettingsPreviewUpdate {
    if (-not $script:ColorPreviewBackground -and -not $script:ColorPreviewText -and -not $script:BossPreviewText -and -not $script:BdoPreviewText) {
        return
    }

    Update-SettingsPreview
    if ($script:SettingsWindow -and $script:SettingsWindow.Dispatcher) {
        $action = [System.Action]{ Update-SettingsPreview }
        $script:SettingsWindow.Dispatcher.BeginInvoke($action, [System.Windows.Threading.DispatcherPriority]::Background) | Out-Null
    }
}

function Apply-PendingSettingsInputs {
    if (-not $script:SettingsDraft -or $script:SyncingSettingsControls) {
        return
    }

    $bdoOffsetText = if ($script:BdoTimeOffsetTextBox) { [string]$script:BdoTimeOffsetTextBox.Text } else { $null }
    $bossBeforeMinutesText = if ($script:BossBeforeMinutesTextBox) { [string]$script:BossBeforeMinutesTextBox.Text } else { $null }
    $bossBeforeSecondsText = if ($script:BossBeforeSecondsTextBox) { [string]$script:BossBeforeSecondsTextBox.Text } else { $null }
    $bossAfterMinutesText = if ($script:BossAfterMinutesTextBox) { [string]$script:BossAfterMinutesTextBox.Text } else { $null }
    $bossAfterSecondsText = if ($script:BossAfterSecondsTextBox) { [string]$script:BossAfterSecondsTextBox.Text } else { $null }
    $bossHighlightAnimationText = if ($script:BossHighlightAnimationTextBox) { [string]$script:BossHighlightAnimationTextBox.Text } else { $null }

    $colorInputs = @(
        [pscustomobject]@{ Name = "BackgroundColor"; Value = if ($script:BackgroundColorText) { [string]$script:BackgroundColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "TextColor"; Value = if ($script:TextColorText) { [string]$script:TextColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "TextOutlineColor"; Value = if ($script:TextOutlineColorText) { [string]$script:TextOutlineColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BdoTextColor"; Value = if ($script:BdoTextColorText) { [string]$script:BdoTextColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BdoTextOutlineColor"; Value = if ($script:BdoTextOutlineColorText) { [string]$script:BdoTextOutlineColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BdoTransitionTextColor"; Value = if ($script:BdoTransitionTextColorText) { [string]$script:BdoTransitionTextColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BdoTransitionTextOutlineColor"; Value = if ($script:BdoTransitionTextOutlineColorText) { [string]$script:BdoTransitionTextOutlineColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BossTextColor"; Value = if ($script:BossTextColorText) { [string]$script:BossTextColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BossTextOutlineColor"; Value = if ($script:BossTextOutlineColorText) { [string]$script:BossTextOutlineColorText.Text } else { $null } },
        [pscustomobject]@{ Name = "BossHighlightColor"; Value = if ($script:BossHighlightColorText) { [string]$script:BossHighlightColorText.Text } else { $null } }
    )

    if ($null -ne $bdoOffsetText) {
        [int]$bdoOffset = $script:BdoTimeOffsetSeconds
        [void][int]::TryParse($bdoOffsetText, [ref]$bdoOffset)
        Set-BdoTimeOffsetSeconds $bdoOffset
    }
    if ($null -ne $bossBeforeMinutesText -or $null -ne $bossBeforeSecondsText) {
        [int]$minutes = 0
        [int]$seconds = 0
        [void][int]::TryParse($bossBeforeMinutesText, [ref]$minutes)
        [void][int]::TryParse($bossBeforeSecondsText, [ref]$seconds)
        Set-BossAlertBeforeSeconds (([Math]::Max(0, $minutes) * 60) + [Math]::Max(0, $seconds))
    }
    if ($null -ne $bossAfterMinutesText -or $null -ne $bossAfterSecondsText) {
        [int]$minutes = 0
        [int]$seconds = 0
        [void][int]::TryParse($bossAfterMinutesText, [ref]$minutes)
        [void][int]::TryParse($bossAfterSecondsText, [ref]$seconds)
        Set-BossAlertAfterSeconds (([Math]::Max(0, $minutes) * 60) + [Math]::Max(0, $seconds))
    }
    if ($null -ne $bossHighlightAnimationText) {
        [double]$seconds = $script:BossHighlightAnimationSeconds
        [void][double]::TryParse($bossHighlightAnimationText, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$seconds)
        Set-BossHighlightAnimationSeconds $seconds
    }

    foreach ($item in $colorInputs) {
        if ($null -ne $item.Value) {
            Set-ColorSettingByName ([string]$item.Name) ([string]$item.Value)
        }
    }

    Request-SettingsPreviewUpdate
}

function Show-BackgroundColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BackgroundColor" $script:BackgroundColor) "#111111"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BackgroundColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-TextColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "TextColor" $script:TextColor) "#FFFFFF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-TextColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-TextOutlineColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "TextOutlineColor" $script:TextOutlineColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-TextOutlineColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BdoTextColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BdoTextColor" $script:BdoTextColor) "#FF66FF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoTextColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BdoTextOutlineColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BdoTextOutlineColor" $script:BdoTextOutlineColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoTextOutlineColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BdoFontDialog {
    $dialog = New-Object System.Windows.Forms.FontDialog
    $dialog.ShowColor = $false
    $dialog.ShowEffects = $false
    $dialog.FontMustExist = $true
    $dialog.Font = New-Object System.Drawing.Font (Get-DialogSettingValue "BdoFontFamily" $script:BdoFontFamily), ([float](Get-DialogSettingValue "BdoFontSize" $script:BdoFontSize)), ([System.Drawing.FontStyle]::Bold)

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoFontFamily $dialog.Font.FontFamily.Name
        Set-BdoFontSize ([int][Math]::Round($dialog.Font.SizeInPoints))
    }
}

function Show-BdoTransitionTextColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BdoTransitionTextColor" $script:BdoTransitionTextColor) "#FFFFFF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoTransitionTextColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BdoTransitionTextOutlineColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BdoTransitionTextOutlineColor" $script:BdoTransitionTextOutlineColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoTransitionTextOutlineColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BdoTransitionFontDialog {
    $dialog = New-Object System.Windows.Forms.FontDialog
    $dialog.ShowColor = $false
    $dialog.ShowEffects = $false
    $dialog.FontMustExist = $true
    $dialog.Font = New-Object System.Drawing.Font (Get-DialogSettingValue "BdoTransitionFontFamily" $script:BdoTransitionFontFamily), ([float](Get-DialogSettingValue "BdoTransitionFontSize" $script:BdoTransitionFontSize)), ([System.Drawing.FontStyle]::Bold)

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BdoTransitionFontFamily $dialog.Font.FontFamily.Name
        Set-BdoTransitionFontSize ([int][Math]::Round($dialog.Font.SizeInPoints))
    }
}

function Show-BossTextColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BossTextColor" $script:BossTextColor) "#FFFFFF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BossTextColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BossTextOutlineColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BossTextOutlineColor" $script:BossTextOutlineColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BossTextOutlineColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BossHighlightColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BossHighlightColor" $script:BossHighlightColor) "#FFFFFF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BossHighlightColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-BossFontDialog {
    $dialog = New-Object System.Windows.Forms.FontDialog
    $dialog.ShowColor = $false
    $dialog.ShowEffects = $false
    $dialog.FontMustExist = $true
    $dialog.Font = New-Object System.Drawing.Font (Get-DialogSettingValue "BossFontFamily" $script:BossFontFamily), ([float](Get-DialogSettingValue "BossFontSize" $script:BossFontSize)), ([System.Drawing.FontStyle]::Bold)

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BossFontFamily $dialog.Font.FontFamily.Name
        Set-BossFontSize ([int][Math]::Round($dialog.Font.SizeInPoints))
    }
}

function Show-FontDialog {
    $dialog = New-Object System.Windows.Forms.FontDialog
    $dialog.ShowColor = $false
    $dialog.ShowEffects = $false
    $dialog.FontMustExist = $true
    $dialog.Font = New-Object System.Drawing.Font (Get-DialogSettingValue "FontFamily" $script:FontFamily), ([float](Get-DialogSettingValue "FontSize" $script:FontSize)), ([System.Drawing.FontStyle]::Bold)

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-FontFamily $dialog.Font.FontFamily.Name
        Set-WidgetFontSize ([int][Math]::Round($dialog.Font.SizeInPoints))
    }
}

function Set-ColorSwatch {
    param(
        [System.Windows.Controls.Border]$Swatch,
        [string]$Hex,
        [bool]$Transparent = $false
    )

    if ($Swatch) {
        if ($Transparent) {
            $Swatch.Background = [System.Windows.Media.Brushes]::Transparent
            $Swatch.ToolTip = "투명"
        }
        else {
            $Swatch.Background = New-Object System.Windows.Media.SolidColorBrush (ConvertTo-WpfColor $Hex "#000000")
            $Swatch.ToolTip = $Hex
        }
    }
}

function Get-SettingOrScriptValue {
    param([string]$Name)

    if ($script:SettingsDraft -and $null -ne $script:SettingsDraft.$Name) {
        return $script:SettingsDraft.$Name
    }
    Get-Variable -Scope Script -Name $Name -ValueOnly
}

function Sync-TransparentColorControls {
    $items = @(
        @("TextColorTransparent", "TextColorTransparentCheckBox", "TextColorSwatch", "TextColor"),
        @("TextOutlineColorTransparent", "TextOutlineColorTransparentCheckBox", "TextOutlineColorSwatch", "TextOutlineColor"),
        @("BdoTextColorTransparent", "BdoTextColorTransparentCheckBox", "BdoTextColorSwatch", "BdoTextColor"),
        @("BdoTextOutlineColorTransparent", "BdoTextOutlineColorTransparentCheckBox", "BdoTextOutlineColorSwatch", "BdoTextOutlineColor"),
        @("BdoTransitionTextColorTransparent", "BdoTransitionTextColorTransparentCheckBox", "BdoTransitionTextColorSwatch", "BdoTransitionTextColor"),
        @("BdoTransitionTextOutlineColorTransparent", "BdoTransitionTextOutlineColorTransparentCheckBox", "BdoTransitionTextOutlineColorSwatch", "BdoTransitionTextOutlineColor"),
        @("BossTextColorTransparent", "BossTextColorTransparentCheckBox", "BossTextColorSwatch", "BossTextColor"),
        @("BossTextOutlineColorTransparent", "BossTextOutlineColorTransparentCheckBox", "BossTextOutlineColorSwatch", "BossTextOutlineColor"),
        @("", "", "BossHighlightColorSwatch", "BossHighlightColor")
    )

    foreach ($item in $items) {
        $transparent = if ([string]::IsNullOrWhiteSpace($item[0])) { $false } else { [bool](Get-SettingOrScriptValue $item[0]) }
        $checkbox = if ([string]::IsNullOrWhiteSpace($item[1])) { $null } else { Get-Variable -Scope Script -Name $item[1] -ValueOnly -ErrorAction SilentlyContinue }
        if ($checkbox) {
            $checkbox.IsChecked = $transparent
        }

        $swatch = Get-Variable -Scope Script -Name $item[2] -ValueOnly -ErrorAction SilentlyContinue
        $hex = [string](Get-SettingOrScriptValue $item[3])
        Set-ColorSwatch $swatch $hex $transparent
    }
}

function New-ColorValueControl {
    param(
        [System.Windows.Controls.TextBox]$TextBox,
        [string]$Hex,
        [string]$SwatchName,
        [string]$ColorPropertyName = "",
        [scriptblock]$DialogHandler = $null,
        [string]$TransparentPropertyName = "",
        [string]$TransparentCheckBoxName = ""
    )

    $panel = New-Object System.Windows.Controls.StackPanel
    $panel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $panel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

    $swatch = New-Object System.Windows.Controls.Border
    $swatch.Width = 18
    $swatch.Height = 18
    $swatch.BorderThickness = New-Object System.Windows.Thickness 1
    $swatch.BorderBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(120, 120, 120))
    $swatch.Margin = New-Object System.Windows.Thickness 0, 0, 8, 0
    $swatch.Cursor = [System.Windows.Input.Cursors]::Hand
    $transparent = $false
    if (-not [string]::IsNullOrWhiteSpace($TransparentPropertyName)) {
        $transparent = [bool](Get-SettingOrScriptValue $TransparentPropertyName)
    }
    Set-ColorSwatch $swatch $Hex $transparent
    if ($DialogHandler) {
        $handler = $DialogHandler
        $swatch.Add_MouseLeftButtonDown({
            param($sender, $eventArgs)
            if ($eventArgs.ClickCount -ge 2) {
                & $handler
                $eventArgs.Handled = $true
            }
        }.GetNewClosure())
    }
    Set-Variable -Scope Script -Name $SwatchName -Value $swatch
    $panel.Children.Add($swatch) | Out-Null

    $TextBox.Width = 78
    $TextBox.Text = (Normalize-HexColorInput $Hex $Hex)
    $TextBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $TextBox.BorderThickness = New-Object System.Windows.Thickness 1
    $TextBox.Padding = New-Object System.Windows.Thickness 3, 1, 3, 1
    if (-not [string]::IsNullOrWhiteSpace($ColorPropertyName)) {
        $propertyName = $ColorPropertyName
        $TextBox.Add_LostFocus({
            param($sender, $eventArgs)
            Set-ColorSettingByName $propertyName $sender.Text
        }.GetNewClosure())
        $TextBox.Add_KeyDown({
            param($sender, $eventArgs)
            if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
                Set-ColorSettingByName $propertyName $sender.Text
                $eventArgs.Handled = $true
            }
        }.GetNewClosure())
    }
    $panel.Children.Add($TextBox) | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($TransparentPropertyName)) {
        $checkbox = New-Object System.Windows.Controls.CheckBox
        $checkbox.Content = "투명"
        $checkbox.IsChecked = $transparent
        $checkbox.Margin = New-Object System.Windows.Thickness 12, 0, 0, 0
        $checkbox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $propertyName = $TransparentPropertyName
        $checkbox.Add_Click({
            param($sender, $eventArgs)
            Set-ColorTransparency $propertyName ([bool]$sender.IsChecked)
        }.GetNewClosure())
        if (-not [string]::IsNullOrWhiteSpace($TransparentCheckBoxName)) {
            Set-Variable -Scope Script -Name $TransparentCheckBoxName -Value $checkbox
        }
        $panel.Children.Add($checkbox) | Out-Null
    }

    $panel
}

function Set-FontValueText {
    param(
        [System.Windows.Controls.TextBlock]$TextBlock,
        [string]$FontName
    )

    if ($TextBlock) {
        $TextBlock.Text = $FontName
        $TextBlock.FontFamily = New-Object System.Windows.Media.FontFamily $FontName
    }
}

function Get-DialogSettingValue {
    param(
        [string]$Name,
        [object]$Fallback
    )

    if ($script:SettingsDraft -and $null -ne $script:SettingsDraft.$Name) {
        return $script:SettingsDraft.$Name
    }
    return $Fallback
}

function New-SettingsRow {
    param(
        [string]$Label,
        [System.Windows.FrameworkElement]$ValueControl,
        [scriptblock]$ClickHandler = $null
    )

    $row = New-Object System.Windows.Controls.Grid
    $row.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $labelColumn = New-Object System.Windows.Controls.ColumnDefinition
    $labelColumn.Width = New-Object System.Windows.GridLength 128
    $row.ColumnDefinitions.Add($labelColumn) | Out-Null

    $valueColumn = New-Object System.Windows.Controls.ColumnDefinition
    $valueColumn.Width = New-Object System.Windows.GridLength 1, ([System.Windows.GridUnitType]::Star)
    $row.ColumnDefinitions.Add($valueColumn) | Out-Null

    $buttonColumn = New-Object System.Windows.Controls.ColumnDefinition
    $buttonColumn.Width = [System.Windows.GridLength]::Auto
    $row.ColumnDefinitions.Add($buttonColumn) | Out-Null

    if ($ClickHandler) {
        $button = New-Object System.Windows.Controls.Button
        $button.Content = "변경"
        $button.Width = 72
        $button.Margin = New-Object System.Windows.Thickness 12, 0, 0, 0
        $button.Add_Click($ClickHandler)
        [System.Windows.Controls.Grid]::SetColumn($button, 2)
        $row.Children.Add($button) | Out-Null
    }

    $labelBlock = New-Object System.Windows.Controls.TextBlock
    $labelBlock.Text = $Label
    $labelBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $labelBlock.TextWrapping = [System.Windows.TextWrapping]::NoWrap
    $labelBlock.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
    [System.Windows.Controls.Grid]::SetColumn($labelBlock, 0)
    $row.Children.Add($labelBlock) | Out-Null

    $ValueControl.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $ValueControl.Margin = New-Object System.Windows.Thickness 8, 0, 0, 0
    $ValueControl.MinWidth = 110
    if ($ValueControl -is [System.Windows.Controls.TextBlock]) {
        $ValueControl.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
    }
    [System.Windows.Controls.Grid]::SetColumn($ValueControl, 1)
    $row.Children.Add($ValueControl) | Out-Null

    $row
}

function New-SliderRow {
    param(
        [System.Windows.Controls.Slider]$Slider,
        [System.Windows.Controls.TextBlock]$ValueText
    )

    $row = New-Object System.Windows.Controls.Grid
    $row.Margin = New-Object System.Windows.Thickness 0, 2, 0, 12
    $row.Height = 48

    $leftColumn = New-Object System.Windows.Controls.ColumnDefinition
    $leftColumn.Width = [System.Windows.GridLength]::Auto
    $row.ColumnDefinitions.Add($leftColumn) | Out-Null

    $middleColumn = New-Object System.Windows.Controls.ColumnDefinition
    $middleColumn.Width = New-Object System.Windows.GridLength 1, ([System.Windows.GridUnitType]::Star)
    $row.ColumnDefinitions.Add($middleColumn) | Out-Null

    $rightColumn = New-Object System.Windows.Controls.ColumnDefinition
    $rightColumn.Width = [System.Windows.GridLength]::Auto
    $row.ColumnDefinitions.Add($rightColumn) | Out-Null

    $valueColumn = New-Object System.Windows.Controls.ColumnDefinition
    $valueColumn.Width = [System.Windows.GridLength]::Auto
    $row.ColumnDefinitions.Add($valueColumn) | Out-Null

    $minus = New-Object System.Windows.Controls.TextBlock
    $minus.Text = "-"
    $minus.Width = 18
    $minus.FontSize = 16
    $minus.TextAlignment = [System.Windows.TextAlignment]::Center
    $minus.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $minus.Margin = New-Object System.Windows.Thickness 0, 8, 0, 0
    [System.Windows.Controls.Grid]::SetColumn($minus, 0)
    $row.Children.Add($minus) | Out-Null

    $Slider.Margin = New-Object System.Windows.Thickness 0
    $Slider.Height = 46
    $Slider.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $Slider.TickPlacement = [System.Windows.Controls.Primitives.TickPlacement]::BottomRight
    $Slider.IsMoveToPointEnabled = $true
    [System.Windows.Controls.Grid]::SetColumn($Slider, 1)
    $row.Children.Add($Slider) | Out-Null

    $plus = New-Object System.Windows.Controls.TextBlock
    $plus.Text = "+"
    $plus.Width = 18
    $plus.FontSize = 16
    $plus.TextAlignment = [System.Windows.TextAlignment]::Center
    $plus.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $plus.Margin = New-Object System.Windows.Thickness 0, 8, 0, 0
    [System.Windows.Controls.Grid]::SetColumn($plus, 2)
    $row.Children.Add($plus) | Out-Null

    $ValueText.Width = 36
    $ValueText.TextAlignment = [System.Windows.TextAlignment]::Right
    $ValueText.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
    $ValueText.Margin = New-Object System.Windows.Thickness 8, 8, 0, 0
    [System.Windows.Controls.Grid]::SetColumn($ValueText, 3)
    $row.Children.Add($ValueText) | Out-Null

    $row
}

function New-BossAlertTimeInputRow {
    param(
        [string]$Label,
        [System.Windows.Controls.TextBox]$MinuteBox,
        [System.Windows.Controls.TextBox]$SecondBox,
        [string]$Suffix
    )

    $row = New-Object System.Windows.Controls.Grid
    $row.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $labelColumn = New-Object System.Windows.Controls.ColumnDefinition
    $labelColumn.Width = New-Object System.Windows.GridLength 1, ([System.Windows.GridUnitType]::Star)
    $row.ColumnDefinitions.Add($labelColumn) | Out-Null

    foreach ($width in 56, 24, 56, 24, 44) {
        $column = New-Object System.Windows.Controls.ColumnDefinition
        $column.Width = New-Object System.Windows.GridLength $width
        $row.ColumnDefinitions.Add($column) | Out-Null
    }

    $labelBlock = New-Object System.Windows.Controls.TextBlock
    $labelBlock.Text = $Label
    $labelBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($labelBlock, 0)
    $row.Children.Add($labelBlock) | Out-Null

    $MinuteBox.Width = 50
    $MinuteBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
    $MinuteBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($MinuteBox, 1)
    $row.Children.Add($MinuteBox) | Out-Null

    $minuteLabel = New-Object System.Windows.Controls.TextBlock
    $minuteLabel.Text = "분"
    $minuteLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($minuteLabel, 2)
    $row.Children.Add($minuteLabel) | Out-Null

    $SecondBox.Width = 50
    $SecondBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
    $SecondBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($SecondBox, 3)
    $row.Children.Add($SecondBox) | Out-Null

    $secondLabel = New-Object System.Windows.Controls.TextBlock
    $secondLabel.Text = "초 $Suffix"
    $secondLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($secondLabel, 4)
    $row.Children.Add($secondLabel) | Out-Null

    $row
}

function New-BossValueEditCell {
    param(
        [string]$Summary,
        [int]$Index,
        [string]$Kind
    )

    $hasValue = -not [string]::IsNullOrWhiteSpace($Summary) -and $Summary -ne "미설정"
    if (-not $hasValue) {
        $button = New-Object System.Windows.Controls.Button
        $button.Content = "설정하기"
        $button.Tag = [pscustomobject]@{ Index = $Index; Kind = $Kind }
        $button.Margin = New-Object System.Windows.Thickness 0, 0, 4, 0
        $button.Add_Click({
            param($sender, $eventArgs)
            if ($sender.Tag.Kind -eq "Days") {
                Show-BossDaysDialog ([int]$sender.Tag.Index)
            }
            else {
                Show-BossTimesDialog ([int]$sender.Tag.Index)
            }
        })
        return $button
    }

    $cell = New-Object System.Windows.Controls.Grid
    $cell.Margin = New-Object System.Windows.Thickness 0, 0, 4, 0
    $textColumn = New-Object System.Windows.Controls.ColumnDefinition
    $textColumn.Width = New-Object System.Windows.GridLength 1, ([System.Windows.GridUnitType]::Star)
    $cell.ColumnDefinitions.Add($textColumn) | Out-Null
    $buttonColumn = New-Object System.Windows.Controls.ColumnDefinition
    $buttonColumn.Width = [System.Windows.GridLength]::Auto
    $cell.ColumnDefinitions.Add($buttonColumn) | Out-Null

    $text = New-Object System.Windows.Controls.TextBlock
    $text.Text = $Summary
    $text.ToolTip = $Summary
    $text.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $text.TextWrapping = [System.Windows.TextWrapping]::Wrap
    [System.Windows.Controls.Grid]::SetColumn($text, 0)
    $cell.Children.Add($text) | Out-Null

    $button = New-Object System.Windows.Controls.Button
    $button.Content = "수정"
    $button.Width = 44
    $button.Margin = New-Object System.Windows.Thickness 6, 0, 0, 0
    $button.Tag = [pscustomobject]@{ Index = $Index; Kind = $Kind }
    $button.Add_Click({
        param($sender, $eventArgs)
        if ($sender.Tag.Kind -eq "Days") {
            Show-BossDaysDialog ([int]$sender.Tag.Index)
        }
        else {
            Show-BossTimesDialog ([int]$sender.Tag.Index)
        }
    })
    [System.Windows.Controls.Grid]::SetColumn($button, 1)
    $cell.Children.Add($button) | Out-Null

    $cell
}

function New-BossRowEditorRow {
    param(
        [object]$BossRow,
        [int]$Index
    )

    $row = New-Object System.Windows.Controls.Grid
    $row.Margin = New-Object System.Windows.Thickness 0, 0, 0, 6

    foreach ($width in 110, 430, 44, 48, 54, 30) {
        $column = New-Object System.Windows.Controls.ColumnDefinition
        $column.Width = New-Object System.Windows.GridLength $width
        $row.ColumnDefinitions.Add($column) | Out-Null
    }

    $nameBox = New-Object System.Windows.Controls.TextBox
    $nameBox.Text = [string]$BossRow.Name
    $nameBox.Tag = $Index
    $nameBox.Margin = New-Object System.Windows.Thickness 0, 0, 4, 0
    $nameBox.Add_LostFocus({
        param($sender, $eventArgs)
        Update-BossRowName ([int]$sender.Tag) $sender.Text
    })
    $nameBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Update-BossRowName ([int]$sender.Tag) $sender.Text
            $eventArgs.Handled = $true
        }
    })
    [System.Windows.Controls.Grid]::SetColumn($nameBox, 0)
    $row.Children.Add($nameBox) | Out-Null

    $timesCell = New-BossValueEditCell (Get-BossRowTimesSummary $BossRow) $Index "Times"
    [System.Windows.Controls.Grid]::SetColumn($timesCell, 1)
    $row.Children.Add($timesCell) | Out-Null

    $priorityBox = New-Object System.Windows.Controls.TextBox
    $priorityBox.Text = [string]$BossRow.Priority
    $priorityBox.Tag = $Index
    $priorityBox.ToolTip = "0이 가장 높고 10이 가장 낮습니다."
    $priorityBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
    $priorityBox.Margin = New-Object System.Windows.Thickness 0, 0, 4, 0
    $priorityBox.Add_LostFocus({
        param($sender, $eventArgs)
        Update-BossRowPriority ([int]$sender.Tag) $sender.Text
    })
    $priorityBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Update-BossRowPriority ([int]$sender.Tag) $sender.Text
            $eventArgs.Handled = $true
        }
    })
    [System.Windows.Controls.Grid]::SetColumn($priorityBox, 2)
    $row.Children.Add($priorityBox) | Out-Null

    $alertCheck = New-Object System.Windows.Controls.CheckBox
    $alertCheck.Content = "알림"
    $alertCheck.Tag = $Index
    $alertCheck.IsChecked = [bool]$BossRow.Alert
    $alertCheck.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $alertCheck.Add_Click({
        param($sender, $eventArgs)
        Update-BossRowAlert ([int]$sender.Tag) ([bool]$sender.IsChecked)
    })
    [System.Windows.Controls.Grid]::SetColumn($alertCheck, 3)
    $row.Children.Add($alertCheck) | Out-Null

    $highlightCheck = New-Object System.Windows.Controls.CheckBox
    $highlightCheck.Content = "강조"
    $highlightCheck.Tag = $Index
    $highlightCheck.IsChecked = [bool]$BossRow.Highlight
    $highlightCheck.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $highlightCheck.Add_Click({
        param($sender, $eventArgs)
        Update-BossRowHighlight ([int]$sender.Tag) ([bool]$sender.IsChecked)
    })
    [System.Windows.Controls.Grid]::SetColumn($highlightCheck, 4)
    $row.Children.Add($highlightCheck) | Out-Null

    $removeButton = New-Object System.Windows.Controls.Button
    $removeButton.Content = "x"
    $removeButton.Tag = $Index
    $removeButton.Width = 24
    $removeButton.Add_Click({ param($sender, $eventArgs) Remove-BossRow ([int]$sender.Tag) })
    [System.Windows.Controls.Grid]::SetColumn($removeButton, 5)
    $row.Children.Add($removeButton) | Out-Null

    $row
}

function Refresh-BossRowsEditor {
    if (-not $script:BossRowsPanel) {
        return
    }

    $script:BossRowsPanel.Children.Clear()
    $rows = @(Get-EditableBossRows)

    $header = New-Object System.Windows.Controls.Grid
    $header.Margin = New-Object System.Windows.Thickness 0, 4, 0, 4
    foreach ($width in 110, 430, 44, 48, 54, 30) {
        $column = New-Object System.Windows.Controls.ColumnDefinition
        $column.Width = New-Object System.Windows.GridLength $width
        $header.ColumnDefinitions.Add($column) | Out-Null
    }
    $labels = @("보스", "요일/시간", "우선", "알림", "강조", "")
    for ($i = 0; $i -lt $labels.Count; $i++) {
        $label = New-Object System.Windows.Controls.TextBlock
        $label.Text = $labels[$i]
        $label.FontSize = 11
        $label.Opacity = 0.82
        [System.Windows.Controls.Grid]::SetColumn($label, $i)
        $header.Children.Add($label) | Out-Null
    }
    $script:BossRowsPanel.Children.Add($header) | Out-Null

    for ($i = 0; $i -lt $rows.Count; $i++) {
        $script:BossRowsPanel.Children.Add((New-BossRowEditorRow $rows[$i] $i)) | Out-Null
    }

    $addButton = New-Object System.Windows.Controls.Button
    $addButton.Content = "+"
    $addButton.Width = 34
    $addButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Left
    $addButton.Margin = New-Object System.Windows.Thickness 0, 2, 0, 8
    $addButton.Add_Click({ Add-BossRow })
    $script:BossRowsPanel.Children.Add($addButton) | Out-Null
}

function New-SettingsExpander {
    param(
        [string]$Header,
        [object]$Content,
        [bool]$Visible
    )

    $expander = New-Object System.Windows.Controls.Expander
    $expander.Header = $Header
    $expander.Content = $Content
    $expander.IsExpanded = $false
    $expander.Margin = New-Object System.Windows.Thickness 18, -8, 0, 14
    $expander.Visibility = if ($Visible) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $expander
}

function New-BlackSpiritLogo {
    $canvas = New-Object System.Windows.Controls.Canvas
    $canvas.Width = 20
    $canvas.Height = 20
    $canvas.Margin = New-Object System.Windows.Thickness 0, 0, 5, 0
    $canvas.IsHitTestVisible = $false

    $body = New-Object System.Windows.Shapes.Ellipse
    $body.Width = 16
    $body.Height = 16
    $body.Fill = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(5, 5, 7))
    $body.Stroke = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(255, 255, 255))
    $body.StrokeThickness = 1
    [System.Windows.Controls.Canvas]::SetLeft($body, 2)
    [System.Windows.Controls.Canvas]::SetTop($body, 3)
    $canvas.Children.Add($body) | Out-Null

    $leftHorn = New-Object System.Windows.Shapes.Polygon
    $leftHorn.Points = [System.Windows.Media.PointCollection]::Parse("6,4 2,0 9,2")
    $leftHorn.Fill = $body.Fill
    $canvas.Children.Add($leftHorn) | Out-Null

    $rightHorn = New-Object System.Windows.Shapes.Polygon
    $rightHorn.Points = [System.Windows.Media.PointCollection]::Parse("14,4 18,0 11,2")
    $rightHorn.Fill = $body.Fill
    $canvas.Children.Add($rightHorn) | Out-Null

    $leftEye = New-Object System.Windows.Shapes.Ellipse
    $leftEye.Width = 3
    $leftEye.Height = 3
    $leftEye.Fill = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(255, 255, 255))
    [System.Windows.Controls.Canvas]::SetLeft($leftEye, 6)
    [System.Windows.Controls.Canvas]::SetTop($leftEye, 9)
    $canvas.Children.Add($leftEye) | Out-Null

    $rightEye = New-Object System.Windows.Shapes.Ellipse
    $rightEye.Width = 3
    $rightEye.Height = 3
    $rightEye.Fill = $leftEye.Fill
    [System.Windows.Controls.Canvas]::SetLeft($rightEye, 11)
    [System.Windows.Controls.Canvas]::SetTop($rightEye, 9)
    $canvas.Children.Add($rightEye) | Out-Null

    $canvas
}

function New-PapuLogo {
    $canvas = New-Object System.Windows.Controls.Canvas
    $canvas.Width = 22
    $canvas.Height = 20
    $canvas.Margin = New-Object System.Windows.Thickness 0, 0, 5, 0
    $canvas.IsHitTestVisible = $false

    $whiteBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(250, 255, 255))
    $blueBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(172, 225, 246))
    $pinkBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(255, 205, 210))
    $darkBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(18, 18, 22))
    $greenBrush = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(154, 184, 134))

    $leftEar = New-Object System.Windows.Shapes.Polygon
    $leftEar.Points = [System.Windows.Media.PointCollection]::Parse("4,8 2,0 9,6")
    $leftEar.Fill = $whiteBrush
    $leftEar.Stroke = $darkBrush
    $leftEar.StrokeThickness = 1
    $canvas.Children.Add($leftEar) | Out-Null

    $rightEar = New-Object System.Windows.Shapes.Polygon
    $rightEar.Points = [System.Windows.Media.PointCollection]::Parse("18,8 20,0 13,6")
    $rightEar.Fill = $whiteBrush
    $rightEar.Stroke = $darkBrush
    $rightEar.StrokeThickness = 1
    $canvas.Children.Add($rightEar) | Out-Null

    $face = New-Object System.Windows.Shapes.Ellipse
    $face.Width = 17
    $face.Height = 13
    $face.Fill = $whiteBrush
    $face.Stroke = $darkBrush
    $face.StrokeThickness = 1
    [System.Windows.Controls.Canvas]::SetLeft($face, 2.5)
    [System.Windows.Controls.Canvas]::SetTop($face, 4)
    $canvas.Children.Add($face) | Out-Null

    $mask = New-Object System.Windows.Shapes.Ellipse
    $mask.Width = 14
    $mask.Height = 7
    $mask.Fill = $blueBrush
    [System.Windows.Controls.Canvas]::SetLeft($mask, 4)
    [System.Windows.Controls.Canvas]::SetTop($mask, 6)
    $canvas.Children.Add($mask) | Out-Null

    $scarf = New-Object System.Windows.Shapes.Polygon
    $scarf.Points = [System.Windows.Media.PointCollection]::Parse("5,14 17,14 15,19 7,19")
    $scarf.Fill = $greenBrush
    $canvas.Children.Add($scarf) | Out-Null

    $leftEye = New-Object System.Windows.Shapes.Ellipse
    $leftEye.Width = 2
    $leftEye.Height = 3
    $leftEye.Fill = $darkBrush
    [System.Windows.Controls.Canvas]::SetLeft($leftEye, 7)
    [System.Windows.Controls.Canvas]::SetTop($leftEye, 9)
    $canvas.Children.Add($leftEye) | Out-Null

    $rightEye = New-Object System.Windows.Shapes.Ellipse
    $rightEye.Width = 2
    $rightEye.Height = 3
    $rightEye.Fill = $darkBrush
    [System.Windows.Controls.Canvas]::SetLeft($rightEye, 13)
    [System.Windows.Controls.Canvas]::SetTop($rightEye, 9)
    $canvas.Children.Add($rightEye) | Out-Null

    $mouth = New-Object System.Windows.Shapes.Ellipse
    $mouth.Width = 4
    $mouth.Height = 5
    $mouth.Fill = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(255, 150, 110))
    $mouth.Stroke = $darkBrush
    $mouth.StrokeThickness = 0.8
    [System.Windows.Controls.Canvas]::SetLeft($mouth, 9)
    [System.Windows.Controls.Canvas]::SetTop($mouth, 11)
    $canvas.Children.Add($mouth) | Out-Null

    $cheek = New-Object System.Windows.Shapes.Ellipse
    $cheek.Width = 3
    $cheek.Height = 3
    $cheek.Fill = $pinkBrush
    [System.Windows.Controls.Canvas]::SetLeft($cheek, 15)
    [System.Windows.Controls.Canvas]::SetTop($cheek, 12)
    $canvas.Children.Add($cheek) | Out-Null

    $canvas
}

function Update-BdoLogo {
    if (-not $script:BdoLogoImage) {
        return
    }

    $script:BdoLogoImage.Source = New-WpfImageSource (Get-BdoLogoPath)
    Apply-BdoTimeStyle
}

function Format-ContextMenuItem {
    param([System.Windows.Controls.MenuItem]$Item)

    $Item.Height = 26
    $Item.Padding = New-Object System.Windows.Thickness 8, 0, 8, 0
    $Item.FontFamily = New-Object System.Windows.Media.FontFamily "Malgun Gothic"
    $Item.FontSize = 8
    $Item.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $Item.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Left
}

function Toggle-Startup {
    try {
        if ($script:SettingsDraft) {
            $nextValue = -not [bool]$script:SettingsDraft.StartupEnabled
            Set-SettingsDraftValue "StartupEnabled" $nextValue | Out-Null
            return
        }

        if (Test-StartupEnabled) {
            Disable-Startup
        }
        else {
            Enable-Startup
        }

        if ($script:StartupMenuItem) {
            $script:StartupMenuItem.IsChecked = Test-StartupEnabled
        }
        if ($script:StartupCheckBox) {
            $script:StartupCheckBox.IsChecked = Test-StartupEnabled
        }
    }
    catch {
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            "시작 프로그램 설정 실패",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
    }
}

function Show-SettingsWindow {
    if ($script:SettingsWindow -and $script:SettingsWindow.IsVisible) {
        $script:SettingsWindow.Activate()
        return
    }

    $settings = New-Object System.Windows.Window
    $settings.Title = "Clock Widget 설정"
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $settings.Width = 920
    $settings.Height = [Math]::Min(760, [Math]::Max(520, $workArea.Height - 120))
    $settings.MinWidth = 760
    $settings.MinHeight = 420
    $settings.MaxWidth = [Math]::Max(760, $workArea.Width - 40)
    $settings.MaxHeight = [Math]::Max(420, $workArea.Height - 40)
    $settings.SizeToContent = [System.Windows.SizeToContent]::Manual
    $settings.ResizeMode = [System.Windows.ResizeMode]::CanResizeWithGrip
    $settings.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
    $settings.Topmost = $false
    $settings.ShowInTaskbar = $true
    $script:SettingsWindow = $settings
    $script:SettingsOriginal = Get-SettingsSnapshot
    $script:SettingsDraft = Copy-SettingsSnapshot $script:SettingsOriginal
    $script:SettingsDirty = $false
    $script:SettingsCloseAction = $null

    $settingsRoot = New-Object System.Windows.Controls.Grid
    $contentRow = New-Object System.Windows.Controls.RowDefinition
    $contentRow.Height = New-Object System.Windows.GridLength 1, ([System.Windows.GridUnitType]::Star)
    $settingsRoot.RowDefinitions.Add($contentRow) | Out-Null
    $buttonRow = New-Object System.Windows.Controls.RowDefinition
    $buttonRow.Height = [System.Windows.GridLength]::Auto
    $settingsRoot.RowDefinitions.Add($buttonRow) | Out-Null
    $previewRow = New-Object System.Windows.Controls.RowDefinition
    $previewRow.Height = [System.Windows.GridLength]::Auto
    $settingsRoot.RowDefinitions.Add($previewRow) | Out-Null
    $settings.Content = $settingsRoot

    $scrollViewer = New-Object System.Windows.Controls.ScrollViewer
    $scrollViewer.VerticalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Auto
    $scrollViewer.HorizontalScrollBarVisibility = [System.Windows.Controls.ScrollBarVisibility]::Disabled
    $scrollViewer.CanContentScroll = $false
    [System.Windows.Controls.Grid]::SetRow($scrollViewer, 0)
    $settingsRoot.Children.Add($scrollViewer) | Out-Null

    $panel = New-Object System.Windows.Controls.StackPanel
    $panel.Margin = New-Object System.Windows.Thickness 16
    $scrollViewer.Content = $panel

    $title = New-Object System.Windows.Controls.TextBlock
    $title.Text = "Clock Widget"
    $title.FontSize = 16
    $title.FontWeight = [System.Windows.FontWeights]::Bold
    $title.Margin = New-Object System.Windows.Thickness 0, 0, 0, 12
    $panel.Children.Add($title) | Out-Null

    $script:StartupCheckBox = New-Object System.Windows.Controls.CheckBox
    $script:StartupCheckBox.Content = "Windows 시작 시 자동 실행"
    $script:StartupCheckBox.IsChecked = Test-StartupEnabled
    $script:StartupCheckBox.Margin = New-Object System.Windows.Thickness 0, 0, 0, 14
    $script:StartupCheckBox.Add_Click({ Toggle-Startup })
    $panel.Children.Add($script:StartupCheckBox) | Out-Null

    $script:BdoTimeCheckBox = New-Object System.Windows.Controls.CheckBox
    $script:BdoTimeCheckBox.Content = "검은사막 게임 내 시간 표시"
    $script:BdoTimeCheckBox.IsChecked = [bool]$script:BdoTimeEnabled
    $script:BdoTimeCheckBox.Margin = New-Object System.Windows.Thickness 0, 0, 0, 14
    $script:BdoTimeCheckBox.Add_Click({
        param($sender, $eventArgs)
        Set-BdoTimeEnabled ([bool]$sender.IsChecked)
    })
    $panel.Children.Add($script:BdoTimeCheckBox) | Out-Null

    $script:BdoOptionsPanel = New-Object System.Windows.Controls.StackPanel
    $script:BdoOptionsPanel.Margin = New-Object System.Windows.Thickness 10, 8, 0, 0

    $script:BdoIconEnabledCheckBox = New-Object System.Windows.Controls.CheckBox
    $script:BdoIconEnabledCheckBox.Content = "검은사막 아이콘 표시"
    $script:BdoIconEnabledCheckBox.IsChecked = [bool]$script:BdoIconEnabled
    $script:BdoIconEnabledCheckBox.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8
    $script:BdoIconEnabledCheckBox.Add_Click({
        param($sender, $eventArgs)
        Set-BdoIconEnabled ([bool]$sender.IsChecked)
    })
    $script:BdoOptionsPanel.Children.Add($script:BdoIconEnabledCheckBox) | Out-Null

    $script:BdoIconChoicePanel = New-Object System.Windows.Controls.StackPanel
    $script:BdoIconChoicePanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $script:BdoIconChoicePanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $bdoIconLabel = New-Object System.Windows.Controls.TextBlock
    $bdoIconLabel.Text = "검은사막 아이콘"
    $bdoIconLabel.Margin = New-Object System.Windows.Thickness 0, 0, 12, 0
    $bdoIconLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoIconChoicePanel.Children.Add($bdoIconLabel) | Out-Null

    $script:BdoBlackSpiritRadioButton = New-Object System.Windows.Controls.RadioButton
    $script:BdoBlackSpiritRadioButton.Content = "흑정령"
    $script:BdoBlackSpiritRadioButton.GroupName = "BdoIcon"
    $script:BdoBlackSpiritRadioButton.Margin = New-Object System.Windows.Thickness 0, 0, 16, 0
    $script:BdoBlackSpiritRadioButton.IsChecked = ($script:BdoIconType -ne "papu")
    $script:BdoBlackSpiritRadioButton.Add_Checked({ Set-BdoIconType "blackSpirit" })
    $script:BdoIconChoicePanel.Children.Add($script:BdoBlackSpiritRadioButton) | Out-Null

    $script:BdoPapuRadioButton = New-Object System.Windows.Controls.RadioButton
    $script:BdoPapuRadioButton.Content = "파푸"
    $script:BdoPapuRadioButton.GroupName = "BdoIcon"
    $script:BdoPapuRadioButton.IsChecked = ($script:BdoIconType -eq "papu")
    $script:BdoPapuRadioButton.Add_Checked({ Set-BdoIconType "papu" })
    $script:BdoIconChoicePanel.Children.Add($script:BdoPapuRadioButton) | Out-Null
    if ($script:BdoIconEnabled) {
        $script:BdoIconChoicePanel.Visibility = [System.Windows.Visibility]::Visible
    }
    else {
        $script:BdoIconChoicePanel.Visibility = [System.Windows.Visibility]::Collapsed
    }
    $script:BdoOptionsPanel.Children.Add($script:BdoIconChoicePanel) | Out-Null

    $bdoTimeFormatLabel = New-Object System.Windows.Controls.TextBlock
    $bdoTimeFormatLabel.Text = "검은사막 시간 표시"
    $bdoTimeFormatLabel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 4
    $script:BdoOptionsPanel.Children.Add($bdoTimeFormatLabel) | Out-Null

    $bdoTimeFormatPanel = New-Object System.Windows.Controls.StackPanel
    $bdoTimeFormatPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $bdoTimeFormatPanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $script:BdoTimeFormat24RadioButton = New-Object System.Windows.Controls.RadioButton
    $script:BdoTimeFormat24RadioButton.Content = "24시간"
    $script:BdoTimeFormat24RadioButton.GroupName = "BdoTimeFormat"
    $script:BdoTimeFormat24RadioButton.Margin = New-Object System.Windows.Thickness 0, 0, 18, 0
    $script:BdoTimeFormat24RadioButton.IsChecked = ($script:BdoTimeFormat -ne "12")
    $script:BdoTimeFormat24RadioButton.Add_Checked({ Set-BdoTimeFormat "24" })
    $bdoTimeFormatPanel.Children.Add($script:BdoTimeFormat24RadioButton) | Out-Null

    $script:BdoTimeFormat12RadioButton = New-Object System.Windows.Controls.RadioButton
    $script:BdoTimeFormat12RadioButton.Content = "AM/PM"
    $script:BdoTimeFormat12RadioButton.GroupName = "BdoTimeFormat"
    $script:BdoTimeFormat12RadioButton.IsChecked = ($script:BdoTimeFormat -eq "12")
    $script:BdoTimeFormat12RadioButton.Add_Checked({ Set-BdoTimeFormat "12" })
    $bdoTimeFormatPanel.Children.Add($script:BdoTimeFormat12RadioButton) | Out-Null

    $script:BdoOptionsPanel.Children.Add($bdoTimeFormatPanel) | Out-Null

    $bdoFontLabel = New-Object System.Windows.Controls.TextBlock
    $bdoFontLabel.Text = "검은사막 글자 크기"
    $script:BdoOptionsPanel.Children.Add($bdoFontLabel) | Out-Null

    $script:BdoFontSizeSlider = New-Object System.Windows.Controls.Slider
    $script:BdoFontSizeSlider.Minimum = 8
    $script:BdoFontSizeSlider.Maximum = 48
    $script:BdoFontSizeSlider.Value = [double]$script:BdoFontSize
    $script:BdoFontSizeSlider.TickFrequency = 2
    $script:BdoFontSizeSlider.IsSnapToTickEnabled = $true
    $script:BdoFontSizeSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BdoFontSize ([int]$sender.Value)
    })
    $script:BdoFontSizeValueText = New-Object System.Windows.Controls.TextBlock
    $script:BdoFontSizeValueText.Text = [string]$script:BdoFontSize
    $script:BdoOptionsPanel.Children.Add((New-SliderRow $script:BdoFontSizeSlider $script:BdoFontSizeValueText)) | Out-Null

    $bdoOffsetRow = New-Object System.Windows.Controls.DockPanel
    $bdoOffsetRow.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $bdoOffsetLabel = New-Object System.Windows.Controls.TextBlock
    $bdoOffsetLabel.Text = "검은사막 시간 보정(초)"
    $bdoOffsetLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.DockPanel]::SetDock($bdoOffsetLabel, [System.Windows.Controls.Dock]::Left)
    $bdoOffsetRow.Children.Add($bdoOffsetLabel) | Out-Null

    $bdoOffsetHint = New-Object System.Windows.Controls.TextBlock
    $bdoOffsetHint.Text = "-180 ~ 180"
    $bdoOffsetHint.Margin = New-Object System.Windows.Thickness 8, 0, 0, 0
    $bdoOffsetHint.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.DockPanel]::SetDock($bdoOffsetHint, [System.Windows.Controls.Dock]::Right)
    $bdoOffsetRow.Children.Add($bdoOffsetHint) | Out-Null

    $script:BdoTimeOffsetTextBox = New-Object System.Windows.Controls.TextBox
    $script:BdoTimeOffsetTextBox.Width = 64
    $script:BdoTimeOffsetTextBox.Text = [string]$script:BdoTimeOffsetSeconds
    $script:BdoTimeOffsetTextBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
    $script:BdoTimeOffsetTextBox.Add_LostFocus({ Apply-BdoTimeOffsetInput })
    $script:BdoTimeOffsetTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BdoTimeOffsetInput
            $eventArgs.Handled = $true
        }
    })
    [System.Windows.Controls.DockPanel]::SetDock($script:BdoTimeOffsetTextBox, [System.Windows.Controls.Dock]::Right)
    $bdoOffsetRow.Children.Add($script:BdoTimeOffsetTextBox) | Out-Null
    $script:BdoOptionsPanel.Children.Add($bdoOffsetRow) | Out-Null

    $bdoOffsetTip = New-Object System.Windows.Controls.TextBlock
    $bdoOffsetTip.Text = "팁: 위젯 시간이 실제 게임보다 느리면 +, 빠르면 -"
    $bdoOffsetTip.FontSize = 11
    $bdoOffsetTip.Opacity = 0.75
    $bdoOffsetTip.Margin = New-Object System.Windows.Thickness 0, -4, 0, 8
    $script:BdoOptionsPanel.Children.Add($bdoOffsetTip) | Out-Null

    $bdoFormulaTip = New-Object System.Windows.Controls.TextBlock
    $bdoFormulaTip.Text = "계산 기준: 낮 07~22시는 4.5배, 밤 22~07시는 13.5배, 1일은 현실 4시간"
    $bdoFormulaTip.FontSize = 11
    $bdoFormulaTip.Opacity = 0.75
    $bdoFormulaTip.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $bdoFormulaTip.Margin = New-Object System.Windows.Thickness 0, -6, 0, 8
    $script:BdoOptionsPanel.Children.Add($bdoFormulaTip) | Out-Null

    $script:BdoTransitionCheckBox = New-Object System.Windows.Controls.CheckBox
    $script:BdoTransitionCheckBox.Content = "낮/밤 전환 남은 시간 표시"
    $script:BdoTransitionCheckBox.IsChecked = [bool]$script:BdoTransitionEnabled
    $script:BdoTransitionCheckBox.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8
    $script:BdoTransitionCheckBox.Add_Click({
        param($sender, $eventArgs)
        Set-BdoTransitionEnabled ([bool]$sender.IsChecked)
    })
    $script:BdoOptionsPanel.Children.Add($script:BdoTransitionCheckBox) | Out-Null

    $script:BdoTransitionOptionsPanel = New-Object System.Windows.Controls.StackPanel
    $script:BdoTransitionOptionsPanel.Margin = New-Object System.Windows.Thickness 18, -2, 0, 10

    $bdoTransitionFontLabel = New-Object System.Windows.Controls.TextBlock
    $bdoTransitionFontLabel.Text = "전환 시간 글자 크기"
    $script:BdoTransitionOptionsPanel.Children.Add($bdoTransitionFontLabel) | Out-Null

    $script:BdoTransitionFontSizeSlider = New-Object System.Windows.Controls.Slider
    $script:BdoTransitionFontSizeSlider.Minimum = 8
    $script:BdoTransitionFontSizeSlider.Maximum = 48
    $script:BdoTransitionFontSizeSlider.Value = [double]$script:BdoTransitionFontSize
    $script:BdoTransitionFontSizeSlider.TickFrequency = 2
    $script:BdoTransitionFontSizeSlider.IsSnapToTickEnabled = $true
    $script:BdoTransitionFontSizeSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BdoTransitionFontSize ([int]$sender.Value)
    })
    $script:BdoTransitionFontSizeValueText = New-Object System.Windows.Controls.TextBlock
    $script:BdoTransitionFontSizeValueText.Text = [string]$script:BdoTransitionFontSize
    $script:BdoTransitionOptionsPanel.Children.Add((New-SliderRow $script:BdoTransitionFontSizeSlider $script:BdoTransitionFontSizeValueText)) | Out-Null

    $script:BdoTransitionTextColorText = New-Object System.Windows.Controls.TextBox
    $script:BdoTransitionTextColorText.Text = $script:BdoTransitionTextColor
    $script:BdoTransitionOptionsPanel.Children.Add((New-SettingsRow "전환 시간 채움색" (New-ColorValueControl $script:BdoTransitionTextColorText $script:BdoTransitionTextColor "BdoTransitionTextColorSwatch" "BdoTransitionTextColor" { Show-BdoTransitionTextColorDialog } "BdoTransitionTextColorTransparent" "BdoTransitionTextColorTransparentCheckBox"))) | Out-Null

    $script:BdoTransitionTextOutlineColorText = New-Object System.Windows.Controls.TextBox
    $script:BdoTransitionTextOutlineColorText.Text = $script:BdoTransitionTextOutlineColor
    $script:BdoTransitionOptionsPanel.Children.Add((New-SettingsRow "전환 시간 테두리색" (New-ColorValueControl $script:BdoTransitionTextOutlineColorText $script:BdoTransitionTextOutlineColor "BdoTransitionTextOutlineColorSwatch" "BdoTransitionTextOutlineColor" { Show-BdoTransitionTextOutlineColorDialog } "BdoTransitionTextOutlineColorTransparent" "BdoTransitionTextOutlineColorTransparentCheckBox"))) | Out-Null

    $script:BdoTransitionFontFamilyText = New-Object System.Windows.Controls.TextBlock
    Set-FontValueText $script:BdoTransitionFontFamilyText $script:BdoTransitionFontFamily
    $script:BdoTransitionOptionsPanel.Children.Add((New-SettingsRow "전환 시간 글꼴" $script:BdoTransitionFontFamilyText { Show-BdoTransitionFontDialog })) | Out-Null

    $script:BdoTransitionOptionsPanel.Visibility = if ($script:BdoTransitionEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $script:BdoOptionsPanel.Children.Add($script:BdoTransitionOptionsPanel) | Out-Null

    $script:BdoTextColorText = New-Object System.Windows.Controls.TextBox
    $script:BdoTextColorText.Text = $script:BdoTextColor
    $script:BdoOptionsPanel.Children.Add((New-SettingsRow "검은사막 채움색" (New-ColorValueControl $script:BdoTextColorText $script:BdoTextColor "BdoTextColorSwatch" "BdoTextColor" { Show-BdoTextColorDialog } "BdoTextColorTransparent" "BdoTextColorTransparentCheckBox"))) | Out-Null

    $script:BdoTextOutlineColorText = New-Object System.Windows.Controls.TextBox
    $script:BdoTextOutlineColorText.Text = $script:BdoTextOutlineColor
    $script:BdoOptionsPanel.Children.Add((New-SettingsRow "검은사막 테두리색" (New-ColorValueControl $script:BdoTextOutlineColorText $script:BdoTextOutlineColor "BdoTextOutlineColorSwatch" "BdoTextOutlineColor" { Show-BdoTextOutlineColorDialog } "BdoTextOutlineColorTransparent" "BdoTextOutlineColorTransparentCheckBox"))) | Out-Null

    $script:BdoFontFamilyText = New-Object System.Windows.Controls.TextBlock
    Set-FontValueText $script:BdoFontFamilyText $script:BdoFontFamily
    $script:BdoOptionsPanel.Children.Add((New-SettingsRow "검은사막 글꼴" $script:BdoFontFamilyText { Show-BdoFontDialog })) | Out-Null

    $script:BdoOptionsExpander = New-SettingsExpander "검은사막 상세 설정" $script:BdoOptionsPanel ([bool]$script:BdoTimeEnabled)
    $panel.Children.Add($script:BdoOptionsExpander) | Out-Null

    $script:BossAlertCheckBox = New-Object System.Windows.Controls.CheckBox
    $script:BossAlertCheckBox.Content = "보스 등장 알림 표시"
    $script:BossAlertCheckBox.IsChecked = [bool]$script:BossAlertEnabled
    $script:BossAlertCheckBox.Margin = New-Object System.Windows.Thickness 0, 0, 0, 14
    $script:BossAlertCheckBox.Add_Click({
        param($sender, $eventArgs)
        Set-BossAlertEnabled ([bool]$sender.IsChecked)
    })
    $panel.Children.Add($script:BossAlertCheckBox) | Out-Null

    $script:BossOptionsPanel = New-Object System.Windows.Controls.StackPanel
    $script:BossOptionsPanel.Margin = New-Object System.Windows.Thickness 10, 8, 0, 0

    $bossFontLabel = New-Object System.Windows.Controls.TextBlock
    $bossFontLabel.Text = "보스 알림 글자 크기"
    $script:BossOptionsPanel.Children.Add($bossFontLabel) | Out-Null

    $script:BossFontSizeSlider = New-Object System.Windows.Controls.Slider
    $script:BossFontSizeSlider.Minimum = 8
    $script:BossFontSizeSlider.Maximum = 48
    $script:BossFontSizeSlider.Value = [double]$script:BossFontSize
    $script:BossFontSizeSlider.TickFrequency = 2
    $script:BossFontSizeSlider.IsSnapToTickEnabled = $true
    $script:BossFontSizeSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BossFontSize ([int]$sender.Value)
    })
    $script:BossFontSizeValueText = New-Object System.Windows.Controls.TextBlock
    $script:BossFontSizeValueText.Text = [string]$script:BossFontSize
    $script:BossOptionsPanel.Children.Add((New-SliderRow $script:BossFontSizeSlider $script:BossFontSizeValueText)) | Out-Null

    $script:BossBeforeMinutesTextBox = New-Object System.Windows.Controls.TextBox
    $script:BossBeforeSecondsTextBox = New-Object System.Windows.Controls.TextBox
    Set-BossAlertTimeInputControls "Before" $script:BossAlertBeforeSeconds
    $script:BossBeforeMinutesTextBox.Add_LostFocus({ Apply-BossAlertBeforeInput })
    $script:BossBeforeSecondsTextBox.Add_LostFocus({ Apply-BossAlertBeforeInput })
    $script:BossBeforeMinutesTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BossAlertBeforeInput
            $eventArgs.Handled = $true
        }
    })
    $script:BossBeforeSecondsTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BossAlertBeforeInput
            $eventArgs.Handled = $true
        }
    })
    $script:BossOptionsPanel.Children.Add((New-BossAlertTimeInputRow "표시 시작" $script:BossBeforeMinutesTextBox $script:BossBeforeSecondsTextBox "전")) | Out-Null

    $script:BossAfterMinutesTextBox = New-Object System.Windows.Controls.TextBox
    $script:BossAfterSecondsTextBox = New-Object System.Windows.Controls.TextBox
    Set-BossAlertTimeInputControls "After" $script:BossAlertAfterSeconds
    $script:BossAfterMinutesTextBox.Add_LostFocus({ Apply-BossAlertAfterInput })
    $script:BossAfterSecondsTextBox.Add_LostFocus({ Apply-BossAlertAfterInput })
    $script:BossAfterMinutesTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BossAlertAfterInput
            $eventArgs.Handled = $true
        }
    })
    $script:BossAfterSecondsTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BossAlertAfterInput
            $eventArgs.Handled = $true
        }
    })
    $script:BossOptionsPanel.Children.Add((New-BossAlertTimeInputRow "표시 종료" $script:BossAfterMinutesTextBox $script:BossAfterSecondsTextBox "후")) | Out-Null

    $script:BossHighlightAnimationTextBox = New-Object System.Windows.Controls.TextBox
    $script:BossHighlightAnimationTextBox.Width = 64
    $script:BossHighlightAnimationTextBox.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Right
    $script:BossHighlightAnimationTextBox.Text = $script:BossHighlightAnimationSeconds.ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture)
    $script:BossHighlightAnimationTextBox.Add_LostFocus({ Apply-BossHighlightAnimationInput })
    $script:BossHighlightAnimationTextBox.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Enter) {
            Apply-BossHighlightAnimationInput
            $eventArgs.Handled = $true
        }
    })
    $script:BossOptionsPanel.Children.Add((New-SettingsRow "강조 알림 애니메이션 속도" $script:BossHighlightAnimationTextBox)) | Out-Null

    $script:BossHighlightColorText = New-Object System.Windows.Controls.TextBox
    $script:BossHighlightColorText.Text = $script:BossHighlightColor
    $script:BossOptionsPanel.Children.Add((New-SettingsRow "강조 알림 표시 색상" (New-ColorValueControl $script:BossHighlightColorText $script:BossHighlightColor "BossHighlightColorSwatch" "BossHighlightColor" { Show-BossHighlightColorDialog }))) | Out-Null

    $bossRowsLabel = New-Object System.Windows.Controls.TextBlock
    $bossRowsLabel.Text = "보스 행 설정"
    $bossRowsLabel.Margin = New-Object System.Windows.Thickness 0, 2, 0, 4
    $script:BossOptionsPanel.Children.Add($bossRowsLabel) | Out-Null

    $script:BossRowsPanel = New-Object System.Windows.Controls.StackPanel
    $script:BossRowsPanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 10
    $script:BossOptionsPanel.Children.Add($script:BossRowsPanel) | Out-Null
    Refresh-BossRowsEditor

    $bossTopMarginLabel = New-Object System.Windows.Controls.TextBlock
    $bossTopMarginLabel.Text = "보스 알림 상단 여백"
    $script:BossOptionsPanel.Children.Add($bossTopMarginLabel) | Out-Null

    $script:BossMarginTopSlider = New-Object System.Windows.Controls.Slider
    $script:BossMarginTopSlider.Minimum = 0
    $script:BossMarginTopSlider.Maximum = 40
    $script:BossMarginTopSlider.Value = [double]$script:BossMarginTop
    $script:BossMarginTopSlider.TickFrequency = 2
    $script:BossMarginTopSlider.IsSnapToTickEnabled = $true
    $script:BossMarginTopSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BossMarginTop ([int]$sender.Value)
    })
    $script:BossMarginTopValueText = New-Object System.Windows.Controls.TextBlock
    $script:BossMarginTopValueText.Text = [string]$script:BossMarginTop
    $script:BossOptionsPanel.Children.Add((New-SliderRow $script:BossMarginTopSlider $script:BossMarginTopValueText)) | Out-Null

    $bossBottomMarginLabel = New-Object System.Windows.Controls.TextBlock
    $bossBottomMarginLabel.Text = "보스 알림 하단 간격"
    $script:BossOptionsPanel.Children.Add($bossBottomMarginLabel) | Out-Null

    $script:BossMarginBottomSlider = New-Object System.Windows.Controls.Slider
    $script:BossMarginBottomSlider.Minimum = 0
    $script:BossMarginBottomSlider.Maximum = 40
    $script:BossMarginBottomSlider.Value = [double]$script:BossMarginBottom
    $script:BossMarginBottomSlider.TickFrequency = 2
    $script:BossMarginBottomSlider.IsSnapToTickEnabled = $true
    $script:BossMarginBottomSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BossMarginBottom ([int]$sender.Value)
    })
    $script:BossMarginBottomValueText = New-Object System.Windows.Controls.TextBlock
    $script:BossMarginBottomValueText.Text = [string]$script:BossMarginBottom
    $script:BossOptionsPanel.Children.Add((New-SliderRow $script:BossMarginBottomSlider $script:BossMarginBottomValueText)) | Out-Null

    $script:BossTextColorText = New-Object System.Windows.Controls.TextBox
    $script:BossTextColorText.Text = $script:BossTextColor
    $script:BossOptionsPanel.Children.Add((New-SettingsRow "보스 알림 채움색" (New-ColorValueControl $script:BossTextColorText $script:BossTextColor "BossTextColorSwatch" "BossTextColor" { Show-BossTextColorDialog } "BossTextColorTransparent" "BossTextColorTransparentCheckBox"))) | Out-Null

    $script:BossTextOutlineColorText = New-Object System.Windows.Controls.TextBox
    $script:BossTextOutlineColorText.Text = $script:BossTextOutlineColor
    $script:BossOptionsPanel.Children.Add((New-SettingsRow "보스 알림 테두리색" (New-ColorValueControl $script:BossTextOutlineColorText $script:BossTextOutlineColor "BossTextOutlineColorSwatch" "BossTextOutlineColor" { Show-BossTextOutlineColorDialog } "BossTextOutlineColorTransparent" "BossTextOutlineColorTransparentCheckBox"))) | Out-Null

    $script:BossFontFamilyText = New-Object System.Windows.Controls.TextBlock
    Set-FontValueText $script:BossFontFamilyText $script:BossFontFamily
    $script:BossOptionsPanel.Children.Add((New-SettingsRow "보스 알림 글꼴" $script:BossFontFamilyText { Show-BossFontDialog })) | Out-Null

    $script:BossOptionsExpander = New-SettingsExpander "보스 알림 상세 설정" $script:BossOptionsPanel ([bool]$script:BossAlertEnabled)
    $panel.Children.Add($script:BossOptionsExpander) | Out-Null

    $timeFormatLabel = New-Object System.Windows.Controls.TextBlock
    $timeFormatLabel.Text = "시간 표시"
    $timeFormatLabel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 4
    $panel.Children.Add($timeFormatLabel) | Out-Null

    $timeFormatPanel = New-Object System.Windows.Controls.StackPanel
    $timeFormatPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $timeFormatPanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $script:TimeFormat24RadioButton = New-Object System.Windows.Controls.RadioButton
    $script:TimeFormat24RadioButton.Content = "24시간"
    $script:TimeFormat24RadioButton.GroupName = "TimeFormat"
    $script:TimeFormat24RadioButton.Margin = New-Object System.Windows.Thickness 0, 0, 18, 0
    $script:TimeFormat24RadioButton.IsChecked = ($script:TimeFormat -ne "12")
    $script:TimeFormat24RadioButton.Add_Checked({ Set-TimeFormat "24" })
    $timeFormatPanel.Children.Add($script:TimeFormat24RadioButton) | Out-Null

    $script:TimeFormat12RadioButton = New-Object System.Windows.Controls.RadioButton
    $script:TimeFormat12RadioButton.Content = "AM/PM"
    $script:TimeFormat12RadioButton.GroupName = "TimeFormat"
    $script:TimeFormat12RadioButton.IsChecked = ($script:TimeFormat -eq "12")
    $script:TimeFormat12RadioButton.Add_Checked({ Set-TimeFormat "12" })
    $timeFormatPanel.Children.Add($script:TimeFormat12RadioButton) | Out-Null
    $panel.Children.Add($timeFormatPanel) | Out-Null

    $script:MeridiemLanguagePanel = New-Object System.Windows.Controls.StackPanel
    $script:MeridiemLanguagePanel.Margin = New-Object System.Windows.Thickness 18, 0, 0, 14

    $meridiemLabel = New-Object System.Windows.Controls.TextBlock
    $meridiemLabel.Text = "언어 선택"
    $meridiemLabel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 4
    $script:MeridiemLanguagePanel.Children.Add($meridiemLabel) | Out-Null

    $meridiemRadioPanel = New-Object System.Windows.Controls.StackPanel
    $meridiemRadioPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    $script:MeridiemEnglishRadioButton = New-Object System.Windows.Controls.RadioButton
    $script:MeridiemEnglishRadioButton.Content = "English AM/PM"
    $script:MeridiemEnglishRadioButton.GroupName = "MeridiemLanguage"
    $script:MeridiemEnglishRadioButton.Margin = New-Object System.Windows.Thickness 0, 0, 18, 0
    $script:MeridiemEnglishRadioButton.IsChecked = ($script:MeridiemLanguage -ne "ko")
    $script:MeridiemEnglishRadioButton.Add_Checked({ Set-MeridiemLanguage "en" })
    $meridiemRadioPanel.Children.Add($script:MeridiemEnglishRadioButton) | Out-Null

    $script:MeridiemKoreanRadioButton = New-Object System.Windows.Controls.RadioButton
    $script:MeridiemKoreanRadioButton.Content = "한국어 오전/오후"
    $script:MeridiemKoreanRadioButton.GroupName = "MeridiemLanguage"
    $script:MeridiemKoreanRadioButton.IsChecked = ($script:MeridiemLanguage -eq "ko")
    $script:MeridiemKoreanRadioButton.Add_Checked({ Set-MeridiemLanguage "ko" })
    $meridiemRadioPanel.Children.Add($script:MeridiemKoreanRadioButton) | Out-Null
    $script:MeridiemLanguagePanel.Children.Add($meridiemRadioPanel) | Out-Null

    if ($script:TimeFormat -eq "12") {
        $script:MeridiemLanguagePanel.Visibility = [System.Windows.Visibility]::Visible
    }
    else {
        $script:MeridiemLanguagePanel.Visibility = [System.Windows.Visibility]::Collapsed
    }
    $panel.Children.Add($script:MeridiemLanguagePanel) | Out-Null

    $fontLabel = New-Object System.Windows.Controls.TextBlock
    $fontLabel.Text = "글자 크기"
    $panel.Children.Add($fontLabel) | Out-Null

    $script:FontSizeSlider = New-Object System.Windows.Controls.Slider
    $script:FontSizeSlider.Minimum = 12
    $script:FontSizeSlider.Maximum = 96
    $script:FontSizeSlider.Value = [double]$script:FontSize
    $script:FontSizeSlider.TickFrequency = 4
    $script:FontSizeSlider.IsSnapToTickEnabled = $true
    $script:FontSizeSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-WidgetFontSize ([int]$sender.Value)
    })
    $script:FontSizeValueText = New-Object System.Windows.Controls.TextBlock
    $script:FontSizeValueText.Text = [string]$script:FontSize
    $panel.Children.Add((New-SliderRow $script:FontSizeSlider $script:FontSizeValueText)) | Out-Null

    $opacityLabel = New-Object System.Windows.Controls.TextBlock
    $opacityLabel.Text = "배경 진하기"
    $panel.Children.Add($opacityLabel) | Out-Null

    $opacitySlider = New-Object System.Windows.Controls.Slider
    $opacitySlider.Minimum = 0
    $opacitySlider.Maximum = 100
    $opacitySlider.Value = [double]($script:BackgroundOpacity * 100)
    $opacitySlider.TickFrequency = 5
    $opacitySlider.IsSnapToTickEnabled = $true
    $opacitySlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BackgroundOpacity ($sender.Value / 100)
    })
    $script:BackgroundOpacityValueText = New-Object System.Windows.Controls.TextBlock
    $script:BackgroundOpacityValueText.Text = [string]([int][Math]::Round($script:BackgroundOpacity * 100))
    $panel.Children.Add((New-SliderRow $opacitySlider $script:BackgroundOpacityValueText)) | Out-Null

    $script:BackgroundColorText = New-Object System.Windows.Controls.TextBox
    $script:BackgroundColorText.Text = $script:BackgroundColor
    $panel.Children.Add((New-SettingsRow "배경 색상" (New-ColorValueControl $script:BackgroundColorText $script:BackgroundColor "BackgroundColorSwatch" "BackgroundColor" { Show-BackgroundColorDialog }))) | Out-Null

    $script:TextColorText = New-Object System.Windows.Controls.TextBox
    $script:TextColorText.Text = $script:TextColor
    $panel.Children.Add((New-SettingsRow "글자 채움색" (New-ColorValueControl $script:TextColorText $script:TextColor "TextColorSwatch" "TextColor" { Show-TextColorDialog } "TextColorTransparent" "TextColorTransparentCheckBox"))) | Out-Null

    $script:TextOutlineColorText = New-Object System.Windows.Controls.TextBox
    $script:TextOutlineColorText.Text = $script:TextOutlineColor
    $panel.Children.Add((New-SettingsRow "글자 테두리색" (New-ColorValueControl $script:TextOutlineColorText $script:TextOutlineColor "TextOutlineColorSwatch" "TextOutlineColor" { Show-TextOutlineColorDialog } "TextOutlineColorTransparent" "TextOutlineColorTransparentCheckBox"))) | Out-Null

    $script:FontFamilyText = New-Object System.Windows.Controls.TextBlock
    Set-FontValueText $script:FontFamilyText $script:FontFamily
    $panel.Children.Add((New-SettingsRow "글꼴" $script:FontFamilyText { Show-FontDialog })) | Out-Null

    $script:TrayIconPathText = New-Object System.Windows.Controls.TextBlock
    $script:TrayIconPathText.Text = [System.IO.Path]::GetFileName((Get-EffectiveTrayIconPath))
    $panel.Children.Add((New-SettingsRow "트레이 아이콘" $script:TrayIconPathText { Show-TrayIconDialog })) | Out-Null

    $trayPreviewRow = New-Object System.Windows.Controls.DockPanel
    $trayPreviewRow.Margin = New-Object System.Windows.Thickness 0, 0, 0, 8

    $trayPreviewLabel = New-Object System.Windows.Controls.TextBlock
    $trayPreviewLabel.Text = "아이콘 미리보기"
    $trayPreviewLabel.Width = 86
    $trayPreviewLabel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.DockPanel]::SetDock($trayPreviewLabel, [System.Windows.Controls.Dock]::Left)
    $trayPreviewRow.Children.Add($trayPreviewLabel) | Out-Null

    $script:TrayIconPreviewImage = New-Object System.Windows.Controls.Image
    $script:TrayIconPreviewImage.Width = 32
    $script:TrayIconPreviewImage.Height = 32
    $script:TrayIconPreviewImage.Stretch = [System.Windows.Media.Stretch]::Uniform
    $trayPreviewRow.Children.Add($script:TrayIconPreviewImage) | Out-Null
    $panel.Children.Add($trayPreviewRow) | Out-Null

    $previewHostPanel = New-Object System.Windows.Controls.StackPanel
    $previewHostPanel.Margin = New-Object System.Windows.Thickness 16, 0, 16, 12
    [System.Windows.Controls.Grid]::SetRow($previewHostPanel, 2)
    $settingsRoot.Children.Add($previewHostPanel) | Out-Null

    $previewLabel = New-Object System.Windows.Controls.TextBlock
    $previewLabel.Text = "프리뷰"
    $previewLabel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 4
    $previewHostPanel.Children.Add($previewLabel) | Out-Null

    $script:ColorPreviewBackground = New-Object System.Windows.Controls.Border
    $script:ColorPreviewBackground.MinHeight = 82
    $script:ColorPreviewBackground.CornerRadius = New-Object System.Windows.CornerRadius 4
    $script:ColorPreviewBackground.Padding = New-Object System.Windows.Thickness 10, 8, 10, 8
    $script:ColorPreviewBackground.Margin = New-Object System.Windows.Thickness 0

    $previewStack = New-Object System.Windows.Controls.StackPanel
    $previewStack.Orientation = [System.Windows.Controls.Orientation]::Vertical
    $previewStack.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $previewStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

    $script:BdoPreviewPanel = New-Object System.Windows.Controls.StackPanel
    $script:BdoPreviewPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $script:BdoPreviewPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BdoPreviewPanel.Margin = New-Object System.Windows.Thickness 0, 0, 0, 2

    $script:BdoPreviewImage = New-Object System.Windows.Controls.Image
    $script:BdoPreviewImage.Width = 18
    $script:BdoPreviewImage.Height = 18
    $script:BdoPreviewImage.Stretch = [System.Windows.Media.Stretch]::Uniform
    $script:BdoPreviewImage.Margin = New-Object System.Windows.Thickness 0, 0, 4, 0
    $script:BdoPreviewPanel.Children.Add($script:BdoPreviewImage) | Out-Null

    $script:BdoPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:BdoPreviewText.Text = "09:34"
    $script:BdoPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:BdoPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $script:BdoPreviewPanel.Children.Add($script:BdoPreviewText) | Out-Null

    $script:BdoTransitionPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:BdoTransitionPreviewText.Text = "(밤까지 12분)"
    $script:BdoTransitionPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:BdoTransitionPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoTransitionPreviewText.Margin = New-Object System.Windows.Thickness 6, 0, 0, 0
    $script:BdoTransitionPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $script:BdoPreviewPanel.Children.Add($script:BdoTransitionPreviewText) | Out-Null
    $previewStack.Children.Add($script:BdoPreviewPanel) | Out-Null

    $script:BossPreviewBorder = New-Object System.Windows.Controls.Border
    $script:BossPreviewBorder.CornerRadius = New-Object System.Windows.CornerRadius 3
    $script:BossPreviewBorder.Padding = New-Object System.Windows.Thickness 4, 1, 4, 1
    $script:BossPreviewBorder.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center

    $script:BossPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:BossPreviewText.Text = "[가모스] 등장 45분 전"
    $script:BossPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:BossPreviewText.TextAlignment = [System.Windows.TextAlignment]::Center
    $script:BossPreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BossPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $script:BossPreviewBorder.Child = $script:BossPreviewText
    $previewStack.Children.Add($script:BossPreviewBorder) | Out-Null

    $script:ColorPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:ColorPreviewText.Text = "12:34:56"
    $script:ColorPreviewText.FontSize = 22
    $script:ColorPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:ColorPreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:ColorPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:ColorPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $previewStack.Children.Add($script:ColorPreviewText) | Out-Null
    $script:ColorPreviewBackground.Child = $previewStack
    $previewHostPanel.Children.Add($script:ColorPreviewBackground) | Out-Null

    $buttonPanel = New-Object System.Windows.Controls.StackPanel
    $buttonPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $buttonPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right
    $buttonPanel.Margin = New-Object System.Windows.Thickness 16, 8, 16, 8

    $applyButton = New-Object System.Windows.Controls.Button
    $applyButton.Content = "적용"
    $applyButton.Width = 72
    $applyButton.Margin = New-Object System.Windows.Thickness 0, 0, 8, 0
    $applyButton.Add_Click({
        if ($script:SettingsDraft) {
            Apply-PendingSettingsInputs
            Apply-SettingsSnapshot $script:SettingsDraft $false
            $script:SettingsDirty = -not (Test-SettingsSnapshotEqual $script:SettingsDraft $script:SettingsOriginal)
            Request-SettingsPreviewUpdate
        }
    })
    $buttonPanel.Children.Add($applyButton) | Out-Null

    $okButton = New-Object System.Windows.Controls.Button
    $okButton.Content = "확인"
    $okButton.Width = 72
    $okButton.Margin = New-Object System.Windows.Thickness 0, 0, 8, 0
    $okButton.Add_Click({
        if ($script:SettingsDraft) {
            Apply-PendingSettingsInputs
            Apply-SettingsSnapshot $script:SettingsDraft $true
            $script:SettingsOriginal = Copy-SettingsSnapshot $script:SettingsDraft
            $script:SettingsDirty = $false
        }
        $script:SettingsCloseAction = "ok"
        $script:SettingsWindow.Close()
    })
    $buttonPanel.Children.Add($okButton) | Out-Null

    $cancelButton = New-Object System.Windows.Controls.Button
    $cancelButton.Content = "취소"
    $cancelButton.Width = 72
    $cancelButton.Add_Click({
        if ($script:SettingsOriginal) {
            Apply-SettingsSnapshot $script:SettingsOriginal $false
        }
        $script:SettingsCloseAction = "cancel"
        $script:SettingsWindow.Close()
    })
    $buttonPanel.Children.Add($cancelButton) | Out-Null
    [System.Windows.Controls.Grid]::SetRow($buttonPanel, 1)
    $settingsRoot.Children.Add($buttonPanel) | Out-Null

    Update-TrayIconPreview
    Sync-SettingsControlsFromDraft

    $settings.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.Key -eq [System.Windows.Input.Key]::Escape) {
            $sender.Close()
            $eventArgs.Handled = $true
        }
    })

    $settings.Add_Closing({
        param($sender, $eventArgs)

        if ($script:SettingsCloseAction -eq "ok" -or $script:SettingsCloseAction -eq "cancel") {
            return
        }

        if ($script:SettingsDirty) {
            $answer = [System.Windows.MessageBox]::Show(
                "저장하지 않은 설정 변경이 있습니다. 닫으면 이번에 바꾼 내용이 취소됩니다. 그래도 닫을까요?",
                "설정 닫기",
                [System.Windows.MessageBoxButton]::YesNo,
                [System.Windows.MessageBoxImage]::Warning
            )
            if ($answer -ne [System.Windows.MessageBoxResult]::Yes) {
                $eventArgs.Cancel = $true
                return
            }
        }

        if ($script:SettingsOriginal) {
            Apply-SettingsSnapshot $script:SettingsOriginal $false
        }
        $script:SettingsCloseAction = "discard"
    })

    $settings.Add_Closed({
        $script:StartupCheckBox = $null
        $script:BdoTimeCheckBox = $null
        $script:BdoOptionsExpander = $null
        $script:BdoOptionsPanel = $null
        $script:BdoIconEnabledCheckBox = $null
        $script:BdoIconChoicePanel = $null
        $script:BdoBlackSpiritRadioButton = $null
        $script:BdoPapuRadioButton = $null
        $script:BdoTimeFormat24RadioButton = $null
        $script:BdoTimeFormat12RadioButton = $null
        $script:BdoFontSizeSlider = $null
        $script:BdoFontSizeValueText = $null
        $script:BdoTimeOffsetTextBox = $null
        $script:BdoTextColorText = $null
        $script:BdoTextColorSwatch = $null
        $script:BdoTextColorTransparentCheckBox = $null
        $script:BdoTextOutlineColorText = $null
        $script:BdoTextOutlineColorSwatch = $null
        $script:BdoTextOutlineColorTransparentCheckBox = $null
        $script:BdoFontFamilyText = $null
        $script:BdoTransitionCheckBox = $null
        $script:BdoTransitionOptionsPanel = $null
        $script:BdoTransitionFontSizeSlider = $null
        $script:BdoTransitionFontSizeValueText = $null
        $script:BdoTransitionTextColorText = $null
        $script:BdoTransitionTextColorSwatch = $null
        $script:BdoTransitionTextColorTransparentCheckBox = $null
        $script:BdoTransitionTextOutlineColorText = $null
        $script:BdoTransitionTextOutlineColorSwatch = $null
        $script:BdoTransitionTextOutlineColorTransparentCheckBox = $null
        $script:BdoTransitionFontFamilyText = $null
        $script:BossAlertCheckBox = $null
        $script:BossOptionsExpander = $null
        $script:BossOptionsPanel = $null
        $script:BossFontSizeSlider = $null
        $script:BossFontSizeValueText = $null
        $script:BossBeforeMinutesTextBox = $null
        $script:BossBeforeSecondsTextBox = $null
        $script:BossAfterMinutesTextBox = $null
        $script:BossAfterSecondsTextBox = $null
        $script:BossHighlightAnimationTextBox = $null
        $script:BossHighlightColorText = $null
        $script:BossHighlightColorSwatch = $null
        $script:BossRowsPanel = $null
        $script:BossMarginTopSlider = $null
        $script:BossMarginTopValueText = $null
        $script:BossMarginBottomSlider = $null
        $script:BossMarginBottomValueText = $null
        $script:BossTextColorText = $null
        $script:BossTextColorSwatch = $null
        $script:BossTextColorTransparentCheckBox = $null
        $script:BossTextOutlineColorText = $null
        $script:BossTextOutlineColorSwatch = $null
        $script:BossTextOutlineColorTransparentCheckBox = $null
        $script:BossFontFamilyText = $null
        $script:TimeFormat24RadioButton = $null
        $script:TimeFormat12RadioButton = $null
        $script:MeridiemLanguagePanel = $null
        $script:MeridiemEnglishRadioButton = $null
        $script:MeridiemKoreanRadioButton = $null
        $script:FontSizeSlider = $null
        $script:FontSizeValueText = $null
        $script:BackgroundOpacityValueText = $null
        $script:BackgroundColorText = $null
        $script:BackgroundColorSwatch = $null
        $script:TextColorText = $null
        $script:TextColorSwatch = $null
        $script:TextColorTransparentCheckBox = $null
        $script:TextOutlineColorText = $null
        $script:TextOutlineColorSwatch = $null
        $script:TextOutlineColorTransparentCheckBox = $null
        $script:FontFamilyText = $null
        $script:TrayIconPathText = $null
        $script:TrayIconPreviewImage = $null
        $script:ColorPreviewBackground = $null
        $script:ColorPreviewText = $null
        $script:BdoPreviewPanel = $null
        $script:BdoPreviewImage = $null
        $script:BdoPreviewText = $null
        $script:BdoTransitionPreviewText = $null
        $script:BossPreviewBorder = $null
        $script:BossPreviewText = $null
        $script:SettingsOriginal = $null
        $script:SettingsDraft = $null
        $script:SettingsDirty = $false
        $script:SettingsCloseAction = $null
        $script:SyncingSettingsControls = $false
    })

    $settings.Show() | Out-Null
}

$config = Read-WidgetConfig
$script:FontSize = [int]$config.FontSize
$script:BackgroundOpacity = [double]$config.BackgroundOpacity
$script:BackgroundColor = [string]$config.BackgroundColor
$script:TextColor = [string]$config.TextColor
$script:TextColorTransparent = [bool]$config.TextColorTransparent
$script:TextOutlineColor = [string]$config.TextOutlineColor
$script:TextOutlineColorTransparent = [bool]$config.TextOutlineColorTransparent
$script:FontFamily = [string]$config.FontFamily
$script:TrayIconPath = [string]$config.TrayIconPath
$script:TimeFormat = [string]$config.TimeFormat
$script:MeridiemLanguage = [string]$config.MeridiemLanguage
$script:BdoTimeEnabled = [bool]$config.BdoTimeEnabled
$script:BdoTimeFormat = [string]$config.BdoTimeFormat
$script:BdoIconType = [string]$config.BdoIconType
$script:BdoIconEnabled = [bool]$config.BdoIconEnabled
$script:BdoFontSize = [int]$config.BdoFontSize
$script:BdoTimeOffsetSeconds = [int]$config.BdoTimeOffsetSeconds
$script:BdoTextColor = [string]$config.BdoTextColor
$script:BdoTextColorTransparent = [bool]$config.BdoTextColorTransparent
$script:BdoTextOutlineColor = [string]$config.BdoTextOutlineColor
$script:BdoTextOutlineColorTransparent = [bool]$config.BdoTextOutlineColorTransparent
$script:BdoFontFamily = [string]$config.BdoFontFamily
$script:BdoTransitionEnabled = [bool]$config.BdoTransitionEnabled
$script:BdoTransitionFontSize = [int]$config.BdoTransitionFontSize
$script:BdoTransitionTextColor = [string]$config.BdoTransitionTextColor
$script:BdoTransitionTextColorTransparent = [bool]$config.BdoTransitionTextColorTransparent
$script:BdoTransitionTextOutlineColor = [string]$config.BdoTransitionTextOutlineColor
$script:BdoTransitionTextOutlineColorTransparent = [bool]$config.BdoTransitionTextOutlineColorTransparent
$script:BdoTransitionFontFamily = [string]$config.BdoTransitionFontFamily
$script:BossAlertEnabled = [bool]$config.BossAlertEnabled
$script:BossFontSize = [int]$config.BossFontSize
$script:BossTextColor = [string]$config.BossTextColor
$script:BossTextColorTransparent = [bool]$config.BossTextColorTransparent
$script:BossTextOutlineColor = [string]$config.BossTextOutlineColor
$script:BossTextOutlineColorTransparent = [bool]$config.BossTextOutlineColorTransparent
$script:BossFontFamily = [string]$config.BossFontFamily
$script:BossAlertBeforeSeconds = [int]$config.BossAlertBeforeSeconds
$script:BossAlertAfterSeconds = [int]$config.BossAlertAfterSeconds
$script:BossMarginTop = [int]$config.BossMarginTop
$script:BossMarginBottom = [int]$config.BossMarginBottom
$script:BossHighlightAnimationSeconds = [double]$config.BossHighlightAnimationSeconds
$script:BossHighlightColor = [string]$config.BossHighlightColor
$script:BossRows = @(Copy-BossRows $config.BossRows)

$script:Window = New-Object System.Windows.Window
$script:Window.Title = "Clock Widget"
$script:Window.WindowStyle = [System.Windows.WindowStyle]::None
$script:Window.AllowsTransparency = $true
$script:Window.Background = [System.Windows.Media.Brushes]::Transparent
$script:Window.Topmost = $true
$script:Window.ShowInTaskbar = $false
$script:Window.ResizeMode = [System.Windows.ResizeMode]::NoResize
$script:Window.SizeToContent = [System.Windows.SizeToContent]::WidthAndHeight
$script:Window.Left = [double]$config.X
$script:Window.Top = [double]$config.Y
$script:Window.Add_SourceInitialized({ Hide-WindowFromAltTab })
$script:Window.Add_Loaded({
    Update-TrayToggleText
    Clamp-WidgetToScreenBounds
})
$script:Window.Add_SizeChanged({ Clamp-WidgetToScreenBounds })

$script:Border = New-Object System.Windows.Controls.Border
$script:Border.Background = [System.Windows.Media.Brushes]::Transparent
$script:Border.Padding = New-Object System.Windows.Thickness 0
$script:Window.Content = $script:Border

$script:WidgetGrid = New-Object System.Windows.Controls.Grid
$script:Border.Child = $script:WidgetGrid

$script:BackgroundLayer = New-Object System.Windows.Shapes.Rectangle
$script:BackgroundLayer.Fill = Get-BackgroundBrush $script:BackgroundOpacity
$script:BackgroundLayer.Opacity = $script:BackgroundOpacity
$script:BackgroundLayer.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
$script:BackgroundLayer.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
$script:WidgetGrid.Children.Add($script:BackgroundLayer) | Out-Null

$script:ContentStack = New-Object System.Windows.Controls.StackPanel
$script:ContentStack.Orientation = [System.Windows.Controls.Orientation]::Vertical
$script:ContentStack.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:ContentStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:WidgetGrid.Children.Add($script:ContentStack) | Out-Null

$script:BdoTimePanel = New-Object System.Windows.Controls.StackPanel
$script:BdoTimePanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
$script:BdoTimePanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:BdoTimePanel.Background = [System.Windows.Media.Brushes]::Transparent
$script:BdoLogoImage = New-Object System.Windows.Controls.Image
$script:BdoLogoImage.Width = 22
$script:BdoLogoImage.Height = 22
$script:BdoLogoImage.Stretch = [System.Windows.Media.Stretch]::Uniform
$script:BdoLogoImage.Margin = New-Object System.Windows.Thickness 0, 0, 5, 0
$script:BdoLogoImage.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:BdoLogoImage.IsHitTestVisible = $false
$script:BdoTimePanel.Children.Add($script:BdoLogoImage) | Out-Null
Update-BdoLogo

$script:BdoTextGrid = New-Object System.Windows.Controls.Grid
$script:BdoTextGrid.Background = [System.Windows.Media.Brushes]::Transparent
$script:BdoTimePanel.Children.Add($script:BdoTextGrid) | Out-Null

$script:BdoOutlineTextBlocks = @()
$bdoOutlineOffsets = @(
    @(-1, -1), @(0, -1), @(1, -1),
    @(-1, 0),           @(1, 0),
    @(-1, 1),  @(0, 1),  @(1, 1)
)
foreach ($offset in $bdoOutlineOffsets) {
    $outlineBlock = New-BdoTextBlock (Get-BdoTextOutlineBrush)
    $outlineBlock.IsHitTestVisible = $false
    $entry = [pscustomobject]@{
        Block = $outlineBlock
        X = [double]$offset[0]
        Y = [double]$offset[1]
    }
    $script:BdoOutlineTextBlocks += $entry
    $script:BdoTextGrid.Children.Add($outlineBlock) | Out-Null
}

$script:BdoTimeTextBlock = New-BdoTextBlock (Get-BdoTextBrush)
$script:BdoTextGrid.Children.Add($script:BdoTimeTextBlock) | Out-Null

$script:BdoTransitionTextBlock = New-Object System.Windows.Controls.TextBlock
$script:BdoTransitionTextBlock.Text = ""
$script:BdoTransitionTextBlock.FontWeight = [System.Windows.FontWeights]::Bold
$script:BdoTransitionTextBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:BdoTransitionTextBlock.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:BdoTransitionTextBlock.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
$script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
$script:BdoTimePanel.Children.Add($script:BdoTransitionTextBlock) | Out-Null

$script:ContentStack.Children.Add($script:BdoTimePanel) | Out-Null

$script:BossAlertTextBlock = $null
$script:BossAlertPanel = New-Object System.Windows.Controls.StackPanel
$script:BossAlertPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical
$script:BossAlertPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:BossAlertPanel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:BossAlertPanel.Margin = New-Object System.Windows.Thickness 2, $script:BossMarginTop, 2, $script:BossMarginBottom
$script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Collapsed
$script:ContentStack.Children.Add($script:BossAlertPanel) | Out-Null

$script:ClockTextGrid = New-Object System.Windows.Controls.Grid
$script:ClockTextGrid.Background = [System.Windows.Media.Brushes]::Transparent
$script:ContentStack.Children.Add($script:ClockTextGrid) | Out-Null

$script:OutlineTextBlocks = @()
$outlineOffsets = @(
    @(-1, -1), @(0, -1), @(1, -1),
    @(-1, 0),           @(1, 0),
    @(-1, 1),  @(0, 1),  @(1, 1)
)
foreach ($offset in $outlineOffsets) {
    $outlineBlock = New-ClockTextBlock (Get-TextOutlineBrush)
    $outlineBlock.IsHitTestVisible = $false
    $entry = [pscustomobject]@{
        Block = $outlineBlock
        X = [double]$offset[0]
        Y = [double]$offset[1]
    }
    $script:OutlineTextBlocks += $entry
    $script:ClockTextGrid.Children.Add($outlineBlock) | Out-Null
}

$script:TextBlock = New-ClockTextBlock (Get-TextBrush)
$script:ClockTextGrid.Children.Add($script:TextBlock) | Out-Null

Apply-ClockTextStyle
Apply-BdoTimeStyle

$dragHandler = {
    param($sender, $eventArgs)
    if ($eventArgs.ChangedButton -eq [System.Windows.Input.MouseButton]::Left) {
        try {
            $script:Window.DragMove()
            Clamp-WidgetToScreenBounds
            Save-WidgetConfig
        }
        catch {
        }
    }
}

$rightClickHandler = {
    param($sender, $eventArgs)

    if ($script:TrayMenu) {
        Update-TrayToggleText
        $script:TrayMenu.Show([System.Windows.Forms.Control]::MousePosition)
    }
    $eventArgs.Handled = $true
}

$script:Border.Add_MouseLeftButtonDown($dragHandler)
$script:WidgetGrid.Add_MouseLeftButtonDown($dragHandler)
$script:BackgroundLayer.Add_MouseLeftButtonDown($dragHandler)
$script:ContentStack.Add_MouseLeftButtonDown($dragHandler)
$script:BdoTimePanel.Add_MouseLeftButtonDown($dragHandler)
$script:BdoTextGrid.Add_MouseLeftButtonDown($dragHandler)
$script:BdoTransitionTextBlock.Add_MouseLeftButtonDown($dragHandler)
$script:ClockTextGrid.Add_MouseLeftButtonDown($dragHandler)
$script:TextBlock.Add_MouseLeftButtonDown($dragHandler)
if ($script:BossAlertTextBlock) {
    $script:BossAlertTextBlock.Add_MouseLeftButtonDown($dragHandler)
}
if ($script:BossAlertPanel) {
    $script:BossAlertPanel.Add_MouseLeftButtonDown($dragHandler)
}
$script:Border.Add_MouseRightButtonUp($rightClickHandler)
$script:WidgetGrid.Add_MouseRightButtonUp($rightClickHandler)
$script:BackgroundLayer.Add_MouseRightButtonUp($rightClickHandler)
$script:ContentStack.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTimePanel.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTextGrid.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTransitionTextBlock.Add_MouseRightButtonUp($rightClickHandler)
$script:ClockTextGrid.Add_MouseRightButtonUp($rightClickHandler)
$script:TextBlock.Add_MouseRightButtonUp($rightClickHandler)
if ($script:BossAlertTextBlock) {
    $script:BossAlertTextBlock.Add_MouseRightButtonUp($rightClickHandler)
}
if ($script:BossAlertPanel) {
    $script:BossAlertPanel.Add_MouseRightButtonUp($rightClickHandler)
}

$script:Window.Add_KeyDown({
    param($sender, $eventArgs)
    if ($eventArgs.Key -eq [System.Windows.Input.Key]::Add -or $eventArgs.Key -eq [System.Windows.Input.Key]::OemPlus) {
        Set-WidgetFontSize ($script:FontSize + 4)
    }
    elseif ($eventArgs.Key -eq [System.Windows.Input.Key]::Subtract -or $eventArgs.Key -eq [System.Windows.Input.Key]::OemMinus) {
        Set-WidgetFontSize ($script:FontSize - 4)
    }
})

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(200)
$timer.Add_Tick({ Update-ClockText })
$timer.Start()

$script:Window.Add_Closing({
    Save-WidgetConfig
    $timer.Stop()
    if ($script:TrayIcon) {
        $script:TrayIcon.Visible = $false
        $script:TrayIcon.Dispose()
    }
    if ($script:CurrentTrayIcon) {
        $script:CurrentTrayIcon.Dispose()
    }
    if ($script:TrayMenu) {
        $script:TrayMenu.Dispose()
    }
})

Update-ClockText
Create-TrayIcon
$script:Application = New-Object System.Windows.Application
$script:Application.ShutdownMode = [System.Windows.ShutdownMode]::OnMainWindowClose
$script:Application.Run($script:Window) | Out-Null
