$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$rootPrefix = $root.TrimEnd("\") + "\"
$manifestPath = Join-Path $root "manifest.json"
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$packageName = "discord-gif-blocker-$($manifest.version).zip"
$distDir = Join-Path $root "dist"
$packagePath = Join-Path $distDir $packageName
$stagingDir = Join-Path $distDir "webstore-package"

$ignorePath = Join-Path $root ".webstoreignore"
$ignorePatterns = @()
if (Test-Path $ignorePath) {
  $ignorePatterns = Get-Content $ignorePath | Where-Object {
    $line = $_.Trim()
    $line -and -not $line.StartsWith("#")
  }
}

function Test-Ignored($relativePath) {
  $normalized = $relativePath.Replace("\", "/")

  foreach ($pattern in $ignorePatterns) {
    $normalizedPattern = $pattern.Replace("\", "/").Trim()
    if ($normalizedPattern.EndsWith("/")) {
      $prefix = $normalizedPattern.TrimEnd("/")
      if ($normalized -eq $prefix -or $normalized.StartsWith("$prefix/")) {
        return $true
      }
      continue
    }

    if ($normalized -like $normalizedPattern) {
      return $true
    }
  }

  return $false
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null
if (Test-Path $stagingDir) {
  Remove-Item -LiteralPath $stagingDir -Recurse -Force
}
if (Test-Path $packagePath) {
  Remove-Item -LiteralPath $packagePath -Force
}
New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null

Get-ChildItem -Path $root -Recurse -File | ForEach-Object {
  $relativePath = $_.FullName.Substring($rootPrefix.Length)
  if (Test-Ignored $relativePath) {
    return
  }

  $destination = Join-Path $stagingDir $relativePath
  New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
  Copy-Item -LiteralPath $_.FullName -Destination $destination
}

Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $packagePath -Force
Remove-Item -LiteralPath $stagingDir -Recurse -Force

Write-Output $packagePath
