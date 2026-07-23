# vi:se et:
$Env:Editor='gvim'

. "$HOME\.config\PowerShell\pwsh_aliases.ps1"
. "$HOME\.config\PowerShell\yazi.ps1"

function Prompt() {
    Write-Host ""
    Write-Host -NoNewLine -ForegroundColor Blue "$env:username@$env:computername"
    Write-Host " $(Convert-Path $PWD)"
    return "PS> "
}

if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
    $OmpConf = "$HOME\.ompconf.json"
    if (Test-Path $OmpConf) {
        oh-my-posh init pwsh --config $OmpConf | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

if ($ENV:WT_SESSION -ne "") {
    # Windows Terminal Related (STUB)
}

