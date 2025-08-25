# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

param(
    [string] $CanonicalResxPath = "$PSScriptRoot/../../Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/Localization.1033.resx",
    [string] $ControlBundlePath = "$PSScriptRoot/../../Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/bundle.js",
    [string] $CanvasBundlePath = "$PSScriptRoot/../../CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.bundle.js",
    [string] $CanvasJsonPath = "$PSScriptRoot/../../CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.json",
    [string] $CanvasResxPath = "$PSScriptRoot/../../CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.resx",
    [switch] $UpdateCanvasResx,
    [switch] $SkipCanvasResx
)

$ErrorActionPreference = 'Stop'

function Get-ResxLabels {
    param([string] $ResxPath)
    if (-not (Test-Path -LiteralPath $ResxPath)) {
        throw "Resx not found: $ResxPath"
    }
    [xml]$xml = Get-Content -Raw -LiteralPath $ResxPath -Encoding UTF8
    $labels = [ordered]@{}
    foreach ($node in $xml.root.data) {
        $key = [string]$node.name
        if (-not $key) { continue }
        $value = $null
        # Support significant whitespace values if present
        if ($node.value.'#significant-whitespace') {
            $value = [string]$node.value.'#significant-whitespace'
        } elseif ($node.value) {
            $value = [string]$node.value
        } else {
            $value = ''
        }
        # Normalize placeholders for empty
        if ($value -eq '{Empty}') { $value = '' }
        $labels[$key] = $value
    }
    # Sort by key for stable output
    $sorted = [ordered]@{}
    foreach ($k in ($labels.Keys | Sort-Object)) { $sorted[$k] = $labels[$k] }
    return $sorted
}

function Write-JsonLabels {
    param([hashtable] $Labels, [string] $OutPath)
    $json = $Labels | ConvertTo-Json -Compress -Depth 5
    Set-Content -LiteralPath $OutPath -Value $json -Encoding UTF8
}

function Replace-KeyArrayInBundle {
    param([string] $BundlePath, [string[]] $Keys)
    if (-not (Test-Path -LiteralPath $BundlePath)) {
        throw "Bundle not found: $BundlePath"
    }
    $content = Get-Content -Raw -LiteralPath $BundlePath -Encoding UTF8
    $escapedKeys = $Keys | ForEach-Object { '"' + ($_ -replace '"','\\"') + '"' }
    $arrayText = '[' + ($escapedKeys -join ',') + ']'
    $pattern = 'var\s+t\s*=\s*\[[\s\S]*?\];'
    if ($content -notmatch $pattern) {
        throw "Could not find key array pattern in bundle: $BundlePath"
    }
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, "var t=$arrayText;", [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($newContent -eq $content) {
        Write-Verbose "No changes for $BundlePath"
    }
    Set-Content -LiteralPath $BundlePath -Value $newContent -Encoding UTF8
}

function Sync-CanvasResxFromControl {
    param([string] $SourceResx, [string] $TargetResx)
    if (-not (Test-Path -LiteralPath $SourceResx)) { throw "Source resx not found: $SourceResx" }
    $src = Get-Content -Raw -LiteralPath $SourceResx -Encoding UTF8
    Set-Content -LiteralPath $TargetResx -Value $src -Encoding UTF8
}

Write-Host "Reading canonical resx: $CanonicalResxPath"
$labels = Get-ResxLabels -ResxPath $CanonicalResxPath

Write-Host "Writing Canvas JSON: $CanvasJsonPath"
Write-JsonLabels -Labels $labels -OutPath $CanvasJsonPath

# Determine whether to sync Canvas resx (default: true). Back-compat: if -UpdateCanvasResx provided, honor it.
$shouldSyncCanvasResx = $true
if ($PSBoundParameters.ContainsKey('UpdateCanvasResx')) { $shouldSyncCanvasResx = [bool]$UpdateCanvasResx }
if ($SkipCanvasResx) { $shouldSyncCanvasResx = $false }

if ($shouldSyncCanvasResx) {
    Write-Host "Syncing Canvas resx from control: $CanvasResxPath"
    Sync-CanvasResxFromControl -SourceResx $CanonicalResxPath -TargetResx $CanvasResxPath
} else {
    Write-Host "Skipping Canvas resx sync (per parameters)."
}

Write-Host "Updating control bundle key array: $ControlBundlePath"
Replace-KeyArrayInBundle -BundlePath $ControlBundlePath -Keys $labels.Keys

Write-Host "Updating Canvas bundle key array: $CanvasBundlePath"
Replace-KeyArrayInBundle -BundlePath $CanvasBundlePath -Keys $labels.Keys

Write-Host "Localization sync complete. Keys: $($labels.Keys.Count) updated."
