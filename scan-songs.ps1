# Neon Keys song scanner
# Start Neon Keys.bat runs this every time. It looks through the Songs folder
# (and every folder inside it) for MIDI files and writes songs-library.js,
# which the game reads. You never need to run or edit this yourself.

$root  = Split-Path -Parent $MyInvocation.MyCommand.Path
$songs = Join-Path $root 'Songs'
$out   = Join-Path $root 'songs-library.js'

if (-not (Test-Path $songs)) { New-Item -ItemType Directory -Path $songs | Out-Null }

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('// Made automatically by Start Neon Keys.bat. Do not edit: it is rebuilt every launch.')
$lines.Add('window.NEONKEYS_LIBRARY = [')
$count = 0
Get-ChildItem -LiteralPath $songs -Recurse -File |
  Where-Object { $_.Extension -match '^\.(mid|midi|kar)$' } |
  Sort-Object FullName |
  ForEach-Object {
    $rel    = $_.FullName.Substring($songs.Length).TrimStart('\')
    $folder = Split-Path -Parent $rel
    if (-not $folder) { $folder = '' }
    $folder = $folder -replace '\\', ' / '
    $item = [ordered]@{ folder = $folder; file = $_.Name; data = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)) }
    $lines.Add(($item | ConvertTo-Json -Compress) + ',')
    $count++
  }
$lines.Add('];')
[IO.File]::WriteAllText($out, ($lines -join "`r`n"), (New-Object System.Text.UTF8Encoding $false))
Write-Host "Neon Keys: found $count song(s) in the Songs folder."
