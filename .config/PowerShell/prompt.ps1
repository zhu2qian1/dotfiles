if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    function Prompt() {
        Write-Host ""
        Write-Host -NoNewLine -ForegroundColor Blue "$env:username@$env:computername"
        Write-Host " $(Convert-Path $PWD)"
        return "PS> "
    }
    return;
}
starship init powershell | Invoke-Expression
