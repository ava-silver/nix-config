{ ... }:
{
  imports = [ ../../modules/darwin ];

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
    "azure-cli"
    "azure/functions/azure-functions-core-tools@4"
  ];
  homebrew.casks = [ "gcloud-cli" ];
  system.primaryUser = "ava.silver";
  system.stateVersion = 5;
  users.users."ava.silver".home = "/Users/ava.silver";
  home-manager = {
    useGlobalPkgs = true;
    users."ava.silver".imports = [ ../../modules/home ];
  };
}
