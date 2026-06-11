{ ... }: {
  imports = [
    ./home-llm.nix
    ./home-dev.nix
    ./home-personal.nix
  ];

  home.username = "Chie";
  home.homeDirectory = "/Users/Chie";
  home.stateVersion = "26.05";

  # Chie's git identity
  programs.git.settings.user = {
    name = "Chie Amano";
    email = "achse603@gmail.com";
  };
}
