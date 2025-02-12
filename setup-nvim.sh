#!/bin/bash

set -e

# Define colors for output using tput for better compatibility
PINK=$(tput setaf 204)
PURPLE=$(tput setaf 141)
GREEN=$(tput setaf 114)
ORANGE=$(tput setaf 208)
BLUE=$(tput setaf 75)
YELLOW=$(tput setaf 221)
RED=$(tput setaf 196)
NC=$(tput sgr0) # No Color


echo -e "${PURPLE}Welcome to the TD.Dots Auto Config!${NC}"

sudo -v

while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Function to prompt user for input with a select menu
select_option() {
  local prompt_message="$1"
  shift
  local options=("$@")
  PS3="${ORANGE}$prompt_message${NC} "
  select opt in "${options[@]}"; do
    if [ -n "$opt" ]; then
      echo "$opt"
      break
    else
      echo -e "${RED}Invalid option. Please try again.${NC}"
    fi
  done
}

# Function to prompt user for input with a default option
prompt_user() {
  local prompt_message="$1"
  local default_answer="$2"
  read -p "$(echo -e ${BLUE}$prompt_message [$default_answer]${NC}) " user_input
  user_input="${user_input:-$default_answer}"
  echo "$user_input"
}

# Function to display a spinner
spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}
# Function to check and create directories if they do not exist
ensure_directory_exists() {
  local dir_path="$1"
  local create_templates="$2"

  if [ ! -d "$dir_path" ]; then
    echo -e "${YELLOW}Directory $dir_path does not exist. Creating...${NC}"
    mkdir -p "$dir_path"
  else
    echo -e "${GREEN}Directory $dir_path already exists.${NC}"
  fi

  # Check for the "templates" directory only if create_templates is true
  if [ "$create_templates" == "true" ]; then
    if [ ! -d "$dir_path/templates" ]; then
      echo -e "${YELLOW}Templates directory does not exist. Creating...${NC}"
      mkdir -p "$dir_path/templates"
      echo -e "${GREEN}Templates directory created at $dir_path/templates${NC}"
    else
      echo -e "${GREEN}Templates directory already exists at $dir_path/templates${NC}"
    fi
  fi
}

# Function to check if running on WSL
is_wsl() {
  grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null
  return $?
}

# Function to run commands with optional suppression of output
run_command() {
  local command=$1
  if [ "$show_details" = "Yes" ]; then
    eval $command
  else
    eval $command &>/dev/null
  fi
}

# Function to detect if the system is Arch Linux
is_arch() {
  if [ -f /etc/arch-release ]; then
    return 0
  else
    return 1
  fi
}

# Function to install basic dependencies
install_dependencies() {
    run_command "sudo apt-get update"
    run_command "sudo apt-get install -y build-essential curl file git"
    run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    run_command ". $HOME/.cargo/env"
}

install_homebrew_with_progress() {
  local install_command="$1"

  echo -e "${YELLOW}Installing Homebrew...${NC}"

  if [ "$show_details" = "No" ]; then
    # Run installation in the background and show progress
    (eval "$install_command" &>/dev/null) &
    spinner
  else
    # Run installation normally
    eval "$install_command"
  fi
}

# Function to install Homebrew if not installed
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Homebrew is not installed. Installing Homebrew...${NC}"

    if [ "$show_details" = "No" ]; then
      # Show progress bar while installing Homebrew
      install_homebrew_with_progress "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      spinner
    else
      # Install Homebrew normally
      run_command "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi

    # Add Homebrew to PATH based on OS
      run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.zshrc)"
      run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.bashrc)"
      run_command "mkdir -p ~/.config/fish"
      run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.config/fish/config.fish)"
      run_command "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
  else
    echo -e "${GREEN}Homebrew is already installed.${NC}"
  fi
}

# Function to update or replace a line in a file
update_or_replace() {
  local file="$1"
  local search="$2"
  local replace="$3"

  if grep -q "$search" "$file"; then
    awk -v search="$search" -v replace="$replace" '
    $0 ~ search {print replace; next}
    {print}
    ' "$file" >"${file}.tmp" && mv "${file}.tmp" "$file"
  else
    echo "$replace" >>"$file"
  fi
}

