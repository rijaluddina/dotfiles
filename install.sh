#!/bin/bash

# Colors for better visuals
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting system configuration...${NC}"

# Define package names
packages=(
  bat
  curl
  eza
  fd-find
  gcc
  gh
  git
  git-delta
  gnome-shell-extension-manager
  gnome-tweaks
  luarocks
  make
  php
  php-sqlite3
  php-xml
  php-intl
  php-cli
  php-curl
  php-zip
  python3.12-venv
  ripgrep
  sqlite3
  tmux
  xsel
  zsh
  zoxide
)

# Function to install packages
install_packages() {
  echo -e "${BLUE}Updating package lists...${NC}"
  sudo apt update
  echo -e "${BLUE}Installing required packages...${NC}"
  for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "$package"; then
      echo -e "${GREEN}Installing $package...${NC}"
      sudo apt install -y "$package"
    else
      echo -e "${RED}$package is already installed.${NC}"
    fi
  done
}

# Install Neovim
install_neovim() {
  if ! command -v nvim &>/dev/null; then
    echo -e "${GREEN}Installing Neovim...${NC}"
    sudo snap install nvim --classic
  else
    echo -e "${RED}Neovim is already installed.${NC}"
  fi
}

# Configure batcat & fd-find in Ubuntu
configure_bat_fd() {
  echo -e "${BLUE}Configuring batcat and fd-find...${NC}"
  mkdir -p ~/.local/bin
  ln -sf /usr/bin/batcat ~/.local/bin/bat
  ln -sf /usr/bin/fdfind ~/.local/bin/fd
}

# Install Zsh and Oh My Zsh
install_zsh() {
  if [ -z "$ZSH" ]; then
    echo -e "${GREEN}Installing Zsh and Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  else
    echo -e "${RED}Oh My Zsh is already installed.${NC}"
  fi

  echo -e "${BLUE}Installing Zsh plugins...${NC}"
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
  git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
}

# Install Tpm for Tmux
install_tmux_tpm() {
  echo -e "${BLUE}Installing TPM for Tmux...${NC}"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Install fzf & fzf-git
install_fzf() {
  echo -e "${BLUE}Installing fzf and fzf-git...${NC}"
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
  git clone https://github.com/junegunn/fzf-git.sh.git ~/.fzf-git.sh
}

# Install nvm
install_nvm() {
  if ! command -v nvm &>/dev/null; then
    echo -e "${GREEN}Installing nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  else
    echo -e "${RED}nvm is already installed.${NC}"
  fi
}

# Install WhiteSur-gtk-theme
install_whitesur_theme() {
  echo -e "${BLUE}Installing WhiteSur-gtk-theme...${NC}"
  git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 ~/.WhiteSur
}

# Install lazygit
install_lazygit() {
  if ! command -v lazygit &>/dev/null; then
    echo -e "${GREEN}Installing lazygit...${NC}"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
  else
    echo -e "${RED}lazygit is already installed.${NC}"
  fi
}

# Install composer
install_composer() {
  if ! command -v composer &>/dev/null; then
    echo -e "${GREEN}Installing Composer...${NC}"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
  else
    echo -e "${RED}Composer is already installed.${NC}"
  fi
}

# Clone your dotfiles
clone_dotfiles() {
  if [ ! -d "$HOME/.dotfiles" ]; then
    echo -e "${BLUE}Cloning your dotfiles...${NC}"
    git clone https://github.com/rijaluddina/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
  else
    echo -e "${RED}Dotfiles are already cloned.${NC}"
  fi
}

# Main installation process
echo -e "${BLUE}Do you want to proceed with installing the necessary packages? (y/n)${NC}"
read -r proceed
if [[ "$proceed" == "y" ]]; then
  install_packages
  install_neovim
  configure_bat_fd
  install_zsh
  install_tmux_tpm
  install_fzf
  install_nvm
  install_whitesur_theme
  install_lazygit
  install_composer
  clone_dotfiles
  echo -e "${GREEN}Configuration completed!${NC}"
else
  echo -e "${RED}Installation aborted.${NC}"
fi
