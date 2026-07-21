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

# --- Placement helpers -------------------------------------------------------
# Place the flame mark centred at (cx,cy). Mark natural size is 68.39w x 132.06h,
# with its visual centre at (100.01, 78.03) in mark coordinates.
function MarkG {
    param([double]$cx, [double]$cy, [double]$s, [string]$fg)
    @"
  <g style="color:$fg" transform="translate($cx,$cy) scale($s) translate(-100.01,-78.03)"><use href="#mark"/></g>
"@
}

# Brand wordmark "HILDINGS HANTVERK" in mm, with enlarged initials, centred by default.
function Wordmark {
    param([double]$cx, [double]$y, [double]$size, [string]$fg, [string]$anchor = 'middle')
    $h = [math]::Round($size * 1.11, 3)
    @"
<text x="$cx" y="$y" text-anchor="$anchor" style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-weight:300;letter-spacing:0.04em;fill:$fg"><tspan font-size="$h">H</tspan><tspan font-size="$size">ILDINGS </tspan><tspan font-size="$h">H</tspan><tspan font-size="$size">ANTVERK</tspan></text>
"@
}

$amber = '#f5b041'   # warm amber accent

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

# =============================================================================
#  NEW & EXPLORATORY VARIATIONS
# =============================================================================

# 8) Monogram HH — the flame reads as a candle standing between two initials ---
$monoBody = @"
  <text x="52" y="120" text-anchor="middle" style="font-family:'Cormorant Garamond',Georgia,serif;font-weight:500;font-size:120px;fill:$near">H</text>
  <text x="168" y="120" text-anchor="middle" style="font-family:'Cormorant Garamond',Georgia,serif;font-weight:500;font-size:120px;fill:$near">H</text>
$(MarkG 110 70 0.6 $near)
"@
Save-Svg -Name 'monogram-hh' -ViewBox '0 0 220 150' -RootColor $near -Body $monoBody

# 9) Round emblem / seal with curved text -------------------------------------
$emblemBody = @"
  <circle cx="100" cy="100" r="96" fill="none" stroke="$near" stroke-width="1.6"/>
  <circle cx="100" cy="100" r="88" fill="none" stroke="$near" stroke-width="0.7"/>
  <path id="arcTop" d="M 24 100 A 76 76 0 0 1 176 100" fill="none"/>
  <path id="arcBot" d="M 176 100 A 76 76 0 0 1 24 100" fill="none"/>
  <text style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-weight:400;font-size:12px;letter-spacing:0.24em;fill:$near"><textPath href="#arcTop" startOffset="50%" text-anchor="middle">HILDINGS · HANTVERK</textPath></text>
  <text style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-weight:400;font-size:10px;letter-spacing:0.22em;fill:$near"><textPath href="#arcBot" startOffset="50%" text-anchor="middle">HANDGJORDA LJUS</textPath></text>
  <circle cx="14" cy="100" r="1.9" fill="$near"/>
  <circle cx="186" cy="100" r="1.9" fill="$near"/>
$(MarkG 100 98 0.6 $near)
"@
Save-Svg -Name 'emblem-round' -ViewBox '0 0 200 200' -RootColor $near -Body $emblemBody

# 10) Ornamental divider — flame flanked by rules -----------------------------
$dividerBody = @"
  <line x1="24" y1="22" x2="130" y2="22" stroke="$near" stroke-width="1"/>
  <line x1="190" y1="22" x2="296" y2="22" stroke="$near" stroke-width="1"/>
  <circle cx="24" cy="22" r="2.2" fill="$near"/>
  <circle cx="296" cy="22" r="2.2" fill="$near"/>
  <rect x="127" y="19" width="6" height="6" transform="rotate(45 130 22)" fill="$near"/>
  <rect x="187" y="19" width="6" height="6" transform="rotate(45 190 22)" fill="$near"/>
$(MarkG 160 18 0.26 $near)
"@
Save-Svg -Name 'divider' -ViewBox '0 0 320 44' -RootColor $near -Body $dividerBody

# 11) Business card — front (85 x 55 mm) --------------------------------------
$bcFront = @"
  <rect x="0" y="0" width="85" height="55" fill="$near"/>
  <rect x="3" y="3" width="79" height="49" fill="none" stroke="$cream" stroke-width="0.4" opacity="0.5"/>
$(MarkG 42.5 22 0.135 $cream)
$(Wordmark 42.5 41 4.2 $cream)
  <text x="42.5" y="47.5" text-anchor="middle" style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-size:2.6px;letter-spacing:0.35em;fill:$cream;opacity:0.72">HANDGJORDA LJUS</text>
