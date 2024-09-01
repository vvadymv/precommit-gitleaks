# Git Pre-commit Hook for Gitleaks

This repository provides a Git pre-commit hook script that automatically checks for sensitive information in your commits using [Gitleaks](https://github.com/gitleaks/gitleaks). This script ensures that no secrets or sensitive information are committed to your repository.

## Installation

Follow the steps below to set up the pre-commit hook in your git repository.

### 1. Manual Installation

1. Copy the pre-commit hook script 

   Downlopad this repository and copy script `pre-commit` to your local git repository's hooks, make sure the script executable:
   ```
   cp path-to-downloaded-repo/pre-commit .git/hooks/
   chmod +x .git/hooks/pre-commit
   ```

2. Enable the Hook via Git Config

   You can enable or disable the pre-commit hook using git config:
   ```
   git config hooks.gitleaks.enabled true   # To enable
   git config hooks.gitleaks.enabled false  # To disable
   ```

3. Test the Hook
   
   Test the pre-commit hook by making a commit:
   ```
   git commit -m "Test commit"
   ```
**If gitleaks detects any sensitive information, the commit will be aborted. Otherwise, the commit will proceed.**

> [!WARNING]  
> Potential Impact on Existing Configuration

If you already have a pre-commit hook configured, installing this script will overwrite your existing configuration. To avoid losing existing pre-commit logic, you should append the new gitleaks logic to your existing .git/hooks/pre-commit file instead of replacing it.

## Alternative Solution: Using pre-commit Framework
To manage multiple pre-commit hooks more effectively and avoid conflicts, consider using the pre-commit framework.

### Steps to use pre-commit Framework. 
If you don't already have pre-commit installed, you can install it using pip, create a .pre-commit-config.yaml configuration file and install needed hooks.
1. Install pre-commit
   ```
   pip install pre-commit
   ```
2. Create a .pre-commit-config.yaml file in the root of your repository with the following content:
   ```
   repos:
     - repo: https://github.com/gitleaks/gitleaks
       rev: v8.18.4
       hooks:
         - id: gitleaks
   ```
3. Install defined the pre-commit hooks:
    ```
    pre-commit install
    ```
4. Test the Hook by making a commit - the pre-commit framework will automatically run gitleaks and any other hooks defined in your .pre-commit-config.yaml.