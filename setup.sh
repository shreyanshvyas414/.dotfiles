#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$HOME/Documents/stuff/dots"
INSTALL_TOOLS=true
DRY_RUN=false

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[•]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -nt|--no-tools) INSTALL_TOOLS=false; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: ./setup.sh [--no-tools] [--dry-run]"
      exit 0 ;;
    *) shift ;;
  esac
done

run() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

echo ""
log "Installing dotfiles..."
echo ""

# Install tools (macOS)
if $INSTALL_TOOLS && [[ "$OSTYPE" == "darwin"* ]]; then
  log "Installing tools via Homebrew..."

  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  tools=(tmux neovim fzf ripgrep fd git alacritty bob node starship)

  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      log "Installing $tool..."
      if ! run brew install "$tool"; then
        run brew install --cask "$tool" || warn "Failed to install $tool"
      fi
    fi
  done

  # Nerd Font
  run brew tap homebrew/cask-fonts
  run brew install --cask font-fira-code-nerd-font || true

  success "Tools installed"
  echo ""
fi

# Create directories
log "Creating config directories..."
run mkdir -p "$HOME/.config/alacritty"
run mkdir -p "$HOME/.config/tmux"
run mkdir -p "$HOME/.config/nvim"
run mkdir -p "$HOME/.config/zsh"
run mkdir -p "$HOME/Scripts"

# Symlink helper
install() {
  local src="$1"
  local dest="$2"
  local name="$3"

  if [[ ! -e "$src" ]]; then
    warn "Not found: $src"
    return
  fi

  # Backup existing real files
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    run mv "$dest" "$dest.backup.$(date +%s)"
  fi

  # Remove old symlink
  [[ -L "$dest" ]] && run rm "$dest"

  run ln -sf "$src" "$dest"
  success "$name"
}

log "Linking configs..."

install "$DOTFILES/alacritty/alacritty.conf" \
        "$HOME/.config/alacritty/alacritty.conf" \
        "Alacritty"

install "$DOTFILES/git/.gitconfig" \
        "$HOME/.gitconfig" \
        "Git"

install "$DOTFILES/tmux/.tmux.conf" \
        "$HOME/.config/tmux/.tmux.conf" \
        "Tmux"

install "$DOTFILES/nvim" \
        "$HOME/.config/nvim" \
        "Neovim"

install "$DOTFILES/zsh" \
        "$HOME/.config/zsh" \
        "Zsh config"

install "$DOTFILES/starship/starship.toml" \
        "$HOME/.config/starship.toml" \
        "Starship"

# .zshrc Setup
if [[ ! -f "$HOME/.zshrc" ]]; then
  log "Creating .zshrc..."

  cat > "$HOME/.zshrc" <<'ZSHRC'
# Auto-start tmux (Alacritty only)
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  if [ "$TERM_PROGRAM" = "alacritty" ] || [ "$ALACRITTY_SOCKET" ]; then
    if ! tmux has-session -t main 2>/dev/null; then
      tmux new-session -d -s main
    fi
    exec tmux attach -t main
  fi
fi

# Modular Zsh config
ZSH_CONFIG="$HOME/.config/zsh"
for file in env cache aliases completion history options keybinds; do
  [[ -f "$ZSH_CONFIG/$file.zsh" ]] && source "$ZSH_CONFIG/$file.zsh"
done

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
ZSHRC

  success ".zshrc created"
else
  # Ensure starship init exists
  if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
    log "Adding Starship init to existing .zshrc..."
    echo -e '\n# Starship prompt\nif command -v starship &>/dev/null; then\n  eval "$(starship init zsh)"\nfi' >> "$HOME/.zshrc"
    success "Starship added to .zshrc"
  fi
fi

# Scripts
if [[ -d "$DOTFILES/Scripts" ]]; then
  log "Installing scripts..."
  for script in "$DOTFILES/Scripts"/*; do
    [[ -f "$script" ]] || continue
    dest="$HOME/Scripts/$(basename "$script")"
    run ln -sf "$script" "$dest"
    run chmod +x "$dest"
  done
  success "Scripts"
fi

# Neovim Setup
if command -v nvim &>/dev/null && ! $DRY_RUN; then
  log "Installing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa || true
  success "Neovim plugins installed"
fi

echo ""
success "Done!"
echo ""
log "Next steps:"
echo "  1. Restart terminal: exec zsh"
echo "  2. Test Neovim: nvim"
echo "  3. Test Tmux: tmux"
echo ""