"@
Save-Svg -Name 'business-card-front' -ViewBox '0 0 85 55' -RootColor $near -Body $bcFront

# 12) Business card — back (85 x 55 mm, write-on lines) -----------------------
$bcBack = @"
  <rect x="0" y="0" width="85" height="55" fill="$cream"/>
  <rect x="3" y="3" width="79" height="49" fill="none" stroke="$near" stroke-width="0.35" opacity="0.3"/>
$(MarkG 42.5 12 0.05 $near)
$(Wordmark 42.5 20 2.6 $near)
  <line x1="10" y1="24" x2="75" y2="24" stroke="$near" stroke-width="0.3" opacity="0.3"/>
  <text x="10" y="32" style="font-family:Calibri,Arial,sans-serif;font-size:2.1px;letter-spacing:0.18em;fill:$near;opacity:0.6">TELEFON</text>
  <line x1="34" y1="32" x2="76" y2="32" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
  <text x="10" y="40" style="font-family:Calibri,Arial,sans-serif;font-size:2.1px;letter-spacing:0.18em;fill:$near;opacity:0.6">E-POST</text>
  <line x1="34" y1="40" x2="76" y2="40" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
  <text x="10" y="48" style="font-family:Calibri,Arial,sans-serif;font-size:2.1px;letter-spacing:0.18em;fill:$near;opacity:0.6">INSTAGRAM</text>
  <line x1="34" y1="48" x2="76" y2="48" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
"@
Save-Svg -Name 'business-card-back' -ViewBox '0 0 85 55' -RootColor $near -Body $bcBack

# 13) Product hang-tag — front (52 x 84 mm) -----------------------------------
$pcFront = @"
  <rect x="1" y="1" width="50" height="82" rx="4" fill="$cream" stroke="$near" stroke-width="0.5"/>
  <circle cx="26" cy="7" r="2.3" fill="none" stroke="$near" stroke-width="0.6"/>
$(MarkG 26 36 0.16 $near)
$(Wordmark 26 55 3.4 $near)
  <line x1="16" y1="60" x2="36" y2="60" stroke="$near" stroke-width="0.4"/>
  <text x="26" y="66" text-anchor="middle" style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-size:2.4px;letter-spacing:0.3em;fill:$near;opacity:0.7">HANDGJORT LJUS</text>
  <text x="26" y="77" text-anchor="middle" style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-size:2.1px;letter-spacing:0.08em;fill:$near;opacity:0.5">hildingshantverk.se</text>
"@
Save-Svg -Name 'product-card-front' -ViewBox '0 0 52 84' -RootColor $near -Body $pcFront

# 14) Product hang-tag — back (52 x 84 mm, info fields + care) ----------------
$pcBack = @"
  <rect x="1" y="1" width="50" height="82" rx="4" fill="$cream" stroke="$near" stroke-width="0.5"/>
  <circle cx="26" cy="7" r="2.3" fill="none" stroke="$near" stroke-width="0.6"/>
$(Wordmark 26 16 2.4 $near)
  <line x1="8" y1="20" x2="44" y2="20" stroke="$near" stroke-width="0.3" opacity="0.3"/>
  <text x="8" y="29" style="font-family:Calibri,Arial,sans-serif;font-size:2.2px;letter-spacing:0.16em;fill:$near;opacity:0.65">BRINNTID</text>
  <line x1="24" y1="29" x2="44" y2="29" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
  <text x="8" y="38" style="font-family:Calibri,Arial,sans-serif;font-size:2.2px;letter-spacing:0.16em;fill:$near;opacity:0.65">VIKT</text>
  <line x1="24" y1="38" x2="44" y2="38" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
  <text x="8" y="47" style="font-family:Calibri,Arial,sans-serif;font-size:2.2px;letter-spacing:0.16em;fill:$near;opacity:0.65">DATUM</text>
  <line x1="24" y1="47" x2="44" y2="47" stroke="$near" stroke-width="0.3" stroke-dasharray="0.8 1" opacity="0.4"/>
  <line x1="8" y1="55" x2="44" y2="55" stroke="$near" stroke-width="0.3" opacity="0.3"/>
  <text x="26" y="61" text-anchor="middle" style="font-family:'Cormorant Garamond',Georgia,serif;font-weight:500;font-size:4px;letter-spacing:0.14em;fill:$near">SKÖTSELRÅD</text>
  <text x="26" y="67" text-anchor="middle" style="font-family:Calibri,Arial,sans-serif;font-size:1.9px;fill:$near;opacity:0.7">Låt aldrig ljuset brinna utan uppsikt.</text>
  <text x="26" y="71" text-anchor="middle" style="font-family:Calibri,Arial,sans-serif;font-size:1.9px;fill:$near;opacity:0.7">Trimma veken till ca 5 mm före tändning.</text>
  <text x="26" y="75" text-anchor="middle" style="font-family:Calibri,Arial,sans-serif;font-size:1.9px;fill:$near;opacity:0.7">Låt brinna högst 4 timmar i taget.</text>
  <text x="26" y="79" text-anchor="middle" style="font-family:Calibri,Arial,sans-serif;font-size:1.9px;fill:$near;opacity:0.7">Håll borta från barn, husdjur och drag.</text>
