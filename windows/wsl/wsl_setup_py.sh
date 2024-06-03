#!/usr/bin/env bash

set -e

if [[ $EUID -eq 0 ]]; then
  echo "This script must be run as non-root, use "$0" instead" 1>&2
  exit 1
fi

_VERBOSE=0
CURRENT_STEP=1
TOTAL_STEPS=8

while getopts "v" opt; do
  case $opt in
  v)
    _VERBOSE=1
    ;;
  \?)
    printf "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

validate_dependencies() {
  local dependencies=("$@")

  for dep in "${dependencies[@]}"; do
      if ! command_exists "$dep"; then
          printf "Error: $dep is not installed. Please install it before running this script.\n" >&2
          exit 1
      fi
  done
}

run_command() {
  if [[ $_VERBOSE -eq 1 ]]; then
    "$@" || { exit 1; }
  else
    "$@" &>/dev/null || { printf "Error: Command failed: %s\n" "$*" >&2; exit 1; }
  fi
}

print_progress() {
  printf "[%d/%d]: %s\n" "$CURRENT_STEP" "$TOTAL_STEPS" "$@"
  ((CURRENT_STEP++))
}

add_to_file_if_not_present() {
  local file=$1
  local line=$2
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

main() {
  if command_exists "pyenv"; then
    printf "Pyenv already installed. Skipping.\n"
    exit 0
  fi

  validate_dependencies curl awk sort sed

  # Step 1: Update package list
  print_progress "Updating package lists"
  run_command sudo apt update

  # Step 2: Install essential packages
  print_progress "Installing essential packages"
  run_command sudo apt install -y gcc make zlib1g zlib1g-dev build-essential libssl-dev libbz2-dev \
      libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev \
      libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

  # Step 3: Install pyenv
  print_progress "Installing pyenv"
  run_command bash -c "$(curl -s https://pyenv.run)"

  # Step 4: Configure pyenv initialization in .bashrc
  print_progress "Configuring pyenv initialization in .bashrc"
  {
    add_to_file_if_not_present ~/.bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
    add_to_file_if_not_present ~/.bashrc 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    add_to_file_if_not_present ~/.bashrc 'eval "$(pyenv init -)"'
    add_to_file_if_not_present ~/.bashrc 'eval "$(pyenv virtualenv-init -)"'
  }

  # Step 5: Configure pyenv in .profile
  print_progress "Configuring pyenv initialization in .profile"
  {
    add_to_file_if_not_present ~/.profile 'export PYENV_ROOT="$HOME/.pyenv"'
    add_to_file_if_not_present ~/.profile 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    add_to_file_if_not_present ~/.profile 'eval "$(pyenv init -)"'
  }

  # Step 6: Restart shell
  print_progress "Restarting shell"
  
  # In non-verbose mode, these commands fail when using run_command.
  source ~/.profile
  source ~/.bashrc

  # Step 7 & 8: Install the latest Python version using pyenv
  print_progress "Installing the latest Python version using pyenv"
  {
    latest_version=$(pyenv install -l | awk '!/[a-zA-Z]/ {gsub(/^[ \t]+/, ""); print}' | sort -rV | sed -n 1p)
    if [ -z "$latest_version" ]; then
      printf "Error: Unable to determine the latest Python version.\n" >&2
      exit 1
    fi
    
    run_command pyenv install -s "$latest_version"
    
    print_progress "Setting latest Python version ($latest_version) as global version"
    run_command pyenv global "$latest_version"
  }

  printf "All tasks completed. You're now ready to go!\n"
}

main "$@"