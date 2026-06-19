{ pkgs, ... }: {
  # Personal tools and preferences (not intended for sharing)
  # Add tmux, vim, shell aliases, etc. here
  home.packages = with pkgs; [
    tmux
  ];

  programs.nixvim = {
    enable = true;
    version.enableNixpkgsReleaseCheck = false;
  };
}
