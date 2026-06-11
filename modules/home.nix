{ pkgs, ... }: {
  home.username = "Chie";
  home.homeDirectory = "/Users/Chie";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    colima
    docker
    ghq
    ollama
    pixi
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Chie Amano";
        email = "achse603@gmail.com";
      };
      ghq.root = "~/ghq";
    };
  };

  programs.vscode.enable = true;

  programs.zsh = {
    enable = true;
    initContent = ''
      eval "$(pixi completion --shell zsh)"
    '';
  };

  # Colima（Docker ランタイム）をバックグラウンドで自動起動
  launchd.agents.colima = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.colima}/bin/colima" "start" "--foreground" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/colima.log";
      StandardErrorPath = "/tmp/colima.log";
    };
  };

  # Start Ollama in background
  launchd.agents.ollama = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/ollama.log";
      StandardErrorPath = "/tmp/ollama.log";
    };
  };

}
