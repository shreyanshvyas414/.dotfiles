# vague.yazi

A Yazi flavor for this machine's Vague terminal theme, tuned for low eye strain.

## Design

Hues come from the Vague palette (kitty + the fish prompt). Saturation and
lightness are retargeted to match [kanagawa-paper](https://github.com/melindachang/kanagawa-paper.yazi),
which keeps accents desaturated and mid-luminance rather than bright.

|                        | kanagawa-paper | this flavor |
| ---------------------- | -------------- | ----------- |
| mean accent saturation | 20.0%          | 21.5%       |
| mean contrast vs bg    | 5.54:1         | 5.67:1      |
| max accent contrast    | 7.85:1         | 7.87:1      |

For comparison, the first cut of this flavor used the raw terminal colors and
landed at 61.9% mean saturation and 8.74:1 mean contrast, peaking at 12.85:1 -
harsh enough to be tiring.

## Palette

| role       | color     | notes                                  |
| ---------- | --------- | -------------------------------------- |
| background | `#18191a` | kitty `background`                     |
| surface    | `#232425` | tab inactive, mode alt                 |
| surface+   | `#2b2d31` | progress bar ground                    |
| border     | `#5c5f66` | borders, permission separators         |
| dim text   | `#99968f` | absent/stale entries - stays legible   |
| text       | `#cdcdcd` | kitty `foreground`, 11.07:1            |
| gold       | `#c0ab82` | signature accent (was `#ffd787`)       |
| gold dim   | `#9e8c57` |                                        |
| green      | `#6a956a` |                                        |
| teal       | `#809d9d` |                                        |
| aqua       | `#87a19c` | **was `#94e2d5` at 57% sat, 11.82:1**  |
| blue       | `#658695` |                                        |
| red        | `#b86f7f` |                                        |
| magenta    | `#938aa8` |                                        |

Derived from `catppuccin-mocha.yazi` by colour substitution, so key coverage
tracks that flavor. See `LICENSE-tmtheme` and `NOTICE`.
