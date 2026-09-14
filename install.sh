#!/usr/bin/env bash
set -e

# When sourced (rather than executed) this script runs inside the user's shell.
# In that case `set -e` and `exit` would affect THEIR shell — `exit` would close
# the terminal outright and `set -e` would linger and kill later commands. So
# detect sourcing up front and turn those behaviours off.
_SOURCED=0
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    _SOURCED=1
    set +e
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#--------------------------------------------------
# --apply: emit the shell snippet and nothing else
#--------------------------------------------------
# Handled before any install work, so `eval "$(./install.sh --apply)"` is fast
# and free of sudo prompts or stray output. Must come first for that reason.
if [[ "${1:-}" == "--apply" ]]; then
    cat <<'APPLY'
__term_setup_apply() {
    source "$HOME/.bashrc"
    echo "[ok] Oh My Posh + Zoxide loaded into this shell."
}
__term_setup_apply
unset -f __term_setup_apply
APPLY
    exit 0
fi

echo "================================================="
echo "Terminal Setup (Fastfetch, Ghostty, Oh my posh, Zoxide)"
echo "================================================="

#--------------------------------------------------
# Install Fastfetch
#--------------------------------------------------
if ! command -v fastfetch >/dev/null 2>&1; then
    echo "Fastfetch not found. Installing..."

    sudo dnf install -y fastfetch
else
    echo "Fastfetch already installed."
fi

#--------------------------------------------------
# Install Ghostty
#--------------------------------------------------
if ! command -v ghostty >/dev/null 2>&1; then
    echo "Ghostty not found. Installing..."

    sudo dnf -y copr enable scottames/ghostty
    sudo dnf -y install ghostty
else
    echo "Ghostty already installed."
fi

#--------------------------------------------------
# Remove default terminal (ptyxis)
#--------------------------------------------------
if rpm -q ptyxis >/dev/null 2>&1; then
    echo "Removing default ptyxis terminal..."
    sudo dnf remove -y ptyxis
else
    echo "ptyxis not installed, skipping removal."
fi

#--------------------------------------------------
# Set Ghostty as the default terminal
#--------------------------------------------------
echo "Setting Ghostty as default terminal..."
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'

#--------------------------------------------------
# Add Ghostty to Nautilus context menu
#--------------------------------------------------
if ! command -v nautilus-open-any-terminal >/dev/null 2>&1; then
    echo "Installing nautilus-open-any-terminal..."
    sudo dnf -y copr enable monkeygold/nautilus-open-any-terminal
    sudo dnf -y install nautilus-open-any-terminal
    nautilus -q
else
    echo "nautilus-open-any-terminal already installed."
fi

gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal ghostty

#--------------------------------------------------
# Install Oh My Posh
#--------------------------------------------------
if ! command -v oh-my-posh >/dev/null 2>&1; then
    echo "Oh My Posh not found. Installing..."

    curl -s https://ohmyposh.dev/install.sh | sudo bash -s
else
    echo "Oh My Posh already installed."
fi

#--------------------------------------------------
# Install Zoxide
#--------------------------------------------------
if ! command -v zoxide >/dev/null 2>&1; then
    echo "Zoxide not found. Installing..."
    sudo dnf install -y zoxide
else
    echo "Zoxide already installed."
fi

#--------------------------------------------------
# Install configuration files
#--------------------------------------------------
echo "Installing configuration..."

mkdir -p "$HOME/.config/fastfetch"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/oh-my-posh"

install -m 644 "$SCRIPT_DIR/fastfetch.jsonc" \
    "$HOME/.config/fastfetch/config.jsonc"

install -m 644 "$SCRIPT_DIR/ghostty.conf" \
    "$HOME/.config/ghostty/config.ghostty"

install -m 644 "$SCRIPT_DIR/oh-my-posh-overdrive.json" \
    "$HOME/.config/oh-my-posh/overdrive.omp.json"

#--------------------------------------------------
# Configure Bash
#--------------------------------------------------
INIT_CMD='eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/overdrive.omp.json)"'

if ! grep -Fxq "$INIT_CMD" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Oh My Posh" >> "$HOME/.bashrc"
    echo "$INIT_CMD" >> "$HOME/.bashrc"
    echo "Added Oh My Posh initialization to ~/.bashrc"
else
    echo "Oh My Posh already configured in ~/.bashrc"
fi

# Zoxide
ZOX_ALIAS='alias cd="z"'
ZOX_INIT='eval "$(zoxide init bash)"'
if ! grep -Fxq "$ZOX_INIT" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Zoxide" >> "$HOME/.bashrc"
    echo "$ZOX_ALIAS" >> "$HOME/.bashrc"
    echo "$ZOX_INIT" >> "$HOME/.bashrc"
    echo "Added Zoxide initialization to ~/.bashrc"
else
    echo "Zoxide already configured in ~/.bashrc"
fi

echo
echo "Installation complete!"
echo

#--------------------------------------------------
# Apply to the current shell
#--------------------------------------------------
# A child process cannot modify its parent shell's environment, so a script
# can never fix the *caller's* prompt on its own. Two supported ways to apply:
#
#   1. source install.sh   -> runs here, in your shell, then reloads .bashrc
#   2. eval "$(./install.sh --apply)"  -> emits code your shell then evals
#
# `--apply` prints the snippet instead of running it, which keeps normal
# execution (and piping into a file) free of surprises.

echo
echo "Installation complete!"
echo

# If this script was *sourced*, we're running inside the user's shell and can
# reload .bashrc in place for an immediate effect. `return` (not `exit`) is
# correct here — `exit` would close the user's terminal.
if [[ "$_SOURCED" == 1 ]]; then
    echo "Sourced — applying to this shell now."
    # shellcheck disable=SC1090,SC1091
    source "$HOME/.bashrc"
    echo "[ok] Oh My Posh + Zoxide loaded into this shell."
    return 0
fi

echo "To apply to this shell without opening a new terminal, run:"
echo
echo "    source ./install.sh"
echo
echo "Or restart your terminal, or run: source ~/.bashrc"
