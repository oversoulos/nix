{ config, lib, pkgs, ... }:

{
  # Building mode - DevOps/Development
  environment.etc."nixos/modes/building.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Mode-specific packages
      home.packages = with pkgs; [
        vscode
        git
        git-lfs
        nodejs_22
        python3
        python3Packages.pip
        python3Packages.virtualenv
        gcc
        cmake
        gnumake
        docker
        docker-compose
        podman
        podman-compose
        ghostty
        nemo
        obsidian
        kubectl
        kubernetes-helm
        terraform
        ansible
        awscli2
        azure-cli
      ];
      
      # Mode-specific environment
      home.sessionVariables = {
        MODE_NAME = "building";
        MODE_COLOR = "#10B981"; # Green
        OBSIDIAN_VAULT = "$HOME/modes/building/vault";
        PROJECT_DIR = "$HOME/projects";
        DOCKER_HOST = "unix:///run/docker.sock";
        KUBECONFIG = "$HOME/.kube/config";
      };
      
      # Waybar config for this mode
      xdg.configFile."waybar/config".source = ./modes/building/waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./modes/building/waybar-style.css;
      
      # Mode-specific aliases
      home.shellAliases = {
        build = "cd ~/projects";
        dev = "cd ~/projects && nvim";
        test = "cd ~/projects && cargo test || pytest || npm test";
        deploy = "cd ~/projects && ./deploy.sh";
        k = "kubectl";
        kctx = "kubectl config use-context";
        kns = "kubectl config set-context --current --namespace";
        dc = "docker-compose";
        dc-up = "docker-compose up -d";
        dc-down = "docker-compose down";
        dc-logs = "docker-compose logs -f";
        pc = "podman-compose";
        terra = "terraform";
      };
      
      # Sway keybindings for this mode
      xdg.configFile."sway/config.d/building.conf".text = ''
        # Development keys
        bindsym F5 exec ~/projects/build.sh
        bindsym F6 exec ~/projects/test.sh
        bindsym F7 exec ~/projects/deploy.sh
        bindsym $mod+v exec vscode
        bindsym $mod+g exec ghostty
        bindsym $mod+n exec nemo
        bindsym $mod+c exec obsidian
        bindsym $mod+d exec ${pkgs.wofi}/bin/wofi --dmenu --prompt "Project:" --cache-file /dev/null < ~/projects/list.sh
      '';
    }
  '';

  # Ensure building mode directory exists with character cards
  systemd.services.building-mode-setup = {
    description = "Setup building mode workspace";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/modes/building/vault
          mkdir -p /home/user/modes/building/characters
          mkdir -p /home/user/projects
          cat > /home/user/modes/building/.envrc << EOF
        export MODE_ACTIVE=building
        export OBSIDIAN_VAULT=\$HOME/modes/building/vault
        export PROJECT_DIR=\$HOME/projects
        export PATH=\$PATH:\$HOME/modes/building/bin
        EOF
          cat > /home/user/modes/building/characters/README.md << EOF
        # Building Mode Characters
        ## Character Cards
        Each character represents a different development role for project contexts.
        ### DevOps Engineer
        - Focus: Infrastructure, CI/CD, Kubernetes, Terraform
        - Tools: kubectl, terraform, ansible, docker
        - Tasks: Deployment pipelines, monitoring, scaling
        ### Backend Developer
        - Focus: APIs, databases, microservices
        - Tools: Python, Node, Go, SQL, NoSQL
        - Tasks: Business logic, performance optimization
        ### Frontend Developer
        - Focus: UI/UX, React, Vue, Angular
        - Tools: JavaScript, TypeScript, CSS, HTML
        - Tasks: User interfaces, responsive design
        ### Database Administrator
        - Focus: Data models, migration, query optimization
        - Tools: PostgreSQL, MongoDB, Redis, SQL
        - Tasks: Schema design, performance tuning
        ### QA Specialist
        - Focus: Testing, automation, bug reports
        - Tools: Jest, Cypress, Selenium, Postman
        - Tasks: Test coverage, regression testing
        EOF
          cat > /home/user/modes/building/README.md << EOF
        # Building Mode
        ## Purpose
        Full-stack development, containers, project work.
        ## Hotkeys
        - \`F5\`: Build project
        - \`F6\`: Test project
        - \`F7\`: Deploy project
        - \`$mod+v\`: VSCode
        - \`$mod+g\`: Ghostty terminal
        - \`$mod+n\`: Nemo file manager
        - \`$mod+c\`: Obsidian
        - \`$mod+d\`: Select project
        ## Character Cards
        See \`characters/\` for role-based development personas.
        EOF
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
