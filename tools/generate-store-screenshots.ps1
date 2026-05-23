Add-Type -AssemblyName System.Drawing

function New-Bitmap($width, $height) {
  $bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function New-RoundedRectPath($x, $y, $width, $height, $radius) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  if ($radius -le 0) {
    $path.AddRectangle((New-Object System.Drawing.RectangleF($x, $y, $width, $height)))
    return $path
  }

  $diameter = $radius * 2
  $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
  $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
  $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function Save-Png($bitmap, $relativePath) {
  $fullPath = Join-Path $PSScriptRoot "..\$relativePath"
  New-Item -ItemType Directory -Force -Path (Split-Path $fullPath -Parent) | Out-Null
  $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Fill-RoundedRect($g, $x, $y, $w, $h, $r, $color) {
  $path = New-RoundedRectPath $x $y $w $h $r
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.FillPath($brush, $path)
  $brush.Dispose()
  $path.Dispose()
}

function Draw-Text($g, $text, $x, $y, $size, $color, $style) {
  $font = New-Object System.Drawing.Font("Segoe UI", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.DrawString($text, $font, $brush, $x, $y)
  $brush.Dispose()
  $font.Dispose()
}

function Draw-BlockSlash($g, $x1, $y1, $x2, $y2, $stroke) {
  $white = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(250, 255, 255, 255), [single]($stroke * 1.25))
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

function Draw-GifCard($g, $x, $y, $blocked) {
  Fill-RoundedRect $g $x $y 430 250 18 ([System.Drawing.Color]::FromArgb(255, 235, 238, 246))

  $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.RectangleF($x, $y, 430, 250)),
    [System.Drawing.Color]::FromArgb(255, 121, 93, 245),
    [System.Drawing.Color]::FromArgb(255, 27, 181, 201),
    35
  )
  $inner = New-RoundedRectPath ($x + 18) ($y + 18) 394 166 12
  $g.FillPath($gradient, $inner)
  $gradient.Dispose()
  $inner.Dispose()

  Fill-RoundedRect $g ($x + 34) ($y + 202) 64 26 13 ([System.Drawing.Color]::FromArgb(255, 38, 42, 58))
  Draw-Text $g "GIF" ($x + 48) ($y + 201) 18 ([System.Drawing.Color]::FromArgb(255, 245, 247, 252)) ([System.Drawing.FontStyle]::Bold)

  $play = New-Object System.Drawing.Drawing2D.GraphicsPath
  $play.AddPolygon(@(
    (New-Object System.Drawing.PointF(($x + 184), ($y + 68))),
    (New-Object System.Drawing.PointF(($x + 184), ($y + 134))),
    (New-Object System.Drawing.PointF(($x + 244), ($y + 101)))
  ))
  $playBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 255, 255, 255))
  $g.FillPath($playBrush, $play)
  $playBrush.Dispose()
  $play.Dispose()

  if ($blocked) {
    Fill-RoundedRect $g $x $y 430 250 18 ([System.Drawing.Color]::FromArgb(235, 24, 27, 38))
    Draw-BlockSlash $g ($x + 108) ($y + 198) ($x + 322) ($y + 52) 28
    Draw-Text $g "Hidden by Discord GIF Blocker" ($x + 74) ($y + 106) 24 ([System.Drawing.Color]::FromArgb(255, 245, 247, 252)) ([System.Drawing.FontStyle]::Bold)
  }
}

