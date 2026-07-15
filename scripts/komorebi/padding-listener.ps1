# vi:se bomb:
$pipeName = "komorebiPwsh"


$pipeServer = New-Object System.IO.Pipes.NamedPipeServerStream($pipeName, [System.IO.Pipes.PipeDirection]::InOut)

Write-Host "サーバーが起動しました。クライアントからの接続を待っています..."
$pipeServer.WaitForConnection()

Write-Host "クライアントが接続しました。"

$reader = New-Object System.IO.StreamReader($pipeServer)

try {
    while ($true) {
        $event = $reader.ReadLine()

        if ($null -eq $event) {
            break
        }

        $j = ConvertFrom-Json $event
        # Write-Output $j
        if ($j.event.type -eq 'FocusWorkspaceNumber' -and $j.event.type -eq 0 ) {
            Write-Output " --- state --- "
            Write-Output $j.state
        }
        Write-Output $j.event.type
        Write-Output $j.event.content
        Write-Output "--------"
    }
}
finally {
    $pipeServer.Dispose()
}

