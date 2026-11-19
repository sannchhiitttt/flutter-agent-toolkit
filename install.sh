#!/usr/bin/env bash
# ==============================================================================
# Flutter Agent Toolkit — Cross-Platform Installer (Linux & macOS)
# Installs MCP Servers (EvolveMem, Graphify, Marionette, Dart) & Agent Skills
# ==============================================================================

set -euo pipefail

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

log_info() { echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}${BOLD}[SUCCESS]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}${BOLD}[WARNING]${RESET} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${RESET} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PROJECT="${PWD}"
INSTALL_GLOBAL=false
NON_INTERACTIVE=false

print_banner() {
  echo -e "${CYAN}${BOLD}"
  echo "╔════════════════════════════════════════════════════════════════════╗"
  echo "║                   FLUTTER AGENT TOOLKIT                            ║"
  echo "║        AI-Agentic MCP Servers & Skills for Supercharged Flutter    ║"
  echo "╚════════════════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --target <dir>       Target Flutter/fullstack project directory (default: current directory)
  --global             Install skills globally (into ~/.gemini/skills, ~/.claude/skills, etc.)
  -y, --yes            Run in non-interactive mode with default answers
  -h, --help           Show this help message
EOF
  exit 0
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_PROJECT="$(cd "$2" && pwd)"
      shift 2
      ;;
    --global)
      INSTALL_GLOBAL=true
      shift
      ;;
    -y|--yes)
      NON_INTERACTIVE=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      log_error "Unknown option: $1"
      usage
      ;;
  esac
done

detect_os() {
  OS_TYPE="$(uname -s)"
  case "$OS_TYPE" in
    Linux)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="${ID:-linux}"
        DISTRO_NAME="${NAME:-Linux}"
      else
        DISTRO="linux"
        DISTRO_NAME="Linux"
      fi
      log_info "Detected OS: Linux ($DISTRO_NAME)"
      ;;
    Darwin)
      DISTRO="macos"
      DISTRO_NAME="macOS"
      log_info "Detected OS: Apple macOS"
      ;;
    *)
      log_error "Unsupported OS: $OS_TYPE. Please use install.ps1 on Windows."
      exit 1
      ;;
  esac
}

check_prerequisites() {
  log_info "Verifying core prerequisites..."

  # Check Git
  if ! command -v git &>/dev/null; then
    log_error "'git' is not installed. Please install git first."
    exit 1
  fi

  # Check Python 3
  if ! command -v python3 &>/dev/null; then
    log_error "'python3' is not installed. Please install Python 3.10+."
    exit 1
  fi

  # Check Dart / Flutter
  if ! command -v dart &>/dev/null; then
    # Look for flutter in common locations
    COMMON_FLUTTER_PATHS=(
      "$HOME/flutter/bin"
      "$HOME/Develop/flutter/bin"
      "$HOME/development/flutter/bin"
      "/opt/flutter/bin"
      "/usr/local/bin"
    )
    FOUND=false
    for p in "${COMMON_FLUTTER_PATHS[@]}"; do
      if [ -x "$p/dart" ]; then
        export PATH="$p:$PATH"
        FOUND=true
        log_info "Found Dart/Flutter SDK at $p"
        break
      fi
    done
    if [ "$FOUND" = false ]; then
      log_warn "Neither 'dart' nor 'flutter' was found in PATH."
      log_warn "Please ensure Flutter/Dart SDK is installed and added to your PATH."
    fi
  fi

  # Check or install Astral 'uv'
  if ! command -v uv &>/dev/null; then
    log_info "'uv' not found. Installing uv (fast Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  fi

  log_success "Core prerequisites verified."
}

install_mcp_servers() {
  echo ""
  log_info "------------------------------------------------------------"
  log_info "Step 1: Installing MCP Servers"
  log_info "------------------------------------------------------------"

  # 1. Marionette MCP (Flutter UI Automation)
  if command -v dart &>/dev/null; then
    log_info "Activating Marionette MCP via dart pub..."
    dart pub global activate marionette_mcp
    export PATH="$HOME/.pub-cache/bin:$PATH"
    log_success "marionette_mcp installed."
  else
    log_warn "Skipping marionette_mcp installation because 'dart' CLI is not found."
  fi

  # 2. Graphify MCP (Codebase AST & Knowledge Graph)
  log_info "Installing graphify MCP server..."
  if command -v uv &>/dev/null; then
    uv tool install --force graphifyy || pip3 install --user graphifyy
  else
    pip3 install --user graphifyy
  fi
  export PATH="$HOME/.local/bin:$PATH"
  log_success "graphify-mcp installed."

  # 3. EvolveMem MCP (Persistent Cross-Session Agent Memory)
  log_info "Setting up EvolveMem MCP server..."
  EVOLVEMEM_DIR="$HOME/.evolvemem"
  mkdir -p "$EVOLVEMEM_DIR"

  if [ ! -d "$EVOLVEMEM_DIR/venv" ]; then
    log_info "Creating dedicated virtual environment at $EVOLVEMEM_DIR/venv..."
    python3 -m venv "$EVOLVEMEM_DIR/venv"
  fi

  "$EVOLVEMEM_DIR/venv/bin/pip" install --quiet --upgrade pip
  "$EVOLVEMEM_DIR/venv/bin/pip" install --quiet -r "$SCRIPT_DIR/tools/evolvemem_mcp/requirements.txt"

  # Create wrapper runner script in ~/.local/bin
  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/evolvemem-mcp" <<RUNNER
#!/usr/bin/env bash
exec "$EVOLVEMEM_DIR/venv/bin/python" "$SCRIPT_DIR/tools/evolvemem_mcp/server.py" --db "$EVOLVEMEM_DIR/memories.sqlite3" "\$@"
RUNNER
  chmod +x "$HOME/.local/bin/evolvemem-mcp"
  log_success "EvolveMem MCP configured with SQLite storage at $EVOLVEMEM_DIR/memories.sqlite3"
}

