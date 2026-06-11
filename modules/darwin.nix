{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Flakes and nix-commandを有効化
  nix.settings.experimental-features = "nix-command flakes";

  # allow unfree packages（VS Code, etc.）
  nixpkgs.config.allowUnfree = true;

  # macOSのユーザー情報をnix-darwinに教える（ユーザー管理はmacOSに任せる）
  users.users.Chie = {
    home = "/Users/Chie";
  };

  system.stateVersion = 5;
}
