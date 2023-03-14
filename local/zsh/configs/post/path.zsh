#!/usr/bin/sh
# PATHS
# ===========================================================================
# ** Doesn't allow rvm or nvm to load. Commenting it out **

# if [ -x /usr/libexec/path_helper ]; then
#   # Mac OS X uses path_helper and /etc/paths.d to preload PATH, clear it out first
#   PATH=''
#   eval `/usr/libexec/path_helper -s`
# fi

PATH="$PATH:/usr/local/bin:/usr/local/lib/node_modules"
# PATH="$PATH:/usr/local/opt/gnu-sed/libexec/gnubin" # make sure gnu-sed works as sed
# PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# PATH="/usr/local/opt/gettext/bin:$PATH"
PATH="$HOME/.dotfiles/bin:$HOME/.bin:$HOME/bin:$PATH"
PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# PATH="/usr/local/opt/rock-runtime-ruby22/bin:$PATH" # Shutterstock - Putting it first so ruby defaults to it and not ruby in /usr/local/bin

# export YVM_DIR=/usr/local/opt/yvm
# [ -r $YVM_DIR/yvm.sh ] && . $YVM_DIR/yvm.sh

export PATH="$(yarn global bin):$PATH"

PATH=$HOME/.npm-global/bin:$PATH

if brew ls --versions jenv > /dev/null; then
  # PATH="$HOME/.jenv/shims:$PATH" # doesn't appear in docs anymore
  PATH="$HOME/.jenv/bin:$PATH"
  eval "$(jenv init -)"

  # jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-12.jdk/Contents/Home/
  # jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/
fi


export -U PATH
