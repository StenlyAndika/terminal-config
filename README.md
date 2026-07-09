# Terminal Setup

Fedora terminal stack: Ghostty + Oh My Posh + Fastfetch + Zoxide.

## Contents

| File | What |
|------|------|
| `install.sh` | One-shot: installs everything and drops configs in place |
| `config.ghostty` | Ghostty config — dark theme, block cursor, split keybinds |
| `overdrive.omp.json` | Oh My Posh prompt — OS icon, path, git status, sysinfo |
| `config.jsonc` | Fastfetch config — boxed system info layout |

## Usage

```sh
./install.sh
```

Restart your terminal or `source ~/.bashrc`.

## License

AGPL-3.0
