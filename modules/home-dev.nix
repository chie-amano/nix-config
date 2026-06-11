{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghq
    pixi
  ];

  programs.git = {
    enable = true;
    settings = {
      commit = { verbose = "true"; };
      fetch = { prune = "true"; };
      ghq.root = "~/ghq";
      grep = { linenumber = "true"; };
      init = { defaultBranch = "main"; };
      log = { date = "iso-local"; };
      merge = { commit = "false"; };
      pull = { rebase = "true"; };
      rebase = { autoStash = "true"; };
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
