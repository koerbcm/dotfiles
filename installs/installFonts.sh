#!/bin/sh

. $HOME/.dotfiles/installs/utils/lib.sh

info "installing fonts to font book"

cp $HOME/.dotfiles/fonts/* $HOME/Library/Fonts

success "finished installing fonts"
