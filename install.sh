#!/bin/sh

# Colors for better visuals
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define package names
packages="
  bat
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
"

ask() {
  while true; do
    printf "%s (Y/n) " "$1"
    read -r REPLY
    REPLY=${REPLY:-"y"}
    case $REPLY in
    [Yy]) return 1 ;;
    [Nn]) return 0 ;;
    esac
  done
}

# Function to install packages
install_packages() {
  echo "${BLUE}Updating package lists...${NC}"
  sudo apt update && sudo apt upgrade -y || {
    echo "${RED}Failed to update package lists.${NC}"
    exit 1
  }

  echo "${BLUE}Installing required packages...${NC}"
  for package in $packages; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
      echo "${GREEN}Installing $package...${NC}"
      sudo apt install -y "$package" || { echo "${RED}Failed to install $package.${NC}"; }
    else
      echo "${YELLOW}$package is already installed.${NC}"
    fi
  done
}

# Install Neovim
install_neovim() {
  if ! dpkg -s nvim >/dev/null 2>&1; then
    echo "${GREEN}Installing Neovim...${NC}"
    sudo snap install nvim --classic || { echo "${RED}Failed to install Neovim.${NC}"; }
  else
    echo "${YELLOW}Neovim is already installed.${NC}"
  fi
}

# Configure batcat & fd-find in Ubuntu
configure_bat_fd() {
  echo "${BLUE}Configuring batcat and fd-find...${NC}"
  if [ ! -d "$HOME/.local/bin/bat" ] && [ ! -d "$HOME/.local/bin/fd" ]; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
    ln -sf /usr/bin/fdfind ~/.local/bin/fd
  else
    echo "${YELLOW}batcat & fd-find has been configured"
  fi
}

# Install Zsh and Oh My Zsh
install_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "${GREEN}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { echo "${RED}Failed to install Oh My Zsh.${NC}"; }
    exit 1
  else
    echo "${YELLOW}Oh My Zsh is already installed.${NC}"
  fi
  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ] ||
    [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] ||
    [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" ] ||
    [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete" ]; then
    echo "${BLUE}Installing Zsh plugins...${NC}"

    # Cloning zsh-autosuggestions
    if ! git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; then
      echo "${RED}Failed to clone zsh-autosuggestions.${NC}"
    fi

    # Cloning zsh-syntax-highlighting
    if ! git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"; then
      echo "${RED}Failed to clone zsh-syntax-highlighting.${NC}"
    fi

    # Cloning fast-syntax-highlighting
    if ! git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"; then
      echo "${RED}Failed to clone fast-syntax-highlighting.${NC}"
    fi

    # Cloning zsh-autocomplete
    if ! git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"; then
      echo "${RED}Failed to clone zsh-autocomplete.${NC}"
    fi
  else
    echo "${YELLOW}Zsh plugins are already installed.${NC}"
  fi

  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  else
    echo "${YELLOW}powerlevel10k already installed.${NC}"
  fi
  shell=$(echo $SHELL)
  if [ "$shell" = "/bin/bash" ]; then
    # Set zsh as the default shell
    echo "${BLUE}Setting zsh as the default shell...${NC}"
    chsh -s $(which zsh) || { echo "${RED}Failed to set Zsh as default shell.${NC}"; }
  else
    echo "${YELLOW}Zsh is your default shell.${NC}"
  fi
}

# Install Tpm for Tmux
install_tmux_tpm() {
  echo "${BLUE}Installing TPM for Tmux...${NC}"
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  else
    echo "${YELLOW}TPM is already installed.${NC}"
  fi
}

# Install fzf & fzf-git
install_fzf() {
  if [ ! -d "$HOME/.fzf" ] && [ ! -d "$HOME/.fzf-git.sh" ]; then
    echo "${BLUE}Installing fzf and fzf-git...${NC}"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    git clone https://github.com/junegunn/fzf-git.sh.git ~/.fzf-git.sh
  else
    echo "${YELLOW}fzf is already installed.${NC}"
  fi
}

# Install nvm
install_nvm() {
  if ! command -v nvm >/dev/null 2>&1; then
    echo "${GREEN}Installing nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash || { echo "${RED}Failed to install nvm.${NC}"; }
  else
    echo "${YELLOW}nvm is already installed.${NC}"
  fi
}

# Install WhiteSur-gtk-theme
install_whitesur_theme() {
  echo "${BLUE}Installing WhiteSur-gtk-theme...${NC}"
  if [ ! -d "$HOME/.WhiteSur" ]; then
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1 ~/.WhiteSur
  else
    echo "${YELLOW}WhiteSur theme is already installed.${NC}"
  fi
}

# Install lazygit
install_lazygit() {
  if ! command -v lazygit >/dev/null 2>&1; then
    echo "${GREEN}Installing lazygit...${NC}"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin || { echo "${RED}Failed to install lazygit.${NC}"; }
    rm -f lazygit.tar.gz
  else
    echo "${YELLOW}lazygit is already installed.${NC}"
  fi
}

# Install composer
install_composer() {
  if ! command -v composer >/dev/null 2>&1; then
    echo "${GREEN}Installing Composer...${NC}"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer || { echo "${RED}Failed to move Composer.${NC}"; }
  else
    echo "${YELLOW}Composer is already installed.${NC}"
  fi
}

# Clone your dotfiles
clone_dotfiles() {
  if [ ! -d "$HOME/.dotfiles" ]; then
    echo "${BLUE}Cloning your dotfiles...${NC}"
    git clone --recursive https://github.com/rijaluddina/dotfiles.git ~/.dotfiles || {
      echo "${RED}Failed to clone dotfiles.${NC}"
      exit 1
    }
  else
    echo "${YELLOW}Dotfiles are already cloned.${NC}"
  fi
}

