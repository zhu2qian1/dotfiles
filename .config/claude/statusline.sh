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
[ -n "$cwd" ] && cwd=$(cygpath -u "$cwd" 2>/dev/null || printf '%s' "$cwd")
[ -d "$cwd" ] && cd "$cwd"

# ホーム配下は ~ に短縮
disp=${cwd/#$HOME/\~}

# git 情報は 1 プロセスでまとめて取得
worktree='' branch=''
if info=$(git rev-parse --show-toplevel --abbrev-ref HEAD --git-dir --git-common-dir 2>/dev/null); then
  { read -r top; read -r branch; read -r gitdir; read -r common; } <<<"$info"
  worktree=$(basename "$top")
  # リンク worktree（メインの作業ツリーでない）は印を付ける
  [ "$gitdir" != "$common" ] && worktree="⑂$worktree"
  [ "$branch" = HEAD ] && branch='(detached)'
fi

# モデル表示: "Opus 5 · medium"（effort 非対応モデルではモデル名のみ）
# fast モード時は "Opus 5 ⚡ medium"
info_model=$model
[ -n "$fast" ] && info_model="$info_model ⚡"
[ -n "$effort" ] && info_model="$info_model ($effort)"
[ -n "$thinking" ] && info_model="$info_model $thinking"

line1=$disp
[ -n "$worktree" ] && line1="$line1  $worktree  $branch"
[ -n "$info_model" ] && line1="[$info_model]  $line1"

line2=""
# mae-kakou
[ -n "$rate_5h_percentage" ] && line2="5h: $rate_5h_percentage%" || line2="5h: N/A"
[ -n "$rate_5h_resets_at" ]  && line2="$line2 (Resets at $(printf "$rate_5h_resets_at" | awk '$0="@"$0' | xargs -I {} date -d {} +"%F %T"))"
[ -n "$rate_7d_percentage" ] && line2="$line2, 7d: $rate_7d_percentage%" || line2="$line2, 7d: N/A"

line3=""

printf '%s\n%s\n%s' "$line1" "$line2" "$line3"
