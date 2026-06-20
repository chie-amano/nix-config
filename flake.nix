{
  description = "Chie's macOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nixvim, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # VS Code, etc.
      };
    in
    {

      # -----------------------------------------------------------------------
      # System layer — nix-darwin. Applied rarely and requires sudo.
      # Bootstraps Nix itself and basic system settings only (see darwin.nix).
      # home-manager is intentionally NOT wired in here: all user/app config
      # lives in the standalone home-manager output below so that day-to-day
      # changes never need sudo.
      #   sudo darwin-rebuild switch --flake .#Chies-MacBook-Pro
      # -----------------------------------------------------------------------
      darwinConfigurations."Chies-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [ ./modules/darwin.nix ];
      };

      # -----------------------------------------------------------------------
      # User layer — home-manager (standalone). Applied often, NO sudo.
      # Chie's apps and dotfiles. After editing any module, run:
      #   home-manager switch --flake .#Chie
      # -----------------------------------------------------------------------
      homeConfigurations."Chie" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nixvim.homeModules.nixvim
          ./modules/home.nix
        ];
      };

      # -----------------------------------------------------------------------
      # Template for colleagues who only need the local LLM environment.
      # Standalone home-manager — NO sudo required.
      # Steps:
      #   1. Replace "yourname" with: whoami
      #   2. Run: nix run home-manager/release-26.05 -- switch --flake .#yourname
      #      (subsequent updates: home-manager switch --flake .#yourname)
      # -----------------------------------------------------------------------
      # homeConfigurations."yourname" = home-manager.lib.homeManagerConfiguration {
      #   inherit pkgs;
      #   modules = [
      #     ./modules/home-llm.nix
      #     {
      #       home.username = "yourname";
      #       home.homeDirectory = "/Users/yourname";
      #       home.stateVersion = "26.05";
      #     }
      #   ];
      # };

    };
}
