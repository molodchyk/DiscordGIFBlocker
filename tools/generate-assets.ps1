Add-Type -AssemblyName System.Drawing

function New-Bitmap($width, $height) {
  $bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function New-RoundedRectPath($x, $y, $width, $height, $radius) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $diameter = $radius * 2
  $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
  $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
  $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function Save-Png($bitmap, $path) {
  $fullPath = Join-Path $PSScriptRoot "..\$path"
  $directory = Split-Path $fullPath -Parent
  New-Item -ItemType Directory -Force -Path $directory | Out-Null
  $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Draw-BlockSlash($g, $x1, $y1, $x2, $y2, $stroke) {
  $shadow = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 6, 8, 14), [single]($stroke + 4))
  $shadow.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $shadow.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($shadow, $x1 + 2, $y1 + 2, $x2 + 2, $y2 + 2)
  $shadow.Dispose()

  $white = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(245, 255, 255, 255), [single]($stroke * 1.22))
  $white.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $white.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($white, $x1, $y1, $x2, $y2)
  $white.Dispose()

  $red = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 238, 74, 74), [single]$stroke)
  $red.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $red.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($red, $x1, $y1, $x2, $y2)
  $red.Dispose()
}

function Draw-MediaBubble($g, $x, $y, $w, $h, $scale, $showGifLabel) {
  $bubblePath = New-RoundedRectPath $x $y $w $h ($h * 0.24)
  $bubbleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 247, 252))
  $bubbleBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 187, 194, 214), [single]([Math]::Max(1, $scale * 0.018)))
  $g.FillPath($bubbleBrush, $bubblePath)
  $g.DrawPath($bubbleBorder, $bubblePath)
  $bubbleBrush.Dispose()
  $bubbleBorder.Dispose()
  $bubblePath.Dispose()

  if ($showGifLabel) {
    $labelFont = New-Object System.Drawing.Font("Segoe UI", [single]($h * 0.32), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $labelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 41, 45, 59))
    $format = New-Object System.Drawing.StringFormat
    $format.Alignment = [System.Drawing.StringAlignment]::Center
    $format.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString("GIF", $labelFont, $labelBrush, (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $format)
    $format.Dispose()
    $labelBrush.Dispose()
    $labelFont.Dispose()
  } else {
    $play = New-Object System.Drawing.Drawing2D.GraphicsPath
    $play.AddPolygon(@(
      (New-Object System.Drawing.PointF(($x + $w * 0.42), ($y + $h * 0.33))),
      (New-Object System.Drawing.PointF(($x + $w * 0.42), ($y + $h * 0.68))),
      (New-Object System.Drawing.PointF(($x + $w * 0.68), ($y + $h * 0.50)))
    ))
    $playBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 41, 45, 59))
    $g.FillPath($playBrush, $play)
    $playBrush.Dispose()
    $play.Dispose()

    $dotBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 88, 101, 242))
    $dotSize = [Math]::Max(2, $scale * 0.055)
    $g.FillEllipse($dotBrush, ($x + $w * 0.20), ($y + $h * 0.42), $dotSize, $dotSize)
    $g.FillEllipse($dotBrush, ($x + $w * 0.28), ($y + $h * 0.42), $dotSize, $dotSize)
    $dotBrush.Dispose()
  }
}

function Draw-GifLabel($g, $x, $y, $w, $h) {
  $labelFont = New-Object System.Drawing.Font("Segoe UI", [single]($h * 0.32), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $labelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 41, 45, 59))
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center
  $g.DrawString("GIF", $labelFont, $labelBrush, (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $format)
  $format.Dispose()
  $labelBrush.Dispose()
  $labelFont.Dispose()
}

function Draw-Icon($size, $path) {
  $ctx = New-Bitmap $size $size
  $g = $ctx.Graphics
  $g.Clear([System.Drawing.Color]::Transparent)

  $tile = New-RoundedRectPath ($size * 0.07) ($size * 0.07) ($size * 0.86) ($size * 0.86) ($size * 0.20)
  $tileBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.RectangleF(0, 0, $size, $size)),
    [System.Drawing.Color]::FromArgb(255, 42, 46, 66),
    [System.Drawing.Color]::FromArgb(255, 14, 17, 27),
    45
  )
  $g.FillPath($tileBrush, $tile)
  $tileBrush.Dispose()
  $tile.Dispose()

  Draw-MediaBubble $g ($size * 0.22) ($size * 0.25) ($size * 0.56) ($size * 0.42) $size $false
  Draw-BlockSlash $g ($size * 0.29) ($size * 0.76) ($size * 0.76) ($size * 0.28) ([Math]::Max(2, $size * 0.11))

  Save-Png $ctx.Bitmap $path
  $g.Dispose()
  $ctx.Bitmap.Dispose()
}

