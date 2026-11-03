{ pkgs, isWork }:
with pkgs;
[
  git
  gh
  glab
  delta
  difftastic
  mergiraf
  nano

  just
  curl
  lsd
  zoxide
  fzf
  bat
  rm-improved
  ripgrep
  fd
  gum
  bottom
  gnused
  gnutar
  gzip
  xz
  zip
  unzip
  gawk
  findutils
  gnugrep
  diffutils
  patch
  file
  which
  less
  wget
  rsync
  tree
  gnumake
  nmap
  magic-wormhole
  gotestsum
  kingfisher

  moreutils
  jq
  fastfetch

  python315
  python3Packages.ipython
  uv
  ruff
  pipx
  ty
  pyrefly

  bun

  rust-analyzer
  jinja-lsp

  nixd
  nil
  nixfmt

  prek
]
++ pkgs.lib.optionals (!isWork) [ nodejs_26 ]
