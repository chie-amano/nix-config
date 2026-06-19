{
  description = "Chie's macOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.11-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nixvim, ... }: {

    # Chie's full setup
    darwinConfigurations."Chies-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./modules/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
          home-manager.users.Chie = import ./modules/home.nix;
          users.users.Chie = {
            home = "/Users/Chie";
          };
        }
      ];
    };

    # -------------------------------------------------------------------------
    # Template for colleagues who only need the local LLM environment.
    # Steps:
    #   1. Replace "your-macbook" with: scutil --get LocalHostName
    #   2. Replace "yourname" with: whoami
    #   3. Run: sudo nix run nix-darwin -- switch --flake .#your-macbook
    # -------------------------------------------------------------------------
    # darwinConfigurations."your-macbook" = nix-darwin.lib.darwinSystem {
    #   system = "aarch64-darwin";
    #   modules = [
    #     ./modules/darwin.nix
    #     home-manager.darwinModules.home-manager
    #     {
    #       home-manager.useGlobalPkgs = true;
    #       home-manager.useUserPackages = true;
    #       home-manager.users.yourname = {
    #         imports = [ ./modules/home-llm.nix ];
    #         home.username = "yourname";
    #         home.homeDirectory = "/Users/yourname";
    #         home.stateVersion = "26.11";
    #       };
    #       users.users.yourname = {
    #         home = "/Users/yourname";
    #       };
    #     }
    #   ];
    # };

  };
}
