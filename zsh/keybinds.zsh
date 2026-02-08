bindkey -e

bindkey '^[f' forward-word
bindkey '^[b' backward-word

bindkey '^W' backward-kill-word
bindkey '^U' kill-whole-line
bindkey '^K' kill-line
bindkey '^?' backward-delete-char

KEYTIMEOUT=1

