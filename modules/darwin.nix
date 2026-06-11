{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Flakes and nix-commandを有効化
  nix.settings.experimental-features = "nix-command flakes";

  # allow unfree packages（VS Code, etc.）
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 5;
}
