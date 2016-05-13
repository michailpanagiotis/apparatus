install:
	git submodule init
	git submodule update

ubx: ubx.bash ubx.git vim screen gpsdate
	$(info ubx done!)

osx: osx.bash osx.git vim tmux gpsdate
	$(info osx done!)

osx.bash:
	$(info *** bash ***)
	test -e $(HOME)/.apparatus/bash/bash_prompt      && ln -fs $(HOME)/.apparatus/bash/bash_prompt      $(HOME)/.bash_prompt
	test -e $(HOME)/.apparatus/bash/osx/bash_aliases && ln -fs $(HOME)/.apparatus/bash/osx/bash_aliases $(HOME)/.bash_aliases
	test -e $(HOME)/.apparatus/bash/osx/bash_extras  && ln -fs $(HOME)/.apparatus/bash/osx/bash_extras  $(HOME)/.bash_extras
	test -e $(HOME)/.apparatus/bash/bash_profile     && ln -fs $(HOME)/.apparatus/bash/bash_profile     $(HOME)/.bash_profile

osx.git:
	$(info *** git ***)
	test -e $(HOME)/.apparatus/git/gitconfig         && ln -fs $(HOME)/.apparatus/git/gitconfig         $(HOME)/.gitconfig
	test -e $(HOME)/.apparatus/git/osx/git.author    && ln -fs $(HOME)/.apparatus/git/osx/git.author    $(HOME)/.git.author

ubx.bash:
	$(info *** bash ***)
	test -e $(HOME)/.apparatus/bash/bash_prompt      && ln -fs $(HOME)/.apparatus/bash/bash_prompt      $(HOME)/.bash_prompt
	test -e $(HOME)/.apparatus/bash/ubx/bash_aliases && ln -fs $(HOME)/.apparatus/bash/ubx/bash_aliases $(HOME)/.bash_aliases
	test -e $(HOME)/.apparatus/bash/ubx/bash_extras  && ln -fs $(HOME)/.apparatus/bash/ubx/bash_extras  $(HOME)/.bash_extras
	test -e $(HOME)/.apparatus/bash/bash_profile     && ln -fs $(HOME)/.apparatus/bash/bash_profile     $(HOME)/.bashrc

ubx.git:
	$(info *** git ***)
	test -e $(HOME)/.apparatus/git/gitconfig         && ln -fs $(HOME)/.apparatus/git/gitconfig         $(HOME)/.gitconfig
	test -e $(HOME)/.apparatus/git/ubx/git.author    && ln -fs $(HOME)/.apparatus/git/ubx/git.author    $(HOME)/.git.author

vim:
	$(info *** vim ***)
	test -e $(HOME)/.apparatus/vim/vimrc             && ln -fs $(HOME)/.apparatus/vim/vimrc             $(HOME)/.vimrc

tmux:
	$(info *** tmux ***)
	test -e $(HOME)/.apparatus/tmux/tmux.conf        && ln -fs $(HOME)/.apparatus/tmux/tmux.conf        $(HOME)/.tmux.conf

screen:
	$(info *** screen ***)
	test -e $(HOME)/.apparatus/screen/screenrc       && ln -fs $(HOME)/.apparatus/screen/screenrc       $(HOME)/.screenrc

gpsdate:
	#$(info *** gpsdate ***)
	# TODO

.PHONY: osx.bash osx.git ubx.bash ubx.git vim tmux screen gpsdate
