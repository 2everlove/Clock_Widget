# Clock Widget module: ClockWidget.ClockDisplay.ps1
# This file is dot-sourced by ClockWidget.ps1.

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

function Get-BackgroundBorderBrush {
    New-ColorBrushOrTransparent $script:BackgroundBorderColor "#000000" $script:BackgroundBorderColorTransparent
}

function Get-BackgroundBorderThickness {
    if ($script:BackgroundBorderColorTransparent) {
        return (New-Object System.Windows.Thickness 0)
    }

    $thickness = [double][Math]::Max(0, [Math]::Min(10, [int]$script:BackgroundBorderThickness))
    New-Object System.Windows.Thickness $thickness
}

function Get-BackgroundCornerRadiusValue {
    [double][Math]::Max(0, [Math]::Min(30, [int]$script:BackgroundBorderRadius))
}

function Get-BackgroundCornerRadius {
    New-Object System.Windows.CornerRadius (Get-BackgroundCornerRadiusValue)
}

function Apply-BackgroundCornerRadius {
    $radius = Get-BackgroundCornerRadiusValue
    if ($script:Border) {
        $script:Border.CornerRadius = New-Object System.Windows.CornerRadius $radius
    }
    if ($script:BackgroundLayer) {
        $script:BackgroundLayer.RadiusX = $radius
        $script:BackgroundLayer.RadiusY = $radius
    }
}

function Apply-BackgroundBorderStyle {
    if (-not $script:Border) {
        return
    }

    Apply-BackgroundCornerRadius

    if ($script:WidgetMoveMode) {
        $script:Border.BorderBrush = [System.Windows.Media.Brushes]::Black
        $script:Border.BorderThickness = New-Object System.Windows.Thickness 2
        return
    }

    $script:Border.BorderBrush = Get-BackgroundBorderBrush
    $script:Border.BorderThickness = Get-BackgroundBorderThickness
}

function Get-TextBrush {
    New-ColorBrushOrTransparent $script:TextColor "#FFFFFF" $script:TextColorTransparent
}

function Get-TextOutlineBrush {
    New-ColorBrushOrTransparent $script:TextOutlineColor "#000000" $script:TextOutlineColorTransparent
}

function Get-ClockDateTextBrush {
    New-ColorBrushOrTransparent $script:ClockDateTextColor "#FFFFFF" $script:ClockDateTextColorTransparent
}

function Get-ClockDateTextOutlineBrush {
    New-ColorBrushOrTransparent $script:ClockDateTextOutlineColor "#000000" $script:ClockDateTextOutlineColorTransparent
}

function Get-OutlineThickness {
    [double][Math]::Max(1.0, [Math]::Round($script:FontSize * 0.04, 1))
}

function Get-ClockDateOutlineThickness {
    [double][Math]::Max(0.75, [Math]::Round($script:ClockDateFontSize * 0.06, 1))
}

function New-TextOutlinePath {
    $path = New-Object System.Windows.Shapes.Path
    $path.Fill = [System.Windows.Media.Brushes]::Transparent
    $path.StrokeLineJoin = [System.Windows.Media.PenLineJoin]::Round
    $path.StrokeStartLineCap = [System.Windows.Media.PenLineCap]::Round
    $path.StrokeEndLineCap = [System.Windows.Media.PenLineCap]::Round
    $path.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $path.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $path.IsHitTestVisible = $false
    $path.Visibility = [System.Windows.Visibility]::Collapsed
    $path
}

