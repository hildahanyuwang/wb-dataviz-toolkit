# Render an HTML infographic to PNG via headless Edge/Chrome.
# Usage: powershell -File render.ps1 <htmlName-no-ext> <width> <height>
param([string]$name, [int]$w, [int]$h)
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) { $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }
if (-not (Test-Path $edge)) { $edge = "C:\Program Files\Google\Chrome\Application\chrome.exe" }
$html = "$dir\$name.html"; $png = "$dir\$name.png"
$url  = "file:///$($html.Replace('\','/'))"
$prof = "$env:TEMP\edge_render_$(Get-Random)"
if (Test-Path $png) { Remove-Item $png -Force }
$args = @("--headless=new","--disable-gpu","--no-sandbox","--user-data-dir=$prof",
          "--screenshot=$png","--window-size=$w,$h",$url)
Start-Process -FilePath $edge -ArgumentList $args -Wait
if (Test-Path $png) {
  Add-Type -AssemblyName System.Drawing
  $img = [System.Drawing.Image]::FromFile($png)
  Write-Output "OK $name.png $($img.Width)x$($img.Height) ($([math]::Round((Get-Item $png).Length/1kb))kb)"
  $img.Dispose()
} else { Write-Output "FAILED $name" }
try { Remove-Item $prof -Recurse -Force -ErrorAction Stop } catch {}
