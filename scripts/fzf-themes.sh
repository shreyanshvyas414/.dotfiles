#!/usr/bin/env bash
# Shared fzf layout for every picker in this directory, so they all look alike.
# Source it, then expand one of the arrays into your fzf call:
#     source "$(dirname "${BASH_SOURCE[0]}")/fzf-themes.sh"
#     ... | fzf "${FZF_THEME_SESSION[@]}"

FZF_THEME_BASE=(
    --color=bw
    --height=100%
    --margin=0,0,0,0
    --layout=reverse
    --info=hidden
    --no-hscroll
)

# --scheme=path biases the fuzzy scorer toward path components (fzf >= 0.45).
FZF_THEME_SESSION=("${FZF_THEME_BASE[@]}" --scheme=path)

FZF_THEME_LINKS=("${FZF_THEME_BASE[@]}" --cycle)

FZF_THEME_SCRIPTS=("${FZF_THEME_BASE[@]}" --scheme=path)
