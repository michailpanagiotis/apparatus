# My macos dev essentials

The simple `setup` script below needs the following software. Almost all of the latter are available as brew packages.

* [chunkwm](https://github.com/koekeishiya/chunkwm)
* [shkd](https://github.com/koekeishiya/skhd)
* [kitty](https://github.com/kovidgoyal/kitty)
* [git](https://git-scm.com/)
* [vim](https://github.com/vim/vim)
* [tmux](https://github.com/tmux/tmux)
* [tig](https://github.com/jonas/tig)
* [fzf](https://github.com/junegunn/fzf)
* [ripgrep](https://github.com/BurntSushi/ripgrep)

## Setup

Add all brew related file with the help of [brew.txt](https://github.com/michailpanagiotis/apparatus/blob/macos/mike/brew.txt):

```bash
<~/.apparatus/brew.txt xargs brew install
```

Clone the repo:

```bash
git clone git@github.com:michailpanagiotis/apparatus.git ~/.apparatus
```

Link the respective rcs and dirs to your home by running the `setup` script:

```bash
cd ~/.apparatus && ./setup
```

## tmux

Set the tmux plugin manager:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After opening tmux install the plugins referenced in `.tmux.config` with:

```
Ctrl-a I
```
