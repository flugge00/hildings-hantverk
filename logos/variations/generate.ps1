# Generates all Hildings Hantverk logo variations as self-contained SVG files.
# Run once from anywhere:  pwsh -File logos/variations/generate.ps1
# Re-run after changing the source logo to regenerate every variation.

$ErrorActionPreference = 'Stop'
$logosDir = Split-Path -Parent $PSScriptRoot          # ...\logos
$srcPath  = Join-Path $logosDir 'Logga_HildingsHantverk_200x200mm.svg'
$outDir   = $PSScriptRoot
$src     = Get-Content -Raw -LiteralPath $srcPath

# --- Extract the flame path (resolved d + transform) from the source ---------
$flameBlock = [regex]::Match($src, '<path\b[^>]*id="path1-2-8-2"[^>]*/>').Value
$flameD     = [regex]::Match($flameBlock, '\sd="([^"]+)"').Groups[1].Value
$flameT     = [regex]::Match($flameBlock, 'transform="(matrix[^"]+)"').Groups[1].Value

# The two thin wick lines (short, taken verbatim from the source)
$line1 = 'm 92.716065,109.55303 -0.04163,19.70327'
$line2 = 'm 100.87085,92.771752 -0.10928,42.162928'

# --- Brand palette -----------------------------------------------------------
$near  = '#14100c'   # near-black (brand dark)
$cream = '#f3e9d8'   # cream
$red   = '#a3231a'   # deep candle red
$green = '#1c3a2e'   # dark forest green
$white = '#ffffff'

# --- Reusable defs (everything uses currentColor so it recolours cleanly) -----
$markDef = @"
    <g id="mark">
      <g transform="translate(2.2445383,1.1255979)">
        <path d="$flameD" transform="$flameT" style="fill:currentColor;fill-rule:nonzero;stroke:none"/>
        <path d="$line1" style="fill:none;stroke:currentColor;stroke-width:1.3;stroke-linecap:round;stroke-linejoin:round"/>
        <path d="$line2" style="fill:none;stroke:currentColor;stroke-width:1.3;stroke-linecap:round;stroke-linejoin:round"/>
      </g>
    </g>
"@

$wordDef = @"
    <text id="wordtext" x="99.138596" y="157.57072" style="font-style:normal;font-weight:300;font-size:22.86px;line-height:0.9;font-family:Calibri,'Segoe UI','Helvetica Neue',Arial,sans-serif;text-align:center;text-anchor:middle;fill:currentColor;stroke:none">
      <tspan x="99.138596" y="157.57072"><tspan style="font-size:25.4px">H</tspan>ILDINGS</tspan>
      <tspan x="99.138596" y="180.43073"><tspan style="font-size:25.4px">H</tspan>ANTVERK</tspan>
    </text>
"@

# Single-line wordmark (baseline at y=0, starts at x=0) for wide/header layouts
$wordWideDef = @"
    <text id="wordwide" x="0" y="0" style="font-style:normal;font-weight:300;font-size:22.86px;font-family:Calibri,'Segoe UI','Helvetica Neue',Arial,sans-serif;text-anchor:start;fill:currentColor;stroke:none"><tspan style="font-size:25.4px">H</tspan>ILDINGS <tspan style="font-size:25.4px">H</tspan>ANTVERK</text>
"@

function Save-Svg {
    param([string]$Name, [string]$ViewBox, [string]$RootColor, [string]$Body, [bool]$IncludeWord = $false)
    $p = $ViewBox -split '\s+'
    $w = [double]$p[2]; $h = [double]$p[3]
    $defs = $markDef
    if ($IncludeWord) { $defs = "$markDef`n$wordDef`n$wordWideDef" }
    $svg = @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="$ViewBox" width="$([math]::Round($w,2))" height="$([math]::Round($h,2))" style="color:$RootColor">
  <defs>
$defs
  </defs>
$Body
</svg>
"@
    $file = Join-Path $outDir "$Name.svg"
    Set-Content -LiteralPath $file -Value $svg -Encoding UTF8 -NoNewline
    Write-Host "  wrote $Name.svg  ($([math]::Round($w))x$([math]::Round($h)))"
}

Write-Host 'Generating logo variations...'

