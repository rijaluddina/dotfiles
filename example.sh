#!/bin/bash

# Colors for better visuals
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

coba() {
  shell=$(echo $SHELL)
  if [[ $shell == "/bin/zsh" ]]; then
    # Set zsh as the default shell
    echo -e "${BLUE}Setting zsh as the default shell...${NC}"
    chsh -s $(which zsh) || { echo -e "${RED}Failed to set Zsh as default shell.${NC}"; }
  else
    echo -e "${BLUE}Zsh is your default shell!.${NC}"
  fi
}
coba
