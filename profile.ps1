$Env:Editor='gvim'

function Prompt() {
    Write-Output ""
    Write-Host -NoNewLine -ForegroundColor Blue "$env:username@$env:computername"
    Write-Host " $(Convert-Path $PWD)"
    return "PS> "
}

if (Get-Command "eza" -ErrorAction SilentlyContinue) {
    function Invoke-EzaLla {
        eza --all --icons --long --time-style long-iso $args
    }
    Set-Alias lla Invoke-EzaLla
    function Invoke-EzaLl {
        eza       --icons --long --time-style long-iso $args
    }
    Set-Alias ll Invoke-EzaLl
}

