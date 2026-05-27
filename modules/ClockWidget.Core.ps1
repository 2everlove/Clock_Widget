# Clock Widget module: ClockWidget.Core.ps1
# This file is dot-sourced by ClockWidget.ps1.

function Get-DefaultConfig {
    [pscustomobject]@{
        X = 80
        Y = 80
        FontSize = 34
        BackgroundOpacity = 0.86
        BackgroundColor = "#111111"
        BackgroundBorderColor = "#000000"
        BackgroundBorderColorTransparent = $true
        BackgroundBorderThickness = 2
        BackgroundBorderRadius = 0
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
        BossRows = @(Get-DefaultBossRows)
    }
}

function Read-WidgetConfig {
    if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
        return Get-DefaultConfig
    }

    try {
        $config = Get-Content -LiteralPath $script:ConfigPath -Raw | ConvertFrom-Json
        $default = Get-DefaultConfig

        foreach ($name in "X", "Y", "FontSize", "BackgroundColor", "BackgroundBorderColor", "BackgroundBorderColorTransparent", "BackgroundBorderThickness", "BackgroundBorderRadius", "TextColor", "TextColorTransparent", "TextOutlineColor", "TextOutlineColorTransparent", "FontFamily", "TrayIconPath", "TimeFormat", "MeridiemLanguage", "BdoTimeEnabled", "BdoTimeFormat", "BdoIconType", "BdoIconEnabled", "BdoFontSize", "BdoTimeOffsetSeconds", "BdoTextColor", "BdoTextColorTransparent", "BdoTextOutlineColor", "BdoTextOutlineColorTransparent", "BdoFontFamily", "BdoTransitionEnabled", "BdoTransitionFontSize", "BdoTransitionTextColor", "BdoTransitionTextColorTransparent", "BdoTransitionTextOutlineColor", "BdoTransitionTextOutlineColorTransparent", "BdoTransitionFontFamily", "BossAlertEnabled", "BossFontSize", "BossTextColor", "BossTextColorTransparent", "BossTextOutlineColor", "BossTextOutlineColorTransparent", "BossFontFamily", "BossAlertBeforeSeconds", "BossAlertAfterSeconds", "BossMarginTop", "BossMarginBottom", "BossHighlightAnimationSeconds", "BossHighlightColor", "BossRows") {
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
        if ($null -eq $config.BossRows -or @($config.BossRows).Count -eq 0) {
            $config.BossRows = @(Get-DefaultBossRows)
        }

        return $config
    }
    catch {
        return Get-DefaultConfig
    }
}

function Save-WidgetConfig {
    if ($null -eq $script:Window) {
        return
    }

    Clamp-WidgetToScreenBounds

    $config = [pscustomobject]@{
        X = [int]$script:Window.Left
        Y = [int]$script:Window.Top
        FontSize = [int]$script:FontSize
        BackgroundOpacity = [double]$script:BackgroundOpacity
        BackgroundColor = [string]$script:BackgroundColor
        BackgroundBorderColor = [string]$script:BackgroundBorderColor
        BackgroundBorderColorTransparent = [bool]$script:BackgroundBorderColorTransparent
        BackgroundBorderThickness = [int]$script:BackgroundBorderThickness
        BackgroundBorderRadius = [int]$script:BackgroundBorderRadius
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
    }

    $configJson = $config | ConvertTo-Json -Depth 8
    if ($script:LastSavedConfigJson -eq $configJson) {
        return
    }

    if ($null -eq $script:LastSavedConfigJson -and (Test-Path -LiteralPath $script:ConfigPath)) {
        $currentJson = Get-Content -LiteralPath $script:ConfigPath -Raw -ErrorAction SilentlyContinue
        if ($currentJson -and $currentJson.Trim() -eq $configJson.Trim()) {
            $script:LastSavedConfigJson = $configJson
            return
        }
    }

    $configJson | Set-Content -LiteralPath $script:ConfigPath -Encoding UTF8
    $script:LastSavedConfigJson = $configJson
}

