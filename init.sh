#!/bin/bash

# Function to append a newline to .bashrc
append_newline_to_bashrc() {
  echo "" >>"$HOME/.bashrc"
}


# Function to install packages from a list
install_packages() {
  echo "Installing packages from pkglist..."
  for pkg in $(cat pkglist); do
    sudo apt-get -y install "$pkg"
  done
}

# Function to install 'z' from GitHub
install_z() {
  Z_PATH=/usr/local/bin/z
  echo "Installing z..."

  # Check if the .z directory already exists
  if [ -d "$Z_PATH" ]; then
    echo "z is already installed."
  else
    "Cloning z..."
    sudo git clone https://github.com/rupa/z.git $Z_PATH
  fi

  # Check if the .bashrc already sources z.sh
  if ! grep -q "source $Z_PATH/z.sh" "$HOME/.bashrc"; then
    echo "Adding z source to .bashrc..."
    echo "# z" >>"$HOME/.bashrc"
    echo "source $Z_PATH/z.sh" >>"$HOME/.bashrc"
    append_newline_to_bashrc
  else
    echo "z source already present in .bashrc"
  fi
}

# Function to install 'fnm' (Fast Node Manager)
install_fnm() {
  command -v fnm

  # Check if fnm is already installed
  if command -v fnm >/dev/null 2>&1; then
    echo "fnm is already installed."
  else
    # Install fnm using the recommended installation script
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
    source "$HOME/.bashrc"
    fnm install 20
    fnm use 20
  fi

  # Add fnm initialization to the shell profile to ensure it is loaded
  if ! grep -q 'eval "$(fnm env --use-on-cd)"' "$HOME/.bashrc"; then
    echo "Adding fnm initialization to .bashrc..."
    echo 'eval "$(fnm env --use-on-cd)"' >>"$HOME/.bashrc"
    append_newline_to_bashrc
  else
    echo "fnm initialization already present in .bashrc"
  fi
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

    sudo apt install -y apt-transport-https
    sudo apt update
    sudo apt install -y code

    echo "Visual Studio Code installation complete."
  fi
}

# Function to add hstr config
add_hstr_config() {

  # Add hstr config to .bashrc
  if ! grep -q 'HSTR configuration' "$HOME/.bashrc"; then
    echo "Adding hstr config to .bashrc..."
    hstr --show-configuration >>"$HOME/.bashrc"
    append_newline_to_bashrc
  else
    echo "hstr config already present in .bashrc"
  fi
}

install_starship() {
    # Check if Starship is already installed
    if command -v starship &> /dev/null; then
        echo "Starship is already installed."
    else
        echo "Starship is not installed. Installing now..."

        # Install Starship
        curl -sS https://starship.rs/install.sh | sh

        # Check if installation was successful
        if command -v starship &> /dev/null; then
            echo "Starship installed successfully."
        else
            echo "Starship installation failed."
            return 1
        fi
    fi
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
    append_newline_to_bashrc
  fi
}

install_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    echo "pnpm is already installed."
  else
    npm add -g pnpm
  fi
}

install_font_awesome() {
    # Check if FontAwesome is already installed by looking for one of its font files
    if fc-list | grep -qi "Font Awesome"; then
        echo "FontAwesome is already installed."
        return 0
    fi

    # URL of the FontAwesome zip file
    URL="https://use.fontawesome.com/releases/v6.6.0/fontawesome-free-6.6.0-desktop.zip"

    # Temporary directory for downloading and unzipping
    TEMP_DIR=$(mktemp -d)

    # Destination directory for the fonts
    FONT_DIR="$HOME/.fonts"

    # Download the zip file
    echo "Downloading FontAwesome..."
    wget -q -O "$TEMP_DIR/fontawesome.zip" "$URL"

    # Unzip the file
    echo "Unzipping FontAwesome..."
    unzip -q "$TEMP_DIR/fontawesome.zip" -d "$TEMP_DIR"

    # Create the fonts directory if it doesn't exist
    echo "Creating fonts directory if it doesn't exist..."
    mkdir -p "$FONT_DIR"

    # Move the .otf files to the fonts directory
    echo "Moving .otf files to $FONT_DIR..."
    find "$TEMP_DIR" -name '*.otf' -exec mv {} "$FONT_DIR" \;

    # Update the font cache
    echo "Updating font cache..."
    fc-cache -f -v

    # Cleanup
    echo "Cleaning up..."
    rm -rf "$TEMP_DIR"

    echo "FontAwesome installation complete!"
}

generate_ssh_key() {
  local key_name=$1
  local comment=$2

  if [ ! -f ~/.ssh/${key_name} ]; then
    echo "Generating SSH key: ${key_name}"
    ssh-keygen -t ed25519 -N "" -C "${comment}" -f ~/.ssh/${key_name}
    echo "SSH key ${key_name} generated."
  else
    echo "SSH key ${key_name} already exists."
  fi
}

# Ensure the script isn't running as root (not recommended for user-specific installations)
if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. It uses 'sudo' internally when needed."
  exit 1
fi

sudo apt update && sudo apt upgrade

# Install system-wide packages
install_packages
install_font_awesome

# add .bashrc_base
if grep -qxF "source $HOME/.bashrc_base" "$HOME/.bashrc"; then
  echo "source $HOME/.bashrc_base is already present in .bashrc"
else
  echo "source $HOME/.bashrc_base" >>"$HOME/.bashrc"
  echo "Added source $HOME/.bashrc_base to .bashrc"
fi

# Install starship 
install_starship

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

# Generate SSH keys
generate_ssh_key "private" "private_key"
generate_ssh_key "titanom" "titanom_key"

if ! pgrep -x "Xorg" >/dev/null; then
  echo "No X session found. Starting X..."
  startx
else
  echo "X session is already running."
fi

echo "Setup complete! Please restart your terminal or source your .bashrc to apply changes."
