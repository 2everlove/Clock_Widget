# Clock Widget module: ClockWidget.BossAlert.ps1
# This file is dot-sourced by ClockWidget.ps1.

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

function Get-DefaultBossRows {
    $priorityByName = @{
        "불가살" = 0
        "우투리" = 0
        "금돼지왕" = 0
        "산군" = 0
        "귄트" = 0
        "가모스" = 0
        "벨" = 0
        "검은그림자" = 0
        "크자카" = 1
        "누베르" = 1
        "오핀" = 1
        "카란다" = 1
        "쿠툼" = 1
        "무라카" = 1
    }
    $schedule = @(
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
    $dayKeys = @((Get-BossDayDefinitions | ForEach-Object { $_.Key }))
    $rowsByName = [ordered]@{}

    foreach ($entry in $schedule) {
        foreach ($day in $dayKeys) {
            $bossText = [string]$entry.$day
            if ([string]::IsNullOrWhiteSpace($bossText)) {
                continue
            }
            foreach ($bossName in @($bossText -split '\s*/\s*' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
                if (-not $rowsByName.Contains($bossName)) {
                    $dayTimes = [ordered]@{}
                    foreach ($key in $dayKeys) {
                        $dayTimes[$key] = @()
                    }
                    $rowsByName[$bossName] = [ordered]@{
                        Name = $bossName
                        Days = @()
                        Times = @()
                        DayTimes = $dayTimes
                        Priority = if ($priorityByName.ContainsKey($bossName)) { [int]$priorityByName[$bossName] } else { 10 }
                        Highlight = $false
                        Alert = $true
                    }
                }
                $row = $rowsByName[$bossName]
                $row.DayTimes[$day] = @($row.DayTimes[$day]) + [string]$entry.Time
            }
        }
    }

    $rowsByName.Values | ForEach-Object {
        $row = $_
        [pscustomobject]@{
            Name = [string]$row.Name
            Days = @($dayKeys | Where-Object { @($row.DayTimes[$_]).Count -gt 0 })
            Times = @($row.DayTimes.Values | ForEach-Object { $_ } | Sort-Object -Unique)
            DayTimes = [pscustomobject]$row.DayTimes
            Priority = [int]$row.Priority
            Highlight = [bool]$row.Highlight
            Alert = [bool]$row.Alert
        }
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

function Apply-BossAlertStyle {
    if (-not $script:BossAlertPanel -and -not $script:BossAlertTextBlock) {
        return
    }

    $bossFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))
    if ($script:BossAlertPanel) {
        $script:BossAlertPanel.Margin = New-Object System.Windows.Thickness 2, $script:BossMarginTop, 2, $script:BossMarginBottom
        foreach ($child in @($script:BossAlertPanel.Children)) {
            if ($child -is [System.Windows.Controls.Border] -and $child.Tag -and $child.Tag.TextBlock) {
                Apply-BossAlertTextBlockStyle $child.Tag.TextBlock $bossFontSize
                if ($child.Tag.BossNameTextBlocks) {
                    foreach ($nameText in @($child.Tag.BossNameTextBlocks)) {
                        $nameText.FontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
                        $nameText.FontSize = $bossFontSize
                        $nameText.Foreground = Get-BossTextBrush
                        $nameText.LineHeight = [double]($bossFontSize * 1.2)
                    }
                }
                if ($child.Tag.OutlinePath -and $child.Tag.PlainText) {
                    Update-TextOutlinePathGeometry $child.Tag.OutlinePath ([string]$child.Tag.PlainText) $script:BossFontFamily $bossFontSize (New-Object System.Windows.Thickness 0) ([double]([Math]::Max(0.75, [Math]::Round($bossFontSize * 0.06, 1)) * 1.8)) (Get-BossTextOutlineBrush) ([bool]($script:BossTextColorTransparent -and -not $script:BossTextOutlineColorTransparent))
                }
                if ($child.Tag -and $child.Tag.WidthTexts) {
                    $reservedWidth = Get-BossAlertReservedWidth $child.Tag.WidthTexts $child.Tag.BossParts
                    $child.Width = $reservedWidth
                    $child.MinWidth = $reservedWidth
                    if ($child.Child) {
                        $child.Child.Width = $reservedWidth
                        $child.Child.MinWidth = $reservedWidth
                    }
                    $child.Tag.TextBlock.Width = $reservedWidth
                    $child.Tag.TextBlock.MinWidth = $reservedWidth
                }
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
    if ($script:BossTextColorTransparent) {
        $TextBlock.Effect = $null
    }
    else {
        $TextBlock.Effect = New-Object System.Windows.Media.Effects.DropShadowEffect -Property @{
            Color = (ConvertTo-WpfColor $script:BossTextOutlineColor "#000000")
            BlurRadius = 0
            ShadowDepth = 1
            Opacity = (Get-OutlineEffectOpacity $script:BossTextOutlineColorTransparent)
        }
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
        $FillElement.Opacity = 0.0
        $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
        $animation.From = 0.0
        $animation.To = 1.0
        $animation.Duration = New-Object System.Windows.Duration ([TimeSpan]::FromSeconds($seconds))
        $animation.AutoReverse = $true
        $animation.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        $animation.EasingFunction = New-Object System.Windows.Media.Animation.SineEase -Property @{
            EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut
        }
        $FillElement.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $animation)
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

function Measure-BossAlertDisplayTextWidth {
    param(
        [string]$Text,
        [object]$BossParts = @()
    )

    $fontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))
    $fontFamily = New-Object System.Windows.Media.FontFamily $script:BossFontFamily
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
        $formatted = New-Object System.Windows.Media.FormattedText $Text, ([System.Globalization.CultureInfo]::CurrentCulture), ([System.Windows.FlowDirection]::LeftToRight), $typeface, $fontSize, ([System.Windows.Media.Brushes]::Black), $pixelsPerDip
    }
    catch {
        $formatted = New-Object System.Windows.Media.FormattedText $Text, ([System.Globalization.CultureInfo]::CurrentCulture), ([System.Windows.FlowDirection]::LeftToRight), $typeface, $fontSize, ([System.Windows.Media.Brushes]::Black)
    }

    $highlightPadding = @($BossParts | Where-Object { [bool]$_.Highlight }).Count * 4.0
    [double][Math]::Ceiling($formatted.WidthIncludingTrailingWhitespace + $highlightPadding + 8.0)
}

function Get-BossAlertReservedWidth {
    param(
        [object]$WidthTexts,
        [object]$BossParts = @()
    )

    $maxWidth = 0.0
    foreach ($candidate in @($WidthTexts)) {
        if ([string]::IsNullOrWhiteSpace([string]$candidate)) {
            continue
        }
        $maxWidth = [Math]::Max($maxWidth, (Measure-BossAlertDisplayTextWidth ([string]$candidate) $BossParts))
    }
    [double][Math]::Max(1.0, $maxWidth)
}

function New-BossAlertDisplayItem {
    param(
        [string]$Text,
        [object]$BossParts = @(),
        [string]$StableKey = $Text,
        [object]$WidthTexts = @($Text)
    )

    $border = New-Object System.Windows.Controls.Border
    $border.CornerRadius = New-Object System.Windows.CornerRadius 3
    $border.Padding = New-Object System.Windows.Thickness 0
    $border.Margin = New-Object System.Windows.Thickness 0, 0, 0, 1
    $border.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $border.Uid = $StableKey
    $border.Background = [System.Windows.Media.Brushes]::Transparent

    $itemGrid = New-Object System.Windows.Controls.Grid
    $itemGrid.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $itemGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

    $outlinePath = New-TextOutlinePath
    $itemGrid.Children.Add($outlinePath) | Out-Null

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.FontWeight = [System.Windows.FontWeights]::Bold
    $textBlock.TextAlignment = [System.Windows.TextAlignment]::Center
    $textBlock.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
    $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $textBlock.LineStackingStrategy = [System.Windows.LineStackingStrategy]::BlockLineHeight
    Apply-BossAlertTextBlockStyle $textBlock

    $reservedWidth = Get-BossAlertReservedWidth $WidthTexts $BossParts
    $border.Width = $reservedWidth
    $border.MinWidth = $reservedWidth
    $itemGrid.Width = $reservedWidth
    $itemGrid.MinWidth = $reservedWidth
    $textBlock.Width = $reservedWidth
    $textBlock.MinWidth = $reservedWidth

    $nameTextBlocks = @()
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
                $nameBorder.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

                $nameGrid = New-Object System.Windows.Controls.Grid
                $nameGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
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
                $nameText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
                $nameGrid.Children.Add($nameText) | Out-Null
                $nameTextBlocks += $nameText
                $nameBorder.Child = $nameGrid
                Start-BossHighlightAnimation $nameBorder $fill
                $nameInline = New-Object System.Windows.Documents.InlineUIContainer $nameBorder
                $nameInline.BaselineAlignment = [System.Windows.BaselineAlignment]::Center
                $textBlock.Inlines.Add($nameInline) | Out-Null
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

    $itemGrid.Children.Add($textBlock) | Out-Null
    $border.Child = $itemGrid
    Update-TextOutlinePathGeometry $outlinePath $Text $script:BossFontFamily ([double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))) (New-Object System.Windows.Thickness 0) ([double]([Math]::Max(0.75, [Math]::Round([double]$script:BossFontSize * 0.06, 1)) * 1.8)) (Get-BossTextOutlineBrush) ([bool]($script:BossTextColorTransparent -and -not $script:BossTextOutlineColorTransparent))
    $border.Tag = [pscustomobject]@{
        TextBlock = $textBlock
        SuffixRun = $suffixRun
        HasBossParts = (@($BossParts).Count -gt 0)
        WidthTexts = @($WidthTexts)
        BossParts = @($BossParts)
        BossNameTextBlocks = @($nameTextBlocks)
        OutlinePath = $outlinePath
        PlainText = $Text
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
    if ([string]$Item.Tag.PlainText -eq [string]$Text) {
        return
    }

    if ([bool]$Item.Tag.HasBossParts -and $Item.Tag.SuffixRun) {
        $suffix = $Text -replace '^\[[^\]]+\]', ''
        $Item.Tag.SuffixRun.Text = "]$suffix"
    }
    elseif ($Item.Tag.TextBlock) {
        $Item.Tag.TextBlock.Text = $Text
    }
    $Item.Tag.PlainText = $Text
    if ($Item.Tag.OutlinePath) {
        $bossFontSize = [double][Math]::Max(8, [Math]::Min(48, $script:BossFontSize))
        Update-TextOutlinePathGeometry $Item.Tag.OutlinePath $Text $script:BossFontFamily $bossFontSize (New-Object System.Windows.Thickness 0) ([double]([Math]::Max(0.75, [Math]::Round($bossFontSize * 0.06, 1)) * 1.8)) (Get-BossTextOutlineBrush) ([bool]($script:BossTextColorTransparent -and -not $script:BossTextOutlineColorTransparent))
    }
}

function Reset-BossAlertRuntimeCache {
    $version = 0
    if ($null -ne $script:BossAlertRuntimeVersion) {
        $version = [int]$script:BossAlertRuntimeVersion
    }
    $script:BossAlertRuntimeVersion = $version + 1
    $script:BossAlertItemsCacheKey = $null
    $script:BossAlertItemsCache = $null
    $script:BossAlertDisplayUpdateKey = $null
}

function Get-BossAlertRuntimeVersion {
    if ($null -eq $script:BossAlertRuntimeVersion) {
        $script:BossAlertRuntimeVersion = 0
    }
    [int]$script:BossAlertRuntimeVersion
}

function Get-CachedBossAlertItems {
    param([datetime]$Now = (Get-Date))

    $cacheKey = "{0:yyyyMMddHHmmss}|{1}" -f $Now, (Get-BossAlertRuntimeVersion)
    if ($script:BossAlertItemsCacheKey -eq $cacheKey -and $null -ne $script:BossAlertItemsCache) {
        return @($script:BossAlertItemsCache)
    }

    $items = @(Get-BossAlertItems $Now)
    $script:BossAlertItemsCacheKey = $cacheKey
    $script:BossAlertItemsCache = @($items)
    @($items)
}

function Update-BossAlertDisplay {
    param(
        [datetime]$Now = (Get-Date),
        [bool]$Force = $false
    )

    $updateKey = "{0:yyyyMMddHHmmss}|{1}" -f $Now, (Get-BossAlertRuntimeVersion)
    if (-not $Force -and $script:BossAlertDisplayUpdateKey -eq $updateKey) {
        return
    }
    $script:BossAlertDisplayUpdateKey = $updateKey

    if ($script:BossAlertPanel) {
        if (-not $script:BossAlertEnabled) {
            if ($script:BossAlertPanel.Children.Count -gt 0) {
                $script:BossAlertPanel.Children.Clear()
            }
            $script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $bossAlerts = @(Get-CachedBossAlertItems $Now)
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
                    $script:BossAlertPanel.Children.Add((New-BossAlertDisplayItem $alert.Text $alert.BossParts $alert.Key $alert.WidthTexts)) | Out-Null
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
            if ($script:BossAlertPanel.Children.Count -gt 0) {
                $script:BossAlertPanel.Children.Clear()
            }
            $script:BossAlertPanel.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
    elseif ($script:BossAlertTextBlock) {
        if (-not $script:BossAlertEnabled) {
            $script:BossAlertTextBlock.Text = ""
            $script:BossAlertTextBlock.Visibility = [System.Windows.Visibility]::Collapsed
            return
        }

        $bossAlerts = @(Get-CachedBossAlertItems $Now | ForEach-Object { $_.Text })
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

function Get-BossScheduleEventsForDay {
    param([System.DayOfWeek]$DayOfWeek)

    $dayKey = Get-BossDayKey $DayOfWeek
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
        $widthTexts = @($text)
        if ($first.State -eq "before") {
            $durationCandidates = @(
                [int]$first.DeltaSeconds,
                [int]$beforeSeconds,
                [int][Math]::Max(0, $beforeSeconds - 1),
                [int][Math]::Min($beforeSeconds, 3599),
                [int][Math]::Min($beforeSeconds, 599),
                [int][Math]::Min($beforeSeconds, 59)
            ) | Select-Object -Unique
            $widthTexts = @($durationCandidates | ForEach-Object {
                "[{0}] 등장 {1} 전" -f $bossNames, (Format-BossAlertDuration ([int]$_))
            })
        }
        $grouped += [pscustomobject]@{
            Time = $first.Time
            Priority = [int]$first.Priority
            Highlight = [bool](@($items | Where-Object { $_.Highlight }).Count -gt 0)
            BossParts = @($items | ForEach-Object { [pscustomobject]@{ Name = [string]$_.Name; Highlight = [bool]$_.Highlight } })
            Key = "{0:O}|{1}|{2}" -f $first.Time, $first.State, (@($items | ForEach-Object { "{0}:{1}" -f $_.Name, ([bool]$_.Highlight) }) -join "/")
            Text = $text
            WidthTexts = @($widthTexts)
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

function Set-BossAlertEnabled {
    param([bool]$Value)

    if (Set-SettingsDraftValue "BossAlertEnabled" $Value) {
        return
    }

    $script:BossAlertEnabled = $Value
    Set-OptionsGroupVisibility $script:BossOptionsExpander $script:BossOptionsPanel $script:BossAlertEnabled $true
    Reset-BossAlertRuntimeCache
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
    Reset-BossAlertRuntimeCache
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
    Reset-BossAlertRuntimeCache
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
    Reset-BossAlertRuntimeCache
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
    Reset-BossAlertRuntimeCache
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
    Reset-BossAlertRuntimeCache
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

function Test-BossRowScheduleConfigured {
    param([object]$BossRow)

    (Get-BossRowTimesSummary $BossRow) -ne "미설정"
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

    if (Test-BossRowScheduleConfigured $rows[$Index]) {
        $bossName = ([string]$rows[$Index].Name).Trim()
        if ([string]::IsNullOrWhiteSpace($bossName)) {
            $bossName = "보스"
        }
        $answer = [System.Windows.MessageBox]::Show(
            "「$bossName」을 삭제하시겠습니까?",
            "보스 알림 삭제",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Question
        )
        if ($answer -ne [System.Windows.MessageBoxResult]::Yes) {
            return
        }
    }

    $nextRows = @()
    for ($i = 0; $i -lt $rows.Count; $i++) {
        if ($i -ne $Index) {
            $nextRows += $rows[$i]
        }
    }
    Set-BossRows $nextRows
}

function Reset-BossRowSchedule {
    param([int]$Index)

    $rows = @(Get-EditableBossRows)
    if ($Index -lt 0 -or $Index -ge $rows.Count) {
        return
    }

    $bossName = ([string]$rows[$Index].Name).Trim()
    if ([string]::IsNullOrWhiteSpace($bossName)) {
        $bossName = "보스"
    }
    $answer = [System.Windows.MessageBox]::Show(
        "「$bossName」의 요일/시간을 초기화 하시겠습니까?",
        "보스 요일/시간 초기화",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Question
    )
    if ($answer -ne [System.Windows.MessageBoxResult]::Yes) {
        return
    }

    $rows[$Index].Days = @()
    $rows[$Index].Times = @()
    $rows[$Index].DayTimes = [pscustomobject]([ordered]@{
        Mon = @()
        Tue = @()
        Wed = @()
        Thu = @()
        Fri = @()
        Sat = @()
        Sun = @()
    })
    Set-BossRows $rows
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

    foreach ($width in 56, 24, 56, 24, 64) {
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
    $resetColumn = New-Object System.Windows.Controls.ColumnDefinition
    $resetColumn.Width = [System.Windows.GridLength]::Auto
    $cell.ColumnDefinitions.Add($resetColumn) | Out-Null

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

    if ($Kind -eq "Times") {
        $resetButton = New-Object System.Windows.Controls.Button
        $resetButton.Content = "초기화"
        $resetButton.Width = 56
        $resetButton.Margin = New-Object System.Windows.Thickness 4, 0, 0, 0
        $resetButton.Tag = $Index
        $resetButton.Add_Click({
            param($sender, $eventArgs)
            Reset-BossRowSchedule ([int]$sender.Tag)
        })
        [System.Windows.Controls.Grid]::SetColumn($resetButton, 2)
        $cell.Children.Add($resetButton) | Out-Null
    }

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
    param([bool]$Force = $false)

    if (-not $script:BossRowsPanel) {
        return
    }

    $rows = @(Get-EditableBossRows)
    $signature = Get-BossRowsSignature $rows
    if (-not $Force -and $script:BossRowsEditorSignature -eq $signature) {
        return
    }

    $script:BossRowsEditorSignature = $signature
    $script:BossRowsPanel.Children.Clear()

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

