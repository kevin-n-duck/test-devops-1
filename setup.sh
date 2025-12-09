#!/bin/bash

echo "[Validator Setup] Starting setup..."

# Detect OS and install Node.js if missing
OS="$(uname -s)"

detect_and_install_node() {
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo "[INFO] Node.js already installed: $(node -v)"
        echo "[INFO] npm version: $(npm -v)"
        node_version=$(node -v)

        # shellcheck disable=SC2086
        major_v=$(echo ${node_version/#v/} | cut -d "." -f1)

        if [[ $major_v -lt 18 ]] ; then
            echo "upgrade node version 18 or higher"

        fi


        return
    fi

    echo "[INFO] Node.js or npm not found. Attempting installation..."

    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                echo "[INFO] Installing Node.js via apt..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt install -y nodejs
            elif [ -f /etc/redhat-release ]; then
                echo "[INFO] Installing Node.js via yum..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            else
                echo "[WARN] Unsupported Linux distro. Please install Node.js manually."
                exit 1
            fi
            ;;
        Darwin*)
            if command -v brew &>/dev/null; then
                echo "[INFO] Installing Node.js via Homebrew..."
                brew install node
            else
                echo "[ERROR] Homebrew not found. Please install Node.js manually."
                exit 1
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "[INFO] Detected Windows (Git Bash or WSL). Please install Node.js manually from https://nodejs.org/"
            exit 1
            ;;
        *)
            echo "[ERROR] Unknown OS: $OS"
            exit 1
            ;;
    esac
}

detect_and_install_node

# Prepare logs directory
mkdir -p logs

DATE_FORMAT=$(date +%Y-%m-%d)

# Install dependencies
echo "[INFO] Installing Node.js dependencies..."
npm install | tee logs/setup_${DATE_FORMAT}.log

# Prepare .env file
if [ ! -f .env ]; then
    if [ -f .env_example ]; then
        cp .env_example .env
        echo "[INFO] Copied .env_example to .env"
    else
        echo "[ERROR] No .env or .env_example found. Cannot continue."
        exit 1
    fi
fi

echo "[Validator Setup] Setup complete."
./start.sh | tee logs/start_${DATE_FORMAT}.log