function Draw-DiscordPanel($g, $x, $y, $w, $h) {
  $panelPath = New-RoundedRectPath $x $y $w $h 24
  $panelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 36, 39, 51))
  $g.FillPath($panelBrush, $panelPath)
  $panelBrush.Dispose()
  $panelPath.Dispose()

  $sidebar = New-RoundedRectPath ($x + 22) ($y + 22) 74 ($h - 44) 18
  $sidebarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 28, 31, 42))
  $g.FillPath($sidebarBrush, $sidebar)
  $sidebarBrush.Dispose()
  $sidebar.Dispose()

  $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 111, 119, 140))
  $rowCount = 4
  if ($h -lt 160) {
    $rowCount = 2
  }

  for ($i = 0; $i -lt $rowCount; $i++) {
    $rowY = $y + 44 + ($i * 52)
    $g.FillEllipse($textBrush, $x + 120, $rowY, 22, 22)
    $barX = $x + 158
    $barWidth = [Math]::Max(28, [Math]::Min(($w * 0.42), ($x + $w - $barX - 22)))
    $barPath = New-RoundedRectPath $barX ($rowY + 4) $barWidth 14 7
    $g.FillPath($textBrush, $barPath)
    $barPath.Dispose()
  }
  $textBrush.Dispose()
}

function Draw-Promo($width, $height, $path, $isSmall) {
  $ctx = New-Bitmap $width $height
  $g = $ctx.Graphics
  $g.Clear([System.Drawing.Color]::FromArgb(255, 15, 18, 28))

  $accent = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.RectangleF(0, 0, $width, $height)),
    [System.Drawing.Color]::FromArgb(255, 47, 51, 75),
    [System.Drawing.Color]::FromArgb(255, 13, 16, 27),
    0
  )
  $g.FillRectangle($accent, 0, 0, $width, $height)
  $accent.Dispose()

  if ($isSmall) {
    $titleFont = New-Object System.Drawing.Font("Segoe UI", 30, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $subtitleFont = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 246, 248, 252))
    $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 190, 197, 214))
    $g.DrawString("Discord GIF Blocker", $titleFont, $white, 30, 32)
    $g.DrawString("Hide GIFs in Discord chat", $subtitleFont, $muted, 32, 70)
    Draw-DiscordPanel $g 34 118 244 104
    Draw-MediaBubble $g 302 124 96 64 128 $true
    Draw-BlockSlash $g 318 188 388 128 9
    Draw-GifLabel $g 302 124 96 64
  } else {
    $titleFont = New-Object System.Drawing.Font("Segoe UI", 66, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $subtitleFont = New-Object System.Drawing.Font("Segoe UI", 34, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 246, 248, 252))
    $muted = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 190, 197, 214))
    $g.DrawString("Discord GIF Blocker", $titleFont, $white, 96, 92)
    $g.DrawString("Hide GIFs in Discord chat", $subtitleFont, $muted, 102, 174)
    Draw-DiscordPanel $g 820 88 470 340
    Draw-MediaBubble $g 450 268 250 182 320 $true
    Draw-BlockSlash $g 462 486 712 236 42
  }

  $titleFont.Dispose()
  $subtitleFont.Dispose()
  $white.Dispose()
  $muted.Dispose()

  Save-Png $ctx.Bitmap $path
  $g.Dispose()
  $ctx.Bitmap.Dispose()
}

Draw-Icon 16 "assets/icons/icon-16.png"
Draw-Icon 32 "assets/icons/icon-32.png"
Draw-Icon 48 "assets/icons/icon-48.png"
Draw-Icon 64 "assets/icons/icon-64.png"
Draw-Icon 128 "assets/icons/icon-128.png"
Draw-Promo 440 280 "assets/store/cws-small-promo-440x280.png" $true
Draw-Promo 1400 560 "assets/store/cws-marquee-promo-1400x560.png" $false
