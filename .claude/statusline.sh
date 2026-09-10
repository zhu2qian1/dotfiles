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
} <<<"$(jq -r '
  (.workspace.current_dir // .cwd // ""),
  (.model.display_name // .model.id // ""),
  (.effort.level // ""),
  (if .thinking.enabled then "Thinking" else "" end),
  (if .fast_mode then "fast" else "" end),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // "")
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

cwd=$raw_cwd
# Windows 形式（C:\... や ...\...）のときだけ cygpath を呼ぶ。Linux では fork しない
case $cwd in
  [A-Za-z]:* | *\\*) cwd=$(cygpath -u "$cwd" 2>/dev/null || printf '%s' "$cwd") ;;
esac
[ -d "$cwd" ] && cd "$cwd"

# ホーム配下は ~ に短縮
disp=${cwd/#$HOME/\~}

# 色定義（path=シアン, worktree=マゼンタ, branch=グリーン, 警告=イエロー）
c_path=$'\033[36m'
c_worktree=$'\033[35m'
c_branch=$'\033[32m'
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

line2=""
[ -n "$rate_5h_percentage" ] && line2="5h: $rate_5h_percentage%" || line2="5h: N/A"
[ -n "$rate_5h_resets_at" ]  && line2="$line2 (Resets at $(date -d "@$rate_5h_resets_at" +"%F %T"))"
[ -n "$rate_7d_percentage" ] && line2="$line2, 7d: $rate_7d_percentage%" || line2="$line2, 7d: N/A"

# 多重化の外で動いていたら警告する。シェル起動時の自動起動はやめたので、
# 起動し忘れると端末を閉じた (ssh が切れた) 時点で作業ごと中断される。
# statusline は claude の子プロセスなので、claude が起動された環境をそのまま
# 見られる。fork せず環境変数だけで判定する。
line3=""
if [ -z "${TMUX:-}${STY:-}${ZELLIJ:-}${HERDR_ENV:-}" ]; then
  line3="${c_warn}⚠ not in herdr/tmux: closing this terminal ends the session${c_reset}"
fi

printf '%s\n%s\n%s' "$line1" "$line2" "$line3"
