#!/bin/bash

# Prompt the user at the start of the script
read -p "Do you want to use i3 with GNOME Flashback? (y/n): " response

install_i3_gnome() {
  I3_GNOME_PATH="$HOME/.i3-gnome"
  DESKTOP_FILE="/usr/share/applications/i3-gnome.desktop"

  # Check if the i3-gnome desktop file already exists
  if [ -f "$DESKTOP_FILE" ]; then
    echo "i3-gnome is already installed."
  else
    echo "Installing i3-gnome..."

    # Clone the i3-gnome repository to the specified path
    git clone https://github.com/nmakel/i3-gnome.git "$I3_GNOME_PATH"

    # Navigate to the directory and install dependencies
    cd "$I3_GNOME_PATH" || return

    # Run make install with sudo to ensure proper permissions
    sudo make install

    cd -

    echo "i3-gnome installation complete."
  fi
}

# Check if the user wants to proceed
if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "You chose to use i3 with GNOME Flashback. Installing..."

  # Install GNOME Flashback and i3
  sudo apt-get install -y gnome-flashback make gdm3
  install_i3_gnome # Install i3-gnome integration

  # remap caps to super with dconf, gnome overwrites settings from 00-keyboard.conf
  dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:super']"

  I3_CONFIG_PATH="$HOME/.config/i3/config"
  MEDIA_KEYS_CONFIG_PATH="$HOME/.config/i3/media-keybindings.config"

  # remove 'include' for media keybindings from i3 config in case gnome flashback is used
  if [ -f "$I3_CONFIG_PATH" ]; then
    # Check if the include line exists
    if grep -q "include $MEDIA_KEYS_CONFIG_PATH" "$I3_CONFIG_PATH"; then
      echo "Removing include line for $MEDIA_KEYS_CONFIG_PATH from i3 config."

      # Remove the 'include' line using sed
      sed -i "/$(echo $MEDIA_KEYS_CONFIG_PATH | sed 's/[&/\]/\\&/g')/d" $I3_CONFIG_PATH
    else
      echo "No include line for $MEDIA_KEYS_CONFIG_PATH found in i3 config."
    fi
  else
    echo "$I3_CONFIG_PATH does not exist. Skipping removal."
  fi

else
  echo "You chose not to use i3 with GNOME Flashback. Skipping..."
fi

append_newline_to_bashrc() {
  echo "" >>"$HOME/.bashrc"
}

# Function to install packages from a list
install_packages() {
  echo "Installing packages from pkglist..."
  while IFS= read -r pkg; do
    if ! dpkg -l | grep -q "^ii  $pkg "; then
      sudo apt-get -y install "$pkg"
    else
      echo "$pkg is already installed."
    fi
  done <pkglist
}

# Function to install 'z' from GitHub
install_z() {
  Z_PATH=/usr/local/bin/z

  # Check if the .z directory already exists
  if [ -d "$Z_PATH" ]; then
    echo "z is already installed."
  else
    echo "Installing z..."
    echo "Cloning z..."
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
}

# Function to install 'kitty' (terminal emulator)
install_kitty() {
  command -v kitty

  # Check if fnm is already installed
  if command -v kitty >/dev/null 2>&1; then
    echo "kitty is already installed."
  else
    echo "Installing kitty..."
    curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    sudo ln -s $HOME/.local/kitty.app/bin/* /usr/bin/
    echo "Kitty installation complete."
  fi

}

# Function to install the latest Visual Studio Code
install_vscode() {

  if command -v code >/dev/null 2>&1; then
    echo "Visual Studio Code is already installed."
  else
    echo "Installing Visual Studio Code..."
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
  if command -v starship &>/dev/null; then
    echo "Starship is already installed."
  else
    echo "Starship is not installed. Installing now..."

    # Install Starship
    curl -sS https://starship.rs/install.sh | sh

    # Check if installation was successful
    if command -v starship &>/dev/null; then
      echo "Starship installed successfully."
      echo "Adding starship config to .bashrc"
      echo 'eval "$(starship init bash)"' >>"$HOME/.bashrc"
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
sudo apt install extrepo -y
# enable librewolf repo
sudo extrepo enable librewolf
sudo apt update

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

install_kitty

install_starship

install_z

install_fnm

install_vscode

install_pyenv

install_pnpm

add_hstr_config

# Generate SSH keys
generate_ssh_key "gh_alt" "gh_alt_key"
generate_ssh_key "main" "main_key"

if ! pgrep -x "Xorg" >/dev/null; then
  echo "No X session found. Starting X..."
  startx
else
  echo "X session is already running."
fi

echo "Disable desktop in gsettings..."
gsettings set org.gnome.gnome-flashback desktop false
gsettings set org.gnome.gnome-flashback root-background true

echo "Setup complete! Please restart your terminal or source your .bashrc to apply changes."
