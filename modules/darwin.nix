{ pkgs, ... }: {
  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable Flakes and nix-command
  nix.settings.experimental-features = "nix-command flakes";

  # allow unfree packages（VS Code, etc.）
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # fix broken dlinfo dependencies of open-webuidlinfo
  # test of dlinfo requires libdl.dylib which is not available on macOS.
  # This can be removed if upstream is fixed: https://github.com/NixOS/nixpkgs/issues
  nixpkgs.overlays = [
    (final: prev: {
      python313 = prev.python313.override {
        packageOverrides = _: pyPrev: {
          dlinfo = pyPrev.dlinfo.overridePythonAttrs (_: {
            doCheck = false;
            meta = pyPrev.dlinfo.meta // { broken = false; };
          });
        };
      };
    })
  ];

  # Tell user info to nix-darwin
  users.users.Chie = {
    home = "/Users/Chie";
  };

  system.stateVersion = 5;
}
