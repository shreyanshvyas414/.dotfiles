#!/usr/bin/env bash
# Fuzzy-open a bookmark from links.tsv.
#   enter  open in browser
#   ctrl-y copy the URL
#   ctrl-e edit links.tsv in $EDITOR
set -uo pipefail

LINKS_FILE="${LINKS_FILE:-$HOME/.config/links.tsv}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fzf-themes.sh"

if [[ ! -f "$LINKS_FILE" ]]; then
    echo "Missing links file: $LINKS_FILE" >&2
    exit 1
fi

# Drop the header row and any blank/comment lines.
rows=$(tail -n +2 "$LINKS_FILE" | grep -v '^[[:space:]]*\(#\|$\)' || true)
[[ -n "$rows" ]] || exit 0

selection=$(
    printf '%s\n' "$rows" \
        | fzf "${FZF_THEME_LINKS[@]}" \
            --delimiter=$'\t' \
            --with-nth 1,2 \
            --nth 1,2 \
            --prompt="links> " \
            --expect=ctrl-e,ctrl-y
) || exit 0

# With --expect, fzf prints the pressed key on line 1 (empty for enter)
# and the selected row on line 2.
key=$(printf '%s\n' "$selection" | sed -n '1p')
line=$(printf '%s\n' "$selection" | sed -n '2p')
[[ -n "$line" ]] || exit 0

IFS=$'\t' read -r title url <<< "$line"
[[ -n "$url" ]] || exit 0

case "$key" in
    ctrl-e)
        exec "${EDITOR:-nvim}" "$LINKS_FILE"
        ;;
    ctrl-y)
        printf '%s' "$url" | pbcopy
        [[ -n "${TMUX:-}" ]] && tmux display-message "Copied: ${title:-$url}"
        ;;
    *)
        open "$url"
        ;;
esac
