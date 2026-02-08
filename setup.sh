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
  
  tools=(tmux neovim fzf ripgrep fd git alacritty node)
  for tool in "${tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      run brew install "$tool" 2>/dev/null || run brew install --cask "$tool" 2>/dev/null || true
    fi
  done
  
  # Install font
  run brew tap homebrew/cask-fonts
  run brew install --cask font-fira-code-nerd-font 2>/dev/null || true
  
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

# Install configs
install() {
  local src="$1"
  local dest="$2"
  local name="$3"
  
  if [[ ! -e "$src" ]]; then
    warn "Not found: $src"
    return
  fi
  
  # Backup existing
  if [[ -e "$dest" ]] && [[ ! -L "$dest" ]]; then
    run mv "$dest" "$dest.backup"
  fi
  
  # Remove old symlink
  [[ -L "$dest" ]] && run rm "$dest"
  
  # Create symlink
  run ln -sf "$src" "$dest"
  success "$name"
}

log "Linking configs..."

# Alacritty
install "$DOTFILES/alacritty/alacritty.conf" "$HOME/.config/alacritty/alacritty.conf" "Alacritty"

# Git
install "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig" "Git"

# Tmux
install "$DOTFILES/tmux/.tmux.conf" "$HOME/.config/tmux/.tmux.conf" "Tmux"

# Neovim
install "$DOTFILES/nvim" "$HOME/.config/nvim" "Neovim"

# Zsh
install "$DOTFILES/zsh" "$HOME/.config/zsh" "Zsh config"

# Create .zshrc if it doesn't exist
if [[ ! -f "$HOME/.zshrc" ]]; then
  log "Creating .zshrc..."
  cat > "$HOME/.zshrc" <<'ZSHRC'
# Auto-start tmux (Alacritty only)
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    if [ "$TERM_PROGRAM" = "alacritty" ] || [ "$ALACRITTY_SOCKET" ]; then
        if ! tmux has-session -t main 2>/dev/null; then
            tmux new-session -d -s main
        fi
        exec tmux attach -t main
    fi
fi

# Load zsh config
ZSH_CONFIG="$HOME/.config/zsh"
[[ -f "$ZSH_CONFIG/env.zsh" ]] && source "$ZSH_CONFIG/env.zsh"
[[ -f "$ZSH_CONFIG/cache.zsh" ]] && source "$ZSH_CONFIG/cache.zsh"
[[ -f "$ZSH_CONFIG/aliases.zsh" ]] && source "$ZSH_CONFIG/aliases.zsh"
[[ -f "$ZSH_CONFIG/completion.zsh" ]] && source "$ZSH_CONFIG/completion.zsh"
[[ -f "$ZSH_CONFIG/history.zsh" ]] && source "$ZSH_CONFIG/history.zsh"
[[ -f "$ZSH_CONFIG/options.zsh" ]] && source "$ZSH_CONFIG/options.zsh"
[[ -f "$ZSH_CONFIG/keybinds.zsh" ]] && source "$ZSH_CONFIG/keybinds.zsh"
[[ -f "$ZSH_CONFIG/prompt.zsh" ]] && source "$ZSH_CONFIG/prompt.zsh"
ZSHRC
  success ".zshrc created"
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

# Neovim setup
if command -v nvim &>/dev/null && ! $DRY_RUN; then
  log "Installing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  success "Neovim plugins installed"
fi

echo ""
success "Done! "
echo ""
log "Next steps:"
echo "  1. Restart terminal: exec zsh"
echo "  2. Test Neovim: nvim"
echo "  3. Test Tmux: tmux"
echo ""