function Get-SettingsPropertyNames {
    @(
        "FontSize", "BackgroundOpacity", "BackgroundColor", "BackgroundBorderColor", "BackgroundBorderColorTransparent", "BackgroundBorderThickness", "BackgroundBorderRadius", "TextColor", "TextColorTransparent",
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
        BackgroundBorderColor = [string]$script:BackgroundBorderColor
        BackgroundBorderColorTransparent = [bool]$script:BackgroundBorderColorTransparent
        BackgroundBorderThickness = [int]$script:BackgroundBorderThickness
        BackgroundBorderRadius = [int]$script:BackgroundBorderRadius
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
    $script:BackgroundBorderColor = [string]$Snapshot.BackgroundBorderColor
    $script:BackgroundBorderColorTransparent = [bool]$Snapshot.BackgroundBorderColorTransparent
    $script:BackgroundBorderThickness = [int]$Snapshot.BackgroundBorderThickness
    $script:BackgroundBorderRadius = [int]$Snapshot.BackgroundBorderRadius
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
        Enable-Startup
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
    Apply-BackgroundBorderStyle
    Update-BdoLogo
    Apply-ClockTextStyle
    Apply-BdoTimeStyle
    Apply-BossAlertStyle
    Reset-BossAlertRuntimeCache
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
        if ($script:BackgroundBorderThicknessSlider) { $script:BackgroundBorderThicknessSlider.Value = [double]$draft.BackgroundBorderThickness }
        if ($script:BackgroundBorderThicknessValueText) { $script:BackgroundBorderThicknessValueText.Text = [string]([int]$draft.BackgroundBorderThickness) }
        if ($script:BackgroundBorderRadiusSlider) { $script:BackgroundBorderRadiusSlider.Value = [double]$draft.BackgroundBorderRadius }
        if ($script:BackgroundBorderRadiusValueText) { $script:BackgroundBorderRadiusValueText.Text = [string]([int]$draft.BackgroundBorderRadius) }
        if ($script:BackgroundColorText) { $script:BackgroundColorText.Text = [string]$draft.BackgroundColor }
        Set-ColorSwatch $script:BackgroundColorSwatch $draft.BackgroundColor
        if ($script:BackgroundBorderColorText) { $script:BackgroundBorderColorText.Text = [string]$draft.BackgroundBorderColor }
        Set-ColorSwatch $script:BackgroundBorderColorSwatch $draft.BackgroundBorderColor ([bool]$draft.BackgroundBorderColorTransparent)
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

function Update-SettingsDirtyState {
    if ($script:SettingsDraft -and $script:SettingsOriginal) {
        $script:SettingsDirty = -not (Test-SettingsSnapshotEqual $script:SettingsDraft $script:SettingsOriginal)
    }
}

function Sync-DraftColorControl {
    param(
        [object]$Draft,
        [string]$ColorProperty,
        [string]$TextControlName,
        [string]$SwatchControlName,
        [string]$TransparentProperty = ""
    )

    $textControl = Get-Variable -Scope Script -Name $TextControlName -ValueOnly -ErrorAction SilentlyContinue
    if ($textControl) {
        $textControl.Text = [string]$Draft.$ColorProperty
    }

    $swatch = Get-Variable -Scope Script -Name $SwatchControlName -ValueOnly -ErrorAction SilentlyContinue
    $transparent = $false
    if (-not [string]::IsNullOrWhiteSpace($TransparentProperty)) {
        $transparent = [bool]$Draft.$TransparentProperty
    }
    Set-ColorSwatch $swatch ([string]$Draft.$ColorProperty) $transparent
}

function Sync-SettingsControlsForDraftChange {
    param([string]$Name)

    if ($null -eq $script:SettingsDraft -or $script:SyncingSettingsControls) {
        return
    }

    $draft = $script:SettingsDraft
    $script:SyncingSettingsControls = $true
    try {
        switch ($Name) {
            "StartupEnabled" {
                if ($script:StartupCheckBox) { $script:StartupCheckBox.IsChecked = [bool]$draft.StartupEnabled }
            }
            "BdoTimeEnabled" {
                if ($script:BdoTimeCheckBox) { $script:BdoTimeCheckBox.IsChecked = [bool]$draft.BdoTimeEnabled }
                Set-OptionsGroupVisibility $script:BdoOptionsExpander $script:BdoOptionsPanel ([bool]$draft.BdoTimeEnabled)
            }
            "BdoTimeFormat" {
                if ($script:BdoTimeFormat24RadioButton) { $script:BdoTimeFormat24RadioButton.IsChecked = ($draft.BdoTimeFormat -ne "12") }
                if ($script:BdoTimeFormat12RadioButton) { $script:BdoTimeFormat12RadioButton.IsChecked = ($draft.BdoTimeFormat -eq "12") }
            }
            "BdoIconEnabled" {
                if ($script:BdoIconEnabledCheckBox) { $script:BdoIconEnabledCheckBox.IsChecked = [bool]$draft.BdoIconEnabled }
                if ($script:BdoIconChoicePanel) { $script:BdoIconChoicePanel.Visibility = if ($draft.BdoIconEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
            }
            "BdoIconType" {
                if ($script:BdoBlackSpiritRadioButton) { $script:BdoBlackSpiritRadioButton.IsChecked = ($draft.BdoIconType -ne "papu") }
                if ($script:BdoPapuRadioButton) { $script:BdoPapuRadioButton.IsChecked = ($draft.BdoIconType -eq "papu") }
            }
            "BdoFontSize" {
                if ($script:BdoFontSizeSlider) { $script:BdoFontSizeSlider.Value = [double]$draft.BdoFontSize }
                if ($script:BdoFontSizeValueText) { $script:BdoFontSizeValueText.Text = [string]$draft.BdoFontSize }
            }
            "BdoTimeOffsetSeconds" {
                if ($script:BdoTimeOffsetTextBox) { $script:BdoTimeOffsetTextBox.Text = [string]$draft.BdoTimeOffsetSeconds }
            }
            "BdoTextColor" { Sync-DraftColorControl $draft "BdoTextColor" "BdoTextColorText" "BdoTextColorSwatch" "BdoTextColorTransparent" }
            "BdoTextOutlineColor" { Sync-DraftColorControl $draft "BdoTextOutlineColor" "BdoTextOutlineColorText" "BdoTextOutlineColorSwatch" "BdoTextOutlineColorTransparent" }
            "BdoFontFamily" {
                if ($script:BdoFontFamilyText) { Set-FontValueText $script:BdoFontFamilyText $draft.BdoFontFamily }
            }
            "BdoTransitionEnabled" {
                if ($script:BdoTransitionCheckBox) { $script:BdoTransitionCheckBox.IsChecked = [bool]$draft.BdoTransitionEnabled }
                if ($script:BdoTransitionOptionsPanel) { $script:BdoTransitionOptionsPanel.Visibility = if ($draft.BdoTransitionEnabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
            }
            "BdoTransitionFontSize" {
                if ($script:BdoTransitionFontSizeSlider) { $script:BdoTransitionFontSizeSlider.Value = [double]$draft.BdoTransitionFontSize }
                if ($script:BdoTransitionFontSizeValueText) { $script:BdoTransitionFontSizeValueText.Text = [string]$draft.BdoTransitionFontSize }
            }
            "BdoTransitionTextColor" { Sync-DraftColorControl $draft "BdoTransitionTextColor" "BdoTransitionTextColorText" "BdoTransitionTextColorSwatch" "BdoTransitionTextColorTransparent" }
            "BdoTransitionTextOutlineColor" { Sync-DraftColorControl $draft "BdoTransitionTextOutlineColor" "BdoTransitionTextOutlineColorText" "BdoTransitionTextOutlineColorSwatch" "BdoTransitionTextOutlineColorTransparent" }
            "BdoTransitionFontFamily" {
                if ($script:BdoTransitionFontFamilyText) { Set-FontValueText $script:BdoTransitionFontFamilyText $draft.BdoTransitionFontFamily }
            }
            "BossAlertEnabled" {
                if ($script:BossAlertCheckBox) { $script:BossAlertCheckBox.IsChecked = [bool]$draft.BossAlertEnabled }
                Set-OptionsGroupVisibility $script:BossOptionsExpander $script:BossOptionsPanel ([bool]$draft.BossAlertEnabled)
            }
            "BossFontSize" {
                if ($script:BossFontSizeSlider) { $script:BossFontSizeSlider.Value = [double]$draft.BossFontSize }
                if ($script:BossFontSizeValueText) { $script:BossFontSizeValueText.Text = [string]$draft.BossFontSize }
            }
            "BossAlertBeforeSeconds" { Set-BossAlertTimeInputControls "Before" ([int]$draft.BossAlertBeforeSeconds) }
            "BossAlertAfterSeconds" { Set-BossAlertTimeInputControls "After" ([int]$draft.BossAlertAfterSeconds) }
            "BossMarginTop" {
                if ($script:BossMarginTopSlider) { $script:BossMarginTopSlider.Value = [double]$draft.BossMarginTop }
                if ($script:BossMarginTopValueText) { $script:BossMarginTopValueText.Text = [string]$draft.BossMarginTop }
            }
            "BossMarginBottom" {
                if ($script:BossMarginBottomSlider) { $script:BossMarginBottomSlider.Value = [double]$draft.BossMarginBottom }
                if ($script:BossMarginBottomValueText) { $script:BossMarginBottomValueText.Text = [string]$draft.BossMarginBottom }
            }
            "BossTextColor" { Sync-DraftColorControl $draft "BossTextColor" "BossTextColorText" "BossTextColorSwatch" "BossTextColorTransparent" }
            "BossTextOutlineColor" { Sync-DraftColorControl $draft "BossTextOutlineColor" "BossTextOutlineColorText" "BossTextOutlineColorSwatch" "BossTextOutlineColorTransparent" }
            "BossHighlightColor" { Sync-DraftColorControl $draft "BossHighlightColor" "BossHighlightColorText" "BossHighlightColorSwatch" }
            "BossFontFamily" {
                if ($script:BossFontFamilyText) { Set-FontValueText $script:BossFontFamilyText $draft.BossFontFamily }
            }
            "BossRows" { Refresh-BossRowsEditor }
            "BossHighlightAnimationSeconds" {
                if ($script:BossHighlightAnimationTextBox) { $script:BossHighlightAnimationTextBox.Text = ([double]$draft.BossHighlightAnimationSeconds).ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture) }
            }
            "TimeFormat" {
                if ($script:TimeFormat24RadioButton) { $script:TimeFormat24RadioButton.IsChecked = ($draft.TimeFormat -ne "12") }
                if ($script:TimeFormat12RadioButton) { $script:TimeFormat12RadioButton.IsChecked = ($draft.TimeFormat -eq "12") }
                if ($script:MeridiemLanguagePanel) { $script:MeridiemLanguagePanel.Visibility = if ($draft.TimeFormat -eq "12") { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed } }
            }
            "MeridiemLanguage" {
                if ($script:MeridiemEnglishRadioButton) { $script:MeridiemEnglishRadioButton.IsChecked = ($draft.MeridiemLanguage -ne "ko") }
                if ($script:MeridiemKoreanRadioButton) { $script:MeridiemKoreanRadioButton.IsChecked = ($draft.MeridiemLanguage -eq "ko") }
            }
            "FontSize" {
                if ($script:FontSizeSlider) { $script:FontSizeSlider.Value = [double]$draft.FontSize }
                if ($script:FontSizeValueText) { $script:FontSizeValueText.Text = [string]$draft.FontSize }
            }
            "BackgroundOpacity" {
                if ($script:BackgroundOpacityValueText) { $script:BackgroundOpacityValueText.Text = [string]([int][Math]::Round([double]$draft.BackgroundOpacity * 100)) }
            }
            "BackgroundBorderThickness" {
                if ($script:BackgroundBorderThicknessSlider) { $script:BackgroundBorderThicknessSlider.Value = [double]$draft.BackgroundBorderThickness }
                if ($script:BackgroundBorderThicknessValueText) { $script:BackgroundBorderThicknessValueText.Text = [string]([int]$draft.BackgroundBorderThickness) }
            }
            "BackgroundBorderRadius" {
                if ($script:BackgroundBorderRadiusSlider) { $script:BackgroundBorderRadiusSlider.Value = [double]$draft.BackgroundBorderRadius }
                if ($script:BackgroundBorderRadiusValueText) { $script:BackgroundBorderRadiusValueText.Text = [string]([int]$draft.BackgroundBorderRadius) }
            }
            "BackgroundColor" { Sync-DraftColorControl $draft "BackgroundColor" "BackgroundColorText" "BackgroundColorSwatch" }
            "BackgroundBorderColor" { Sync-DraftColorControl $draft "BackgroundBorderColor" "BackgroundBorderColorText" "BackgroundBorderColorSwatch" "BackgroundBorderColorTransparent" }
            "TextColor" { Sync-DraftColorControl $draft "TextColor" "TextColorText" "TextColorSwatch" "TextColorTransparent" }
            "TextOutlineColor" { Sync-DraftColorControl $draft "TextOutlineColor" "TextOutlineColorText" "TextOutlineColorSwatch" "TextOutlineColorTransparent" }
            "FontFamily" {
                if ($script:FontFamilyText) { Set-FontValueText $script:FontFamilyText $draft.FontFamily }
            }
            "TrayIconPath" {
                if ($script:TrayIconPathText) { $script:TrayIconPathText.Text = [System.IO.Path]::GetFileName($draft.TrayIconPath) }
                Update-TrayIconPreview
            }
        }

        if ($Name -like "*Transparent") {
            Sync-TransparentColorControls
        }
    }
    finally {
        $script:SyncingSettingsControls = $false
    }

    Request-SettingsPreviewUpdate
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

    $currentValue = $script:SettingsDraft.$Name
    if ($Name -eq "BossRows") {
        if ((Get-BossRowsSignature $currentValue) -eq (Get-BossRowsSignature $Value)) {
            return $true
        }
    }
    elseif ([string]$currentValue -eq [string]$Value) {
        return $true
    }

    $script:SettingsDraft.$Name = $Value
    Update-SettingsDirtyState
    Sync-SettingsControlsForDraftChange $Name
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

function Set-WidgetClickThrough {
    param([bool]$Enabled)

    if ($null -eq $script:Window) {
        return
    }

    $helper = New-Object System.Windows.Interop.WindowInteropHelper $script:Window
    $handle = $helper.Handle
    if ($handle -eq [IntPtr]::Zero) {
        return
    }

    $style = [NativeWindowTools]::GetWindowLongPtr($handle, [NativeWindowTools]::GWL_EXSTYLE).ToInt64()
    if ($Enabled) {
        $style = $style -bor [NativeWindowTools]::WS_EX_TRANSPARENT
    }
    else {
        $style = $style -band (-bnot [NativeWindowTools]::WS_EX_TRANSPARENT)
    }
    [NativeWindowTools]::SetWindowLongPtr($handle, [NativeWindowTools]::GWL_EXSTYLE, (New-Object IntPtr $style)) | Out-Null
}

function Set-WidgetMoveMode {
    param([bool]$Enabled)

    $script:WidgetMoveMode = $Enabled
    Set-WidgetClickThrough (-not $Enabled)

    $moveCursor = if ($Enabled) { [System.Windows.Input.Cursors]::SizeAll } else { $null }
    if ($script:Window) {
        $script:Window.Cursor = $moveCursor
    }
    if ($script:Border) {
        $script:Border.Cursor = $moveCursor
    }
    if ($script:WidgetGrid) {
        $script:WidgetGrid.Cursor = $moveCursor
    }
    if ($script:BackgroundLayer) {
        $script:BackgroundLayer.Cursor = $moveCursor
    }
    if ($script:ContentStack) {
        $script:ContentStack.Cursor = $moveCursor
    }
    if ($script:MoveModeFixButton) {
        $script:MoveModeFixButton.Visibility = if ($Enabled) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
        $script:MoveModeFixButton.IsHitTestVisible = $Enabled
        $script:MoveModeFixButton.Cursor = [System.Windows.Input.Cursors]::Hand
    }
    Apply-BackgroundBorderStyle
    if ($script:ContentStack) {
        $script:ContentStack.Opacity = if ($Enabled) { 0.45 } else { 1.0 }
        if ($Enabled) {
            $blur = New-Object System.Windows.Media.Effects.BlurEffect
            $blur.Radius = 1.5
            $script:ContentStack.Effect = $blur
        }
        else {
            $script:ContentStack.Effect = $null
        }
    }
    if ($script:BackgroundLayer) {
        $script:BackgroundLayer.Opacity = if ($Enabled) { [Math]::Min([double]$script:BackgroundOpacity, 0.35) } else { [double]$script:BackgroundOpacity }
    }
}

function Start-WidgetMoveMode {
    if (-not $script:Window.IsVisible) {
        Set-WidgetVisible $true
    }
    Set-WidgetMoveMode $true
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
        Set-WidgetClickThrough (-not $script:WidgetMoveMode)
    }
    else {
        Set-WidgetMoveMode $false
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

    $moveItem = $script:TrayMenu.Items.Add("이동")
    $moveItem.Add_Click({ Start-WidgetMoveMode })

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
    $entryScriptPath = if (-not [string]::IsNullOrWhiteSpace($script:EntryScriptPath)) { $script:EntryScriptPath } else { Join-Path $script:AppDir "ClockWidget.ps1" }
    $command = "`"$script:PowerShellPath`" -NoProfile -ExecutionPolicy Bypass -File `"$entryScriptPath`""
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
        "BackgroundBorderColor" { Set-BackgroundBorderColor $nextValue }
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

