#!/usr/bin/env bash
# Claude Code の最小 statusline: cwd / git worktree / git branch / モデル・effort。
# 追加プロセスは jq 1 回 + git 1 回だけ。

input=$(cat)

# 必要な値をまとめて 1 行ずつ取り出す（jq は 1 プロセスのみ）
{
  read -r raw_cwd
  read -r model
  read -r effort
  read -r thinking
  read -r fast
  read -r rate_5h_percentage
  read -r rate_5h_resets_at
  read -r rate_7d_percentage
  read -r rate_7d_resets_at
  read -r ctx_used_percentage
  read -r cache_expires_at
} <<<"$(jq -r '
  (.workspace.current_dir // .cwd // ""),
  (.model.display_name // .model.id // ""),
  (.effort.level // ""),
  (if .thinking.enabled then "Thinking" else "" end),
  (if .fast_mode then "fast" else "" end),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.context_window.used_percentage // ""),
  (if .prompt_cache.warm then (.prompt_cache.expires_at // "") else "" end)
' <<<"$input")"

# Windows 版 jq は CRLF で出力するため、末尾の CR を落とす
raw_cwd=${raw_cwd%$'\r'}
model=${model%$'\r'}
effort=${effort%$'\r'}
thinking=${thinking%$'\r'}
fast=${fast%$'\r'}
rate_5h_percentage=${rate_5h_percentage%$'\r'}
rate_7d_percentage=${rate_7d_percentage%$'\r'}
rate_5h_resets_at=${rate_5h_resets_at%$'\r'}
rate_7d_resets_at=${rate_7d_resets_at%$'\r'}
ctx_used_percentage=${ctx_used_percentage%$'\r'}
cache_expires_at=${cache_expires_at%$'\r'}

cwd=$raw_cwd
# Windows 形式（C:\... や ...\...）のときだけ cygpath を呼ぶ。Linux では fork しない
case $cwd in
  [A-Za-z]:* | *\\*) cwd=$(cygpath -u "$cwd" 2>/dev/null || printf '%s' "$cwd") ;;
esac
[ -d "$cwd" ] && cd "$cwd"

# ホーム配下は ~ に短縮
disp=${cwd/#$HOME/\~}

# 色定義（path=シアン, worktree=マゼンタ, branch=グリーン, キャッシュ=ブルー, 警告=イエロー）
c_path=$'\033[36m'
c_worktree=$'\033[35m'
c_branch=$'\033[32m'
c_cache=$'\033[34m'
c_warn=$'\033[33m'
c_reset=$'\033[0m'

disp="${c_path}${disp}${c_reset}"

# git 情報は 1 プロセスでまとめて取得
worktree='' branch=''
if info=$(git rev-parse --show-toplevel --abbrev-ref HEAD --git-dir --git-common-dir 2>/dev/null); then
  { read -r top; read -r branch; read -r gitdir; read -r common; } <<<"$info"
  worktree=${top##*/}
  # リンク worktree（メインの作業ツリーでない）は印を付ける
  [ "$gitdir" != "$common" ] && worktree="⑂$worktree"
  [ "$branch" = HEAD ] && branch='(detached)'
  worktree="${c_worktree}${worktree}${c_reset}"
  branch="${c_branch}${branch}${c_reset}"
fi

# モデル表示: "Opus 5 (medium) thinking"（effort 非対応モデルではモデル名のみ）
# fast モード時は "Opus 5 ⚡ (medium)"
info_model=$model
[ -n "$fast" ] && info_model="$info_model ⚡"
[ -n "$effort" ] && info_model="$info_model ($effort)"
[ -n "$thinking" ] && info_model="$info_model $thinking"

line1=$disp
[ -n "$worktree" ] && line1="$line1  $worktree  $branch"
[ -n "$info_model" ] && line1="[$info_model]  $line1"

# API から渡る割合が 7.0000001 のような浮動小数点誤差を含むことがあるので
# 表示前に小数点以下 2 桁へ丸める
fmt_pct() { [ -n "$1" ] && printf '%.2f' "$1"; }

rate_5h_percentage=$(fmt_pct "$rate_5h_percentage")
rate_7d_percentage=$(fmt_pct "$rate_7d_percentage")
ctx_used_percentage=$(fmt_pct "$ctx_used_percentage")

line2=""
[ -n "$rate_7d_percentage" ] && line2="7d: $rate_7d_percentage%" || line2="7d: N/A"
# 7d は週単位なので時刻まで出すと冗長。行が長くなって折り返すので日付だけにする
[ -n "$rate_7d_resets_at" ]  && line2="$line2 (Resets at $(date -d "@$rate_7d_resets_at" +"%F"))"
[ -n "$rate_5h_percentage" ] && line2="$line2, 5h: $rate_5h_percentage%" || line2="$line2, 5h: N/A"
[ -n "$rate_5h_resets_at" ]  && line2="$line2 (Resets at $(date -d "@$rate_5h_resets_at" +"%F %T"))"
[ -n "$ctx_used_percentage" ] && line2="$line2, ctx: $ctx_used_percentage%"

# 多重化の外で動いていたら警告する。シェル起動時の自動起動はやめたので、
# 起動し忘れると端末を閉じた (ssh が切れた) 時点で作業ごと中断される。
# statusline は claude の子プロセスなので、claude が起動された環境をそのまま
# 見られる。fork せず環境変数だけで判定する。
#
# プロンプトキャッシュの失効時刻はその前に置く。TTL は 5m か 1h なので日付は
# 自明で、時刻だけ出す。warm でないときは expires_at が過去の時刻や null になり
# 意味を持たないので出さない。statusline は expires_at の時点で再描画されるため、
# 失効すれば refreshInterval 無しでも表示が消える。
line3=""
[ -n "$cache_expires_at" ] && line3="${c_cache}Cache expires at $(date -d "@$cache_expires_at" +"%T")${c_reset}"
if [ -z "${TMUX:-}${STY:-}${ZELLIJ:-}${HERDR_ENV:-}" ]; then
  [ -n "$line3" ] && line3="$line3  "
  line3="${line3}${c_warn}⚠ not in herdr/tmux: closing this terminal ends the session${c_reset}"
fi

printf '%s\n%s\n%s' "$line1" "$line2" "$line3"
