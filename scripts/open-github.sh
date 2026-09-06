#!/usr/bin/env bash
# Open the current repository's origin remote in the browser.
# Takes the directory as $1 (tmux passes #{pane_current_path}); defaults to PWD.
set -uo pipefail

target_dir="${1:-$PWD}"
target_dir="${target_dir/#\~/$HOME}"
cd "$target_dir" 2>/dev/null || exit 1

notify() {
    if [[ -n "${TMUX:-}" ]]; then
        tmux display-message "$1"
    else
        echo "$1" >&2
    fi
}

url=$(git remote get-url origin 2>/dev/null) || {
    notify "Not a git repository (or no 'origin' remote)"
    exit 1
}

# git@host:owner/repo.git  ->  https://host/owner/repo
if [[ "$url" == git@* ]]; then
    url="${url#git@}"
    url="${url/://}"
fi
url="${url%.git}"
[[ "$url" == http* ]] || url="https://$url"

open "$url"
