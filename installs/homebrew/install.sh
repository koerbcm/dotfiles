#!/bin/sh

. $HOME/.dotfiles/installs/utils/lib.sh

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

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

info "updating homebrew"
brew update
success "updated homebrew"

info "installing n(node version manager)"
brew "n"
/bin/bash -c "$(n lts)"
success "installed n(node version manager)"

info "installing rcm for dotfiles operations"
brew 'rcm'
success "installed rcm"

info "installing homebrew bundler"
brew tap homebrew/bundle
success "installed homebrew bundler"
info "installing Brewfile packages. This might take a while..."
brew bundle --file $HOME/.dotfiles/installs/homebrew/Brewfile
info "uninstalling brew node version since we will use node version manager"
brew uninstall node --ignore-dependencies
success "installed homebrew bundler and Brewfile formulae"
info "REMINDER: Set npm global install directory to ~/.npm-global \n    npm config set prefix '~/.npm-global'\n"
info "To auto-update brew please run: brew autoupdate --start --upgrade --cleanup --enable-notification"

success "finished homebrew setup"
