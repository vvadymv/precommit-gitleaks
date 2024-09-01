#!/bin/bash

# Check if the pre-commit hook is enabled via git config
ENABLED=$(git config --bool hooks.gitleaks.enabled)

if [ "$ENABLED" != "true" ]; then
  echo "Pre-commit hook for gitleaks is disabled. Enable it with: git config hooks.gitleaks.enabled true"
  exit 0
fi

# Define installation directory in user's home
INSTALL_DIR="$HOME/bin"
GITLEAKS_PATH="$INSTALL_DIR/gitleaks"

# Function to install gitleaks
install_gitleaks() {
  echo "Installing gitleaks..."

  # Create the installation directory if it doesn't exist
  mkdir -p "$INSTALL_DIR"

  # Detect OS and download the appropriate binary
  case "$(uname -s)" in
    Linux)
      curl -sSfL https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-linux-amd64 -o "$GITLEAKS_PATH"
      ;;
    Darwin)
      curl -sSfL https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-darwin-amd64 -o "$GITLEAKS_PATH"
      ;;
    *)
      echo "Unsupported OS. Please install gitleaks manually."
      exit 1
      ;;
  esac

  # Check if gitleaks binary exists and make it executable
  if [ -f "$GITLEAKS_PATH" ]; then
    chmod +x "$GITLEAKS_PATH"
    echo "gitleaks installed successfully in $INSTALL_DIR."
  else
    echo "Failed to download gitleaks. Please install it manually."
    exit 1
  fi
}

# Ensure the install directory is in the user's PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "Adding $INSTALL_DIR to PATH."
  export PATH="$INSTALL_DIR:$PATH"
  # Optionally add to ~/.bashrc or ~/.zshrc to persist in future sessions
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc depending on your shell
fi

# Check if gitleaks is already installed
if ! command -v gitleaks &> /dev/null; then
  install_gitleaks
fi

# Run gitleaks
echo "Running gitleaks..."
gitleaks detect --verbose --redact

# Check the exit status of gitleaks
if [ $? -ne 0 ]; then
  echo "gitleaks detected sensitive information. Commit aborted."
  exit 1
fi

echo "No leaks detected. Proceeding with commit."
exit 0
