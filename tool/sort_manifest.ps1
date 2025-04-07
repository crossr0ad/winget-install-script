# Manifest.json を id 順にソートする
param (
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    [string]$OutputFile
)

Set-StrictMode -Version Latest

if (-not $OutputFile) {
    $OutputFile = $InputFile
}

$json = Get-Content $InputFile -Raw -Encoding UTF8 | ConvertFrom-Json
$json.packages = $json.packages | Sort-Object id
$json | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Encoding UTF8
