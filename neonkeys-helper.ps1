# Neon Keys helper
# Start Neon Keys.bat runs this hidden in the background. It lets the game
# save your progress and your Studio songs into this folder:
#   Save\progress.json          stars, scores, practice log, settings
#   Save\Backups\               one backup copy per day (last 14 days)
#   Save\Compositions\          your Studio songs (editable)
#   Songs\My Compositions\      your Studio songs as .mid, to practice in the game
# It only listens on this computer (localhost) and closes itself
# about 20 minutes after the game is closed. You never need to run it yourself.

$ErrorActionPreference = 'Stop'
$root   = Split-Path -Parent $MyInvocation.MyCommand.Path
$save   = Join-Path $root 'Save'
$backup = Join-Path $save 'Backups'
$comps  = Join-Path $save 'Compositions'
$songs  = Join-Path $root 'Songs'
$mine   = Join-Path $songs 'My Compositions'
foreach ($d in @($save, $backup, $comps, $songs, $mine)) { if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Path $d | Out-Null } }
$progress = Join-Path $save 'progress.json'
$utf8 = New-Object System.Text.UTF8Encoding $false

$listener = New-Object System.Net.HttpListener
$port = 0
foreach ($p in 8765, 8766) {
  try { $listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add("http://localhost:$p/"); $listener.Start(); $port = $p; break }
  catch {
    # already running? then there is nothing to do
    try { $r = Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:$p/ping" -TimeoutSec 2; if ($r.Content -match 'neonkeys') { exit } } catch {}
  }
}
if ($port -eq 0) { exit }

$types = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'; '.json'='application/json; charset=utf-8';
  '.css'='text/css'; '.mid'='audio/midi'; '.midi'='audio/midi'; '.png'='image/png'; '.jpg'='image/jpeg'; '.svg'='image/svg+xml'; '.txt'='text/plain; charset=utf-8' }

function Send($ctx, [int]$code, [string]$type, [byte[]]$bytes) {
  $res = $ctx.Response
  $res.StatusCode = $code
  $res.Headers.Add('Access-Control-Allow-Origin', '*')
  $res.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  $res.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')
  $res.Headers.Add('Cache-Control', 'no-store')
  if ($type) { $res.ContentType = $type }
  if ($bytes -and $bytes.Length) { $res.ContentLength64 = $bytes.Length; $res.OutputStream.Write($bytes, 0, $bytes.Length) }
  $res.OutputStream.Close()
}
function SendText($ctx, [int]$code, [string]$type, [string]$text) { Send $ctx $code $type ($utf8.GetBytes($text)) }
function ReadBody($req) { $ms = New-Object System.IO.MemoryStream; $req.InputStream.CopyTo($ms); return ,$ms.ToArray() }
function SafeName([string]$n, [string]$ext) {
  $n = [Uri]::UnescapeDataString($n)
  $n = [IO.Path]::GetFileNameWithoutExtension($n)
  $n = ($n -replace "[^A-Za-z0-9 _\-\(\)\.'&!]", '').Trim(' ', '.')
  if (-not $n) { $n = 'Untitled' }
  if ($n.Length -gt 60) { $n = $n.Substring(0, 60) }
  return $n + $ext
}
function WriteSafe([string]$path, [byte[]]$bytes) {
  $tmp = $path + '.tmp'
  [IO.File]::WriteAllBytes($tmp, $bytes)
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Force }
  Move-Item -LiteralPath $tmp -Destination $path
}
function SongLibrary() {
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add('window.NEONKEYS_LIBRARY = [')
  Get-ChildItem -LiteralPath $songs -Recurse -File | Where-Object { $_.Extension -match '^\.(mid|midi|kar)$' } | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($songs.Length).TrimStart('\', '/')
    $folder = Split-Path -Parent $rel
    if (-not $folder) { $folder = '' }
    $folder = $folder -replace '[\\/]', ' / '
    $item = [ordered]@{ folder = $folder; file = $_.Name; data = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)) }
    $lines.Add(($item | ConvertTo-Json -Compress) + ',')
  }
  $lines.Add('];')
  return ($lines -join "`n")
}

