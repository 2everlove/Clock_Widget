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
    public const long WS_EX_TRANSPARENT = 0x00000020L;

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
$script:EntryScriptPath = $PSCommandPath
$script:ConfigPath = Join-Path $script:AppDir "clock_widget_config.json"
$script:DefaultTrayIconPath = Join-Path $script:AppDir "clock_widget_cyberpunk.ico"
$script:CustomTrayIconPath = Join-Path $script:AppDir "clock_widget_custom_icon"
$script:BdoBlackSpiritIconPath = Join-Path $script:AppDir "bdo_black_spirit_variant.png"
$script:BdoPapuIconPath = Join-Path $script:AppDir "bdo_papu_variant.png"
$script:StartupPath = Join-Path ([Environment]::GetFolderPath("Startup")) "$($script:AppName).vbs"
$script:PowerShellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
$script:SettingsWindow = $null
$script:WidgetMoveMode = $false

$script:ModuleRoot = Join-Path $script:AppDir "modules"
. (Join-Path $script:ModuleRoot "ClockWidget.Core.ps1")
. (Join-Path $script:ModuleRoot "ClockWidget.ClockDisplay.ps1")
. (Join-Path $script:ModuleRoot "ClockWidget.BdoTime.ps1")
. (Join-Path $script:ModuleRoot "ClockWidget.BossAlert.ps1")
. (Join-Path $script:ModuleRoot "ClockWidget.SettingsWindow.ps1")


$config = Read-WidgetConfig
$script:FontSize = [int]$config.FontSize
$script:BackgroundOpacity = [double]$config.BackgroundOpacity
$script:BackgroundColor = [string]$config.BackgroundColor
$script:BackgroundBorderColor = [string]$config.BackgroundBorderColor
$script:BackgroundBorderColorTransparent = [bool]$config.BackgroundBorderColorTransparent
$script:BackgroundBorderThickness = [int]$config.BackgroundBorderThickness
$script:BackgroundBorderRadius = [int]$config.BackgroundBorderRadius
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
$script:WidgetSectionOrder = @(Normalize-WidgetSectionOrder $config.WidgetSectionOrder)

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
$script:Window.Add_SourceInitialized({
    Hide-WindowFromAltTab
    Set-WidgetMoveMode $false
})
$script:Window.Add_Loaded({
    Update-TrayToggleText
    Clamp-WidgetToScreenBounds
})
$script:Window.Add_SizeChanged({ Clamp-WidgetToScreenBounds })

$script:Border = New-Object System.Windows.Controls.Border
$script:Border.Background = [System.Windows.Media.Brushes]::Transparent
$script:Border.BorderBrush = Get-BackgroundBorderBrush
$script:Border.BorderThickness = Get-BackgroundBorderThickness
$script:Border.CornerRadius = Get-BackgroundCornerRadius
$script:Border.Padding = New-Object System.Windows.Thickness 0
$script:Window.Content = $script:Border

$script:WidgetGrid = New-Object System.Windows.Controls.Grid
$script:Border.Child = $script:WidgetGrid

$script:BackgroundLayer = New-Object System.Windows.Shapes.Rectangle
$script:BackgroundLayer.Fill = Get-BackgroundBrush $script:BackgroundOpacity
$script:BackgroundLayer.Opacity = $script:BackgroundOpacity
$script:BackgroundLayer.RadiusX = Get-BackgroundCornerRadiusValue
$script:BackgroundLayer.RadiusY = Get-BackgroundCornerRadiusValue
$script:BackgroundLayer.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
$script:BackgroundLayer.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
$script:WidgetGrid.Children.Add($script:BackgroundLayer) | Out-Null

$script:ContentStack = New-Object System.Windows.Controls.StackPanel
$script:ContentStack.Orientation = [System.Windows.Controls.Orientation]::Vertical
$script:ContentStack.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:ContentStack.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:WidgetGrid.Children.Add($script:ContentStack) | Out-Null

