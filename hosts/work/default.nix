{ ... }:
{
  # Formula-level trust doesn't cover tap siblings, which Homebrew still loads (e.g. on upgrade).
  homebrew.taps =
    map
      (name: {
        inherit name;
        trusted = true;
      })
      [
        "withgraphite/tap"
        "atlassian/acli"
        "azure/functions"
      ];

  homebrew.brews = [
    "withgraphite/tap/graphite"
    "direnv"
    "awscli"
    "aws-vault"
    "tfenv"
    "kubectx"
    "atlassian/acli/acli"
    "azure/functions/azure-functions-core-tools@4"
  ];
  homebrew.casks = [
    "gcloud-cli"
    "azure-cli"
  ];
  system.stateVersion = 5;
}