$last = Get-Date
while ($listener.IsListening) {
  $ar = $listener.BeginGetContext($null, $null)
  while (-not $ar.AsyncWaitHandle.WaitOne(5000)) {
    if (((Get-Date) - $last).TotalMinutes -gt 20) { $listener.Stop(); exit }
  }
  $ctx = $listener.EndGetContext($ar)
  $last = Get-Date
  try {
    $req = $ctx.Request
    $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)
    $m = $req.HttpMethod
    if ($m -eq 'OPTIONS') { Send $ctx 204 $null $null; continue }

    if ($path -eq '/ping') {
      $at = 0
      if (Test-Path -LiteralPath $progress) { try { $j = Get-Content -LiteralPath $progress -Raw -Encoding UTF8 | ConvertFrom-Json; if ($j.savedAt) { $at = $j.savedAt } } catch {} }
      SendText $ctx 200 'application/json' ('{"app":"neonkeys","port":' + $port + ',"savedAt":' + $at + '}')
    }
    elseif ($path -eq '/save' -and $m -eq 'GET') {
      if (Test-Path -LiteralPath $progress) { Send $ctx 200 'application/json; charset=utf-8' ([IO.File]::ReadAllBytes($progress)) }
      else { SendText $ctx 200 'application/json' '{}' }
    }
    elseif ($path -eq '/save' -and $m -eq 'POST') {
      $body = ReadBody $req
      $text = $utf8.GetString($body)
      $null = $text | ConvertFrom-Json            # refuse anything that isn't valid JSON
      WriteSafe $progress $body
      $today = Join-Path $backup ('progress-' + (Get-Date -Format 'yyyy-MM-dd') + '.json')
      if (-not (Test-Path -LiteralPath $today)) {
        Copy-Item -LiteralPath $progress -Destination $today
        Get-ChildItem -LiteralPath $backup -Filter 'progress-*.json' | Sort-Object Name -Descending | Select-Object -Skip 14 | Remove-Item -Force
      }
      SendText $ctx 200 'application/json' '{"ok":true}'
    }
    elseif ($path -eq '/songs-library.js') {
      SendText $ctx 200 'text/javascript; charset=utf-8' (SongLibrary)
    }
    elseif ($path -eq '/compositions' -and $m -eq 'GET') {
      $list = @(Get-ChildItem -LiteralPath $comps -Filter '*.json' | Sort-Object LastWriteTime -Descending | ForEach-Object { [ordered]@{ file = $_.Name; name = $_.BaseName; modified = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') } })
      if ($list.Count -eq 0) { SendText $ctx 200 'application/json' '[]' } else { SendText $ctx 200 'application/json' (ConvertTo-Json -InputObject $list -Compress) }
    }
    elseif ($path -like '/compositions/*') {
      $file = Join-Path $comps (SafeName ($path.Substring(14)) '.json')
      if ($m -eq 'POST') { $body = ReadBody $req; $null = $utf8.GetString($body) | ConvertFrom-Json; WriteSafe $file $body; SendText $ctx 200 'application/json' '{"ok":true}' }
      elseif (Test-Path -LiteralPath $file) { Send $ctx 200 'application/json; charset=utf-8' ([IO.File]::ReadAllBytes($file)) }
      else { SendText $ctx 404 'text/plain' 'not found' }
    }
    elseif ($path -like '/mysong/*' -and $m -eq 'POST') {
      $file = Join-Path $mine (SafeName ($path.Substring(8)) '.mid')
      WriteSafe $file (ReadBody $req)
      SendText $ctx 200 'application/json' '{"ok":true}'
    }
    elseif ($m -eq 'GET') {
      if ($path -eq '/') { $path = '/NeonKeys.html' }
      $full = [IO.Path]::GetFullPath((Join-Path $root $path.TrimStart('/')))
      if (-not $full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or $full.StartsWith($save, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $full -PathType Leaf)) { SendText $ctx 404 'text/plain' 'not found' }
      else {
        $ext = [IO.Path]::GetExtension($full).ToLower()
        $type = $types[$ext]; if (-not $type) { $type = 'application/octet-stream' }
        Send $ctx 200 $type ([IO.File]::ReadAllBytes($full))
      }
    }
    else { SendText $ctx 405 'text/plain' 'no' }
  } catch {
    try { SendText $ctx 500 'text/plain' ($_.Exception.Message) } catch {}
  }
}