$script:MoveModeFixButton = New-Object System.Windows.Controls.Button
$script:MoveModeFixButton.Content = "고정"
$script:MoveModeFixButton.Width = 82
$script:MoveModeFixButton.Height = 34
$script:MoveModeFixButton.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:MoveModeFixButton.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:MoveModeFixButton.Visibility = [System.Windows.Visibility]::Collapsed
$script:MoveModeFixButton.IsHitTestVisible = $false
$script:MoveModeFixButton.Opacity = 0.95
$script:MoveModeFixButton.Cursor = [System.Windows.Input.Cursors]::Hand
$script:MoveModeFixButton.Add_Click({
    Set-WidgetMoveMode $false
    Save-WidgetConfig
})
[System.Windows.Controls.Panel]::SetZIndex($script:MoveModeFixButton, 10)
$script:WidgetGrid.Children.Add($script:MoveModeFixButton) | Out-Null

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

$script:BdoTimeOutlinePath = New-TextOutlinePath
$script:BdoTextGrid.Children.Add($script:BdoTimeOutlinePath) | Out-Null

$script:BdoTimeTextBlock = New-BdoTextBlock (Get-BdoTextBrush)
$script:BdoTextGrid.Children.Add($script:BdoTimeTextBlock) | Out-Null

$script:BdoTransitionTextGrid = New-Object System.Windows.Controls.Grid
$script:BdoTransitionTextGrid.Background = [System.Windows.Media.Brushes]::Transparent
$script:BdoTransitionTextGrid.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Center
$script:BdoTransitionTextGrid.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
$script:BdoTransitionTextGrid.Visibility = [System.Windows.Visibility]::Collapsed
$script:BdoTimePanel.Children.Add($script:BdoTransitionTextGrid) | Out-Null

$script:BdoTransitionOutlineTextBlocks = @()
$bdoTransitionOutlineOffsets = @(
    @(-1, -1), @(0, -1), @(1, -1),
    @(-1, 0),           @(1, 0),
    @(-1, 1),  @(0, 1),  @(1, 1)
)
foreach ($offset in $bdoTransitionOutlineOffsets) {
    $outlineBlock = New-BdoTransitionTextBlock (Get-BdoTransitionTextOutlineBrush)
    $outlineBlock.IsHitTestVisible = $false
    $entry = [pscustomobject]@{
        Block = $outlineBlock
        X = [double]$offset[0]
        Y = [double]$offset[1]
    }
    $script:BdoTransitionOutlineTextBlocks += $entry
    $script:BdoTransitionTextGrid.Children.Add($outlineBlock) | Out-Null
}

$script:BdoTransitionOutlinePath = New-TextOutlinePath
$script:BdoTransitionTextGrid.Children.Add($script:BdoTransitionOutlinePath) | Out-Null

$script:BdoTransitionTextBlock = New-BdoTransitionTextBlock (Get-BdoTransitionTextBrush)
$script:BdoTransitionTextGrid.Children.Add($script:BdoTransitionTextBlock) | Out-Null

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

$script:TextOutlinePath = New-TextOutlinePath
$script:ClockTextGrid.Children.Add($script:TextOutlinePath) | Out-Null

$script:TextBlock = New-ClockTextBlock (Get-TextBrush)
$script:ClockTextGrid.Children.Add($script:TextBlock) | Out-Null
$script:BdoTimePanel.Tag = "BdoTime"
$script:BossAlertPanel.Tag = "BossAlert"
$script:ClockTextGrid.Tag = "Clock"
$script:BdoTimePanel.AllowDrop = $true
$script:BossAlertPanel.AllowDrop = $true
$script:ClockTextGrid.AllowDrop = $true
Apply-WidgetSectionOrder

Apply-ClockTextStyle
Apply-BdoTimeStyle

$dragHandler = {
    param($sender, $eventArgs)
    if (-not $script:WidgetMoveMode) {
        return
    }

    if ($eventArgs.ChangedButton -eq [System.Windows.Input.MouseButton]::Left) {
        try {
            $script:Window.DragMove()
            Clamp-WidgetToScreenBounds
            Save-WidgetConfig
            $eventArgs.Handled = $true
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
$script:Border.Add_MouseRightButtonUp($rightClickHandler)
$script:WidgetGrid.Add_MouseRightButtonUp($rightClickHandler)
$script:BackgroundLayer.Add_MouseRightButtonUp($rightClickHandler)
$script:ContentStack.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTimePanel.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTextGrid.Add_MouseRightButtonUp($rightClickHandler)
$script:BdoTransitionTextGrid.Add_MouseRightButtonUp($rightClickHandler)
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

