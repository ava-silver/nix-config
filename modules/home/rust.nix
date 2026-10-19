{ pkgs, ... }:
{
  bootstrap.packages = [ pkgs.rustup ];
  bootstrap.steps = [
    ''
      if [[ -z "$(ls -A "$HOME/.rustup/toolchains" 2>/dev/null)" ]]; then
        rustup default stable && rustup component add rust-src || failed=1
      fi
    ''
  ];
}
