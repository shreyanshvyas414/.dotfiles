function pj --description 'Fuzzy-select a zoxide directory with fzf and cd into it'
    set -l dir (zoxide query -l | fzf)
    and cd -- $dir
end