function Draw-DiscordMock($g, $blocked) {
  $g.Clear([System.Drawing.Color]::FromArgb(255, 18, 19, 24))

  Fill-RoundedRect $g 0 0 1280 800 0 ([System.Drawing.Color]::FromArgb(255, 18, 19, 24))
  Fill-RoundedRect $g 0 0 68 800 0 ([System.Drawing.Color]::FromArgb(255, 14, 15, 20))
  Fill-RoundedRect $g 68 0 250 800 0 ([System.Drawing.Color]::FromArgb(255, 31, 33, 42))
  Fill-RoundedRect $g 318 0 962 58 0 ([System.Drawing.Color]::FromArgb(255, 28, 30, 38))

  for ($i = 0; $i -lt 5; $i++) {
    Fill-RoundedRect $g 18 (22 + $i * 62) 34 34 12 ([System.Drawing.Color]::FromArgb(255, 50, 54, 68))
  }

  Draw-Text $g "Creative Server" 92 28 22 ([System.Drawing.Color]::FromArgb(255, 245, 247, 252)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "# general-chat" 350 18 24 ([System.Drawing.Color]::FromArgb(255, 245, 247, 252)) ([System.Drawing.FontStyle]::Bold)

  $channels = @("# welcome", "# announcements", "# general-chat", "# image-share", "# support")
  for ($i = 0; $i -lt $channels.Count; $i++) {
    $y = 92 + $i * 48
    if ($channels[$i] -eq "# general-chat") {
      Fill-RoundedRect $g 88 ($y - 7) 206 36 8 ([System.Drawing.Color]::FromArgb(255, 64, 67, 78))
    }
    Draw-Text $g $channels[$i] 98 $y 19 ([System.Drawing.Color]::FromArgb(255, 196, 200, 211)) ([System.Drawing.FontStyle]::Regular)
  }

  $messageColor = [System.Drawing.Color]::FromArgb(255, 226, 229, 236)
  Draw-Text $g "Alex" 374 98 18 ([System.Drawing.Color]::FromArgb(255, 88, 166, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "Here is one more GIF for the chat." 426 98 18 $messageColor ([System.Drawing.FontStyle]::Regular)
  Draw-GifCard $g 374 136 $blocked

  Draw-Text $g "Sam" 374 432 18 ([System.Drawing.Color]::FromArgb(255, 88, 166, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "Now the conversation is readable again." 424 432 18 $messageColor ([System.Drawing.FontStyle]::Regular)
  Fill-RoundedRect $g 374 476 620 54 10 ([System.Drawing.Color]::FromArgb(255, 36, 39, 49))
  Draw-Text $g "No private Discord names, messages, or servers are shown." 396 491 18 ([System.Drawing.Color]::FromArgb(255, 170, 176, 191)) ([System.Drawing.FontStyle]::Regular)
}

function Draw-Caption($g, $title, $subtitle) {
  Fill-RoundedRect $g 52 624 520 92 18 ([System.Drawing.Color]::FromArgb(255, 12, 14, 20))
  Draw-Text $g $title 78 642 31 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g $subtitle 80 682 20 ([System.Drawing.Color]::FromArgb(255, 203, 209, 224)) ([System.Drawing.FontStyle]::Regular)
}

function Draw-BeforeScreenshot() {
  $ctx = New-Bitmap 1280 800
  Draw-DiscordMock $ctx.Graphics $false
  Draw-Caption $ctx.Graphics "GIFs visible in chat" "Animated media can take over the conversation."
  Save-Png $ctx.Bitmap "assets/store/screenshots/02-gifs-visible.png"
  $ctx.Graphics.Dispose()
  $ctx.Bitmap.Dispose()
}

function Draw-AfterScreenshot() {
  $ctx = New-Bitmap 1280 800
  Draw-DiscordMock $ctx.Graphics $true
  Draw-Caption $ctx.Graphics "GIFs hidden automatically" "The chat stays calmer without extra setup."
  Save-Png $ctx.Bitmap "assets/store/screenshots/01-gifs-hidden.png"
  $ctx.Graphics.Dispose()
  $ctx.Bitmap.Dispose()
}

function Draw-PrivacyScreenshot() {
  $ctx = New-Bitmap 1280 800
  $g = $ctx.Graphics
  $g.Clear([System.Drawing.Color]::FromArgb(255, 17, 20, 31))

  Draw-Text $g "Discord GIF Blocker" 92 86 58 ([System.Drawing.Color]::FromArgb(255, 248, 250, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "Tiny, local, and private." 96 160 30 ([System.Drawing.Color]::FromArgb(255, 198, 205, 224)) ([System.Drawing.FontStyle]::Regular)

  Fill-RoundedRect $g 96 248 330 190 18 ([System.Drawing.Color]::FromArgb(255, 36, 40, 55))
  Fill-RoundedRect $g 475 248 330 190 18 ([System.Drawing.Color]::FromArgb(255, 36, 40, 55))
  Fill-RoundedRect $g 854 248 330 190 18 ([System.Drawing.Color]::FromArgb(255, 36, 40, 55))

  Draw-Text $g "Runs only on" 132 292 26 ([System.Drawing.Color]::FromArgb(255, 216, 221, 235)) ([System.Drawing.FontStyle]::Regular)
  Draw-Text $g "discord.com" 132 334 34 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)) ([System.Drawing.FontStyle]::Bold)

  Draw-Text $g "No analytics" 514 306 34 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "No tracking" 514 356 26 ([System.Drawing.Color]::FromArgb(255, 216, 221, 235)) ([System.Drawing.FontStyle]::Regular)

  Draw-Text $g "No remote code" 891 306 34 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)) ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g "No server required" 891 356 26 ([System.Drawing.Color]::FromArgb(255, 216, 221, 235)) ([System.Drawing.FontStyle]::Regular)

  Fill-RoundedRect $g 96 524 1088 82 18 ([System.Drawing.Color]::FromArgb(255, 25, 29, 42))
  Draw-Text $g "It only hides GIF media in your browser. It does not collect, store, or send your data." 128 548 26 ([System.Drawing.Color]::FromArgb(255, 232, 236, 246)) ([System.Drawing.FontStyle]::Regular)

  Save-Png $ctx.Bitmap "assets/store/screenshots/03-privacy.png"
  $g.Dispose()
  $ctx.Bitmap.Dispose()
}

Draw-BeforeScreenshot
Draw-AfterScreenshot
Draw-PrivacyScreenshot
