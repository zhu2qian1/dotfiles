#!/usr/bin/env bash
# lid が閉じている間だけ内蔵ディスプレイを消す (GNOME / mutter)。
#
# logind の HandleLidSwitch* が決めるのは suspend するかどうかだけ。AC 接続中は
# HandleLidSwitchExternalPower=ignore で起こしたままにする (クラムシェルで CI
# サーバ的に使う) が、そうすると GNOME は内蔵パネルを点けっぱなしにする。lid を
# 閉じても mutter の PowerSaveMode は 0 のまま、backlight も落ちないことを実機
# (Ubuntu 24.04 / GNOME 46) で確認した。そこで UPower の LidIsClosed を購読して
# PowerSaveMode を直接切り替える。バッテリー時は logind が suspend するので、
# その直前にここで消灯しても害は無い。
#
# lid の検知自体はファームウェア任せ。Dell は BIOS の "Lid Switch" が無効だと
# _LID が常に open を返し、LidIsClosed が一度も変化しない。
set -u

# PATH 上で linuxbrew の gdbus が /usr/bin より先に見つかる。brew の glib は
# system bus の既定ソケットを自分の prefix 配下で探すので "Could not connect:
# No such file or directory" で落ちる。session bus は systemd --user が
# DBUS_SESSION_BUS_ADDRESS を渡すので問題ない。
export DBUS_SYSTEM_BUS_ADDRESS="${DBUS_SYSTEM_BUS_ADDRESS:-unix:path=/run/dbus/system_bus_socket}"

# PowerSaveMode: 0=on, 3=off。gsd-power がアイドル時の消灯に使うのと同じ値。
set_power_save() {
    gdbus call --session \
        --dest org.gnome.Mutter.DisplayConfig \
        --object-path /org/gnome/Mutter/DisplayConfig \
        --method org.freedesktop.DBus.Properties.Set \
        org.gnome.Mutter.DisplayConfig PowerSaveMode "<int32 $1>" >/dev/null
}

# monitor は変化しか流さない。閉じたままログインし直した・サービスを再起動した
# 場合に備え、起動時点の状態を先に反映する。
if gdbus call --system \
        --dest org.freedesktop.UPower \
        --object-path /org/freedesktop/UPower \
        --method org.freedesktop.DBus.Properties.Get \
        org.freedesktop.UPower LidIsClosed | grep -q true; then
    set_power_save 3
fi

# PropertiesChanged は他のプロパティとまとめて届くことがある
# ({'OnBattery': <false>, 'LidIsClosed': <true>} など) ので部分一致で拾う。
gdbus monitor --system \
        --dest org.freedesktop.UPower \
        --object-path /org/freedesktop/UPower |
    while IFS= read -r line; do
        case "$line" in
            *"'LidIsClosed': <true>"*)  set_power_save 3 ;;
            *"'LidIsClosed': <false>"*) set_power_save 0 ;;
        esac
    done
