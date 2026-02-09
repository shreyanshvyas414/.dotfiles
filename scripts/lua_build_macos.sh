#!/bin/bash
set -euo pipefail

# Lua Build Script with Manifest
# Installs Lua, LuaRocks, and LuaJIT
# Tracks installed files for clean removal

SCRIPT_VERSION="1.1.0"

# --- Versions & Paths
LUA_VERSION="5.5.0"
LUA_SHA256="57ccc32bbbd005cab75bcc52444052535af691789dba2b9016d5c50640d68b3d"
LUAROCKS_VERSION="3.13.0"

INSTALL_NAME="lua-${LUA_VERSION}"
LUA_DIR="$HOME/lua"
MANIFEST_DIR="$HOME/.local/share/package-manifests"
MANIFEST_FILE="$MANIFEST_DIR/$INSTALL_NAME.manifest"
BUILD_DIR=$(mktemp -d /tmp/lua-build.XXXXXXXXXX)

# --- Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Helpers
mkdir -p "$MANIFEST_DIR"

add_to_manifest() { echo "$1" >> "$MANIFEST_FILE"; }

is_installed() { [ -f "$MANIFEST_FILE" ]; }

INSTALL_OK=1  # default safe; install_lua resets to 0 before build starts
cleanup_on_error() {
    if [[ "$INSTALL_OK" -eq 0 ]]; then
        log_error "Build failed — cleaning up $BUILD_DIR"
        rm -rf "$BUILD_DIR"
    fi
}

# --- Uninstall
uninstall() {
    if ! is_installed; then
        log_error "$INSTALL_NAME is not installed (no manifest found)"
        exit 1
    fi

    log_info "Uninstalling $INSTALL_NAME..."

    # Remove tracked files in reverse order (awk works everywhere, no tac/tail -r needed)
    awk 'NR>0 && !/^#/{a[NR]=$0} END{for(i=NR;i>=1;i--) if(a[i]) print a[i]}' "$MANIFEST_FILE" \
    | while read -r file; do
        [ -e "$file" ] && { log_info "  removing $file"; rm -rf "$file"; }
    done

    # Strip the source line from shell RC files
    for rc in ~/.bashrc ~/.zshrc; do
        [ -f "$rc" ] || continue
        grep -q "source.*lua/.profile" "$rc" 2>/dev/null || continue
        # -i '' is macOS sed; works on Linux too when the suffix is empty
        sed -i '' "/source.*lua\/.profile/d" "$rc" && log_info "  cleaned $(basename "$rc")"
    done

    rm -f "$MANIFEST_FILE"
    log_info "Uninstall complete."
    exit 0
}

