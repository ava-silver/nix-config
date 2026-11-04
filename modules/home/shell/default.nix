{
  config,
  lib,
  pkgs,
  host,
  ...
}:
{
  programs.zsh = {
    enable = true;

    # Work: ZDOTDIR moves the managed .zshrc aside so ~/.zshrc stays mutable for IT-managed blocks.
    dotDir = lib.mkIf host.work "${config.xdg.configHome}/zsh";

    autocd = true;

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
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

    envExtra = lib.mkIf host.work ''
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$HOME/.yarn/switch/bin:$PATH:$HOME/.local/bin"
      [[ ! -f $HOME/.cargo/env ]] || . "$HOME/.cargo/env"
    '';

    profileExtra = lib.mkIf host.work ''
      [[ ! -f $HOME/.zprofile ]] || source $HOME/.zprofile
      # dogbrew shell-hooks: if you don't want this to be called, comment it out and dogbrew will honour that on subsequent updates.  See also the more dangerous `dogbrew self setup --disable-shell-hooks`.
      [ -f "/opt/dogbrew/share/etc/dogbrew/init.zsh" ] && . "/opt/dogbrew/share/etc/dogbrew/init.zsh"
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      # Before compinit, since the IT block and dogbrew extend fpath. Both
      # dogbrew lines must match its output verbatim, or it rewrites the file.
      (lib.mkIf host.work (
        lib.mkOrder 510 ''
          [[ ! -f $HOME/.zshrc ]] || source $HOME/.zshrc
          # dogbrew shell-hooks: if you don't want this to be called, comment it out and dogbrew will honour that on subsequent updates.  See also the more dangerous `dogbrew self setup --disable-shell-hooks`.
          [ -f "/opt/dogbrew/share/etc/dogbrew/init.zsh" ] && . "/opt/dogbrew/share/etc/dogbrew/init.zsh"
        ''
      ))
      ''
        source ${./rc.zsh}
        source ${./p10k.zsh}

        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        source ${pkgs.fzf}/share/fzf/completion.zsh
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh

        zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'
      ''
      (lib.mkIf host.work ''
        source ${./work.zsh}
      '')
    ];
  };
}
