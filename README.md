#### My debian dev essentials

* urxvt
* xmonad
* xmobar
* dmenu
* stalonetray
* vim
* git
* tmux
* tig

#### Setup

Clone the repo:

```bash
git clone git@github.com:michailpanagiotis/apparatus.git ~/.apparatus
```

Link the respective rcs and dirs to your home by running the `setup` script:

```bash
cd ~/.apparatus && ./setup
```

#### tmux

Set the tmux plugin manager:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After opening tmux install the plugins referenced in `.tmux.config` with:

```
Ctrl-a I
```
