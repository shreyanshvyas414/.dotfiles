#!/usr/bin/env bash
# Find every runnable script under the current project, pick one, run it,
# and hold the pane open so you can read the output.
set -uo pipefail

target_dir="${1:-$PWD}"
target_dir="${target_dir/#\~/$HOME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/fzf-themes.sh"

if [[ ! -d "$target_dir" ]]; then
    echo "Directory does not exist: $target_dir" >&2
    exit 1
fi

cd "$target_dir" || exit 1

classify_script() {
    local path="$1" name first_line
    name="$(basename "$path")"

    case "$name" in
        *.py) printf 'python'; return 0 ;;
        *.sh|*.bash|*.zsh) printf 'bash'; return 0 ;;
        *.fish) printf 'fish'; return 0 ;;
    esac

    first_line=""
    IFS= read -r -n 256 first_line < "$path" 2>/dev/null || true

    case "$first_line" in
        '#!'*python*)                       printf 'python'; return 0 ;;
        '#!'*fish*)                         printf 'fish';   return 0 ;;
        '#!'*bash*|'#!'*sh|'#!'*sh\ *|'#!'*zsh*) printf 'bash'; return 0 ;;
    esac

    # Extension-less executables: run them directly.
    if [[ -x "$path" && "$name" != *.* ]]; then
        printf 'exec'
        return 0
    fi

    return 1
}

find_scripts() {
    find . \
        \( -name .git -o -name node_modules -o -name .venv -o -name venv \
           -o -name __pycache__ -o -name .mypy_cache -o -name .pytest_cache \
           -o -name .ruff_cache -o -name target -o -name dist -o -name build \
           -o -name .next -o -name .svelte-kit -o -name .turbo -o -name vendor \
           -o -name .direnv -o -name Pods \
        \) -type d -prune -o \
        -type f \
        \( -name '*.py' -o -name '*.sh' -o -name '*.bash' -o -name '*.fish' \
           -o -perm -u+x \
        \) -print0
}

list_scripts() {
    while IFS= read -r -d '' path; do
        kind="$(classify_script "$path" || true)"
        [[ -n "$kind" ]] || continue
        printf '%s\t%s\t%s\n' "${path#./}" "$kind" "$path"
    done < <(find_scripts)
}

selected="$(
    list_scripts \
        | sort \
        | fzf "${FZF_THEME_SCRIPTS[@]}" \
            --delimiter=$'\t' \
            --with-nth 1,2 \
            --nth 1,2 \
            --prompt="scripts> "
)" || exit 0

[[ -n "$selected" ]] || exit 0

IFS=$'\t' read -r display_name kind path <<< "$selected"

# Retitle the tmux window after what is running.
printf '\033]2;%s\033\\' "script:${display_name}"
printf 'Running %s in %s\n\n' "$display_name" "$target_dir"

status=0
case "$kind" in
    python) python3 "$path" || status=$? ;;
    bash)   bash    "$path" || status=$? ;;
    fish)   fish    "$path" || status=$? ;;
    exec)   "$path"          || status=$? ;;
    *)      echo "Unknown script type: $kind" >&2; status=1 ;;
esac

printf '\n'
if [[ "$status" -eq 0 ]]; then
    printf 'Finished: %s\n' "$display_name"
else
    printf 'Exited with status %s: %s\n' "$status" "$display_name"
fi

printf 'Press enter to close... '
read -r _
exit "$status"
