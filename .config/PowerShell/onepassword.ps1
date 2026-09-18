# 1Password CLI (op)
if (-not(Get-Command 'op' -ErrorAction SilentlyContinue)) {
    return
}

# 生成される補完スクリプトは `op __completeNoDesc` の stderr (cobra のデバッグ出力
# "Completion ended with directive: ...") を外側の `2>&1 | Out-Null` で捨てるつもり
# だが、Invoke-Expression 経由で起動したネイティブコマンドの stderr はそこで捕まらず、
# Tab を押すたびにコンソールへ漏れる (pwsh 7 / Windows PowerShell 5.1 とも)。
# リダイレクトを Invoke-Expression に渡す文字列の内側へ移して捨てる。op の更新で
# 生成物が変わって置換が当たらなくなっても、漏れる状態に戻るだけで補完は壊れない。
$OpCompletion = op completion powershell | Out-String
$OpCompletion = $OpCompletion.Replace(
    'Invoke-Expression -OutVariable out "$RequestComp" 2>&1 | Out-Null',
    'Invoke-Expression -OutVariable out "$RequestComp 2>`$null" | Out-Null')
$OpCompletion | Invoke-Expression
Remove-Variable OpCompletion

