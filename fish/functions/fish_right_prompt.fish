function fish_right_prompt
    test -z "$CMD_DURATION"; and return

    if test $CMD_DURATION -gt 60000
        set -l mins (math --scale=0 "$CMD_DURATION / 60000")
        set -l secs (math --scale=0 "($CMD_DURATION % 60000) / 1000")
        set_color d7af00
        if test $secs -gt 0
            echo -n "$mins"m"$secs"s
        else
            echo -n "$mins"m
        end
        set_color normal
    else if test $CMD_DURATION -gt 1000
        set -l secs (math --scale=0 "$CMD_DURATION / 1000")
        set_color d7af00
        echo -n "$secs"s
        set_color normal
    end
end
