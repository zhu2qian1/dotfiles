uuidv7() {
    local ms ts_hex rb time_high time_low
    local b0 b1 b2 rest ver_and_rand_a var_and_rand_b

    ms=$(( $(date +%s%N) / 1000000 ))
    ts_hex=$(printf '%012x' "$ms")

    rb=$(od -An -N10 -tx1 /dev/urandom | tr -d ' \n')

    time_high="${ts_hex:0:8}"
    time_low="${ts_hex:8:4}"

    b0=${rb:0:2}
    b1=${rb:2:2}
    ver_and_rand_a=$(printf '7%01x%s' $(( 16#${b0} & 0xF )) "$b1")

    b2=$(( (16#${rb:4:2} & 0x3F) | 0x80 ))
    rest=${rb:6:10}
    var_and_rand_b=$(printf '%02x%s' "$b2" "$rest")

    printf '%s-%s-%s-%s-%s\n' \
        "$time_high" "$time_low" "$ver_and_rand_a" \
        "${var_and_rand_b:0:4}" "${var_and_rand_b:4:12}"
}
