# komorebi
if ((-not (Get-Command "komorebic" -ErrorAction SilentlyContinue)) -or (-not(Get-Command "whkd" -ErrorAction SilentlyContinue))) {
    return;
}

$NamedPipeName = 'komorebiPwsh'
function Start-Komorebi-My {
    Param ([Switch] $DoRefresh)

    if ($DoRefresh) {
        komorebic start --bar --whkd --clean-state
    } else {
        komorebic start --bar --whkd
    }
    # Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile', '-File', "$HOME\dotfiles\scripts\komorebi\padding-listener.ps1"
    # Start-Sleep -Milliseconds 500
    # komorebic subscribe-pipe $NamedPipeName
}
function Stop-Komorebi-My {
    # komorebic unsubscribe-pipe $NamedPipeName
    komorebic stop --bar --whkd
}
function Restart-Komorebi-My {
    Param ([Switch] $DoRefresh)

    Stop-Komorebi-My
    Start-Komorebi-My $DoRefresh
}
function Rename-KomorebiFocusedWorkspace([String] $NewWorkspaceName) {
    if ($NewWorkspaceName -eq "") {
        return
    }
    $MonitorIndex   = komorebic.exe query focused-monitor-index
    $WorkspaceIndex = komorebic.exe query focused-workspace-index
    komorebic.exe workspace-name $MonitorIndex $WorkspaceIndex $NewWorkspaceName
}
