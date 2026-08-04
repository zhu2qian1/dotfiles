# vi:se et:
$Env:Editor='gvim'

. "$HOME\.config\PowerShell\pwsh_aliases.ps1"
. "$HOME\.config\PowerShell\yazi.ps1"
. "$HOME\.config\PowerShell\komorebi.ps1"

function Prompt() {
    Write-Host ""
    Write-Host -NoNewLine -ForegroundColor Blue "$env:username@$env:computername"
    Write-Host " $(Convert-Path $PWD)"
    return "PS> "
}

if ($ENV:WT_SESSION -ne "") {
    # Windows Terminal Related (STUB)
}

