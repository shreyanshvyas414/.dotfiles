#!/usr/bin/env bash
# Fuzzy-pick a project directory, then create-or-switch to a tmux session
# named after it. With one argument, skip the picker and use that path.
set -uo pipefail

# Directories whose immediate children are each a project.
PROJECT_PARENTS=(
    "$HOME/Documents"
    "$HOME/Documents/Work"
)

# Directories that are themselves a destination, listed verbatim.
PLAIN_DIRS=(
    "$HOME"
    "$HOME/.config"
    "$HOME/Documents"
    "$HOME/Documents/Work"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fzf-themes.sh"

candidates() {
    local d
    for d in "${PLAIN_DIRS[@]}"; do
        [[ -d "$d" ]] && printf '%s\n' "$d"
    done

    local parents=()
    for d in "${PROJECT_PARENTS[@]}"; do
        [[ -d "$d" ]] && parents+=("$d")
    done
    if (( ${#parents[@]} )); then
        fd . "${parents[@]}" --type=dir --max-depth=1 --full-path 2>/dev/null \
            | sed 's|/$||'
    fi
}

if [[ $# -eq 1 ]]; then
    selected="${1/#\~/$HOME}"
else
    selected=$(
        candidates \
            | sed "s|^$HOME/|~/|; s|^$HOME$|~|" \
            | awk '!seen[$0]++' \
            | fzf "${FZF_THEME_SESSION[@]}" --prompt="session> "
    )

    [[ -n "$selected" ]] || exit 0
    selected="${selected/#\~/$HOME}"
fi

[[ -n "$selected" && -d "$selected" ]] || exit 0

# tmux session names cannot contain "." or ":".
if [[ "$selected" == "$HOME" ]]; then
    selected_name="home"
else
    selected_name=$(basename "$selected" | tr '.:' '__')
fi

if ! tmux has-session -t "=$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "=$selected_name"
else
    tmux attach-session -t "=$selected_name"
fi
