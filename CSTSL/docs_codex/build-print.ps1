param(
    [string]$Typst = 'typst',
    [string]$FontPath = '',
    [switch]$IncludeClaude
)

$ErrorActionPreference = 'Stop'
$compiler = (Get-Command $Typst -ErrorAction Stop).Source
$fontArgs = @()
if ($FontPath) {
    $fontArgs = @('--font-path', (Resolve-Path -LiteralPath $FontPath).Path)
}

$availableFonts = & $compiler fonts @fontArgs
if ($LASTEXITCODE -ne 0) { throw 'Cannot list Typst fonts.' }
$requiredFonts = @('Palatino Linotype')
if ($IncludeClaude) { $requiredFonts += 'Noto Sans' }
foreach ($requiredFont in $requiredFonts) {
    if ($availableFonts -notcontains $requiredFont) {
        throw "$requiredFont is required. Install the font or supply -FontPath with its Regular, Bold, Italic and BoldItalic font files."
    }
}

# Default: rebuild the Codex print files. Optionally rebuild the Claude lessons
# that consume shared content, keeping their PDFs in docs_claude.
$courseRoot = Split-Path -Parent $PSScriptRoot
$documents = @(
    (Join-Path $PSScriptRoot 'GK_InA4_DenTrang.typ'),
    (Join-Path $PSScriptRoot 'GK_PhuLuc_Mang_InA4_DenTrang.typ')
)
if ($IncludeClaude) {
    $documents += Join-Path $courseRoot 'docs_claude/GK0_TapInGiay_ViDuTrenLop.typ'
    $documents += Join-Path $courseRoot 'docs_claude/GK5_CauHoiLyThuyet.typ'
}
foreach ($inputFile in $documents) {
    $outputFile = [IO.Path]::ChangeExtension($inputFile, '.pdf')
    & $compiler compile @fontArgs --root $courseRoot $inputFile $outputFile
    if ($LASTEXITCODE -ne 0) { throw "Typst compile failed: $inputFile" }
    Write-Output "Built $outputFile"
}
