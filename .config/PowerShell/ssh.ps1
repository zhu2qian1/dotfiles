# ssh
if (-not (Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
    return
}

# Pick a Host entry from ~/.ssh/config with fzf, then ssh to it.
# A Host line may list several names ("Host a b c"), so split on whitespace
# and offer each one separately. Wildcards (Host *, *.example.com) are not
# connectable targets, so drop them.
function Invoke-InteractiveSsh {
    [CmdletBinding()]
    param (
        [string]$SshConfigFile = "$HOME\.ssh\config"
    )

    if (-not (Get-Command 'fzf' -ErrorAction SilentlyContinue)) {
        Write-Error 'command "fzf" is not found. Aborting.'
        return
    }

    if (-not (Test-Path -LiteralPath $SshConfigFile -PathType Leaf)) {
        Write-Error "ssh config file '$SshConfigFile' is not found. Aborting."
        return
    }
    Write-Verbose "ssh config file found: $(Convert-Path $SshConfigFile)"

    # Match Host at the start of a line only, so HostName lines are not picked up.
    $SshHosts = Get-Content -LiteralPath $SshConfigFile |
        Select-String -Pattern '^\s*Host\s+(.+)$' |
        ForEach-Object { $_.Matches[0].Groups[1].Value -split '\s+' } |
        Where-Object { $_ -and $_ -notmatch '[*?!]' } |
        Select-Object -Unique

    if (-not $SshHosts) {
        Write-Error "no host entry in '$SshConfigFile'. Aborting."
        return
    }

    $SelectedHost = $SshHosts | fzf --prompt='ssh> ' --height=40% --reverse
    if (-not $SelectedHost) {
        Write-Verbose 'No host selected (escaped or none matched?). Aborting.'
        return
    }
    Write-Verbose "Selected Host: $SelectedHost"

    ssh $SelectedHost
}
Set-Alias issh Invoke-InteractiveSsh
