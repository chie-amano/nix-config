{ pkgs, ... }: {
  home.username = "Chie";
  home.homeDirectory = "/Users/Chie";
  home.stateVersion = "26.11";

  home.packages = with pkgs; [
    pixi
    ghq
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

  # Start Open WebUI in background (http://localhost:8080)
  launchd.agents.open-webui = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.open-webui}/bin/open-webui" "serve" "--port" "8080" ];
      RunAtLoad = true;
      KeepAlive = true;
      EnvironmentVariables = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        WEBUI_AUTH = "False"; # No auth, Local use only.
      };
      StandardOutPath = "/tmp/open-webui.log";
      StandardErrorPath = "/tmp/open-webui.log";
    };
  };
}
