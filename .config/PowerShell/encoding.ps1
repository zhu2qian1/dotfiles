# 日本語環境の Windows は ANSI/OEM コードページが 932 (Shift-JIS) なので、
# コンソールの [Console]::OutputEncoding も既定で 932 になる。starship や
# fzf・git など UTF-8 を吐くネイティブコマンドの出力がそのまま Shift-JIS と
# して復号され、prompt.ps1 の `starship init powershell | iex` が受け取る
# 初期化スクリプトごと文字化けする (プロンプトが壊れて「starship が効いて
# いない」ように見える)。
#
# Windows Terminal は pwsh を起こす前に ConPTY を 65001 にするので表面化
# しないが、他のターミナルでは 932 のまま来る。noctty (Ghostty の Windows
# fork) の utf8-console は既定の auto が CJK コードページを意図的に避ける
# うえ、設定するのが注入されるシェル統合スクリプト = プロファイルより後の
# タイミングなので、どちらにせよここには間に合わない。
#
# コンソールを持たないホスト (出力がリダイレクトされた場合など) では設定に
# 失敗するので、握り潰して残りのプロファイルを続行させる。
try {
    if ([Console]::OutputEncoding.CodePage -ne 65001) {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    }
} catch {
}
