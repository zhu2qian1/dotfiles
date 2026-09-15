# zoxide. 番号を大きくしてあるのは、prompt より後に init する必要があるため。
#
# starship init は既存の PROMPT_COMMAND を STARSHIP_PROMPT_COMMAND へ退避して
# PROMPT_COMMAND を starship_precmd だけに置き換える。zoxide を先に init すると
# フック自体は starship 経由で呼ばれ続けるものの、zoxide の doctor は
# PROMPT_COMMAND しか見ないので「初期化が最後になっていない」と警告を出す。
# 後から init すれば PROMPT_COMMAND='starship_precmd;__zoxide_hook' となり、
# starship が $? を読んだ後に zoxide が走る (どちらも終了ステータスを保つ)。
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
