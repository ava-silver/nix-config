{ lib, pkgs, ... }@args:
let
  isWork = args.isWork or false;
in
{
  # Work: .zshrc stays mutable for IT-managed blocks. ~/.zshenv is sourced
  # automatically by zsh for every invocation and is not touched by IT tools.
  # The interactive guard keeps aliases and keychain lookups out of scripts.
  home.file.".zshenv" = lib.mkIf isWork {
    text = ''
      [[ -o interactive ]] || return
      source ${./rc.zsh}
    '';
  };

  programs.zsh = lib.mkIf (!isWork) {
    enable = true;

    history = {
      size = 100000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      share = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autoswitch-virtualenv";
        src = pkgs.fetchFromGitHub {
          owner = "MichaelAquilina";
          repo = "zsh-autoswitch-virtualenv";
          rev = "3.9.0";
          hash = "sha256-j2YX+OcYbvS2G/KUNzcWbJepm9bZlegp1r8ZjcY6Nnw=";
        };
        file = "autoswitch_virtualenv.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        source ${./rc.zsh}
        source ${./p10k.zsh}

        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        source ${pkgs.fzf}/share/fzf/completion.zsh
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh

        zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'
      ''
    ];
  };
}