function Update-TextOutlinePathGeometry {
    param(
        [System.Windows.Shapes.Path]$Path,
        [string]$Text,
        [string]$FontFamilyName,
        [double]$FontSize,
        [System.Windows.Thickness]$Margin,
        [double]$StrokeThickness,
        [System.Windows.Media.Brush]$StrokeBrush,
        [bool]$Visible
    )

    if (-not $Path) {
        return
    }

    if (-not $Visible -or [string]::IsNullOrEmpty($Text)) {
        $Path.Visibility = [System.Windows.Visibility]::Collapsed
        return
    }

    $fontFamily = New-Object System.Windows.Media.FontFamily $FontFamilyName
    $typeface = New-Object System.Windows.Media.Typeface $fontFamily, ([System.Windows.FontStyles]::Normal), ([System.Windows.FontWeights]::Bold), ([System.Windows.FontStretches]::Normal)
    $pixelsPerDip = 1.0
    if ($script:Window) {
        try {
            $pixelsPerDip = [System.Windows.Media.VisualTreeHelper]::GetDpi($script:Window).PixelsPerDip
        }
        catch {
            $pixelsPerDip = 1.0
        }
    }

    try {
        $formatted = New-Object System.Windows.Media.FormattedText $Text, ([System.Globalization.CultureInfo]::CurrentCulture), ([System.Windows.FlowDirection]::LeftToRight), $typeface, $FontSize, ([System.Windows.Media.Brushes]::Black), $pixelsPerDip
    }
    catch {
        $formatted = New-Object System.Windows.Media.FormattedText $Text, ([System.Globalization.CultureInfo]::CurrentCulture), ([System.Windows.FlowDirection]::LeftToRight), $typeface, $FontSize, ([System.Windows.Media.Brushes]::Black)
    }

    $geometry = $formatted.BuildGeometry((New-Object System.Windows.Point 0, 0))
    $bounds = $geometry.Bounds
    $geometry.Transform = New-Object System.Windows.Media.TranslateTransform (-$bounds.X), (-$bounds.Y)

    $Path.Data = $geometry
    $Path.Width = [double][Math]::Ceiling($bounds.Width)
    $Path.Height = [double][Math]::Ceiling($bounds.Height)
    $Path.Margin = $Margin
    $Path.Stroke = $StrokeBrush
    $Path.StrokeThickness = $StrokeThickness
    $Path.Visibility = [System.Windows.Visibility]::Visible
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

function New-ClockDateTextBlock {
    param([System.Windows.Media.Brush]$Brush)

    $block = New-Object System.Windows.Controls.TextBlock
    $block.Text = "2026/01/01 (목)"
    $block.FontFamily = New-Object System.Windows.Media.FontFamily $script:ClockDateFontFamily
    $block.FontSize = [double]$script:ClockDateFontSize
    $block.FontWeight = [System.Windows.FontWeights]::Bold
    $block.Foreground = $Brush
    $block.Margin = New-Object System.Windows.Thickness 0
    $block.LineHeight = [double]($script:ClockDateFontSize * 1.0)
    $block.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $block.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $block.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $block
}

function Get-ClockDateFormatPresets {
    @(
        [pscustomobject]@{ Label = "yyyy/MM/dd (ddd)"; Format = "yyyy/MM/dd (ddd)"; IsCustom = $false },
        [pscustomobject]@{ Label = "yyyy-MM-dd (ddd)"; Format = "yyyy-MM-dd (ddd)"; IsCustom = $false },
        [pscustomobject]@{ Label = "MM/dd (ddd)"; Format = "MM/dd (ddd)"; IsCustom = $false },
        [pscustomobject]@{ Label = "yyyy년 M월 d일 (ddd)"; Format = "yyyy년 M월 d일 (ddd)"; IsCustom = $false },
        [pscustomobject]@{ Label = "사용자 지정"; Format = ""; IsCustom = $true }
    )
}

function Get-DefaultClockDateFormat {
    "yyyy/MM/dd (ddd)"
}

function Get-NormalizedClockDateFormat {
    param([object]$Format)

    $value = [string]$Format
    if ([string]::IsNullOrWhiteSpace($value)) {
        return Get-DefaultClockDateFormat
    }
    $value.Trim()
}

function ConvertTo-ClockDateDotNetFormat {
    param([string]$Format)

    $normalized = Get-NormalizedClockDateFormat $Format
    $withDayTokens = $normalized.Replace("dddd", "{!!}").Replace("ddd", "{!}")
    $withDayTokens.Replace("/", "'/'")
}

function Format-ClockDateText {
    param(
        [datetime]$Value,
        [string]$Format
    )

    $shortDayLabels = @("일", "월", "화", "수", "목", "금", "토")
    $longDayLabels = @("일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일")
    $dayIndex = [int]$Value.DayOfWeek
    $formatForDotNet = ConvertTo-ClockDateDotNetFormat $Format
    $text = $Value.ToString($formatForDotNet, [System.Globalization.CultureInfo]::InvariantCulture)
    $text.Replace("{!!}", $longDayLabels[$dayIndex]).Replace("{!}", $shortDayLabels[$dayIndex])
}

function Test-ClockDateFormat {
    param([string]$Format)

    try {
        [void](Format-ClockDateText ([datetime]"2026-01-01 13:34:56") $Format)
        return $true
    }
    catch {
        return $false
    }
}

function Get-ClockDateText {
    param([datetime]$Value = (Get-Date))

    try {
        Format-ClockDateText $Value (Get-NormalizedClockDateFormat $script:ClockDateFormat)
    }
    catch {
        Format-ClockDateText $Value (Get-DefaultClockDateFormat)
    }
}

function Apply-ClockDateLayout {
    if (-not $script:ClockTextGrid -or -not $script:ClockDateTextGrid -or -not $script:ClockTimeTextGrid) {
        return
    }

    $script:ClockTextGrid.Children.Clear()
    if ($script:ClockDatePosition -eq "Inline") {
        $script:ClockTextGrid.Orientation = [System.Windows.Controls.Orientation]::Horizontal
        if ($script:ClockDateEnabled) {
            $script:ClockDateTextGrid.Margin = New-Object System.Windows.Thickness 0, 0, 8, 0
            $script:ClockTextGrid.Children.Add($script:ClockDateTextGrid) | Out-Null
        }
        $script:ClockTimeTextGrid.Margin = New-Object System.Windows.Thickness 0
        $script:ClockTextGrid.Children.Add($script:ClockTimeTextGrid) | Out-Null
        return
    }

    $script:ClockTextGrid.Orientation = [System.Windows.Controls.Orientation]::Vertical
    $script:ClockDateTextGrid.Margin = New-Object System.Windows.Thickness 0
    $script:ClockTimeTextGrid.Margin = New-Object System.Windows.Thickness 0
    if ($script:ClockDateEnabled -and $script:ClockDatePosition -eq "Above") {
        $script:ClockTextGrid.Children.Add($script:ClockDateTextGrid) | Out-Null
        $script:ClockTextGrid.Children.Add($script:ClockTimeTextGrid) | Out-Null
    }
    elseif ($script:ClockDateEnabled -and $script:ClockDatePosition -eq "Below") {
        $script:ClockTextGrid.Children.Add($script:ClockTimeTextGrid) | Out-Null
        $script:ClockTextGrid.Children.Add($script:ClockDateTextGrid) | Out-Null
    }
    else {
        $script:ClockTextGrid.Children.Add($script:ClockTimeTextGrid) | Out-Null
    }
}

function Apply-ClockDateStyle {
    if (-not $script:ClockDateTextBlock) {
        return
    }

    $fontFamily = New-Object System.Windows.Media.FontFamily $script:ClockDateFontFamily
    $lineHeight = [double]($script:ClockDateFontSize * 1.0)
    $outlineBrush = Get-ClockDateTextOutlineBrush
    $fillBrush = Get-ClockDateTextBrush
    $outlineThickness = Get-ClockDateOutlineThickness

    if ($script:ClockDateOutlineTextBlocks) {
        foreach ($item in $script:ClockDateOutlineTextBlocks) {
            $item.Block.FontFamily = $fontFamily
            $item.Block.FontSize = [double]$script:ClockDateFontSize
            $item.Block.LineHeight = $lineHeight
            $item.Block.Margin = New-Object System.Windows.Thickness 0
            $item.Block.Foreground = $outlineBrush
            $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $outlineThickness), ($item.Y * $outlineThickness)
            $item.Block.Visibility = if ($script:ClockDateTextColorTransparent -or $script:ClockDateTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
        }
    }

    if ($script:ClockDateOutlinePath) {
        Update-TextOutlinePathGeometry $script:ClockDateOutlinePath $script:ClockDateTextBlock.Text $script:ClockDateFontFamily ([double]$script:ClockDateFontSize) (New-Object System.Windows.Thickness 0) ([double]($outlineThickness * 1.8)) $outlineBrush ([bool]($script:ClockDateTextColorTransparent -and -not $script:ClockDateTextOutlineColorTransparent))
    }

    $script:ClockDateTextBlock.FontFamily = $fontFamily
    $script:ClockDateTextBlock.FontSize = [double]$script:ClockDateFontSize
    $script:ClockDateTextBlock.LineHeight = $lineHeight
    $script:ClockDateTextBlock.Margin = New-Object System.Windows.Thickness 0
    $script:ClockDateTextBlock.Foreground = $fillBrush
    $script:ClockDateTextBlock.Visibility = if ($script:ClockDateTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }

    if ($script:ClockDateTextGrid) {
        $script:ClockDateTextGrid.Visibility = if ($script:ClockDateEnabled -and -not ($script:ClockDateTextColorTransparent -and $script:ClockDateTextOutlineColorTransparent)) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    }
    Apply-ClockDateLayout
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
            $item.Block.Visibility = if ($script:TextColorTransparent -or $script:TextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
        }
    }

    if ($script:TextOutlinePath) {
        Update-TextOutlinePathGeometry $script:TextOutlinePath $script:TextBlock.Text $script:FontFamily ([double]$script:FontSize) $padding ([double]($outlineThickness * 1.8)) $outlineBrush ([bool]($script:TextColorTransparent -and -not $script:TextOutlineColorTransparent))
    }

    $script:TextBlock.FontFamily = $fontFamily
    $script:TextBlock.FontSize = [double]$script:FontSize
    $script:TextBlock.LineHeight = $lineHeight
    $script:TextBlock.Margin = $padding
    $script:TextBlock.Foreground = $fillBrush
    $script:TextBlock.Visibility = if ($script:TextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }

    Apply-BossAlertStyle
    Apply-ClockDateStyle
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

function Update-ClockText {
    if ($script:TextBlock) {
        $text = Get-ClockText
        if ($script:OutlineTextBlocks) {
            foreach ($item in $script:OutlineTextBlocks) {
                $item.Block.Text = $text
            }
        }
        if ($script:TextOutlinePath) {
            Update-TextOutlinePathGeometry $script:TextOutlinePath $text $script:FontFamily ([double]$script:FontSize) (Get-WidgetPadding $script:FontSize) ([double]((Get-OutlineThickness) * 1.8)) (Get-TextOutlineBrush) ([bool]($script:TextColorTransparent -and -not $script:TextOutlineColorTransparent))
        }
        $script:TextBlock.Text = $text
    }

    if ($script:ClockDateTextBlock) {
        $dateText = Get-ClockDateText
        if ($script:ClockDateOutlineTextBlocks) {
            foreach ($item in $script:ClockDateOutlineTextBlocks) {
                $item.Block.Text = $dateText
            }
        }
        if ($script:ClockDateOutlinePath) {
            Update-TextOutlinePathGeometry $script:ClockDateOutlinePath $dateText $script:ClockDateFontFamily ([double]$script:ClockDateFontSize) (New-Object System.Windows.Thickness 0) ([double]((Get-ClockDateOutlineThickness) * 1.8)) (Get-ClockDateTextOutlineBrush) ([bool]($script:ClockDateTextColorTransparent -and -not $script:ClockDateTextOutlineColorTransparent))
        }
        $script:ClockDateTextBlock.Text = $dateText
    }

    if ($script:BdoTimeTextBlock) {
        $bdoText = Get-BdoGameTimeText
        if ($script:BdoOutlineTextBlocks) {
            foreach ($item in $script:BdoOutlineTextBlocks) {
                $item.Block.Text = $bdoText
            }
        }
        if ($script:BdoTimeOutlinePath) {
            Update-TextOutlinePathGeometry $script:BdoTimeOutlinePath $bdoText $script:BdoFontFamily ([double]$script:BdoFontSize) (New-Object System.Windows.Thickness 0) ([double]((Get-BdoOutlineThickness) * 1.8)) (Get-BdoTextOutlineBrush) ([bool]($script:BdoTextColorTransparent -and -not $script:BdoTextOutlineColorTransparent))
        }
        $script:BdoTimeTextBlock.Text = $bdoText
    }
    if ($script:BdoTransitionTextBlock) {
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled) {
            $transitionText = Get-BdoTransitionText
            if ($script:BdoTransitionOutlineTextBlocks) {
                foreach ($item in $script:BdoTransitionOutlineTextBlocks) {
                    $item.Block.Text = $transitionText
                }
            }
            if ($script:BdoTransitionOutlinePath) {
                $transitionFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BdoTransitionFontSize))
                $transitionOutlineThickness = [double][Math]::Max(0.75, [Math]::Round($transitionFontSize * 0.06, 1))
                Update-TextOutlinePathGeometry $script:BdoTransitionOutlinePath $transitionText $script:BdoTransitionFontFamily $transitionFontSize (New-Object System.Windows.Thickness 0) ([double]($transitionOutlineThickness * 1.8)) (Get-BdoTransitionTextOutlineBrush) ([bool]($script:BdoTransitionTextColorTransparent -and -not $script:BdoTransitionTextOutlineColorTransparent))
            }
            $script:BdoTransitionTextBlock.Text = $transitionText
            if ($script:BdoTransitionTextGrid) {
                $script:BdoTransitionTextGrid.Visibility = if ($script:BdoTransitionTextColorTransparent -and $script:BdoTransitionTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
            }
            $script:BdoTransitionTextBlock.Visibility = if ($script:BdoTransitionTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
        }
        else {
            if ($script:BdoTransitionOutlineTextBlocks) {
                foreach ($item in $script:BdoTransitionOutlineTextBlocks) {
                    $item.Block.Text = ""
                }
            }
            if ($script:BdoTransitionOutlinePath) {
                $script:BdoTransitionOutlinePath.Visibility = [System.Windows.Visibility]::Collapsed
            }
            $script:BdoTransitionTextBlock.Text = ""
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
            if ($script:BdoTransitionTextGrid) {
                $script:BdoTransitionTextGrid.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }
    }

    Update-BossAlertDisplay
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

function Set-BackgroundBorderColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "BackgroundBorderColor" $Value) {
        return
    }

    $script:BackgroundBorderColor = $Value
    Apply-BackgroundBorderStyle
    if ($script:BackgroundBorderColorText) {
        $script:BackgroundBorderColorText.Text = $script:BackgroundBorderColor
    }
    Set-ColorSwatch $script:BackgroundBorderColorSwatch $script:BackgroundBorderColor $script:BackgroundBorderColorTransparent
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BackgroundBorderThickness {
    param([int]$Value)

    $nextValue = [Math]::Max(0, [Math]::Min(10, $Value))
    if (Set-SettingsDraftValue "BackgroundBorderThickness" $nextValue) {
        return
    }

    $script:BackgroundBorderThickness = $nextValue
    Apply-BackgroundBorderStyle
    if ($script:BackgroundBorderThicknessSlider) {
        $script:BackgroundBorderThicknessSlider.Value = [double]$script:BackgroundBorderThickness
    }
    if ($script:BackgroundBorderThicknessValueText) {
        $script:BackgroundBorderThicknessValueText.Text = [string]$script:BackgroundBorderThickness
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-BackgroundBorderRadius {
    param([int]$Value)

    $nextValue = [Math]::Max(0, [Math]::Min(30, $Value))
    if (Set-SettingsDraftValue "BackgroundBorderRadius" $nextValue) {
        return
    }

    $script:BackgroundBorderRadius = $nextValue
    Apply-BackgroundCornerRadius
    if ($script:BackgroundBorderRadiusSlider) {
        $script:BackgroundBorderRadiusSlider.Value = [double]$script:BackgroundBorderRadius
    }
    if ($script:BackgroundBorderRadiusValueText) {
        $script:BackgroundBorderRadiusValueText.Text = [string]$script:BackgroundBorderRadius
    }
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
        { $_ -in @("ClockDateTextColorTransparent", "ClockDateTextOutlineColorTransparent") } {
            Apply-ClockDateStyle
        }
        "BackgroundBorderColorTransparent" {
            Apply-BackgroundBorderStyle
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

function Set-ClockDateEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "ClockDateEnabled" $Value) {
        return
    }

    $script:ClockDateEnabled = $Value
    Apply-ClockDateStyle
    Update-ClockText
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDatePosition {
    param([string]$Value)

    $nextValue = if (@("Above", "Below", "Inline") -contains $Value) { $Value } else { "Above" }
    if (Set-SettingsDraftValue "ClockDatePosition" $nextValue) {
        return
    }

    $script:ClockDatePosition = $nextValue
    Apply-ClockDateLayout
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDateFormat {
    param([string]$Value)

    $nextValue = Get-NormalizedClockDateFormat $Value
    if (Set-SettingsDraftValue "ClockDateFormat" $nextValue) {
        return
    }

    $script:ClockDateFormat = $nextValue
    Update-ClockText
    if (Get-Command Update-ClockDateFormatValidation -ErrorAction SilentlyContinue) {
        Update-ClockDateFormatValidation
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDateFontSize {
    param([int]$Value)

    $nextValue = [Math]::Max(8, [Math]::Min(72, $Value))
    if (Set-SettingsDraftValue "ClockDateFontSize" $nextValue) {
        return
    }

    $script:ClockDateFontSize = $nextValue
    Apply-ClockDateStyle
    if ($script:ClockDateFontSizeSlider) {
        $script:ClockDateFontSizeSlider.Value = [double]$script:ClockDateFontSize
    }
    if ($script:ClockDateFontSizeValueText) {
        $script:ClockDateFontSizeValueText.Text = [string]$script:ClockDateFontSize
    }
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDateTextColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "ClockDateTextColor" $Value) {
        return
    }

    $script:ClockDateTextColor = $Value
    Apply-ClockDateStyle
    if ($script:ClockDateTextColorText) {
        $script:ClockDateTextColorText.Text = $script:ClockDateTextColor
    }
    Set-ColorSwatch $script:ClockDateTextColorSwatch $script:ClockDateTextColor $script:ClockDateTextColorTransparent
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDateTextOutlineColor {
    param([string]$Value)

    if (Set-SettingsDraftValue "ClockDateTextOutlineColor" $Value) {
        return
    }

    $script:ClockDateTextOutlineColor = $Value
    Apply-ClockDateStyle
    if ($script:ClockDateTextOutlineColorText) {
        $script:ClockDateTextOutlineColorText.Text = $script:ClockDateTextOutlineColor
    }
    Set-ColorSwatch $script:ClockDateTextOutlineColorSwatch $script:ClockDateTextOutlineColor $script:ClockDateTextOutlineColorTransparent
    Sync-TransparentColorControls
    Update-SettingsPreview
    Save-WidgetConfig
}

function Set-ClockDateFontFamily {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    if (Set-SettingsDraftValue "ClockDateFontFamily" $Value) {
        return
    }

    $script:ClockDateFontFamily = $Value
    Apply-ClockDateStyle
    if ($script:ClockDateFontFamilyText) {
        Set-FontValueText $script:ClockDateFontFamilyText $script:ClockDateFontFamily
    }
    Update-SettingsPreview
    Save-WidgetConfig
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

function Show-BackgroundBorderColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "BackgroundBorderColor" $script:BackgroundBorderColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-BackgroundBorderColor (ConvertTo-HexColor $dialog.Color)
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

function Show-ClockDateTextColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "ClockDateTextColor" $script:ClockDateTextColor) "#FFFFFF"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-ClockDateTextColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-ClockDateTextOutlineColorDialog {
    $dialog = New-Object System.Windows.Forms.ColorDialog
    $dialog.AllowFullOpen = $true
    $dialog.FullOpen = $true
    $dialog.Color = ConvertTo-DrawingColor (Get-DialogSettingValue "ClockDateTextOutlineColor" $script:ClockDateTextOutlineColor) "#000000"

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-ClockDateTextOutlineColor (ConvertTo-HexColor $dialog.Color)
    }
}

function Show-ClockDateFontDialog {
    $dialog = New-Object System.Windows.Forms.FontDialog
    $dialog.ShowColor = $false
    $dialog.ShowEffects = $false
    $dialog.FontMustExist = $true
    $dialog.Font = New-Object System.Drawing.Font (Get-DialogSettingValue "ClockDateFontFamily" $script:ClockDateFontFamily), ([float](Get-DialogSettingValue "ClockDateFontSize" $script:ClockDateFontSize)), ([System.Drawing.FontStyle]::Bold)

    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-ClockDateFontFamily $dialog.Font.FontFamily.Name
        Set-ClockDateFontSize ([int][Math]::Round($dialog.Font.SizeInPoints))
    }
}

