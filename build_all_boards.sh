#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

usage() {
  cat <<'EOF'
Usage: ./build_all_boards.sh [options] [board1 board2...]

Options:
  -b, --boards BOARD[,BOARD,...]   Build one or more boards separated by commas.
  -e, --env-file FILE             Read board names from a .env-style file.
  -l, --list                      Show configured boards and exit.
  -c, --clean                     Remove existing build directories before building.
  -h, --help                      Show this help message.

Examples:
  ./build_all_boards.sh -b qemu_x86,native_posix
  ./build_all_boards.sh qemu_x86 qemu_x86_64
  ./build_all_boards.sh -e boards.env
  ./build_all_boards.sh -l
  ./build_all_boards.sh -c qemu_x86
EOF
}

boards=()
clean=false
list_only=false
env_file="boards.env"

read_boards_from_env() {
  if [[ ! -f "$env_file" ]]; then
    return 1
  fi

  local line
  line="$(grep -E '^[[:space:]]*BOARDS[[:space:]]*=' "$env_file" | tail -n1 || true)"
  if [[ -z "$line" ]]; then
    return 1
  fi

  local rhs="${line#*=}"
  rhs="${rhs##+([[:space:]])}"
  rhs="${rhs%%+([[:space:]])}"
  rhs="${rhs#\"}"
  rhs="${rhs%\"}"
  rhs="${rhs#\'}"
  rhs="${rhs%\'}"

  IFS=',' read -r -a boards <<< "$rhs"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--boards)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Error: missing argument for $1"
        usage
        exit 1
      fi
      IFS=',' read -r -a boards <<< "$1"
      shift
      ;;
    -e|--env-file)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Error: missing argument for $1"
        usage
        exit 1
      fi
      env_file="$1"
      shift
      ;;
    -l|--list)
      list_only=true
      shift
      ;;
    -c|--clean)
      clean=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -* )
      echo "Error: unknown option: $1"
      usage
      exit 1
      ;;
    * )
      boards+=("$1")
      shift
      ;;
  esac
 done

if [[ ${#boards[@]} -eq 0 ]]; then
  if ! read_boards_from_env; then
    echo "Error: no boards specified and no valid BOARDS variable found in $env_file."
    usage
    exit 1
  fi
fi

if [[ "$list_only" == true ]]; then
  echo "Configured boards:"
  for board in "${boards[@]}"; do
    echo "- $board"
  done
  exit 0
fi

for board in "${boards[@]}"; do
  build_dir="build/${board}"
  if [[ "$clean" == true && -d "$build_dir" ]]; then
    echo "Removing existing build directory: $build_dir"
    rm -rf "$build_dir"
  fi

  echo "Building for board: $board"
  west build -b "$board" -d "$build_dir" "$SCRIPT_DIR"
  echo "Finished build for $board -> $build_dir"
  echo
 done

echo "All requested builds completed."
