{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghq
    pixi
  ];

  programs.git = {
    enable = true;
    settings = {
      ghq.root = "~/ghq";
      # Add user.name and user.email in home.nix or your own configuration
    };
  };

  programs.vscode.enable = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      eval "$(pixi completion --shell zsh)"
    '';
  };
}
