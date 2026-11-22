{ config, ... }:
{
  # Out-of-store so settings changed in Zed write back to the repo.
  xdg.configFile = {
    "zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/zed/settings.json";
    "zed/keymap.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.thisRepoDir}/modules/home/zed/keymap.json";
  };
}
