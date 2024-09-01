#!/bin/bash

# Check if the pre-commit hook is enabled via git config
ENABLED=$(git config --bool hooks.gitleaks.enabled)

if [ "$ENABLED" != "true" ]; then
  echo "Pre-commit hook for gitleaks is disabled. Enable it with: git config hooks.gitleaks.enabled true"
  exit 0
fi

# Gitleaks version
GITLEAKS_VER="8.18.4"

# Define installation directory in user's home
INSTALL_DIR="$HOME/bin"
GITLEAKS_PATH="$INSTALL_DIR/gitleaks"

# Function to install gitleaks
install_gitleaks() {
  echo "Installing gitleaks..."

  # Create the installation directory if it doesn't exist
  mkdir -p "$INSTALL_DIR"

  # Define the URL for the gitleaks release
  GITLEAKS_x64_URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VER}/gitleaks_${GITLEAKS_VER}_linux_x64.tar.gz"
  GITLEAKS_Darwin_URL="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VER}/gitleaks_${GITLEAKS_VER}_darwin_x64.tar.gz"

  # Detect OS and download the appropriate binary
  case "$(uname -s)" in
    Linux)
      curl -sSfL "$GITLEAKS_x64_URL" | tar -xvz -C "$INSTALL_DIR" gitleaks
      ;;
    Darwin)
      curl -sSfL "$GITLEAKS_Darwin_URL" | tar -xvz -C "$INSTALL_DIR" gitleaks
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
    echo "Failed to download or extract gitleaks. Please install it manually."
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
echo -n "Current gitleaks version: "
gitleaks version
echo "Running gitleaks check: "
gitleaks protect --staged --verbose --redact --report-path findings.json

# Check the exit status of gitleaks
if [ $? -ne 0 ]; then
  echo "gitleaks detected sensitive information. Commit aborted."
  exit 1
fi

echo "No credentials detected. Proceeding with commit."
exit 0
