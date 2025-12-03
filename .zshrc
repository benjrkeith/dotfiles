# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep nomatch
bindkey -v
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/ben/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# END of NVM

# Custom
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias clip='xclip -selection clipboard'
alias v='nvim'

export PATH="$PATH:$HOME/.bin"
export EDITOR='nvim'
export PROMPT="%{$(tput setaf 51)%}%n%{$(tput setaf 39)%}@%{$(tput setaf 39)%}%m %{$(tput sgr0)%}$ "

fastfetch
# End of Custom


