# Interactive shells only
[[ -o interactive ]] || return

# Tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    if [ "$TERM_PROGRAM" = "alacritty" ] || [ "$ALACRITTY_SOCKET" ]; then
        if ! tmux has-session -t main 2>/dev/null; then
            tmux new-session -d -s main
        fi
        exec tmux attach -t main
    fi
fi


ZSH_CONFIG="$HOME/.config/zsh"

source "$ZSH_CONFIG/env.zsh"
source "$ZSH_CONFIG/cache.zsh"
source "$ZSH_CONFIG/aliases.zsh"
source "$ZSH_CONFIG/completion.zsh"
source "$ZSH_CONFIG/history.zsh"
source "$ZSH_CONFIG/options.zsh"
source "$ZSH_CONFIG/keybinds.zsh"
source "$ZSH_CONFIG/prompt.zsh"

# External profile
source /Users/shrey99sh/lua/.profile

