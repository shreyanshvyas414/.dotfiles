# .dotfiles

> My minimal dotfiles, organized with clarity.  
> (pushed in a moment of confidence)

Kinda don’t know why I pushed all of this stuff… whatever.

So yeah — here are all my config files before I break or do changes again.

---

## Stack

Keyboard Remapper    => Kanata  
Window Manager       => Aerospace  
Terminal Emulator    => Ghostty (Kitty as backup)  
Code Editor          => Neovim (vimpack)  
Menubar (?)          => Sketchybar (replacement of the thing Apple calls a menubar)  
Multiplexer          => Tmux  
Shell                => ZSH (Fish configured too)  
File Manager         => Yazi  

---

## Philosophy

- Make it fast  
- Make it minimal  
- Break it often  
- Fix it later  
- Automate it eventually  
- Forget how it works after 2 weeks  

---

## tmux as a launcher

Prefix is `M-Space`. Beyond panes and windows, these open pickers from `scripts/`:

| Key        | Does                                                          |
| ---------- | ------------------------------------------------------------- |
| `prefix f` | pick a project, create-or-switch to its tmux session           |
| `prefix S` | find and run any script in the current project                 |
| `prefix O` | open a bookmark from `links.tsv` (`ctrl-y` copy, `ctrl-e` edit)|
| `prefix g` | open this repo's `origin` remote in the browser                |
| `prefix G` | lazygit, reusing the window if it's already open               |
| `prefix y` | yazi, reusing the window if it's already open                  |

All pickers share one fzf theme via `scripts/fzf-themes.sh`, so they look alike.
Project roots for `prefix f` are the two arrays at the top of
`scripts/tmux-session-dispensary.sh`.

---

## Install

```sh
git clone git@github.com:shrey99sh/.dotfiles.git
cd .dotfiles
./setup.sh --dry-run   # see what it would link
./setup.sh             # actually link it
```

`setup.sh` symlinks into `~/.config`, backing up anything real it finds as
`*.backup.<timestamp>`.

---

Some custom configuration sprinkled on top for aesthetic performance.
