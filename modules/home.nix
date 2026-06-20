{ ... }: {
  imports = [
    ./home-llm.nix
    ./home-dev.nix
    ./home-personal.nix
  ];

  home.username = "Chie";
  home.homeDirectory = "/Users/Chie";
  home.stateVersion = "26.05";

  # Put the Nix profiles on PATH via hm-session-vars (sourced by every shell,
  # including login shells). Without this, GUI-launched apps (Ghostty from
  # Spotlight/Launchpad) start a shell that lacks ~/.nix-profile/bin, so
  # Nix-installed CLIs like lazygit are "not found". Terminal-launched shells
  # only worked because they inherited PATH from a parent that had it set up.
  home.sessionPath = [
    "/Users/Chie/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];

  # Chie's git identity
  programs.git.settings.user = {
    name = "Chie Amano";
    email = "93822689+chie-amano@users.noreply.github.com";
  };
}
