# Terminal Setup

Fedora terminal stack: Ghostty + Oh My Posh + Fastfetch + Zoxide.

Targets Fedora with GNOME. Requires `sudo` and `dnf`.

## Contents

| File | What | Deployed to |
|------|------|-------------|
| `install.sh` | One-shot installer — packages + configs + shell init | — |
| `ghostty.conf` | Ghostty — Kali-Dark theme, block cursor, split keybinds | `~/.config/ghostty/config.ghostty` |
| `oh-my-posh-overdrive.json` | Oh My Posh prompt — OS icon, path, git status, sysinfo | `~/.config/oh-my-posh/overdrive.omp.json` |
| `fastfetch.jsonc` | Fastfetch — boxed system info layout | `~/.config/fastfetch/config.jsonc` |

## Usage

```sh
./install.sh
```

Restart your terminal or `source ~/.bashrc`.

The script is idempotent — safe to re-run. It checks for each package before
installing and guards every `~/.bashrc` edit with a `grep -Fxq` check.

## What the installer does

1. Installs `fastfetch`, `ghostty` (copr `scottames/ghostty`), `oh-my-posh`,
   and `zoxide`.
2. Removes the default `ptyxis` terminal and sets Ghostty as the GNOME default.
3. Adds a "Open in Terminal" Nautilus entry via
   `nautilus-open-any-terminal` (copr `monkeygold/nautilus-open-any-terminal`).
4. Copies the three config files into `~/.config/` (see table above).
5. Appends Oh My Posh and Zoxide init blocks to `~/.bashrc`.

Configs are **copied, not symlinked** — intentional, so edits to the deployed
files stay live even if this repo moves. Re-running `install.sh` overwrites
them. There is no uninstall step; the `~/.bashrc` edits are append-only.

## Theme

The Ghostty palette is **Kali-Dark**, taken verbatim from Kali's official
`kali-themes` package (`etc/xdg/alacritty/alacritty.toml`, `colorScheme=Kali-Dark`).

| Slot | Color | | Slot | Color |
|------|-------|-|------|-------|
| 0 black | `#1f2229` | | 8 bright black | `#198388` |
| 1 red | `#d41919` | | 9 bright red | `#ec0101` |
| 2 green | `#5ebdab` | | 10 bright green | `#47d4b9` |
| 3 yellow | `#fea44c` | | 11 bright yellow | `#ff8a18` |
| 4 blue | `#367bf0` | | 12 bright blue | `#277fff` |
| 5 magenta | `#9755b3` | | 13 bright magenta | `#962ac3` |
| 6 cyan | `#49aee6` | | 14 bright cyan | `#05a1f7` |
| 7 white | `#e6e6e6` | | 15 bright white | `#ffffff` |

Background `#23252e`, foreground `#ffffff`.

Note: Kali also ships an `etc-purple` variant, but that one is *light*
(`background = 0xFFFFFF`, `colorScheme=Kali-Light`). This repo uses the
standard dark variant from `etc/xdg`.

## Requirements

- Fedora (uses `dnf`, `rpm`, and `copr`)
- GNOME (`gsettings` keys for the default terminal and Nautilus)
- A [Nerd Font](https://www.nerdfonts.com/) for the prompt and Fastfetch
  glyphs (Fira Code recommended — Kali's own choice)

## License

AGPL-3.0
