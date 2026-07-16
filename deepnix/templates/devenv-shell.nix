# Template for per-project development environments
{ pkgs, ... }:

{
  # Development environment packages
  packages = with pkgs; [
    # Core tools (adjust as needed)
    git
    nodejs_22
    python3
    gcc
    cmake
    # Project-specific tools
    # ... add your project dependencies here
  ];

  # Environment variables
  env = {
    PROJECT_NAME = "my-project";
    PROJECT_VERSION = "0.1.0";
    # ... add project-specific variables
  };

  # Shell hooks
  shellHook = ''
    echo "Entering project: $PROJECT_NAME"
    echo "Version: $PROJECT_VERSION"
    # Run project setup
    if [ -f ./setup.sh ]; then
      ./setup.sh
    fi
  '';

  # Editor configuration
  editorConfig = {
    # ... add editor settings
  };
}
