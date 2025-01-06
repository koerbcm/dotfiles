#!/bin/sh

. $HOME/.dotfiles/installs/utils/lib.sh

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# doesn't set right
# Used with n node version manager
export N_PREFIX="$HOME/.n"
export PREFIX="$HOME/.n"

info "checking for existing homebrew install"
if test ! $(which brew)
then
  info "existing install not found, installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  success "installed homebrew"
fi
# fixme doesn't put brew into path so everything breaks
info "updating homebrew"
brew update
success "updated homebrew"

info "unalias mac git installation"
unalias git
info "list git aliases for verification:"
alias | grep "git="
success "alias removed"

info "install brew git"
brew install git
info "list git location for verification:"
which git
success " git installed from brew"

env | grep PREFIX
# info "installing n(node version manager)"
# brew install "n"
# # this doesn't work
# /bin/bash -c "$(n lts)"
# success "installed n(node version manager)"

info "installing rcm for dotfiles operations"
brew install 'rcm'
success "installed rcm"

info "installing homebrew bundler"
brew tap homebrew/bundle
success "installed homebrew bundler"
info "installing Brewfile packages. This might take a while..."
brew bundle --file $HOME/.dotfiles/installs/homebrew/Brewfile
info "uninstalling brew node version since we will use node version manager"
brew uninstall node --ignore-dependencies
success "installed homebrew bundler and Brewfile formulae"
info "Java Versions/Locations:"
/usr/libexec/java_home -V
info "REMINDER: Install java versions to jenv: \n    e.g. 'jenv add /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home'\n"
info "REMINDER: Set npm global install directory to ~/.npm-global \n    npm config set prefix '~/.npm-global'\n"
info "REMINDER: Run rcup for dotfiles: \n    env RCRC=$HOME/.dotfiles/rcrc rcup\n"
info "To auto-update brew please run: brew autoupdate --start --upgrade --cleanup --enable-notification"

success "finished homebrew setup"
