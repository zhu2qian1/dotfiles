# Yazi-related
function Set-YaziFileOneSetting() {
    # file.exe specify
    if (-not $IsWindows) {
        Write-Debug "Set-YaziFileOneSetting: OS is not Windwos. Skipping.";
        return; # abort when OS is not Windows
    }
    if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Debug "Set-YaziFileOneSetting: git is not found. Skipping.";
        return; # if git is not found, abort
    }

    $GitPath = Get-Command 'git' | Resolve-Path;
    $GitBase = $GitPath | Split-Path | Split-Path;
    $FileExe = Join-Path $GitBase 'usr/bin/file.exe';
    if (-not (Test-Path $FileExe)) {
        Write-Debug "Set-YaziFileOneSetting: file.exe is not found. Skipping.";
        return; # file.exe not found
    }

    $Env:YAZI_FILE_ONE = $FileExe
}

if (Get-Command 'yazi' -ErrorAction SilentlyContinue) {
    Set-YaziFileOneSetting

    function y {
        $tmp = (New-TemporaryFile).FullName
        yazi.exe @args --cwd-file="$tmp"
        $cwd = Get-Content -Path $tmp -Encoding UTF8
        if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
            Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
        }
        Remove-Item -Path $tmp
    }
}
