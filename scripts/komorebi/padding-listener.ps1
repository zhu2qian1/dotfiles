# vi:se bomb:
$pipeName = "komorebiPwsh"


$pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::InOut)

Write-Host "サーバーが起動しました。クライアントからの接続を待っています..."
$pipeServer.WaitForConnection()

Write-Host "クライアントが接続しました。"

$reader = New-Object System.IO.StreamReader($pipeServer)

$targetWorkspaceIndex = 0
$logSkippingEventTypes = @('Uncloak', 'Cloak', 'TitleUpdate', 'AddSubscriberPipe', 'FocusChange', 'FocusWindow', 'State', 'CycleStack', 'MoveWindow', 'MoveContainerToWorkspaceNumber', 'FocusWorkspaceNumber')
$loggingEventTypes = @('Destroy', 'Hide', 'StackWindow', 'UnstackWindow', 'MoveContainerToWorkspaceNumber')

try {
    while ($true) {
        $event = $reader.ReadLine()

        if ($null -eq $event) {
            break
        }

        $j = ConvertFrom-Json $event
        # Write-Output $j
        # SKIP
        if ($logSkippingEventTypes -contains $j.event.type) {
            Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DEBUG: SKIPPING EVENT ($($j.event.type), $($j.event.content))" -ForegroundColor 'DarkGray'
            continue
        }
        if ($loggingEventTypes -contains $j.event.type) {
            Write-Host -ForegroundColor 'DarkGreen' "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DEBUG: type    = $($j.event.type) "
            Write-Host -ForegroundColor 'DarkGreen' "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DEBUG: content = $($j.event.content)"
            continue
        }
        Write-Host -ForegroundColor 'Cyan' "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DEBUG: type    = $($j.event.type) "
        Write-Host -ForegroundColor 'Cyan' "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') DEBUG: content = $($j.event.content)"
    }
}
finally {
    $pipeServer.Dispose()
}

