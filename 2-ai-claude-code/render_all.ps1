# render_all.ps1 — render every template to ./renders/ (PNG).
# Usage:  ./render_all.ps1
# Uses a throwaway browser profile, so it does NOT touch your normal browser.
$dir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edge)) { $edge = "C:\Program Files\Microsoft\Edge\Application\msedge.exe" }
if (-not (Test-Path $edge)) { $edge = "C:\Program Files\Google\Chrome\Application\chrome.exe" }
$out = "$dir\renders"; New-Item -ItemType Directory -Force $out | Out-Null

$jobs = @(
  @{ n = "01_leads_hero";    w = 1080; h = 1440 },
  @{ n = "02_report_charts"; w = 1080; h = 1440 },
  @{ n = "03_linkedin_card"; w = 1200; h = 1200 },
  @{ n = "04_newsletter";    w = 1080; h = 1100 },
  @{ n = "05_dime_ai";       w = 1080; h = 1070 }
)

foreach ($j in $jobs) {
  $html = "$dir\templates\$($j.n).html"
  $png  = "$out\$($j.n).png"
  $prof = "$env:TEMP\edge_render_$(Get-Random)"
  if (Test-Path $png) { Remove-Item $png -Force }
  $a = @("--headless=new","--disable-gpu","--no-sandbox","--user-data-dir=$prof",
         "--screenshot=$png","--window-size=$($j.w),$($j.h)",
         "file:///$($html.Replace('\','/'))")
  Start-Process -FilePath $edge -ArgumentList $a -Wait
  if (Test-Path $png) { Write-Output "OK   $($j.n).png" } else { Write-Output "FAIL $($j.n)" }
  try { Remove-Item $prof -Recurse -Force -ErrorAction Stop } catch {}
}
Write-Output "Done. PNGs in: $out"
