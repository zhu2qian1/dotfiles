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
# komorebi と bar は動かしたまま whkd だけを止める / 起こす。
# `komorebic stop --whkd` は komorebi ごと落とすので、ゲーム中などホットキーだけ
# 一時的に切りたいときに使う。
function Start-Whkd {
    Param ([Switch] $DoShowWindow)
    # 二重起動すると同じホットキーの登録が衝突するので、動いていれば何もしない
    if (Get-Process -Name whkd -ErrorAction SilentlyContinue) {
        return
    }
    if ($DoShowWindow) {
        Start-Process whkd
    } else {
        Start-Process whkd -WindowStyle Hidden
    }
}
function Stop-Whkd {
    Get-Process -Name whkd -ErrorAction SilentlyContinue | Stop-Process -Force
}
function Rename-KomorebiFocusedWorkspace([String] $NewWorkspaceName) {
    if ($NewWorkspaceName -eq "") {
        return
    }
    $MonitorIndex   = komorebic.exe query focused-monitor-index
    $WorkspaceIndex = komorebic.exe query focused-workspace-index
    komorebic.exe workspace-name $MonitorIndex $WorkspaceIndex $NewWorkspaceName
}
