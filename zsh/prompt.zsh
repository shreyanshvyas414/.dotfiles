setopt PROMPT_SUBST

# Soothing colors (all from 1–12 range-ish)
MAGENTA='%F{13}'     # username (keep, you like it)
YELLOW='%F{222}'     # neutral UI (time, normal dirs)
CYAN='%F{109}'       # git dirs (soft blue)
GREEN='%F{108}'      # git branch (muted green)
RED='%F{9}'          # errors ONLY
GRAY='%F{222}'       # glue text (in, separators)
RESET='%f'


# Directory color logic
dir_color() {
  if [[ $? -ne 0 ]]; then
    echo "$RED"
    return
  fi
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$CYAN" || echo "$YELLOW"
}

# Git branch (icon + darker color only)
git_prompt() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n $branch ]]; then
    echo " ${GRAY} ${GREEN}$branch${RESET}"
  fi
}

# Dynamic "in" color
in_color() {
  echo "$GRAY"
}

# $ color
arrow_color() {
  git rev-parse --is-inside-work-tree &>/dev/null && echo "$CYAN" || echo "$GRAY"
}

# Time color
time_color() {
  echo "$YELLOW"
}

# Left prompt (unchanged)
PROMPT='${MAGENTA}%n ${GRAY}in $(dir_color)%2~${RESET}$(git_prompt)
$(arrow_color)$ ${RESET}'

# Right prompt (unchanged)
#RPROMPT='$(time_color)%D{%I:%M %p}${RESET}'

