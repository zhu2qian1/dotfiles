<#
.SYNOPSIS
    Noctty theme dumper
#>
[CmdletBinding()]
param(
    [string]$TargetPath = "$ENV:TEMP\noctty"
    [string]$NocttyExe = 'noctty.exe'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'


if (-not (Get-Command $NocttyExe -ErrorAction SilentlyContinue)) {
    throw
}

if (-not (Test-Path $TargetPath -Type Container)) {
    New-Item $TargetPath -ItemType Container
}

