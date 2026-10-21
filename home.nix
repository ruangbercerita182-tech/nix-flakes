{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # Jangan ubah setelah konfigurasi pertama dibuat.
  # environment {
  # "XDG_DATA_DIRS" "/home/sam/.nix-profile/share:/usr/local/share:/usr/share"
  # }
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Fonts
    font-awesome
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Core CLI
    git
    gh
    curl
    wget
    jq
    ripgrep
    fd
    fzf
    bat
    eza
    tree
    htop
    tmux
    which
    bc

    # Shell productivity
    zoxide
    starship

    # The devenv CLI comes from the nix profile instead of home-manager: the
    # CLI has to match the devenv modules that a project pins, and nixpkgs
    # unstable carries the matching release.

    # Nix
    nixfmt
    nil

    #
    kind
    gnumake
    gcc

    buf
    protobuf

    nodejs
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.git;

    settings = {
      user = {
        name = "ruangbercerita182-tech";
        email = "ruangbercerita182@gmail.com";
      };

      init.defaultBranch = "main";
      core.editor = "helix";
      pull.rebase = false;
      push.autoSetupRemote = true;
      fetch.prune = true;

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        lg = "log --oneline --graph --decorate";
        last = "log -1 HEAD --stat";
      };
    };
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
    ];
  };

  programs.gh = {
    enable = true;

    gitCredentialHelper.enable = true;

    settings = {
      git_protocol = "ssh";
      editor = "helix";
      prompt = "enabled";

      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
        rv = "repo view";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        HashKnownHosts = true;
        IdentityFile = "/home/sam/.ssh/id_ed25519";
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentitiesOnly = true;
        IdentityFile = "/home/sam/.ssh/id_ed25519";
      };
    };
  };

  programs.librewolf.enable = true;
  programs.google-chrome.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -lah";
      ls = "eza -l";
      cat = "bat";
      helix = "hx";
    };
    initExtra = lib.mkBefore ''
      . "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
      eval "$(devenv hook bash)"
      export PATH="/home/sam/.bun/bin:$PATH"
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
  };

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "helix";
    VISUAL = "helix";
    PAGER = "less";
    LESS = "-FRX";
  };
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
  ];
  targets.genericLinux.enable = true;

  programs.helix = {
    enable = true;

    settings = {
      theme = "tokyonight";

      editor = {
        line-number = "relative";
        mouse = true;
        cursorline = true;
        color-modes = true;
        bufferline = "multiple";

        indent-guides = {
          render = true;
          character = "│";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker.hidden = false;

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
          ];
          center = [
            "file-type"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
          ];
        };
      };
    };

    languages = {
      language-server = {
        nil = {
          command = lib.getExe pkgs.nil;
        };

        gopls = {
          command = lib.getExe pkgs.gopls;
          config = {
            gofumpt = true;
            staticcheck = true;
          };
        };

        typescript-language-server = {
          command = lib.getExe pkgs.typescript-language-server;
          args = [ "--stdio" ];
        };
      };

      language = [
        {
          name = "nix";
          language-servers = [ "nil" ];
          formatter.command = lib.getExe pkgs.nixfmt;
          auto-format = true;
        }

        {
          name = "go";
          language-servers = [ "gopls" ];
          formatter = {
            command = "${pkgs.gotools}/bin/goimports";
            args = [ ];
          };
          auto-format = true;
          debugger = {
            name = "go";
            transport = "tcp";
            command = lib.getExe pkgs.delve;
            args = [ "dap" ];
            port-arg = "-l 127.0.0.1:{}";

            templates = [
              {
                name = "debug";
                request = "launch";
                completion = [
                  {
                    name = "entrypoint";
                    completion = "filename";
                    default = ".";
                  }
                ];
                args = {
                  mode = "debug";
                  program = "{0}";
                };
              }
              {
                name = "test";
                request = "launch";
                completion = [
                  {
                    name = "package";
                    completion = "directory";
                    default = ".";
                  }
                ];
                args = {
                  mode = "test";
                  program = "{0}";
                };
              }
            ];
          };
        }

        {
          name = "typescript";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = "${pkgs.prettier}/bin/prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
        }

        {
          name = "tsx";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = lib.getExe pkgs.prettier;
            args = [
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
        }

        {
          name = "javascript";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = lib.getExe pkgs.prettier;
            args = [
              "--parser"
              "babel"
            ];
          };
          auto-format = true;
        }

        {
          name = "jsx";
          language-servers = [ "typescript-language-server" ];
          formatter = {
            command = lib.getExe pkgs.prettier;
            args = [
              "--parser"
              "babel"
            ];
          };
          auto-format = true;
        }
      ];
    };
  };
}
