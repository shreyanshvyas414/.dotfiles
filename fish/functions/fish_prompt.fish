function __shrey_pwd --description 'Current directory with $HOME collapsed to ~, like zsh %~'
    set -l p (pwd)
    if test "$p" = "$HOME"
        echo '~'
    else if string match -q -- "$HOME/*" "$p"
        echo '~/'(string sub -s (math (string length "$HOME") + 2) -- "$p")
    else
        echo "$p"
    end
end

function fish_prompt
    set -l last_status $status

    # One git query per prompt, reused for both colours and the branch.
    set -l in_git 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1; and set in_git 1

    set -l dir_color ffd787
    if test $last_status -ne 0
        set dir_color brred
    else if test $in_git -eq 1
        set dir_color 87afaf
    end

    set -l arrow_color ffd787
    test $in_git -eq 1; and set arrow_color 87af87

    set_color $dir_color
    echo -n (__shrey_pwd)
    set_color normal

    if test $in_git -eq 1
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color 87af87
            echo -n " $branch"
            set_color normal
        end
    end

    set_color $arrow_color
    echo -n ' $ '
    set_color normal
end