# 1) Logo only ----------------------------------------------------------------
Save-Svg -Name 'logo-only' -ViewBox '65.81 12 68.39 132.06' -RootColor $near `
    -Body '  <use href="#mark"/>'

# 2) Vertical lockup (text under) --------------------------------------------
Save-Svg -Name 'lockup-vertical' -ViewBox '40.25 12 117.78 183.31' -RootColor $near -IncludeWord $true `
    -Body "  <use href=`"#mark`"/>`n  <use href=`"#wordtext`"/>"

# 3) Vertical lockup reversed (cream, for dark backgrounds) -------------------
Save-Svg -Name 'lockup-vertical-reversed' -ViewBox '40.25 12 117.78 183.31' -RootColor $cream -IncludeWord $true `
    -Body "  <use href=`"#mark`"/>`n  <use href=`"#wordtext`"/>"

# 4) Horizontal lockup (text to the right) -----------------------------------
Save-Svg -Name 'lockup-horizontal' -ViewBox '65.81 12 184.17 132.06' -RootColor $near -IncludeWord $true `
    -Body "  <use href=`"#mark`"/>`n  <use href=`"#wordtext`" transform=`"translate(91.95,-82.37)`"/>"

# 4b) Wide wordmark on a single line (headers, letterheads) -------------------
Save-Svg -Name 'wordmark-wide' -ViewBox '-6 -30 209.06 43' -RootColor $near -IncludeWord $true `
    -Body '  <use href="#wordwide"/>'
Save-Svg -Name 'wordmark-wide-reversed' -ViewBox '-6 -30 209.06 43' -RootColor $cream -IncludeWord $true `
    -Body '  <use href="#wordwide"/>'

# 4c) Wide lockup: mark + single-line text to the right (site headers) --------
Save-Svg -Name 'lockup-wide' -ViewBox '65.81 12 279.45 132.06' -RootColor $near -IncludeWord $true `
    -Body "  <use href=`"#mark`"/>`n  <use href=`"#wordwide`" transform=`"translate(140.2,90.03)`"/>"
Save-Svg -Name 'lockup-wide-reversed' -ViewBox '65.81 12 279.45 132.06' -RootColor $cream -IncludeWord $true `
    -Body "  <use href=`"#mark`"/>`n  <use href=`"#wordwide`" transform=`"translate(140.2,90.03)`"/>"

# 5) Round badges (background, no text) ---------------------------------------
$badges = @(
    @{ n = 'white'; bg = $white; fg = $near  },
    @{ n = 'black'; bg = $near;  fg = $cream },
    @{ n = 'red';   bg = $red;   fg = $cream },
    @{ n = 'green'; bg = $green; fg = $cream }
)
foreach ($b in $badges) {
    $body = @"
  <circle cx="100" cy="100" r="94" fill="$($b.bg)"/>
  <circle cx="100" cy="100" r="86" fill="none" stroke="$($b.fg)" stroke-width="1" opacity="0.35"/>
  <g style="color:$($b.fg)" transform="translate(100,100) scale(0.9) translate(-100.01,-78.03)">
    <use href="#mark"/>
  </g>
"@
    Save-Svg -Name "badge-round-$($b.n)" -ViewBox '0 0 200 200' -RootColor $near -Body $body
}

# 6) App icons (rounded square, no text) -------------------------------------
$icons = @(
    @{ n = 'dark';  bg = $near;  fg = $cream },
    @{ n = 'light'; bg = $white; fg = $near  }
)
foreach ($i in $icons) {
    $body = @"
  <rect x="6" y="6" width="188" height="188" rx="42" fill="$($i.bg)"/>
  <g style="color:$($i.fg)" transform="translate(100,100) scale(0.86) translate(-100.01,-78.03)">
    <use href="#mark"/>
  </g>
"@
    Save-Svg -Name "app-icon-$($i.n)" -ViewBox '0 0 200 200' -RootColor $near -Body $body
}

# 7) Stamp / watermark (transparent, outline ring) ---------------------------
$stampBody = @"
  <circle cx="100" cy="100" r="94" fill="none" stroke="currentColor" stroke-width="2"/>
  <circle cx="100" cy="100" r="86" fill="none" stroke="currentColor" stroke-width="0.8"/>
  <g transform="translate(100,100) scale(0.8) translate(-100.01,-78.03)">
    <use href="#mark"/>
  </g>
"@
Save-Svg -Name 'stamp' -ViewBox '0 0 200 200' -RootColor $near -Body $stampBody

Write-Host 'Done.'
