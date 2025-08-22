# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

param(
    [switch] $CopyToClipboard
)

$ErrorActionPreference = 'Stop'

$translationFiles = Get-Item "$PSScriptRoot/../../Translations/Localization.*.resx" | Where-Object { $_.Name -ne 'Localization.1033.resx' -and $_.Name -ne 'Localization.1025.resx' }
$translationFiles = @("$PSScriptRoot/../../Translations/Localization.1033.resx") + $translationFiles

$translations = @()

[xml]$enUSTranslationXml = Get-Content -Raw "$PSScriptRoot/../../Translations/Localization.1033.resx"
$enUSTranslationXmlData = $enUSTranslationXml.root.data | Select-Object -Property name, value | Sort-Object -Property name

. "$PSScriptRoot/../utils/Get-LanguageFromLcid.ps1"

foreach ($translationFile in $translationFiles) {
    $language = "en-US"
    if ($translationFile.Name -match "Localization\.(\d+)\.resx") {
        $lcid = $matches[1]
        $language = Get-LanguageFromLcid -Lcid $lcid
        if (-not $language) { $language = "Unknown" }
    }
    [xml]$translationXml = Get-Content -Raw $translationFile -Encoding UTF8

    $translatedLabels = [ordered]@{}
    $translationXmlData = $translationXml.root.data | Select-Object -Property name, value | Sort-Object -Property name
    $enUSTranslationXmlData | ForEach-Object {
        $key = $_.name
        $translation = ($translationXmlData | Where-Object { $_.name -eq $key })

        $translatedLabels[$key] = if ($translation.value.'#significant-whitespace') {
            $translation.value.'#significant-whitespace'
        } elseif ($translation.value) {
            $translation.value
        } else {
            $_.value
        }

        if ($translatedLabels[$key] -eq '{Empty}') {
            $translatedLabels[$key] = ''
        }
    }

    $translations += [pscustomobject]@{ code=$language; labels=$translatedLabels }
}

$tableEntries = @()
foreach ($translation in $translations) {
    $labelEntries = @()
    foreach ($label in $translation.labels.GetEnumerator()) {
        $key = $label.Name
        # Power Fx escapes double quotes by doubling them
        $value = $label.Value.Replace('"', '""')
        $labelEntries += "$($key):""$($value)"""
    }
    $labelsString = "{ " + ($labelEntries -join ',') + " }"
    $tableEntries += "{ code: ""$($translation.code)"", labels: $($labelsString) }"
}
$translationsPowerFxTableData = "Table(" + ($tableEntries -join ',') + ")"

$translationPowerFx = "With({languages:$translationsPowerFxTableData},Set(gblAvailableLanguages,ForAll(languages,code));With({language:Coalesce(LookUp(languages,code=gblLanguageCode),LookUp(languages,code=""en-US""))},Set(gblLanguageCode,language.code);language.labels))"

if ($CopyToClipboard) {
    Set-Clipboard -Value $translationPowerFx
} else {
    Write-Output $translationPowerFx
}
