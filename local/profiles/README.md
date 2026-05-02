Profile overlays are optional and loaded automatically when present.

Active selectors:
- `DOTFILES_CONTEXT` (`work` or `personal`)
- `DOTFILES_PLATFORM` (`mac`, `wsl`, `linux`, `windows`, etc.)

Load order:
1. `local/profiles/<context>.env.zsh`
2. `local/profiles/<platform>.env.zsh`
3. `~/.env.<context>.local`
4. `~/.env.<platform>.local`

Then aliases:
1. `local/profiles/<context>.aliases.zsh`
2. `local/profiles/<platform>.aliases.zsh`
3. `~/.aliases.<context>.local`
4. `~/.aliases.<platform>.local`

Then functions:
1. `local/profiles/<context>.functions.zsh`
2. `local/profiles/<platform>.functions.zsh`
3. `~/.functions.<context>.local`
4. `~/.functions.<platform>.local`

Set context per machine in `~/.dotfiles-context.local`, for example:

```zsh
export DOTFILES_CONTEXT=work
```

Legacy bundles are opt-in:
- `DOTFILES_ENABLE_LEGACY_ALIASES=1`
- `DOTFILES_ENABLE_LEGACY_FUNCTIONS=1`

Kubernetes/Helm OMZ plugins are also opt-in:
- `DOTFILES_ENABLE_OMZ_K8S_PLUGINS=1`

AWS OMZ plugin is opt-in:
- `DOTFILES_ENABLE_OMZ_AWS_PLUGIN=1`

Default policy in this repo:
- `work + mac` => `DOTFILES_ENABLE_OMZ_K8S_PLUGINS=1`
- all other contexts/platforms => `DOTFILES_ENABLE_OMZ_K8S_PLUGINS=0`
