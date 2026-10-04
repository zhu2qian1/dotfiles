# psmux (tmux for Windows)
if (-not (Get-Command 'psmux' -ErrorAction SilentlyContinue)) {
    return
}

Set-Alias t psmux

# Pick a psmux session with fzf, then attach to it, or switch to it when
# already inside psmux (psmux sets $env:TMUX just like tmux does).
# With no server / no sessions there is nothing to pick, so start "main"
# instead of showing an empty fzf list the user has to cancel out of.
#
# Enter picks an existing session; ctrl-n creates one named after the
# query. Creating on Enter-when-nothing-matches would not work: fzf's
# fuzzy match makes "work" (or even "wrk") select an existing "work-api",
# so a name that is a subsequence of another could never be created.
# Targets use "=name" for the same reason -- -t also prefix-matches.
# Bash/zsh 版 `its` (.config/shell/20-aliases.sh) と挙動を揃えてある。
function Invoke-PsmuxSessionPicker {
    [CmdletBinding()]
    param ()

    if (-not (Get-Command 'fzf' -ErrorAction SilentlyContinue)) {
        Write-Error 'command "fzf" is not found. Aborting.'
        return
    }

    # Windows PowerShell 5.1 は $OutputEncoding の既定が us-ascii で、ネイティブ
    # コマンドへパイプした文字列の非 ASCII 文字が `?` に化け、日本語のセッション
    # 名が fzf に正しく渡らない。$OutputEncoding は .NET の静的プロパティではなく
    # 普通の preference variable なので、関数内での代入はこのスコープのローカル
    # 変数になり、関数を抜ければ元に戻る (グローバルには残らない)。PowerShell 7 は
    # 既定が UTF-8 なので実質何も変わらない。
    # fzf の出力を受け取る側 ([Console]::OutputEncoding) は encoding.ps1 で UTF-8 に
    # してある。
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)

    # psmux (3.3.8 で確認) は #{session_name} をときどき空で返す。行数は
    # セッション数どおりだが一部の行が空になり、作成直後のセッションが複数
    # あると 1 割ほどの頻度で起きる (書式を指定しない ls でも同様に欠ける)。
    # 空行があれば数回取り直し、それでも残った空行は捨てる。
    foreach ($Attempt in 1..3) {
        $Sessions = @(psmux list-sessions -F '#{session_name}' 2>$null)
        if ($Sessions -notcontains '') {
            break
        }
        Write-Verbose "psmux returned an empty session name (attempt $Attempt)."
    }
    $Sessions = @($Sessions | Where-Object { $_ })

    # tmux はサーバが無いと "no server running" で exit 1 になるが、psmux は
    # exit 0 で何も出力しない。終了コードではなく一覧が空かどうかで判定する。
    if (-not $Sessions) {
        Write-Verbose 'No psmux session found. Starting "main".'
        psmux new-session -s main
        return
    }

    $Selected = $Sessions | fzf --prompt='psmux> ' --height=40% --reverse `
        --header='enter: attach / ctrl-n: new session' `
        --bind 'ctrl-n:print-query'
    # 空白だけのクエリで ctrl-n を押した場合も「何も選ばなかった」扱いにする
    $Name = "$Selected".Trim()
    if (-not $Name) {
        Write-Verbose 'No session selected (escaped or none matched?). Aborting.'
        return
    }
    Write-Verbose "Selected session: $Name"

    # new-session -s はこれらを受け付けるが、-t ではウィンドウ / ペインの区切り
    # として解釈されるため、作ったセッションを二度と指定できなくなる
    if ($Name -match '[.:]') {
        Write-Error "session name must not contain '.' or ':'. Aborting."
        return
    }

    psmux has-session -t "=$Name" 2>$null
    if ($LASTEXITCODE -ne 0) {
        psmux new-session -d -s $Name
        if ($LASTEXITCODE -ne 0) {
            return
        }
    }

    if ($env:TMUX) {
        psmux switch-client -t "=$Name"
    } else {
        psmux attach-session -t "=$Name"
    }
}
# Linux 側は既存の ts コマンドと衝突するため its に改名した。Windows でも
# 名前を揃えて its に統一する。
Set-Alias its Invoke-PsmuxSessionPicker
