{ pkgs, ... }: {
  home.packages = with pkgs; [
    ghq
    pixi
  ];

  programs.git = {
    enable = true;
    settings = {
      alias = {
        aliases = "config --get-regexp '^alias\\.'";
        bl = "blame --abbrev=6";
        lo = "log --graph --all --date=format:'%Y-%m-%d %H:%M' --format='%C(white dim) %h %Creset %s %C(cyan dim)(%ad)%Creset%C(green) <%an>%C(bold yellow)%d%Creset'";
        loo = "log --stat --graph --decorate --all";
        pushf = "push --force-with-lease --force-if-includes";
        root = "rev-parse --show-toplevel";
        sh = "show --color-words='[^[:space:]]'";
        st = "status --short --branch";
        wt = "!f() { if [ -z \"$1\" ]; then echo \"Create a new branch as a worktree.\nUsage:\n  $ git wt <new-branch-name>\"; return 1; fi; ROOT=\"$(git rev-parse --show-toplevel)\"; WORKTREE_PATH=\"$(dirname \"$ROOT\")/$(basename \"$ROOT\")=$1\"; git worktree add --quiet \"$WORKTREE_PATH\" -b \"$1\" && echo \"$WORKTREE_PATH\"; }; f";
      };
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