# --- Install
install_lua() {
    # Arm the error trap for this path only
    INSTALL_OK=0
    trap cleanup_on_error EXIT

    # Guard: already installed?
    if is_installed; then
        log_warn "$INSTALL_NAME is already installed at $LUA_DIR"
        read -rp "Reinstall? [y/N] " -n 1; echo
        [[ $REPLY =~ ^[Yy]$ ]] && uninstall || { log_info "Cancelled."; exit 0; }
    fi

    # Guard: need Xcode CLI tools
    if ! xcode-select -p &>/dev/null; then
        log_warn "Xcode command-line tools not found. Installing…"
        xcode-select --install
        log_warn "Re-run this script after the installation finishes."
        exit 0
    fi

    # --- Init manifest
    { echo "# Manifest for $INSTALL_NAME"
      echo "# Created: $(date)"
    } > "$MANIFEST_FILE"

    mkdir -p "$LUA_DIR"
    add_to_manifest "$LUA_DIR"

    # --- Lua
    cd "$BUILD_DIR"

    log_info "Downloading Lua ${LUA_VERSION}…"
    wget -q "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"

    log_info "Verifying checksum…"
    shasum -a 256 "lua-${LUA_VERSION}.tar.gz" | grep -q "$LUA_SHA256" \
        || { log_error "SHA-256 mismatch — aborting."; exit 1; }

    tar xzf "lua-${LUA_VERSION}.tar.gz"
    cd "lua-${LUA_VERSION}"

    sed -i '' "s#/usr/local#${LUA_DIR}#g" Makefile

    log_info "Building Lua…"
    make macosx
    make test
    make install

    for p in bin/lua bin/luac include lib share man; do
        add_to_manifest "$LUA_DIR/$p"
    done

    # --- Profile
    cat > "$LUA_DIR/.profile" << EOF
# Lua ${LUA_VERSION} environment
export PATH=${LUA_DIR}/bin:\${PATH:-}
export LUA_CPATH=${LUA_DIR}/lib/lua/5.5/?.so
export LUA_PATH=${LUA_DIR}/share/lua/5.5/?.lua
export MANPATH=${LUA_DIR}/share/man:\${MANPATH:-}
EOF
    add_to_manifest "$LUA_DIR/.profile"

    for rc in ~/.bashrc ~/.zshrc; do
        [ -f "$rc" ] || continue
        grep -q "source ${LUA_DIR}/.profile" "$rc" 2>/dev/null && continue
        echo "source ${LUA_DIR}/.profile" >> "$rc"
        log_info "  added source line to $(basename "$rc")"
    done

    # Bring env into the current shell for the rest of this script
    # shellcheck source=/dev/null
    source "$LUA_DIR/.profile"

    # --- LuaRocks
    cd "$BUILD_DIR"

    log_info "Downloading LuaRocks ${LUAROCKS_VERSION}…"
    wget -q "https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz"
    tar xzf "luarocks-${LUAROCKS_VERSION}.tar.gz"
    cd "luarocks-${LUAROCKS_VERSION}"

    log_info "Building LuaRocks…"
    ./configure --prefix="$LUA_DIR" \
                --with-lua="$LUA_DIR" \
                --lua-suffix=5.5 \
                --with-lua-include="$LUA_DIR/include"
    make build
    make install

    add_to_manifest "$LUA_DIR/bin/luarocks"
    add_to_manifest "$LUA_DIR/bin/luarocks-admin"
    add_to_manifest "$LUA_DIR/etc/luarocks"

    # --- LuaJIT
    cd "$BUILD_DIR"

    log_info "Cloning LuaJIT…"
    git clone https://luajit.org/git/luajit.git
    cd luajit

    MACOS_VERSION=$(sw_vers -productVersion)
    MACOSX_DEPLOYMENT_TARGET="${MACOS_VERSION%.*}"
    export MACOSX_DEPLOYMENT_TARGET

    log_info "Building LuaJIT…"
    make
    make install PREFIX="$LUA_DIR"

    add_to_manifest "$LUA_DIR/bin/luajit"

    # --- luasec
    OPENSSL_PATH=""
    for candidate in /opt/homebrew/opt/openssl@3 /opt/homebrew/opt/openssl \
                     /usr/local/opt/openssl@3  /usr/local/opt/openssl; do
        [ -d "$candidate" ] && { OPENSSL_PATH="$candidate"; break; }
    done

    if [ -n "$OPENSSL_PATH" ]; then
        log_info "Installing luasec (OpenSSL at ${OPENSSL_PATH})…"
        luarocks --local install luasec \
            OPENSSL_INCDIR="$OPENSSL_PATH/include" \
            OPENSSL_LIBDIR="$OPENSSL_PATH/lib" \
            || log_warn "luasec install failed (non-critical)"
    else
        log_warn "OpenSSL not found — skipping luasec. Install via: brew install openssl@3"
    fi

    # --- Summary
    log_info ""
    log_info ""
    log_info "  Installation complete "
    log_info ""
    lua -v
    luarocks --version
    luajit -v
    log_info ""
    log_info "  Dir:      $LUA_DIR"
    log_info "  Manifest: $MANIFEST_FILE"
    log_info "  Usage:    source $LUA_DIR/.profile   (or restart terminal)"
    log_info ""
    log_info "  $0 --status     check install"
    log_info "  $0 --uninstall  remove everything"
    log_info ""

    # Mark success — EXIT trap will not clean up after this point
    INSTALL_OK=1

    read -rp "Remove build files? [y/N] " -n 1; echo
    [[ $REPLY =~ ^[Yy]$ ]] && { rm -rf "$BUILD_DIR"; log_info "Build files removed."; } \
                            || log_info "Build files left at $BUILD_DIR"
}

# --- Status
check_status() {
    if ! is_installed; then log_warn "$INSTALL_NAME is not installed"; exit 0; fi

    log_info "$INSTALL_NAME is installed"
    grep "^#" "$MANIFEST_FILE"
    echo "  Tracked paths: $(grep -cv '^#' "$MANIFEST_FILE")"
    echo ""
    [ -x "$LUA_DIR/bin/lua"       ] && "$LUA_DIR/bin/lua"       -v
    [ -x "$LUA_DIR/bin/luarocks"  ] && "$LUA_DIR/bin/luarocks"  --version
    [ -x "$LUA_DIR/bin/luajit"    ] && "$LUA_DIR/bin/luajit"    -v
}

# --- Entry point
case "${1:-}" in
    --install|"")  install_lua    ;;
    --uninstall)   uninstall      ;;
    --update)      uninstall; install_lua ;;
    --status)      check_status   ;;
    --help)
        cat << EOF
Lua Build Script v$SCRIPT_VERSION

Usage:  $0 [--install | --uninstall | --update | --status | --help]

  --install     Install Lua ${LUA_VERSION}, LuaRocks ${LUAROCKS_VERSION}, LuaJIT  (default)
  --uninstall   Remove everything tracked by the manifest
  --update      Uninstall then reinstall
  --status      Print version info and manifest summary
  --help        Show this message

Paths:
  Install dir   $LUA_DIR
  Manifest      $MANIFEST_FILE
EOF
        ;;
    *)  log_error "Unknown option: $1"; "$0" --help; exit 1 ;;
esac
