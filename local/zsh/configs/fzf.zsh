# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Auto-completion and key bindings
# -------------------------------
if [[ $- == *i* ]]; then
  [[ -r "$HOME/.fzf/shell/completion.zsh" ]] && source "$HOME/.fzf/shell/completion.zsh"
  [[ -r "$HOME/.fzf/shell/key-bindings.zsh" ]] && source "$HOME/.fzf/shell/key-bindings.zsh"
  [[ -r "$HOME/.fzf/shell/completion.zsh" || -r "$HOME/.fzf/shell/key-bindings.zsh" ]] && export DOTFILES_FZF_LOADED=1
fi
