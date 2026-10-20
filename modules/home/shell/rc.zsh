#!/usr/bin/env zsh

# PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"
export PATH="$PATH:$HOME/.local/bin"
[[ ! -d $HOME/.cargo/bin ]] || path+=($HOME/.cargo/bin)

# Environment
export LANG="en_US.UTF-8"
export EDITOR="zed --wait"
export DO_NOT_TRACK=true
export GH_TELEMETRY=false
export HOST_HOOK_RUNNER=1
export GPG_TTY=$(tty)
export _ZO_EXCLUDE_DIRS="$HOME/go/src/github.com/DataDog"
export FFF_ENABLE_HOME_SCAN=0

[[ ! -f $HOME/.cargo_vars ]] || source $HOME/.cargo_vars

if [[ $OSTYPE == darwin* ]]; then
  alias xclip=pbcopy
  alias pinentry=pinentry-mac
  export HOMEBREW_NO_ENV_HINTS=1
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
  alias brewi="brew update && brew install"
  alias brewr="brew uninstall"
  alias brewu='brew update && brew upgrade --greedy -y'
  alias disablesleep='sudo pmset -a disablesleep 1'
  alias enablesleep='sudo pmset -a disablesleep 0'
  export OPENROUTER_API_KEY=$(security find-generic-password -a ${USER} -s OPENROUTER_API_KEY -w 2>/dev/null)

  write_token() {
    printf "Enter env var name (e.g. FOOBAR_TOKEN): " &&
      read TOKEN_NAME &&
      printf "Enter API token value: " &&
      read TOKEN &&
      security add-generic-password -U -a ${USER} -s ${TOKEN_NAME} -w ${TOKEN} &&
      unset TOKEN &&
      unset TOKEN_NAME
  }
fi

if [[ $OSTYPE == linux* ]]; then
  alias open=xdg-open
  alias xclip=wl-copy
fi

# General
alias cp='cp -riv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias less='less -FSRXc'
# git defaults LESS to FRX when unset; -X skips the alternate screen, so the
# mouse wheel can't scroll delta/less. Setting it (without X) restores that.
export LESS=-FR
alias wget='wget -c'
alias cat=bat
alias ccat='\cat'
alias top=btm
alias c=clear
alias cd=z
alias src='exec zsh'
alias g=git
alias path='echo -e ${PATH//:/\\n}'
alias fix_term='echo -e "\033c"'
alias qfind='find . -iname'
alias zip='zip -r'
alias rm=rip
alias rrm='/bin/rm -rf'
alias time='=time'
alias lower='tr "[:upper:]" "[:lower:]"'
alias upper='tr "[:lower:]" "[:upper:]"'
alias uuid='uuidgen | lower | tee /dev/tty | xclip'
alias gotest=gotestsum
alias code=zed
alias pis='pi --model openai-codex/gpt-5.6-sol --thinking medium'
alias llm='llama serve -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M'
alias _=sudo
# LS
alias ls=lsd
alias l=ls
alias ll='ls -lAh'

# URL
alias urldecode="python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))'"
alias urlencode="python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1].strip(), safe=\"\"))'"

# Kubernetes
alias k=kubectl
alias kgp='kubectl get pod'
alias kbash='kbash --pod'
alias ktx=kubectx-switcher
alias kns=kubens
alias hd=hotdog

# Terraform
alias tf=terraform
alias tfa='terraform apply -auto-approve'
alias tfd='terraform destroy -auto-approve'
alias tfr='terraform destroy -auto-approve && terraform apply -auto-approve'

# Bazel
alias gz='bzl run //:gazelle -- domains/cloud_platform/ && g ac gazelle && gt ss'

# Bun
alias bunup='(cd ~/.bun/install/global && bun update)'
alias bunupdate=bunup

python() {
  if [[ $# == 0 ]]; then ipython; else python3 "$@"; fi
}

install-hooks() {
  command -v prek &>/dev/null || brew install prek
  local hooks_path
  hooks_path=$(git config --global core.hooksPath)
  [[ -n "$hooks_path" ]] && git config --global --unset core.hooksPath
  prek install
  [[ -n "$hooks_path" ]] && git config --global core.hooksPath "$hooks_path"
}

awsopen() {
  open -a "Google Chrome" "https://console.aws.amazon.com/go/view?arn=$1"
}

# Resolves a leading alias in the given words into the `expanded_cmd` array,
# so wrapper functions accept aliases as arguments the way a shell would.
expand-alias() {
  typeset -ga expanded_cmd=("$@")
  local -i depth=0
  while (( $+aliases[$expanded_cmd[1]] && depth++ < 16 )); do
    expanded_cmd=("${(@Q)${(z)aliases[$expanded_cmd[1]]}}" "${expanded_cmd[@]:1}")
  done
}

aws-sso() {
  expand-alias "$@"
  aws-vault exec sso-serverless-sandbox-account-admin -- "${expanded_cmd[@]}"
}
alias aws='aws-sso /opt/homebrew/bin/aws'

loop() {
  local interval=1
  if [[ $1 == -n ]]; then
    interval=$2
    shift 2
  fi
  expand-alias "$@"
  local -a cmd=("${expanded_cmd[@]}")
  while true; do
    "${cmd[@]}"
    sleep "$interval"
  done
}

dd-auth-session() {
  eval "$(dd-auth --output --domain "$@" | sed 's/^/export /')"
}

piredact() {
  if [[ $# != 1 ]]; then
    printf 'Usage: piredact <seeker-slack-message-url>\n' >&2
    return 2
  fi
  pi --no-session --model dd-ai-gateway/baseten/deepseek-ai/DeepSeek-V4-Flash-0731 \
    "Read the Seeker alert at $1. Collect every reported local file path that exists, then run exactly one command to redact and verify them: redact-secrets -- <absolute-path>... Do not read or print secret values yourself."
}

[[ ! -f $HOME/.zsh_aliases.local ]] || source $HOME/.zsh_aliases.local
