function __shrey_pwd
    set -l p (string replace -r '^'"$HOME"'' '~' (pwd))
    set -l parts (string split '/' $p)
    set -l n (count $parts)
    if test $n -gt 2
        string join '/' $parts[-2..-1]
    else
        echo $p
    end
end

function fish_prompt
    set -l last_status $status

    set -l dir_color ffd787
    if test $last_status -ne 0
        set dir_color brred
    else if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set dir_color 87afaf
    end

    set -l arrow_color ffd787
    git rev-parse --is-inside-work-tree >/dev/null 2>&1; and set arrow_color 87af87

    set_color brmagenta
    echo -n (whoami)' '
    set_color ffd787
    echo -n 'in '
    set_color $dir_color
    echo -n (__shrey_pwd)
    set_color normal

    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -n "$branch"
        set_color ffd787
        echo -n ' '
        set_color 87af87
        echo -n $branch
        set_color normal
    end

    echo
    set_color $arrow_color
    echo -n '$ '
    set_color normal
end
