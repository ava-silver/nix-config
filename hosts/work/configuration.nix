{ ... }:
{
  imports = [ ../../modules/darwin ];

  homebrew.brews = [
    "withgraphite/tap/graphite"
    "direnv"
    "awscli"
    "aws-vault"
    "terraform"
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
