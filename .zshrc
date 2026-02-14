# Interactive Shells Only
[[ -o interactive ]] || return

# Auto Tmux (Alacritty Only)
if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
  if [[ "$TERM_PROGRAM" == "alacritty" || -n "$ALACRITTY_SOCKET" ]]; then
    if ! tmux has-session -t main 2>/dev/null; then
      tmux new-session -d -s main
    fi
    exec tmux attach -t main
  fi
fi

# Environment

# Paths
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$PATH"

export ZATHURA_PLUGIN_PATH="$(brew --prefix)/opt/zathura/lib/zathura"

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Cache
export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "$HOME/.cache/zsh"

# Navigation Stack

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  export _ZO_FZF_CMD="sk"   # use skim instead of fzf
  export _ZO_FZF_OPTS="--height 40% --reverse"
  eval "$(zoxide init zsh)"
fi

# Direnv
# if command -v direnv >/dev/null 2>&1; then
#   eval "$(direnv hook zsh)"
# fi
#
# Utils

# Smart mkdir + cd
mkcd() {
  if [[ -z "$1" ]]; then
    echo "mkcd: missing directory name"
    return 1
  fi

  mkdir -p -- "$1" && cd -- "$1"
}

# Fuzzy project
pj() {
  zoxide query -l | sk | xargs -r cd
}

# Finder shortcut
finder() {
  open .
}
zle -N finder
bindkey '^f' finder

# Tree view
lt() {
  eza --tree --level=2 --icons
}

# Base eza wrapper
e() { eza --icons --group-directories-first "$@"; }

# Aliases

# Core
alias cd='z'
alias cdi='zi'
alias ls='e'
alias ll='e -alh --git'
alias la='e -a'
alias l='e -lh'
alias cl='clear'
alias cs='clear'
alias cls='clear'
alias co='code'
alias sc='source'
alias rf='rm -rf'
alias t='touch'
alias mkd='mkdir'
alias hs='history'
alias cat="bat"

# Editors
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias vm='vim'

# npm
alias nis='npm install'
alias ns='npm start'
alias nrd='npm run dev'
alias nt='npm run test'

# git
alias gi='git init'
alias gb='git branch'
alias gfa='git fetch'
alias gbb='git checkout -b'
alias gs='git status'
alias ga='git add'
alias glog='git log'
alias glg='git log'
alias glr='git reflog'
alias gif='git diff'
alias gpl='git pull origin'
alias gpu='git push origin'
alias gch='git checkout'
alias gr='git remote -v'
alias gra='git remote add origin'
alias gt='git tag'

# brew
alias bi='brew install'
alias bu='brew uninstall'
alias bl='brew list'

# rust
alias rn='cargo run'

# tmux
alias tls="tmux list-sessions"
alias ts="tmux list-sessions"
alias m="tmux"
alias te="exit"

# Completion
autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Options
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# Keybindings
bindkey -e
bindkey '^[f' forward-word
bindkey '^[b' backward-word
bindkey '^W' backward-kill-word
bindkey '^U' kill-whole-line
bindkey '^K' kill-line
bindkey '^?' backward-delete-char

KEYTIMEOUT=1

# External Profile
[[ -f /Users/shrey99sh/lua/.profile ]] && source /Users/shrey99sh/lua/.profile

# FNM
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Prompt #
setopt PROMPT_SUBST

# Duration
zmodload zsh/datetime
typeset -gi CMD_START_MS=0
typeset -g CMD_DURATION=""

preexec() {
  CMD_START_MS=$(( EPOCHREALTIME * 1000 ))
}

precmd() {
  (( CMD_START_MS == 0 )) && return
  local end_ms=$(( EPOCHREALTIME * 1000 ))
  local duration_ms=$(( end_ms - CMD_START_MS ))
  
  duration_ms=${duration_ms%.*}
  
  if (( duration_ms > 60000 )); then
    local mins=$((duration_ms / 60000))
    local secs=$(((duration_ms % 60000) / 1000))
    if (( secs > 0 )); then
      CMD_DURATION="%F{178}${mins}m${secs}s%f"
    else
      CMD_DURATION="%F{178}${mins}m%f"
    fi
  elif (( duration_ms > 1000 )); then
    CMD_DURATION="%F{178}$((duration_ms / 1000))s%f"
  else
    CMD_DURATION=""
  fi
  CMD_START_MS=0
}

dir_color() {
  if [[ $? -ne 0 ]]; then
    echo "%F{9}"
    return
  fi
  git rev-parse --is-inside-work-tree &>/dev/null && echo "%F{109}" || echo "%F{222}"
}

git_prompt() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    echo " %F{222} %F{108}$branch%f"
  fi
}

arrow_color() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo "%F{108}" || echo "%F{222}"
}

PROMPT='%F{13}%n %F{222}in $(dir_color)%2~%f$(git_prompt)
$(arrow_color)$ %f'

time_color() {
  echo "%F{222}"
}

# Uncomment if you want right prompt time
RPROMPT='${CMD_DURATION}'
# RPROMPT='%F{222}%D{%I:%M %p}%f'



# Starship
# export STARSHIP_CONFIG="$HOME/.config/starship.toml"
# eval "$(starship init zsh)"
#
# enable_transience() {
#   emulate -L zsh
#   starship_transient_prompt_func() {
#     starship module character
#   }
# }


# defaults write com.apple.dock autohide -bool true
# defaults write com.apple.Dock autohide -bool true
# defaults write com.apple.Dock autohide-delay -float 1000
# defaults write com.apple.universalaccess reduceMotion -bool true
#
# killall SystemUIServer
# killall Dock