configuration() {
  echo "${BLUE}Symlink neovim configuration...${NC}"
  if [ -e ~/.config/nvim ] || [ -L ~/.config/nvim ]; then
    echo "${YELLOW}Neovim configuration already exists. Skipping...${NC}"
  else
    ln -s ~/.dotfiles/config/nvim ~/.config/ && echo "${GREEN}Neovim configuration copied successfully.${NC}" || echo -e "${RED}Neovim configuration failed.${NC}"
  fi

  echo "${BLUE}Symlink lazygit configuration...${NC}"
  if [ -e ~/.config/lazygit ] || [ -L ~/.config/lazygit ]; then
    echo "${YELLOW}Lazygit configuration already exists. Skipping...${NC}"
  else
    ln -s ~/.dotfiles/config/lazygit ~/.config/ && echo "${GREEN}Lazygit configuration copied successfully.${NC}" || echo -e "${RED}Lazygit configuration failed.${NC}"
  fi

  echo "${BLUE}Symlink git configuration...${NC}"
  if [ -e ~/.gitconfig ] || [ -L ~/.gitconfig ]; then
    echo "${YELLOW}Git configuration already exists. Skipping...${NC}"
  else
    ln -s ~/.dotfiles/user/gitconfig ~/.gitconfig && echo "${GREEN}Git configuration copied successfully.${NC}" || echo -e "${RED}Git configuration failed.${NC}"
  fi

  echo "${BLUE}Symlink tmux configuration...${NC}"
  if [ -e ~/.tmux.conf ] || [ -L ~/.tmux.conf ]; then
    echo "${YELLOW}Tmux configuration already exists. Skipping...${NC}"
  else
    ln -s ~/.dotfiles/user/tmux.conf ~/.tmux.conf && echo "${GREEN}Tmux configuration copied successfully.${NC}" || echo -e "${RED}Tmux configuration failed.${NC}"
  fi

  echo "${BLUE}Symlink workspace configuration...${NC}"
  if [ -e ~/.workspace.sh ] || [ -L ~/.workspace.sh ]; then
    echo "${YELLOW}Tmux configuration already exists. Skipping...${NC}"
  else
    ln -s ~/.dotfiles/user/workspace.sh ~/.workspace.sh && echo "${GREEN}Workspace configuration copied successfully.${NC}" || echo -e "${RED}Workspace configuration failed.${NC}"
  fi

  echo "${BLUE}Symlink zsh configuration...${NC}"
  if [ -e ~/.tmux.conf ] || [ -L ~/.tmux.conf ] || [ ! -d "$HOME/.zshrc" ]; then
    rm ~/.zshrc && ln -s ~/.dotfiles/user/zshrc ~/.zshrc && echo "${GREEN}Zsh reconfiguration successfully.${NC}" || echo -e "${RED}Zsh configuration failed.${NC}"
  else
    ln -s ~/.dotfiles/user/zshrc ~/.zshrc && echo "${GREEN}Zsh configuration successfully.${NC}" || echo -e "${RED}Zsh configuration failed.${NC}"
  fi

  if [ ! -d "$HOME/.local/share/backgrounds" ]; then
    ask "$(echo "${BLUE}$(whoami),do you want to configure the backgrounds?${NC}")"
    rm -rf ~/.local/share/backgrounds
    ln -s ~/.dotfiles/local/backgrounds ~/.local/share/
  fi

  if [ ! -d "$HOME/.local/share/fonts" ]; then
    ask "$(echo "${BLUE}$(whoami),do you want to configure the fonts?${NC}")"
    rm -rf ~/.local/share/fonts
    ln -s ~/.dotfiles/local/fonts ~/.local/share/
  fi
}

# Main installation process
ask "$(echo "${BLUE}$(whoami),Do you want to proceed with installing the necessary packages?${NC}")"
if [ $? -eq 1 ]; then
  echo "${BLUE}Starting system configuration...${NC}"
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
  configuration
  echo "${GREEN}Configuration completed!${NC}"
else
  echo "${RED}Installation aborted.${NC}"
fi
