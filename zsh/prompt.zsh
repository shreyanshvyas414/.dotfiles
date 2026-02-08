setopt PROMPT_SUBST

# Colors
MAGENTA='%F{13}'
YELLOW='%F{222}'
CYAN='%F{10}'
RED='%F{9}'
GRAY='%F{185}'
GREEN='%F{2}'
RESET='%f'

# Directory
dir_color() {
  if [[ $? -ne 0 ]]; then
    echo "$RED"
    return
  fi
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$CYAN" || echo "$YELLOW"
}

# Git branch indicator
git_prompt() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    echo " ${RED}on ${CYAN}$branch${RESET}"
  fi
}

# Git
in_color() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$RED" || echo "$GRAY"
}

# Arrow
arrow_color() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$RED" || echo "$GRAY"
}

# Timw
time_color() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$RED" || echo "$GRAY"
}

# Left
PROMPT='${MAGENTA}%n $(in_color)in $(dir_color)%2~${RESET}$(git_prompt)
$(arrow_color)❯${RESET} '

# Right
RPROMPT='$(time_color)%D{%I:%M %p}${RESET}'