install_skills() {
  echo ""
  log_info "------------------------------------------------------------"
  log_info "Step 2: Deploying Agent Skills"
  log_info "------------------------------------------------------------"

  SKILL_TARGET_DIRS=()

  if [ "$INSTALL_GLOBAL" = true ]; then
    SKILL_TARGET_DIRS+=(
      "$HOME/.gemini/skills"
      "$HOME/.claude/skills"
      "$HOME/.agents/skills"
    )
  else
    SKILL_TARGET_DIRS+=(
      "$TARGET_PROJECT/.gemini/skills"
      "$TARGET_PROJECT/.claude/skills"
      "$TARGET_PROJECT/.agents/skills"
    )
  fi

  for dest in "${SKILL_TARGET_DIRS[@]}"; do
    mkdir -p "$dest"
    log_info "Copying skills to $dest..."

    # Copy Flutter skills
    if [ -d "$SCRIPT_DIR/skills/flutter" ]; then
      cp -r "$SCRIPT_DIR/skills/flutter/"* "$dest/" 2>/dev/null || true
    fi

    # Copy Design & UI/UX skills
    if [ -d "$SCRIPT_DIR/skills/design" ]; then
      cp -r "$SCRIPT_DIR/skills/design/"* "$dest/" 2>/dev/null || true
    fi

    # Copy SEO skills
    if [ -d "$SCRIPT_DIR/skills/seo" ]; then
      cp -r "$SCRIPT_DIR/skills/seo/"* "$dest/" 2>/dev/null || true
    fi
  done

  log_success "Skills deployed successfully to project & agent environments."
}

generate_mcp_config() {
  echo ""
  log_info "------------------------------------------------------------"
  log_info "Step 3: Generating Project MCP Configuration"
  log_info "------------------------------------------------------------"

  mkdir -p "$TARGET_PROJECT/.vscode"
  TARGET_CONFIG="$TARGET_PROJECT/.vscode/mcp.json"
  TARGET_ROOT_CONFIG="$TARGET_PROJECT/.mcp.json"

  cat > "$TARGET_CONFIG" <<EOF
{
  "mcpServers": {
    "dart-mcp-server": {
      "command": "dart",
      "args": ["mcp-server"],
      "cwd": "\${workspaceFolder}"
    },
    "marionette_mcp": {
      "command": "marionette_mcp",
      "args": [],
      "cwd": "\${workspaceFolder}"
    },
    "graphify": {
      "command": "graphify-mcp",
      "args": [
        "--graph",
        "\${workspaceFolder}/.graphify_ast.json"
      ],
      "cwd": "\${workspaceFolder}"
    },
    "evolvemem-memory": {
      "command": "$EVOLVEMEM_DIR/venv/bin/python",
      "args": [
        "$SCRIPT_DIR/tools/evolvemem_mcp/server.py",
        "--db",
        "$EVOLVEMEM_DIR/memories.sqlite3"
      ],
      "cwd": "\${workspaceFolder}"
    }
  }
}
EOF

  cp "$TARGET_CONFIG" "$TARGET_ROOT_CONFIG"
  log_success "Created MCP configurations:"
  echo "  - $TARGET_CONFIG"
  echo "  - $TARGET_ROOT_CONFIG"
}

print_summary() {
  echo ""
  echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════════${RESET}"
  echo -e "${GREEN}${BOLD}🎉 Installation Complete! Flutter Agent Toolkit is Ready! 🎉${RESET}"
  echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════════${RESET}"
  echo ""
  echo -e "${BOLD}Installed MCP Servers:${RESET}"
  echo "  ✓ Dart SDK MCP Server       (dart mcp-server)"
  echo "  ✓ Marionette MCP Driver     (Live Flutter app testing & inspection)"
  echo "  ✓ Graphify MCP Server       (Codebase AST & dependency knowledge graph)"
  echo "  ✓ EvolveMem Memory Server   (Long-term episodic & semantic memory)"
  echo ""
  echo -e "${BOLD}Installed Skill Categories:${RESET}"
  echo "  ✓ Flutter & Dart: Architecture, testing, responsive layouts, error fixing"
  echo "  ✓ Frontend & UI/UX: ui-ux-pro-max, impeccable, taste-skill, web-design-guidelines"
  echo "  ✓ SEO Suite: Technical SEO, schema markup, crawlability for Flutter Web"
  echo ""
  echo -e "${BOLD}Next Steps:${RESET}"
  echo "  1. Open your project in Antigravity, Cursor, or VS Code."
  echo "  2. Ensure your shell PATH includes:"
  echo "     export PATH=\"\$HOME/.pub-cache/bin:\$HOME/.local/bin:\$PATH\""
  echo "  3. Start pair-programming with your AI agent!"
  echo ""
}

main() {
  print_banner
  detect_os
  check_prerequisites
  install_mcp_servers
  install_skills
  generate_mcp_config
  print_summary
}

main
