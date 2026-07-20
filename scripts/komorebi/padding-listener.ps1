# vi:se bomb:
$pipeName = "komorebiPwsh"


$pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::InOut)

Write-Host "サーバーが起動しました。クライアントからの接続を待っています..."
$pipeServer.WaitForConnection()

Write-Host "クライアントが接続しました。"

$reader = New-Object System.IO.StreamReader($pipeServer)

$targetWorkspaceIndex = 0
$logSkippingEventTypes = @("Uncloak", "Cloak")

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
            Write-Output " --- SKIP LOGGING --- "
            continue
        }
        Write-Output " --- BEGIN log --- "
        if ($j.event.type -eq 'FocusWorkspaceNumber' -and $j.event.type -eq $targetWorkspaceIndex) {
            Write-Output " --- BEGIN event.type=FocusWorkspaceNumber: 0 --- "
            Write-Output $j.state
            Write-Output " --- END event.type=FocusWorkspaceNumber: 0 --- "
        }
        Write-Output $j.event.type
        Write-Output $j.event.content
        Write-Output " --- END log --- "
    }
}
finally {
    $pipeServer.Dispose()
}

