HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep nomatch
bindkey -v

zstyle :compinstall filename '/home/ben/.zshrc'
autoload -Uz compinit
compinit

alias ls='ls -l --color=auto'
alias grep='grep --color=auto'
alias v='nvim'

export PATH="$PATH:$HOME/.bin:/home/ben/.dotnet/tools"
export EDITOR='nvim'

source /usr/share/nvm/init-nvm.sh

eval "$(starship init zsh)"

fastfetch