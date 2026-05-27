# Clock Widget module: ClockWidget.BdoTime.ps1
# This file is dot-sourced by ClockWidget.ps1.

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

    $outline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 20, 20, 24)), 3
    $softOutline = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 20, 20, 24)), 2
    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $blue = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 198, 234, 252))
    $blueShadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 132, 205, 238))
    $pink = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 222, 226))
    $green = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 177, 199, 158))
    $dark = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 15, 15, 20))
    $mouthBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 150, 112))
    $hatBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 118, 114, 139))
    $hatShade = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 45, 43, 65))
    $hatBadge = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 247, 221, 190))
    $hatLine = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 3
    $cyanPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(150, 112, 210, 242)), 4

    $leftEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $leftEar.StartFigure()
    $leftEar.AddBezier(29, 38, 13, 32, 15, 9, 28, 5)
    $leftEar.AddBezier(28, 5, 37, 10, 44, 27, 49, 37)
    $leftEar.AddBezier(49, 37, 43, 40, 35, 40, 29, 38)
    $leftEar.CloseFigure()
    $rightEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rightEar.StartFigure()
    $rightEar.AddBezier(67, 38, 83, 32, 81, 9, 68, 5)
    $rightEar.AddBezier(68, 5, 59, 10, 52, 27, 47, 37)
    $rightEar.AddBezier(47, 37, 53, 40, 61, 40, 67, 38)
    $rightEar.CloseFigure()
    $leftInnerEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $leftInnerEar.AddBezier(26, 33, 20, 25, 22, 13, 29, 10)
    $leftInnerEar.AddBezier(29, 10, 34, 16, 38, 27, 40, 34)
    $rightInnerEar = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rightInnerEar.AddBezier(70, 33, 76, 25, 74, 13, 67, 10)
    $rightInnerEar.AddBezier(67, 10, 62, 16, 58, 27, 56, 34)

    $tail = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tail.StartFigure()
    $tail.AddBezier(68, 67, 83, 65, 88, 78, 80, 87)
    $tail.AddBezier(80, 87, 74, 83, 67, 78, 61, 72)
    $tail.CloseFigure()
    $graphics.FillPath($pink, $tail)
    $graphics.DrawPath($softOutline, $tail)

    $graphics.FillPath($white, $leftEar)
    $graphics.FillPath($white, $rightEar)
    $graphics.DrawPath($pink, $leftInnerEar)
    $graphics.DrawPath($pink, $rightInnerEar)
    $graphics.DrawPath($outline, $leftEar)
    $graphics.DrawPath($outline, $rightEar)

    $graphics.FillEllipse($white, 20, 28, 56, 55)
    $graphics.DrawEllipse($outline, 20, 28, 56, 55)

    $mask = New-Object System.Drawing.Drawing2D.GraphicsPath
    $mask.StartFigure()
    $mask.AddBezier(24, 39, 34, 30, 62, 30, 73, 39)
    $mask.AddBezier(73, 39, 69, 54, 32, 55, 23, 43)
    $mask.CloseFigure()
    $graphics.FillPath($blue, $mask)
    $graphics.FillEllipse($blueShadow, 65, 43, 7, 13)

    $scarf = New-Object System.Drawing.Drawing2D.GraphicsPath
    $scarf.StartFigure()
    $scarf.AddBezier(27, 61, 37, 69, 59, 69, 69, 61)
    $scarf.AddBezier(69, 61, 66, 75, 31, 75, 27, 61)
    $scarf.CloseFigure()
    $graphics.FillPath($green, $scarf)

    $leftArmPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), 10
    $leftArmPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $leftArmPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($leftArmPen, 26, 61, 16, 51)
    $graphics.DrawLine($leftArmPen, 70, 61, 80, 51)
    $graphics.DrawLine($softOutline, 21, 58, 15, 52)
    $graphics.DrawLine($softOutline, 75, 58, 81, 52)
    $graphics.FillEllipse($pink, 76, 49, 6, 6)

    $graphics.FillEllipse($dark, 34, 44, 5, 10)
    $graphics.FillEllipse($dark, 57, 44, 5, 10)
    $graphics.FillEllipse($dark, 45, 48, 6, 5)
    $graphics.FillEllipse($mouthBrush, 42, 51, 12, 17)
    $graphics.DrawEllipse($softOutline, 42, 51, 12, 17)
    $graphics.FillEllipse($white, 30, 39, 7, 5)
    $graphics.FillEllipse($white, 59, 39, 7, 5)

    $hat = New-Object System.Drawing.Drawing2D.GraphicsPath
    $hat.StartFigure()
    $hat.AddBezier(33, 29, 35, 17, 58, 15, 68, 26)
    $hat.AddBezier(68, 26, 58, 32, 42, 34, 33, 29)
    $hat.CloseFigure()
    $hatBrim = New-Object System.Drawing.Drawing2D.GraphicsPath
    $hatBrim.StartFigure()
    $hatBrim.AddBezier(28, 31, 38, 26, 63, 27, 72, 33)
    $hatBrim.AddBezier(72, 33, 61, 37, 39, 36, 28, 31)
    $hatBrim.CloseFigure()
    $graphics.FillPath($hatBrush, $hat)
    $graphics.FillPath($hatShade, $hatBrim)
    $graphics.DrawPath($outline, $hat)
    $graphics.DrawPath($outline, $hatBrim)
    $graphics.DrawArc($hatLine, 33, 28, 36, 8, 185, 160)
    $graphics.FillEllipse($hatBadge, 43, 20, 7, 10)
    $graphics.DrawArc($cyanPen, 23, 39, 15, 24, 165, 60)

    $bitmap.Save($script:BdoPapuIconPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $leftEar.Dispose()
    $rightEar.Dispose()
    $leftInnerEar.Dispose()
    $rightInnerEar.Dispose()
    $tail.Dispose()
    $mask.Dispose()
    $scarf.Dispose()
    $hat.Dispose()
    $hatBrim.Dispose()
    $outline.Dispose()
    $softOutline.Dispose()
    $white.Dispose()
    $blue.Dispose()
    $blueShadow.Dispose()
    $pink.Dispose()
    $green.Dispose()
    $dark.Dispose()
    $mouthBrush.Dispose()
    $hatBrush.Dispose()
    $hatShade.Dispose()
    $hatBadge.Dispose()
    $hatLine.Dispose()
    $cyanPen.Dispose()
    $leftArmPen.Dispose()
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

function Get-BdoOutlineThickness {
    [double][Math]::Max(0.75, [Math]::Round($script:BdoFontSize * 0.06, 1))
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

function New-BdoTransitionTextBlock {
    param([System.Windows.Media.Brush]$Brush)

    $block = New-Object System.Windows.Controls.TextBlock
    $block.Text = ""
    $block.FontFamily = New-Object System.Windows.Media.FontFamily $script:BdoTransitionFontFamily
    $block.FontSize = [double]$script:BdoTransitionFontSize
    $block.FontWeight = [System.Windows.FontWeights]::Bold
    $block.Foreground = $Brush
    $block.Margin = New-Object System.Windows.Thickness 0
    $block.LineHeight = [double]($script:BdoTransitionFontSize * 1.0)
    $block.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    $block.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $block.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $block
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
            $item.Block.Visibility = if ($script:BdoTextColorTransparent -or $script:BdoTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
        }
    }
    if ($script:BdoTimeOutlinePath) {
        Update-TextOutlinePathGeometry $script:BdoTimeOutlinePath $script:BdoTimeTextBlock.Text $script:BdoFontFamily ([double]$script:BdoFontSize) (New-Object System.Windows.Thickness 0) ([double]($outlineThickness * 1.8)) $outlineBrush ([bool]($script:BdoTextColorTransparent -and -not $script:BdoTextOutlineColorTransparent))
    }

    $script:BdoTimeTextBlock.FontFamily = $fontFamily
    $script:BdoTimeTextBlock.FontSize = [double]$script:BdoFontSize
    $script:BdoTimeTextBlock.LineHeight = $lineHeight
    $script:BdoTimeTextBlock.Foreground = $fillBrush
    $script:BdoTimeTextBlock.Visibility = if ($script:BdoTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
    $script:BdoTimePanel.Margin = New-Object System.Windows.Thickness 0, ([Math]::Max(2, [Math]::Round($script:BdoFontSize * 0.10))), 0, -2

    if ($script:BdoTransitionTextBlock) {
        $transitionFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BdoTransitionFontSize))
        $transitionFontFamily = New-Object System.Windows.Media.FontFamily $script:BdoTransitionFontFamily
        $transitionLineHeight = [double]($transitionFontSize * 1.0)
        $transitionMargin = New-Object System.Windows.Thickness 0
        $transitionOutlineBrush = Get-BdoTransitionTextOutlineBrush
        $transitionOutlineThickness = [double][Math]::Max(0.75, [Math]::Round($transitionFontSize * 0.06, 1))
        if ($script:BdoTransitionOutlineTextBlocks) {
            foreach ($item in $script:BdoTransitionOutlineTextBlocks) {
                $item.Block.FontFamily = $transitionFontFamily
                $item.Block.FontSize = $transitionFontSize
                $item.Block.LineHeight = $transitionLineHeight
                $item.Block.Margin = $transitionMargin
                $item.Block.Foreground = $transitionOutlineBrush
                $item.Block.RenderTransform = New-Object System.Windows.Media.TranslateTransform ($item.X * $transitionOutlineThickness), ($item.Y * $transitionOutlineThickness)
                $item.Block.Visibility = if ($script:BdoTransitionTextColorTransparent -or $script:BdoTransitionTextOutlineColorTransparent) { [System.Windows.Visibility]::Collapsed } else { [System.Windows.Visibility]::Visible }
            }
        }
        if ($script:BdoTransitionOutlinePath) {
            Update-TextOutlinePathGeometry $script:BdoTransitionOutlinePath $script:BdoTransitionTextBlock.Text $script:BdoTransitionFontFamily $transitionFontSize $transitionMargin ([double]($transitionOutlineThickness * 1.8)) $transitionOutlineBrush ([bool]($script:BdoTransitionTextColorTransparent -and -not $script:BdoTransitionTextOutlineColorTransparent))
        }
        $script:BdoTransitionTextBlock.FontFamily = $transitionFontFamily
        $script:BdoTransitionTextBlock.FontSize = $transitionFontSize
        $script:BdoTransitionTextBlock.LineHeight = $transitionLineHeight
        $script:BdoTransitionTextBlock.Foreground = Get-BdoTransitionTextBrush
        $script:BdoTransitionTextBlock.Margin = $transitionMargin
        $script:BdoTransitionTextBlock.Visibility = if ($script:BdoTransitionTextColorTransparent) { [System.Windows.Visibility]::Hidden } else { [System.Windows.Visibility]::Visible }
        $script:BdoTransitionTextBlock.Effect = $null
        if ($script:BdoTransitionTextGrid) {
            $script:BdoTransitionTextGrid.Margin = New-Object System.Windows.Thickness 6, 0, 0, 0
        }
        if ($script:BdoTimeEnabled -and $script:BdoTransitionEnabled -and -not ($script:BdoTransitionTextColorTransparent -and $script:BdoTransitionTextOutlineColorTransparent)) {
            if ($script:BdoTransitionTextGrid) {
                $script:BdoTransitionTextGrid.Visibility = [System.Windows.Visibility]::Visible
            }
            $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Visible
            if ($script:BdoTransitionTextColorTransparent) {
                $script:BdoTransitionTextBlock.Visibility = [System.Windows.Visibility]::Hidden
            }
        }
        else {
            if ($script:BdoTransitionTextGrid) {
                $script:BdoTransitionTextGrid.Visibility = [System.Windows.Visibility]::Collapsed
            }
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
        $nextLabel = "아침까지"
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