"@
Save-Svg -Name 'product-card-back' -ViewBox '0 0 52 84' -RootColor $near -Body $pcBack

# 15) Round lid stickers (cream & dark) ---------------------------------------
$lidVariants = @(
    @{ n = 'cream'; bg = $cream; fg = $near  },
    @{ n = 'dark';  bg = $near;  fg = $cream }
)
foreach ($v in $lidVariants) {
    $body = @"
  <circle cx="60" cy="60" r="58" fill="$($v.bg)" stroke="$($v.fg)" stroke-width="1"/>
  <circle cx="60" cy="60" r="52" fill="none" stroke="$($v.fg)" stroke-width="0.5" opacity="0.45"/>
  <path id="lidTop" d="M 18 60 A 42 42 0 0 1 102 60" fill="none"/>
  <path id="lidBot" d="M 102 60 A 42 42 0 0 1 18 60" fill="none"/>
  <text style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-weight:400;font-size:7.5px;letter-spacing:0.22em;fill:$($v.fg)"><textPath href="#lidTop" startOffset="50%" text-anchor="middle">HILDINGS · HANTVERK</textPath></text>
  <text style="font-family:Calibri,'Segoe UI',Arial,sans-serif;font-weight:400;font-size:6px;letter-spacing:0.2em;fill:$($v.fg)"><textPath href="#lidBot" startOffset="50%" text-anchor="middle">HANDGJORDA LJUS</textPath></text>
  <circle cx="13" cy="60" r="1.3" fill="$($v.fg)"/>
  <circle cx="107" cy="60" r="1.3" fill="$($v.fg)"/>
  <g style="color:$($v.fg)" transform="translate(60,60) scale(0.3) translate(-100.01,-78.03)"><use href="#mark"/></g>
"@
    Save-Svg -Name "label-top-$($v.n)" -ViewBox '0 0 120 120' -RootColor $near -Body $body
}

# 16) Wrap-around jar label (190 x 70 mm) -------------------------------------
$wrapBody = @"
  <rect x="1" y="1" width="188" height="68" rx="6" fill="$cream" stroke="$near" stroke-width="0.6"/>
$(MarkG 34 35 0.19 $near)
  <line x1="60" y1="14" x2="60" y2="56" stroke="$near" stroke-width="0.5" opacity="0.5"/>
$(Wordmark 128 32 5 $near)
  <text x="128" y="45" text-anchor="middle" style="font-family:'Cormorant Garamond',Georgia,serif;font-style:italic;font-weight:500;font-size:7px;fill:$near;opacity:0.8">— modellnamn —</text>
  <text x="128" y="54" text-anchor="middle" style="font-family:Calibri,Arial,sans-serif;font-size:3px;letter-spacing:0.16em;fill:$near;opacity:0.55">HANDGJORT LJUS · 220 G · BRINNTID ~40 H</text>
"@
Save-Svg -Name 'candle-wrap-label' -ViewBox '0 0 190 70' -RootColor $near -Body $wrapBody

# 17) Gift / thank-you tag (96 x 60 mm) ---------------------------------------
$giftBody = @"
  <rect x="1" y="1" width="94" height="58" rx="6" fill="$cream" stroke="$near" stroke-width="0.5"/>
  <circle cx="12" cy="12" r="2.6" fill="none" stroke="$near" stroke-width="0.6"/>
$(MarkG 48 15 0.1 $near)
  <text x="48" y="42" text-anchor="middle" style="font-family:'Cormorant Garamond',Georgia,serif;font-style:italic;font-weight:500;font-size:24px;fill:$near">Tack!</text>
$(Wordmark 48 52 2.8 $near)
"@
Save-Svg -Name 'gift-tag' -ViewBox '0 0 96 60' -RootColor $near -Body $giftBody

Write-Host 'Done.'
