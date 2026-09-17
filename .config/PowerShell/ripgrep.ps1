# ripgrep の設定ファイル (.config\ripgrep\ripgreprc)。rg は既定の設定ファイルを
# 持たず、この環境変数を見たときだけ読む。
#
# 30-tools.sh と同じく rg の有無は確認しない。rg が無くても参照されないだけで
# 害は無く、プロファイル読み込み後に scoop / winget で入れた rg にもそのまま効く。
$env:RIPGREP_CONFIG_PATH = Join-Path $HOME '.config\ripgrep\ripgreprc'
