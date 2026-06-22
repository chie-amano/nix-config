{ pkgs, ... }: {
  # Personal tools and preferences (not intended for sharing)
  # Add tmux, vim, shell aliases, etc. here
  programs.claude-code = {
    enable = true;
    # pkgs.claude-code comes from the llm-agents overlay added in flake.nix,
    # so it tracks the latest release instead of the nixpkgs-pinned version.
    package = pkgs.claude-code;
    settings = {
      theme = "dark";
      autoUpdates = false;
      includeCoAuthoredBy = false;
      autoCompactEnabled = false;
      enableAllProjectMcpServers = true;
      feedbackSurveyState.lastShownTime = 1754089004345;
      permissions = {
        deny = [
          "Bash(rm -rf /*)"
          "Bash(rm -rf /)"
          "Bash(sudo rm -:*)"
          "Bash(chmod 777 /*)"
          "Bash(chmod -R 777 /*)"
          "Bash(dd if=:*)"
          "Bash(mkfs.:*)"
          "Bash(fdisk -:*)"
          "Bash(format -:*)"
          "Bash(shutdown -:*)"
          "Bash(reboot -:*)"
          "Bash(halt -:*)"
          "Bash(poweroff -:*)"
          "Bash(killall -:*)"
          "Bash(pkill -:*)"
          "Bash(nc -l -:*)"
          "Bash(ncat -l -:*)"
          "Bash(netcat -l -:*)"
          "Bash(rm -rf ~:*)"
          "Bash(rm -rf $HOME:*)"
          "Bash(rm -rf ~/.ssh*)"
          "Bash(rm -rf ~/.config*)"
        ];
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      # File operations with eza
      l = "eza --long --classify --all --time-style=long-iso --group-directories-first";
      ll = "eza --long --classify --all --time-style=long-iso --group-directories-first";
      llt = "eza --long --classify --all --time-style=long-iso --group-directories-first --sort=changed";
      treee = "eza --tree --classify=auto";
      treel = "eza --tree --classify=auto --long";
      # gitstats = "fzf --preview 'git -C {} status -s && echo ----- && git -C {} lo -n 5 --oneline' --bind 'enter:execute(cd {} && $SHELL)+reload(ghq list -p)'";


      # Safe file operations
      rm = "rm -I";

      # Directory navigation
      ".." = "cd ..";
    };
    interactiveShellInit = ''
      # Add fish builtin completions to the completion path
      set -l builtin_completions $__fish_data_dir/completions
      if not contains $builtin_completions $fish_complete_path
        set -gx fish_complete_path $builtin_completions $fish_complete_path
      end

      # https://fishshell.com/docs/current/cmds/fish_git_prompt.html
      set -g __fish_git_prompt_char_stateseparator ' '
      set -g __fish_git_prompt_showdirtystate 1
      set -g __fish_git_prompt_showuntrackedfiles 1
      set -g __fish_git_prompt_showupstreamHEAD 1
      set -g __fish_git_prompt_show_informative_status 1
      set -g __fish_git_prompt_char_cleanstate '_'
      set -g __fish_git_prompt_char_dirtystate '*'
      set -g __fish_git_prompt_char_invalidstate '#'
      set -g __fish_git_prompt_char_stagedstate '+'
      set -g __fish_git_prompt_char_stashstate '$'
      set -g __fish_git_prompt_char_untrackedfiles '?'
      set -g fish_prompt_pwd_dir_length 3
      set -g fish_prompt_pwd_full_dirs 3
      source ${./fish_prompt.fish}
      function fish_title
        set -q argv[1]; or set argv fish
        echo $argv: (prompt_pwd);
      end
      function we
        if test -f /proc/version && string match -qi "*microsoft*" (cat /proc/version)
          /mnt/c/Windows/explorer.exe (wslpath -w "$PWD")
        else
          echo "Error: 'we' command is only available on WSL (Windows Subsystem for Linux)"
          return 1
        end
      end
    '';
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableFishIntegration = true;
    settings = {
      # ctrl + shift + , to reload ghostty settings.
      # https://ghostty.org/docs/config/reference
      adjust-cursor-thickness = 6;
      theme = "Ghostty Default Style Dark";
      # Absolute path so GUI launches (Spotlight/Launchpad) work too: the app
      # starts via `bash --noprofile --norc` without ~/.nix-profile/bin on PATH,
      # so a bare `fish` is not found. The store path keeps following rebuilds.
      command = "${pkgs.fish}/bin/fish";
    };
  };
  
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        { pager = "delta --dark --paging=never"; }
      ];
    };
  };


  programs.nixvim = {
    enable = true;
    version.enableNixpkgsReleaseCheck = false;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      # Keep current working directory when open new window or panes
      bind-key c new-window -c "#{pane_current_path}"
      bind-key % split-window -hc "#{pane_current_path}"
      bind-key '"' split-window -vc "#{pane_current_path}"

      #################
      # Neovim compatibility
      #################
      # Fix escape-time for Neovim
      set-option -sg escape-time 10

      # Enable focus-events for autoread
      set-option -g focus-events on

      # Set proper terminal for colors
      set-option -g default-terminal "screen-256color"

      # Enable true color support
      set-option -sa terminal-features ',xterm-256color:RGB'
      set-option -sa terminal-overrides ',xterm-256color:Tc'

      #################
      # Pains
      #################
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Use Alt-arrow keys without prefix key to switch panes
      bind-key -n M-Left select-pane -L
      bind-key -n M-Right select-pane -R
      bind-key -n M-Up select-pane -U
      bind-key -n M-Down select-pane -D

      # Change pane border colors
      set-option -g pane-border-style "bg=#333333,fg=#aaaaaa"
      set-option -g pane-active-border-style "bg=#aaaaaa,fg=#333333"

      # Keep showing window numbe when <prefix> q
      bind-key -T prefix e display-panes -d 0

      # keep pane title static
      set-option -g automatic-rename off
      set-option -g pane-border-format "#{pane_index}:#T"
      set-option -g status-interval 5
      set-option -g pane-border-status bottom

      # Disable layout change with <space>
      unbind-key Space

      #################
      # Status Bar
      #################
      # Set status bar position
      set-option -g renumber-windows on
      set-option -g status-bg "#333333"
      set-option -g status-fg "#aaaaaa"
      set-option -g status-justify centre
      set-option -g status-position top
      set-window-option -g window-status-current-style "bg=#aaaaaa,fg=#333333"

      #################
      # Others
      #################
      # Required for Kitty image protocol (image.nvim) to work through tmux
      set -g allow-passthrough on

      # start window/pane index from 1
      set -g base-index 1
      setw -g pane-base-index 1
      # send 'control + a' to applications
      bind-key C-a send-prefix
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