# Ask if the user wants to see detailed output
show_details="Yes"

# Ask for the operating system
os_choice="linux"
 
# Install basic dependencies with progress bar
echo -e "${YELLOW}Installing basic dependencies...${NC}"
if [ "$show_details" = "No" ]; then
  install_dependencies &
  spinner
else
  install_dependencies
fi

# Function to clone repository with progress bar
clone_repository_with_progress() {
  local repo_url="$1"
  local clone_dir="$2"
  local progress_duration=$3

  echo -e "${YELLOW}Cloning repository...${NC}"

  if [ "$show_details" = "No" ]; then
    # Run clone command in the background and show progress
    (git clone "$repo_url" "$clone_dir" &>/dev/null) &
    spinner "$progress_duration"
  else
    # Run clone command normally
    git clone "$repo_url" "$clone_dir"
  fi
}

# Step 1: Clone the Repository
echo -e "${YELLOW}Step 1: Clone the Repository${NC}"
if [ -d "TD.Dots" ]; then
  echo -e "${GREEN}Repository already cloned. Overwriting...${NC}"
  rm -rf "TD.Dots"
fi
clone_repository_with_progress "https://github.com/tdalexm/Dotfiles.git" "TD.Dots" 20
cd TD.Dots || exit

# Install Homebrew if not installed
install_homebrew

# Shared Steps (macOS, Linux, or WSL)

# Function to install shell or plugins with progress bar
install_shell_with_progress() {
  local name="$1"
  local install_command="$2"

  echo -e "${YELLOW}Installing $name...${NC}"
  if [ "$show_details" = "No" ]; then
    (eval "$install_command" &>/dev/null) &
    spinner
  else
    eval "$install_command"
  fi
}

set_as_default_shell() {
  local name="$1"

  echo -e "${YELLOW}Setting default shell to $name...${NC}"
  local shell_path
  shell_path=$(which "$name") # Obtener el camino completo del shell

  if [ -n "$shell_path" ]; then
    sudo sh -c "grep -Fxq \"$shell_path\" /etc/shells || echo \"$shell_path\" >> /etc/shells"

    sudo chsh -s "$shell_path" "$USER"

    if [ "$SHELL" != "$shell_path" ]; then
      echo -e "${RED}Error: Shell did not change. Please check manually.${NC}"
      echo -e "${GREEN}Command: sudo chsh -s $shell_path \$USER ${NC}"
    else
      echo -e "${GREEN}Shell changed to $shell_path successfully.${NC}"
    fi
  else
    echo -e "${RED}Shell $name not found.${NC}"
  fi
}

echo -e "${YELLOW}Step 3: Choose and Install Shell${NC}"
shell_choice="nushell"

# Case for shell choice
  run_command "cp -rf bash-env-json ~/.config/"
  run_command "cp -rf bash-env.nu ~/.config/"

  install_shell_with_progress "nushell" "brew install nushell carapace zoxide atuin jq bash starship"

  mkdir -p ~/.cache/starship
  mkdir -p ~/.cache/carapace
  mkdir -p ~/.local/share/atuin

  run_command "cp -rf starship.toml ~/.config/"

  echo -e "${YELLOW}Configuring Nushell...${NC}"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    mkdir -p ~/Library/Application\ Support/nushell
    update_or_replace "nushell/env.nu" "/home/linuxbrew/.linuxbrew/bin" "    | prepend '/opt/homebrew/bin'"
    run_command "cp -rf nushell/* ~/Library/Application\ Support/nushell/"
  else
    mkdir -p ~/.config/nushell
    run_command "cp -rf nushell/* ~/.config/nushell/"
  fi


# Function to install dependencies with progress bar
install_dependencies_with_progress() {
  local install_command="$1"

  echo -e "${YELLOW}Installing dependencies...${NC}"

  if [ "$show_details" = "No" ]; then
    # Run installation in the background and show progress
    (eval "$install_command" &>/dev/null) &
    spinner
  else
    # Run installation normally
    eval "$install_command"
  fi
}

