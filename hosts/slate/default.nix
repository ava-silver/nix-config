{ ... }:
{
  networking.hostName = "slate";
  system.stateVersion = 5;

  homebrew = {
    brews = [
      "llama.cpp"
    ];
    casks = [
      "bitwarden"
    ];
  };
}
