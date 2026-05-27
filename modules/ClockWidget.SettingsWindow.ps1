# Clock Widget module: ClockWidget.SettingsWindow.ps1
# This file is dot-sourced by ClockWidget.ps1.

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
        $script:ColorPreviewBackground.BorderBrush = Get-BackgroundBorderBrush
        $script:ColorPreviewBackground.BorderThickness = Get-BackgroundBorderThickness
        $script:ColorPreviewBackground.CornerRadius = Get-BackgroundCornerRadius
        $script:ColorPreviewBackground.Opacity = 1.0
    }
    if ($script:ColorPreviewText) {
        $previewFontSize = [double][Math]::Max(16, [Math]::Min(42, $script:FontSize))
        $previewPadding = New-Object System.Windows.Thickness 0
        $previewLineHeight = [double]($previewFontSize * 1.0)
        $previewOutlineThickness = [double][Math]::Max(1.0, [Math]::Round($previewFontSize * 0.04, 1))
        $previewFontFamily = New-Object System.Windows.Media.FontFamily $script:FontFamily

        if ($script:ColorPreviewOutlineTextBlocks) {
            foreach ($item in $script:ColorPreviewOutlineTextBlocks) {
                $item.Block.Text = $previewTime
                $item.Block.FontFamily = $previewFontFamily
                $item.Block.FontSize = $previewFontSize
                $item.Block.LineHeight = $previewLineHeight
                $item.Block.Margin = $previewPadding
                $item.Block.Foreground = Get-TextOutlineBrush
                $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $previewOutlineThickness), ($item.Y * $previewOutlineThickness)
                $item.Block.Visibility = if ($script:TextColorTransparent -or $script:TextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
            }
        }
        if ($script:ColorPreviewOutlinePath) {
            Update-TextOutlinePathGeometry $script:ColorPreviewOutlinePath $previewTime $script:FontFamily $previewFontSize $previewPadding ([double]($previewOutlineThickness * 1.8)) (Get-TextOutlineBrush) ([bool]($script:TextColorTransparent -and -not $script:TextOutlineColorTransparent))
        }

        $script:ColorPreviewText.Foreground = Get-TextBrush
        $script:ColorPreviewText.FontFamily = $previewFontFamily
        $script:ColorPreviewText.Text = $previewTime
        $script:ColorPreviewText.FontSize = $previewFontSize
        $script:ColorPreviewText.LineHeight = $previewLineHeight
        $script:ColorPreviewText.Margin = $previewPadding
        $script:ColorPreviewText.Visibility = if ($script:TextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
        $script:ColorPreviewText.Effect = $null
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
        $bdoPreviewText = Get-BdoGameTimeText
        $bdoPreviewFontSize = [double][Math]::Max(10, [Math]::Min(32, $script:BdoFontSize))
        $bdoPreviewFontFamily = New-Object System.Windows.Media.FontFamily $script:BdoFontFamily
        $bdoPreviewLineHeight = [double]($bdoPreviewFontSize * 1.0)
        $bdoPreviewOutlineThickness = [double][Math]::Max(0.75, [Math]::Round($bdoPreviewFontSize * 0.06, 1))
        if ($script:BdoPreviewOutlineTextBlocks) {
            foreach ($item in $script:BdoPreviewOutlineTextBlocks) {
                $item.Block.Text = $bdoPreviewText
                $item.Block.FontFamily = $bdoPreviewFontFamily
                $item.Block.FontSize = $bdoPreviewFontSize
                $item.Block.LineHeight = $bdoPreviewLineHeight
                $item.Block.Margin = New-Object System.Windows.Thickness 0
                $item.Block.Foreground = Get-BdoTextOutlineBrush
                $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $bdoPreviewOutlineThickness), ($item.Y * $bdoPreviewOutlineThickness)
                $item.Block.Visibility = if ($script:BdoTextColorTransparent -or $script:BdoTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
            }
        }
        if ($script:BdoPreviewOutlinePath) {
            Update-TextOutlinePathGeometry $script:BdoPreviewOutlinePath $bdoPreviewText $script:BdoFontFamily $bdoPreviewFontSize (New-Object System.Windows.Thickness 0) ([double]($bdoPreviewOutlineThickness * 1.8)) (Get-BdoTextOutlineBrush) ([bool]($script:BdoTextColorTransparent -and -not $script:BdoTextOutlineColorTransparent))
        }
        $script:BdoPreviewText.Text = $bdoPreviewText
        $script:BdoPreviewText.FontFamily = $bdoPreviewFontFamily
        $script:BdoPreviewText.FontSize = $bdoPreviewFontSize
        $script:BdoPreviewText.LineHeight = $bdoPreviewLineHeight
        $script:BdoPreviewText.Foreground = Get-BdoTextBrush
        $script:BdoPreviewText.Visibility = if ($script:BdoTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
        $script:BdoPreviewText.Effect = $null
    }
    if ($script:BdoTransitionPreviewText) {
        $transitionPreviewText = Get-BdoTransitionText
        $transitionPreviewFontSize = [double][Math]::Max(9, [Math]::Min(28, $script:BdoTransitionFontSize))
        $transitionPreviewFontFamily = New-Object System.Windows.Media.FontFamily $script:BdoTransitionFontFamily
        $transitionPreviewLineHeight = [double]($transitionPreviewFontSize * 1.0)
        $transitionPreviewOutlineThickness = [double][Math]::Max(0.75, [Math]::Round($transitionPreviewFontSize * 0.06, 1))
        if ($script:BdoTransitionPreviewOutlineTextBlocks) {
            foreach ($item in $script:BdoTransitionPreviewOutlineTextBlocks) {
                $item.Block.Text = $transitionPreviewText
                $item.Block.FontFamily = $transitionPreviewFontFamily
                $item.Block.FontSize = $transitionPreviewFontSize
                $item.Block.LineHeight = $transitionPreviewLineHeight
                $item.Block.Margin = New-Object System.Windows.Thickness 0
                $item.Block.Foreground = Get-BdoTransitionTextOutlineBrush
                $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $transitionPreviewOutlineThickness), ($item.Y * $transitionPreviewOutlineThickness)
                $item.Block.Visibility = if ($script:BdoTransitionTextColorTransparent -or $script:BdoTransitionTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
            }
        }
        if ($script:BdoTransitionPreviewOutlinePath) {
            Update-TextOutlinePathGeometry $script:BdoTransitionPreviewOutlinePath $transitionPreviewText $script:BdoTransitionFontFamily $transitionPreviewFontSize (New-Object System.Windows.Thickness 0) ([double]($transitionPreviewOutlineThickness * 1.8)) (Get-BdoTransitionTextOutlineBrush) ([bool]($script:BdoTransitionTextColorTransparent -and -not $script:BdoTransitionTextOutlineColorTransparent))
        }
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled -and -not ($script:BdoTransitionTextColorTransparent -and $script:BdoTransitionTextOutlineColorTransparent)) {
            if ($script:BdoTransitionPreviewGrid) {
                $script:BdoTransitionPreviewGrid.Visibility = [System.Windows.Visibility]::Visible
            }
            $script:BdoTransitionPreviewText.Visibility = if ($script:BdoTransitionTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
            $script:BdoTransitionPreviewText.Text = $transitionPreviewText
            $script:BdoTransitionPreviewText.FontFamily = $transitionPreviewFontFamily
            $script:BdoTransitionPreviewText.FontSize = $transitionPreviewFontSize
            $script:BdoTransitionPreviewText.LineHeight = $transitionPreviewLineHeight
            $script:BdoTransitionPreviewText.Foreground = Get-BdoTransitionTextBrush
            $script:BdoTransitionPreviewText.Effect = $null
        }
        else {
            $script:BdoTransitionPreviewText.Visibility = [System.Windows.Visibility]::Collapsed
            if ($script:BdoTransitionPreviewGrid) {
                $script:BdoTransitionPreviewGrid.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
    }
    if ($script:BossPreviewHostPanel) {
        if ($script:BossAlertEnabled) {
            $script:BossPreviewHostPanel.Children.Clear()
            $previewAlerts = @(Get-BossAlertItems)
            if ($previewAlerts.Count -gt 0) {
                foreach ($alert in $previewAlerts) {
                    $previewItem = New-BossAlertDisplayItem $alert.Text $alert.BossParts $alert.Key $alert.WidthTexts
                    $previewItem.Margin = New-Object System.Windows.Thickness 0, $script:BossMarginTop, 0, $script:BossMarginBottom
                    $script:BossPreviewHostPanel.Children.Add($previewItem) | Out-Null
                }
                $script:BossPreviewHostPanel.Visibility = [System.Windows.Visibility]::Visible
            }
            else {
                $script:BossPreviewHostPanel.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
        else {
            $script:BossPreviewHostPanel.Children.Clear()
            $script:BossPreviewHostPanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
}

function Request-SettingsPreviewUpdate {
    if (-not $script:ColorPreviewBackground -and -not $script:ColorPreviewText -and -not $script:BossPreviewHostPanel -and -not $script:BdoPreviewText) {
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
        [pscustomobject]@{ Name = "BackgroundBorderColor"; Value = if ($script:BackgroundBorderColorText) { [string]$script:BackgroundBorderColorText.Text } else { $null } },
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
        @("BackgroundBorderColorTransparent", "BackgroundBorderColorTransparentCheckBox", "BackgroundBorderColorSwatch", "BackgroundBorderColor"),
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
    $labelColumn.Width = New-Object System.Windows.GridLength 190
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
    $labelBlock.TextTrimming = [System.Windows.TextTrimming]::None
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

    $borderThicknessLabel = New-Object System.Windows.Controls.TextBlock
    $borderThicknessLabel.Text = "배경 테두리 굵기"
    $panel.Children.Add($borderThicknessLabel) | Out-Null

    $script:BackgroundBorderThicknessSlider = New-Object System.Windows.Controls.Slider
    $script:BackgroundBorderThicknessSlider.Minimum = 0
    $script:BackgroundBorderThicknessSlider.Maximum = 10
    $script:BackgroundBorderThicknessSlider.Value = [double]$script:BackgroundBorderThickness
    $script:BackgroundBorderThicknessSlider.TickFrequency = 1
    $script:BackgroundBorderThicknessSlider.IsSnapToTickEnabled = $true
    $script:BackgroundBorderThicknessSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BackgroundBorderThickness ([int]$sender.Value)
    })
    $script:BackgroundBorderThicknessValueText = New-Object System.Windows.Controls.TextBlock
    $script:BackgroundBorderThicknessValueText.Text = [string]$script:BackgroundBorderThickness
    $panel.Children.Add((New-SliderRow $script:BackgroundBorderThicknessSlider $script:BackgroundBorderThicknessValueText)) | Out-Null

    $borderRadiusLabel = New-Object System.Windows.Controls.TextBlock
    $borderRadiusLabel.Text = "배경 모서리 반경"
    $panel.Children.Add($borderRadiusLabel) | Out-Null

    $script:BackgroundBorderRadiusSlider = New-Object System.Windows.Controls.Slider
    $script:BackgroundBorderRadiusSlider.Minimum = 0
    $script:BackgroundBorderRadiusSlider.Maximum = 30
    $script:BackgroundBorderRadiusSlider.Value = [double]$script:BackgroundBorderRadius
    $script:BackgroundBorderRadiusSlider.TickFrequency = 1
    $script:BackgroundBorderRadiusSlider.IsSnapToTickEnabled = $true
    $script:BackgroundBorderRadiusSlider.Add_ValueChanged({
        param($sender, $eventArgs)
        Set-BackgroundBorderRadius ([int]$sender.Value)
    })
    $script:BackgroundBorderRadiusValueText = New-Object System.Windows.Controls.TextBlock
    $script:BackgroundBorderRadiusValueText.Text = [string]$script:BackgroundBorderRadius
    $panel.Children.Add((New-SliderRow $script:BackgroundBorderRadiusSlider $script:BackgroundBorderRadiusValueText)) | Out-Null

    $script:BackgroundColorText = New-Object System.Windows.Controls.TextBox
    $script:BackgroundColorText.Text = $script:BackgroundColor
    $panel.Children.Add((New-SettingsRow "배경 색상" (New-ColorValueControl $script:BackgroundColorText $script:BackgroundColor "BackgroundColorSwatch" "BackgroundColor" { Show-BackgroundColorDialog }))) | Out-Null

    $script:BackgroundBorderColorText = New-Object System.Windows.Controls.TextBox
    $script:BackgroundBorderColorText.Text = $script:BackgroundBorderColor
    $panel.Children.Add((New-SettingsRow "배경 테두리색" (New-ColorValueControl $script:BackgroundBorderColorText $script:BackgroundBorderColor "BackgroundBorderColorSwatch" "BackgroundBorderColor" { Show-BackgroundBorderColorDialog } "BackgroundBorderColorTransparent" "BackgroundBorderColorTransparentCheckBox"))) | Out-Null

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
    $script:ColorPreviewBackground.CornerRadius = Get-BackgroundCornerRadius
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

    $script:BdoPreviewTextGrid = New-Object System.Windows.Controls.Grid
    $script:BdoPreviewTextGrid.Background = [System.Windows.Media.Brushes]::Transparent
    $script:BdoPreviewTextGrid.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BdoPreviewTextGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

    $script:BdoPreviewOutlineTextBlocks = @()
    $bdoPreviewOutlineOffsets = @(
        @(-1, -1), @(0, -1), @(1, -1),
        @(-1, 0),           @(1, 0),
        @(-1, 1),  @(0, 1),  @(1, 1)
    )
    foreach ($offset in $bdoPreviewOutlineOffsets) {
        $outlinePreviewText = New-Object System.Windows.Controls.TextBlock
        $outlinePreviewText.Text = "09:34"
        $outlinePreviewText.FontWeight = [System.Windows.FontWeights]::Bold
        $outlinePreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        $outlinePreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $outlinePreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
        $outlinePreviewText.IsHitTestVisible = $false
        $script:BdoPreviewOutlineTextBlocks += [pscustomobject]@{
            Block = $outlinePreviewText
            X = [double]$offset[0]
            Y = [double]$offset[1]
        }
        $script:BdoPreviewTextGrid.Children.Add($outlinePreviewText) | Out-Null
    }

    $script:BdoPreviewOutlinePath = New-TextOutlinePath
    $script:BdoPreviewTextGrid.Children.Add($script:BdoPreviewOutlinePath) | Out-Null

    $script:BdoPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:BdoPreviewText.Text = "09:34"
    $script:BdoPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:BdoPreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BdoPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $script:BdoPreviewTextGrid.Children.Add($script:BdoPreviewText) | Out-Null
    $script:BdoPreviewPanel.Children.Add($script:BdoPreviewTextGrid) | Out-Null

    $transitionPreviewOutlineOffsets = @(
        @(-1, -1), @(0, -1), @(1, -1),
        @(-1, 0),           @(1, 0),
        @(-1, 1),  @(0, 1),  @(1, 1)
    )

    $script:BdoTransitionPreviewGrid = New-Object System.Windows.Controls.Grid
    $script:BdoTransitionPreviewGrid.Background = [System.Windows.Media.Brushes]::Transparent
    $script:BdoTransitionPreviewGrid.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BdoTransitionPreviewGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoTransitionPreviewGrid.Margin = New-Object System.Windows.Thickness 6, 0, 0, 0

    $script:BdoTransitionPreviewOutlineTextBlocks = @()
    foreach ($offset in $transitionPreviewOutlineOffsets) {
        $outlinePreviewText = New-Object System.Windows.Controls.TextBlock
        $outlinePreviewText.Text = "(밤까지 12분)"
        $outlinePreviewText.FontWeight = [System.Windows.FontWeights]::Bold
        $outlinePreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        $outlinePreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $outlinePreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
        $outlinePreviewText.IsHitTestVisible = $false
        $script:BdoTransitionPreviewOutlineTextBlocks += [pscustomobject]@{
            Block = $outlinePreviewText
            X = [double]$offset[0]
            Y = [double]$offset[1]
        }
        $script:BdoTransitionPreviewGrid.Children.Add($outlinePreviewText) | Out-Null
    }

    $script:BdoTransitionPreviewOutlinePath = New-TextOutlinePath
    $script:BdoTransitionPreviewGrid.Children.Add($script:BdoTransitionPreviewOutlinePath) | Out-Null

    $script:BdoTransitionPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:BdoTransitionPreviewText.Text = "(밤까지 12분)"
    $script:BdoTransitionPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:BdoTransitionPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:BdoTransitionPreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BdoTransitionPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $script:BdoTransitionPreviewGrid.Children.Add($script:BdoTransitionPreviewText) | Out-Null
    $script:BdoPreviewPanel.Children.Add($script:BdoTransitionPreviewGrid) | Out-Null
    $previewStack.Children.Add($script:BdoPreviewPanel) | Out-Null

    $script:BossPreviewHostPanel = New-Object System.Windows.Controls.StackPanel
    $script:BossPreviewHostPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical
    $script:BossPreviewHostPanel.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:BossPreviewHostPanel.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $previewStack.Children.Add($script:BossPreviewHostPanel) | Out-Null

    $colorPreviewTextGrid = New-Object System.Windows.Controls.Grid
    $colorPreviewTextGrid.Background = [System.Windows.Media.Brushes]::Transparent
    $colorPreviewTextGrid.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $colorPreviewTextGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

    $script:ColorPreviewOutlineTextBlocks = @()
    $previewOutlineOffsets = @(
        @(-1, -1), @(0, -1), @(1, -1),
        @(-1, 0),           @(1, 0),
        @(-1, 1),  @(0, 1),  @(1, 1)
    )
    foreach ($offset in $previewOutlineOffsets) {
        $outlinePreviewText = New-Object System.Windows.Controls.TextBlock
        $outlinePreviewText.Text = "12:34:56"
        $outlinePreviewText.FontSize = 22
        $outlinePreviewText.FontWeight = [System.Windows.FontWeights]::Bold
        $outlinePreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
        $outlinePreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $outlinePreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
        $outlinePreviewText.IsHitTestVisible = $false
        $script:ColorPreviewOutlineTextBlocks += [pscustomobject]@{
            Block = $outlinePreviewText
            X = [double]$offset[0]
            Y = [double]$offset[1]
        }
        $colorPreviewTextGrid.Children.Add($outlinePreviewText) | Out-Null
    }

    $script:ColorPreviewOutlinePath = New-TextOutlinePath
    $colorPreviewTextGrid.Children.Add($script:ColorPreviewOutlinePath) | Out-Null

    $script:ColorPreviewText = New-Object System.Windows.Controls.TextBlock
    $script:ColorPreviewText.Text = "12:34:56"
    $script:ColorPreviewText.FontSize = 22
    $script:ColorPreviewText.FontWeight = [System.Windows.FontWeights]::Bold
    $script:ColorPreviewText.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $script:ColorPreviewText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $script:ColorPreviewText.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $colorPreviewTextGrid.Children.Add($script:ColorPreviewText) | Out-Null
    $previewStack.Children.Add($colorPreviewTextGrid) | Out-Null
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
        $script:BackgroundBorderColorText = $null
        $script:BackgroundBorderColorSwatch = $null
        $script:BackgroundBorderColorTransparentCheckBox = $null
        $script:BackgroundBorderThicknessSlider = $null
        $script:BackgroundBorderThicknessValueText = $null
        $script:BackgroundBorderRadiusSlider = $null
        $script:BackgroundBorderRadiusValueText = $null
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
        $script:ColorPreviewOutlineTextBlocks = $null
        $script:ColorPreviewOutlinePath = $null
        $script:ColorPreviewText = $null
        $script:BdoPreviewPanel = $null
        $script:BdoPreviewImage = $null
        $script:BdoPreviewTextGrid = $null
        $script:BdoPreviewOutlineTextBlocks = $null
        $script:BdoPreviewOutlinePath = $null
        $script:BdoPreviewText = $null
        $script:BdoTransitionPreviewGrid = $null
        $script:BdoTransitionPreviewOutlineTextBlocks = $null
        $script:BdoTransitionPreviewOutlinePath = $null
        $script:BdoTransitionPreviewText = $null
        $script:BossPreviewHostPanel = $null
        $script:SettingsOriginal = $null
        $script:SettingsDraft = $null
        $script:SettingsDirty = $false
        $script:SettingsCloseAction = $null
        $script:SyncingSettingsControls = $false
        $script:BossRowsEditorSignature = $null
    })

    $settings.Show() | Out-Null
}

