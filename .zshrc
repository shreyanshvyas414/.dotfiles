[[ -o interactive ]] || return

if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]]; then
  if [[ "$TERM_PROGRAM" == "ghostty" || -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    if ! tmux has-session -t home 2>/dev/null; then
      tmux new-session -d -s home
    fi
    exec tmux attach -t home
  fi
fi

export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"
export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"
export PATH=/usr/local/clamav/bin:/usr/local/clamav/sbin:$PATH
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

export TOKEN_SAVIOR_PROFILE=optimized
export TOKEN_SAVIOR_CLIENT=claude-code
export CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1
export CLAUDE_CODE_DISABLE_AGENT_VIEW=1
export WORKSPACE_ROOTS="$HOME/Documents/Work/chattypie"

export TS_BASH_COMPACT=1
export TS_BASH_REWRITE=1

export PATH="/Users/shrey99sh/.antigravity-ide/antigravity-ide/bin:$PATH"

export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "$HOME/.cache/zsh"
# zsh-autocomplete points zsh's recent-dirs (cdr) file at this directory but
# does not create it; without this every `cd` errors from chpwd_recent_filehandler.
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"

# Completion: zsh-autocomplete runs compinit itself, so do not call compinit
# separately (per its README). It must also be sourced before anything that
# calls compdef - `zoxide init` and `fnm env` below both do.
zstyle '*:compinit' arguments -d "$ZSH_COMPDUMP"
source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

bindkey -e
bindkey '^[f' forward-word
bindkey '^[b' backward-word
bindkey '^W' backward-kill-word
bindkey '^U' kill-whole-line
bindkey '^K' kill-line
bindkey '^?' backward-delete-char

KEYTIMEOUT=1

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v zoxide >/dev/null 2>&1; then
  export _ZO_FZF_CMD="fzf"
  export _ZO_FZF_OPTS="--height 40% --reverse"
  eval "$(zoxide init zsh)"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# if command -v direnv >/dev/null 2>&1; then
#   eval "$(direnv hook zsh)"
# fi



[[ -f /Users/shrey99sh/lua/.profile ]] && source /Users/shrey99sh/lua/.profile

alias cd='z'
alias cdi='zi'
alias pc="pbcopy"
alias ll='eza -alF'
alias la='eza -a'
alias l='eza -F'
alias dir='eza -a'
alias cl='clear'
alias cls="clear"
alias cs="clear"
alias co='code'
alias sc='source'
alias rf='rm -rf'
alias t='touch'
alias mkd='mkdir'
alias hs='history'
alias cat="bat"

export EDITOR="nvim"
export VISUAL="nvim"
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias vm='vim'
alias nv="neovide"

alias python="python3"
alias py="python3"
alias pip="pip3"

alias nis='npm install'
alias ns='npm start'
alias nrd='npm run dev'
alias nt='npm run test'

alias lg='lazygit'
alias gi='git init'
alias gb='git branch'
alias gfa='git fetch'
alias gbb='git checkout -b'
alias gs='git status'
alias gsa='git stash'
alias gpo='git stash pop'
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

alias bi='brew install'
alias bu='brew uninstall'
alias bl='brew list'
alias bc='brew cleanup'

alias cr='cargo run'

alias tls="tmux list-sessions"
alias ts="tmux list-sessions"
alias m="tmux"
alias te="exit"

alias token-get='token-ts get'
alias token-ctx='token-ts ctx'
alias token-search='token-ts search'
alias token-structure='token-ts structure'
alias token-ts='uvx --from "token-savior-recall[memory-vector]" ts'

mkcd() {
  if [[ -z "$1" ]]; then
    echo "mkcd: missing directory name"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

pj() {
  local dir
  dir=$(zoxide query -l | fzf) && cd -- "$dir"
}

finder() {
  open .
}
zle -N finder
bindkey '^f' finder

y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

yazi-widget() {
  y
  zle reset-prompt
}
zle -N yazi-widget
bindkey '^[o' yazi-widget

setopt PROMPT_SUBST

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

# Single line, full path with $HOME collapsed to ~ (zsh %~), matching
# fish_prompt. Colours unchanged; dir_color must stay the first
# substitution so it still sees the real $?.
PS1='$(dir_color)%~%f$(git_prompt)$(arrow_color) $ %f'

time_color() {
  echo "%F{222}"
}

RPROMPT='${CMD_DURATION}'
# RPROMPT='%F{222}%D{%I:%M %p}%f'

export PATH="/Users/shrey99sh/.antigravity-ide/antigravity-ide/bin:$PATH"
export PATH="/Users/shrey99sh/.local/share/fnm/node-versions/v24.19.0/installation/bin:$PATH"

# Must stay at the very end: it wraps ZLE widgets, so anything that defines
# widgets after this point would not get highlighted.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