# Step 5: Additional Configurations

# Dependencies Install
echo -e "${YELLOW}Step 4: Installing Additional Dependencies...${NC}"

install_dependencies_with_progress "sudo apt-get update && sudo apt-get upgrade -y"

# Function to install window manager with progress bar
install_window_manager_with_progress() {
  local install_command="$1"

  echo -e "${YELLOW}Installing window manager...${NC}"

  if [ "$show_details" = "No" ]; then
    # Run installation in the background and show progress
    (eval "$install_command" &>/dev/null) &
    spinner
  else
    # Run installation normally
    eval "$install_command"
  fi
}

# Ask if they want to use Tmux or Zellij, or none
echo -e "${YELLOW}Step 4: Choose and Install Window Manager${NC}"
wm_choice="zellij"

  if [ "$show_details" = "Yes" ]; then
    install_window_manager_with_progress "brew uninstall zellij | cargo install zellij"
  else
    run_command "cargo install zellij"
  fi

  echo -e "${YELLOW}Configuring Zellij...${NC}"
  run_command "mkdir -p ~/.config/zellij"
  run_command "cp -r zellij/* ~/.config/zellij/"

  # Replace TMUX with ZELLIJ and tmux with zellij only in the selected shell configuration
  if [[ "$shell_choice" == "nushell" ]]; then
    os_type=$(uname)

    if [[ "$os_type" == "Darwin" ]]; then
      update_or_replace "nushell/config.nu" '"tmux"' 'let MULTIPLEXER = "zellij"'
      update_or_replace "nushell/config.nu" '"TMUX"' 'let MULTIPLEXER_ENV_PREFIX = "ZELLIJ"'
      run_command "cp -rf nushell/* ~/Library/Application\ Support/nushell/"
    else
      update_or_replace ~/.config/nushell/config.nu '"tmux"' 'let MULTIPLEXER = "zellij"'
      update_or_replace ~/.config/nushell/config.nu '"TMUX"' 'let MULTIPLEXER_ENV_PREFIX = "ZELLIJ"'
    fi
  fi

# Neovim Configuration
echo -e "${YELLOW}Step 5: Choose and Install NVIM${NC}"
install_nvim=$(select_option "Do you want to install Neovim?" "Yes" "No")

if [ "$install_nvim" = "Yes" ]; then
run_command "mkdir -p ~/notes"
  OBSIDIAN_PATH="~/notes"
  ensure_directory_exists "$OBSIDIAN_PATH" "true"

  # Install additional packages with Neovim
  install_dependencies_with_progress "brew install nvim node npm git gcc fzf fd ripgrep coreutils bat curl lazygit"

  # Neovim Configuration
  echo -e "${YELLOW}Configuring Neovim...${NC}"
  run_command "mkdir -p ~/.config/nvim"
  run_command "cp -r nvim/* ~/.config/nvim/"
  # Obsidian Configuration
  echo -e "${YELLOW}Configuring Obsidian...${NC}"
  obsidian_config_file="$HOME/.config/nvim/lua/plugins/obsidian.lua"

  if [ -f "$obsidian_config_file" ]; then
    # Replace the vault path in the existing configuration
    update_or_replace "$obsidian_config_file" "/your/notes/path" "path = '$OBSIDIAN_PATH'"
  else
    echo -e "${RED}Obsidian configuration file not found at $obsidian_config_file. Please check your setup.${NC}"
  fi
fi

# Clean up: Remove the cloned repository
sudo chown -R $(whoami) $(brew --prefix)/*
echo -e "${YELLOW}Cleaning up...${NC}"
cd ..
run_command "rm -rf TD.Dots"

if [ "$shell_choice" = "nushell" ]; then
  shell_choice="nu"
fi

set_as_default_shell "$shell_choice"

echo -e "${GREEN}Configuration complete. Restarting shell...${NC}"
echo -e "${GREEN}If it doesn't restart, restart your computer or WSL instance??${NC}"

exec $shell_choice
