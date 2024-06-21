#!/bin/bash

# Function to append a newline to .bashrc
append_newline_to_bashrc() {
  echo "" >>"$HOME/.bashrc"
}

# Function to install 'oh my bash'
install_oh_my_bash() {
  # Check if Oh My Bash is already installed
  if [ -d "$HOME/.oh-my-bash" ]; then
    echo "Oh My Bash is already installed."
  else
    echo "Installing Oh My Bash..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
    echo "Oh My Bash installation complete."
  fi
  append_newline_to_bashrc
}

# Function to install packages from a list
install_packages() {
  echo "Installing packages from pkglist..."
  for pkg in $(cat pkglist); do
    sudo apt-get -y install "$pkg"
  done
  append_newline_to_bashrc
}

# Function to install 'z' from GitHub
install_z() {
  Z_PATH=/usr/local/bin/z
  echo "Installing z..."

  # Check if the .z directory already exists
  if [ -d "$HOME/.z" ]; then
    echo "z is already installed."
  else
    sudo git clone https://github.com/rupa/z.git $Z_PATH
  fi

  # Check if the .bashrc already sources z.sh
  if ! grep -q "source $Z_PATH/z.sh" "$HOME/.bashrc"; then
    echo "Adding z source to .bashrc..."
    echo "# z" >>"$HOME/.bashrc"
    echo "source $Z_PATH/z.sh" >>"$HOME/.bashrc"
  else
    echo "z source already present in .bashrc"
  fi
  append_newline_to_bashrc
}

# Function to install 'fnm' (Fast Node Manager)
install_fnm() {
  echo "Installing fnm and node lts..."
  command -v fnm

  # Check if fnm is already installed
  if command -v fnm >/dev/null 2>&1; then
    echo "fnm is already installed."
  else
    # Install fnm using the recommended installation script
    curl -fsSL https://fnm.vercel.app/install | bash
    fnm install 20
  fi

  # Add fnm initialization to the shell profile to ensure it is loaded
  if ! grep -q 'eval "$(fnm env --use-on-cd)"' "$HOME/.bashrc"; then
    echo "Adding fnm initialization to .bashrc..."
    echo 'eval "$(fnm env --use-on-cd)"' >>"$HOME/.bashrc"
  else
    echo "fnm initialization already present in .bashrc"
  fi
  append_newline_to_bashrc
}

# Function to install the latest Visual Studio Code
install_vscode() {
  echo "Installing Visual Studio Code..."

  if command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code is already installed."
  else
    sudo apt-get install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    rm -f packages.microsoft.gpg

    echo "Visual Studio Code installation complete."
  fi
  append_newline_to_bashrc
}

# Function to add hstr config
add_hstr_config() {
  echo "Adding hstr config"

  # Add hstr config to .bashrc
  if ! grep -q 'HSTR configuration' "$HOME/.bashrc"; then
    echo "Adding hstr config to .bashrc..."
    hstr --show-configuration >>"$HOME/.bashrc"
  else
    echo "hstr config already present in .bashrc"
  fi
  append_newline_to_bashrc
}

# Function to install pyenv
install_pyenv() {
  if [ -d "$HOME/.pyenv" ]; then
    echo "pyenv is already installed."
  else
    curl https://pyenv.run | bash
    eval "$(pyenv virtualenv-init -)"
  fi

  if ! grep -q "pyenv" "$HOME/.bashrc"; then
    echo "# pyenv" >>"$HOME/.bashrc"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >>"$HOME/.bashrc"
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >>"$HOME/.bashrc"
    echo 'eval "$(pyenv init -)"' >>"$HOME/.bashrc"
  fi
  append_newline_to_bashrc
}

install_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    echo "pnpm is already installed."
  else
    npm add -g pnpm
  fi
}

# Ensure the script isn't running as root (not recommended for user-specific installations)
if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. It uses 'sudo' internally when needed."
  exit 1
fi

# Install system-wide packages
install_packages

# Install Oh My Bash (must be first to avoid overwriting .bashrc changes)
install_oh_my_bash

# Run user-specific installations for 'z'
install_z

# Install fnm
install_fnm

# Install Visual Studio Code
install_vscode

# Install pyenv
install_pyenv

install_pnpm

# Add hstr configuration
add_hstr_config

echo "Setup complete! Please restart your terminal or source your .bashrc to apply changes."
