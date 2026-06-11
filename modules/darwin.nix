{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Flakes and nix-command
  nix.settings.experimental-features = "nix-command flakes";

  # allow unfree packages（VS Code, etc.）
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Tell user info to nix-darwin
  users.users.Chie = {
    home = "/Users/Chie";
  };

  system.stateVersion = 5;
}
