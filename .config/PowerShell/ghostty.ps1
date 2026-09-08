# noctty (Ghostty の Windows fork) のシェル統合を global スコープで読み直す。
#
# noctty は pwsh を
#   pwsh.exe -NoExit -Command "& { ...; . '<resources>\shell-integration\powershell\integration.ps1' }"
# という形で起こす。`& { }` は子スコープを作るので、そこで dot-source された
# integration.ps1 の中身はそのスコープに入り、ブロックを抜けた時点で消える。
# `function global:prompt` だけは明示的に global なので生き残るが、その中から
# 呼ばれる __ghostty_write_osc などのヘルパ関数と $ESC / $BEL は消えるため、
# プロンプト描画のたびに CommandNotFoundException が出て PowerShell 既定の
# "PS>" にフォールバックする — starship のプロンプトが一切出なくなる。
#
# プロファイルは global スコープで走るので、ここで読み直せばヘルパもグローバル
# に定義されて prompt が完走する。integration.ps1 は $Global:__ghostty_aid で
# 冪等ガードされており、後から走る noctty 側の注入と二重に適用されても
# __ghostty_original_prompt が上書きされることはない。
#
# starship のプロンプトを包む必要があるので prompt.ps1 より後に読むこと。
if ($env:GHOSTTY_RESOURCES_DIR) {
    $integration = Join-Path $env:GHOSTTY_RESOURCES_DIR 'shell-integration\powershell\integration.ps1'
    if (Test-Path -LiteralPath $integration) {
        . $integration
    }
}
