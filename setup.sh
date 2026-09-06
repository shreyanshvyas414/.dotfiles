#!/usr/bin/env bash

set -euo pipefail

# Repo root, derived from this script's location - works wherever the repo is
# cloned. (The old hardcoded ~/Documents/stuff/dots path had gone stale.)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
log "Installing dotfiles from $DOTFILES"
echo ""

# Tools (macOS)
if $INSTALL_TOOLS && [[ "$OSTYPE" == "darwin"* ]]; then
  log "Installing tools via Homebrew..."

  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  formulae=(tmux neovim fzf ripgrep fd git node bob eza bat btop yazi zoxide kanata fish lazygit)
  for f in "${formulae[@]}"; do
    command -v "$f" &>/dev/null || run brew install "$f" || warn "Failed: $f"
  done

  casks=(ghostty kitty)
  for c in "${casks[@]}"; do
    run brew install --cask "$c" || warn "Failed: $c"
  done

  # Maple Mono NF - the font both ghostty and kitty reference.
  run brew install --cask font-maple-mono-nf || \
    warn "font-maple-mono-nf unavailable; install Maple Mono NF manually"

  success "Tools installed"
  echo ""
fi

# Symlink helper
install() {
  local src="$1" dest="$2" name="$3"

  if [[ ! -e "$src" ]]; then
    warn "Not found, skipping: $src"
    return
  fi

  run mkdir -p "$(dirname "$dest")"

  # Back up a real file/dir; replace a symlink outright
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    run mv "$dest" "$dest.backup.$(date +%s)"
  fi
  [[ -L "$dest" ]] && run rm "$dest"

  run ln -sfn "$src" "$dest"
  success "$name"
}

log "Linking configs..."

install "$DOTFILES/.zshrc"                 "$HOME/.zshrc"                          "Zsh"
install "$DOTFILES/git/.gitconfig"         "$HOME/.gitconfig"                      "Git"
install "$DOTFILES/ghostty/config"         "$HOME/.config/ghostty/config"          "Ghostty"
install "$DOTFILES/kitty/kitty.conf"       "$HOME/.config/kitty/kitty.conf"        "Kitty"
install "$DOTFILES/tmux/tmux.conf"         "$HOME/.config/tmux/tmux.conf"          "Tmux"
install "$DOTFILES/fish"                   "$HOME/.config/fish"                    "Fish"
install "$DOTFILES/nvim"                   "$HOME/.config/nvim"                    "Neovim"
install "$DOTFILES/yazi"                   "$HOME/.config/yazi"                    "Yazi"
install "$DOTFILES/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml" "AeroSpace"
install "$DOTFILES/kanata/kanata.kbd"      "$HOME/.config/kanata/kanata.kbd"       "Kanata"
install "$DOTFILES/btop/btop.conf"         "$HOME/.config/btop/btop.conf"          "btop"
# SketchyBar is retired: aerospace.toml no longer triggers it and
# ~/.config/sketchybar is gone. Files kept in-repo; un-comment to revive.
# install "$DOTFILES/sketchybar"           "$HOME/.config/sketchybar"              "SketchyBar"

# tmux launcher pickers. tmux.conf calls these by absolute path
# (~/.config/scripts/...), so the directory has to land there.
install "$DOTFILES/scripts"                "$HOME/.config/scripts"                 "Scripts (tmux pickers)"
install "$DOTFILES/ripgrep/rgrc"           "$HOME/.config/ripgrep/rgrc"            "ripgrep"
install "$DOTFILES/links.tsv"              "$HOME/.config/links.tsv"               "Links"

# Ghostty cursor shaders (third-party, not vendored into this repo).
# Cloned inside the repo and linked out, so the relative `shaders/` path in
# ghostty/config resolves from either the repo or ~/.config/ghostty.
if [[ ! -d "$DOTFILES/ghostty/shaders" ]]; then
  log "Cloning ghostty cursor shaders..."
  run git clone --depth 1 https://github.com/sahaj-b/ghostty-cursor-shaders \
    "$DOTFILES/ghostty/shaders" || warn "shader clone failed; custom-shader will be inert"
fi
install "$DOTFILES/ghostty/shaders" "$HOME/.config/ghostty/shaders" "Ghostty shaders"

# Scripts (repo dir is lowercase)
if [[ -d "$DOTFILES/scripts" ]]; then
  log "Installing scripts..."
  run mkdir -p "$HOME/Scripts"
  for script in "$DOTFILES/scripts"/*; do
    [[ -f "$script" ]] || continue
    dest="$HOME/Scripts/$(basename "$script")"
    run ln -sf "$script" "$dest"
    run chmod +x "$dest"
  done
  success "Scripts"
fi

# Neovim plugins - this config uses the built-in vim.pack, not lazy.nvim
if command -v nvim &>/dev/null && ! $DRY_RUN; then
  log "Syncing Neovim plugins (vim.pack)..."
  nvim --headless "+lua vim.pack.update()" +qa || warn "vim.pack sync failed"
  success "Neovim plugins synced"
fi

# Yazi flavors declared in yazi/package.toml (vague.yazi is tracked in-repo)
if command -v ya &>/dev/null && ! $DRY_RUN; then
  log "Installing yazi packages..."
  ya pkg install || warn "ya pkg install failed"
fi

echo ""
success "Done!"
echo ""
log "Next steps:"
echo "  1. Restart terminal: exec zsh"
echo "  2. Grant Ghostty Accessibility permission for the cmd+\` quick terminal"
echo "  3. Kanata needs a cmd_allowed build for its (cmd ...) aliases"
echo ""
