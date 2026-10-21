#!/usr/bin/env zsh

# The IT block's `brew shellenv` runs path_helper, which moves Homebrew ahead of Nix and Volta.
typeset -U path
path=($HOME/.nix-profile/bin $VOLTA_HOME/bin /run/current-system/sw/bin $path)
path+=($HOME/dd/eclair-scripts/bin $HOME/dd/eclair-scripts/azure/bin)

export AWS_PROFILE=sso-serverless-sandbox-account-admin
export GITLAB_HOST=gitlab.ddbuild.io
export GITLAB_TOKEN=$(security find-generic-password -a ${USER} -s GITLAB_TOKEN -w 2>/dev/null)
export NODE_OPTIONS="--max-old-space-size=30000"
export TF_CLI_ARGS_apply="-backup=-"
export TF_CLI_ARGS_destroy="-backup=-"
export BATS_LIB_PATH=$HOME/.local/lib/bats
export PYENCHANT_LIBRARY_PATH=/opt/homebrew/lib/libenchant-2.2.dylib

if (( $+commands[kubectl] )); then
  _load_kubectl_completion() {
    unfunction _load_kubectl_completion
    source <(command kubectl completion zsh)
    _kubectl "$@"
  }
  compdef _load_kubectl_completion kubectl
fi

if (( $+commands[gt] )); then
  _load_gt_completion() {
    unfunction _load_gt_completion
    source <(command gt completion)
    _gt_yargs_completions "$@"
  }
  compdef _load_gt_completion gt
fi

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Jamf only sources this from ~/.zprofile, so non-login shells would otherwise miss the Privileges sudo alias.
[[ ! -f $HOME/.privilegesalias ]] || source $HOME/.privilegesalias
