{ pkgs, ... }: {
  # Base requirement for home-manager to manage itself
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    colima  # Container runtimes on macOS
    docker  # Container
    ollama  # Local LLM server
  ];

  # Start Colima (Docker runtime) at login
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

  # Start Ollama LLM server at login
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
