# Usage: Run this script to analyze the Web of Science data in 01_Data folder
# Results will be printed to console.

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$baseDir = Split-Path -Parent $scriptDir
$dataPath = Join-Path $baseDir "01_原始数据\savedrecs.txt"

if (-not (Test-Path $dataPath)) {
    Write-Error "Data file not found at $dataPath"
    exit
}

$records = @()
$currentRecord = @{}
$currentTag = $null
$content = Get-Content -Path $dataPath -Encoding UTF8

foreach ($line in $content) {
    if ($line -match "^ER") {
        if ($currentRecord.Count -gt 0) { $records += New-Object PSObject -Property $currentRecord }
        $currentRecord = @{}
        $currentTag = $null
        continue
    }
    if ($line -match "^([A-Z0-9]{2})\s+(.*)") {
        $currentTag = $Matches[1]
        $currentRecord[$currentTag] = $Matches[2].Trim()
    } elseif ($line -match "^\s+(.*)" -and $currentTag) {
        $currentRecord[$currentTag] += " " + $Matches[1].Trim()
    }
}

Write-Output "--- Data Analysis Summary ---"
Write-Output "Total Records: $($records.Count)"
Write-Output "`nTop 5 Cited Papers:"
$records | Select-Object TI, TC, PY, SO | Sort-Object {[int]$_.TC} -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Output "$($_.TC) cites: $($_.TI) ($($_.PY))"
}
